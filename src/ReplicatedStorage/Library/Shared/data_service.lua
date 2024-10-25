--> Variables
local RunService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local IS_SERVER = RunService:IsServer()

local Promise = require(script.Parent.Parent.Packages.Promise)

local data_service = {
	profileTemplate = require(script.Parent.Parent.Configurations.data_templates),
	dataSets = {},	
	clientReplica = nil
}
data_service.__index = data_service

--> Server Variables

if IS_SERVER then
	Signal = require(script.Parent.Parent.Packages.Signal)
	ReplicaService = require(game.ReplicatedStorage.ServerPackages.replica_service)
	PlayerProfileClassToken = ReplicaService.NewClassToken("PlayerProfile")
else
	player = game.Players.LocalPlayer	
	data_service.ReplicaController = require(game.ReplicatedStorage.ClientPackages.ReplicaController)
end

--> Helper

function DeepCopy(duping)
	local duped = {}
	for index,value in pairs(duping) do
		if type(value) == "table" then
			value = DeepCopy(value)
		end
		duped[index] = value
	end
	return duped
end

--> Server Functions

-- Create a new replica profile for a player
function data_service:NewRepliProfile(player, profile)

	local player_profile = {
		Profile = profile,
		Replica = ReplicaService.NewReplica({
			ClassToken = PlayerProfileClassToken,
			Data = profile.Data,
			Replication = player,
		}),
		_player = player,
		Signals = {},
	}

	setmetatable(player_profile, data_service)
	self.dataSets[player] = player_profile

end

-- Create a new signal for a player's profile
function data_service:CreateSignal(player, key)
	local dataSet = self:GetDataSet(player)
	if not dataSet then return end

	if not dataSet.Signals[key] then
		dataSet.Signals[key] = Signal.new()
	end
end


function data_service:DeleteProfile(player)
	local dataSet = self:GetDataSet(player)
	if dataSet then
		dataSet.Replica:Destroy()
		replicatedStorage.Networking.Bindables.PlayerLeaving:Fire(player, dataSet.Profile.Data)
		
		-- Disconnect all signals
		for key, signal in pairs(dataSet.Signals) do
			signal:Destroy()
		end

		self.dataSets[player] = nil
	end
