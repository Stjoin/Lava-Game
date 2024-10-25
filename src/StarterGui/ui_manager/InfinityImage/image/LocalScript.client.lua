local TweenService = game:GetService("TweenService")

-- Configuration
local infinityImage = script.Parent
local cursor = infinityImage:WaitForChild("CursorImage")
local parentObject = script.Parent.Parent

-- Function to calculate point on infinity curve
local function infinityPoint(t)
	local x = math.sin(t) / (1 + math.cos(t)^2)
	local y = math.sin(t) * math.cos(t) / (1 + math.cos(t)^2)
	return Vector2.new(x, y)
end

-- Function to approximate arc length
local function approximateArcLength(numSegments)
	local length = 0
	local prevPoint = infinityPoint(0)
	for i = 1, numSegments do
		local t = (i / numSegments) * 2 * math.pi
		local newPoint = infinityPoint(t)
		length = length + (newPoint - prevPoint).Magnitude
		prevPoint = newPoint
	end
	return length
end

-- Generate evenly spaced points along the path
local function generateEvenlySpacedPoints(numPoints)
	local totalLength = approximateArcLength(1000)  -- Use a high number for better approximation
	local points = {}
	local accumulatedLength = 0
	local prevPoint = infinityPoint(0)
	local t = 0
	for i = 1, numPoints do
		local targetLength = (i - 1) / (numPoints - 1) * totalLength
		while accumulatedLength < targetLength do
			t = t + 0.01  -- Small step size for better accuracy
			local newPoint = infinityPoint(t)
			accumulatedLength = accumulatedLength + (newPoint - prevPoint).Magnitude
			prevPoint = newPoint
		end
		table.insert(points, prevPoint)
	end
	return points
end

-- Generate points for the infinity path
local pathPoints = generateEvenlySpacedPoints(100)  -- Adjust number of points as needed

-- Function to tween cursor along the path
local function tweenAlongPath()
	for _, point in ipairs(pathPoints) do
		if not parentObject:GetAttribute("enabled") then
			return  -- Exit the function if disabled mid-tween
		end
		local tweenInfo = TweenInfo.new(0.02, Enum.EasingStyle.Linear)
		local newX = 0.52 + point.X * 0.35
		local newY = 0.57 + point.Y * 0.8
		local newPos = UDim2.new(newX, 0, newY, 0)
		local tween = TweenService:Create(cursor, tweenInfo, {Position = newPos})
		tween:Play()
		tween.Completed:Wait()
	end
end

-- Main loop
local loopConnection = nil

local function startLoop()
	if loopConnection then return end  -- Prevent multiple loops
	loopConnection = task.spawn(function()
		while parentObject:GetAttribute("enabled") do
			tweenAlongPath()
			task.wait()
		end
	end)
end

local function stopLoop()
	if loopConnection then
		task.cancel(loopConnection)
		loopConnection = nil
	end
end

-- Listen for attribute changes
parentObject:GetAttributeChangedSignal("enabled"):Connect(function()
	local enabled = parentObject:GetAttribute("enabled")	
	script.Parent.Parent.Visible = enabled
	
	if parentObject:GetAttribute("enabled") then
		startLoop()
	else
		stopLoop()
	end
end)

-- Initial setup
if parentObject:GetAttribute("enabled") then
	startLoop()
end