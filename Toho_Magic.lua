local t = {}

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------JSON Functions Begin----------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

--JSON Encoder and Parser for Lua 5.1
--
--Copyright 2007 Shaun Brown  (http://www.chipmunkav.com)
--All Rights Reserved.

--Permission is hereby granted, free of charge, to any person 
--obtaining a copy of this software to deal in the Software without 
--restriction, including without limitation the rights to use, 
--copy, modify, merge, publish, distribute, sublicense, and/or 
--sell copies of the Software, and to permit persons to whom the 
--Software is furnished to do so, subject to the following conditions:

--The above copyright notice and this permission notice shall be 
--included in all copies or substantial portions of the Software.
--If you find this software useful please give www.chipmunkav.com a mention.

--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
--EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
--OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
--IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
--ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
--CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
--CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local string = string
local math = math
local table = table
local error = error
local tonumber = tonumber
local tostring = tostring
local type = type
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local assert = assert


local StringBuilder = {
	buffer = {}
}

function StringBuilder:New()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.buffer = {}
	return o
end

function StringBuilder:Append(s)
	self.buffer[#self.buffer+1] = s
end

function StringBuilder:ToString()
	return table.concat(self.buffer)
end

local JsonWriter = {
	backslashes = {
		['\b'] = "\\b",
		['\t'] = "\\t",	
		['\n'] = "\\n", 
		['\f'] = "\\f",
		['\r'] = "\\r", 
		['"']  = "\\\"", 
		['\\'] = "\\\\", 
		['/']  = "\\/"
	}
}

function JsonWriter:New()
	local o = {}
	o.writer = StringBuilder:New()
	setmetatable(o, self)
	self.__index = self
	return o
end

function JsonWriter:Append(s)
	self.writer:Append(s)
end

function JsonWriter:ToString()
	return self.writer:ToString()
end

function JsonWriter:Write(o)
	local t = type(o)
	if t == "nil" then
		self:WriteNil()
	elseif t == "boolean" then
		self:WriteString(o)
	elseif t == "number" then
		self:WriteString(o)
	elseif t == "string" then
		self:ParseString(o)
	elseif t == "table" then
		self:WriteTable(o)
	elseif t == "function" then
		self:WriteFunction(o)
	elseif t == "thread" then
		self:WriteError(o)
	elseif t == "userdata" then
		self:WriteError(o)
	end
end

function JsonWriter:WriteNil()
	self:Append("null")
end

function JsonWriter:WriteString(o)
	self:Append(tostring(o))
end

function JsonWriter:ParseString(s)
	self:Append('"')
	self:Append(string.gsub(s, "[%z%c\\\"/]", function(n)
		local c = self.backslashes[n]
		if c then return c end
		return string.format("\\u%.4X", string.byte(n))
	end))
	self:Append('"')
end

function JsonWriter:IsArray(t)
	local count = 0
	local isindex = function(k) 
		if type(k) == "number" and k > 0 then
			if math.floor(k) == k then
				return true
			end
		end
		return false
	end
	for k,v in pairs(t) do
		if not isindex(k) then
			return false, '{', '}'
		else
			count = math.max(count, k)
		end
	end
	return true, '[', ']', count
end

function JsonWriter:WriteTable(t)
	local ba, st, et, n = self:IsArray(t)
	self:Append(st)	
	if ba then		
		for i = 1, n do
			self:Write(t[i])
			if i < n then
				self:Append(',')
			end
		end
	else
		local first = true;
		for k, v in pairs(t) do
			if not first then
				self:Append(',')
			end
			first = false;			
			self:ParseString(k)
			self:Append(':')
			self:Write(v)			
		end
	end
	self:Append(et)
end

function JsonWriter:WriteError(o)
	error(string.format(
		"Encoding of %s unsupported", 
		tostring(o)))
end

function JsonWriter:WriteFunction(o)
	if o == Null then 
		self:WriteNil()
	else
		self:WriteError(o)
	end
end

local StringReader = {
	s = "",
	i = 0
}

function StringReader:New(s)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.s = s or o.s
	return o	
end

function StringReader:Peek()
	local i = self.i + 1
	if i <= #self.s then
		return string.sub(self.s, i, i)
	end
	return nil
end

function StringReader:Next()
	self.i = self.i+1
	if self.i <= #self.s then
		return string.sub(self.s, self.i, self.i)
	end
	return nil
end

function StringReader:All()
	return self.s
end

local JsonReader = {
	escapes = {
		['t'] = '\t',
		['n'] = '\n',
		['f'] = '\f',
		['r'] = '\r',
		['b'] = '\b',
	}
}

function JsonReader:New(s)
	local o = {}
	o.reader = StringReader:New(s)
	setmetatable(o, self)
	self.__index = self
	return o;
end

function JsonReader:Read()
	self:SkipWhiteSpace()
	local peek = self:Peek()
	if peek == nil then
		error(string.format(
			"Nil string: '%s'", 
			self:All()))
	elseif peek == '{' then
		return self:ReadObject()
	elseif peek == '[' then
		return self:ReadArray()
	elseif peek == '"' then
		return self:ReadString()
	elseif string.find(peek, "[%+%-%d]") then
		return self:ReadNumber()
	elseif peek == 't' then
		return self:ReadTrue()
	elseif peek == 'f' then
		return self:ReadFalse()
	elseif peek == 'n' then
		return self:ReadNull()
	elseif peek == '/' then
		self:ReadComment()
		return self:Read()
	else
		return nil
	end
end

function JsonReader:ReadTrue()
	self:TestReservedWord{'t','r','u','e'}
	return true
end

function JsonReader:ReadFalse()
	self:TestReservedWord{'f','a','l','s','e'}
	return false
end

function JsonReader:ReadNull()
	self:TestReservedWord{'n','u','l','l'}
	return nil
end

function JsonReader:TestReservedWord(t)
	for i, v in ipairs(t) do
		if self:Next() ~= v then
			error(string.format(
				"Error reading '%s': %s", 
				table.concat(t), 
				self:All()))
		end
	end
end

function JsonReader:ReadNumber()
	local result = self:Next()
	local peek = self:Peek()
	while peek ~= nil and string.find(
		peek, 
		"[%+%-%d%.eE]") do
		result = result .. self:Next()
		peek = self:Peek()
	end
	result = tonumber(result)
	if result == nil then
		error(string.format(
			"Invalid number: '%s'", 
			result))
	else
		return result
	end
end

function JsonReader:ReadString()
	local result = ""
	assert(self:Next() == '"')
	while self:Peek() ~= '"' do
		local ch = self:Next()
		if ch == '\\' then
			ch = self:Next()
			if self.escapes[ch] then
				ch = self.escapes[ch]
			end
		end
		result = result .. ch
	end
	assert(self:Next() == '"')
	local fromunicode = function(m)
		return string.char(tonumber(m, 16))
	end
	return string.gsub(
		result, 
		"u%x%x(%x%x)", 
		fromunicode)
end

function JsonReader:ReadComment()
	assert(self:Next() == '/')
	local second = self:Next()
	if second == '/' then
		self:ReadSingleLineComment()
	elseif second == '*' then
		self:ReadBlockComment()
	else
		error(string.format(
			"Invalid comment: %s", 
			self:All()))
	end
end

function JsonReader:ReadBlockComment()
	local done = false
	while not done do
		local ch = self:Next()		
		if ch == '*' and self:Peek() == '/' then
			done = true
		end
		if not done and 
			ch == '/' and 
			self:Peek() == "*" then
			error(string.format(
				"Invalid comment: %s, '/*' illegal.",  
				self:All()))
		end
	end
	self:Next()
end

function JsonReader:ReadSingleLineComment()
	local ch = self:Next()
	while ch ~= '\r' and ch ~= '\n' do
		ch = self:Next()
	end
end

function JsonReader:ReadArray()
	local result = {}
	assert(self:Next() == '[')
	local done = false
	if self:Peek() == ']' then
		done = true;
	end
	while not done do
		local item = self:Read()
		result[#result+1] = item
		self:SkipWhiteSpace()
		if self:Peek() == ']' then
			done = true
		end
		if not done then
			local ch = self:Next()
			if ch ~= ',' then
				error(string.format(
					"Invalid array: '%s' due to: '%s'", 
					self:All(), ch))
			end
		end
	end
	assert(']' == self:Next())
	return result
end

function JsonReader:ReadObject()
	local result = {}
	assert(self:Next() == '{')
	local done = false
	if self:Peek() == '}' then
		done = true
	end
	while not done do
		local key = self:Read()
		if type(key) ~= "string" then
			error(string.format(
				"Invalid non-string object key: %s", 
				key))
		end
		self:SkipWhiteSpace()
		local ch = self:Next()
		if ch ~= ':' then
			error(string.format(
				"Invalid object: '%s' due to: '%s'", 
				self:All(), 
				ch))
		end
		self:SkipWhiteSpace()
		local val = self:Read()
		result[key] = val
		self:SkipWhiteSpace()
		if self:Peek() == '}' then
			done = true
		end
		if not done then
			ch = self:Next()
			if ch ~= ',' then
				error(string.format(
					"Invalid array: '%s' near: '%s'", 
					self:All(), 
					ch))
			end
		end
	end
	assert(self:Next() == "}")
	return result
end

function JsonReader:SkipWhiteSpace()
	local p = self:Peek()
	while p ~= nil and string.find(p, "[%s/]") do
		if p == '/' then
			self:ReadComment()
		else
			self:Next()
		end
		p = self:Peek()
	end
end

function JsonReader:Peek()
	return self.reader:Peek()
end

function JsonReader:Next()
	return self.reader:Next()
end

function JsonReader:All()
	return self.reader:All()
end

function Encode(o)
	local writer = JsonWriter:New()
	writer:Write(o)
	return writer:ToString()
end

function Decode(s)
	local reader = JsonReader:New(s)
	return reader:Read()
end

function Null()
	return Null
end
-------------------- End JSON Parser ------------------------

t.DecodeJSON = function(jsonString)
	pcall(function() warn("RbxUtility.DecodeJSON is deprecated, please use Game:GetService('HttpService'):JSONDecode() instead.") end)

	if type(jsonString) == "string" then
		return Decode(jsonString)
	end
	print("RbxUtil.DecodeJSON expects string argument!")
	return nil
end

t.EncodeJSON = function(jsonTable)
	pcall(function() warn("RbxUtility.EncodeJSON is deprecated, please use Game:GetService('HttpService'):JSONEncode() instead.") end)
	return Encode(jsonTable)
end








------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------------------------------------Terrain Utilities Begin-----------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--makes a wedge at location x, y, z
--sets cell x, y, z to default material if parameter is provided, if not sets cell x, y, z to be whatever material it previously w
--returns true if made a wedge, false if the cell remains a block
t.MakeWedge = function(x, y, z, defaultmaterial)
	return game:GetService("Terrain"):AutoWedgeCell(x,y,z)
end

t.SelectTerrainRegion = function(regionToSelect, color, selectEmptyCells, selectionParent)
	local terrain = game:GetService("Workspace"):FindFirstChild("Terrain")
	if not terrain then return end

	assert(regionToSelect)
	assert(color)

	if not type(regionToSelect) == "Region3" then
		error("regionToSelect (first arg), should be of type Region3, but is type",type(regionToSelect))
	end
	if not type(color) == "BrickColor" then
		error("color (second arg), should be of type BrickColor, but is type",type(color))
	end

	-- frequently used terrain calls (speeds up call, no lookup necessary)
	local GetCell = terrain.GetCell
	local WorldToCellPreferSolid = terrain.WorldToCellPreferSolid
	local CellCenterToWorld = terrain.CellCenterToWorld
	local emptyMaterial = Enum.CellMaterial.Empty

	-- container for all adornments, passed back to user
	local selectionContainer = Instance.new("Model")
	selectionContainer.Name = "SelectionContainer"
	selectionContainer.Archivable = false
	if selectionParent then
		selectionContainer.Parent = selectionParent
	else
		selectionContainer.Parent = game:GetService("Workspace")
	end

	local updateSelection = nil -- function we return to allow user to update selection
	local currentKeepAliveTag = nil -- a tag that determines whether adorns should be destroyed
	local aliveCounter = 0 -- helper for currentKeepAliveTag
	local lastRegion = nil -- used to stop updates that do nothing
	local adornments = {} -- contains all adornments
	local reusableAdorns = {}

	local selectionPart = Instance.new("Part")
	selectionPart.Name = "SelectionPart"
	selectionPart.Transparency = 1
	selectionPart.Anchored = true
	selectionPart.Locked = true
	selectionPart.CanCollide = false
	selectionPart.Size = Vector3.new(4.2,4.2,4.2)

	local selectionBox = Instance.new("SelectionBox")

	-- srs translation from region3 to region3int16
	local function Region3ToRegion3int16(region3)
		local theLowVec = region3.CFrame.p - (region3.Size/2) + Vector3.new(2,2,2)
		local lowCell = WorldToCellPreferSolid(terrain,theLowVec)

		local theHighVec = region3.CFrame.p + (region3.Size/2) - Vector3.new(2,2,2)
		local highCell = WorldToCellPreferSolid(terrain, theHighVec)

		local highIntVec = Vector3int16.new(highCell.x,highCell.y,highCell.z)
		local lowIntVec = Vector3int16.new(lowCell.x,lowCell.y,lowCell.z)

		return Region3int16.new(lowIntVec,highIntVec)
	end

	-- helper function that creates the basis for a selection box
	function createAdornment(theColor)
		local selectionPartClone = nil
		local selectionBoxClone = nil

		if #reusableAdorns > 0 then
			selectionPartClone = reusableAdorns[1]["part"]
			selectionBoxClone = reusableAdorns[1]["box"]
			table.remove(reusableAdorns,1)

			selectionBoxClone.Visible = true
		else
			selectionPartClone = selectionPart:Clone()
			selectionPartClone.Archivable = false

			selectionBoxClone = selectionBox:Clone()
			selectionBoxClone.Archivable = false

			selectionBoxClone.Adornee = selectionPartClone
			selectionBoxClone.Parent = selectionContainer

			selectionBoxClone.Adornee = selectionPartClone

			selectionBoxClone.Parent = selectionContainer
		end

		if theColor then
			selectionBoxClone.Color = theColor
		end

		return selectionPartClone, selectionBoxClone
	end

	-- iterates through all current adornments and deletes any that don't have latest tag
	function cleanUpAdornments()
		for cellPos, adornTable in pairs(adornments) do

			if adornTable.KeepAlive ~= currentKeepAliveTag then -- old news, we should get rid of this
				adornTable.SelectionBox.Visible = false
				table.insert(reusableAdorns,{part = adornTable.SelectionPart, box = adornTable.SelectionBox})
				adornments[cellPos] = nil
			end
		end
	end

	-- helper function to update tag
	function incrementAliveCounter()
		aliveCounter = aliveCounter + 1
		if aliveCounter > 1000000 then
			aliveCounter = 0
		end
		return aliveCounter
	end

	-- finds full cells in region and adorns each cell with a box, with the argument color
	function adornFullCellsInRegion(region, color)
		local regionBegin = region.CFrame.p - (region.Size/2) + Vector3.new(2,2,2)
		local regionEnd = region.CFrame.p + (region.Size/2) - Vector3.new(2,2,2)

		local cellPosBegin = WorldToCellPreferSolid(terrain, regionBegin)
		local cellPosEnd = WorldToCellPreferSolid(terrain, regionEnd)

		currentKeepAliveTag = incrementAliveCounter()
		for y = cellPosBegin.y, cellPosEnd.y do
			for z = cellPosBegin.z, cellPosEnd.z do
				for x = cellPosBegin.x, cellPosEnd.x do
					local cellMaterial = GetCell(terrain, x, y, z)

					if cellMaterial ~= emptyMaterial then
						local cframePos = CellCenterToWorld(terrain, x, y, z)
						local cellPos = Vector3int16.new(x,y,z)

						local updated = false
						for cellPosAdorn, adornTable in pairs(adornments) do
							if cellPosAdorn == cellPos then
								adornTable.KeepAlive = currentKeepAliveTag
								if color then
									adornTable.SelectionBox.Color = color
								end
								updated = true
								break
							end 
						end

						if not updated then
							local selectionPart, selectionBox = createAdornment(color)
							selectionPart.Size = Vector3.new(4,4,4)
							selectionPart.CFrame = CFrame.new(cframePos)
							local adornTable = {SelectionPart = selectionPart, SelectionBox = selectionBox, KeepAlive = currentKeepAliveTag}
							adornments[cellPos] = adornTable
						end
					end
				end
			end
		end
		cleanUpAdornments()
	end


	------------------------------------- setup code ------------------------------
	lastRegion = regionToSelect

	if selectEmptyCells then -- use one big selection to represent the area selected
		local selectionPart, selectionBox = createAdornment(color)

		selectionPart.Size = regionToSelect.Size
		selectionPart.CFrame = regionToSelect.CFrame

		adornments.SelectionPart = selectionPart
		adornments.SelectionBox = selectionBox

		updateSelection = 
			function (newRegion, color)
				if newRegion and newRegion ~= lastRegion then
				lastRegion = newRegion
				selectionPart.Size = newRegion.Size
				selectionPart.CFrame = newRegion.CFrame
			end
				if color then
				selectionBox.Color = color
			end
			end
	else -- use individual cell adorns to represent the area selected
		adornFullCellsInRegion(regionToSelect, color)
		updateSelection = 
			function (newRegion, color)
				if newRegion and newRegion ~= lastRegion then
				lastRegion = newRegion
				adornFullCellsInRegion(newRegion, color)
			end
			end

	end

	local destroyFunc = function()
		updateSelection = nil
		if selectionContainer then selectionContainer:Destroy() end
		adornments = nil
	end

	return updateSelection, destroyFunc
end

-----------------------------Terrain Utilities End-----------------------------







------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------Signal class begin------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--[[
A 'Signal' object identical to the internal RBXScriptSignal object in it's public API and semantics. This function 
can be used to create "custom events" for user-made code.
API:
Method :connect( function handler )
	Arguments:   The function to connect to.
	Returns:     A new connection object which can be used to disconnect the connection
	Description: Connects this signal to the function specified by |handler|. That is, when |fire( ... )| is called for
	             the signal the |handler| will be called with the arguments given to |fire( ... )|. Note, the functions
	             connected to a signal are called in NO PARTICULAR ORDER, so connecting one function after another does
	             NOT mean that the first will be called before the second as a result of a call to |fire|.

Method :disconnect()
	Arguments:   None
	Returns:     None
	Description: Disconnects all of the functions connected to this signal.

Method :fire( ... )
	Arguments:   Any arguments are accepted
	Returns:     None
	Description: Calls all of the currently connected functions with the given arguments.

Method :wait()
	Arguments:   None
	Returns:     The arguments given to fire
	Description: This call blocks until 
]]

function t.CreateSignal()
	local this = {}

	local mBindableEvent = Instance.new('BindableEvent')
	local mAllCns = {} --all connection objects returned by mBindableEvent::connect

	--main functions
	function this:connect(func)
		if self ~= this then error("connect must be called with `:`, not `.`", 2) end
		if type(func) ~= 'function' then
			error("Argument #1 of connect must be a function, got a "..type(func), 2)
		end
		local cn = mBindableEvent.Event:Connect(func)
		mAllCns[cn] = true
		local pubCn = {}
		function pubCn:disconnect()
			cn:Disconnect()
			mAllCns[cn] = nil
		end
		pubCn.Disconnect = pubCn.disconnect

		return pubCn
	end

	function this:disconnect()
		if self ~= this then error("disconnect must be called with `:`, not `.`", 2) end
		for cn, _ in pairs(mAllCns) do
			cn:Disconnect()
			mAllCns[cn] = nil
		end
	end

	function this:wait()
		if self ~= this then error("wait must be called with `:`, not `.`", 2) end
		return mBindableEvent.Event:Wait()
	end

	function this:fire(...)
		if self ~= this then error("fire must be called with `:`, not `.`", 2) end
		mBindableEvent:Fire(...)
	end

	this.Connect = this.connect
	this.Disconnect = this.disconnect
	this.Wait = this.wait
	this.Fire = this.fire

	return this
end

------------------------------------------------- Sigal class End ------------------------------------------------------




------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------Create Function Begins---------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--[[
A "Create" function for easy creation of Roblox instances. The function accepts a string which is the classname of
the object to be created. The function then returns another function which either accepts accepts no arguments, in 
which case it simply creates an object of the given type, or a table argument that may contain several types of data, 
in which case it mutates the object in varying ways depending on the nature of the aggregate data. These are the
type of data and what operation each will perform:
1) A string key mapping to some value:
      Key-Value pairs in this form will be treated as properties of the object, and will be assigned in NO PARTICULAR
      ORDER. If the order in which properties is assigned matter, then they must be assigned somewhere else than the
      |Create| call's body.

2) An integral key mapping to another Instance:
      Normal numeric keys mapping to Instances will be treated as children if the object being created, and will be
      parented to it. This allows nice recursive calls to Create to create a whole hierarchy of objects without a
      need for temporary variables to store references to those objects.

3) A key which is a value returned from Create.Event( eventname ), and a value which is a function function
      The Create.E( string ) function provides a limited way to connect to signals inside of a Create hierarchy 
      for those who really want such a functionality. The name of the event whose name is passed to 
      Create.E( string )

4) A key which is the Create function itself, and a value which is a function
      The function will be run with the argument of the object itself after all other initialization of the object is 
      done by create. This provides a way to do arbitrary things involving the object from withing the create 
      hierarchy. 
      Note: This function is called SYNCHRONOUSLY, that means that you should only so initialization in
      it, not stuff which requires waiting, as the Create call will block until it returns. While waiting in the 
      constructor callback function is possible, it is probably not a good design choice.
      Note: Since the constructor function is called after all other initialization, a Create block cannot have two 
      constructor functions, as it would not be possible to call both of them last, also, this would be unnecessary.


Some example usages:

A simple example which uses the Create function to create a model object and assign two of it's properties.
local model = Create'Model'{
    Name = 'A New model',
    Parent = game.Workspace,
}


An example where a larger hierarchy of object is made. After the call the hierarchy will look like this:
Model_Container
 |-ObjectValue
 |  |
 |  `-BoolValueChild
 `-IntValue

local model = Create'Model'{
    Name = 'Model_Container',
    Create'ObjectValue'{
        Create'BoolValue'{
            Name = 'BoolValueChild',
        },
    },
    Create'IntValue'{},
}


An example using the event syntax:

local part = Create'Part'{
    [Create.E'Touched'] = function(part)
        print("I was touched by "..part.Name)
    end,	
}


An example using the general constructor syntax:

local model = Create'Part'{
    [Create] = function(this)
        print("Constructor running!")
        this.Name = GetGlobalFoosAndBars(this)
    end,
}


Note: It is also perfectly legal to save a reference to the function returned by a call Create, this will not cause
      any unexpected behavior. EG:
      local partCreatingFunction = Create'Part'
      local part = partCreatingFunction()
]]

