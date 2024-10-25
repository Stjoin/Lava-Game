--> Variables
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

local Tween = {}
local rotatingObjects = {}

--> Module Functions

-- UpDown
function Tween.UpDown(object, height)
	local isBasePart = object:IsA("BasePart")
	local isGuiObject = object:IsA("GuiObject")

	local endPosition
	if isBasePart then
		endPosition = object.Position + Vector3.new(0, object.Size.Y * (height or 1), 0)
	elseif isGuiObject then
		endPosition = object.Position + UDim2.new(0, 0, 0, object.Size.Y.Offset * (height or 1))
	else
		error("Object must be a BasePart or GuiObject")
	end

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)

	local tween = tweenService:Create(object, tweenInfo, {Position = endPosition})
	tween:Play()
end

-- Rotate
function Tween.Rotate(object, speed, axis)
	speed = speed or 1
	axis = axis or "Y"
	axis = string.upper(axis)
	if axis ~= "X" and axis ~= "Y" and axis ~= "Z" then
		error("Invalid axis. Must be 'X', 'Y', or 'Z'")
	end
	table.insert(rotatingObjects, {object = object, speed = speed, axis = axis})
end

runService.Heartbeat:Connect(function()
	for _, item in ipairs(rotatingObjects) do
		local object = item.object
		local speed = item.speed
		local axis = item.axis
		if object:IsA("BasePart") then
			-- Rotate the BasePart
			local rotation
			if axis == "X" then
				rotation = CFrame.Angles(math.rad(speed), 0, 0)
			elseif axis == "Y" then
				rotation = CFrame.Angles(0, math.rad(speed), 0)
			else  -- Z axis
				rotation = CFrame.Angles(0, 0, math.rad(speed))
			end
			object.CFrame = object.CFrame * rotation
		elseif object:IsA("GuiObject") then
			-- Rotate the GuiObject
			object.Rotation = object.Rotation + speed
		elseif object:IsA("Model") then
			-- Rotate the Model
			local rotation
			if axis == "X" then
				rotation = CFrame.Angles(math.rad(speed), 0, 0)
			elseif axis == "Y" then
				rotation = CFrame.Angles(0, math.rad(speed), 0)
			else  -- Z axis
				rotation = CFrame.Angles(0, 0, math.rad(speed))
			end
			-- Use PivotTo for models
			local currentCFrame = object:GetPivot()
			object:PivotTo(currentCFrame * rotation)
		else
			error("Object must be a BasePart, GuiObject, or Model")
		end
	end
end)

-- Bounce
function Tween.Bounce(object, Distance, Speed, Interval, Repeats)
	task.spawn(function()
		Distance = Distance or 0.2
		Interval = Interval or 1
		Repeats = Repeats or -1
		Speed = Speed or 1

		local StartPosition = object.Position
		local TargetPosition

		if object:IsA("BasePart") then
			TargetPosition = StartPosition + Vector3.new(0, Distance, 0)
		elseif object:IsA("GuiObject") then
			TargetPosition = StartPosition - UDim2.fromScale(0, Distance)
		else
			error("Object must be a BasePart or GuiObject")
		end

		local Time = 1 / Speed

		while Repeats ~= 0 do
			Repeats -= 1
			tweenService:Create(object, TweenInfo.new(Time * 0.3, Enum.EasingStyle.Circular), {Position = TargetPosition}):Play()
			task.wait(Time * 0.3)
			tweenService:Create(object, TweenInfo.new(Time * 0.7, Enum.EasingStyle.Bounce), {Position = StartPosition}):Play()
			task.wait(Time * 0.7 + Interval)
		end
	end)
end

-- Shake
function Tween.Shake(object, Rotation, Time, Interval, Count, Repeats)
	task.spawn(function()
		Interval = Interval or 1.5
		Rotation = Rotation or 45
		Repeats = Repeats or -1
		Time = Time or 0.15
		Count = Count or 3

		local StartRotation
		if object:IsA("BasePart") then
			StartRotation = object.Orientation
		elseif object:IsA("GuiObject") then
			StartRotation = object.Rotation
		else
			error("Object must be a BasePart or GuiObject")
		end

		local ShakeInfo = TweenInfo.new(Time, Enum.EasingStyle.Linear)

		while Repeats ~= 0 do
			Repeats -= 1
			for Shake = 1, Count do
				if object:IsA("BasePart") then
					tweenService:Create(object, ShakeInfo, {Orientation = StartRotation + Vector3.new(Rotation, 0, 0)}):Play()
				elseif object:IsA("GuiObject") then
					tweenService:Create(object, ShakeInfo, {Rotation = StartRotation + Rotation}):Play()
				end
				task.wait(Time)
				if object:IsA("BasePart") then
					tweenService:Create(object, ShakeInfo, {Orientation = StartRotation}):Play()
				elseif object:IsA("GuiObject") then
					tweenService:Create(object, ShakeInfo, {Rotation = StartRotation}):Play()
				end
				Rotation = -Rotation
			end
			task.wait(Interval)
		end
	end)
end

return Tween
