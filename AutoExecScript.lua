--{"https://raw.githubusercontent.com/VolcanoReg/Lua-SB-script/main/DemonicCatCFrameOptimized.lua","DemCatVis"}
NGROK_URL = "https://3983-114-10-120-107.ngrok-free.app"
local Scripts = {
	{"https://raw.githubusercontent.com/VolcanoReg/Lua-SB-script/main/DemonicCatCFrameOptimized.lua","DemCatVis"},
	{NGROK_URL.."/DemonicCatCFrameOptimized.lua","DemCatVis_Local"},
	{"https://raw.githubusercontent.com/VolcanoReg/Lua-SB-script/main/Nuke_Gun.lua","Nuke_Gun"},
}
local Running = {}
local TIMER = 15
local Http = game:GetService("HttpService")
script.Parent = owner

for i,v in pairs(owner:GetChildren()) do
	if v.Name == "CommandBasedAction" then
		v:Destroy()
	end
end

CommandAction = Instance.new("RemoteEvent")
CommandAction.Name = "CommandBasedAction"
CommandAction.Parent = owner

--NLS
Client = function()
	NLS(
	[[
	local remote = owner:WaitForChild("CommandBasedAction")
	print(remote)
	local chat = game:GetService("Chat")
	prefix = "&"
	chat.Chatted:Connect(function(part,msg,color)
		if part.Name == game.Players.LocalPlayer.Name and string.sub(msg,1,1) == prefix then
			remote:FireServer(string.sub(msg,2))
		end
	end)
	remote.OnClientEvent:Connect(function(msg)
		print(msg)
		chat:Chat(owner.Character,msg)
	end)
	]])
end
Client()

function Message(Message,WithPopUp)
	if WithPopUp == true then CommandAction:FireAllClients(Message) end
	print(Message)
end
--Http function used to get the script
function ScriptHttpChecker(url,nocache)
	checker = 0
	MAX_RETRY = 5
	local noerror,code
	repeat 
		checker += 1
		print("Try "..checker)
		noerror,code = pcall(function(url,nocache) return Http:GetAsync(url,nocache) end,url,nocache)
		task.wait(1)
	until noerror == true or checker == MAX_RETRY
	return noerror,code
end

functions_list = {
	{"Init",function(name)
		for i,scripta in next,Scripts do
			if name == scripta[2] then
				Message("Auto Executing "..scripta[2],true)
				noerror,codes = ScriptHttpChecker(scripta[1],true)
				if noerror == false then
					
				else
					table.insert(Running,{scripta[2],NS(codes),codes})
				end
			end
		end
	end},
	{"StopAll",function()
		--Stop Function
		for i,scripta in next,Running do
			Message("Stopping Script: "..scripta[1])
			scripta[2]:Destroy()
			task.wait(1/10)
		end
		Running = {}
		owner:LoadCharacter()
		Message("Script Stopped",true)
	end
	},
	{"Ngrok",function(input)
		getfenv(0)["NGROK_URL"] = tostring(input)
	end}
}
CommandAction.OnServerEvent:Connect(function(_,msg)
	msg = string.split(msg," ")
	for i,commands in next,functions_list do
		if msg[1] == commands[1] then
			commands[2](msg[2])
		end
	end
end)

--Put localscript on newly added character or respawned Character
owner.CharacterAdded:Connect(function(Char)
	Client()
end)

--The Scripts Autochecker and Autoexecutor
while true do
	if #Running < 1 then
		Message("No Running Scripts",false)
	else
		for i,scripta in next,Running do
			newcode = nil
			for i,code in next,Scripts do
				if scripta[1] == code[2] then
					noerror,newcode = ScriptHttpChecker(code[1],true)
					if noerror == false then
						Message("Error getting script",true)
					end
				else
				end
			end
			if scripta[3] ~= newcode then
				Message("New Code Detected",true)
				local Pivoted = owner.Character:GetPivot()
				owner:LoadCharacter()
				owner.Character:PivotTo(Pivoted)
				scripta[2]:Destroy() --destroy old NS
				scripta[2] = NS(newcode) --replace with the new ones
				scripta[3] = newcode -- replace old code with new code
			end
			Message("No New Code Detected",false)
		end
	end
	task.wait(TIMER)
end