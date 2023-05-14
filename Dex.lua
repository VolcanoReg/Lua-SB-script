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

local partsWithId = {}
local awaitRef = {}

local root = {
	ID = 0;
	Type = "ScreenGui";
	Properties = {
		Name = "Dex";
		ResetOnSpawn = false;
	};
	Children = {
		{
			ID = 1;
			Type = "Frame";
			Properties = {
				Position = UDim2.new(1,0,0.5,36);
				BackgroundTransparency = 0.10000000149011612;
				Name = "PropertiesFrame";
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Size = UDim2.new(0,300,0.5,-36);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 2;
					Type = "LocalScript";
					Properties = {
						Name = "Properties";
					};
					Children = {
						{
							ID = 3;
							Type = "ModuleScript";
							Properties = {
								Name = "RawApiJson";
							};
							Children = {};
						};
					};
				};
				{
					ID = 4;
					Type = "Frame";
					Properties = {
						Name = "Header";
						Position = UDim2.new(0,0,0,-36);
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,0,36);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 5;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								TextColor3 = Color3.new(0,0,0);
								Text = "Properties";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 1;
								Position = UDim2.new(0,4,0,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								TextSize = 14;
								Size = UDim2.new(1,-4,0.5,0);
							};
							Children = {};
						};
						{
							ID = 6;
							Type = "TextBox";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								TextColor3 = Color3.new(0,0,0);
								Text = "Search Properties";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.800000011920929;
								Position = UDim2.new(0,4,0.5,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								TextSize = 14;
								Size = UDim2.new(1,-8,0.5,-3);
							};
							Children = {};
						};
					};
				};
				{
					ID = 7;
					Type = "BindableFunction";
					Properties = {
						Name = "GetApi";
					};
					Children = {};
				};
				{
					ID = 8;
					Type = "BindableFunction";
					Properties = {
						Name = "GetAwaiting";
					};
					Children = {};
				};
				{
					ID = 9;
					Type = "BindableEvent";
					Properties = {
						Name = "SetAwaiting";
					};
					Children = {};
				};
			};
		};
		{
			ID = 10;
			Type = "Frame";
			Properties = {
				BackgroundTransparency = 0.10000000149011612;
				Name = "ExplorerPanel";
				Position = UDim2.new(1,0,0,0);
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Size = UDim2.new(0,300,0.5,0);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 11;
					Type = "BindableEvent";
					Properties = {
						Name = "SelectionChanged";
					};
					Children = {};
				};
				{
					ID = 12;
					Type = "BindableFunction";
					Properties = {
						Name = "SetOption";
					};
					Children = {};
				};
				{
					ID = 13;
					Type = "BindableFunction";
					Properties = {
						Name = "SetSelection";
					};
					Children = {};
				};
				{
					ID = 14;
					Type = "BindableFunction";
					Properties = {
						Name = "GetOption";
					};
					Children = {};
				};
				{
					ID = 15;
					Type = "BindableFunction";
					Properties = {
						Name = "GetSelection";
					};
					Children = {};
				};
				{
					ID = 16;
					Type = "LocalScript";
					Properties = {};
					Children = {};
				};
				{
					ID = 17;
					Type = "BindableFunction";
					Properties = {
						Name = "GetPrint";
					};
					Children = {};
				};
			};
		};
		{
			ID = 18;
			Type = "LocalScript";
			Properties = {
				Name = "Selection";
			};
			Children = {};
		};
		{
			ID = 19;
			Type = "Frame";
			Properties = {
				Visible = false;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				BackgroundTransparency = 1;
				Name = "SideMenu";
				Position = UDim2.new(1,-330,0,0);
				Size = UDim2.new(0,30,0,180);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 20;
					Type = "TextButton";
					Properties = {
						FontSize = Enum.FontSize.Size24;
						Active = false;
						TextTransparency = 1;
						Text = ">";
						TextSize = 24;
						AutoButtonColor = false;
						Size = UDim2.new(0,30,0,30);
						Font = Enum.Font.SourceSans;
						Name = "Toggle";
						Position = UDim2.new(0,0,0,60);
						TextWrapped = true;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
						BorderSizePixel = 0;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 21;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						Text = "DEX";
						BackgroundTransparency = 1;
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Title";
						Size = UDim2.new(0,30,0,20);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 14;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 22;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size12;
						Text = "v3";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,30,0,20);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Version";
						Position = UDim2.new(0,0,0,15);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 12;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 23;
					Type = "ImageLabel";
					Properties = {
						ImageColor3 = Color3.new(233/255,233/255,233/255);
						Image = "rbxassetid://1513966937";
						Name = "Slant";
						Position = UDim2.new(0,0,0,90);
						BackgroundTransparency = 1;
						Rotation = 180;
						Size = UDim2.new(0,30,0,30);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 24;
					Type = "Frame";
					Properties = {
						Size = UDim2.new(0,30,0,30);
						Name = "Main";
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {};
				};
				{
					ID = 25;
					Type = "Frame";
					Properties = {
						Position = UDim2.new(0,0,0,30);
						Name = "SlideOut";
						ClipsDescendants = true;
						BackgroundTransparency = 1;
						Size = UDim2.new(0,30,0,150);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(44/51,44/51,44/51);
					};
					Children = {
						{
							ID = 26;
							Type = "Frame";
							Properties = {
								Name = "SlideFrame";
								Position = UDim2.new(0,0,0,-120);
								Size = UDim2.new(0,30,0,120);
								BorderSizePixel = 0;
								BackgroundColor3 = Color3.new(44/51,44/51,44/51);
							};
							Children = {
								{
									ID = 27;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size24;
										Text = "";
										AutoButtonColor = false;
										Size = UDim2.new(0,30,0,30);
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 1;
										Position = UDim2.new(0,0,0,90);
										TextSize = 24;
										Name = "Explorer";
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {
										{
											ID = 28;
											Type = "ImageLabel";
											Properties = {
												ImageColor3 = Color3.new(14/51,14/51,14/51);
												Image = "rbxassetid://472635937";
												Name = "Icon";
												Position = UDim2.new(0,5,0,5);
												BackgroundTransparency = 1;
												ZIndex = 2;
												Size = UDim2.new(0,20,0,20);
												BackgroundColor3 = Color3.new(1,1,1);
											};
											Children = {};
										};
									};
								};
								{
									ID = 29;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size24;
										Text = "";
										AutoButtonColor = false;
										Size = UDim2.new(0,30,0,30);
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 1;
										Position = UDim2.new(0,0,0,60);
										TextSize = 24;
										Name = "SaveMap";
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {
										{
											ID = 30;
											Type = "ImageLabel";
											Properties = {
												ImageColor3 = Color3.new(14/51,14/51,14/51);
												Image = "rbxassetid://472636337";
												Name = "Icon";
												Position = UDim2.new(0,5,0,5);
												BackgroundTransparency = 1;
												ZIndex = 2;
												Size = UDim2.new(0,20,0,20);
												BackgroundColor3 = Color3.new(1,1,1);
											};
											Children = {};
										};
									};
								};
								{
									ID = 31;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size24;
										Text = "";
										AutoButtonColor = false;
										Size = UDim2.new(0,30,0,30);
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 1;
										Position = UDim2.new(0,0,0,30);
										TextSize = 24;
										Name = "Settings";
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {
										{
											ID = 32;
											Type = "ImageLabel";
											Properties = {
												ImageColor3 = Color3.new(14/51,14/51,14/51);
												Image = "rbxassetid://472635774";
												Name = "Icon";
												Position = UDim2.new(0,5,0,5);
												BackgroundTransparency = 1;
												ZIndex = 2;
												Size = UDim2.new(0,20,0,20);
												BackgroundColor3 = Color3.new(1,1,1);
											};
											Children = {};
										};
									};
								};
								{
									ID = 33;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size24;
										Text = "";
										AutoButtonColor = false;
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 1;
										Size = UDim2.new(0,30,0,30);
										Name = "About";
										TextSize = 24;
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {
										{
											ID = 34;
											Type = "ImageLabel";
											Properties = {
												ImageColor3 = Color3.new(14/51,14/51,14/51);
												Image = "rbxassetid://476354004";
												Name = "Icon";
												Position = UDim2.new(0,5,0,5);
												BackgroundTransparency = 1;
												ZIndex = 2;
												Size = UDim2.new(0,20,0,20);
												BackgroundColor3 = Color3.new(1,1,1);
											};
											Children = {};
										};
									};
								};
							};
						};
					};
				};
				{
					ID = 35;
					Type = "TextButton";
					Properties = {
						FontSize = Enum.FontSize.Size24;
						Active = false;
						Text = "";
						AutoButtonColor = false;
						Font = Enum.Font.SourceSans;
						Name = "OpenScriptEditor";
						Position = UDim2.new(0,0,0,30);
						Size = UDim2.new(0,30,0,30);
						TextSize = 24;
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 36;
							Type = "ImageLabel";
							Properties = {
								ImageColor3 = Color3.new(9/85,14/85,53/255);
								ImageTransparency = 1;
								BackgroundTransparency = 1;
								Image = "rbxassetid://475456048";
								Name = "Icon";
								Position = UDim2.new(0,5,0,5);
								Size = UDim2.new(0,20,0,20);
								ZIndex = 2;
								BorderSizePixel = 0;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 37;
			Type = "Frame";
			Properties = {
				BackgroundTransparency = 0.10000000149011612;
				Name = "SettingsPanel";
				Position = UDim2.new(1,0,0,0);
				BorderColor3 = Color3.new(191/255,191/255,191/255);
				Size = UDim2.new(0,300,1,0);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 38;
					Type = "Frame";
					Properties = {
						Name = "Header";
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,0,17);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 39;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								TextColor3 = Color3.new(0,0,0);
								Text = "Settings";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 1;
								Position = UDim2.new(0,4,0,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								TextSize = 14;
								BorderSizePixel = 0;
								Size = UDim2.new(1,-4,1,0);
							};
							Children = {};
						};
					};
				};
				{
					ID = 40;
					Type = "BindableFunction";
					Properties = {
						Name = "GetSetting";
					};
					Children = {};
				};
				{
					ID = 41;
					Type = "Frame";
					Properties = {
						Visible = false;
						Name = "SettingTemplate";
						Position = UDim2.new(0,0,0,18);
						BackgroundTransparency = 1;
						Size = UDim2.new(1,0,0,60);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 42;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								Text = "SettingName";
								TextXAlignment = Enum.TextXAlignment.Left;
								Font = Enum.Font.SourceSans;
								Name = "SName";
								Position = UDim2.new(0,10,0,0);
								BackgroundTransparency = 1;
								Size = UDim2.new(1,-20,0,30);
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 43;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								Text = "Off";
								TextXAlignment = Enum.TextXAlignment.Left;
								Font = Enum.Font.SourceSans;
								Name = "Status";
								Position = UDim2.new(0,60,0,30);
								BackgroundTransparency = 1;
								Size = UDim2.new(0,50,0,15);
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 44;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "";
								Font = Enum.Font.SourceSans;
								Name = "Change";
								Position = UDim2.new(0,10,0,30);
								TextSize = 14;
								Size = UDim2.new(0,40,0,15);
								BorderSizePixel = 0;
								BackgroundColor3 = Color3.new(44/51,44/51,44/51);
							};
							Children = {
								{
									ID = 45;
									Type = "TextLabel";
									Properties = {
										Font = Enum.Font.SourceSans;
										FontSize = Enum.FontSize.Size14;
										Name = "OnBar";
										TextSize = 14;
										Size = UDim2.new(0,0,0,15);
										Text = "";
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(0,49/85,44/51);
									};
									Children = {};
								};
								{
									ID = 46;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										ClipsDescendants = true;
										Text = "";
										Font = Enum.Font.SourceSans;
										Name = "Bar";
										Position = UDim2.new(0,-2,0,-2);
										Size = UDim2.new(0,10,0,19);
										TextSize = 14;
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(0,0,0);
									};
									Children = {};
								};
							};
						};
					};
				};
				{
					ID = 47;
					Type = "Frame";
					Properties = {
						Name = "SettingList";
						Position = UDim2.new(0,0,0,17);
						BackgroundTransparency = 1;
						Size = UDim2.new(1,0,1,-17);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
			};
		};
		{
			ID = 48;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Draggable = true;
				Name = "SaveInstance";
				Position = UDim2.new(0.30000001192092896,0,0.30000001192092896,0);
				Size = UDim2.new(0,350,0,20);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 49;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Save Instance";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 2;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
				{
					ID = 50;
					Type = "Frame";
					Properties = {
						Name = "MainWindow";
						BorderColor3 = Color3.new(191/255,191/255,191/255);
						BackgroundTransparency = 0.10000000149011612;
						Size = UDim2.new(1,0,0,200);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 51;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Save";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.07500000298023224,0,1,-40);
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Name = "Save";
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 52;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "This will save an instance to your PC. Type in the name for your instance. (.rbxmx will be added automatically.)";
								BackgroundTransparency = 1;
								TextWrapped = true;
								Font = Enum.Font.SourceSans;
								Name = "Desc";
								Position = UDim2.new(0,0,0,20);
								Size = UDim2.new(1,0,0,40);
								BackgroundColor3 = Color3.new(1,1,1);
								TextSize = 14;
								TextWrap = true;
							};
							Children = {};
						};
						{
							ID = 53;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Cancel";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.5249999761581421,0,1,-40);
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Name = "Cancel";
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 54;
							Type = "TextBox";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								Text = "";
								TextXAlignment = Enum.TextXAlignment.Left;
								Font = Enum.Font.SourceSans;
								Name = "FileName";
								Position = UDim2.new(0.07500000298023224,0,0.4000000059604645,0);
								BackgroundTransparency = 0.20000000298023224;
								Size = UDim2.new(0.8500000238418579,0,0,30);
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 55;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								TextColor3 = Color3.new(1,1,1);
								Text = "";
								Size = UDim2.new(0,20,0,20);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.6000000238418579;
								Position = UDim2.new(0.07500000298023224,0,0.625,0);
								Name = "SaveObjects";
								ZIndex = 2;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 56;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										BackgroundTransparency = 0.4000000059604645;
										Font = Enum.Font.SourceSans;
										Name = "enabled";
										Position = UDim2.new(0,3,0,3);
										TextSize = 14;
										Size = UDim2.new(0,14,0,14);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(97/255,97/255,97/255);
									};
									Children = {};
								};
							};
						};
						{
							ID = 57;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "Save \"Object\" type values";
								TextXAlignment = Enum.TextXAlignment.Left;
								Font = Enum.Font.SourceSans;
								Name = "Desc2";
								Position = UDim2.new(0.07500000298023224,30,0.625,0);
								BackgroundTransparency = 1;
								Size = UDim2.new(0.925000011920929,-30,0,20);
								TextSize = 14;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 58;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Draggable = true;
				Name = "Confirmation";
				Position = UDim2.new(0.5,-175,0.5,-75);
				Size = UDim2.new(0,350,0,20);
				ZIndex = 3;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 59;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Confirm";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 3;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
				{
					ID = 60;
					Type = "Frame";
					Properties = {
						Name = "MainWindow";
						BackgroundTransparency = 0.10000000149011612;
						BorderColor3 = Color3.new(191/255,191/255,191/255);
						ZIndex = 2;
						Size = UDim2.new(1,0,0,150);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 61;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Yes";
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.07500000298023224,0,1,-40);
								Name = "Yes";
								ZIndex = 2;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 62;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "The file, FILENAME, already exists. Overwrite?";
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,40);
								TextWrapped = true;
								Font = Enum.Font.SourceSans;
								Name = "Desc";
								Position = UDim2.new(0,0,0,20);
								BackgroundColor3 = Color3.new(1,1,1);
								ZIndex = 2;
								TextSize = 14;
								TextWrap = true;
							};
							Children = {};
						};
						{
							ID = 63;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "No";
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.5249999761581421,0,1,-40);
								Name = "No";
								ZIndex = 2;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 64;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Draggable = true;
				Name = "Caution";
				Position = UDim2.new(0.5,-175,0.5,-75);
				Size = UDim2.new(0,350,0,20);
				ZIndex = 5;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 65;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Caution";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 5;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
				{
					ID = 66;
					Type = "Frame";
					Properties = {
						Name = "MainWindow";
						BackgroundTransparency = 0.10000000149011612;
						BorderColor3 = Color3.new(191/255,191/255,191/255);
						ZIndex = 4;
						Size = UDim2.new(1,0,0,150);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 67;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "The file, FILENAME, already exists. Overwrite?";
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,42);
								TextWrapped = true;
								Font = Enum.Font.SourceSans;
								Name = "Desc";
								Position = UDim2.new(0,0,0,20);
								BackgroundColor3 = Color3.new(1,1,1);
								ZIndex = 4;
								TextSize = 14;
								TextWrap = true;
							};
							Children = {};
						};
						{
							ID = 68;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Ok";
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.30000001192092896,0,1,-40);
								Name = "Ok";
								ZIndex = 4;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 69;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Draggable = true;
				Name = "CallRemote";
				Position = UDim2.new(0.5,-175,0.5,-100);
				Size = UDim2.new(0,350,0,20);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 70;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Call Remote";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 2;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
				{
					ID = 71;
					Type = "Frame";
					Properties = {
						Name = "MainWindow";
						BorderColor3 = Color3.new(191/255,191/255,191/255);
						BackgroundTransparency = 0.10000000149011612;
						Size = UDim2.new(1,0,0,200);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 72;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "Arguments";
								BackgroundTransparency = 1;
								TextWrapped = true;
								Font = Enum.Font.SourceSans;
								Name = "Desc";
								Position = UDim2.new(0,0,0,20);
								Size = UDim2.new(1,0,0,20);
								BackgroundColor3 = Color3.new(1,1,1);
								TextSize = 14;
								TextWrap = true;
							};
							Children = {};
						};
						{
							ID = 73;
							Type = "ScrollingFrame";
							Properties = {
								MidImage = "rbxasset://textures/blackBkg_square.png";
								Size = UDim2.new(1,0,0,80);
								BackgroundTransparency = 1;
								Position = UDim2.new(0,0,0,40);
								Name = "Arguments";
								ScrollingDirection = Enum.ScrollingDirection.Y;
								TopImage = "rbxasset://textures/blackBkg_square.png";
								BottomImage = "rbxasset://textures/blackBkg_square.png";
								BackgroundColor3 = Color3.new(1,1,1);
								CanvasSize = UDim2.new();
							};
							Children = {};
						};
						{
							ID = 74;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								TextColor3 = Color3.new(1,1,1);
								Text = "";
								Size = UDim2.new(0,20,0,20);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.6000000238418579;
								Position = UDim2.new(0.07500000298023224,0,0.625,0);
								Name = "DisplayReturned";
								ZIndex = 2;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 75;
									Type = "TextLabel";
									Properties = {
										Visible = false;
										FontSize = Enum.FontSize.Size14;
										Text = "";
										BackgroundTransparency = 0.4000000059604645;
										Font = Enum.Font.SourceSans;
										Name = "enabled";
										Position = UDim2.new(0,3,0,3);
										Size = UDim2.new(0,14,0,14);
										TextSize = 14;
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(97/255,97/255,97/255);
									};
									Children = {};
								};
							};
						};
						{
							ID = 76;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "Display values returned";
								TextXAlignment = Enum.TextXAlignment.Left;
								Font = Enum.Font.SourceSans;
								Name = "Desc2";
								Position = UDim2.new(0.07500000298023224,30,0.625,0);
								BackgroundTransparency = 1;
								Size = UDim2.new(0.925000011920929,-30,0,20);
								TextSize = 14;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 77;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size24;
								BorderColor3 = Color3.new(0,0,0);
								Text = "+";
								Font = Enum.Font.SourceSansBold;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.800000011920929,0,0.625,0);
								Size = UDim2.new(0,20,0,20);
								Name = "Add";
								TextSize = 24;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 78;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size24;
								BorderColor3 = Color3.new(0,0,0);
								Text = "-";
								Font = Enum.Font.SourceSansBold;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.8999999761581421,0,0.625,0);
								Size = UDim2.new(0,20,0,20);
								Name = "Subtract";
								TextSize = 24;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 79;
							Type = "Frame";
							Properties = {
								Visible = false;
								Name = "ArgumentTemplate";
								BorderColor3 = Color3.new(191/255,191/255,191/255);
								BackgroundTransparency = 0.5;
								Size = UDim2.new(1,0,0,20);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 80;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										BorderColor3 = Color3.new(0,0,0);
										Text = "Script";
										Font = Enum.Font.SourceSans;
										Name = "Type";
										BackgroundTransparency = 0.8999999761581421;
										Size = UDim2.new(0.4000000059604645,0,0,20);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 81;
									Type = "TextBox";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "Value";
										Position = UDim2.new(0.4000000059604645,0,0,0);
										BackgroundTransparency = 0.8999999761581421;
										Size = UDim2.new(0.6000000238418579,-12,0,20);
										TextSize = 14;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
							};
						};
						{
							ID = 82;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Cancel";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.5249999761581421,0,1,-40);
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Name = "Cancel";
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 83;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Call";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.07500000298023224,0,1,-40);
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Name = "Ok";
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 84;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Draggable = true;
				Name = "TableCaution";
				Position = UDim2.new(0.30000001192092896,0,0.30000001192092896,0);
				Size = UDim2.new(0,350,0,20);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 85;
					Type = "Frame";
					Properties = {
						Name = "MainWindow";
						BorderColor3 = Color3.new(191/255,191/255,191/255);
						BackgroundTransparency = 0.10000000149011612;
						Size = UDim2.new(1,0,0,150);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 86;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Ok";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.30000001192092896,0,1,-40);
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Name = "Ok";
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 87;
							Type = "ScrollingFrame";
							Properties = {
								MidImage = "rbxasset://textures/blackBkg_square.png";
								Size = UDim2.new(1,0,0,80);
								BackgroundTransparency = 1;
								Position = UDim2.new(0,0,0,20);
								Name = "TableResults";
								ScrollingDirection = Enum.ScrollingDirection.Y;
								TopImage = "rbxasset://textures/blackBkg_square.png";
								BottomImage = "rbxasset://textures/blackBkg_square.png";
								BackgroundColor3 = Color3.new(1,1,1);
								CanvasSize = UDim2.new();
							};
							Children = {};
						};
						{
							ID = 88;
							Type = "Frame";
							Properties = {
								Visible = false;
								Name = "TableTemplate";
								BorderColor3 = Color3.new(191/255,191/255,191/255);
								BackgroundTransparency = 0.5;
								Size = UDim2.new(1,0,0,20);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 89;
									Type = "TextLabel";
									Properties = {
										BackgroundTransparency = 0.8999999761581421;
										FontSize = Enum.FontSize.Size18;
										Name = "Type";
										Font = Enum.Font.SourceSans;
										Size = UDim2.new(0.4000000059604645,0,0,20);
										Text = "Script";
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 90;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "Script";
										Font = Enum.Font.SourceSans;
										Name = "Value";
										Position = UDim2.new(0.4000000059604645,0,0,0);
										BackgroundTransparency = 0.8999999761581421;
										Size = UDim2.new(0.6000000238418579,-12,0,20);
										TextSize = 14;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
							};
						};
					};
				};
				{
					ID = 91;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Caution";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 2;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
			};
		};
		{
			ID = 92;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Name = "ScriptEditor";
				Position = UDim2.new(0.5,-258,0.5,-208);
				Draggable = true;
				ZIndex = 5;
				Size = UDim2.new(0,516,0,20);
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 93;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Script Viewer";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 5;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
				{
					ID = 94;
					Type = "Frame";
					Properties = {
						Name = "Cover";
						Position = UDim2.new(0,0,3,0);
						Size = UDim2.new(0,516,0,416);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 95;
					Type = "Frame";
					Properties = {
						Name = "EditorGrid";
						Position = UDim2.new(0,0,3,0);
						Size = UDim2.new(0,500,0,400);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 96;
					Type = "Frame";
					Properties = {
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,3,0);
						Name = "TopBar";
						BackgroundColor3 = Color3.new(16/17,16/17,16/17);
					};
					Children = {
						{
							ID = 97;
							Type = "ImageButton";
							Properties = {
								Position = UDim2.new(1,-32,0,40);
								Name = "ScriptBarLeft";
								Active = false;
								BorderColor3 = Color3.new(149/255,149/255,149/255);
								Size = UDim2.new(0,16,0,20);
								BackgroundColor3 = Color3.new(13/15,13/15,13/15);
								AutoButtonColor = false;
							};
							Children = {
								{
									ID = 98;
									Type = "Frame";
									Properties = {
										Name = "Arrow Graphic";
										Position = UDim2.new(0.5,-4,0.5,-4);
										BackgroundTransparency = 1;
										BorderSizePixel = 0;
										Size = UDim2.new(0,8,0,8);
									};
									Children = {
										{
											ID = 99;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.25,0,0.375,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.25,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 100;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.375,0,0.25,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.5,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 101;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.5,0,0.125,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.75,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 102;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.625,0,0,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,1,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
									};
								};
							};
						};
						{
							ID = 103;
							Type = "ImageButton";
							Properties = {
								Position = UDim2.new(1,-16,0,40);
								Name = "ScriptBarRight";
								Active = false;
								BorderColor3 = Color3.new(149/255,149/255,149/255);
								Size = UDim2.new(0,16,0,20);
								BackgroundColor3 = Color3.new(13/15,13/15,13/15);
								AutoButtonColor = false;
							};
							Children = {
								{
									ID = 104;
									Type = "Frame";
									Properties = {
										Name = "Arrow Graphic";
										Position = UDim2.new(0.5,-4,0.5,-4);
										BackgroundTransparency = 1;
										BorderSizePixel = 0;
										Size = UDim2.new(0,8,0,8);
									};
									Children = {
										{
											ID = 105;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.625,0,0.375,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.25,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 106;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.5,0,0.25,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.5,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 107;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.375,0,0.125,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.75,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 108;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.25,0,0,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,1,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
									};
								};
							};
						};
						{
							ID = 109;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								BorderColor3 = Color3.new(0,0,0);
								Text = "To Clipboard";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0,0,0,20);
								Size = UDim2.new(0,80,0,20);
								Name = "Clipboard";
								TextSize = 14;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 110;
							Type = "Frame";
							Properties = {
								Name = "ScriptBar";
								ClipsDescendants = true;
								BorderColor3 = Color3.new(149/255,149/255,149/255);
								Position = UDim2.new(0,0,0,40);
								Size = UDim2.new(1,-32,0,20);
								BackgroundColor3 = Color3.new(14/17,14/17,14/17);
							};
							Children = {};
						};
						{
							ID = 111;
							Type = "Frame";
							Properties = {
								Visible = false;
								Name = "Entry";
								BackgroundTransparency = 1;
								Size = UDim2.new(0,100,1,0);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 112;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size12;
										ClipsDescendants = true;
										BorderColor3 = Color3.new(0,0,0);
										Text = "";
										Size = UDim2.new(1,0,1,0);
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 0.6000000238418579;
										TextXAlignment = Enum.TextXAlignment.Left;
										Name = "Button";
										ZIndex = 4;
										TextSize = 12;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 113;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										BorderColor3 = Color3.new(0,0,0);
										Text = "X";
										Size = UDim2.new(0,20,0,20);
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 1;
										Position = UDim2.new(1,-20,0,0);
										Name = "Close";
										ZIndex = 4;
										TextSize = 14;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
							};
						};
					};
				};
				{
					ID = 114;
					Type = "BindableEvent";
					Properties = {
						Name = "OpenScript";
					};
					Children = {};
				};
				{
					ID = 115;
					Type = "LocalScript";
					Properties = {};
					Children = {};
				};
				{
					ID = 116;
					Type = "TextButton";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						BorderColor3 = Color3.new(0,0,0);
						Text = "X";
						Size = UDim2.new(0,20,0,20);
						Font = Enum.Font.SourceSans;
						BackgroundTransparency = 1;
						Position = UDim2.new(1,-20,0,0);
						Name = "Close";
						ZIndex = 5;
						TextSize = 14;
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
			};
		};
		{
			ID = 117;
			Type = "Frame";
			Properties = {
				Name = "IntroFrame";
				Position = UDim2.new(1,30,0,0);
				Size = UDim2.new(0,301,1,0);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(49/51,49/51,49/51);
			};
			Children = {
				{
					ID = 118;
					Type = "Frame";
					Properties = {
						Name = "Main";
						Position = UDim2.new(0,-30,0,0);
						Size = UDim2.new(0,30,0,90);
						ZIndex = 2;
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(49/51,49/51,49/51);
					};
					Children = {};
				};
				{
					ID = 119;
					Type = "ImageLabel";
					Properties = {
						ImageColor3 = Color3.new(49/51,49/51,49/51);
						Rotation = 180;
						Image = "rbxassetid://1513966937";
						BackgroundTransparency = 1;
						Position = UDim2.new(0,-30,0,90);
						Name = "Slant";
						ZIndex = 2;
						Size = UDim2.new(0,30,0,30);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 120;
					Type = "Frame";
					Properties = {
						Name = "Main";
						Position = UDim2.new(0,-30,0,0);
						Size = UDim2.new(0,30,0,90);
						ZIndex = 2;
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(49/51,49/51,49/51);
					};
					Children = {};
				};
				{
					ID = 121;
					Type = "ImageLabel";
					Properties = {
						ImageColor3 = Color3.new(49/51,49/51,49/51);
						Image = "rbxassetid://483437370";
						Name = "Sad";
						Position = UDim2.new(0,50,1,-250);
						BackgroundTransparency = 1;
						ZIndex = 2;
						Size = UDim2.new(0,200,0,200);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 122;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size28;
						Text = "By Moon";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,140,0,30);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Creator";
						Position = UDim2.new(0,80,0,300);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 28;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 123;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size60;
						Text = "DEX";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,100,0,60);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Title";
						Position = UDim2.new(0,100,0,150);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 60;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 124;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size28;
						Text = "v3";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,100,0,30);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Version";
						Position = UDim2.new(0,100,0,210);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 28;
						TextWrap = true;
					};
					Children = {};
				};
			};
		};
		{
			ID = 125;
			Type = "Frame";
			Properties = {
				BackgroundTransparency = 0.10000000149011612;
				Name = "SaveMapWindow";
				Position = UDim2.new(1,0,0,0);
				BorderColor3 = Color3.new(191/255,191/255,191/255);
				Size = UDim2.new(0,300,1,0);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 126;
					Type = "Frame";
					Properties = {
						Name = "Header";
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,0,17);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 127;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								TextColor3 = Color3.new(0,0,0);
								Text = "Map Downloader";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 1;
								Position = UDim2.new(0,4,0,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								TextSize = 14;
								BorderSizePixel = 0;
								Size = UDim2.new(1,-4,1,0);
							};
							Children = {};
						};
					};
				};
				{
					ID = 128;
					Type = "Frame";
					Properties = {
						Name = "MapSettings";
						Position = UDim2.new(0,0,0,200);
						BackgroundTransparency = 1;
						Size = UDim2.new(1,0,0,240);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 129;
							Type = "Frame";
							Properties = {
								Name = "Terrain";
								Position = UDim2.new(0,0,0,60);
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,60);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 130;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Save Terrain";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "SName";
										Position = UDim2.new(0,10,0,0);
										BackgroundTransparency = 1;
										Size = UDim2.new(1,-20,0,30);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 131;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Off";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "Status";
										Position = UDim2.new(0,60,0,30);
										BackgroundTransparency = 1;
										Size = UDim2.new(0,50,0,15);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 132;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										Font = Enum.Font.SourceSans;
										Name = "Change";
										Position = UDim2.new(0,10,0,30);
										TextSize = 14;
										Size = UDim2.new(0,40,0,15);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(44/51,44/51,44/51);
									};
									Children = {
										{
											ID = 133;
											Type = "TextLabel";
											Properties = {
												Font = Enum.Font.SourceSans;
												FontSize = Enum.FontSize.Size14;
												Name = "OnBar";
												TextSize = 14;
												Size = UDim2.new(0,0,0,15);
												Text = "";
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,49/85,44/51);
											};
											Children = {};
										};
										{
											ID = 134;
											Type = "TextLabel";
											Properties = {
												FontSize = Enum.FontSize.Size14;
												ClipsDescendants = true;
												Text = "";
												Font = Enum.Font.SourceSans;
												Name = "Bar";
												Position = UDim2.new(0,-2,0,-2);
												Size = UDim2.new(0,10,0,19);
												TextSize = 14;
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,0,0);
											};
											Children = {};
										};
									};
								};
							};
						};
						{
							ID = 135;
							Type = "Frame";
							Properties = {
								Name = "Lighting";
								Position = UDim2.new(0,0,0,120);
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,60);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 136;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Lighting Properties";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "SName";
										Position = UDim2.new(0,10,0,0);
										BackgroundTransparency = 1;
										Size = UDim2.new(1,-20,0,30);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 137;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Off";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "Status";
										Position = UDim2.new(0,60,0,30);
										BackgroundTransparency = 1;
										Size = UDim2.new(0,50,0,15);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 138;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										Font = Enum.Font.SourceSans;
										Name = "Change";
										Position = UDim2.new(0,10,0,30);
										TextSize = 14;
										Size = UDim2.new(0,40,0,15);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(44/51,44/51,44/51);
									};
									Children = {
										{
											ID = 139;
											Type = "TextLabel";
											Properties = {
												Font = Enum.Font.SourceSans;
												FontSize = Enum.FontSize.Size14;
												Name = "OnBar";
												TextSize = 14;
												Size = UDim2.new(0,0,0,15);
												Text = "";
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,49/85,44/51);
											};
											Children = {};
										};
										{
											ID = 140;
											Type = "TextLabel";
											Properties = {
												FontSize = Enum.FontSize.Size14;
												ClipsDescendants = true;
												Text = "";
												Font = Enum.Font.SourceSans;
												Name = "Bar";
												Position = UDim2.new(0,-2,0,-2);
												Size = UDim2.new(0,10,0,19);
												TextSize = 14;
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,0,0);
											};
											Children = {};
										};
									};
								};
							};
						};
						{
							ID = 141;
							Type = "Frame";
							Properties = {
								Name = "CameraInstances";
								Position = UDim2.new(0,0,0,180);
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,60);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 142;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Camera Instances";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "SName";
										Position = UDim2.new(0,10,0,0);
										BackgroundTransparency = 1;
										Size = UDim2.new(1,-20,0,30);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 143;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Off";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "Status";
										Position = UDim2.new(0,60,0,30);
										BackgroundTransparency = 1;
										Size = UDim2.new(0,50,0,15);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 144;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										Font = Enum.Font.SourceSans;
										Name = "Change";
										Position = UDim2.new(0,10,0,30);
										TextSize = 14;
										Size = UDim2.new(0,40,0,15);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(44/51,44/51,44/51);
									};
									Children = {
										{
											ID = 145;
											Type = "TextLabel";
											Properties = {
												Font = Enum.Font.SourceSans;
												FontSize = Enum.FontSize.Size14;
												Name = "OnBar";
												TextSize = 14;
												Size = UDim2.new(0,0,0,15);
												Text = "";
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,49/85,44/51);
											};
											Children = {};
										};
										{
											ID = 146;
											Type = "TextLabel";
											Properties = {
												FontSize = Enum.FontSize.Size14;
												ClipsDescendants = true;
												Text = "";
												Font = Enum.Font.SourceSans;
												Name = "Bar";
												Position = UDim2.new(0,-2,0,-2);
												Size = UDim2.new(0,10,0,19);
												TextSize = 14;
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,0,0);
											};
											Children = {};
										};
									};
								};
							};
						};
						{
							ID = 147;
							Type = "Frame";
							Properties = {
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,60);
								Name = "Scripts";
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 148;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Save Scripts";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "SName";
										Position = UDim2.new(0,10,0,0);
										BackgroundTransparency = 1;
										Size = UDim2.new(1,-20,0,30);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 149;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Off";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "Status";
										Position = UDim2.new(0,60,0,30);
										BackgroundTransparency = 1;
										Size = UDim2.new(0,50,0,15);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 150;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										Font = Enum.Font.SourceSans;
										Name = "Change";
										Position = UDim2.new(0,10,0,30);
										TextSize = 14;
										Size = UDim2.new(0,40,0,15);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(44/51,44/51,44/51);
									};
									Children = {
										{
											ID = 151;
											Type = "TextLabel";
											Properties = {
												Font = Enum.Font.SourceSans;
												FontSize = Enum.FontSize.Size14;
												Name = "OnBar";
												TextSize = 14;
												Size = UDim2.new(0,0,0,15);
												Text = "";
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,49/85,44/51);
											};
											Children = {};
										};
										{
											ID = 152;
											Type = "TextLabel";
											Properties = {
												FontSize = Enum.FontSize.Size14;
												ClipsDescendants = true;
												Text = "";
												Font = Enum.Font.SourceSans;
												Name = "Bar";
												Position = UDim2.new(0,-2,0,-2);
												Size = UDim2.new(0,10,0,19);
												TextSize = 14;
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,0,0);
											};
											Children = {};
										};
									};
								};
							};
						};
					};
				};
				{
					ID = 153;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size18;
						TextColor3 = Color3.new(0,0,0);
						Text = "To Save";
						Font = Enum.Font.SourceSans;
						Name = "ToSave";
						Position = UDim2.new(0,0,0,17);
						BackgroundTransparency = 1;
						TextSize = 18;
						Size = UDim2.new(1,0,0,20);
					};
					Children = {};
				};
				{
					ID = 154;
					Type = "Frame";
					Properties = {
						Name = "CopyList";
						Position = UDim2.new(0,0,0,37);
						BackgroundTransparency = 0.800000011920929;
						Size = UDim2.new(1,0,0,163);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 155;
					Type = "Frame";
					Properties = {
						Name = "Bottom";
						Position = UDim2.new(0,0,1,-50);
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,0,50);
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 156;
							Type = "TextLabel";
							Properties = {
								TextWrapped = true;
								TextColor3 = Color3.new(0,0,0);
								Text = "After the map saves, open a new place on studio, then right click Lighting and \"Insert from file...\", then select your file and run the unpacker script inside the folder.";
								TextXAlignment = Enum.TextXAlignment.Left;
								FontSize = Enum.FontSize.Size14;
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 1;
								Position = UDim2.new(0,4,0,0);
								Size = UDim2.new(1,-4,1,0);
								TextYAlignment = Enum.TextYAlignment.Top;
								TextSize = 14;
								TextWrap = true;
							};
							Children = {};
						};
					};
				};
				{
					ID = 157;
					Type = "TextButton";
					Properties = {
						FontSize = Enum.FontSize.Size18;
						BorderColor3 = Color3.new(0,0,0);
						Text = "Save";
						Font = Enum.Font.SourceSans;
						BackgroundTransparency = 0.800000011920929;
						Position = UDim2.new(0,0,1,-80);
						Size = UDim2.new(1,0,0,30);
						Name = "Save";
						TextSize = 18;
						BackgroundColor3 = Color3.new(16/17,16/17,16/17);
					};
					Children = {};
				};
				{
					ID = 158;
					Type = "TextBox";
					Properties = {
						FontSize = Enum.FontSize.Size18;
						Text = "PlaceName";
						TextXAlignment = Enum.TextXAlignment.Left;
						Font = Enum.Font.SourceSans;
						Name = "FileName";
						Position = UDim2.new(0,0,1,-105);
						BackgroundTransparency = 0.6000000238418579;
						Size = UDim2.new(1,0,0,25);
						TextSize = 18;
						BackgroundColor3 = Color3.new(16/17,16/17,16/17);
					};
					Children = {};
				};
				{
					ID = 159;
					Type = "Frame";
					Properties = {
						Visible = false;
						Name = "Entry";
						BackgroundTransparency = 1;
						Size = UDim2.new(1,0,0,22);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 160;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								TextColor3 = Color3.new(1,1,1);
								Text = "";
								Size = UDim2.new(0,20,0,20);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.6000000238418579;
								Position = UDim2.new(0,10,0,1);
								Name = "Change";
								ZIndex = 2;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 161;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										BackgroundTransparency = 0.4000000059604645;
										Font = Enum.Font.SourceSans;
										Name = "enabled";
										Position = UDim2.new(0,3,0,3);
										TextSize = 14;
										Size = UDim2.new(0,14,0,14);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(97/255,97/255,97/255);
									};
									Children = {};
								};
							};
						};
						{
							ID = 162;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								TextColor3 = Color3.new(0,0,0);
								Text = "Workspace";
								Font = Enum.Font.SourceSans;
								Name = "Info";
								Position = UDim2.new(0,40,0,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								BackgroundTransparency = 1;
								TextSize = 18;
								Size = UDim2.new(1,-40,0,22);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 163;
			Type = "Frame";
			Properties = {
				BackgroundTransparency = 0.10000000149011612;
				Name = "RemoteDebugWindow";
				Position = UDim2.new(1,0,0,0);
				BorderColor3 = Color3.new(191/255,191/255,191/255);
				Size = UDim2.new(0,300,1,0);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 164;
					Type = "Frame";
					Properties = {
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,0,17);
						Name = "Header";
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 165;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								TextColor3 = Color3.new(0,0,0);
								Text = "Remote Debugger";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 1;
								Position = UDim2.new(0,4,0,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								TextSize = 14;
								Size = UDim2.new(1,-4,1,0);
							};
							Children = {};
						};
					};
				};
				{
					ID = 166;
					Type = "BindableFunction";
					Properties = {
						Name = "GetSetting";
					};
					Children = {};
				};
				{
					ID = 167;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size32;
						Text = "Have fun with remotes";
						BackgroundTransparency = 1;
						TextWrapped = true;
						Font = Enum.Font.SourceSans;
						Name = "Desc";
						Position = UDim2.new(0,0,0,20);
						Size = UDim2.new(1,0,0,40);
						BackgroundColor3 = Color3.new(1,1,1);
						TextSize = 32;
						TextWrap = true;
					};
					Children = {};
				};
			};
		};
		{
			ID = 168;
			Type = "Frame";
			Properties = {
				Draggable = true;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Name = "About";
				Position = UDim2.new(1,0,0,0);
				Size = UDim2.new(0,300,1,0);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 169;
					Type = "ImageLabel";
					Properties = {
						ImageColor3 = Color3.new(49/51,49/51,49/51);
						Image = "rbxassetid://483437370";
						Name = "Sad";
						Position = UDim2.new(0,50,1,-250);
						BackgroundTransparency = 1;
						ZIndex = 2;
						Size = UDim2.new(0,200,0,200);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 170;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size28;
						Text = "By Moon";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,140,0,30);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Creator";
						Position = UDim2.new(0,80,0,300);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 28;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 171;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size60;
						Text = "DEX";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,100,0,60);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Title";
						Position = UDim2.new(0,100,0,150);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 60;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 172;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size28;
						Text = "v3";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,100,0,30);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Version";
						Position = UDim2.new(0,100,0,210);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 28;
						TextWrap = true;
					};
					Children = {};
				};
			};
		};
		{
			ID = 173;
			Type = "ImageButton";
			Properties = {
				ImageColor3 = Color3.new(233/255,233/255,233/255);
				Image = "rbxassetid://1513966937";
				Name = "Toggle";
				Position = UDim2.new(1,0,0,0);
				Rotation = 180;
				Size = UDim2.new(0,40,0,40);
				BackgroundTransparency = 1;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 174;
					Type = "TextLabel";
					Properties = {
						TextWrapped = true;
						Text = "<";
						BackgroundColor3 = Color3.new(1,1,1);
						Rotation = 180;
						Font = Enum.Font.SourceSans;
						BackgroundTransparency = 1;
						Position = UDim2.new(0,2,0,10);
						FontSize = Enum.FontSize.Size24;
						Size = UDim2.new(0,30,0,30);
						TextSize = 24;
						TextWrap = true;
					};
					Children = {};
				};
			};
		};
		{
			ID = 175;
			Type = "Folder";
			Properties = {
				Name = "TempPastes";
			};
			Children = {};
		};
	};
};

