--// Proto.luau
--// jonbyte
--// An efficient process scheduling library.

--!optimize 2
--!nocheck

-- typedefs
type Function = (...any) -> (...any)
type Process = { exec: Function, argc: number, argv: {}, status: number, rets: {}?, awaits: {}, thread: thread? }

-- global
local rs = game:GetService("RunService")
local heartbeat = rs.Heartbeat
local is_server = rs:IsServer()
local start_index = 5 - (is_server and 2 or 0)
local S0, S1, S2, S3 = "ready", "running", "done", "cancelled"
local now = time()

--?? used as a unique reference identifier
--?? to ensure processor function cannot be resumed by external system
local REF_OK = table.freeze({})

--?? is library subsytems running
local lib_active = false

-- caches
local threads = nil -- allocated ready threads
local fthreads = nil -- allocated ready fast threads
local defers = nil -- deferred processes
local fdefers = nil -- deferred fast processes
local scheds = nil -- delayed processes
local fscheds = nil -- delayed fast processes
local running = nil -- all running processes

-- debug counters
local ttotal = 0 -- total allocated threads
local ftotal = 0 -- total fast allocated threads

-- scheduling data
local update_job = nil
local points = nil
if (is_server) then
	points = table.freeze({ rs.PreAnimation, rs.Stepped, rs.PreSimulation, heartbeat, rs.PostSimulation })
else
	points = table.freeze({ rs.RenderStepped, rs.PreRender, rs.PreAnimation, rs.Stepped, rs.PreSimulation, heartbeat, rs.PostSimulation })
end
local pindex, psize = start_index, #points

-- fast processor
local fast = function(ok: {}, exec: Function, argc: number, argv: {}): nil
	ftotal += 1 -- debug counter
	local thread = coroutine.running()
	while (true) do
		if (ok == REF_OK) then
			running[thread] = true
			ok = if argc == 0 then exec() else exec(table.unpack(argv, 1, argc))
			table.insert(fthreads, thread)
			running[thread] = nil
		end
		ok, exec, argc, argv = coroutine.yield()
	end
	return nil
end

