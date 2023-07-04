local Scripts = {
	{"https://raw.githubusercontent.com/VolcanoReg/Lua-SB-script/main/DemonicCatCFrameOptimized.lua","DemCatVis"}
}
local Running = {}
local TIMER = 10
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
				print("Auto Executing "..scripta[2])
				noerror,codes = ScriptHttpChecker(scripta[1],true)
				if noerror == false then
					CommandAction:FireAllClients("No Running Scripts")
					print("Error getting script")
				else
					table.insert(Running,{scripta[2],NS(codes),codes})
				end
			end
		end
	end},
	{"StopAll",function()
		--Stop Function
	end
	},
}
CommandAction.OnServerEvent:Connect(function(_,msg)
	msg = string.split(msg," ")
	for i,commands in next,functions_list do
		if msg[1] == commands[1] then
			commands[2](msg[2])
		end
	end
end)

--The Scripts Autochecker and Autoexecutor
while true do
	if #Running < 1 then
		CommandAction:FireAllClients("No Running Scripts")
		print("No Running Scripts")
	else
		for i,scripta in next,Running do
			newcode = nil
			for i,code in next,Scripts do
				if scripta[1] == code[2] then
					noerror,newcode = ScriptHttpChecker(code[1],true)
					if noerror == false then
						CommandAction:FireAllClients("No Running Scripts")
						print("Error getting script")
					end
				else
				end
			end
			if scripta[3] ~= newcode then
				print("New Code Detected")
				CommandAction:FireAllClients("New Code Detected")
				owner:LoadCharacter()
				Client()
				scripta[2]:Destroy() --destroy old NS
				scripta[2] = NS(newcode) --replace with the new ones
				scripta[3] = newcode -- replace old code with new code
			end
			CommandAction:FireAllClients("No New Code Detected")
			print("No New Code Detected")
		end
	end
	task.wait(TIMER)
end