local function Scan(item, parent)
	local obj = Instance.new(item.Type)
	if (item.ID) then
		local awaiting = awaitRef[item.ID]
		if (awaiting) then
			awaiting[1][awaiting[2]] = obj
			awaitRef[item.ID] = nil
		else
			partsWithId[item.ID] = obj
		end
	end
	for p,v in pairs(item.Properties) do
		do1 = function(p,v)if (type(v) == "string") then
			local id = tonumber(v:match("^_R:(%w+)_$"))
			if (id) then
				if (partsWithId[id]) then
					v = partsWithId[id]
				else
					awaitRef[id] = {obj, p}
					v = nil
				end
			end
		end
		obj[p] = v
        task.wait()
		end
		FASTLIB.fdefer(do1,p,v)
	end
	for _,c in pairs(item.Children) do
		Scan(c, obj)
        task.wait()
	end
	obj.Parent = parent
	return obj
end
Scan(root, owner.PlayerGui)
print("GUIDONE")
owner.PlayerGui:WaitForChild("Dex"):WaitForChild("TempPastes").Parent = game.LocalizationService
local Gui = owner.PlayerGui:WaitForChild("Dex")

local IntroFrame = Gui:WaitForChild("IntroFrame")

local SideMenu = Gui:WaitForChild("SideMenu")
local OpenToggleButton = Gui:WaitForChild("Toggle")
local CloseToggleButton = SideMenu:WaitForChild("Toggle")
local OpenScriptEditorButton = SideMenu:WaitForChild("OpenScriptEditor")

