local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local PathVisualizer = {}
PathVisualizer.__index = PathVisualizer

-- Constants
local DOT_SPACING = math.huge -- Space between dots in studs
local DOT_SIZE = Vector3.new(0.8, 0.8, 0.8)
local DOT_COLOR = Color3.new(1, 1, 0) -- Yellow color for dots
local LINE_COLOR = Color3.new(1, 0.7, 0) -- Slightly darker yellow for lines
local LINE_THICKNESS = 1
local UPDATE_INTERVAL = 0.2 -- Update path every 0.1 seconds
local RAYCAST_DISTANCE = 100 -- Maximum distance for the raycast

function PathVisualizer.new(player, destination)
	local self = setmetatable({}, PathVisualizer)
	self.player = player
	self.destination = destination
	self.dots = {}
	self.lines = {}
	self.lastUpdate = 0
	self.startDot = nil
	self.startAttachment = nil
	return self
end

function PathVisualizer:CreateStartDot()
	self.startDot = self:CreateDot(Vector3.new(0, 0, 0))
	self.startAttachment = Instance.new("Attachment")
	self.startAttachment.Parent = self.startDot
end

function PathVisualizer:UpdateStartDotPosition()
	local character = self.player.Character
	if not character then return end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character, self.startDot}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local rayDirection = Vector3.new(0, -RAYCAST_DISTANCE, 0)

	local raycastResult = workspace:Raycast(humanoidRootPart.Position, rayDirection, raycastParams)

	if raycastResult then
		self.startDot.Position = raycastResult.Position
	else
		-- If raycast fails, set to a position slightly below the HumanoidRootPart
		self.startDot.Position = humanoidRootPart.Position - Vector3.new(0, humanoidRootPart.Size.Y/2 + 1, 0)
	end
end

function PathVisualizer:UpdatePath()
	if not self.startDot then return end
	local path = PathfindingService:CreatePath({WaypointSpacing = DOT_SPACING})
	path:ComputeAsync(self.startDot.Position, self.destination)
	if path.Status == Enum.PathStatus.Success then
		self:ClearVisuals()
		self:CreateVisuals(path:GetWaypoints())
	end
end

function PathVisualizer:CreateVisuals(waypoints)
	local prevAttachment = self.startAttachment
	for i = 2, #waypoints do  -- Start from 2 to skip the first waypoint (player's position)
		local position = waypoints[i].Position
		local dot = self:CreateDot(position)
		table.insert(self.dots, dot)

		local attachment = Instance.new("Attachment")
		attachment.Parent = dot

		if prevAttachment then
			local line = self:CreateLine(prevAttachment, attachment)
			table.insert(self.lines, line)
		end
		prevAttachment = attachment

		-- Create additional dots and lines between waypoints
		if i < #waypoints then
			local nextPosition = waypoints[i + 1].Position
			local direction = (nextPosition - position).Unit
			local distance = (nextPosition - position).Magnitude
			local dotsCount = math.floor(distance / DOT_SPACING) - 1

			for j = 1, dotsCount do
				local interpPosition = position + direction * (j * DOT_SPACING)
				local interpDot = self:CreateDot(interpPosition)
				table.insert(self.dots, interpDot)

				local interpAttachment = Instance.new("Attachment")
				interpAttachment.Parent = interpDot

				local interpLine = self:CreateLine(prevAttachment, interpAttachment)
				table.insert(self.lines, interpLine)

				prevAttachment = interpAttachment
			end
		end
	end
end

function PathVisualizer:CreateDot(position)
	local dot = Instance.new("Part")
	dot.Shape = "Ball"
	dot.Anchored = true
	dot.CanCollide = false
	dot.Size = DOT_SIZE
	dot.Transparency =1 
	dot.Position = position
	dot.Parent = workspace
	return dot
end

function PathVisualizer:CreateLine(attachment0, attachment1)
	local beam = Instance.new("Beam")
	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.Width0 = LINE_THICKNESS
	beam.Width1 = LINE_THICKNESS
	beam.FaceCamera = true
	beam.Texture = "rbxassetid://2823834262"
	beam.TextureSpeed = 5
	beam.LightEmission = 0.3
	beam.LightInfluence = 1
	beam.TextureMode = Enum.TextureMode.Wrap
	beam.Transparency = NumberSequence.new(0)
	beam.Segments = 1
	beam.Color = ColorSequence.new(LINE_COLOR)
	beam.Parent = workspace
	return beam
end

function PathVisualizer:ClearVisuals()
	for _, dot in ipairs(self.dots) do
		dot:Destroy()
	end
	self.dots = {}

	for _, line in ipairs(self.lines) do
		line:Destroy()
	end
	self.lines = {}
end

function PathVisualizer:Start()
	self:CreateStartDot()

	self.updateConnection = RunService.Heartbeat:Connect(function()
		self:UpdateStartDotPosition()

		if time() - self.lastUpdate >= UPDATE_INTERVAL then
			self:UpdatePath()
			self.lastUpdate = time()
		end
	end)
end

function PathVisualizer:Stop()
	if self.updateConnection then
		self.updateConnection:Disconnect()
	end
	self:ClearVisuals()
	if self.startDot then
		self.startDot:Destroy()
		self.startDot = nil
	end
end

function PathVisualizer:SetDestination(newDestination)
	self.destination = newDestination
	self:UpdatePath()
end

return PathVisualizer