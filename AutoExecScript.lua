local Scripts = {
	{"https://raw.githubusercontent.com/VolcanoReg/Lua-SB-script/main/DemonicCatCFrameOptimized.lua","DemCatVis"}
}
local Running = {}
local TIMER = 10
local Http = game:GetService("HttpService")
local CBA = Instance.new("RemoteEvent")
script.Parent = owner
CBA.Name = "CommandBasedAction"
CBA.Parent = owner

--NLS
NLS(
[[
local remote = owner:WaitForChild("CommandBasedAction")
local chat = game:GetService("Chat")
prefix = &
chat.Chatted:Connect(function(part,msg,color)
    if part.Name == game.Players.LocalPlayer.Name and string.sub(msg,1,1) == prefix then
        remote:FireServer(string.sub(msg,2))
    end
end)
remote.OnClientEvent:Connect(function(msg)
	game:GetService("Chat"):Chat(owner.Character,msg)
end)
]],script)

--Http function used to get the script
function ScriptHttpChecker(url,nocache,header)
	checker = 0
	MAX_RETRY = 5
	local noerror,code
	repeat 
		checker += 1
		print("Try "..checker)
		noerror,code = pcall(Http:GetAsync,url,nocache,header or {})
		task.wait(1)
	until noerror == true or checker == MAX_RETRY
	return noerror,code
end

functions_list = {
	{"Init",function(name)
		for i,scripta in next,Scripts do
			if name == script[2] then
				print("Auto Executing "..scripta[2])
				noerror,codes = ScriptHttpChecker(scripta[1],true)
				if noerror == false then
					print("Error getting script")
				else
					table.insert(Running,{script[2],NS(codes),codes})
				end
			end
		end
	end},
	{"StopAll",function()
		--Stop Function
	end
	},
}
CBA.OnServerEvent:Connect(function(_,msg)
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
		CBA:FireAllClient("No Running Scripts")
		print("No Running Scripts")
	else
		for i,scripta in next,Running do
			newcode = nil
			for i,code in next,Scripts do
				if scripta[1] == code[2] then
					newcode = ScriptHttpChecker(code[1],true)
				end
			end
			if scripta[3] ~= newcode then
				print("New Code Detected")
				CBA:FireAllClient("New Code Detected")
				owner:LoadCharacter()
				scripta[2]:Destroy() --destroy old NS
				scripta[2] = NS(newcode) --replace with the new ones
				scripta[3] = newcode -- replace old code with new code
			end
			CBA:FireAllClient("No New Code Detected")
			print("No New Code Detected")
		end
	end
	task.wait(TIMER)
end