local ScriptEditor = Gui:WaitForChild("ScriptEditor")

local SlideOut = SideMenu:WaitForChild("SlideOut")
local SlideFrame = SlideOut:WaitForChild("SlideFrame")
local Slant = SideMenu:WaitForChild("Slant")

local ExplorerButton = SlideFrame:WaitForChild("Explorer")
local SettingsButton = SlideFrame:WaitForChild("Settings")

local SelectionBox = Instance.new("SelectionBox")
SelectionBox.Parent = Gui

local ExplorerPanel = Gui:WaitForChild("ExplorerPanel")
local PropertiesFrame = Gui:WaitForChild("PropertiesFrame")
local SaveMapWindow = Gui:WaitForChild("SaveMapWindow")
local RemoteDebugWindow = Gui:WaitForChild("RemoteDebugWindow")

local SettingsPanel = Gui:WaitForChild("SettingsPanel")
local AboutPanel = Gui:WaitForChild("About")
local SettingsListener = SettingsPanel:WaitForChild("GetSetting")
local SettingTemplate = SettingsPanel:WaitForChild("SettingTemplate")
local SettingList = SettingsPanel:WaitForChild("SettingList")

local SaveMapCopyList = SaveMapWindow:WaitForChild("CopyList")
local SaveMapSettingFrame = SaveMapWindow:WaitForChild("MapSettings")
local SaveMapName = SaveMapWindow:WaitForChild("FileName")
local SaveMapButton = SaveMapWindow:WaitForChild("Save")
local SaveMapCopyTemplate = SaveMapWindow:WaitForChild("Entry")
local SaveMapSettings = {
	CopyWhat = {
		Workspace = true,
		Lighting = true,
		ReplicatedStorage = true,
		ReplicatedFirst = true,
		StarterPack = true,
		StarterGui = true,
		StarterPlayer = true
	},
	SaveScripts = true,
	SaveTerrain = true,
	LightingProperties = true,
	CameraInstances = true
}

