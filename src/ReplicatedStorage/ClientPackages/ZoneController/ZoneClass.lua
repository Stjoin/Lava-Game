local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Library.Packages.Signal)

local Zone = {}
Zone.__index = Zone

function Zone.new(Containers)
	local self = setmetatable({}, Zone)
	self.Containers = Containers
	self.playersInZone = {}
	self.isInZone = false
	self.OnPlayerEntered = Signal.new()
	self.OnPlayerLeft = Signal.new()
	for _, container in ipairs(self.Containers) do
		container:SetAttribute("Zone", true)
	end
	return self
end

function Zone:PlayerEntered(character)
	if not self.playersInZone[character] and self.OnPlayerEntered then
		self.playersInZone[character] = true
		self.isInZone = true
		self.OnPlayerEntered:Fire(character)
	end
end

function Zone:PlayerLeft(character)
	if self.playersInZone[character] and self.OnPlayerLeft then
		self.playersInZone[character] = nil
		self.isInZone = false
		self.OnPlayerLeft:Fire(character)
	end
end

function Zone:ContainsPart(part)
	for _, container in ipairs(self.Containers) do
		if container == part then
			return true
		end
	end
	return false
end

function Zone:Destroy()
	if self.OnPlayerEntered  then
		self.OnPlayerEntered:Destroy()
		self.OnPlayerEntered = nil
	end

	if self.OnPlayerLeft then
		self.OnPlayerLeft:Destroy()
		self.OnPlayerLeft = nil
	end
	
	for _, container in ipairs(self.Containers) do
		container:SetAttribute("Zone", nil)
	end
end

return Zone