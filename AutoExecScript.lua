local Scripts = {
	{"https://raw.githubusercontent.com/VolcanoReg/Lua-SB-script/main/DemonicCatCFrameOptimized.lua","DemCatVis"}
}
local Running = {}
local TIMER = 10
local Http = game:GetService("HttpService")
local CBA = Instance.new("RemoteEvent")
CBA.Name = "CommandBasedAction"
CBA.Parent = owner

--NLS
NLS(
[[local remote = owner:WaitForChild("CommandBasedAction")
prefix = &
chat.Chatted:Connect(function(part,msg,color)
    if part.Name == game.Players.LocalPlayer.Name and string.sub(msg,1,1) == prefix then
        remote:FireServer(string.sub(msg,2))
    end
end)
]])

--Http function used to get the script
function ScriptHttpChecker(url,nocache,header)
	return Http:GetAsync(url,nocache,header or {})
end

functions_list = {
	{"Init",function(name)
		for i,script in next,Scripts do
			if name == script[2] then
				print("Auto Executing "..script[2])
				codes = ScriptHttpChecker(script[1],true)
				table.insert(Running,{script[2],NS(codes),codes})
			end
		end
	end},
	{"StopAll",function()
		--Stop Function
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
	else
		for i,script in next,Running do
			newcode = nil
			for i,code in next,Scripts do
				if script[1] == code[2] then
					newcode = ScriptHttpChecker(code[1],true)
				end
			end
			if script[3] ~= newcode then
				owner:LoadCharacter()
				script[2]:Destroy() --destroy old NS
				script[2] = NS(newcode) --replace with the new ones
				script[3] = newcode -- replace old code with new code
			end
		end
	end
	task.wait(TIMER)
end