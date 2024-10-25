local TweenService = game:GetService("TweenService")
local BezierTween = {}

-- One-line quadratic Bezier function
local function quadraticBezier(t, p0, p1, p2)
	return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

-- Function to animate an item (BasePart or Model) along a Bezier curve
function BezierTween.animate(item: BasePart | Model, start: Vector3, finish: Vector3, tweenInfo: TweenInfo, changedFunction: ((item: BasePart | Model, t: number) -> ())?): Tween
	-- Calculate middle control point
	local middle = start:Lerp(finish, 0.5) + Vector3.new(0, 7, 0)  -- 7 studs up on Y axis

	-- Create a dummy object to tween
	local dummy = Instance.new("NumberValue")
	dummy.Value = 0

	-- Create and start the tween
	local tween = TweenService:Create(dummy, tweenInfo, {Value = 1})

	-- Get the initial CFrame of the item
	local initialCFrame
	if item:IsA("BasePart") then
		initialCFrame = item.CFrame
	elseif item:IsA("Model") then
		initialCFrame = item:GetPivot()
	else
		error("Item must be a BasePart or Model")
	end

	-- Connect a function to update the item's position
	dummy.Changed:Connect(function()
		local t = dummy.Value
		-- Get the position on the curve using the quadratic Bezier function
		local newPosition = quadraticBezier(t, start, middle, finish)

		-- Update item position
		if item:IsA("BasePart") then
			item.CFrame = CFrame.new(newPosition) * (initialCFrame - initialCFrame.Position)
		elseif item:IsA("Model") then
			item:PivotTo(CFrame.new(newPosition) * (initialCFrame - initialCFrame.Position))
		end

		-- Call the provided changed function if it exists
		if changedFunction then
			changedFunction(item, t)
		end
	end)

	
	-- Start the tween
	tween:Play()

	tween.Completed:Wait()
	-- Return the tween object so it can be managed if needed
	return tween
end

return BezierTween