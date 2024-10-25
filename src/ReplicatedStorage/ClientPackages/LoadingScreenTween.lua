local RunService = game:GetService("RunService")

local Tween = {}
Tween.__index = Tween

local EasingFunctions = {
	Linear = function(t) return t end,
	InOutSine = function(t) return -(math.cos(math.pi * t) - 1) / 2 end,
}

local function lerp(start, finish, alpha)
	local t = typeof(start)
	if t == "number" then
		return start + (finish - start) * alpha
	elseif t == "Vector2" then
		return Vector2.new(lerp(start.X, finish.X, alpha), lerp(start.Y, finish.Y, alpha))
	elseif t == "Vector3" then
		return Vector3.new(lerp(start.X, finish.X, alpha), lerp(start.Y, finish.Y, alpha), lerp(start.Z, finish.Z, alpha))
	elseif t == "UDim2" then
		return UDim2.new(
			lerp(start.X.Scale, finish.X.Scale, alpha), lerp(start.X.Offset, finish.X.Offset, alpha),
			lerp(start.Y.Scale, finish.Y.Scale, alpha), lerp(start.Y.Offset, finish.Y.Offset, alpha)
		)
	else
		return finish
	end
end

function Tween.new(Object, Property, EndValue, EasingFunction, Duration)
	local self = setmetatable({
		Object = Object,
		Property = Property,
		StartValue = Object[Property],
		EndValue = EndValue,
		EasingFunction = EasingFunctions[EasingFunction] or EasingFunction or EasingFunctions.Linear,
		Duration = Duration,
		ElapsedTime = 0,
		IsPlaying = false,
		CustomBehavior = nil
	}, Tween)
	self:Play()
	return self
end

function Tween:Play()
	if not self.IsPlaying then
		self.IsPlaying = true
		self.Connection = RunService.RenderStepped:Connect(function(deltaTime)
			self.ElapsedTime = self.ElapsedTime + deltaTime
			if self.ElapsedTime < self.Duration then
				local alpha = self.EasingFunction(self.ElapsedTime / self.Duration)
				local value = self.CustomBehavior and self.CustomBehavior(self, alpha) or lerp(self.StartValue, self.EndValue, alpha)
				self.Object[self.Property] = value
			else
				self:Stop()
				self.Object[self.Property] = self.EndValue
			end
		end)
	end
end

function Tween:Stop()
	if self.IsPlaying then
		self.IsPlaying = false
		self.Connection:Disconnect()
	end
end

function Tween:Restart()
	self:Stop()
	self.ElapsedTime = 0
	self.StartValue = self.Object[self.Property]
	self:Play()
end

function Tween:Wait()
	while self.IsPlaying do RunService.RenderStepped:Wait() end
end

local TweenModule = setmetatable({
	EasingFunctions = EasingFunctions,
	SizeTween = function(Object, StartSize, MiddleSize, EndSize, EasingFunction, Duration)
		local tween = Tween.new(Object, "Size", EndSize, EasingFunction, Duration)
		tween.CustomBehavior = function(_, alpha)
			return alpha < 0.5 and lerp(StartSize, MiddleSize, alpha * 2) or lerp(MiddleSize, EndSize, (alpha - 0.5) * 2)
		end
		return tween
	end
}, {
	__call = function(_, ...) return Tween.new(...) end
})

return TweenModule