--the Create function need to be created as a functor, not a function, in order to support the Create.E syntax, so it
--will be created in several steps rather than as a single function declaration.
local function Create_PrivImpl(objectType)
	if type(objectType) ~= 'string' then
		error("Argument of Create must be a string", 2)
	end
	--return the proxy function that gives us the nice Create'string'{data} syntax
	--The first function call is a function call using Lua's single-string-argument syntax
	--The second function call is using Lua's single-table-argument syntax
	--Both can be chained together for the nice effect.
	return function(dat)
		--default to nothing, to handle the no argument given case
		dat = dat or {}

		--make the object to mutate
		local obj = Instance.new(objectType)
		local parent = nil

		--stored constructor function to be called after other initialization
		local ctor = nil

		for k, v in pairs(dat) do
			--add property
			if type(k) == 'string' then
				if k == 'Parent' then
					-- Parent should always be set last, setting the Parent of a new object
					-- immediately makes performance worse for all subsequent property updates.
					parent = v
				else
					obj[k] = v
				end


				--add child
			elseif type(k) == 'number' then
				if type(v) ~= 'userdata' then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: "..type(v), 2)
				end
				v.Parent = obj


				--event connect
			elseif type(k) == 'table' and k.__eventname then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create.E\'"..k.__eventname.."\']` must have a function value\
					       got: "..tostring(v), 2)
				end
				obj[k.__eventname]:connect(v)


				--define constructor function
			elseif k == t.Create then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create]` should be paired with a constructor function, \
					       got: "..tostring(v), 2)
				elseif ctor then
					--ctor already exists, only one allowed
					error("Bad entry in Create body: Only one constructor function is allowed", 2)
				end
				ctor = v


			else
				error("Bad entry ("..tostring(k).." => "..tostring(v)..") in Create body", 2)
			end
		end

		--apply constructor function if it exists
		if ctor then
			ctor(obj)
		end

		if parent then
			obj.Parent = parent
		end

		--return the completed object
		return obj
	end
end

--now, create the functor:
t.Create = setmetatable({}, {__call = function(tb, ...) return Create_PrivImpl(...) end})

--and create the "Event.E" syntax stub. Really it's just a stub to construct a table which our Create
--function can recognize as special.
t.Create.E = function(eventName)
	return {__eventname = eventName}
end

-------------------------------------------------Create function End----------------------------------------------------




------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------Documentation Begin-----------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

t.Help = 
	function(funcNameOrFunc) 
		--input argument can be a string or a function.  Should return a description (of arguments and expected side effects)
		if funcNameOrFunc == "DecodeJSON" or funcNameOrFunc == t.DecodeJSON then
		return "Function DecodeJSON.  " ..
			"Arguments: (string).  " .. 
			"Side effect: returns a table with all parsed JSON values" 
	end
		if funcNameOrFunc == "EncodeJSON" or funcNameOrFunc == t.EncodeJSON then
		return "Function EncodeJSON.  " ..
			"Arguments: (table).  " .. 
			"Side effect: returns a string composed of argument table in JSON data format" 
	end  
		if funcNameOrFunc == "MakeWedge" or funcNameOrFunc == t.MakeWedge then
		return "Function MakeWedge. " ..
			"Arguments: (x, y, z, [default material]). " ..
			"Description: Makes a wedge at location x, y, z. Sets cell x, y, z to default material if "..
			"parameter is provided, if not sets cell x, y, z to be whatever material it previously was. "..
			"Returns true if made a wedge, false if the cell remains a block "
	end
		if funcNameOrFunc == "SelectTerrainRegion" or funcNameOrFunc == t.SelectTerrainRegion then
		return "Function SelectTerrainRegion. " ..
			"Arguments: (regionToSelect, color, selectEmptyCells, selectionParent). " ..
			"Description: Selects all terrain via a series of selection boxes within the regionToSelect " ..
			"(this should be a region3 value). The selection box color is detemined by the color argument " ..
			"(should be a brickcolor value). SelectionParent is the parent that the selection model gets placed to (optional)." ..
			"SelectEmptyCells is bool, when true will select all cells in the " ..
			"region, otherwise we only select non-empty cells. Returns a function that can update the selection," ..
			"arguments to said function are a new region3 to select, and the adornment color (color arg is optional). " ..
			"Also returns a second function that takes no arguments and destroys the selection"
	end
		if funcNameOrFunc == "CreateSignal" or funcNameOrFunc == t.CreateSignal then
		return "Function CreateSignal. "..
			"Arguments: None. "..
			"Returns: The newly created Signal object. This object is identical to the RBXScriptSignal class "..
			"used for events in Objects, but is a Lua-side object so it can be used to create custom events in"..
			"Lua code. "..
			"Methods of the Signal object: :connect, :wait, :fire, :disconnect. "..
			"For more info you can pass the method name to the Help function, or view the wiki page "..
			"for this library. EG: Help('Signal:connect')."
	end
		if funcNameOrFunc == "Signal:connect" then
		return "Method Signal:connect. "..
			"Arguments: (function handler). "..
			"Return: A connection object which can be used to disconnect the connection to this handler. "..
			"Description: Connectes a handler function to this Signal, so that when |fire| is called the "..
			"handler function will be called with the arguments passed to |fire|."
	end
		if funcNameOrFunc == "Signal:wait" then
		return "Method Signal:wait. "..
			"Arguments: None. "..
			"Returns: The arguments passed to the next call to |fire|. "..
			"Description: This call does not return until the next call to |fire| is made, at which point it "..
			"will return the values which were passed as arguments to that |fire| call."
	end
		if funcNameOrFunc == "Signal:fire" then
		return "Method Signal:fire. "..
			"Arguments: Any number of arguments of any type. "..
			"Returns: None. "..
			"Description: This call will invoke any connected handler functions, and notify any waiting code "..
			"attached to this Signal to continue, with the arguments passed to this function. Note: The calls "..
			"to handlers are made asynchronously, so this call will return immediately regardless of how long "..
			"it takes the connected handler functions to complete."
	end
		if funcNameOrFunc == "Signal:disconnect" then
		return "Method Signal:disconnect. "..
			"Arguments: None. "..
			"Returns: None. "..
			"Description: This call disconnects all handlers attacched to this function, note however, it "..
			"does NOT make waiting code continue, as is the behavior of normal Roblox events. This method "..
			"can also be called on the connection object which is returned from Signal:connect to only "..
			"disconnect a single handler, as opposed to this method, which will disconnect all handlers."
	end
		if funcNameOrFunc == "Create" then
		return "Function Create. "..
			"Arguments: A table containing information about how to construct a collection of objects. "..
			"Returns: The constructed objects. "..
			"Descrition: Create is a very powerfull function, whose description is too long to fit here, and "..
			"is best described via example, please see the wiki page for a description of how to use it."
	end
	end

--------------------------------------------Documentation Ends----------------------------------------------------------
















--[[KillerDarkness0105's/Codex#6685 Touhou magic script]]--


plr = "VolcanoReg"
Player=game:GetService("Players")[plr]
Character=Player.Character
PlayerGui=Player.PlayerGui
Backpack=Player.Backpack
Torso=Character.Torso
Head=Character.Head
Humanoid=Character.Humanoid
LeftArm=Character["Left Arm"]
LeftLeg=Character["Left Leg"]
RightArm=Character["Right Arm"]
RightLeg=Character["Right Leg"]
LS=Torso["Left Shoulder"]
LH=Torso["Left Hip"]
RS=Torso["Right Shoulder"]
RH=Torso["Right Hip"]
Face = Head.face
Neck=Torso.Neck
it=Instance.new
attacktype=1
attacktype2=1
vt=Vector3.new
cf=CFrame.new
cn=CFrame.new
euler=CFrame.fromEulerAnglesXYZ
angles=CFrame.Angles
necko=cf(0, 1, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0)
necko2=cf(0, -0.5, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0)
LHC0=cf(-1,-1,0,-0,-0,-1,0,1,0,1,0,0)
LHC1=cf(-0.5,1,0,-0,-0,-1,0,1,0,1,0,0)
RHC0=cf(1,-1,0,0,0,1,0,1,0,-1,-0,-0)
RHC1=cf(0.5,1,0,0,0,1,0,1,0,-1,-0,-0)
RootPart=Character.HumanoidRootPart
RootJoint=RootPart.RootJoint
RootCF=euler(-1.57,0,3.14)
attack = false
attackdebounce = false
trispeed=.2
attackmode='none'
local idle=0
local Anim="Idle"
stance = false
local ff = 2
noleg = false
evadecooldown = false
Humanoid.Animator.Parent = nil
equip = false
local Effects = {}
 attackspeed = 0.14 
 df = false
 Swing = 1
local sine = 0
local change = 1
local val = 0
magic = false
cam = workspace.CurrentCamera
deb = game:GetService("Debris")
RbxUtility = t
Create = RbxUtility.Create
Humanoid.WalkSpeed = 32
Humanoid.JumpPower = 76
local g ="Lime green"
local r ="Dark indigo"






music = Instance.new("Sound",Torso) -- change to Character for global music --Change to Torso for non-global music. You may wanna leave this at torso tho...
music.Volume = 0.5
music.TimePosition = 0
music.Pitch = 1
if Player.Name == "TheSatanicAngel" then
music.SoundId = "rbxassetid://512289595"--576413172 --music2 = 1117522463 --music3 = 903651242 --music4 = 611389938 -- 541377118  490561591
else
music.SoundId = "rbxassetid://803364705"--576413172 --music2 = 1117522463 --music3 = 903651242 --music4 = 611389938 -- 541377118  490561591
end
music.Looped = true
music:Play()







local handee = Instance.new("Part")
handee.Parent = Character
handee.Size = Vector3.new(.2,.2,.2)
handee.Archivable = true
handee.Transparency = 1
handee.CanCollide = false
handee.BrickColor = BrickColor.new("Cyan")
handee.Material = "Neon"
local handeeweld = Instance.new("Weld")
handeeweld.Parent = handee
handeeweld.Part0 = RightArm
handeeweld.Part1 = handee
handeeweld.C1 = CFrame.new(0, 0.97, 0)*CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))
handeeweld.Part0 = RightArm
        
        
        
        
    
        
        
        
        
        
        
        
so = function(id,par,vol,pit)
    coroutine.resume(coroutine.create(function()
    local sou = Instance.new("Sound",par or workspace)
    sou.Volume=vol
    sou.Pitch=pit or 1
    sou.SoundId=id
    swait()
    sou:play()
    game:GetService("Debris"):AddItem(sou,8)
    end))
end

--save shoulders
RSH, LSH=nil, nil
--welds
RW, LW=Instance.new("Weld"), Instance.new("Weld")
RW.Name="Right Shoulder" LW.Name="Left Shoulder"
LH=Torso["Left Hip"]
RH=Torso["Right Hip"]
TorsoColor=Torso.BrickColor

function NoOutline(Part)
Part.TopSurface,Part.BottomSurface,Part.LeftSurface,Part.RightSurface,Part.FrontSurface,Part.BackSurface = 10,10,10,10,10,10
end

player=Player
ch=Character
RSH=ch.Torso["Right Shoulder"]
LSH=ch.Torso["Left Shoulder"]
--
RSH.Parent=nil
LSH.Parent=nil
--
RW.Name="Right Shoulder"
RW.Part0=ch.Torso
RW.C0=cf(1.5, 0.5, 0) --* CFrame.fromEulerAnglesXYZ(1.3, 0, -0.5)
RW.C1=cf(0, 0.5, 0)
RW.Part1=ch["Right Arm"]
RW.Parent=ch.Torso
--
LW.Name="Left Shoulder"
LW.Part0=ch.Torso
LW.C0=cf(-1.5, 0.5, 0) --* CFrame.fromEulerAnglesXYZ(1.7, 0, 0.8)
LW.C1=cf(0, 0.5, 0)
LW.Part1=ch["Left Arm"]
LW.Parent=ch.Torso
 
 
newWeld = function(wp0, wp1, wc0x, wc0y, wc0z)
    local wld = Instance.new("Weld", wp1)
    wld.Part0 = wp0
    wld.Part1 = wp1
    wld.C0 = CFrame.new(wc0x, wc0y, wc0z)
end
 
 
newWeld(RootPart, Torso, 0, -1, 0)
Torso.Weld.C1 = CFrame.new(0, -1, 0)
newWeld(Torso, LeftLeg, -0.5, -1, 0)
LeftLeg.Weld.C1 = CFrame.new(0, 1, 0)
newWeld(Torso, RightLeg, 0.5, -1, 0)
RightLeg.Weld.C1 = CFrame.new(0, 1, 0)

Player=game:GetService('Players')[plr]
Character=Player.Character
mouse=Player:GetMouse() -- need fix
m=Instance.new('Model',Character)
 
 
    local function weldBetween(a, b)
        local weldd = Instance.new("ManualWeld")
        weldd.Part0 = a
        weldd.Part1 = b
        weldd.C0 = CFrame.new()
        weldd.C1 = b.CFrame:inverse() * a.CFrame
        weldd.Parent = a
        return weldd
    end
   
    ArtificialHB = Instance.new("BindableEvent", script)
ArtificialHB.Name = "Heartbeat"
 
script:WaitForChild("Heartbeat")
 
frame = 1 / 60
tf = 0
allowframeloss = false
tossremainder = false
lastframe = tick()
script.Heartbeat:Fire()

game:GetService("RunService").Heartbeat:Connect(function(s, p)
    tf = tf + s
    if tf >= frame then
        if allowframeloss then
            script.Heartbeat:Fire()
            lastframe = tick()
        else
            for i = 1, math.floor(tf / frame) do
                script.Heartbeat:Fire()
            end
            lastframe = tick()
        end
        if tossremainder then
            tf = 0
        else
            tf = tf - frame * math.floor(tf / frame)
        end
    end
end)
 
function swait(num)
    if num == 0 or num == nil then
        ArtificialHB.Event:wait()
    elseif num ~= 0 or num ~= nil then
        for i = 0, num do
            ArtificialHB.Event:wait()
        end
    end
end
 
 
 
function RemoveOutlines(part)
    part.TopSurface, part.BottomSurface, part.LeftSurface, part.RightSurface, part.FrontSurface, part.BackSurface = 10, 10, 10, 10, 10, 10
end
   

part = function(formfactor, parent, reflectance, transparency, brickcolor, name, size)
  local fp = it("Part")
  fp.formFactor = formfactor
  fp.Parent = parent
  fp.Reflectance = reflectance
  fp.Transparency = transparency
  fp.CanCollide = false
  fp.Locked = true
  fp.BrickColor = brickcolor
  fp.Name = name
  fp.Size = size
  fp.Position = Torso.Position
  NoOutline(fp)
  if fp.BrickColor == BrickColor.new("Dark indigo") then
    fp.Material = "Neon"
  else
    if fp.BrickColor == BrickColor.new("Fossil") then
      fp.BrickColor = BrickColor.new("Dark indigo")
      fp.Material = "Neon"
    else
      fp.Material = "Neon"
    end
  end
  fp:BreakJoints()
  return fp
end

mesh = function(Mesh, part, meshtype, meshid, offset, scale)
  local mesh = it(Mesh)
  mesh.Parent = part
  if Mesh == "SpecialMesh" then
    mesh.MeshType = meshtype
    mesh.MeshId = meshid
  end
  mesh.Offset = offset
  mesh.Scale = scale
  return mesh
end

weld = function(parent, part0, part1, c0)
  local weld = it("Weld")
  weld.Parent = parent
  weld.Part0 = part0
  weld.Part1 = part1
  weld.C0 = c0
  return weld
end

F1 = Instance.new("Folder", Character)
F1.Name = "Effects Folder"
F2 = Instance.new("Folder", F1)
F2.Name = "Effects"
Triangle = function(a, b, c)
end

MagicBlock4 = function(brickcolor, cframe, x1, y1, z1, x3, y3, z3, delay)
  local prt = part(3, F2, 0, 0, brickcolor, "Effect", vt())
  prt.Anchored = true
  prt.CanCollide = false
  prt.CFrame = cframe
  prt.Name = "prt"
  msh = mesh("BlockMesh", prt, "", "", vt(0, 0, 0), vt(x1, y1, z1))
  game:GetService("Debris"):AddItem(prt, 5)
  table.insert(Effects, {prt, "Block1", delay, x3, y3, z3})
end



MagicCircle4 = function(brickcolor, cframe, x1, y1, z1, x3, y3, z3, delay)
  local prt = part(3, F2, 0, 0, brickcolor, "Effect", vt())
  prt.Anchored = true
  prt.CanCollide = false
  prt.CFrame = cframe
  prt.Name = "prt"
  local msh = mesh("SpecialMesh", prt, "Sphere", "", vt(0, 0, 0), vt(x1, y1, z1))
  game:GetService("Debris"):AddItem(prt, 5)
  table.insert(Effects, {prt, "Cylinder", delay, x3, y3, z3})
end

MagicWave4 = function(brickcolor, cframe, x1, y1, z1, x3, y3, z3, delay)
  local prt = part(3, F2, 0, 0, brickcolor, "Effect", vt())
  prt.Anchored = true
  prt.CFrame = cframe
  local msh = mesh("SpecialMesh", prt, "FileMesh", "http://www.roblox.com/asset/?id=20329976", vt(0, 0, 0), vt(x1, y1, z1))
  game:GetService("Debris"):AddItem(prt, 5)
  table.insert(Effects, {prt, "Cylinder", delay, x3, y3, z3})
end

MagicCylinder4 = function(brickcolor, cframe, x1, y1, z1, x3, y3, z3, delay)
  local prt = part(3, F2, 0, 0, brickcolor, "Effect", vt(0.2, 0.2, 0.2))
  prt.Anchored = true
  prt.CFrame = cframe
  msh = mesh("SpecialMesh", prt, "Head", "", vt(0, 0, 0), vt(x1, y1, z1))
  game:GetService("Debris"):AddItem(prt, 5)
  Effects[#Effects + 1] = {prt, "Cylinder", delay, x3, y3, z3}
end

MagicCylinder5 = function(brickcolor, cframe, x1, y1, z1, x3, y3, z3, delay)
  local prt = part(3, F2, 0, 0, brickcolor, "Effect", vt(0.2, 0.2, 0.2))
  prt.Anchored = true
  prt.CFrame = cframe
  msh = mesh("CylinderMesh", prt, "", "", vt(0, 0, 0), vt(x1, y1, z1))
  game:GetService("Debris"):AddItem(prt, 5)
  Effects[#Effects + 1] = {prt, "Cylinder", delay, x3, y3, z3}
end

MagicBlood4 = function(brickcolor, cframe, x1, y1, z1, x3, y3, z3, delay)
  local prt = part(3, F2, 0, 0, brickcolor, "Effect", vt())
  prt.Anchored = true
  prt.CFrame = cframe
  local msh = mesh("SpecialMesh", prt, "Sphere", "", vt(0, 0, 0), vt(x1, y1, z1))
  game:GetService("Debris"):AddItem(prt, 5)
  table.insert(Effects, {prt, "Blood", delay, x3, y3, z3})
end

ElecEffect4 = function(cff, x, y, z)
  local prt = part(3, F2, 0, 0, BrickColor.new("Dark indigo"), "Part", vt(1, 1, 1))
  prt.Anchored = true
  prt.CFrame = cff * cf(math.random(-x, x), math.random(-y, y), math.random(-z, z))
  prt.CFrame = cf(prt.Position)
  game:GetService("Debris"):AddItem(prt, 2)
  xval = math.random() / 2
  yval = math.random() / 2
  zval = math.random() / 2
  msh = mesh("BlockMesh", prt, "", "", vt(0, 0, 0), vt(xval, yval, zval))
  Effects[#Effects + 1] = {prt, "Elec", 0.1, x, y, z, xval, yval, zval}
end

function SkullEffect(brickcolor,cframe,x1,y1,z1,delay)
local prt=part(3,workspace,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.CFrame=cframe
local msh=mesh("SpecialMesh",prt,"FileMesh","http://www.roblox.com/asset/?id=4770583",vt(0,0,0),vt(x1,y1,z1))
--http://www.roblox.com/asset/?id=4770560
game:GetService("Debris"):AddItem(prt,2)
CF=prt.CFrame
coroutine.resume(coroutine.create(function(Part,Mesh,TehCF) 
for i=0,1,0.2 do
wait()
Part.CFrame=CF*cf(0,0,-0.4)
end
for i=0,1,delay do
wait()
--Part.CFrame=CF*cf((math.random(-1,0)+math.random())/5,(math.random(-1,0)+math.random())/5,(math.random(-1,0)+math.random())/5)
Mesh.Scale=Mesh.Scale
end
for i=0,1,0.1 do
wait()
Part.Transparency=i
end
Part.Parent=nil
end),prt,msh,CF)
end
 
function MagicBlock(brickcolor,cframe,x1,y1,z1,x3,y3,z3,delay)
local prt=part(3,Character,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.Material = "Neon"
prt.CFrame=cframe
prt.CFrame=prt.CFrame*euler(math.random(-50,50),math.random(-50,50),math.random(-50,50))
msh=mesh("BlockMesh",prt,"","",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh) 
for i=0,1,delay do
swait()
Part.CFrame=Part.CFrame*euler(math.random(-50,50),math.random(-50,50),math.random(-50,50))
Part.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,z3)
end
Part.Parent=nil
end),prt,msh)
end

function MagicBlockSteady(brickcolor,cframe,x1,y1,z1,x3,y3,z3,delay,rottype)
local prt=part(3,Character,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.Material = "Neon"
prt.CFrame=cframe
msh=mesh("BlockMesh",prt,"","",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh) 
	local rtype = rottype
for i=0,1,delay do
swait()
if rtype == 1 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,0.1)
elseif rtype == 2 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,-0.1)
end
Part.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,z3)
end
Part.Parent=nil
end),prt,msh)
end

function MagicSphere(brickcolor,cframe,x1,y1,z1,x3,y3,z3,delay)
local prt=part(3,Character,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.CFrame=cframe
prt.CFrame=prt.CFrame*euler(math.random(-50,50),math.random(-50,50),math.random(-50,50))
msh=mesh("SpecialMesh",prt,"Sphere","",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh) 
for i=0,1,delay do
swait()
Part.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,z3)
end
Part.Parent=nil
end),prt,msh)
end

function MagicBlockSteady(brickcolor,cframe,x1,y1,z1,x3,y3,z3,delay,rottype)
local prt=part(3,Character,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.Material = "Neon"
prt.CFrame=cframe
msh=mesh("BlockMesh",prt,"","",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh) 
	local rtype = rottype
for i=0,1,delay do
swait()
if rtype == 1 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,0.1)
elseif rtype == 2 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,-0.1)
end
Part.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,z3)
end
Part.Parent=nil
end),prt,msh)
end

function MagicShock(brickcolor,cframe,x1,y1,x3,y3,delay,rottype)
local prt=part(3,Character,1,1,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.Material = "Neon"
prt.CFrame=cframe
local dec = decal(prt.Color,"http://www.roblox.com/asset/?id=874580939","Front",prt)
local dec2 = decal(prt.Color,"http://www.roblox.com/asset/?id=874580939","Front",prt)
msh=mesh("BlockMesh",prt,"","",vt(0,0,0),vt(x1,y1,0.01))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh) 
	local rtype = rottype
for i=0,1,delay do
swait()
if rtype == 1 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,0.1)
elseif rtype == 2 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,-0.1)
end
dec.Transparency=i
dec2.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,0)
end
Part.Parent=nil
end),prt,msh)
end

function MagicShockAlt(brickcolor,cframe,x1,y1,x3,y3,delay,rottype)
local prt=part(3,Character,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.Material = "Neon"
prt.CFrame=cframe
msh=mesh("BlockMesh",prt,"","",vt(0,0,0),vt(x1,y1,0.01))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh) 
	local rtype = rottype
for i=0,1,delay do
swait()
if rtype == 1 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,0.1)
elseif rtype == 2 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,-0.1)
end
prt.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,0)
end
Part.Parent=nil
end),prt,msh)
end

function MagicShockAltCircle(brickcolor,cframe,x1,z1,x3,z3,delay,rottype)
local prt=part(3,Character,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.Material = "Neon"
prt.CFrame=cframe
msh=mesh("BlockMesh",prt,"","",vt(0,0,0),vt(x1,1,z1))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh) 
	local rtype = rottype
for i=0,1,delay do
swait()
if rtype == 1 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0.1,0)
elseif rtype == 2 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,-0.1,0)
end
prt.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,0,z3)
end
Part.Parent=nil
end),prt,msh)
end

function MagicShockTrailAlt(brickcolor,cframe,x1,y1,z1,x3,y3,delay,rottype)
local prt=part(3,Character,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.Material = "Neon"
prt.CFrame=cframe
msh=mesh("BlockMesh",prt,"","",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh) 
	local rtype = rottype
for i=0,1,delay do
swait()
if rtype == 1 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,0.1)
elseif rtype == 2 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,-0.1)
end
prt.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,0)
end
Part.Parent=nil
end),prt,msh)
end

function MagicShockTrailAlt2(brickcolor,cframe,x1,y1,z1,x3,y3,z3,delay,rottype)
local prt=part(3,Character,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.Material = "Neon"
prt.CFrame=cframe
msh=mesh("BlockMesh",prt,"","",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh) 
	local rtype = rottype
for i=0,1,delay do
swait()
if rtype == 1 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,0.1)
elseif rtype == 2 then
prt.CFrame = prt.CFrame*CFrame.Angles(0,0,-0.1)
end
prt.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,z3)
end
Part.Parent=nil
end),prt,msh)
end
 
function MagicBlock2(brickcolor,cframe,Parent,x1,y1,z1,x3,y3,z3,delay)
local prt=part(3,Character,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=false
prt.CFrame=cframe
msh=mesh("BlockMesh",prt,"","",vt(0,0,0),vt(x1,y1,z1))
local wld=weld(prt,prt,Parent,cframe)
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh,Weld) 
for i=0,1,delay do
swait()
Weld.C0=euler(math.random(-50,50),math.random(-50,50),math.random(-50,50))*cframe
--Part.CFrame=Part.CFrame*euler(math.random(-50,50),math.random(-50,50),math.random(-50,50))
Part.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,z3)
end
Part.Parent=nil
end),prt,msh,wld)
end
 
function MagicBlock3(brickcolor,cframe,Parent,x1,y1,z1,x3,y3,z3,delay)
local prt=part(3,workspace,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=false
prt.CFrame=cframe
msh=mesh("BlockMesh",prt,"","",vt(0,0,0),vt(x1,y1,z1))
local wld=weld(prt,prt,Parent,euler(0,0,0)*cf(0,0,0))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh,Weld) 
for i=0,1,delay do
swait()
Weld.C0=euler(i*20,0,0)
--Part.CFrame=Part.CFrame*euler(math.random(-50,50),math.random(-50,50),math.random(-50,50))
Part.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,z3)
end
Part.Parent=nil
end),prt,msh,wld)
end
 
function MagicCircle2(brickcolor,cframe,x1,y1,z1,x3,y3,z3,delay)
local prt=part(3,workspace,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.CFrame=cframe
local msh=mesh("CylinderMesh",prt,"","",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,2)
coroutine.resume(coroutine.create(function(Part,Mesh) 
for i=0,1,delay do
swait()
Part.CFrame=Part.CFrame
Mesh.Scale=Mesh.Scale+vt(x3,y3,z3)
local prt2=part(3,workspace,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt2.Anchored=true
prt2.CFrame=cframe*euler(math.random(-50,50),math.random(-50,50),math.random(-50,50))
local msh2=mesh("SpecialMesh",prt2,"Sphere","",vt(0,0,0),vt(0.5,0.5,0.5))
game:GetService("Debris"):AddItem(prt2,2)
coroutine.resume(coroutine.create(function(Part,Mesh) 
for i=0,1,0.1 do
swait()
Part.CFrame=Part.CFrame*cf(0,0.5,0)
end
Part.Parent=nil
end),prt2,msh2)
end
for i=0,1,delay*2 do
swait()
Part.CFrame=Part.CFrame
Mesh.Scale=vt((x1+x3)-(x1+x3)*i,(y1+y3)-(y1+y3)*i,(z1+z3)-(z1+z3)*i)
end
Part.Parent=nil
end),prt,msh)
end
 
function MagicCircle(brickcolor,cframe,x1,y1,z1,x3,y3,z3,delay)
local prt=part(3,workspace,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.CFrame=cframe
local msh=mesh("SpecialMesh",prt,"Sphere","",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,2)
coroutine.resume(coroutine.create(function(Part,Mesh) 
for i=0,1,delay do
swait()
Part.CFrame=Part.CFrame
Part.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,z3)
end
Part.Parent=nil
end),prt,msh)
end
 
function BreakEffect(brickcolor,cframe,x1,y1,z1)
local prt=part(3,workspace,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.CFrame=cframe*euler(math.random(-50,50),math.random(-50,50),math.random(-50,50))
local msh=mesh("SpecialMesh",prt,"Sphere","",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,2)
coroutine.resume(coroutine.create(function(Part,CF,Numbb,randnumb) 
CF=Part.CFrame
Numbb=0
randnumb=math.random()/10
rand1=math.random()/10
for i=0,1,rand1 do
swait()
CF=CF*cf(0,math.random()/2,0)
--Part.CFrame=Part.CFrame*euler(0.5,0,0)*cf(0,1,0)
Part.CFrame=CF*euler(Numbb,0,0)
Part.Transparency=i
Numbb=Numbb+randnumb
end
Part.Parent=nil
end),prt,CF,Numbb,randnumb)
end
 
function MagicWaveThing(brickcolor,cframe,x1,y1,z1,x3,y3,z3,delay)
local prt=part(3,workspace,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.CFrame=cframe
msh=mesh("SpecialMesh",prt,"FileMesh","http://www.roblox.com/asset/?id=1051557",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh) 
for i=0,1,delay do
swait()
Part.CFrame=Part.CFrame*euler(0,0.7,0)
Part.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,z3)
end
Part.Parent=nil
end),prt,msh)
end
 
function WaveEffect(brickcolor,cframe,x1,y1,z1,x3,y3,z3,delay)
local prt=part(3,workspace,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.CFrame=cframe
msh=mesh("SpecialMesh",prt,"FileMesh","http://www.roblox.com/asset/?id=20329976",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,2)
coroutine.resume(coroutine.create(function(Part,Mesh) 
for i=0,1,delay do
swait()
Part.CFrame=Part.CFrame*cf(0,y3/2,0)
Part.Transparency=i
Mesh.Scale=Mesh.Scale+vt(x3,y3,z3)
end
Part.Parent=nil
end),prt,msh)
end
 
function StravEffect(brickcolor,cframe,x,y,z,x1,y1,z1,delay)
local prt=part(3,workspace,0,0,brickcolor,"Effect",vt(0.5,0.5,0.5))
prt.Anchored=true
prt.CFrame=cframe*cf(x,y,z)
msh=mesh("SpecialMesh",prt,"FileMesh","rbxassetid://168892363",vt(0,0,0),vt(x1,y1,z1))
game:GetService("Debris"):AddItem(prt,5)
coroutine.resume(coroutine.create(function(Part,Mesh,ex,why,zee) 
local num=math.random()
local num2=math.random(-3,2)+math.random()
local numm=0
for i=0,1,delay*2 do
swait()
Part.CFrame=cframe*euler(0,numm*num*10,0)*cf(ex,why,zee)*cf(-i*10,num2,0)
Part.Transparency=i
numm=numm+0.01
end
Part.Parent=nil
Mesh.Parent=nil
end),prt,msh,x,y,z)
end
		
		
	




New = function(Object, Parent, Name, Data)
	local Object = Instance.new(Object)
	for Index, Value in pairs(Data or {}) do
		Object[Index] = Value
	end
	Object.Parent = Parent
	Object.Name = Name
	return Object
end



function clerp(a,b,t)
local qa = {QuaternionFromCFrame(a)}
local qb = {QuaternionFromCFrame(b)}
local ax, ay, az = a.x, a.y, a.z
local bx, by, bz = b.x, b.y, b.z
local _t = 1-t
return QuaternionToCFrame(_t*ax + t*bx, _t*ay + t*by, _t*az + t*bz,QuaternionSlerp(qa, qb, t))
end
 
function QuaternionFromCFrame(cf)
local mx, my, mz, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cf:components()
local trace = m00 + m11 + m22
if trace > 0 then
local s = math.sqrt(1 + trace)
local recip = 0.5/s
return (m21-m12)*recip, (m02-m20)*recip, (m10-m01)*recip, s*0.5
else
local i = 0
if m11 > m00 then
i = 1
end
if m22 > (i == 0 and m00 or m11) then
i = 2
end
if i == 0 then
local s = math.sqrt(m00-m11-m22+1)
local recip = 0.5/s
return 0.5*s, (m10+m01)*recip, (m20+m02)*recip, (m21-m12)*recip
elseif i == 1 then
local s = math.sqrt(m11-m22-m00+1)
local recip = 0.5/s
return (m01+m10)*recip, 0.5*s, (m21+m12)*recip, (m02-m20)*recip
elseif i == 2 then
local s = math.sqrt(m22-m00-m11+1)
local recip = 0.5/s return (m02+m20)*recip, (m12+m21)*recip, 0.5*s, (m10-m01)*recip
end
end
end



function QuaternionToCFrame(px, py, pz, x, y, z, w)
local xs, ys, zs = x + x, y + y, z + z
local wx, wy, wz = w*xs, w*ys, w*zs
local xx = x*xs
local xy = x*ys
local xz = x*zs
local yy = y*ys
local yz = y*zs
local zz = z*zs
return CFrame.new(px, py, pz,1-(yy+zz), xy - wz, xz + wy,xy + wz, 1-(xx+zz), yz - wx, xz - wy, yz + wx, 1-(xx+yy))
end
function QuaternionSlerp(a, b, t)
local cosTheta = a[1]*b[1] + a[2]*b[2] + a[3]*b[3] + a[4]*b[4]
local startInterp, finishInterp;
if cosTheta >= 0.0001 then
if (1 - cosTheta) > 0.0001 then
local theta = math.acos(cosTheta)
local invSinTheta = 1/math.sin(theta)
startInterp = math.sin((1-t)*theta)*invSinTheta
finishInterp = math.sin(t*theta)*invSinTheta  
else
startInterp = 1-t
finishInterp = t
end
else
if (1+cosTheta) > 0.0001 then
local theta = math.acos(-cosTheta)
local invSinTheta = 1/math.sin(theta)
startInterp = math.sin((t-1)*theta)*invSinTheta
finishInterp = math.sin(t*theta)*invSinTheta
else
startInterp = t-1
finishInterp = t
end
end
return a[1]*startInterp + b[1]*finishInterp, a[2]*startInterp + b[2]*finishInterp, a[3]*startInterp + b[3]*finishInterp, a[4]*startInterp + b[4]*finishInterp
end
 
function weld5(part0, part1, c0, c1)
    weeld=Instance.new("Weld", part0)
    weeld.Part0=part0
    weeld.Part1=part1
    weeld.C0=c0
    weeld.C1=c1
    return weeld
end
 
--Example: Torso.Weld.C0 = clerp(Torso.Weld.C0, CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), 0.4)
 
function rayCast(Pos, Dir, Max, Ignore)  -- Origin Position , Direction, MaxDistance , IgnoreDescendants
return game:service("Workspace"):FindPartOnRay(Ray.new(Pos, Dir.unit * (Max or 999.999)), Ignore)
end
 
 
 
 
 
 
 
 
 
-- Damage func
function Dmgfunc(player,mindamage,maxdamage,waait)
    
dodamage = coroutine.wrap(function()
    
if player ~= Character and player:FindFirstChild("IsHit") == nil then
    
Max = mindamage + math.random(-mindamage,maxdamage)

player.Humanoid.Health = player.Humanoid.Health - Max


local thiing = Instance.new("ObjectValue",player)
thiing.Name = "IsHit"
deb:AddItem(thiing,waait)

--for nooby ;)
local Damagetext = Instance.new("BillboardGui",player)
Damagetext.Size = UDim2.new(0,100,0,40)
Damagetext.StudsOffset = Vector3.new(0,3,0)
Damagetext.Adornee = player.Head
Damagetext.Name = "TalkingBillBoard"
local Damagelabel = Instance.new("TextLabel",Damagetext)
Damagelabel.BackgroundTransparency = 1
Damagelabel.BorderSizePixel = 0
Damagelabel.Text = ""..Max
Damagelabel.Font = "Bodoni"
Damagelabel.FontSize = "Size24"
Damagelabel.TextStrokeTransparency = 0
Damagelabel.TextColor3 = Color3.new(255,255,255)
Damagelabel.TextStrokeColor3 = Color3.new(0,0,0)
Damagelabel.Size = UDim2.new(1,0,1.5,0)
deb:AddItem(Damagetext,4.5)
for i = 1, 70 do
wait(0.00000000000000000000000001)
Damagelabel.Position = Damagelabel.Position - UDim2.new(0,0,.06,0)
Damagelabel.TextStrokeTransparency = Damagelabel.TextStrokeTransparency +.06
Damagelabel.TextTransparency = Damagelabel.TextTransparency + .04
end
Damagetext:Destroy()
end
end)
dodamage(player,mindamage,maxdamage,waait)
    
end






-- Bullet func
function Bullets(thinggy,size,color,velocity,damage,bounce,collide,rotation)
    swait()
	   local Bullet = Instance.new("Part",Workspace)
	Bullet.Locked = true
	Bullet.Name = "Bullet"
	Bullet.Anchored = bounce
	Bullet.CanCollide = collide
	Bullet.Transparency = 0.24
	Bullet.Reflectance = 0
	Bullet.BottomSurface = 0
	Bullet.TopSurface = 0
	Bullet.Shape = 0
	Bullet.BrickColor = BrickColor.new(color)
	Bullet.Size = Vector3.new(size,size,size)
	Bullet.Material = "Neon"
	Bullet.Orientation = vt(-90,0,0)
	local Bulletthing = Instance.new("SpecialMesh",Bullet)
	Bulletthing.MeshId = "rbxassetid://1245215297"--OriginalKnifeId1245215297
		local Bulletforce = Instance.new("BodyForce")
	Bulletforce.force = Vector3.new(0,Bullet:GetMass()*166.2,0)
	Bulletforce.Parent = Bullet
	Bullet.CFrame = thinggy.CFrame*CFrame.new(0,0,0) + Vector3.new(math.random(-1,1),math.random(0,0.7),math.random(-1,1))
	local bv = Instance.new("BodyVelocity",Bullet)
	bv.maxForce = Vector3.new(math.huge,math.huge,math.huge)
    Bullet.CFrame = CFrame.new(Bullet.Position,mouse.Hit.p+Vector3.new(math.random(-7,7),math.random(-2,2),math.random(-6,6)))
		bv.velocity = Bullet.CFrame.lookVector*velocity
		
		so("http://roblox.com/asset/?id=925629856",Bullet,0.4,1)
	if bounce == false then
	Bullet.Touched:connect(function(hit)
	if (hit.Parent.Parent ~= Character and hit.Parent ~= Character and hit.Name ~= "Bullet" and hit.Name ~= "prt" and Bullet.Anchored == false) then
	    	    local orbexplode = Instance.new("Sound", Bullet)
    orbexplode.Volume = 0.4
    orbexplode.PlayOnRemove = true
    orbexplode.SoundId = "http://roblox.com/asset/?id=929619479"
    orbexplode.Pitch = 1
    orbexplode:Destroy()
    deb:AddItem(orbexplode, 4)
	Bullet.Anchored = true
	local Explode = Instance.new("Explosion") 
	Explode.Position = Bullet.Position
	Explode.Parent = Workspace 
	Explode.BlastPressure = 0
	Explode.BlastRadius = Bullet.Size.X	*3.6
	Explode.Visible = false
	Explode.Hit:connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid")~=nil and hit.Parent:FindFirstChild("IsHit")==nil then
Dmgfunc(hit.Parent,damage,0+damage,.01)
	end
end)
Bullet.Mesh.Scale = Vector3.new(0,0,0)
MagicCircle4(BrickColor.new(color), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 2.2+size*1.4, 2.2+size*1.4, 2.2+size*1.4, 0.02)
MagicCircle4(BrickColor.new("White"), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 4.2, 4.2, 4.2, 0.02)
	end
	end)
	elseif bounce == true then
	Bullet.Touched:connect(function(hit)
	if (hit.Parent:FindFirstChild("Humanoid")~=nil and hit.Parent~= Character) then
	Bullet.Anchored = true
	local Explode = Instance.new("Explosion") 
	Explode.Position = Bullet.Position
	Explode.Parent = Workspace 
	Explode.BlastPressure = 0
	Explode.BlastRadius = Bullet.Size.X	
	Explode.Visible = false
	Explode.Hit:connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid")~=nil and hit.Parent:FindFirstChild("IsHit")==nil then
	Dmgfunc(hit.Parent,damage,0+damage,.01)
	end
	end)
Bullet.Mesh.Scale = Vector3.new(.1,.1,.1)

MagicCircle4(BrickColor.new(color), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 2.2+size*1.4, 2.2+size*1.4, 2.2+size*1.4, 0.02)
MagicCircle4(BrickColor.new("White"), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 4.2, 4.2, 4.2, 0.02)


	end
	end)
	end
	deb:AddItem(Bullet,5.3)

	return Bullet
end




function Rotbullet(thinggy,size,color,velocity,damage,bounce,collide)
    
    rotation = 0
    rotation2 = 0
    
    
	   local Bullet = Instance.new("Part",Workspace)
	Bullet.Locked = true
	Bullet.Name = "Bullet"
	Bullet.Anchored = bounce
	Bullet.CanCollide = collide
	Bullet.Transparency = 0.24
	Bullet.Reflectance = 0
	Bullet.BottomSurface = 0
	Bullet.TopSurface = 0
	Bullet.Shape = 0
	Bullet.BrickColor = BrickColor.new(color)
	Bullet.Size = Vector3.new(size,size,size)
	Bullet.Material = "Neon"
	local Bulletthing = Instance.new("SpecialMesh",Bullet)
	Bulletthing.MeshType = "Sphere"
		local Bulletforce = Instance.new("BodyForce")
	Bulletforce.force = Vector3.new(0,Bullet:GetMass()*166.2,0)
	Bulletforce.Parent = Bullet
	Bullet.CFrame = thinggy.CFrame*CFrame.new(0,0,0) + Vector3.new(math.random(-1,1),math.random(0,0.7),math.random(-1,1))
	local bv = Instance.new("BodyVelocity",Bullet)
	bv.maxForce = Vector3.new(math.huge,math.huge,math.huge)
    Bullet.CFrame = CFrame.new(Bullet.Position,mouse.Hit.p+Vector3.new(math.random(-7,7),math.random(-2,2),math.random(-6,6)))
		bv.velocity = Bullet.CFrame.lookVector*velocity
		so("http://roblox.com/asset/?id=925629856",Bullet,0.4,1)
	if bounce == false then
	Bullet.Touched:connect(function(hit)
	if (hit.Parent.Parent ~= Character and hit.Parent ~= Character and hit.Name ~= "Bullet" and hit.Name ~= "prt" and Bullet.Anchored == false) then
	    
	    
	    
	    	    local orbexplode = Instance.new("Sound", Bullet)
    orbexplode.Volume = 0.4
    orbexplode.PlayOnRemove = true
    orbexplode.SoundId = "http://roblox.com/asset/?id=929619479"
    orbexplode.Pitch = 1
    orbexplode:Destroy()
    deb:AddItem(orbexplode, 4)
	Bullet.Anchored = true
	
		local Explode = Instance.new("Explosion") 
	Explode.Position = Bullet.Position
	Explode.Parent = Workspace 
	Explode.BlastPressure = 0
	Explode.BlastRadius = Bullet.Size.X	*3.6
	Explode.Visible = false
	
	
	
		Explode.Hit:connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid")~=nil and hit.Parent:FindFirstChild("IsHit")==nil then
Dmgfunc(hit.Parent,damage,0+damage,.01)
	end
end)
Bullet.Mesh.Scale = Vector3.new(0,0,0)
MagicCircle4(BrickColor.new(color), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 2.2+size*1.4, 2.2+size*1.4, 2.2+size*1.4, 0.02)
MagicCircle4(BrickColor.new("White"), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 4.2, 4.2, 4.2, 0.02)

	for i = 1,10 do
wait(0)
rotation2 = rotation2 - 25
	local Bullet2 = Instance.new("Part")
  Bullet2.Parent = workspace
   Bullet2.Material = "Neon"
    Bullet2.BrickColor = BrickColor.new(color)
     Bullet2.CanCollide = false
     Bullet2.Archivable = true
     Bullet2.Anchored = false
     Bullet2.Transparency = 0
     Bullet2.Size = vt(size/1.3,size/1.3,size/1.3)
local B2mesh = Instance.new("SpecialMesh",Bullet2)
     B2mesh.MeshType = "Sphere"
     Bullet2.CFrame = Bullet.CFrame*CFrame.Angles(0,math.rad(rotation2),0)*CFrame.new(0,2,0)
     local bv2 = Instance.new("BodyVelocity",Bullet2)
	bv2.maxForce = Vector3.new(math.huge,math.huge,math.huge)
	    	bv2.velocity = Bullet2.CFrame.lookVector*velocity

	


	
	Bullet2.Touched:connect(function(hit)
	if (hit.Parent.Parent ~= Character and hit.Parent ~= Character and hit.Name ~= "Bullet" and hit.Name ~= "prt" and Bullet.Anchored == true) then
	    Bullet2.Anchored = true
		local Explode2 = Instance.new("Explosion") 
	Explode2.Position = Bullet2.Position
	Explode2.Parent = workspace 
	Explode2.BlastPressure = 0
	Explode2.BlastRadius = Bullet2.Size.X	*3.6
	Explode2.Visible = false
	
		Explode2.Hit:connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid")~=nil and hit.Parent:FindFirstChild("IsHit")==nil then
Dmgfunc(hit.Parent,damage,0+damage,.01)
	end
end)
	Bullet2.Mesh.Scale = Vector3.new(0,0,0)
MagicCircle4(BrickColor.new(color), Bullet2.CFrame * cf(0, 0, 0), 1, 1, 1, 2.2+size/1.4, 2.2+size/1.4, 2.2+size/1.4, 0.02)
MagicCircle4(BrickColor.new("White"), Bullet2.CFrame * cf(0, 0, 0), 1, 1, 1, 4.2, 4.2, 4.2, 0.02)
end
end)
	

end
end
end)

	elseif bounce == true then
	Bullet.Touched:connect(function(hit)
	if (hit.Parent:FindFirstChild("Humanoid")~=nil and hit.Parent~= Character) then
	Bullet.Anchored = true
	local Explode = Instance.new("Explosion") 
	Explode.Position = Bullet.Position
	Explode.Parent = Workspace 
	Explode.BlastPressure = 0
	Explode.BlastRadius = Bullet.Size.X	
	Explode.Visible = false
	Explode.Hit:connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid")~=nil and hit.Parent:FindFirstChild("IsHit")==nil then
	Dmgfunc(hit.Parent,damage,0+damage,.01)
	end
	end)
Bullet.Mesh.Scale = Vector3.new(.1,.1,.1)

MagicCircle4(BrickColor.new(color), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 2.2+size*1.4, 2.2+size*1.4, 2.2+size*1.4, 0.02)
MagicCircle4(BrickColor.new("White"), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 4.2, 4.2, 4.2, 0.02)


	end
	end)
	end
	deb:AddItem(Bullet,3.3)
deb:AddItem(Bullet2,3.3)

	return Bullet
end





function Bullets2(size,color,velocity,damage,bounce,collide)
	local Bullet = Instance.new("Part",workspace)
	Bullet.Locked = true
	Bullet.Name = "Bullet"
	Bullet.Anchored = bounce
	Bullet.CanCollide = collide
	Bullet.Transparency = 0.24
	Bullet.Reflectance = 0
	Bullet.BottomSurface = 0
	Bullet.TopSurface = 0
	Bullet.Shape = 0
	Bullet.BrickColor = BrickColor.new(color)
	Bullet.Size = Vector3.new(size,size,size)
	Bullet.Material = "Neon"
	local Bulletthing = Instance.new("SpecialMesh",Bullet)
	Bulletthing.MeshType = "Sphere"
	Bullet.CFrame = handee.CFrame*CFrame.new(0,0,0) + Vector3.new(math.random(-180,180),math.random(-1.6,6.6),math.random(-180,180))
	local bv = Instance.new("BodyVelocity",Bullet)
	bv.maxForce = Vector3.new(99999,99999,99999)
    Bullet.CFrame = CFrame.new(Bullet.Position,mouse.Hit.p)
		bv.velocity = Bullet.CFrame.lookVector*velocity
		so("http://roblox.com/asset/?id=200633327",Bullet,1,1)
			spawn = coroutine.wrap(function()
	Bullet.Transparency = 0
	Bullet.Mesh.Scale = Vector3.new(3.5,3.5,3.5)
	wait()
	Bullet.Transparency = .25
	Bullet.Mesh.Scale = Vector3.new(2.5,2.5,2.5)
	wait()
	Bullet.Transparency = .5
	Bullet.Mesh.Scale = Vector3.new(1.5,1.5,1.5)
	wait()
	Bullet.Transparency = 0
	Bullet.Mesh.Scale = Vector3.new(1,1,1)
end)
	if bounce == false then
	Bullet.Touched:connect(function(hit)
	if (hit.Parent.Parent ~= Character and hit.Parent ~= Character and hit.Name ~= "Bullet" and Bullet.Anchored == false) then
	Bullet.Anchored = true
	local Explode = Instance.new("Explosion") 
	Explode.Position = Bullet.Position
	Explode.Parent = Workspace 
	Explode.BlastPressure = 0
	Explode.BlastRadius = Bullet.Size.X	
	Explode.Visible = false
	Explode.Hit:connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid")~=nil and hit.Parent:FindFirstChild("IsHit")==nil then
Dmgfunc(hit.Parent,damage,0.7,0)
	end
end)
Bullet.Mesh.Scale = Vector3.new(.1,.1,.1)
MagicBlock(BrickColor.new(color), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 1.7, 1.7, 1.7, 0.04)
MagicBlock(BrickColor.new(color), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 2.2, 2.2, 2.2, 0.04)
for i = 0,2.3,0.1 do
    swait()
	Bullet.Transparency = Bullet.Transparency + 0.02
	Bullet.Mesh.Scale = Bullet.Mesh.Scale + Vector3.new(.3,.3,.3)
	end
	Bullet:Destroy()
	end
	end)
	elseif bounce == true then
	Bullet.Touched:connect(function(hit)
	if (hit.Parent:FindFirstChild("Humanoid")~=nil and hit.Parent~= Character) then
	Bullet.Anchored = true
	local Explode = Instance.new("Explosion") 
	Explode.Position = Bullet.Position
	Explode.Parent = workspace 
	Explode.BlastPressure = 0
	Explode.BlastRadius = Bullet.Size.X	
	Explode.Visible = false
	Explode.Hit:connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid")~=nil and hit.Parent:FindFirstChild("IsHit")==nil then
	Dmgfunc(hit.Parent,damage,0.7,0)
	end
	end)
Bullet.Mesh.Scale = Vector3.new(.1,.1,.1)
MagicBlock(BrickColor.new(color), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 1.7, 1.7, 1.7, 0.04)
MagicBlock(BrickColor.new(color), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 2.2, 2.2, 2.2, 0.04)
for i = 0,2.3,0.1 do
    swait()
	Bullet.Transparency = Bullet.Transparency + 0.02
	Bullet.Mesh.Scale = Bullet.Mesh.Scale + Vector3.new(.3,.3,.3)
	MagicSphere(BrickColor.new(color), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 6.2, 6.2, 6.2, 0.04)
	MagicSphere(BrickColor.new(color), Bullet.CFrame * cf(0, 0, 0), 1, 1, 1, 8.2, 8.2, 8.2, 0.04)
	end
	Bullet:Destroy()
	end
	end)
end
	spawn()
	deb:AddItem(Bullet,10)
	return Bullet
end


 
 
 
 
 
 
 local shooting = false
 
 
-- Shoot func
function shoot()
    so("http://roblox.com/asset/?id=925333540",Torso,1.1,1)
    MagicBlock4(BrickColor.new("Lime green"), RootPart.CFrame * cf(0, 0, 0), 1, 1, 1, 16.2, 16.2, 16.2, 0.04)

    MagicCircle4(BrickColor.new("Dark indigo"), RootPart.CFrame * cf(0, 0, 0), 1, 1, 1, 19.2, 19.2, 19.2, 0.03)
    
    MagicWave4(BrickColor.new("Dark indigo"), cf(RootPart.Position) * cf(0, -1, 0) * euler(0, math.random(-50, 50), 0), 1, 1, 1, 0.5, 0.3, 0.5, 0.04)
    
	MagicWave4(BrickColor.new("Lime green"), RootPart.CFrame * cf(0, -1, 0) * euler(0, math.random(-50, 50), 0), 1, 1, 1, 1, 0.5, 1, 0.05)
    attack = true
    local thing = Instance.new("BodyGyro",RootPart)
	thing.D = 350
	thing.P = 6000
	thing.MaxTorque = vt(100000,math.huge,0)
	thing.CFrame = CFrame.new(RootPart.Position,mouse.Hit.p)
    for i = 0,2,0.16 do
    	swait()
		Torso.Weld.C0 = clerp(Torso.Weld.C0, CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)), 0.2)
		Torso.Neck.C0 = clerp(Torso.Neck.C0,necko *angles(math.rad(0),math.rad(0),math.rad(-80)),.2)
		RW.C0 = clerp(RW.C0, CFrame.new(1.5, 0.5, 0) * angles(math.rad(90), math.rad(0), math.rad(90)),.2)
		LW.C0 = clerp(LW.C0, CFrame.new(-1.5, 0.5, 0) * angles(math.rad(-20), math.rad(0), math.rad(-30)),.2)
		LeftLeg.Weld.C0 = clerp(LeftLeg.Weld.C0, CFrame.new(-0.73, -1.0, 0) * CFrame.Angles(math.rad(-25), math.rad(-66), math.rad(-25)), 0.1)
		RightLeg.Weld.C0 = clerp(RightLeg.Weld.C0, CFrame.new(0.6, -1.0, 0)  * CFrame.Angles(math.rad(0), math.rad(-83), math.rad(0)), 0.1)
	end
	shooting = true

	while shooting == true do
	    swait(2.5)
	    thing.CFrame = CFrame.new(RootPart.Position,mouse.Hit.p)
	    Torso.Velocity =  RootPart.CFrame.lookVector * -13
	    if math.random(1,2) == 1 then
	    	Bullets(handee,math.random(1,2),g,math.random(220,520),5.5,false,false)
	    	MagicBlock(BrickColor.new("Lime green"), RightArm.CFrame * cf(math.random(-100, 100) / 100, -math.random(0, 700) / 100, math.random(-100, 100) / 100), math.random(30, 80) / 100, math.random(30, 80) / 100, math.random(30, 80) / 100, 0.5, 0.5, 0.5, 0.05)
		else
	    	Bullets(handee,math.random(1,2),r,math.random(200,520),6.3,false,false)
	    	MagicBlock(BrickColor.new("Dark indigo"), RightArm.CFrame * cf(math.random(-100, 100) / 100, -math.random(0, 700) / 100, math.random(-100, 100) / 100), math.random(30, 80) / 100, math.random(30, 80) / 100, math.random(30, 80) / 100, 0.5, 0.5, 0.5, 0.05)
	end
end

attack = false
thing:Destroy()
    end




local cardmax = 0
local cardpos = 3
local carding = false
function SCB()
    print('Spell Card Barrage -> Debuff - 3.6 WalkSpeed.')
    Humanoid.WalkSpeed = Humanoid.WalkSpeed-3.6
    so("http://roblox.com/asset/?id=925333540",Torso,1.1,1)
    MagicBlock4(BrickColor.new("Lime green"), RootPart.CFrame * cf(0, 0, 0), 1, 1, 1, 16.2, 16.2, 16.2, 0.04)

    MagicCircle4(BrickColor.new("Dark indigo"), RootPart.CFrame * cf(0, 0, 0), 1, 1, 1, 19.2, 19.2, 19.2, 0.03)
    
    MagicWave4(BrickColor.new("Dark indigo"), cf(RootPart.Position) * cf(0, -1, 0) * euler(0, math.random(-50, 50), 0), 1, 1, 1, 0.5, 0.3, 0.5, 0.04)
    
 	MagicWave4(BrickColor.new("Lime green"), RootPart.CFrame * cf(0, -1, 0) * euler(0, math.random(-50, 50), 0), 1, 1, 1, 1, 0.5, 1, 0.05)
    attack = true

local Card = Instance.new('Part',Character)
Card.Transparency = 0.5
Card.Color = Color3.fromRGB(0,255,0)
Card.Size = Vector3.new(0.65,0.2,1.2)
Card.Material = "Neon"
Card.CFrame = handee.CFrame + Vector3.new(0,3,0)
CardMesh = Instance.new("BlockMesh",Card)
local gyrothing = Instance.new("BodyGyro",Card)
	gyrothing.D = 100
	gyrothing.P = 2000
	gyrothing.MaxTorque = Vector3.new(4000000,4000000,4000000)
	gyrothing.CFrame = CFrame.new(RootPart.Position,mouse.Hit.p)
	local position = Instance.new("BodyPosition",Card)
	position.D = 2350
	position.maxForce = Vector3.new(math.huge,math.huge,math.huge)
cardmax = cardmax+1
cardpos = cardpos+1

      for i = 0,2,0.16 do
        swait()
        gyrothing.CFrame = CFrame.new(RootPart.Position,mouse.Hit.p)
        position.Position = Torso.Position + Vector3.new(10,3,0)
Torso.Weld.C0 = clerp(Torso.Weld.C0, CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)), 0.2)
Torso.Neck.C0 = clerp(Torso.Neck.C0,necko *angles(math.rad(0),math.rad(0),math.rad(-80)),.2)
RW.C0 = clerp(RW.C0, CFrame.new(1.5, 0.5, 0) * angles(math.rad(90), math.rad(0), math.rad(90)),.2)
LW.C0 = clerp(LW.C0, CFrame.new(-1.5, 0.5, 0) * angles(math.rad(-20), math.rad(0), math.rad(-30)),.2)
LeftLeg.Weld.C0 = clerp(LeftLeg.Weld.C0, CFrame.new(-0.73, -1.0, 0) * CFrame.Angles(math.rad(-25), math.rad(-66), math.rad(-25)), 0.1)
RightLeg.Weld.C0 = clerp(RightLeg.Weld.C0, CFrame.new(0.6, -1.0, 0)  * CFrame.Angles(math.rad(0), math.rad(-83), math.rad(0)), 0.1)
end
  
  attack = false

for i = 1,65 do
    position.Position = Torso.Position + Vector3.new(10-cardpos,cardpos,0)
    --position.Position = Torso.Position + Vector3.new(0,cardpos,0)
   swait(2.5)
   gyrothing.CFrame = CFrame.new(RootPart.Position,mouse.Hit.p)
        if math.random(1,2) == 1 then
    Bullets(Card,math.random(0.9,1.1),g,math.random(320,420),6.1,false,false)
else
    Bullets(Card,math.random(0.9,1.1),r,math.random(320,420),8.2,false,false)
end
end



Card:Destroy()
cardmax = cardmax-1
--Humanoid.WalkSpeed = Humanoid.WalkSpeed+3.6
cardpos = cardpos-1
if Humanoid.WalkSpeed == 32 then
    print('WalkSpeed Regained.')
    end
    end




function rotball()
    so("http://roblox.com/asset/?id=925333540",Torso,1.1,1)
    MagicBlock4(BrickColor.new("Lime green"), RootPart.CFrame * cf(0, 0, 0), 1, 1, 1, 16.2, 16.2, 16.2, 0.04)
    MagicCircle4(BrickColor.new("Dark indigo"), RootPart.CFrame * cf(0, 0, 0), 1, 1, 1, 19.2, 19.2, 19.2, 0.03)
    MagicWave4(BrickColor.new("Dark indigo"), cf(RootPart.Position) * cf(0, -1, 0) * euler(0, math.random(-50, 50), 0), 1, 1, 1, 0.5, 0.3, 0.5, 0.04)
 	MagicWave4(BrickColor.new("Lime green"), RootPart.CFrame * cf(0, -1, 0) * euler(0, math.random(-50, 50), 0), 1, 1, 1, 1, 0.5, 1, 0.05)
    attack = true

    local thing = Instance.new("BodyGyro",RootPart)
	thing.D = 350
	thing.P = 6000
	thing.MaxTorque = vt(100000,math.huge,0)
	thing.CFrame = CFrame.new(RootPart.Position,mouse.Hit.p)

    for i = 0,2,0.16 do
        swait()
        thing.CFrame = CFrame.new(RootPart.Position,mouse.Hit.p)
		Torso.Weld.C0 = clerp(Torso.Weld.C0, CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)), 0.2)
		Torso.Neck.C0 = clerp(Torso.Neck.C0,necko *angles(math.rad(0),math.rad(0),math.rad(-80)),.2)
		RW.C0 = clerp(RW.C0, CFrame.new(1.5, 0.5, 0) * angles(math.rad(90), math.rad(0), math.rad(90)),.2)
		LW.C0 = clerp(LW.C0, CFrame.new(-1.5, 0.5, 0) * angles(math.rad(-20), math.rad(0), math.rad(-30)),.2)
		LeftLeg.Weld.C0 = clerp(LeftLeg.Weld.C0, CFrame.new(-0.73, -1.0, 0) * CFrame.Angles(math.rad(-25), math.rad(-66), math.rad(-25)), 0.1)
		RightLeg.Weld.C0 = clerp(RightLeg.Weld.C0, CFrame.new(0.6, -1.0, 0)  * CFrame.Angles(math.rad(0), math.rad(-83), math.rad(0)), 0.1)
	end

  
	local beam = Instance.new("Part", workspace)
	beam.BrickColor = BrickColor.new(g)
	beam.FormFactor = "Custom"
	beam.Material = "Neon"
	beam.Transparency = 0.25
	beam.Anchored = true
	beam.Locked = false
	beam.CanCollide = false

	local Z = Instance.new("SpecialMesh",beam)
	Z.MeshType = "Sphere"

	local ray = Ray.new(handee.CFrame.p, (mouse.Hit.p - handee.CFrame.p).unit * 700)
	local part, position = workspace:FindPartOnRay(ray, player.Character, false, true)
	local distance = (handee.CFrame.p - position).magnitude

	beam.CFrame = CFrame.new(handee.CFrame.p, position) * CFrame.new(0, 0, -distance / 2)
	beam.Size = Vector3.new(1, 1, distance)
	beam.Touched:Connect(function(obj)
		local Explode = Instance.new("Explosion") 
		Explode.Position = beam.Position
		Explode.Parent = workspace
		Explode.BlastPressure = 0
		Explode.BlastRadius = beam.Size.X
		Explode.Visible = false
		Explode.Hit:connect(function(hit)
			if hit.Parent.ClassName == "Model" and hit.Parent:FindFirstChild("IsHit")==nil then
				Dmgfunc(hit.Parent,hit.Parent.Humanoid.MaxHealth/2,hit.Parent.Humanoid.MaxHealth,0)
			end
		end)
	end)



	for i = 1,6,0.1 do
	    swait()
		thing.CFrame = CFrame.new(RootPart.Position,mouse.Hit.p)
		beam.CFrame = CFrame.new((beam.CFrame.p + position) / 2, beam.CFrame.p) * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
		beam.Size = Vector3.new(1, 1, distance)
		MagicBlock4(BrickColor.new("Lime green"), beam.CFrame * cf(0, 0, 0), 1, 1, 1, 16.2, 16.2, 16.2, 0.04)
		MagicShockTrailAlt(BrickColor.new("Dark indigo"),beam.CFrame*CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360))),10,10,5,-0.05,-0.05,25,0.005,math.random(1,2))
		if math.random(1,2) == 1 then
			beam.BrickColor = BrickColor.new(g)
		else
			beam.BrickColor = BrickColor.new(r)
		end
	end
	attack = false

	thing:Destroy()
	beam:Destroy()
end



function Ldash()
    
    

evadecooldown = true
attack = true
so("http://www.roblox.com/asset/?id=707957812", Torso, 2.5, 1)
 
 
 
 


 --+173.8*i
for i = 0,2,0.064 do
swait()
RootPart.Velocity = RootPart.CFrame.rightVector * -54
Torso.Weld.C0 = clerp(Torso.Weld.C0, CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(32)), 0.2)
Torso.Neck.C0 = clerp(Torso.Neck.C0,necko *angles(math.rad(0),math.rad(-9),math.rad(-14)),.2)
RW.C0 = clerp(RW.C0, CFrame.new(1.5, 0.5, 0) * angles(math.rad(77), math.rad(0), math.rad(70)),.2)
LW.C0 = clerp(LW.C0, CFrame.new(-1.0, 0.5, -0.55) * angles(math.rad(30), math.rad(0), math.rad(70)),.2)
LeftLeg.Weld.C0 = clerp(LeftLeg.Weld.C0, CFrame.new(-0.5, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(12)), 0.2)
RightLeg.Weld.C0 = clerp(RightLeg.Weld.C0, CFrame.new(0.5, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(8)), 0.2)
end

attack = false
wait(0.13)
evadecooldown = false
 
 
end





function Rdash()
    
    

evadecooldown = true
attack = true
so("http://www.roblox.com/asset/?id=707957812", Torso, 2.5, 1)
 
 
 
 
 

 --+173.8*i
for i = 0,2,0.064 do
swait()
RootPart.Velocity = RootPart.CFrame.rightVector * 54
Torso.Weld.C0 = clerp(Torso.Weld.C0, CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-32)), 0.2)
Torso.Neck.C0 = clerp(Torso.Neck.C0,necko *angles(math.rad(0),math.rad(9),math.rad(14)),.2)
RW.C0 = clerp(RW.C0, CFrame.new(1.0, 0.5, -0.55) * angles(math.rad(30), math.rad(0), math.rad(-70)),.2)
LW.C0 = clerp(LW.C0, CFrame.new(-1.5, 0.5, 0) * angles(math.rad(77), math.rad(0), math.rad(-70)),.2)
LeftLeg.Weld.C0 = clerp(LeftLeg.Weld.C0, CFrame.new(-0.5, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-8)), 0.2)
RightLeg.Weld.C0 = clerp(RightLeg.Weld.C0, CFrame.new(0.5, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-12)), 0.2)
end
attack = false
wait(0.13)
evadecooldown = false
end

---------------------------------------------------------------------------------------------------------------------------
--[[
Timestopper Watch by VolcanoReg
Beside Texture
Everything done by VolcanoReg himself
Feel free to use the script
Be Responsible

]]

local plr = "VolcanoReg"
local player = game.Players[plr]

local anima = Instance.new("Animation")
anima.Parent = script
anima.AnimationId = "rbxassetid://7326208423"

local Animator = player.Character.Humanoid.Animator

timestopper = player
timestoptime = 4
_G.timestoptime = timestoptime

local AHB = Instance.new("BindableEvent")
AHB.Name = "AHeartbeat"
AHB.Parent = script

local HB = game:GetService("RunService").Heartbeat

--Visual Event
wait(0.25)
local tween = game:GetService("TweenService")
tween_prop = {}

info_in = TweenInfo.new(1,Enum.EasingStyle.Elastic,Enum.EasingDirection.In)
info_out = TweenInfo.new(1,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out)

function sound_visual(parent,sound_id,volume,longtime,distortion)
	local a = Instance.new("Sound")
    --overriding sound function to play at player's character
	a.Parent=player.Character.Head
	a.SoundId=tostring("rbxassetid://"..sound_id)
	a.Volume=volume
	a.Name="Sakuya_Timestop"
	
	local b = Instance.new("DistortionSoundEffect")
	b.Name="BASS"
	b.Level=distortion
	b.Parent=a
	a:Play()
	game.Debris:AddItem(a,longtime)
end

local animator = Animator
local anim_play = animator:LoadAnimation(anima) -- need object

function ticking()
    sound_visual(workspace,850256806,5,0)
end

visual_event = function()
	-- Cannot Be used in SB
	--local colorcorr = Instance.new("ColorCorrectionEffect")
	--colorcorr.Enabled = true
	--colorcorr.Parent = game.Lighting
	
	anim_play:Play()
	wait(0.85)
	wait(1)
	
	coroutine.resume(coroutine.create(function()
		local tool_p = Handles.Position
		local part = Instance.new("Part")
		part.Shape = "Ball"
		part.Name = "TSField"
		part.Parent = game.Workspace
		part.CanCollide = false
		part.CanTouch = true
		part.Massless = true
		part.Position = Vector3.new(tool_p.X,tool_p.Y,tool_p.Z)
		part.Material = Enum.Material.Neon
		local info_p = TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
		local Tween_Prop = {}
		Tween_Prop.Size = Vector3.new(100,100,100)
		Tween_Prop.Transparency = 1
		local info_pl = tween:Create(part,info_p,Tween_Prop)
		wait(0.1)
		info_pl:Play()
		game.Debris:AddItem(part,2)
	end))
	
	--sound_visual(workspace,743521691,2,4,0.5)
	--sound_visual(workspace,743521656,2,4,0.5)
	
	wait(0.1)
	
	
	--colorcorr.Brightness = 1
	
	tween_prop.Brightness = 0
	tween_prop.Contrast = 1
	tween_prop.Saturation = -1
	tween_prop.TintColor = Color3.fromRGB(255,50,50)
	--local a = tween:Create(colorcorr,info_out,tween_prop)
	--a:Play()
	
	ticking()
	
	wait(_G.timestoptime)
	
	game.Debris:AddItem(colorcorr,2)
	
	--sound_visual(workspace,743521691,2,2)
	wait(0.2)
	
	tween_prop.Contrast = 0
	tween_prop.Saturation = 0
	tween_prop.TintColor = Color3.fromRGB(255,255,255)
	--local b = tween:Create(colorcorr,info_in,tween_prop)
	--b:Play()
end

--Timestop Script
--[[
	When Tool is clicked, upper script will fire a bindable event to this script, then
	this script will anchored part and paused music, anchored part will be stored on 
	Anchored as ObjectValue, Same with paused music(At The Moment, will be using Table.Insert()).
	
	After sometimes, the anchored part will be unanchored and the paused sound will be
	played again.
]]
--local event = script.Parent.timestop --Bindable Event not needed
Anchored = {}
Soundstopped = {}
TsState =false

for _,v in next,player.Character:GetDescendants() do
    if v.ClassName == "Part" then
        local tags = Instance.new("BoolValue")
        tags.Name = 'owner'
        tags.Parent = v
        tags.Value = true
    end
end

function cframed(part)
	local cf = part.CFrame
	repeat
		part.CFrame = cf
		HB:Wait()
	until TsState == false
end

function RemoteEventOff(remote)
	print(remote.Name)
	repeat
		wait(1/2048)
		remote.OnServerEvent:Connect(function(plr,msg) plr.Character.Humanoid:Destroy() end)
	until TsState == false
	remote.OnServerEvent:Connect(function()end)
end

timestop_event = function()
	TsState = true
	for i,v in next,workspace:GetDescendants() do
		if v.ClassName == "Model" and v.Name ~= timestopper.Name then
			for i,part in pairs(v:GetDescendants()) do
				if part.ClassName == "Part" and part:FindFirstChild("owner") == nil then
					if part.Anchored == false then
						part.Anchored = true
						--anchor(part)
						table.insert(Anchored,#Anchored+1,part)
					end
				end
			end
		elseif v.ClassName == "Sound" then
			if v.IsPlaying == true and v.Name ~= ("Sakuya_Timestop" or "Sakuya_Timestop_Ticking") then
				v:Pause()
				--paused(v)
				table.insert(Soundstopped,#Soundstopped+1,v)
			end
		elseif v.ClassName == "Part" and v.Name ~= ("TSField") and v:FindFirstChild("owner") == nil and v.Name ~= "Base" then
			if v.Anchored == false then
				v.Anchored = true
				--anchor(v)
				table.insert(Anchored,#Anchored+1,v)
			end
			coroutine.resume(coroutine.create(function() pcall(function() cframed(v) end) end))
		end
	end
	--[[for i,remote in pairs(game:GetDescendants()) do
		if remote.ClassName == "RemoteEvent" then
			coroutine.resume(coroutine.create(function() pcall(function() RemoteEventOff(remote) end) end))
		end
	end]]
	workspace.ChildAdded:Connect(function(obj)
		if obj.ClassName == "Part" then
			if obj.Anchored == false then
				obj.Anchored = true
				--anchor(obj)
				table.insert(Anchored,#Anchored+1,obj)
			end
		elseif obj.ClassName == "Sound" then
			if obj.IsPlaying == true and obj.Name ~= "Sakuya_Timestop" then
				obj:Pause()
				--paused(obj)
				table.insert(Soundstopped,#Soundstopped+1,obj)
			end
		end
	end)
	
	wait(_G.timestoptime+1.65)
	TsState = false
	workspace.ChildAdded:Connect(function()end)

	--[[for i,v in pairs(script.Anchored:GetChildren()) do
		v.Value.Anchored = false
	end
	script.Anchored:ClearAllChildren()
	
	for i,v in pairs(script.SoundPaused:GetChildren()) do
		v.Value:Play()
		v:Play()
	end
	script.SoundPaused:ClearAllChildren() ]]--
	for i,v in next,Anchored do
		v.Anchored = false
	end
	Anchored = {}
	
	for i,v in next,Soundstopped do
		v:Resume()
	end
	Soundstopped = {}
end

-- Main Script
cd = false

function Timestop()
	if cd == false then	
		
		coroutine.resume(coroutine.create(function() 
			cd=true
			wait(_G.timestoptime)
			cd=false 
		end))
		
        coroutine.resume(coroutine.create(function() visual_event() end))
		wait(1.85)
        coroutine.resume(coroutine.create(function() timestop_event() end))
	else
	end
end
---------------------------------------------------------------------------------------------------------------------------
local MouseControl
if Player.PlayerGui:FindFirstChild("Mouser") == nil then
	print("MouserNotFound")
	MouseControl = Instance.new("RemoteEvent")
	MouseControl.Name = "MouseControl"
	MouseControl.Parent = Player.PlayerGui
	print(MouseControl)
else
	MouseControl = Player.PlayerGui:WaitForChild("MouseControl",10)
end

--[[mouse.Button1Down:connect(function(key)
if attack == false then
shoot()
end
end)]]
Button1Down = function(key)
    if attack == false then
        shoot()
    end
end
 
 
 
--[[mouse.Button1Up:connect(function(key)
if shooting == true then
shooting = false
end
end)]]
Button1Up = function(key)
    if shooting == true then
        shooting = false
    end
end
 
  
--[[mouse.KeyDown:connect(function(key)
if key == 'e' and attack == false and cardmax <= 5 then
SCB()
end
end)]]
KeyDown = function(key)
    if key == 'e' and attack == false and cardmax <= 5 then
      SCB()
    elseif key == 'f' and attack == false then
        Ldash()
    elseif key == 'g' and attack == false then
        Rdash()
    elseif key == 'r' and attack == false then
        rotball()
    elseif key == 't' and attack == false then
        Timestop()
    end
end
 
MouseControl.OnServerEvent:Connect(function(_,Comm,Keys,MouseEssence)
	--if _.Name ~= Player.Name then return end

	mouse = MouseEssence
	if Comm == "Button1Down" then
		print("Fired:",Comm)
		Button1Down()
	elseif Comm == "Button1Up" then
		print("Fired:",Comm)
		Button1Up()
	elseif Comm == "KeyDown" and Keys ~= nil then
		print("Fired:",Comm)
		KeyDown(Keys)
	elseif Comm == "KeyUp" and Keys ~= nil then
		print("Fired:",Comm)
		--KeyUp(Keys)
	end
end)
 
--[[mouse.KeyDown:connect(function(key)
if key == 'f' and attack == false then
Ldash()
end
end)
 ]]
 
 
--[[mouse.KeyDown:connect(function(key)
if key == 'g' and attack == false then
Rdash()
end
end)
]]
 
--[[mouse.KeyDown:connect(function(key)
if key == 'r' and attack == false then
rotball()
end
end)
 ]]
-------------------------------------------------------------------------------------------------------------------------- 

 local idk = 0
 
 
 
 local f = 0
 game:GetService("RunService"):BindToRenderStep("W0tT", 0, function()


Humanoid.MaxHealth = 250
f = f+1
if f >= 7 then
    MagicBlock4(BrickColor.new("Dark indigo"), LeftArm.CFrame * cf(0, -1, 0), 1, 1, 1, 0.7, 0.7, 0.7, 0.05)
      MagicCircle4(BrickColor.new("Dark indigo"), LeftArm.CFrame * cf(0, -1, 0), 1, 0.1, 1, 6, 0, 6, 0.1)
end

end)

Humanoid.Health = 250
while true do
    swait()
    sine = sine + change
    local torvel=(RootPart.Velocity*Vector3.new(1,0,1)).magnitude
    local velderp=RootPart.Velocity.y
    hitfloor,posfloor=rayCast(RootPart.Position,(CFrame.new(RootPart.Position,RootPart.Position - Vector3.new(0,1,0))).lookVector,4,Character)
    if attack==true or attack==false then
        if attack==false then
            idle=idle+1
        else
            idle=0
        end
        if idle>=500 then
            if attack==false then
            end
        end



        if RootPart.Velocity.y > 1 and hitfloor==nil then
            Anim="Jump"
        
        
        
        
        
        
            if attack==false then
                change = 1
                
                Humanoid.CameraOffset = Vector3.new(0,0,0)
                Torso.Weld.C0 = clerp(Torso.Weld.C0, CFrame.new(0, -1, -.15) * CFrame.Angles(math.rad(-13), math.rad(0), math.rad(0)), 0.1)
                Torso.Neck.C0 = clerp(Torso.Neck.C0,necko *angles(math.rad(-30+2.05*math.cos(sine/5)),math.rad(0),math.rad(0)),.1)
                RW.C0 = clerp(RW.C0, CFrame.new(1.5, 0.5, 0) * angles(math.rad(-30+2.05*math.cos(sine/5)), math.rad(0), math.rad(50-2.05*math.cos(sine/5))), 0.1)
                LW.C0 = clerp(LW.C0, CFrame.new(-1.5, 0.5, 0) * angles(math.rad(-30+2.05*math.cos(sine/5)), math.rad(0), math.rad(-50+2.05*math.cos(sine/5))), 0.1)
        
            end
            if attack==false  then
                LeftLeg.Weld.C0 = clerp(LeftLeg.Weld.C0, CFrame.new(-0.5, -1, 0) * CFrame.Angles(math.rad(-25+3.05*math.cos(sine/5)), math.rad(0), math.rad(0)), 0.1)
                RightLeg.Weld.C0 = clerp(RightLeg.Weld.C0, CFrame.new(0.5, -.47, -0.7) * CFrame.Angles(math.rad(-12+3.05*math.cos(sine/5)), math.rad(-3), math.rad(0)), 0.1)
            end
        elseif RootPart.Velocity.y < -1 and hitfloor==nil then
            Anim="Fall"
            change = 1
        
        
            if attack==false then
                Humanoid.CameraOffset = Vector3.new(0,0,0)
                Torso.Weld.C0 = clerp(Torso.Weld.C0, CFrame.new(0, -1, 0.2) * CFrame.Angles(math.rad(-10), math.rad(0), math.rad(0)), 0.1)
                RW.C0 = clerp(RW.C0, CFrame.new(1.5, 0.5, 0) * angles(math.rad(90), math.rad(20), math.rad(90)), 0.1)
                LW.C0 = clerp(LW.C0, CFrame.new(-1.5, 0.5, 0) * angles(math.rad(90), math.rad(-20), math.rad(-90)), 0.1)
                Torso.Neck.C0 = clerp(Torso.Neck.C0,necko *angles(math.rad(40),math.rad(0),math.rad(0)),.1)

            end
            if attack==false or attack == true  then
                LeftLeg.Weld.C0 = clerp(LeftLeg.Weld.C0, CFrame.new(-0.5, -1, 0) * CFrame.Angles(math.rad(-8), math.rad(3), math.rad(0)), 0.1)
                RightLeg.Weld.C0 = clerp(RightLeg.Weld.C0, CFrame.new(0.5, -.67, -0.4) * CFrame.Angles(math.rad(25), math.rad(0), math.rad(0)), 0.1)
            end

        elseif torvel<1 and hitfloor~=nil then
            Anim="Idle"
            change = 1.73
            if attack==false and equip == false then
                Humanoid.CameraOffset = Vector3.new(0,0,0)
                Torso.Weld.C0 = clerp(Torso.Weld.C0, CFrame.new(0, -1-0.10*math.cos(sine/40), -0) * CFrame.Angles(math.rad(0), math.rad(30), math.rad(0)), 0.1)
                Torso.Neck.C0 = clerp(Torso.Neck.C0,necko *angles(math.rad(0+4*math.sin(sine/40)),math.rad(0),math.rad(-30)),0.1)


                RW.C0 = clerp(RW.C0, CFrame.new(1.5, 0.5+0.07*math.sin(sine/40), 0) * angles(math.rad(-3+2*math.cos(sine/40)), math.rad(0+7*math.cos(sine/40)), math.rad(3+3.2*math.cos(sine/40))),0.1)
                LW.C0 = clerp(LW.C0, CFrame.new(-1.5, 0.5+0.07*math.sin(sine/40), 0) * angles(math.rad(-3+2*math.cos(sine/40)), math.rad(0-7*math.cos(sine/40)), math.rad(-3-3.2*math.cos(sine/40))),0.1)
                LeftLeg.Weld.C0 = clerp(LeftLeg.Weld.C0, CFrame.new(-0.5, -1+0.10*math.cos(sine/40), 0) * CFrame.Angles(math.rad(0), math.rad(2), math.rad(-3)), 0.1)

                RightLeg.Weld.C0 = clerp(RightLeg.Weld.C0, CFrame.new(0.5, -1+0.10*math.cos(sine/40), 0)  * CFrame.Angles(math.rad(0), math.rad(-2), math.rad(3)), 0.1)
            end




        elseif torvel>2 and torvel<4205 and hitfloor~=nil then
            Anim="Walk"
            change = 1 + Character.Humanoid.WalkSpeed/113
            if attack==false and equip == false then
                Humanoid.CameraOffset = Vector3.new(0,0,0)
                Torso.Weld.C0 = clerp(Torso.Weld.C0, CFrame.new(0, -1-0.42*math.cos(sine/2.5), -.8) * angles(math.rad(-23), math.rad(0), math.rad(0)+ RootPart.RotVelocity.Y / 26), .1)
                Torso.Neck.C0 = clerp(Torso.Neck.C0,necko *angles(math.rad(-7+20*math.sin(sine/2.5)),math.rad(0),math.rad(0+5*math.sin(sine/5)) + RootPart.RotVelocity.Y / 13),.1)
                RW.C0 = clerp(RW.C0, CFrame.new(1.5, 0.5, 0+0.34*math.sin(sine/5)) * angles(math.rad(0-80*math.sin(sine/5))+ RootPart.RotVelocity.Y / -34, math.rad(0), math.rad(6+18*math.sin(sine/5))- RootPart.RotVelocity.Y / 34),.15)
                LW.C0=clerp(LW.C0,cf(-1.5,0.5,0-0.34*math.sin(sine/5))*angles(math.rad(0+80*math.sin(sine/5))+ RootPart.RotVelocity.Y / 34,math.rad(0),math.rad(-6+18*math.sin(sine/5))+ RootPart.RotVelocity.Y / -34),.15)
            
            
                LeftLeg.Weld.C0 = clerp(LeftLeg.Weld.C0, CFrame.new(-0.5, -1-0.24*math.cos(sine/5), 0.+0.21*math.cos(sine/5)) * CFrame.Angles(math.rad(-5-60*math.sin(sine/5)), math.rad(0)+ RootPart.RotVelocity.Y / 42, math.rad(0)+ RootPart.RotVelocity.Y / -54), 0.8)
                RightLeg.Weld.C0 = clerp(RightLeg.Weld.C0, CFrame.new(0.5, -1+0.24*math.cos(sine/5),0.-0.21*math.cos(sine/5)) * CFrame.Angles(math.rad(-5+60*math.sin(sine/5)), math.rad(0)+ RootPart.RotVelocity.Y / 42, math.rad(0)- RootPart.RotVelocity.Y / 54), 0.8)
            end

            if attack==true and noleg == false then
                LeftLeg.Weld.C0 = clerp(LeftLeg.Weld.C0, CFrame.new(-0.5, -1-0.24*math.cos(sine/5), 0+0.32*math.sin(sine/5)) * CFrame.Angles(math.rad(0-65*math.sin(sine/5)), math.rad(3), math.rad(0)), 0.2)
                RightLeg.Weld.C0 = clerp(RightLeg.Weld.C0, CFrame.new(0.5, -1+0.24*math.cos(sine/5), 0-0.32*math.sin(sine/5)) * CFrame.Angles(math.rad(0+65*math.sin(sine/5)), math.rad(-3), math.rad(0)), 0.2)
            end
    end
end



 if 0 < #Effects then
      for e = 1, #Effects do
        if Effects[e] ~= nil then
          local Thing = Effects[e]
          if Thing ~= nil then
            local Part = Thing[1]
            local Mode = Thing[2]
            local Delay = Thing[3]
            local IncX = Thing[4]
            local IncY = Thing[5]
            local IncZ = Thing[6]
            if Thing[1].Transparency <= 1 then
              if Thing[2] == "Block1" then
                Thing[1].CFrame = Thing[1].CFrame * euler(math.random(-80, 80), math.random(-80, 80), math.random(-80, 80))
                Mesh = Thing[1]:FindFirstChild("Mesh")
                if not Mesh then
                  Mesh = Instance.new("BlockMesh")
                end
                Mesh.Scale = Mesh.Scale + vt(Thing[4], Thing[5], Thing[6])
                Thing[1].Transparency = Thing[1].Transparency + Thing[3]
            elseif Thing[2] == "Cylinder" then
                  Mesh = Thing[1]:FindFirstChild("Mesh")
                  if not Mesh then
                    Mesh = Instance.new("BlockMesh")
                  end
                  Mesh.Scale = Mesh.Scale + vt(Thing[4], Thing[5], Thing[6])
                  Thing[1].Transparency = Thing[1].Transparency + Thing[3]
                elseif Thing[2] == "Blood" then
                    Mesh = Thing[1]:FindFirstChild("Mesh")
                    if not Mesh then
                      Mesh = Instance.new("BlockMesh")
                    end
                    Thing[1].CFrame = Thing[1].CFrame * cf(0, 0.5, 0)
                    Mesh.Scale = Mesh.Scale + vt(Thing[4], Thing[5], Thing[6])
                    Thing[1].Transparency = Thing[1].Transparency + Thing[3]
                  	elseif Thing[2] == "Elec" then
                      Mesh = Thing[1]:FindFirstChild("Mesh")
                      if not Mesh then
                        Mesh = Instance.new("BlockMesh")
                      end
                      Mesh.Scale = Mesh.Scale + vt(Thing[7], Thing[8], Thing[9])
                      Thing[1].Transparency = Thing[1].Transparency + Thing[3]
                    elseif Thing[2] == "Disappear" then
                        Thing[1].Transparency = Thing[1].Transparency + Thing[3]
                    end
            else
              Part.Parent = nil
              Part:Destroy()
              --game:GetService("Debris"):AddItem(Part, 0)
              table.remove(Effects, e)
            end
          end
        end
      end
    end
end