--[[
local ClickSelectOption = SettingsPanel:WaitForChild("ClickSelect"):WaitForChild("Change")
local SelectionBoxOption = SettingsPanel:WaitForChild("SelectionBox"):WaitForChild("Change")
local ClearPropsOption = SettingsPanel:WaitForChild("ClearProperties"):WaitForChild("Change")
local SelectUngroupedOption = SettingsPanel:WaitForChild("SelectUngrouped"):WaitForChild("Change")
--]]

local SelectionChanged = ExplorerPanel:WaitForChild("SelectionChanged")
local GetSelection = ExplorerPanel:WaitForChild("GetSelection")
local SetSelection = ExplorerPanel:WaitForChild("SetSelection")

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local CurrentWindow = "Nothing c:"
local Windows = {
	Explorer = {
		ExplorerPanel,
		PropertiesFrame
	},
	Settings = {SettingsPanel},
	SaveMap = {SaveMapWindow},
	Remotes = {RemoteDebugWindow},
	About = {AboutPanel},
}

function switchWindows(wName,over)
	if CurrentWindow == wName and not over then return end
	
	local count = 0
	
	for i,v in pairs(Windows) do
		count = 0
		if i ~= wName then
			for _,c in pairs(v) do c:TweenPosition(UDim2.new(1, 30, count * 0.5, count * 36), "Out", "Quad", 0.5, true) count = count + 1 end
		end
	end
	
	count = 0
	
	if Windows[wName] then
		for _,c in pairs(Windows[wName]) do c:TweenPosition(UDim2.new(1, -300, count * 0.5, count * 36), "Out", "Quad", 0.5, true) count = count + 1 end
	end
	
	if wName ~= "Nothing c:" then
		CurrentWindow = wName
		for i,v in pairs(SlideFrame:GetChildren()) do
			v.BackgroundTransparency = 1
			v.Icon.ImageColor3 = Color3.new(70/255, 70/255, 70/255)
		end
		if SlideFrame:FindFirstChild(wName) then
			SlideFrame[wName].BackgroundTransparency = 0.5
			SlideFrame[wName].Icon.ImageColor3 = Color3.new(0,0,0)
		end
	end