end
local function DeepCopyTable(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[DeepCopyTable(orig_key)] = DeepCopyTable(orig_value)
		end
		setmetatable(copy, DeepCopyTable(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end

-- Set a value in the player's profile data
function data_service:Set(player, path, operation, value, suppressSignal)
	local profileData = self:GetProfileData(player)
	local dataSet = self:GetDataSet(player)
	if not profileData then return end

	-- Updating profile
	local components = type(path) == "string" and string.split(path, ".") or path
	local currentData = profileData
	for i = 1, #components - 1 do
		currentData = currentData[components[i]]
	end

	local lastKey = components[#components]
	local oldValue = currentData[lastKey]

	if operation == "+" then
		currentData[lastKey] = (currentData[lastKey] or 0) + value
	elseif operation == "-" then
		currentData[lastKey] = (currentData[lastKey] or 0) - value
	elseif operation == "=" then
		currentData[lastKey] = value
	else
		error("Invalid operation: " .. tostring(operation))
	end
	-- Updating replica
	dataSet.Replica:SetValue(path, currentData[lastKey]) 

	-- Fire signal only if not suppressed
	if not suppressSignal then
		self:FireNestedSignals(player, path, currentData[lastKey])
	end
end

function data_service:SetNested(player, path, value)
	value = DeepCopy(value)
	local profileData = self:GetProfileData(player)
	local dataSet = self:GetDataSet(player)
	if not profileData then return end

	local function updateNested(data, keys, index, val)
		if index == #keys then
			data[keys[index]] = val
		else
			if type(data[keys[index]]) ~= "table" then
				data[keys[index]] = {}
			end
			updateNested(data[keys[index]], keys, index + 1, val)
		end
	end

	local components = type(path) == "string" and string.split(path, ".") or path
	updateNested(profileData, components, 1, value)

	-- Updating replica
	if dataSet and dataSet.Replica then
		dataSet.Replica:SetValue(path, value)
	else
		warn("dataSet or Replica is nil for player", player, "path", path)
	end

	-- Fire signals
	self:FireNestedSignals(player, path, value)
end

-- Insert a value or table into a player's profile data
function data_service:Insert(player, path, value)
	local profileData = self:GetProfileData(player)
	local dataSet = self:GetDataSet(player)
	if not profileData or not dataSet then return end

	-- Traverse to the specified path in profileData
	local components = type(path) == "string" and string.split(path, ".") or path
	local targetTable = profileData
	for i = 1, #components - 1 do
		local key = components[i]
		if not targetTable[key] then
			targetTable[key] = {}
		end
		targetTable = targetTable[key]
	end

	local lastKey = components[#components]

	-- Perform insertion based on the type of value
	if type(value) == "table" then
		if not targetTable[lastKey] then
			targetTable[lastKey] = {}
		end
		for k, v in pairs(value) do
			targetTable[lastKey][k] = v
		end
	else
		if not targetTable[lastKey] then
			targetTable[lastKey] = {}
		end
		table.insert(targetTable[lastKey], value)
	end

	-- Update replica if on server
	if IS_SERVER then
		dataSet.Replica:SetValue(path, targetTable[lastKey])
	end

	-- Fire signals for the inserted data
	self:FireNestedSignals(player, path, value)
end

-- Modified FireNestedSignals function
function data_service:FireNestedSignals(player, path, value)
	local dataSet = self:GetDataSet(player)
	if not dataSet then return end

	local components = type(path) == "string" and string.split(path, ".") or path
	local currentPath = ""

	for i = 1, #components do
		currentPath = table.concat(components, ".", 1, i)

		if dataSet.Signals[currentPath] then
			dataSet.Signals[currentPath]:Fire(value)
		end
	end
end

-- Connect a listener to a signal for a player's profile data key
function data_service:ConnectToSignal(player, key, listener)
	if IS_SERVER then
		local dataSet = self:GetDataSet(player)
		if not dataSet then print("Not found") return end

		local components = type(key) == "string" and string.split(key, ".") or key
		local fullPath = table.concat(components, ".")

		if not dataSet.Signals[fullPath] then
			self:CreateSignal(player, fullPath)
		end

		return dataSet.Signals[fullPath]:Connect(function(newValue)
			listener(newValue)
		end)
	else
		-- Client-side functionality
		if not self.clientReplica then
			warn("Client replica not initialized", key)
			return
		end

		local initialValue = data_service:GetData(player, key)
		listener(initialValue)

		return self.clientReplica:ListenToChange(key, function(newValue)
			listener(newValue)
		end)
	end
end

-- Get data from a player's profile using a path
function data_service:GetData(player, path)
	local profileData

	-- Check if on server or client
	if IS_SERVER then
		profileData = self:GetProfileData(player)
	else
		if not self.clientReplica then
			return nil
		end
		profileData = self.clientReplica.Data
	end

	if not profileData then return nil end

	local components = type(path) == "string" and string.split(path, ".") or path
	for _, key in ipairs(components) do
		profileData = profileData[key]
		if profileData == nil then
			return nil
		end
	end

	return profileData
end


-- Get the dataset for a player
function data_service:GetDataSet(player)
	if not self:IsActive(player) then
		return nil
	end

	return self.dataSets[player]
end

function data_service:GetDataAsync(player)
	return Promise.new(function(resolve, reject)
		task.spawn(function()
			local timeout = 10
			local startTime = tick()

			if IS_SERVER then
				repeat
					local dataSet = self:GetDataSet(player)
					if dataSet and dataSet.Profile.Data then
						resolve(dataSet.Profile.Data)
						return
					end
					task.wait(0.1)
				until tick() - startTime >= timeout

				reject("No data found for player within 10 seconds")
			else
				-- Client-side logic
				repeat
					if self.clientReplica and self.clientReplica.Data then
						resolve(self.clientReplica.Data)
						return
					end
					task.wait(0.1)
				until tick() - startTime >= timeout

				reject("No client data found within 10 seconds")
			end
		end)
	end)
end

function data_service:GetProfileData(player, client)
	if IS_SERVER then
		local dataSet = self:GetDataSet(player)
		return dataSet and dataSet.Profile.Data or nil
	else
		return self.clientReplica and self.clientReplica.Data or nil
	end
end

-- Check if a dataset is active for a player
function data_service:IsActive(player)
	return self.dataSets[player] ~= nil
end

--> Client functions

function data_service:RequestData()
	self.ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(replica)
		if not self.clientReplica then
			self.clientReplica = replica
		end	
	end)

	self.ReplicaController.RequestData()
end


return data_service
