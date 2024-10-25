
--< Services
local PlayerService = game:GetService("Players")

--< Variables
local BASE_SIZE = 1920 -- 1700 for you

local Player = PlayerService.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UIStrokeStore = {}

--< Functions
local function GetResolution() -- Get current screen resolution
	local viewportSize =  script.Parent.AbsoluteSize
	return viewportSize.X, viewportSize.Y
end

local function StrokeResolution(uiStroke) -- Update one UIStroke
	--// Variables
	local x, y = GetResolution()
	local thickness = uiStroke:GetAttribute("SavedThickness")
	local newThickness = ((thickness / BASE_SIZE) * x)

	--// Update Thickness
	uiStroke.Thickness = newThickness
end

local function ScanForAutoStroke(inst) -- Scan an Instance to find some UIStroke
	for _, uiObject in next, inst:GetDescendants() do
		local ignore = uiObject:GetAttribute("Ignore") -- You can put an boolean attribute set to true on a UIStroke and it will be ignored by the script

		if uiObject:IsA("UIStroke") and (not table.find(UIStrokeStore, uiObject)) and (not ignore) then
			uiObject:SetAttribute("SavedThickness", uiObject.Thickness)
			StrokeResolution(uiObject)

			table.insert(UIStrokeStore, uiObject)
		end
	end
end

local function UpdateStrokeResolution() -- Update all UIStroke registered
	for i = 1, #UIStrokeStore do
		StrokeResolution(UIStrokeStore[i])
	end
end

--< Initialize
ScanForAutoStroke(PlayerGui) -- Scan complete PlayerGui

--< Connections
script.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateStrokeResolution) -- Resize if window size update

PlayerGui.DescendantAdded:Connect(function() -- Scan again to auto stroke new potential UIStroke
	ScanForAutoStroke(PlayerGui)
end)