end

function toggleDex(on)
	if on then
		SideMenu:TweenPosition(UDim2.new(1, -330, 0, 0), "Out", "Quad", 0.5, true)
		OpenToggleButton:TweenPosition(UDim2.new(1,0,0,0), "Out", "Quad", 0.5, true)
		switchWindows(CurrentWindow,true)
	else
		SideMenu:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
		OpenToggleButton:TweenPosition(UDim2.new(1,-40,0,0), "Out", "Quad", 0.5, true)
		switchWindows("Nothing c:")
	end
end

local Settings = {
	ClickSelect = false,
	SelBox = false,
	ClearProps = false,
	SelectUngrouped = true,
	SaveInstanceScripts = true
}

function ReturnSetting(set)
	if set == "ClearProps" then
		return Settings.ClearProps
	elseif set == "SelectUngrouped" then
		return Settings.SelectUngrouped
	end
end

OpenToggleButton.MouseButton1Up:connect(function()
	toggleDex(true)
end)

OpenScriptEditorButton.MouseButton1Up:connect(function()
	if OpenScriptEditorButton.Active then
		ScriptEditor.Visible = true
	end
end)

CloseToggleButton.MouseButton1Up:connect(function()
	if CloseToggleButton.Active then
		toggleDex(false)
	end
end)

