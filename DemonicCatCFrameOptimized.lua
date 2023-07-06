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
    ["Kevin MacLeod - Local Forecast"] = {13413645483,1},
	["魔王 (Mowang) (Shadowlord)"] = {13933942874,1},
	["Nolan Reese - Broken"] = {13933897528,1},
	["goofy ahh dnb beat"] = {13933881937,1},
	["death row"] = {12788222391,1},
	["憂鬱 - Sun"] = {13852611515,1},
	["anti citizen"] = {13933980071,0.75},
	["Elektronomia - Limitless"] = {13822217800,1},
	["Loonboon remix Hardstyle"] = {13799354416,1},
	["Loonboon remix Drum and Bass Remix"] = {13799357814,1},
	
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
magiccircletable = {}
local magiccircle = Instance.new("Part")
magiccircle.Name = "MagicCircle"
magiccircle.Transparency = 1
magiccircle.CanCollide = false
magiccircle.Massless = true
magiccircle.Size = Vector3.new(5.5,0.1,5.5)
magiccircle.CFrame = humanoidrotpart.CFrame - Vector3.new(0,-3,0)
magiccircle.Parent = humanoidrotpart
table.insert(magiccircletable,magiccircle)
print("Magic Circle 1 Block Ready")
local magiccircle2 = Instance.new("Part")
magiccircle2.Name = "MagicCircle"
magiccircle2.Transparency = 1
magiccircle2.CanCollide = false
magiccircle2.Massless = true
magiccircle2.Size = Vector3.new(7.5,0.1,7.5)
magiccircle2.CFrame = humanoidrotpart.CFrame - Vector3.new(0,-2,0)
magiccircle2.Parent = humanoidrotpart
table.insert(magiccircletable,magiccircle2)
print("Magic Circle 2 Block Ready")
local magiccircle3 = Instance.new("Part")
magiccircle3.Name = "MagicCircle"
magiccircle3.Transparency = 1
magiccircle3.CanCollide = false
magiccircle3.Massless = true
magiccircle3.Size = Vector3.new(9.5,0.1,9.5)
magiccircle3.CFrame = humanoidrotpart.CFrame - Vector3.new(0,-1,0)
magiccircle3.Parent = humanoidrotpart
table.insert(magiccircletable,magiccircle3)
print("Magic Circle 3 Block Ready")

local dec = Instance.new("Decal")
dec.Face = "Top"
dec.Name = "Magic"
dec.Texture = "rbxassetid://8058971884"
dec.Parent = magiccircle
print("Magic Ready")
local dec2 = Instance.new("Decal")
dec2.Face = "Top"
dec2.Name = "Magic"
dec2.Texture = "rbxassetid://8058971884"
dec2.Color3 = Color3.fromRGB(128,128,128)
dec2.Parent = magiccircle2
print("Magic Ready")
local dec3 = Instance.new("Decal")
dec3.Face = "Top"
dec3.Name = "Magic"
dec3.Texture = "rbxassetid://8058971884"
dec3.Color3 = Color3.fromRGB(64,64,64)
dec3.Parent = magiccircle3
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
local weld_humroot2 = Instance.new("Weld")
weld_humroot2.Name = "HumRootStrap"
weld_humroot2.Enabled = true
weld_humroot2.Parent = humanoidrotpart
weld_humroot2.Part0 = humanoidrotpart
weld_humroot2.Part1 = magiccircle2
--weld_humroot.C0 = magiccircle.CFrame:Inverse()
weld_humroot2.C1	= CFrame.new(0,3,0)
print("Weld 2 Ready")
local weld_humroot3 = Instance.new("Weld")
weld_humroot3.Name = "HumRootStrap"
weld_humroot3.Enabled = true
weld_humroot3.Parent = humanoidrotpart
weld_humroot3.Part0 = humanoidrotpart
weld_humroot3.Part1 = magiccircle3
--weld_humroot.C0 = magiccircle.CFrame:Inverse()
weld_humroot3.C1	= CFrame.new(0,3,0)
print("Weld 3 Ready")

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
SoundWAVE = {}
for n=1,3 do
	i = Instance.new("Sound")
	i.Name = "WAVE"..n
	i.Volume = 0
	i.Looped = audio.Looped
	i.SoundId = audio.SoundId
	i.Parent = audio.Parent
	table.insert(SoundWAVE,i)
	i:Play()
	EQ = Instance.new("EqualizerSoundEffect")
    EQ.Enabled = true
    EQ.LowGain = if n == 1 then 3 else 0
    EQ.MidGain = if n == 2 then 3 else 0
    EQ.HighGain = if n == 3 then 3 else 0
    EQ.Parent = i
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
            task.delay(1, function()
                db = false
            end)
        end
        h.Health = h.MaxHealth
    end
