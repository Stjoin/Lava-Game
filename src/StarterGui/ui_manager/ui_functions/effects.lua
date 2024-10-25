local module = {}
local Player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local SFX = game.SoundService.SFX
local Main = Player:WaitForChild("PlayerGui"):WaitForChild("main")


local Effects = {
	["ButtonEffects2"] = {},
}

GuiService.MenuOpened:Connect(function()
	for _,Button in pairs(Effects["ButtonEffects2"]) do
		Button.Visible = false
	end
end)

GuiService.MenuClosed:Connect(function()
	for _,Button in pairs(Effects["ButtonEffects2"]) do
		Button.Visible = true
	end
end)

function module.Audio(Name, Volume, PlaybackSpeed)
	local NewAudio = SFX:FindFirstChild(Name, true):Clone()
	NewAudio.Parent = SFX
	spawn(function()
		NewAudio.Volume = Volume or NewAudio.Volume
		NewAudio.PlaybackSpeed = PlaybackSpeed or NewAudio.PlaybackSpeed
		NewAudio:Play()
		NewAudio.Ended:wait()
		NewAudio:Destroy()
	end)
	return NewAudio
end


function module.CurrencyChangedTween(frame)
	local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Sine)

	local tween1 = TweenService:Create(frame.UIScale, tweenInfo, { Scale = 1.1 })
	tween1:Play()
	
	tween1.Completed:Once(function()
		local tween2 = TweenService:Create(frame.UIScale, tweenInfo, { Scale = 1 })
		tween2:Play()
	end)
	
end


function module.tweenPopUp(frame, scale)
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection[scale == 1 and "Out" or "In"])
	
	if scale == 1 then
		frame.Visible = true
	end
	
	local tween = TweenService:Create(frame.UIScale, tweenInfo, { Scale = scale })

	tween.Completed:Connect(function()
		if scale == 0 then
			frame.Visible = false
		end
	end)

	tween:Play()
end

function module.ButtonEffects0()
	
end

function module.ButtonEffects1(Button)
	local Scale = Button:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", Button)
	local rotations = {}
	
	for _,child in Button:GetChildren() do
		if child:HasTag("Rotate") then
			rotations[child] = child.Rotation
		end
	end
	
	Button.MouseEnter:Connect(function()
		if Player:GetAttribute("Device") ~= "PC" then return end
		module.Audio("Hover")
		
		for rotatable,amount in rotations do
			TweenService:Create(rotatable, TweenInfo.new(0.1), {Rotation = amount + 20}):Play()
		end
		
		TweenService:Create(Scale, TweenInfo.new(0.1), {Scale = 1.1}):Play()
	end)
	
	Button.MouseLeave:Connect(function()
		if Player:GetAttribute("Device") ~= "PC" then return end
		
		for rotatable,amount in rotations do
			TweenService:Create(rotatable, TweenInfo.new(0.1), {Rotation = amount}):Play()
		end
		
		TweenService:Create(Scale, TweenInfo.new(0.1), {Scale = 1}):Play()
	end)
	
	Button.ChildAdded:Connect(function(Trigger)
		if Trigger.Name == "PressDown" then
			module.Audio("PressDown")
			TweenService:Create(Scale, TweenInfo.new(0.06), {Scale = 0.9}):Play()
		elseif Trigger.Name == "PressUp" then
			TweenService:Create(Scale, TweenInfo.new(0.1), {Scale = 1.1}):Play()
			task.wait(0.1)
			TweenService:Create(Scale, TweenInfo.new(0.1), {Scale = 1}):Play()
		end
	end)
end

function module.ButtonEffects2(Button)
	Button.MouseEnter:Connect(function()
		if Player:GetAttribute("Device") ~= "PC" then return end
		Button.StateOverlay.ImageColor3 = Color3.fromRGB(255,255,255)
		Button.StateOverlay.ImageTransparency = 0.9
	end)
	
	Button.MouseLeave:Connect(function()
		if Player:GetAttribute("Device") ~= "PC" then return end
		Button.StateOverlay.ImageTransparency = 1
		Button.StateOverlay.ImageColor3 = Color3.fromRGB(255,255,255)
	end)
	
	Button.ChildAdded:Connect(function(Trigger)
		if Trigger.Name == "PressDown" then
			Button.StateOverlay.ImageTransparency = 0.7
			Button.StateOverlay.ImageColor3 = Color3.fromRGB(0,0,0)
		elseif Trigger.Name == "PressUp" then
			Button.StateOverlay.ImageTransparency = 0.9
			Button.StateOverlay.ImageColor3 = Color3.fromRGB(255,255,255)
		end
	end)
	
	table.insert(Effects["ButtonEffects2"], Button)
	if GuiService.MenuIsOpen then
		Button.Visible = false
	end
end

