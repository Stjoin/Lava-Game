local HTTPService = game:GetService('HttpService')
local TweenService = game:GetService('TweenService')

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer.PlayerGui
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")

local SystemsContainer = {}

local fadeScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
fadeScreenGui.Name = 'Main'
fadeScreenGui.DisplayOrder = 70
fadeScreenGui.Enabled = true
fadeScreenGui.ResetOnSpawn = false
fadeScreenGui.IgnoreGuiInset = true

local linearFadeFrame = Instance.new("Frame", fadeScreenGui)
linearFadeFrame.AnchorPoint = Vector2.new(0.5, 0.5)
linearFadeFrame.BackgroundColor3 = Color3.new()
linearFadeFrame.BackgroundTransparency = 0
linearFadeFrame.BorderSizePixel = 0
linearFadeFrame.Size = UDim2.fromScale(1, 1)
linearFadeFrame.Position = UDim2.fromScale(0.5, 0.5)

local fourSquaresFade = {}
for x = 0, 1 do
	for y = 0, 1 do
		local frame = Instance.new("Frame", fadeScreenGui)
		frame.AnchorPoint = Vector2.new(x, y)
		frame.BackgroundColor3 = Color3.fromRGB(255, 102, 219)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		table.insert(fourSquaresFade, frame)
	end
end

local gridFadeInOutSpin = {}
local blockSize = 120 -- pixels
local baseGridFrame = Instance.new("Frame")
baseGridFrame.AnchorPoint = Vector2.new(0.5, 0.5)
baseGridFrame.BackgroundColor3 = Color3.fromRGB(255, 102, 219)
baseGridFrame.BackgroundTransparency = 1
baseGridFrame.BorderSizePixel = 0
baseGridFrame.Size = UDim2.fromOffset(blockSize, blockSize)

local function UpdateBlackGridSquares()
	for x = 1, math.ceil(fadeScreenGui.AbsoluteSize.X / blockSize) do
		if not gridFadeInOutSpin[x] then
			gridFadeInOutSpin[x] = {}
		end
		for y = 1, math.ceil(fadeScreenGui.AbsoluteSize.Y / blockSize) do
			if gridFadeInOutSpin[x][y] then
				continue
			end
			local newBase = baseGridFrame:Clone()
			newBase.Name = 'Grid_'..x..y
			newBase.Position = UDim2.fromOffset(x * blockSize - blockSize/2, y * blockSize - blockSize/2)
			newBase.Parent = fadeScreenGui

			local uiCorner = Instance.new("UICorner")
			uiCorner.Parent = newBase

			gridFadeInOutSpin[x][y] = newBase
		end
	end
end

local currentTweenID = nil

-- // Module // --
local Module = {}

Module.customTweenInfos = {
	defaultTweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
	backTweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	backQuadTweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

function Module:NewTweenID()
	currentTweenID = HTTPService:GenerateGUID(false)
	return currentTweenID
end

function Module:DeferOnTweenComplete(myID, duration)
	task.defer(function()
		task.wait(duration)
		if myID == currentTweenID then
			currentTweenID = nil
		end
	end)
end

function Module:LinearIn(tweenInfo)
	tweenInfo = tweenInfo or Module.customTweenInfos.defaultTweenInfo
	local tweenID = Module:NewTweenID()
	local fadeGoal = { BackgroundTransparency = 0 }
	TweenService:Create(linearFadeFrame, tweenInfo, fadeGoal):Play()
	Module:DeferOnTweenComplete(tweenID, tweenInfo.Time)
	return tweenID
end

function Module:LinearOut(tweenInfo)
	tweenInfo = tweenInfo or Module.customTweenInfos.defaultTweenInfo
	local tweenID = Module:NewTweenID()
	local fadeGoal = { BackgroundTransparency = 1 }
	TweenService:Create(linearFadeFrame, tweenInfo, fadeGoal):Play()
	Module:DeferOnTweenComplete(tweenID, tweenInfo.Time)
	return tweenID
end

function Module:GridSquaresIn(tweenInfo)
	tweenInfo = tweenInfo or Module.customTweenInfos.defaultTweenInfo
	local tweenID = Module:NewTweenID()
	for y = 1, math.ceil(fadeScreenGui.AbsoluteSize.Y / blockSize) do
		task.spawn(function()
			task.wait((y - 1) * 0.05)
			for x = 1, math.ceil(fadeScreenGui.AbsoluteSize.X / blockSize) do
				local frame = gridFadeInOutSpin[x] and gridFadeInOutSpin[x][y]
				if frame then
					frame.Transparency = 0
					frame.UICorner.CornerRadius = UDim.new(1, 0)
					frame.Size = UDim2.fromOffset(0, 0)
					TweenService:Create(frame, tweenInfo, {Size = UDim2.fromOffset(blockSize * 2, blockSize * 2)}):Play()
				end
			end
		end)
	end
	Module:DeferOnTweenComplete(tweenID, tweenInfo.Time)
	return tweenID
end

function Module:GridSquaresOut(tweenInfo)
	tweenInfo = tweenInfo or Module.customTweenInfos.defaultTweenInfo
	local tweenID = Module:NewTweenID()
	for y = 1, math.ceil(fadeScreenGui.AbsoluteSize.Y / blockSize) do
		task.spawn(function()
			task.wait((y - 1) * 0.05)
			for x = 1, math.ceil(fadeScreenGui.AbsoluteSize.X / blockSize) do
				local frame = gridFadeInOutSpin[x] and gridFadeInOutSpin[x][y]
				if frame then
					TweenService:Create(frame, tweenInfo, {Size = UDim2.fromOffset(0, 0)}):Play()
				end
			end
		end)
	end
	Module:DeferOnTweenComplete(tweenID, tweenInfo.Time)
	return tweenID
end

function Module:GetGuiObjectsAtMouse()
	return PlayerGui:GetGuiObjectsAtPosition(LocalMouse.X, LocalMouse.Y)
end

function Module:CharacterAdded(NewCharacter : Model?)
	task.defer(function()
		Module:LinearOut(TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
	end)
	local Humanoid : Humanoid? = NewCharacter and NewCharacter:WaitForChild('Humanoid', 3)
	if Humanoid then
		Humanoid.Died:Connect(function()
			Module:LinearIn()
		end)
	end
end

function Module:YieldForTweenEnd(TweenID : string) : nil
	if currentTweenID == TweenID then
		repeat task.wait(0.1) until currentTweenID ~= TweenID
	end
end

function Module:Init(loadedSystems)

	if Module.Initialised then
		return
	end
	Module.Initialised = true

	-- Load other modules.

	fadeScreenGui:GetPropertyChangedSignal('AbsoluteSize'):Connect(UpdateBlackGridSquares)
	task.defer(UpdateBlackGridSquares)

	if LocalPlayer.Character then
		task.defer(function()
			Module:CharacterAdded(LocalPlayer.Character)
		end)
	end
	LocalPlayer.CharacterAdded:Connect(function(NewCharacter : Model?)
		Module:CharacterAdded(NewCharacter)
	end)

	task.spawn(function()
		--[[while task.wait(4) do
			Module:GridSquaresIn()
			task.wait(2)
			Module:GridSquaresOut()
		end--]]

		--[[while task.wait(14) do
			Module:GridSquaresIn()
			task.wait(2)
			Module:GridSquaresOut()
		end--]]
	end)

end

return Module