end

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

function weldhumrootpart(audioifmodes1)
	for i,wave in SoundWAVE do
		if wave.SoundId ~= audio.SoundId then
			wave.SoundId = audio.SoundId
		end
		if wave.TimePosition ~= audio.TimePosition then
			wave.TimePosition = audio.TimePosition - (tonumber(i)*5)
		end
		if audio.IsPaused == true then
			wave:Pause()
		elseif audio.IsPaused == false then
			wave:Resume()
		end
		if audio.Playing == true then
			wave:Play()
		elseif audio.Playing == false then
			wave:Stop()
		end
	end
    if modes == 1 then
        weld_humroot.C1 *= CFrame.Angles(0,math.rad(rot2*(audioifmodes1/10)),0)
		weld_humroot2.C1 *= CFrame.Angles(0,math.rad(rot2*(audioifmodes1/10)),0)
		weld_humroot3.C1 *= CFrame.Angles(0,math.rad(rot2*(audioifmodes1/10)),0)
    elseif modes == 0 then
        weld_humroot.C1 *= CFrame.Angles(0,math.rad(rot2),0)
		weld_humroot2.C1 *= CFrame.Angles(0,math.rad(rot2),0)
		weld_humroot3.C1 *= CFrame.Angles(0,math.rad(rot2),0)
    end
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
local audio = owner.Character.HumanoidRootPart:WaitForChild("WAVE1")
local audio2 = owner.Character.HumanoidRootPart:WaitForChild("WAVE2")
local audio3 = owner.Character.HumanoidRootPart:WaitForChild("WAVE3")
HB=game:GetService("RunService").RenderStepped;swait=function()HB:Wait();end;
remote2.OnClientEvent:Connect(function(msg)
    pcall(function() audio = msg end)
end)
while true do
    remote2:FireServer({audio.PlaybackLoudness,audio2.PlaybackLoudness,audio3.PlaybackLoudness})
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

--Magiccircle's Sizing Function
Size.OnServerEvent:Connect(function(_,size)
    --if size <= 1 then
    --    size = 1
    --end
    audioifmodes1 = size
    if sizingmode == 0 then
        local changedto = {}
		--changedto.Size = Vector3.new((size[1]/7.5)*defsize,0.1,(size[1]/7.5)*defsize)
		--tweener(magiccircle,changedto,timerforsize)
		--changedto.Size = Vector3.new((size[2]/7.5)*defsize,0.1,(size[2]/7.5)*defsize)
		--tweener(magiccircle,changedto,timerforsize)
		--changedto.Size = Vector3.new((size[3]/7.5)*defsize,0.1,(size[3]/7.5)*defsize)
		--tweener(magiccircle,changedto,timerforsize)
		--#Applying each magiccircle's size
		for i,WAVE in next,size do
			if WAVE <= 1 then
				WAVE = 1
			end
			changedto.Size = Vector3.new((WAVE*i/7.5)*defsize,0.1,(WAVE*i/7.5)*defsize)
			tweener(magiccircletable[i],changedto,timerforsize)
		end
    elseif sizingmode == 1 then
        --local s = game:GetService("RunService").Heartbeat:Wait()
        for i=0,1,0.1 do
            magiccircle.Size = Vector3.new(4,0.1,4):Lerp(Vector3.new((size[1]/7.5)*defsize,0.1,(size[1]/7.5)*defsize),i) --Vector3.new((size/7.5)*defsize,0.1,(size/7.5)*defsize)
            task.wait(0.01)
        end
    end
    
end)

magiccircle.Touched:Connect(function(touched)
    if touched.ClassName == "Part" and touched.Parent:FindFirstChild("Humanoid") == nil and touched.Parent.Name ~= owner.Name and Remover == true then
        pcall(function() touched:Destroy() end)
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
owner.Character.Humanoid.HealthChanged:Connect(OnHealthChanged)
loop()