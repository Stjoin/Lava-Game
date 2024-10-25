local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local confettiShapesAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ConfettiShapes")
local conffetiFrame = script.Parent.Parent.confetti
local confettiActive = false
local fireConfetti = false
local option

local confettiShapes = {
	["Circle"] = 20,
	["Square"] = 20,
	["Triangle"] = 20,
	["Heart"] = 10,
	["Star"] = 5,
	["Diamond"] = 5,
}
local createdConfetti = {
	rain = {},
	blast = {}
}

local function getRandomConfettiShape()
	local totalWeight = 0
	for _, weight in confettiShapes do
		totalWeight += weight
	end

	local r = math.random(totalWeight)
	local count = 0
	for shape, weight in confettiShapes do
		count += weight
		if r <= count then
			return confettiShapesAssets:FindFirstChild(shape)
		end
	end
end

local UIConfetti = {}
local ConfettiModule = {}
UIConfetti.__index = UIConfetti

type ConfettiOptions = {
	Position: Vector2,
	Force: Vector2,
	Gravity: Vector2,
	Parent: GuiBase,
	Colors: { [number]: Color3 }?,
}

function UIConfetti.new(options: ConfettiOptions)
	if not options then
		return
	end

	local self = setmetatable({}, UIConfetti)

	local xForce = if options.Force.X < 0 then options.Force.X * -1 else options.Force.X

	options.Force = Vector2.new(options.Force.X, options.Force.Y + ((0 - xForce) * 0.8))

	local colorsList
	if not options.Colors then
		-- default colors
		options.Colors = {
			Color3.fromRGB(168, 100, 253),
			Color3.fromRGB(41, 205, 255),
			Color3.fromRGB(120, 255, 68),
			Color3.fromRGB(255, 113, 141),
			Color3.fromRGB(253, 255, 106),
		}
	end
	colorsList = options.Colors

	self.Gravity = options.Gravity or Vector2.new(0, 1)
	self.EmitterPosition = options.Position
	self.EmitterPower = options.Force
	self.Position = Vector2.new(0, 0)
	self.Power = options.Force
	self.Colors = options.Colors
	self.CurrentColor = colorsList[math.random(#colorsList)]

	local function getParticle()
		local label = getRandomConfettiShape():Clone()
		label.ImageColor3 = self.CurrentColor
		label.Parent = options.Parent
		label.Rotation = math.random(360)
		label.Visible = true
		label.ZIndex = 20
		return label
	end

	self.Label = getParticle()
	self.DefaultSize = camera.ViewportSize.Y * 0.04  -- Scale size based on screen height
	self.Size = self.DefaultSize
	self.Side = -1
	self.OutOfBounds = false
	self.Enabled = false
	self.Cycles = 0

	return self
end

function UIConfetti:Update()
	if self.Enabled and self.OutOfBounds then
		self.Label.ImageColor3 = self.CurrentColor
		self.Position = Vector2.new(0, 0)
		self.Power = Vector2.new(self.EmitterPower.X + math.random(10) - 5, self.EmitterPower.Y + math.random(10) - 5)
		self.Cycles = self.Cycles + 1
	end

	if (not self.Enabled and self.OutOfBounds) or (not self.Enabled and (self.Cycles == 0)) then
		self.Label.Visible = false
		self.OutOfBounds = true
		self.CurrentColor = self.Colors[math.random(#self.Colors)]
		return
	else
		self.Label.Visible = true
	end

	local startPosition, currentPosition, currentPower = self.EmitterPosition, self.Position, self.Power
	local imageLabel = self.Label

	if imageLabel then
		-- position
		local newPosition = Vector2.new(currentPosition.X - currentPower.X, currentPosition.Y - currentPower.Y)
		local newPower = Vector2.new((currentPower.X / 1.05) - self.Gravity.X, (currentPower.Y / 1.05) - self.Gravity.Y)
		local ViewportSize = camera.ViewportSize

		imageLabel.Position = UDim2.new(startPosition.X, newPosition.X, startPosition.Y, newPosition.Y)

		self.OutOfBounds = (imageLabel.AbsolutePosition.X > ViewportSize.X and self.Gravity.X > 0)
			or (imageLabel.AbsolutePosition.Y > ViewportSize.Y and self.Gravity.Y > 0)
			or (imageLabel.AbsolutePosition.X < 0 and self.Gravity.X < 0)
			or (imageLabel.AbsolutePosition.Y < 0 and self.Gravity.Y < 0)
		self.Position, self.Power = newPosition, newPower

		-- spin
		if newPower.Y < 0 then
			if self.Size <= 0 then
				self.Side = 1
				imageLabel.ImageColor3 = self.CurrentColor
			end
			if self.Size >= self.DefaultSize then
				self.Side = -1
				imageLabel.ImageColor3 =
					Color3.new(self.CurrentColor.r * 0.9, self.CurrentColor.g * 0.9, self.CurrentColor.b * 0.9)
			end
			self.Size = self.Size + (self.Side * 2)
			imageLabel.Size = UDim2.new(0, self.DefaultSize, 0, self.Size)
		end
	end
end

function UIConfetti:Toggle()
	self.Enabled = not self.Enabled
end

function UIConfetti:Destroy()
	self.Label:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

task.spawn(function()
	for i = 1, 40 do
		local rain = UIConfetti.new({
			Position = Vector2.new(math.random(3, 8) / 10, -0.25),
			Force = Vector2.new(math.random(-50, 50) * camera.ViewportSize.Y / 1080, -math.random(10, 25) * camera.ViewportSize.Y / 1080),  -- Scale force based on screen height
			Gravity = Vector2.new(0, 0.25),
			Parent = conffetiFrame,
		})

		local blast = UIConfetti.new({
			Position = Vector2.new(0.5, 1),
			Force = Vector2.new(math.random(-50,50) * camera.ViewportSize.Y / 1080, math.random(50,100) * camera.ViewportSize.Y / 1080),  -- Scale force based on screen height
			Gravity = Vector2.new(0, 0.4),
			Parent = conffetiFrame,
		})

		rain.Enabled = false
		blast.Enabled = false

		rain:Update()
		blast:Update()

		table.insert(createdConfetti.rain, rain)
		table.insert(createdConfetti.blast, blast)

		task.wait(0.05)
	end
end)

function ConfettiModule:Confetti(option)
	local t = tick()
	fireConfetti = true
	conffetiFrame.Visible = true
	task.spawn(function()
		confettiActive = true
		task.wait(0.5)
		confettiActive = false
	end)
	local connection
	if connection then connection:Disconnect() end
	connection = RunService.RenderStepped:Connect(function()
		if (tick() - t) > 1 then
			fireConfetti = false
		end
		for _, val in pairs(createdConfetti[option]) do
			if (tick() - t) > 1 then
				if val.OutOfBounds == false then
					fireConfetti = true
				end
			end
			val.Enabled = confettiActive
			val:Update()
		end
		if fireConfetti == false then
			connection:Disconnect()
		end
	end)
end

return ConfettiModule