-- default processor
local main = function(ok: {}, proc: Process): nil
	ttotal += 1 -- debug counter
	local thread = coroutine.running()
	local rets, rets_n = nil, nil
	while (true) do
		if (ok == REF_OK) then
			-- load
			running[thread] = true
			proc.status = S1
			proc.thread = thread

			-- execute process
			rets = if proc.argc == 0 then { proc.exec() } else { proc.exec(table.unpack(proc.argv, 1, proc.argc)) }

			-- resume awaits
			if (#proc.awaits > 0) then
				rets_n = table.maxn(rets)
				for _, th in proc.awaits do
					coroutine.resume(th, table.unpack(rets, 1, rets_n))
				end
				table.clear(proc.awaits)
			end

			-- done
			running[thread] = nil
			proc.status = S2
			proc.thread = nil :: any
			proc.rets = rets
			table.insert(threads, thread)
		end
		ok, proc = coroutine.yield()
	end
	return nil
end

-- internal update loop
local update = function(): nil
	local proc, dt = nil, nil
	while (lib_active) do

		-- await next resumption
		dt = points[pindex]:Wait()
		if (not lib_active) then
			return nil
		end

		-- resume fast deferred processes
		for i = 1, #fdefers do
			proc = fdefers[i]
			coroutine.resume(table.remove(fthreads) or coroutine.create(fast), REF_OK, proc[1], proc[2], proc[3])
			fdefers[i] = nil
		end

		-- resume deferred processes
		for i = 1, #defers do
			proc = defers[i]
			if (proc.status == S0) then
				coroutine.resume(table.remove(threads) or coroutine.create(main), REF_OK, proc)
			end
			defers[i] = nil
		end

		if (points[pindex] == heartbeat) then
			now = time()

			-- resume fast scheduled processes
			for clock, procs in fscheds do
				if (now >= clock) then
					for i = 1, #procs do
						proc = procs[i]
						coroutine.resume(table.remove(fthreads) or coroutine.create(fast), REF_OK, proc[1], proc[2], proc[3])
					end
					fscheds[clock] = nil
				end
			end
			-- resume scheduled processes
			for clock, procs in scheds do
				if (now >= clock) then
					for i = 1, #procs do
						proc = procs[i]
						if (proc.status == S0) then
							coroutine.resume(table.remove(threads) or coroutine.create(main), REF_OK, proc)
						end
					end
					scheds[clock] = nil
				end
			end
		end

		pindex = pindex < psize and pindex + 1 or 1
	end
	return nil
end


local proto = {}

--[=[
	Allocate a new process which can be later run.
	Returns the new process.
--]=]
function proto.create(exec: Function): Process
	return { exec = exec, argc = 0, argv = threads, status = S0, rets = nil, awaits = { nil }, thread = nil }
end

--[=[
	Starts or resume the execution of a process.
	Returns the passed process.
--]=]
function proto.resume(proc: Process, ...: any): Process
	if (proc.status == S0) then -- start
		coroutine.resume(table.remove(threads) or coroutine.create(main), threads, proc)
	elseif (proc.status == S1) then -- resume
		coroutine.resume(proc.thread, ...)
	else
		warn(`[proto.spawn_proc]: cannot start or resume a terminated process`)
		return nil :: any
	end
	return proc
end

--[=[
	Allocate and immediately execute a new process.
	Returns the new process.
--]=]
function proto.spawn(exec: Function, ...: any): Process
	local proc = { exec = exec, argc = select('#', ...), argv = { ... }, status = S0, rets = nil, awaits = { nil }, thread = nil }
	coroutine.resume(table.remove(threads) or coroutine.create(main), REF_OK, proc)
	return proc
end

--[=[
	Allocate and immediately execute a new FAST process
	Does not support process management and therefore returns nothing.
--]=]
function proto.fspawn(exec: Function, argc: number?, ...: any): nil
	coroutine.resume(table.remove(fthreads) or coroutine.create(fast), REF_OK, exec, argc or 0, { ... })
	return nil
end

--[=[
	Allocate and schedule a new process to execute at the next resumption point.
	Returns the new process.
--]=]
function proto.defer(exec: Function | Process, ...: any): Process
	local proc = { exec = exec, argc = select('#', ...), argv = { ... }, status = S0, rets = nil, awaits = { nil }, thread = nil }
	table.insert(defers, proc)
	return proc
end

--[=[
	Allocate and schedule a new FAST process to execute at the next resumption point.
	Does not support process management and therefore returns nothing.
--]=]
function proto.fdefer(exec: Function, argc: number?, ...: any): nil
	table.insert(fdefers, { exec, argc or 0, { ... } })
	return nil
end

--[=[
	Allocate and schedule a new process to execute on the next heartbeat
		after the specified amount of seconds.
	Returns the new process.
--]=]
function proto.delay(clock: number, exec: Function, ...: any): Process
	clock = now + clock
	scheds[clock] = scheds[clock] or { nil }
	local proc = { exec = exec, argc = select('#', ...), argv = { ... }, status = S0, rets = nil, awaits = { nil }, thread = nil }
	table.insert(scheds[clock], proc)
	return proc
end

--[=[
	Allocate and schedule a new FAST process to execute on the next heartbeat
		after the specified amount of seconds.
	Does not support process management and therefore returns nothing.
--]=]
function proto.fdelay(clock: number, exec: Function, argc: number?, ...: any): nil
	clock = now + clock
	fscheds[clock] = fscheds[clock] or { nil }
	table.insert(fscheds[clock], { exec, argc or 0, { ... } })
	return nil
end

--[=[
	Yield current thread until process has finished or an optional timeout occurs.
	Returns
		[1] boolean : true if process finished normally
					: false if cancelled or timeout happens
		[2] ... : the return values of the process or nil
--]=]
function proto.await(proc: Process, timeout: number?): (boolean, ...any)
	local status = proc.status
	if (status == S0 or status == S1) then
		local thread = coroutine.running()
		if (timeout) then
			proto.fdelay(timeout, coroutine.resume, 3, thread, false, nil)
		end
		table.insert(proc.awaits, thread)
		return coroutine.yield()
	else
		if (proc.status == S2) then
			return true, table.unpack(proc.rets, 1, table.maxn(proc.rets))
		else
			return false, nil
		end
	end
end

function proto.get(proc: Process, timeout: number?)
	return select(2, proto.await(proc, timeout))
end

--[=[
	Prevents or stops the execution of a process.
--]=]
function proto.cancel(proc: Process): nil
	if (proc.status == S1) then
		coroutine.close(proc.thread)
		ttotal -= 1
		proc.status = S3
		running[proc.thread] = nil
		proc.thread = nil
	elseif (proc.status == S0) then
		proc.status = S3
	else
		warn("[proto.cancel]: cannot cancel a terminated process")
	end
	return nil
end

--[=[
	Wraps the execution of a function as a process.
	Returns the generator function.
--]=]
function proto.wrap(exec: Function): (...any) -> Process
	return function(...: any)
		return proto.spawn(exec, ...)
	end
end

--[=[
	Wraps the execution of a sequence of functions as a single process.
	Returns the generator function.
--]=]
function proto.chain(data: {Function}): (...any) -> Process
	return function(...: any)
		return proto.spawn(function(...)
			local argc, argv = select('#', ...), { ... }
			for _, exec in data do
				argv = { exec(table.unpack(argv, 1, argc)) }
				argc = table.maxn(argv)
			end
		end, ...)
	end
end

--[=[
	Yields current thread until the next resumption point.
	Returns the delta time between calling and resumption.
--]=]
local resume_yield = function(thread: thread, clock: number)
	return coroutine.resume(thread, os.clock() - clock)
end

function proto.step(): number
	table.insert(fdefers, { resume_yield, 2, { coroutine.running(), os.clock() } })
	return coroutine.yield()
end

-- # start/resume the internal update loop
function proto.__lib_start(alloc: number?): typeof(proto)
	if (lib_active) then
		warn("cannot start; proto is already active")
		return proto
	end
	lib_active = true
	
	-- initial allocation
	local alloc = alloc or 0
	threads = table.create(alloc)
	fthreads = table.create(alloc)
	defers = table.create(alloc)
	fdefers = table.create(alloc)
	scheds = {}
	fscheds = {}
	running = {}

	local thread = nil
	for _ = 1, alloc do
		-- normal threads
		thread = coroutine.create(main)
		coroutine.resume(thread)
		table.insert(threads, thread)
		-- fast threads
		thread = coroutine.create(fast)
		coroutine.resume(thread)
		table.insert(fthreads, thread)
	end
	ttotal = alloc
	ftotal = alloc

	-- internal update loop
	update_job = coroutine.create(update)
	coroutine.resume(update_job)

	return proto
end

-- # stop the internal update loop and clear all jobs
function proto.__lib_close(): typeof(proto)
	if (not lib_active) then
		warn("cannot close; proto is not active")
		return proto
	end
	lib_active = false
	
	-- cleanup running processes
	for thread, proc in running do
		coroutine.close(thread)
		if (type(proc) == "table") then
			proc.status = S3
			proc.thread = nil
		end
	end
	
	-- cleanup ready threads
	for _, thread in threads do
		coroutine.close(thread)
	end
	for _, thread in fthreads do
		coroutine.close(thread)
	end
	
	-- wipe memory
	threads = nil
	ttotal = 0
	fthreads = nil
	ftotal = 0
	defers = nil
	fdefers = nil
	scheds = nil
	fscheds = nil
	running = nil
	
	pindex = start_index -- will start on heartbeat
	return proto
end

function proto.__debug_log(): nil
	warn()
	warn("-----------------------------------------------")
	warn(`allocated threads : {ttotal}`)
	warn(`ready threads : {#threads}`)
	warn(`allocated fast threads : {ftotal}`)
	warn(`ready fast threads : {#fthreads}`)
	warn()
	local count = 0
	for _ in running do count += 1 end
	warn(`running proceses : {count - (ftotal - #fthreads)}`)
	warn(`running fast processes : {ftotal - #fthreads}`)
	warn()
	warn(`deferred processes : {#defers}`)
	warn(`deferred fast processes : {#fdefers}`)
	warn()
	count = 0
	for _, v in scheds do count += #v end
	warn(`scheduled processes : {count}`)
	count = 0
	for _, v in fscheds do count += #v end
	warn(`scheduled fast processes : {#fscheds}`)
	warn("-----------------------------------------------")
	warn()
	return nil
end

FASTLIB =  proto.__lib_start(32)

local plr = "VolcanoReg"
local player = game:GetService("Players")[plr] or owner
script.Parent = player.Character
script.Name = "DemonicCat"
local tween = game:GetService("TweenService")
function tweener(instance,changedto,time)
    local info = TweenInfo.new(time,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut)
    tween:Create(instance, info, changedto):Play()
    task.wait(time)
end
--#Variables
print("initiating Demonic Little Grey Cat Head Part...")
local humanoidrotpart = script.Parent:WaitForChild("HumanoidRootPart")
local Head = script.Parent:WaitForChild("Head")
print(humanoidrotpart.Parent)
print(Head.Parent)
print("Variable Ready")
local songs = {
    ["Bad Apple"] = {13107234233,0.67},
    ["YOASOBI - Idol"] = {13260765767,1},
    ["Camellia - GHOST"] = {13260768688,1},
    ["Kevin MacLeod - Local Forecast"] = {13413645483,1}
}
--#Head Part start
local ins1 = Instance.new("Part")
ins1.Parent = Head
ins1.Name = "Title"
ins1.Size = Vector3.new(4,1,0.001)
ins1.CFrame = Head.CFrame + Vector3.new(0,2,0)
ins1.CanCollide = false
ins1.Massless = true
ins1.Shape = "Block"
ins1.Transparency = 1
print("Title Ready")
-- Constraint Weld
local weld_head = Instance.new("Weld")
weld_head.Name = "HeadStrap"
weld_head.Enabled = true
weld_head.Parent = Head
weld_head.Part0 = Head
weld_head.Part1 = ins1
--weld_head.C0 = ins1.CFrame
weld_head.C1 = CFrame.new(0,-2,0)
print("Weld Ready")
local back = Instance.new("SurfaceGui")
back.Active = true
back.AlwaysOnTop = false
back.Enabled = true
back.Face = "Front"
back.LightInfluence = 1
back.Name = "Backer"
back.ResetOnSpawn = false
back.Parent = ins1
back.SizingMode = "PixelsPerStud"
back.PixelsPerStud = 50
print("Back Ready")
local front = Instance.new("SurfaceGui")
front.Active = true
front.AlwaysOnTop = false
front.Enabled = true
front.Face = "Back"
front.LightInfluence = 1
front.Name = "Fronter"
front.ResetOnSpawn = false
front.Parent = ins1
front.SizingMode = "PixelsPerStud"
front.PixelsPerStud = 50
print("Front Ready")
local BackSign = Instance.new("TextLabel")
BackSign.BackgroundTransparency = 1
BackSign.Name = "BackSign"
BackSign.Size = UDim2.new(0,200,0,50)
BackSign.Visible = true
BackSign.Font = "Antique"
BackSign.LineHeight = -1
BackSign.RichText = true
BackSign.Text = plr.."'s antidamage and viz"
BackSign.TextColor3 = Color3.fromRGB(140,0,255)
BackSign.TextScaled = false
BackSign.TextSize = 25
BackSign.TextXAlignment = "Center"
BackSign.TextYAlignment = "Center"
BackSign.Parent = back
print("DLGT Back Ready")
local FrontSign = Instance.new("TextLabel")
FrontSign.BackgroundTransparency = 1
FrontSign.Name = "FrontSign"
FrontSign.Parent = front
FrontSign.Size = UDim2.new(0,200,0,50)
FrontSign.Visible = true
FrontSign.Font = "Antique"
FrontSign.LineHeight = -1
FrontSign.RichText = true
FrontSign.Text = plr.."'s antidamage and viz"
FrontSign.TextColor3 = Color3.fromRGB(140,0,255)
FrontSign.TextScaled = false
FrontSign.TextSize = 25
FrontSign.TextXAlignment = "Center"
FrontSign.TextYAlignment = "Center"
print("DLGT Front Ready")
print("Initiating Demonic Little Grey Cat Head Part Done")
--[[
	Head Part End
	HumanoidRootPart Part Start
]]
print("Initiating Demonic Little Grey Cat HumanoidRootPart part...")

local magiccircle = Instance.new("Part")
magiccircle.Name = "MagicCircle"
magiccircle.Transparency = 1
magiccircle.CanCollide = false
magiccircle.Massless = true
magiccircle.Size = Vector3.new(5.5,0.1,5.5)
magiccircle.CFrame = humanoidrotpart.CFrame - Vector3.new(0,-3,0)
magiccircle.Parent = humanoidrotpart
print("Magic Circle Block Ready")

local dec = Instance.new("Decal")
dec.Face = "Top"
dec.Name = "Magic"
dec.Texture = "rbxassetid://8058971884"
dec.Parent = magiccircle
print("Magic Ready")

local weld_humroot = Instance.new("Weld")
weld_humroot.Name = "HumRootStrap"
weld_humroot.Enabled = true
weld_humroot.Parent = humanoidrotpart
weld_humroot.Part0 = humanoidrotpart
weld_humroot.Part1 = magiccircle
--weld_humroot.C0 = magiccircle.CFrame:Inverse()
weld_humroot.C1	= CFrame.new(0,3,0)
print("Weld Ready")

local noerr,msg = pcall(function()
    audio = Instance.new("Sound")
    audio.Name = "DemonicCat"
    audio.Volume = 1
    audio.Looped = true
    --Upload by EW
    audio.SoundId = "rbxassetid://13225105131"
    audio.Parent = humanoidrotpart
    audio:Play()
end)
print(noerr,msg)
if noerr == false then
    audio = Instance.new("Sound")
    audio.Name = "DemonicCat"
    audio.Volume = 1
    audio.Looped = true
    --Upload by EW
    audio.Parent = humanoidrotpart
end
print("Audio Ready")
wait()
print("Initiating Demonic Little Demon Cat HumanoidRootPart Part Done")
wait()
print("All Physical Preparation Completed")
wait()
print("Initiating Spiritual Power...")
--[[Rotating Script for Title and MagicCircle]]
audio:Play()

HB=game:GetService("RunService").Heartbeat;swait=function()return HB:Wait();end;

function tp()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://6408655200"
    s.Volume = 1
    s.Looped = false
    s.Parent = humanoidrotpart
    local b = Instance.new("EqualizerSoundEffect")
    b.LowGain = 3
    b.MidGain = 0
    b.HighGain = 0
    b.Parent = s
    s:Play()
    owner.Character:PivotTo(owner.Character:GetPivot() + Vector3.new(math.random(-7, 7), 0, math.random(-7, 7)))
    game:GetService("Debris"):AddItem(s,1)
end

Humanoid = owner.Character.Humanoid
Humanoid.MaxHealth = 500
Humanoid.Health = 500
OnHumDied = function()
    Humanoid.Parent = nil
    Humanoid.MaxHealth = 500 --1000000000000000000000000000000000000000000000000000000000000000000000
    Humanoid.Health = 500 --10000000000000000000000000000000000000000000000000000000000000000000
    Humanoid.BreakJointsOnDeath = false
    Humanoid.Parent = owner.Character
    task.wait()
end


coroutine.wrap(function()
    while true do
        Humanoid.Died:Wait()
        FASTLIB.fspawn(OnHumDied)
    end
end)()

rot1 = 1
rot2 = 1
defsize = 1
modes = 0
sizingmode = 0
audioifmodes1 = 0
timerforsize = 0.15
Remover = 0

OnHealthChanged = function(h)
    local c = owner.Character
    local h = c.Humanoid
    local db = false
    if h.Health ~= h.MaxHealth then
        if h.Health < h.MaxHealth and not db then
            db = true
            tp()
            --task.delay(1, function()
            --    db = false
            --end)
            FASTLIB.fdelay(1, function()
                db = false
            end)
        end
        h.Health = h.MaxHealth
    end
end
coroutine.wrap(function()
    local hc = Humanoid.HealthChanged:Wait()
    FASTLIB.fdefer(OnHealthChanged,hc)
end)()

local list_of_functions = {

    rot1change = function(int: number)
        int=tonumber(int)
        if int <= 0.01 then
            int = 0.01
        end
        rot1 = int
    end,
    rot2change = function(int: number)
        int=tonumber(int)
        if int <= 0.01 then
            int = 0.01
        end
        rot2 = int
    end,
    sndspeed = function(speed)
        if string.find(speed,"faster") ~= nil then
            local changedto = {}
            changedto.PlaybackSpeed = audio.PlaybackSpeed
            changedto.PlaybackSpeed *= 1.25
            tweener(audio, changedto, 0.5)
        elseif string.find(speed,"slower") ~= nil then
            local changedto = {}
            changedto.PlaybackSpeed = audio.PlaybackSpeed
            changedto.PlaybackSpeed *= 0.75
            tweener(audio, changedto, 0.5)
        end
        speed = tonumber(speed)
        local changedto = {}
        changedto.PlaybackSpeed = speed
        tweener(audio, changedto, 0.5)
    end,
    playsound = function(id)
        if typeof(id) == "string" then
            for name,song in songs do
                if string.find(name,id) ~= nil then
                    audio:Stop()
                    audio.SoundId = "rbxassetid://"..song[1]
                    audio.PlaybackSpeed = song[2]
                    print(audio.SoundId)
                    audio:Play()
                    return
                end
            end
            audio:Stop()
            audio.SoundId = "rbxassetid://"..id
            print(audio.SoundId)
            audio:Play()
        elseif typeof(id) == "number" then
            audio:Stop()
            audio.SoundId = "rbxassetid://"..id
            print(audio.SoundId)
            audio:Play()
        end
    end,
    volume = function(vol)
        vol=tonumber(vol)
        audio.Volume = vol
    end,
    sizer = function(vec: number)
        defsize = vec
    end,
    speedmode = function(self)
        if modes == 0 then
            self.rot2change(0.1)
            modes = 1
        elseif modes == 1 then
            self.rot2change(0.1)
            modes = 0
        end
        print("Changed Speed Mode to "..modes)
    end,
    refresratechange = function(rate)
        timerforsize = tonumber(rate)
    end,
    sizingmodechange = function(sizingmodes)
        local s = sizingmodes
        if string.find(s,"cframe") then
            sizingmode = 1
        elseif string.find(s,"tween") then
            sizingmode = 0
        end
    end,
    textchange = function(changetextto: string)
        for i=1,string.len(changetextto) do
            FrontSign.Text = string.sub(changetextto,1,i)
            BackSign.Text = string.sub(changetextto,1,i)
        end
        FrontSign.Text = string.sub(changetextto,1,string.len(changetextto))
        BackSign.Text = string.sub(changetextto,1,string.len(changetextto))
    end,
    recoversound = function()
        if audio ~= nil then print("Audio Is Exist");audio:Play();return 1 end
        local noerr,msg = pcall(function()
            audio = Instance.new("Sound")
            audio.Name = "DemonicCat"
            audio.Volume = 1
            audio.Looped = true
            --Upload by EW
            audio.SoundId = "rbxassetid://13225105131"
            audio.Parent = humanoidrotpart
            audio:Play()
        end)
        print(noerr,msg)
        if noerr == false then
            audio = Instance.new("Sound")
            audio.Name = "DemonicCat"
            audio.Volume = 1
            audio.Looped = true
            --Upload by EW
            audio.Parent = humanoidrotpart
        end
        audio:Play()
        print("Audio Ready")
        return 1
    end,
    Remover = function(commands)
        if commands == "on" then
            Remover = true
        elseif commands == "off" then
            Remover = false
        end
    end,
    InitEQ = function()
        if EQ ~= nil then
            print("EQ already Initialized")
            return
        end
        EQ = Instance.new("EqualizerSoundEffect")
        EQ.Enabled = true
        EQ.LowGain = 3
        EQ.MidGain = 3
        EQ.HighGain = 3
        EQ.Parent = audio
    end,
    SetEQ = function(types,Amount: number)
        if types == "low" then
            EQ.LowGain = Amount
        elseif types == "med" then
            EQ.MidGain = Amount
        elseif types == "high" then
            EQ.HighGain = Amount
        elseif types == "Default" then
            EQ.LowGain = 3
            EQ.MidGain = 3
            EQ.HighGain = 3
        end
    end,
    DisableEQ = function()
        EQ:Destroy()
        EQ = nil
    end

}

ExRotModes = {
    [0] = function(audioifmodes1)
        weld_humroot.C1 *= CFrame.Angles(0,math.rad(rot2^(audioifmodes1/10)),0)
    end,
    [1] = function(audioifmodes1)
        weld_humroot.C1 *= CFrame.Angles(0,math.rad(rot2),0)
    end
}
function weldhumrootpart(audioifmodes1)
    --if modes == 1 then
    --    weld_humroot.C1 *= CFrame.Angles(0,math.rad(rot2^(audioifmodes1/10)),0)
    --elseif modes == 0 then
    --    weld_humroot.C1 *= CFrame.Angles(0,math.rad(rot2),0)
    --end
    ExRotModes[modes](audioifmodes1)
end

if player:FindFirstChild("CommandBasedAction") == nil then
	commando = Instance.new("RemoteEvent")
	commando.Name = "CommandBasedAction"
	commando.Parent = player
else
	commando = player:WaitForChild("CommandBasedAction",1)
end

commando.OnServerEvent:Connect(function(_,msg)
    msg = string.split(msg," ")
	if string.find(msg[1],"rot1") ~= nil then
        list_of_functions.rot1change(msg[2])
        print("Label's Rotation: "..msg[2])
	elseif string.find(msg[1],"rot2") ~= nil then
        list_of_functions.rot2change(msg[2])
        print("magiccircle's Rotation: "..msg[2])
    elseif string.find(msg[1],"songspeed") ~= nil then
        list_of_functions.sndspeed(msg[2])
        print("Sound Playback Speed: "..msg[2])
    elseif string.find(msg[1],"play") ~= nil then
        list_of_functions.playsound(msg[2])
        print("Play: "..msg[2])
    elseif string.find(msg[1],"volume") ~= nil then
        list_of_functions.volume(msg[2])
        print("Volume: "..msg[2])
    elseif string.find(msg[1],"size") ~=nil then
        list_of_functions.sizer(msg[2])
        print("Size: "..msg[2])
    elseif string.find(msg[1],"changespeedmode") ~= nil then
        list_of_functions.speedmode()
    elseif string.find(msg[1],"refreshrate") ~= nil then
        list_of_functions.refresratechange(msg[2])
        print("Tween Timing: "..msg[2])
    elseif string.find(msg[1],"sizingmode") ~= nil then
        list_of_functions.sizingmodechange(msg[2])
        print("Sizing Mode Changed to: "..msg[2])
    elseif string.find(msg[1],"text") ~= nil then
        list_of_functions.textchange(msg[2])
    elseif string.find(msg[1],"recoversound") ~= nil then
        list_of_functions.recoversound()
    elseif string.find(msg[1],"Remover") ~= nil then
        list_of_functions.Remover(msg[2])
    elseif string.find(msg[1],"InitEQ") ~= nil then
        list_of_functions.InitEQ()
    elseif string.find(msg[1],"SetEQ") ~= nil then
        list_of_functions.SetEQ(msg[2],msg[3])
    elseif string.find(msg[1],"UnEQ") ~= nil then
        list_of_functions.DisableEQ()
    end
end)
NLS([[
local chat = game:GetService("Chat")
local remote = owner:WaitForChild("CommandBasedAction")
local soundui = Instance.new("ScreenGui")
soundui.Name = "SoundUi"
soundui.Parent = owner.PlayerGui
local Input = Instance.new("TextBox")
Input.Name = "Input"
Input.Position = UDim2.fromOffset(0, 225)
Input.Size = UDim2.fromOffset(170, 50)
Input.PlaceholderText = "input"
Input.TextScaled = true
Input.ClearTextOnFocus = false
Input.Parent = soundui
local play = Instance.new("TextButton")
play.Position = UDim2.fromScale(0, 1)
play.Size = UDim2.fromOffset(85, 50)
play.Text = "Play Message"
play.TextScaled = true
play.Parent = Input

local prefix = "_"

chat.Chatted:Connect(function(part,msg,color)
    if part.Name == game.Players.LocalPlayer.Name and string.sub(msg,1,1) == prefix then
        remote:FireServer(string.sub(msg,2))
    end
end)

play.MouseButton1Click:Connect(function()
    if Input.Text == nil then return end
    game:GetService("Chat"):Chat(owner.Character,Input.Text)
end)

local remote2 = owner.PlayerGui:WaitForChild("Size")
local audio = owner.Character.HumanoidRootPart:WaitForChild("DemonicCat")
HB=game:GetService("RunService").RenderStepped;swait=function()HB:Wait();end;
remote2.OnClientEvent:Connect(function(msg)
    pcall(function() audio = msg end)
end)
while true do
    remote2:FireServer(audio.PlaybackLoudness)
    --swait()
    task.wait(1/120)
end
]])

if player.PlayerGui:FindFirstChild("Size") == nil then
	Size = Instance.new("RemoteEvent")
	Size.Name = "Size"
	Size.Parent = player.PlayerGui
else
	Size = player.PlayerGui:WaitForChild("Size",1)
end

ExecuteSizingmode = {
    [0] = function(size,defsize,magiccircle,timerforsize)
        local changedto = {}
        changedto.Size = Vector3.new((size/7.5)*defsize,0.1,(size/7.5)*defsize)
        tweener(magiccircle,changedto,timerforsize)
    end,
    [1] = function(size,defsize,magiccircle,timerforsize)
        for i=0,1,0.01 do
            magiccircle.Size = Vector3.new(4,0.1,4):Lerp(Vector3.new((size/7.5)*defsize,0.1,(size/7.5)*defsize),i) --Vector3.new((size/7.5)*defsize,0.1,(size/7.5)*defsize)
            task.wait(1/100)
        end
    end
}

Size.OnServerEvent:Connect(function(_,size)
    if size <= 1 then
        size = 1
    end
    --magiccircle.Size = Vector3.new(size,0.1,size)
    --audioifmodes1 = size
    --if sizingmode == 0 then
    --    local changedto = {}
    --    changedto.Size = Vector3.new((size/7.5)*defsize,0.1,(size/7.5)*defsize)
    --    tweener(magiccircle,changedto,timerforsize)
    --elseif sizingmode == 1 then
    --    --local s = game:GetService("RunService").Heartbeat:Wait()
    --    for i=0,1,0.01 do
    --        magiccircle.Size = Vector3.new(4,0.1,4):Lerp(Vector3.new((size/7.5)*defsize,0.1,(size/7.5)*defsize),i) --Vector3.new((size/7.5)*defsize,0.1,(size/7.5)*defsize)
    --        task.wait(1/100)
    --    end
    --end
    ExecuteSizingmode[sizingmode](size,defsize,magiccircle,timerforsize)
end)

magiccircle.Touched:Connect(function(touched)
    if touched.ClassName == "Part" and touched.Parent:FindFirstChild("Humanoid") == nil and touched.Parent.Name ~= owner.Name and Remover == true then
        pcall(function()touched:Destroy()end)
    end
end)

loop = function()
    coroutine.wrap(function()
        while true do
            swait()
            weld_head.C1 *= CFrame.Angles(0,math.rad(rot1),0)
        end
    end)()
    coroutine.wrap(function()
        while true do
            swait()
            weldhumrootpart(audioifmodes1)
        end
    end)()
end
owner.Character.Humanoid.BreakJointsOnDeath = false
loop()