--[[
OpenToggleButton.MouseButton1Up:connect(function()
	SideMenu:TweenPosition(UDim2.new(1, -330, 0, 0), "Out", "Quad", 0.5, true)
	
	if CurrentWindow == "Explorer" then
		ExplorerPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
		PropertiesFrame:TweenPosition(UDim2.new(1, -300, 0.5, 36), "Out", "Quad", 0.5, true)
	else
		SettingsPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
	end
	
	OpenToggleButton:TweenPosition(UDim2.new(1,0,0,0), "Out", "Quad", 0.5, true)
end)

CloseToggleButton.MouseButton1Up:connect(function()
	SideMenu:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
	
	ExplorerPanel:TweenPosition(UDim2.new(1, 30, 0, 0), "Out", "Quad", 0.5, true)
	PropertiesFrame:TweenPosition(UDim2.new(1, 30, 0.5, 36), "Out", "Quad", 0.5, true)
	SettingsPanel:TweenPosition(UDim2.new(1, 30, 0, 0), "Out", "Quad", 0.5, true)
	
	OpenToggleButton:TweenPosition(UDim2.new(1,-30,0,0), "Out", "Quad", 0.5, true)
end)
--]]

--[[
ExplorerButton.MouseButton1Up:connect(function()
	switchWindows("Explorer")
end)

SettingsButton.MouseButton1Up:connect(function()
	switchWindows("Settings")
end)
--]]

for i,v in pairs(SlideFrame:GetChildren()) do
	v.MouseButton1Click:connect(function()
		switchWindows(v.Name)
	end)
	
	v.MouseEnter:connect(function()v.BackgroundTransparency = 0.5 end)
	v.MouseLeave:connect(function()if CurrentWindow~=v.Name then v.BackgroundTransparency = 1 end end)
end

--[[
ExplorerButton.MouseButton1Up:connect(function()
	if CurrentWindow ~= "Explorer" then
		CurrentWindow = "Explorer"
		
		ExplorerPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
		PropertiesFrame:TweenPosition(UDim2.new(1, -300, 0.5, 36), "Out", "Quad", 0.5, true)
		SettingsPanel:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
	end
end)

SettingsButton.MouseButton1Up:connect(function()
	if CurrentWindow ~= "Settings" then
		CurrentWindow = "Settings"
		
		ExplorerPanel:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
		PropertiesFrame:TweenPosition(UDim2.new(1, 0, 0.5, 36), "Out", "Quad", 0.5, true)
		SettingsPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
	end
end)
--]]