function module.FrameEffects1(Frame)
	Frame:SetAttribute("Opened", Frame.Position)
	Frame:SetAttribute("Closed", Frame.Position+UDim2.new(0,0,2,0))
	Frame.Position = Frame:GetAttribute("Closed")
	Frame.Visible = false
	Frame:SetAttribute("Open", false)
	
	Frame:GetAttributeChangedSignal("Open"):Connect(function()
		if Frame:GetAttribute("Open") then
			Frame.Position = Frame:GetAttribute("Opened")+UDim2.new(0,0,.2,0)
			Frame.Visible = true
			Camera.FOV.Value += 10
			TweenService:Create(Lighting.Blur, TweenInfo.new(0.15), {Size = 10}):Play()
			TweenService:Create(Frame, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = Frame:GetAttribute("Opened")}):Play()
			module.Audio("Swoosh")
		else
			Camera.FOV.Value -= 10
			TweenService:Create(Lighting.Blur, TweenInfo.new(0.15), {Size = 0}):Play()
			TweenService:Create(Frame, TweenInfo.new(0.15), {Position = Frame:GetAttribute("Closed")}):Play()
			task.wait(0.15)
			if Frame.Position == Frame:GetAttribute("Closed") then
				Frame.Visible = false
			end
		end
	end)
end

function module.FrameEffects2(Frame)
	Frame:SetAttribute("Opened", Frame.Position)
	Frame:SetAttribute("Closed", Frame.Position+UDim2.new(0,0,2,0))
	Frame.Position = Frame:GetAttribute("Closed")
	Frame.Visible = false
	Frame:SetAttribute("Open", false)

	Frame:GetAttributeChangedSignal("Open"):Connect(function()
		if Frame:GetAttribute("Open") then
			Frame.Visible = true
			--Camera.FOV.Value += 10
			TweenService:Create(Frame, TweenInfo.new(0.25), {Position = Frame:GetAttribute("Opened")}):Play()
			module.Audio("Swoosh")
		else
			--Camera.FOV.Value -= 10
			TweenService:Create(Frame, TweenInfo.new(0.25), {Position = Frame:GetAttribute("Closed")}):Play()
			task.wait(0.25)
			if Frame.Position == Frame:GetAttribute("Closed") then
				Frame.Visible = false
			end
		end
	end)
end

function module.NotificationEffects1(Notification)
	task.spawn(function()
		Notification.label.Size = UDim2.new(0,0,0,0)
		Notification.Parent = script.Parent.Parent.notifications
		TweenService:Create(Notification.label, TweenInfo.new(0.2), {Size = UDim2.new(1,0,1,0)}):Play()
		
		local rotation = Notification.label.Rotation
		TweenService:Create(Notification.label, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Rotation = rotation + 6}):Play()
		task.delay(0.2, function()
			TweenService:Create(Notification.label, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = rotation}):Play()
		end)
		
		task.wait(4)
		TweenService:Create(Notification.label, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
		task.wait(0.2)
		Notification:Destroy()
	end)
end

function module.NotificationEffects2(Notification : TextLabel)
	local Mouse = game.Players.LocalPlayer:GetMouse()
	local Location = UDim2.fromOffset(Mouse.X , Mouse.Y)

	local Parent = script.Parent.Parent
	
	local EffectsFolder = Parent:FindFirstChild("Effects")
	if not EffectsFolder then
		EffectsFolder = Instance.new("Folder")
		EffectsFolder.Name = "Effects"
		EffectsFolder.Parent = Parent
	end	
	
	Notification.AnchorPoint = Vector2.one/2
	Notification.Position = Location
	Notification.Parent = EffectsFolder
	
	local EffectWidth = Parent.AbsoluteSize.X * 0.2
	local EffectHeight = Parent.AbsoluteSize.Y * 0.2 

	local RandomWidth = (math.random() - 0.5)
	local RandomRotation = math.random() * 45 * math.sign(RandomWidth) * math.abs(RandomWidth)

	local UIStrokeTransparency =  TweenService:Create(Notification.label.UIStroke , TweenInfo.new(0.3 , Enum.EasingStyle.Sine , Enum.EasingDirection.Out,0, false, 0.4) , {
		Transparency = 1
	})
	local TweenObjTransparency =  TweenService:Create(Notification.label , TweenInfo.new(0.3 , Enum.EasingStyle.Sine , Enum.EasingDirection.Out, 0, false, 0.4) , {
		TextTransparency = 1
	})

	local TweenObj = TweenService:Create(Notification , TweenInfo.new(0.7 , Enum.EasingStyle.Quad , Enum.EasingDirection.Out) , {
		Position = Location + UDim2.fromOffset( RandomWidth * EffectWidth , -EffectHeight ),
		Rotation = RandomRotation,
	})

	--TweenObj.Parent = Notification
	
	Notification.Parent = EffectsFolder
	
	TweenObj:Play()
	
	UIStrokeTransparency:Play()
	TweenObjTransparency:Play()

	game.Debris:AddItem(Notification , TweenObj.TweenInfo.Time)
end


return module
