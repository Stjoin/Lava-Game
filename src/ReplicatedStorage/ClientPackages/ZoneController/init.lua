local library = require(game:GetService("ReplicatedStorage").Library)
local zoneClass = require(script.ZoneClass)
local tableUtil = library.Packages.TableUtil
local player = library.LocalPlayer

local ZonesTable = {}
local ZoneController = {
	ActiveZones = {},
	NotActiveZones = {},
}

-- Utility Functions
local function SwapRemove(t, i)
	local n = #t
	t[i] = t[n]
	t[n] = nil
end

local function Some(tbl, callback)
	for k, v in pairs(tbl) do
		if callback(v, k, tbl) then
			return true
		end
	end
	return false
end

function ZoneController:NewZone(containers, destroyable)
	containers = type(containers) == "table" and containers or {containers}

	local zone = zoneClass.new(containers)

	ZoneController:EnableZone(zone)

	if destroyable then
		for _, container in ipairs(containers) do
			container.Destroying:Once(function()
				ZoneController:DestroyZone(zone)
			end)
		end
	end

	return zone
end

function ZoneController:EnableZone(zone)
	if self.NotActiveZones[zone] then
		SwapRemove(self.NotActiveZones, zone)
	end
	table.insert(self.ActiveZones, zone)
end

function ZoneController:DisableZone(zone)
	if self.ActiveZones[zone] then
		SwapRemove(self.ActiveZones, zone)
	end
	table.insert(self.NotActiveZones, zone)
end

function ZoneController:IsPartOfZone(part)
	for _, zone in pairs(self.ActiveZones) do
		if zone:ContainsPart(part) then
			return zone
		end
	end
	return false
end

function ZoneController:CheckPlayer(character)
	if self.isResetting then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = { character }
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	local overlappingParts = workspace:GetPartsInPart(humanoidRootPart, overlapParams)

	local currentZones = {}
	for _, overlappingPart in pairs(overlappingParts) do
		local zone
		if overlappingPart:GetAttribute("Zone") then
			zone = self:IsPartOfZone(overlappingPart)
			if zone then
				table.insert(currentZones, zone)
				if not ZonesTable[character] or not Some(ZonesTable[character], function(z)
						return z == zone
					end) then
					
					-- Player has Entered this zone
					zone:PlayerEntered(character)
				end
			end
		end
	end

	if ZonesTable[character] then
		for _, oldZone in pairs(ZonesTable[character]) do
			if not Some(currentZones, function(z)
					return z == oldZone
				end) then
				-- Player has left this zone
				oldZone:PlayerLeft(character)
			end
		end
	end

	ZonesTable[character] = currentZones
end

function ZoneController:DestroyZone(destroyableZone)
	if self.ActiveZones[destroyableZone] then
		SwapRemove(self.ActiveZones, destroyableZone)
	elseif self.NotActiveZones[destroyableZone] then
		SwapRemove(self.NotActiveZones, destroyableZone)
	end

	for character, zones in pairs(ZonesTable) do
		for index, zone in ipairs(zones) do
			if zone == destroyableZone then
				table.remove(zones, index)
				destroyableZone:PlayerLeft(character)
				break
			end
		end
	end

	destroyableZone:Destroy()
end

function ZoneController:ResetAllZones()	
	for character, zones in pairs(ZonesTable) do
		for _, zone in ipairs(zones) do			
			zone.OnPlayerLeft:Fire(character)
		end
	end
	table.clear(ZonesTable)
	
	wait()

	for _, zone in pairs(self.ActiveZones) do
		zone:Destroy()
	end
	self.ActiveZones = {}

	for _, zone in pairs(self.NotActiveZones) do
		zone:Destroy()
	end
	self.NotActiveZones = {}
end

local characterTasks = {} 

local function characterAdded(character)
	if characterTasks[character] then
		characterTasks[character]:Cancel() 
	end

	
	characterTasks[character] = task.spawn(function()
		local player = game.Players:GetPlayerFromCharacter(character)
		if not player then return end

		local loaded = player:HasAppearanceLoaded()
		repeat task.wait(0.1) loaded = player:HasAppearanceLoaded() until loaded

		while character:IsDescendantOf(workspace) do
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then break end

			if character.PrimaryPart then
				ZoneController:CheckPlayer(character)
			end

			task.wait(0.1)
		end

		characterTasks[character] = nil
	end)
end

library.Functions.characterAddedFunction(player, characterAdded)

library.Remotes.InitiateRebirth.OnClientEvent:Connect(function(player)
	ZoneController:ResetAllZones()
end)

return ZoneController