function createSetting(name,interName,defaultOn)
	local newSetting = SettingTemplate:Clone()
	newSetting.Position = UDim2.new(0,0,0,#SettingList:GetChildren() * 60)
	newSetting.SName.Text = name
	
	local function toggle(on)
		if on then
			newSetting.Change.Bar:TweenPosition(UDim2.new(0,32,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Change.OnBar:TweenSize(UDim2.new(0,34,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Status.Text = "On"
			Settings[interName] = true
		else
			newSetting.Change.Bar:TweenPosition(UDim2.new(0,-2,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Change.OnBar:TweenSize(UDim2.new(0,0,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Status.Text = "Off"
			Settings[interName] = false
		end
	end	
	
	newSetting.Change.MouseButton1Click:connect(function()
		toggle(not Settings[interName])
	end)
	
	newSetting.Visible = true
	newSetting.Parent = SettingList
	
	if defaultOn then
		toggle(true)
	end
end

createSetting("Click part to select","ClickSelect",false)
createSetting("Selection Box","SelBox",false)
createSetting("Clear property value on focus","ClearProps",false)
createSetting("Select ungrouped models","SelectUngrouped",true)
createSetting("SaveInstance decompiles scripts","SaveInstanceScripts",true)

--[[
ClickSelectOption.MouseButton1Up:connect(function()
	if Settings.ClickSelect then
		Settings.ClickSelect = false
		ClickSelectOption.Text = "OFF"
	else
		Settings.ClickSelect = true
		ClickSelectOption.Text = "ON"
	end
end)

SelectionBoxOption.MouseButton1Up:connect(function()
	if Settings.SelBox then
		Settings.SelBox = false
		SelectionBox.Adornee = nil
		SelectionBoxOption.Text = "OFF"
	else
		Settings.SelBox = true
		SelectionBoxOption.Text = "ON"
	end
end)

ClearPropsOption.MouseButton1Up:connect(function()
	if Settings.ClearProps then
		Settings.ClearProps = false
		ClearPropsOption.Text = "OFF"
	else
		Settings.ClearProps = true
		ClearPropsOption.Text = "ON"
	end
end)

SelectUngroupedOption.MouseButton1Up:connect(function()
	if Settings.SelectUngrouped then
		Settings.SelectUngrouped = false
		SelectUngroupedOption.Text = "OFF"
	else
		Settings.SelectUngrouped = true
		SelectUngroupedOption.Text = "ON"
	end
end)
--]]

local function getSelection()
	local t = GetSelection:Invoke()
	if t and #t > 0 then
		return t[1]
	else
		return nil
	end
end

Mouse.Button1Down:connect(function()
	if CurrentWindow == "Explorer" and Settings.ClickSelect then
		local target = Mouse.Target
		if target then
			SetSelection:Invoke({target})
		end
	end
end)

SelectionChanged.Event:connect(function()
	if Settings.SelBox then
		local success,err = pcall(function()
			local selection = getSelection()
			SelectionBox.Adornee = selection
		end)
		if err then
			SelectionBox.Adornee = nil
		end
	end
end)

SettingsListener.OnInvoke = ReturnSetting

-- Map Copier

function createMapSetting(obj,interName,defaultOn)
	local function toggle(on)
		if on then
			obj.Change.Bar:TweenPosition(UDim2.new(0,32,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Change.OnBar:TweenSize(UDim2.new(0,34,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Status.Text = "On"
			SaveMapSettings[interName] = true
		else
			obj.Change.Bar:TweenPosition(UDim2.new(0,-2,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Change.OnBar:TweenSize(UDim2.new(0,0,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Status.Text = "Off"
			SaveMapSettings[interName] = false
		end
	end	
	
	obj.Change.MouseButton1Click:connect(function()
		toggle(not SaveMapSettings[interName])
	end)
	
	obj.Visible = true
	obj.Parent = SaveMapSettingFrame
	
	if defaultOn then
		toggle(true)
	end
end

function createCopyWhatSetting(serv)
	if SaveMapSettings.CopyWhat[serv] then
		local newSetting = SaveMapCopyTemplate:Clone()
		newSetting.Position = UDim2.new(0,0,0,#SaveMapCopyList:GetChildren() * 22 + 5)
		newSetting.Info.Text = serv
		
		local function toggle(on)
			if on then
				newSetting.Change.enabled.Visible = true
				SaveMapSettings.CopyWhat[serv] = true
			else
				newSetting.Change.enabled.Visible = false
				SaveMapSettings.CopyWhat[serv] = false
			end
		end	
	
		newSetting.Change.MouseButton1Click:connect(function()
			toggle(not SaveMapSettings.CopyWhat[serv])
		end)
		
		newSetting.Visible = true
		newSetting.Parent = SaveMapCopyList
	end
end

createMapSetting(SaveMapSettingFrame.Scripts,"SaveScripts",true)
createMapSetting(SaveMapSettingFrame.Terrain,"SaveTerrain",true)
createMapSetting(SaveMapSettingFrame.Lighting,"LightingProperties",true)
createMapSetting(SaveMapSettingFrame.CameraInstances,"CameraInstances",true)

createCopyWhatSetting("Workspace")
createCopyWhatSetting("Lighting")
createCopyWhatSetting("ReplicatedStorage")
createCopyWhatSetting("ReplicatedFirst")
createCopyWhatSetting("StarterPack")
createCopyWhatSetting("StarterGui")
createCopyWhatSetting("StarterPlayer")

SaveMapName.Text = tostring(game.PlaceId).."MapCopy"

SaveMapButton.MouseButton1Click:connect(function()
	local copyWhat = {}

	local copyGroup = Instance.new("Model",game:GetService('ReplicatedStorage'))

	local copyScripts = SaveMapSettings.SaveScripts

	local copyTerrain = SaveMapSettings.SaveTerrain

	local lightingProperties = SaveMapSettings.LightingProperties

	local cameraInstances = SaveMapSettings.CameraInstances

	-----------------------------------------------------------------------------------

	for i,v in pairs(SaveMapSettings.CopyWhat) do
		if v then
			table.insert(copyWhat,i)
		end
	end

	local consoleFunc = printconsole or writeconsole

	if consoleFunc then
		consoleFunc("Moon's place copier loaded.")
		consoleFunc("Copying map of game "..tostring(game.PlaceId)..".")
	end

	function archivable(root)
		for i,v in pairs(root:GetChildren()) do
			if not game:GetService('Players'):GetPlayerFromCharacter(v) then
				v.Archivable = true
				archivable(v)
			end
		end
	end

	function decompileS(root)
		for i,v in pairs(root:GetChildren()) do
			pcall(function()
				if v:IsA("LocalScript") then
					local isDisabled = v.Disabled
					v.Disabled = true
					v.Source = decompile(v)
					v.Disabled = isDisabled
				
					if v.Source == "" then 
						if consoleFunc then consoleFunc("LocalScript "..v.Name.." had a problem decompiling.") end
					else
						if consoleFunc then consoleFunc("LocalScript "..v.Name.." decompiled.") end
					end
				elseif v:IsA("ModuleScript") then
					v.Source = decompile(v)
				
					if v.Source == "" then 
						if consoleFunc then consoleFunc("ModuleScript "..v.Name.." had a problem decompiling.") end
					else
						if consoleFunc then consoleFunc("ModuleScript "..v.Name.." decompiled.") end
					end
				end
			end)
			decompileS(v)
		end
	end

	for i,v in pairs(copyWhat) do archivable(game[v]) end

	for j,obj in pairs(copyWhat) do
		if obj ~= "StarterPlayer" then
			local newFolder = Instance.new("Folder",copyGroup)
			newFolder.Name = obj
			for i,v in pairs(game[obj]:GetChildren()) do
				if v ~= copyGroup then
					pcall(function()
						v:Clone().Parent = newFolder
					end)
				end
			end
		else
			local newFolder = Instance.new("Model",copyGroup)
			newFolder.Name = "StarterPlayer"
			for i,v in pairs(game[obj]:GetChildren()) do
				local newObj = Instance.new("Folder",newFolder)
				newObj.Name = v.Name
				for _,c in pairs(v:GetChildren()) do
					if c.Name ~= "ControlScript" and c.Name ~= "CameraScript" then
						c:Clone().Parent = newObj
					end
				end
			end
		end
	end

	if workspace.CurrentCamera and cameraInstances then
		local cameraFolder = Instance.new("Model",copyGroup)
		cameraFolder.Name = "CameraItems"
		for i,v in pairs(workspace.CurrentCamera:GetChildren()) do v:Clone().Parent = cameraFolder end
	end

	if copyTerrain then
		local myTerrain = workspace.Terrain:CopyRegion(workspace.Terrain.MaxExtents)
		myTerrain.Parent = copyGroup
	end

	function saveProp(obj,prop,par)
		local myProp = obj[prop]
		if type(myProp) == "boolean" then
			local newProp = Instance.new("BoolValue",par)
			newProp.Name = prop
			newProp.Value = myProp
		elseif type(myProp) == "number" then
			local newProp = Instance.new("IntValue",par)
			newProp.Name = prop
			newProp.Value = myProp
		elseif type(myProp) == "string" then
			local newProp = Instance.new("StringValue",par)
			newProp.Name = prop
			newProp.Value = myProp
		elseif type(myProp) == "userdata" then -- Assume Color3
			pcall(function()
				local newProp = Instance.new("Color3Value",par)
				newProp.Name = prop
				newProp.Value = myProp
			end)
		end
	end

	if lightingProperties then
		local lightingProps = Instance.new("Model",copyGroup)
		lightingProps.Name = "LightingProperties"
	
		saveProp(game:GetService('Lighting'),"Ambient",lightingProps)
		saveProp(game:GetService('Lighting'),"Brightness",lightingProps)
		saveProp(game:GetService('Lighting'),"ColorShift_Bottom",lightingProps)
		saveProp(game:GetService('Lighting'),"ColorShift_Top",lightingProps)
		saveProp(game:GetService('Lighting'),"GlobalShadows",lightingProps)
		saveProp(game:GetService('Lighting'),"OutdoorAmbient",lightingProps)
		saveProp(game:GetService('Lighting'),"Outlines",lightingProps)
		saveProp(game:GetService('Lighting'),"GeographicLatitude",lightingProps)
		saveProp(game:GetService('Lighting'),"TimeOfDay",lightingProps)
		saveProp(game:GetService('Lighting'),"FogColor",lightingProps)
		saveProp(game:GetService('Lighting'),"FogEnd",lightingProps)
		saveProp(game:GetService('Lighting'),"FogStart",lightingProps)
	end

	if decompile and copyScripts then
		decompileS(copyGroup)
	end

	if SaveInstance then
		SaveInstance(copyGroup,SaveMapName.Text..".rbxm")
	elseif saveinstance then
		saveinstance(getelysianpath()..SaveMapName.Text..".rbxm",copyGroup)
	end
	--print("Saved!")
	if consoleFunc then
		consoleFunc("The map has been copied.")
	end
	SaveMapButton.Text = "The map has been saved"
	wait(5)
	SaveMapButton.Text = "Save"
end)

-- End Copier

wait()

IntroFrame:TweenPosition(UDim2.new(1,-301,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)

switchWindows("Explorer")

wait(1)

SideMenu.Visible = true

for i = 0,1,0.1 do
	IntroFrame.BackgroundTransparency = i
	IntroFrame.Main.BackgroundTransparency = i
	IntroFrame.Slant.ImageTransparency = i
	IntroFrame.Title.TextTransparency = i
	IntroFrame.Version.TextTransparency = i
	IntroFrame.Creator.TextTransparency = i
	IntroFrame.Sad.ImageTransparency = i
	wait()
end

IntroFrame.Visible = false

SlideFrame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)
OpenScriptEditorButton:TweenPosition(UDim2.new(0,0,0,150),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)
CloseToggleButton:TweenPosition(UDim2.new(0,0,0,180),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)
Slant:TweenPosition(UDim2.new(0,0,0,210),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)

wait(0.5)

for i = 1,0,-0.1 do
	OpenScriptEditorButton.Icon.ImageTransparency = i
	CloseToggleButton.TextTransparency = i
	wait()
end

CloseToggleButton.Active = true
CloseToggleButton.AutoButtonColor = true

OpenScriptEditorButton.Active = true
OpenScriptEditorButton.AutoButtonColor = true


NLS([[owner.PlayerGui:WaitForChild("Dex"):WaitForChild("TempPastes").Parent=game.LocalizationService;local a=owner.PlayerGui:WaitForChild("Dex")local b=a:WaitForChild("IntroFrame")local c=a:WaitForChild("SideMenu")local d=a:WaitForChild("Toggle")local e=c:WaitForChild("Toggle")local f=c:WaitForChild("OpenScriptEditor")local g=a:WaitForChild("ScriptEditor")local h=c:WaitForChild("SlideOut")local i=h:WaitForChild("SlideFrame")local j=c:WaitForChild("Slant")local k=i:WaitForChild("Explorer")local l=i:WaitForChild("Settings")local m=Instance.new("SelectionBox")m.Parent=a;local n=a:WaitForChild("ExplorerPanel")local o=a:WaitForChild("PropertiesFrame")local p=a:WaitForChild("SaveMapWindow")local q=a:WaitForChild("RemoteDebugWindow")local r=a:WaitForChild("SettingsPanel")local s=a:WaitForChild("About")local t=r:WaitForChild("GetSetting")local u=r:WaitForChild("SettingTemplate")local v=r:WaitForChild("SettingList")local w=p:WaitForChild("CopyList")local x=p:WaitForChild("MapSettings")local y=p:WaitForChild("FileName")local z=p:WaitForChild("Save")local A=p:WaitForChild("Entry")local B={CopyWhat={Workspace=true,Lighting=true,ReplicatedStorage=true,ReplicatedFirst=true,StarterPack=true,StarterGui=true,StarterPlayer=true},SaveScripts=true,SaveTerrain=true,LightingProperties=true,CameraInstances=true}local C=n:WaitForChild("SelectionChanged")local D=n:WaitForChild("GetSelection")local E=n:WaitForChild("SetSelection")local F=game:GetService("Players").LocalPlayer;local G=F:GetMouse()local H="Nothing c:"local I={Explorer={n,o},Settings={r},SaveMap={p},Remotes={q},About={s}}function switchWindows(J,K)if H==J and not K then return end;local L=0;for M,N in pairs(I)do L=0;if M~=J then for O,P in pairs(N)do P:TweenPosition(UDim2.new(1,30,L*0.5,L*36),"Out","Quad",0.5,true)L=L+1 end end end;L=0;if I[J]then for O,P in pairs(I[J])do P:TweenPosition(UDim2.new(1,-300,L*0.5,L*36),"Out","Quad",0.5,true)L=L+1 end end;if J~="Nothing c:"then H=J;for M,N in pairs(i:GetChildren())do N.BackgroundTransparency=1;N.Icon.ImageColor3=Color3.new(70/255,70/255,70/255)end;if i:FindFirstChild(J)then i[J].BackgroundTransparency=0.5;i[J].Icon.ImageColor3=Color3.new(0,0,0)end end end;function toggleDex(Q)if Q then c:TweenPosition(UDim2.new(1,-330,0,0),"Out","Quad",0.5,true)d:TweenPosition(UDim2.new(1,0,0,0),"Out","Quad",0.5,true)switchWindows(H,true)else c:TweenPosition(UDim2.new(1,0,0,0),"Out","Quad",0.5,true)d:TweenPosition(UDim2.new(1,-40,0,0),"Out","Quad",0.5,true)switchWindows("Nothing c:")end end;local R={ClickSelect=false,SelBox=false,ClearProps=false,SelectUngrouped=true,SaveInstanceScripts=true}function ReturnSetting(S)if S=="ClearProps"then return R.ClearProps elseif S=="SelectUngrouped"then return R.SelectUngrouped end end;d.MouseButton1Up:connect(function()toggleDex(true)end)f.MouseButton1Up:connect(function()if f.Active then g.Visible=true end end)e.MouseButton1Up:connect(function()if e.Active then toggleDex(false)end end)for M,N in pairs(i:GetChildren())do N.MouseButton1Click:connect(function()switchWindows(N.Name)end)N.MouseEnter:connect(function()N.BackgroundTransparency=0.5 end)N.MouseLeave:connect(function()if H~=N.Name then N.BackgroundTransparency=1 end end)end;function createSetting(T,U,V)local W=u:Clone()W.Position=UDim2.new(0,0,0,#v:GetChildren()*60)W.SName.Text=T;local function X(Q)if Q then W.Change.Bar:TweenPosition(UDim2.new(0,32,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)W.Change.OnBar:TweenSize(UDim2.new(0,34,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)W.Status.Text="On"R[U]=true else W.Change.Bar:TweenPosition(UDim2.new(0,-2,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)W.Change.OnBar:TweenSize(UDim2.new(0,0,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)W.Status.Text="Off"R[U]=false end end;W.Change.MouseButton1Click:connect(function()X(not R[U])end)W.Visible=true;W.Parent=v;if V then X(true)end end;createSetting("Click part to select","ClickSelect",false)createSetting("Selection Box","SelBox",false)createSetting("Clear property value on focus","ClearProps",false)createSetting("Select ungrouped models","SelectUngrouped",true)createSetting("SaveInstance decompiles scripts","SaveInstanceScripts",true)local function Y()local Z=D:Invoke()if Z and#Z>0 then return Z[1]else return nil end end;G.Button1Down:connect(function()if H=="Explorer"and R.ClickSelect then local _=G.Target;if _ then E:Invoke({_})end end end)C.Event:connect(function()if R.SelBox then local a0,a1=pcall(function()local a2=Y()m.Adornee=a2 end)if a1 then m.Adornee=nil end end end)t.OnInvoke=ReturnSetting;function createMapSetting(a3,U,V)local function X(Q)if Q then a3.Change.Bar:TweenPosition(UDim2.new(0,32,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)a3.Change.OnBar:TweenSize(UDim2.new(0,34,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)a3.Status.Text="On"B[U]=true else a3.Change.Bar:TweenPosition(UDim2.new(0,-2,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)a3.Change.OnBar:TweenSize(UDim2.new(0,0,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)a3.Status.Text="Off"B[U]=false end end;a3.Change.MouseButton1Click:connect(function()X(not B[U])end)a3.Visible=true;a3.Parent=x;if V then X(true)end end;function createCopyWhatSetting(a4)if B.CopyWhat[a4]then local W=A:Clone()W.Position=UDim2.new(0,0,0,#w:GetChildren()*22+5)W.Info.Text=a4;local function X(Q)if Q then W.Change.enabled.Visible=true;B.CopyWhat[a4]=true else W.Change.enabled.Visible=false;B.CopyWhat[a4]=false end end;W.Change.MouseButton1Click:connect(function()X(not B.CopyWhat[a4])end)W.Visible=true;W.Parent=w end end;createMapSetting(x.Scripts,"SaveScripts",true)createMapSetting(x.Terrain,"SaveTerrain",true)createMapSetting(x.Lighting,"LightingProperties",true)createMapSetting(x.CameraInstances,"CameraInstances",true)createCopyWhatSetting("Workspace")createCopyWhatSetting("Lighting")createCopyWhatSetting("ReplicatedStorage")createCopyWhatSetting("ReplicatedFirst")createCopyWhatSetting("StarterPack")createCopyWhatSetting("StarterGui")createCopyWhatSetting("StarterPlayer")y.Text=tostring(game.PlaceId).."MapCopy"z.MouseButton1Click:connect(function()local a5={}local a6=Instance.new("Model",game:GetService('ReplicatedStorage'))local a7=B.SaveScripts;local a8=B.SaveTerrain;local a9=B.LightingProperties;local aa=B.CameraInstances;for M,N in pairs(B.CopyWhat)do if N then table.insert(a5,M)end end;local ab=printconsole or writeconsole;if ab then ab("Moon's place copier loaded.")ab("Copying map of game "..tostring(game.PlaceId)..".")end;function archivable(ac)for M,N in pairs(ac:GetChildren())do if not game:GetService('Players'):GetPlayerFromCharacter(N)then N.Archivable=true;archivable(N)end end end;function decompileS(ac)for M,N in pairs(ac:GetChildren())do pcall(function()if N:IsA("LocalScript")then local ad=N.Disabled;N.Disabled=true;N.Source=decompile(N)N.Disabled=ad;if N.Source==""then if ab then ab("LocalScript "..N.Name.." had a problem decompiling.")end else if ab then ab("LocalScript "..N.Name.." decompiled.")end end elseif N:IsA("ModuleScript")then N.Source=decompile(N)if N.Source==""then if ab then ab("ModuleScript "..N.Name.." had a problem decompiling.")end else if ab then ab("ModuleScript "..N.Name.." decompiled.")end end end end)decompileS(N)end end;for M,N in pairs(a5)do archivable(game[N])end;for ae,a3 in pairs(a5)do if a3~="StarterPlayer"then local af=Instance.new("Folder",a6)af.Name=a3;for M,N in pairs(game[a3]:GetChildren())do if N~=a6 then pcall(function()N:Clone().Parent=af end)end end else local af=Instance.new("Model",a6)af.Name="StarterPlayer"for M,N in pairs(game[a3]:GetChildren())do local ag=Instance.new("Folder",af)ag.Name=N.Name;for O,P in pairs(N:GetChildren())do if P.Name~="ControlScript"and P.Name~="CameraScript"then P:Clone().Parent=ag end end end end end;if workspace.CurrentCamera and aa then local ah=Instance.new("Model",a6)ah.Name="CameraItems"for M,N in pairs(workspace.CurrentCamera:GetChildren())do N:Clone().Parent=ah end end;if a8 then local ai=workspace.Terrain:CopyRegion(workspace.Terrain.MaxExtents)ai.Parent=a6 end;function saveProp(a3,aj,ak)local al=a3[aj]if type(al)=="boolean"then local am=Instance.new("BoolValue",ak)am.Name=aj;am.Value=al elseif type(al)=="number"then local am=Instance.new("IntValue",ak)am.Name=aj;am.Value=al elseif type(al)=="string"then local am=Instance.new("StringValue",ak)am.Name=aj;am.Value=al elseif type(al)=="userdata"then pcall(function()local am=Instance.new("Color3Value",ak)am.Name=aj;am.Value=al end)end end;if a9 then local an=Instance.new("Model",a6)an.Name="LightingProperties"saveProp(game:GetService('Lighting'),"Ambient",an)saveProp(game:GetService('Lighting'),"Brightness",an)saveProp(game:GetService('Lighting'),"ColorShift_Bottom",an)saveProp(game:GetService('Lighting'),"ColorShift_Top",an)saveProp(game:GetService('Lighting'),"GlobalShadows",an)saveProp(game:GetService('Lighting'),"OutdoorAmbient",an)saveProp(game:GetService('Lighting'),"Outlines",an)saveProp(game:GetService('Lighting'),"GeographicLatitude",an)saveProp(game:GetService('Lighting'),"TimeOfDay",an)saveProp(game:GetService('Lighting'),"FogColor",an)saveProp(game:GetService('Lighting'),"FogEnd",an)saveProp(game:GetService('Lighting'),"FogStart",an)end;if decompile and a7 then decompileS(a6)end;if SaveInstance then SaveInstance(a6,y.Text..".rbxm")elseif saveinstance then saveinstance(getelysianpath()..y.Text..".rbxm",a6)end;if ab then ab("The map has been copied.")end;z.Text="The map has been saved"wait(5)z.Text="Save"end)wait()b:TweenPosition(UDim2.new(1,-301,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)switchWindows("Explorer")wait(1)c.Visible=true;for M=0,1,0.1 do b.BackgroundTransparency=M;b.Main.BackgroundTransparency=M;b.Slant.ImageTransparency=M;b.Title.TextTransparency=M;b.Version.TextTransparency=M;b.Creator.TextTransparency=M;b.Sad.ImageTransparency=M;wait()end;b.Visible=false;i:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)f:TweenPosition(UDim2.new(0,0,0,150),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)e:TweenPosition(UDim2.new(0,0,0,180),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)j:TweenPosition(UDim2.new(0,0,0,210),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)wait(0.5)for M=1,0,-0.1 do f.Icon.ImageTransparency=M;e.TextTransparency=M;wait()end;e.Active=true;e.AutoButtonColor=true;f.Active=true;f.AutoButtonColor=true]],owner.PlayerGui)
FEDex=function(a)local b=owner.PlayerGui:WaitForChild("Dex");print(a)print("PastGui")local c=Instance.new("RemoteFunction",b)c.Name="DexAPI"local d=b:WaitForChild("TempPastes")d.Parent=game:GetService("Players"):WaitForChild(a)function RunRemote(...)local e={...}local f=e[1]table.remove(e,1)if e[1]=="EditProperty"then e[2][e[3]]=e[4]end;if e[1]=="Clone"then local g=e[2]:Clone()g.Parent=d;return g end;if e[1]=="PasteTo"then e[2]:Clone().Parent=e[3]end;if e[1]=="Duplicate"then e[2]:Clone().Parent=e[2].Parent end;if e[1]=="SwitchParents"then e[2].Parent=e[3]end;if e[1]=="Group"then local h=Instance.new("Model",e[2].Parent)e[2].Parent=h end;if e[1]=="UnGroup"then if e[2]:IsA("Model")then local h=e[2]for i,j in pairs(h:GetChildren())do j.Parent=h.Parent end;h:Destroy()end end;if e[1]=="Delete"then e[2]:Destroy()end;if e[1]=="GetChildren"then local k=game:WaitForChild(e[2])local l={}local m={}function ReturnTableDataFromClone(j,n,o)local p={}local q=j:Clone()pcall(function()if o then p=o end;if n then q.Parent=n end;for i,j in pairs(q:GetChildren())do j:Destroy()end;p[q]=j;for i,r in pairs(j:GetChildren())do ReturnTableDataFromClone(r,q,p)end end)return p,q end;for i,s in pairs(k:GetChildren())do local t=s:Clone()if t then local u,t=ReturnTableDataFromClone(s,nil,l)if t then table.insert(m,t)t.Parent=d end;if not string.match(t.ClassName,"Value")then t.Changed:connect(function(v)if v~="Parent"or t:IsDescendantOf(game.ServerStorage)or t:IsDescendantOf(game.ServerScriptService)then u[t][v]=t[v]else u[t].Parent=u[t.Parent]end end)else coroutine.wrap(function()while wait(2)do if u[t.Parent]then u[t].Parent=u[t.Parent]else u[t].Parent=t.Parent end;u[t].Name=t.Name;t.Changed:connect(function(w)u[t].Value=w end)end end)()end;for i,x in pairs(t:GetDescendants())do if not string.match(x.ClassName,"Value")then x.Changed:connect(function(v)if v~="Parent"or x:IsDescendantOf(game.ServerStorage)or x:IsDescendantOf(game.ServerScriptService)then pcall(function()u[x][v]=x[v]end)else pcall(function()u[x].Parent=u[x.Parent]end)end end)else coroutine.wrap(function()while wait(2)do if u[x.Parent]then u[x].Parent=u[x.Parent]else u[x].Parent=x.Parent end;u[x].Name=x.Name;x.Changed:connect(function(w)u[x].Value=w end)end end)()end end end end;return m end end;c.OnServerInvoke=RunRemote end;FEDex(owner)