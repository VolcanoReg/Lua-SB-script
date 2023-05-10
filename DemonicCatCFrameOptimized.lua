local plr = "VolcanoReg"
local player = game:GetService("Players")[plr]
script.Parent = player.Character
script.Name = "DemonicCat"
local tween = game:GetService("TweenService")
function tweener(instance,changedto,time)
    local info = TweenInfo.new(time,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut)
    tween:Create(instance, info, changedto):Play()
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
--BackSign.Text = plr.."'s antidamage"
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
--FrontSign.Text = plr.."'s antidamage"
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
--[[
	Rotating Script for Title and MagicCircle
]]
audio:Play()

HB=game:GetService("RunService").Heartbeat;swait=function()HB:Wait();end;

function tp()
    humanoidrotpart.CFrame = humanoidrotpart.CFrame + Vector3.new(math.random(-5,5),0,0)
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
    game:GetService("Debris"):AddItem(s,1)
end



script.Parent:FindFirstChild("Humanoid").HealthChanged:Connect(function(h)
    script.Parent.Humanoid.Health = script.Parent.Humanoid.Health + h
    tp()
end)

script.Parent.Humanoid.MaxHealth = math.huge
script.Parent.Humanoid.Health = math.huge
rot1 = 1
rot2 = 1
defsize = 1
modes = 0
sizingmode = 1
audioifmodes1 = 0
timerforsize = 0.15
Remover = 0

script.Parent:FindFirstChild("Humanoid").Changed:Connect(function(prop)
    if prop == "MaxHealth" then
        script.Parent.Humanoid.MaxHealth = math.huge
    end
end)

function rot1change(int: number)
    int=tonumber(int)
    if int <= 0.01 then
        int = 0.01
    end
    rot1 = int
end

function rot2change(int: number)
    int=tonumber(int)
    if int <= 0.01 then
        int = 0.01
    end
    rot2 = int
end

function sndspeed(speed: number)
    speed=tonumber(speed)
    audio.PlaybackSpeed = speed
end

function playsound(id)
    if typeof(id) == "string" then
        for name,song in songs do
            if string.find(name,id) ~= nil then
                audio:Stop()
                audio.SoundId = "rbxassetid://"..song[1]
                audio.PlaybackSpeed = song[2]
                print(audio.SoundId)
                audio:Play()
            end
        end
    else
    audio:Stop()
    audio.SoundId = "rbxassetid://"..id
    print(audio.SoundId)
    audio:Play()
    end
end

function volume(vol)
    vol=tonumber(vol)
    audio.Volume = vol
end

function sizer(vec: number)
    defsize = vec
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
    sndspeed = function(speed: number)
        speed=tonumber(speed)
        audio.PlaybackSpeed = speed
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
    speedmode = function()
        if modes == 0 then
            rot2change(0.1)
            modes = 1
        elseif modes == 1 then
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

}

function weldhumrootpart(audioifmodes1)
    if modes == 1 then
        weld_humroot.C1 *= CFrame.Angles(0,math.rad(rot2^(audioifmodes1/10)),0)
    elseif modes == 0 then
        weld_humroot.C1 *= CFrame.Angles(0,math.rad(rot2),0)
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

Size.OnServerEvent:Connect(function(_,size)
    if size <= 1 then
        size = 1
    end
    --magiccircle.Size = Vector3.new(size,0.1,size)
    audioifmodes1 = size
    if sizingmode == 0 then
        local changedto = {}
        changedto.Size = Vector3.new((size/5)*defsize,0.1,(size/5)*defsize)
        tweener(magiccircle,changedto,timerforsize)
    elseif sizingmode == 1 then
        magiccircle.Size = Vector3.new((size/5)*defsize,0.1,(size/5)*defsize)
    end
end)

magiccircle.Touched:Connect(function(touched)
    if touched.ClassName == "Part" and touched.Parent:FindFirstChild("Humanoid") == nil and touched.Parent.Name ~= owner.Name and Remover == false then
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
player.Character.Humanoid:SetStateEnabled("Died",false)
loop()
--cl/game:GetService("Chat"):Chat(owner.Character,"_play 13107234233")
--Camellia - GHOST = 13260768688
--YOASOBI -  Idol (アイドル) = 13260765767