--> Variables

local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local SocialService = game:GetService("SocialService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")

local UIEffects = require(script.effects)
local Confetti = require(script.Confetti)
local FadeEffect = require(script.FadeEffect)
local Shimmer = require(script.Shimmer)
local functions = require(game.ReplicatedStorage.Library.Packages.Functions)
local settingsConfig = require(game.ReplicatedStorage.Library.Configurations.settings)
local tweenLibrary = require(game.ReplicatedStorage.Library.Packages.TweenLibrary)

local Player = Players.LocalPlayer
local Assets = ReplicatedStorage.Assets
local Remotes = ReplicatedStorage.Networking.Remotes

local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")

local TraverseUI = script.Parent.traverse
local PromptUI = script.Parent.prompt
local ConfettiUI = script.Parent.confetti
local PurchaseUI = script.purchase
local TipDefine = script.Parent.tipdefine
local Tip = script.Parent.tiplabel
local SFX = game.SoundService.SFX

local _,CanInvite = pcall(function() return SocialService:CanSendGameInviteAsync(Player) end)
local PromptKeybind = Enum.KeyCode.F
local RNG = Random.new()

local MouseOffset = {}
local GamePasses = {}
local KeyBinds = {}
local Products = {}
local Frames = {}
local module = {}

type ConfettiType = "blast" | "rain"

--> Game functions

tweenLibrary.Rotate(script.purchase.wheel, 7)

local Camera = workspace.CurrentCamera
functions.changed(functions.create("NumberValue", Camera, "FOV", Camera.FieldOfView), function(Value)
	TweenService:Create(Camera, TweenInfo.new(0.15), {FieldOfView = Value}):Play()
end)


--> Settings opened 
function module.onSettingsToggled(openCallback, closeCallback)
	local isSettingsOpen = false

	if type(openCallback) == "function" then
		GuiService.MenuOpened:Connect(function(menuType)
			if menuType == Enum.CoreGuiType.EmotesMenu or
				menuType == Enum.CoreGuiType.Health or
				menuType == Enum.CoreGuiType.Backpack or
				menuType == Enum.CoreGuiType.PlayerList or
				menuType == Enum.CoreGuiType.Chat then
				return -- Exit the function if it's one of these known menus
			end
			isSettingsOpen = true
			openCallback()

		end)
	end
	if type(closeCallback) == "function" then
		GuiService.MenuClosed:Connect(function(menuType)
			if not isSettingsOpen then
				return -- Exit if settings weren't open
			end
			if menuType == Enum.CoreGuiType.EmotesMenu or
				menuType == Enum.CoreGuiType.Health or
				menuType == Enum.CoreGuiType.Backpack or
				menuType == Enum.CoreGuiType.PlayerList or
				menuType == Enum.CoreGuiType.Chat then
				return -- Exit the function if it's one of these known menus
			end
			isSettingsOpen = false
			closeCallback()
		end)
	end

end

--> Disable reset

--[[task.spawn(function()
	functions.attemptPcall(10, 1, function() StarterGui:SetCore("ResetButtonCallback", false) end)
end)--]]

--> Device

function DeviceFunctions()
	local Device = Player:GetAttribute("Device")
	for _,Gui in pairs(PlayerGui:GetDescendants()) do
		if Gui.Name == "ConsoleEnabled" then
			Gui.Visible = Device == "Console"
		elseif Gui.Name == "PCEnabled" then
			Gui.Visible = Device == "PC"
		elseif Gui.Name == "MobileEnabled" then
			Gui.Visible = Device == "Mobile"
		end
	end
end

if UserInputService.TouchEnabled then
	Player:SetAttribute("Device","Mobile")
elseif UserInputService.GamepadEnabled then
	Player:SetAttribute("Device","Console")
else
	Player:SetAttribute("Device","PC")
end
DeviceFunctions()

UserInputService.LastInputTypeChanged:Connect(function(Last)
	local NewDevice
	if Last == Enum.UserInputType.Gamepad1 then
		NewDevice = "Console"
	elseif Last == Enum.UserInputType.Keyboard or Last == Enum.UserInputType.MouseMovement or Last == Enum.UserInputType.MouseButton1 then
		NewDevice = "PC"
	elseif Last == Enum.UserInputType.Touch or UserInputService.TouchEnabled then
		NewDevice = "Mobile"
	end
	if Player:GetAttribute("Device") ~= NewDevice and NewDevice then
		Player:SetAttribute("Device", NewDevice)
		DeviceFunctions()
	end
end)

--> SFX


--> Mouse UI

function module.UpdateMouseOffset(Gui, Offset, StayWithinBounds)
	local Position = Vector2.new(Mouse.X, Mouse.Y)
	Offset = Offset or UDim2.new(0,0,0,0)
	
	if StayWithinBounds then
		local Size = Gui.AbsoluteSize
		local ViewportSize = Camera.ViewportSize
		local FromOffset = Vector2.new(Offset.X.Offset, Offset.Y.Offset)
		FromOffset += Vector2.new(Offset.X.Scale, Offset.Y.Scale) * ViewportSize
		Offset = UDim2.new(0,0,0,0)
		
		if Position.X + FromOffset.X + Size.X > ViewportSize.X then
			FromOffset *= Vector2.new(-1,0)
			FromOffset -= Size * Vector2.new(1,0)
		end
		if Position.Y + FromOffset.Y + Size.Y > ViewportSize.Y then
			FromOffset *= Vector2.new(0,-1)
			FromOffset -= Size * Vector2.new(0,1)
		end
		
		Position += FromOffset
	end
	
	Gui.Position = UDim2.new(0,Position.X,0,Position.Y) + Offset
end

functions.renderStepped(function()
	for Gui,Info in pairs(MouseOffset) do
		if not Gui.Parent then MouseOffset[Gui] = nil continue end
		module.UpdateMouseOffset(Gui, Info.Offset, Info.StayWithinBounds)
	end
end)

--> Sliders

local Sliders = {}

functions.renderStepped(function()
	local Mouse = Vector2.new(Mouse.X, Mouse.Y)
	for Pin,Info in pairs(Sliders) do
		if not Pin.Parent then Sliders[Pin] = nil continue end
		if not Info.Dragging then continue end
		local Percent = (Mouse - Info.Parent.AbsolutePosition) / Info.Parent.AbsoluteSize
		Pin.Position = UDim2.fromScale(math.clamp(Percent.X,Info.X.X, Info.X.Y), math.clamp(Percent.Y,Info.Y.X, Info.Y.Y))
	end
end)

UserInputService.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		for Pin,Info in pairs(Sliders) do
			Info.Dragging = false
			if Info.OnRelease then
				Info.OnRelease(Pin.Position)
			end
		end
	end
end)

--> Functions

module.Audio = UIEffects.Audio
Remotes.Audio.OnClientEvent:Connect(module.Audio)

function module.CreateAudio(Audio)
	Audio.SoundGroup = game.SoundService.SFX
	Audio.Parent = game.SoundService.SFX
end

function module.CreateSlider(Input, Pin, Parent, X, Y, OnDrag, OnRelease, StartPosition)
	local Information = {
		X = X,
		Y = Y,
		Parent = Parent,
		OnDrag = OnDrag,
		OnRelease = OnRelease,
	}
	Sliders[Pin] = Information
	Input.MouseButton1Down:Connect(function()
		Information.Dragging = true
	end)
	Pin.Position = StartPosition or Pin.Position
	if OnDrag then
		OnDrag(Pin.Position)
		Pin:GetPropertyChangedSignal("Position"):Connect(function()
			OnDrag(Pin.Position)
		end)
	end
end

function module.ToScale(Value : UDim2, Parent : Instance)
	local ParentSize,X,Y = Parent.AbsoluteSize,Value.X,Value.Y
	local ScreenGui = Parent:IsA("ScreenGui") and Parent or Parent:FindFirstAncestorOfClass("ScreenGui")
	local Inset = ScreenGui and (ScreenGui.IgnoreGuiInset and 36 or 0) or 0
	return UDim2.fromScale(X.Scale + (X.Offset/ParentSize.X), Y.Scale + ((Y.Offset+Inset)/ParentSize.Y))
end

function module.UIVisible(Gui)
	repeat
		if not Gui or (Gui:IsA("GuiObject") and not Gui.Visible) then return end
		Gui = Gui.Parent
	until Gui:IsA("LayerCollector")

	return Gui.Enabled
end

function module.ConnectButtonToInvite(Button)
	functions.onTrigger(Button, "PressDown", function()
		SocialService:PromptGameInvite(Player)
	end)
end

function module.ConnectButtonToPremium(Button)
	functions.onTrigger(Button, "PressDown", function()
		MarketplaceService:PromptPremiumPurchase(Player)
	end)
end

function module.ConnectButtonToFavorite(Button, PlaceId)
	functions.onTrigger(Button, "PressDown", function()
		AvatarEditorService:PromptSetFavorite(PlaceId, Enum.AvatarItemType.Asset, true)
	end)
end

function module.ConnectButtonToUnfavorite(Button, PlaceId)
	functions.onTrigger(Button, "PressDown", function()
		AvatarEditorService:PromptSetFavorite(PlaceId, Enum.AvatarItemType.Asset, false)
	end)
end

function module.ClearGuiObjects(GuiObject)
	for _,Child in pairs(GuiObject:GetChildren()) do
		if not Child:IsA("GuiObject") then continue end
		Child:Destroy()
	end
end

--> Shimmer

function module.CreateShimmer(Gui : GuiObject)
	local shimmer = Shimmer.new(Gui,2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1,false,1)
	shimmer:Play()
end

--module.CreateShimmer(script.Particle.Parent.Parent.Parent.ScreenGui.Particle)
--module.CreateShimmer(script.Particle.Parent.Parent.Parent.main.Settings)

for _, shimmer in CollectionService:GetTagged("shimmer") do
	module.CreateShimmer(shimmer)
end

CollectionService:GetInstanceAddedSignal("shimmer"):Connect(function(shimmer)
	module.CreateShimmer(shimmer)
end)

--> Particles

local Particles = {}
local ParticleEmitters = {}

local ParticleTemplate = {
	Color = ColorSequence.new(Color3.fromRGB(215, 248, 0), Color3.fromRGB(249, 154, 0)), -- White to Yellow gradient
	Transparency = NumberSequence.new(0, .8), -- Starts fully opaque and fades to 50% transparent
	Size = NumberSequence.new(60, 25), -- Starts small and grows a bit
	Squash = NumberSequence.new(1, 1),
	Image = "rbxassetid://7112395588",
	ZOffset = 2,
	Direction = 0,
	Lifetime = NumberRange.new(1.5, 3), -- Shorter lifetime for UI
	Rate = 6, -- Lower rate for subtle effect
	Speed = NumberRange.new(20, 30), -- Slower speed for floating effect
	Rotation = NumberRange.new(0, 360), -- Random rotation
	RotSpeed = NumberRange.new(-50, 50), -- Slow rotation speed
	SpreadAngle = NumberRange.new(360, 360), -- Full spread angle
	LockedToFrame = true,
	Enabled = true,
}

function Number(Min : Number, Max : Number)
	return RNG:NextNumber(Min, Max)
end

local function Range(value)
	if typeof(value) == "NumberRange" then
		return RNG:NextNumber(value.Min, value.Max)
	elseif typeof(value) == "Vector2" then
		return Vector2.new(RNG:NextNumber(value.X, value.Y), RNG:NextNumber(value.X, value.Y))
	end
	return nil
end

function Absolute(Vector : Vector2)
	return UDim2.fromOffset(Vector.X, Vector.Y)
end

function Sequence(Keypoints : SequenceKeypoints, Percent : Number)
	for Index,Keypoint in pairs(Keypoints) do
		local NextKeypoint = Keypoints[Index+1]
		if Keypoint.Time < Percent and NextKeypoint.Time >= Percent then
			local LocalPercent = (Percent - Keypoint.Time) / NextKeypoint.Time - Keypoint.Time
			local Value
			if typeof(Keypoint.Value) == "number" then
				Value = Keypoint.Value + (NextKeypoint.Value-Keypoint.Value) * LocalPercent
			else
				Value = Keypoint.Value:Lerp(NextKeypoint.Value, LocalPercent)
			end
			return Value
		end
	end
end

function module.ParticleEmitter(Gui : GuiObject, Information : Table)
	for Property,Value in pairs(ParticleTemplate) do
		Information[Property] = Information[Property] == nil and Value or Information[Property]
	end
	ParticleEmitters[Gui] = Information
	local Enabled = Gui:FindFirstChild("Enabled")
	if Enabled then
		Enabled:Destroy()
	end
	Enabled = functions.create("BoolValue", Gui, "Enabled", Information.Enabled)

	task.spawn(function()
		while Enabled.Parent do
			if Enabled.Value then
				module.Emit(Gui, 1)
				task.wait(1/Information.Rate)
			else
				task.wait(0.05)
			end
		end
	end)

	return Enabled
end

function module.Emit(Gui : GuiObject, EmitCount : Number)
	EmitCount = EmitCount or ParticleEmitters[Gui].Rate
	for _ = 1,EmitCount do
		local Information = {}
		for Property,Value in pairs(ParticleEmitters[Gui]) do
			Information[Property] = Range(Value) or Value
			if typeof(Value) == "NumberSequence" then
				local Keypoints = {}
				for _,Keypoint in pairs(Value.Keypoints) do
					local Envelope = RNG:NextNumber(-Keypoint.Envelope, Keypoint.Envelope)
					table.insert(Keypoints, NumberSequenceKeypoint.new(Keypoint.Time, Keypoint.Value + Envelope, 0))
				end
				Information[Property] = NumberSequence.new(Keypoints)
			end
		end

		local Velocity = Information.Lifetime * Information.Speed
		Information.Gui = Gui
		Information.StartTime = tick()
		Information.StartPosition = Absolute(Gui.AbsolutePosition)
		Information.Offset = Information.LockedToFrame and UDim2.fromScale(Number(0,1), Number(0,1)) or
			UDim2.fromOffset(Number(0,Gui.AbsoluteSize.X), Number(0,Gui.AbsoluteSize.Y))
		local Direction = Information.Direction
		Direction += Information.SpreadAngle
		Direction = Vector2.new(math.sin(math.rad(Direction)), math.sin(math.rad(Direction-90)))
		Information.Direction = Direction
		Information.EndPosition = UDim2.fromOffset(Velocity * Direction.X, Velocity * Direction.Y)

		local Particle = script.Particle:Clone()
		Particle.Image = Information.Image
		Particle.ZIndex = Information.ZOffset
		Particle.Rotation = Information.Rotation
		Particle.Position = module.ToScale(
			(Information.LockedToFrame and UDim2.new() or Information.StartPosition)
				+ Information.Offset, script.Parent)
		Particles[Particle] = Information

		Particle.Parent = Information.LockedToFrame and Gui or script.Parent
	end
end

functions.heartbeat(function()
	for Particle,Information in pairs(Particles) do
		if not Particle.Parent then Particles[Particle] = nil continue end
		task.spawn(function()
			local Percent = functions.clampOne((tick() - Information.StartTime) / Information.Lifetime)
			Particle.Position = module.ToScale(
				(Information.LockedToFrame and UDim2.new() or Information.StartPosition)
					+ Information.Offset + UDim2.new():Lerp(Information.EndPosition, Percent), script.Parent)
			Particle.Rotation += Information.RotSpeed/10
			Particle.ImageColor3 = Sequence(Information.Color.Keypoints, Percent)
			Particle.Squash.AspectRatio = Sequence(Information.Squash.Keypoints, Percent)
			Particle.ImageTransparency = Sequence(Information.Transparency.Keypoints, Percent)
			local Size = Sequence(Information.Size.Keypoints, Percent)
			Particle.Size = UDim2.fromOffset(Size, Size)

			if Percent >= 1 then
				Particle:Destroy()
				Particles[Particle] = nil
			end
		end)
	end
end)

--module.ParticleEmitter(script.Parent.Parent.ScreenGui.Particle, {})

--> UI

local ViewportSize = Vector2.new(1920, 1080)
local UIStrokes = {}

function UpdateStroke(UIStroke)
	local Information = UIStrokes[UIStroke]
	if not Information then return end
	if not UIStroke.Parent then return end
	Information.Updates += 1
	local Current = Information.Updates
	task.wait(0.2)
	if Current ~= Information.Updates then return end

	if Information.LayerCollector:IsA("BillboardGui") then
		local BillboardGuiSize = Information.LayerCollector.Size
		local Size = UIStroke.Parent.AbsoluteSize / Vector2.new(BillboardGuiSize.X.Scale,BillboardGuiSize.Y.Scale)
		Size /= 50
		Size *= Information.Thickness
		UIStroke.Thickness = math.clamp(math.max(Size.X,Size.Y), 1, math.huge)
	elseif Information.LayerCollector:IsA("ScreenGui") then
		local Size = Information.LayerCollector.AbsoluteSize / ViewportSize
		UIStroke.Thickness = Information.Thickness * math.min(Size.X,Size.Y)
	end
end

function module.UIStroke(UIStroke)
	local LayerCollector = UIStroke.Parent
	repeat
		if LayerCollector:IsA("LayerCollector") then break end
		LayerCollector = LayerCollector.Parent
	until not LayerCollector
	if not LayerCollector or not LayerCollector:IsA("LayerCollector") then return end
	UIStrokes[UIStroke] = {Thickness = UIStroke.Thickness, LayerCollector = LayerCollector, Updates = 0}
	UpdateStroke(UIStroke)
	UIStroke.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		UpdateStroke(UIStroke)
	end)
end

function module.CreateSearchBar(TextBox, ScrollingFrame, GetName, Additional)
	local function UpdateFrame(Frame, Ignore)
		if not Frame:IsA("GuiObject") then return end
		local Name = (not GetName and Frame.Name or GetName(Frame)):gsub("%W",""):lower()
		Frame.Visible = string.match(Name, TextBox.Text:gsub("%W",""):lower()) and (not Additional or Additional(Frame))
		if Ignore then return end
		functions.setCanvasSize(ScrollingFrame, ScrollingFrame:FindFirstChildWhichIsA("UIGridStyleLayout").AbsoluteContentSize)
	end

	local function UpdateSearch()
		for _,Frame in pairs(ScrollingFrame:GetChildren()) do
			UpdateFrame(Frame, true)
		end
		functions.setCanvasSize(ScrollingFrame, ScrollingFrame:FindFirstChildWhichIsA("UIGridStyleLayout").AbsoluteContentSize)
	end

	TextBox:GetPropertyChangedSignal("Text"):Connect(UpdateSearch)
	ScrollingFrame.ChildAdded:Connect(UpdateFrame)
	UpdateSearch()
end

function module.Confetti(Type : Confetti)
	module.Audio("Confetti")
	Confetti:Confetti(Type or "blast")
end

Remotes.Confetti.OnClientEvent:Connect(module.Confetti)


function module.FadeIn(tweenInfo)
	FadeEffect:GridSquaresIn(tweenInfo)
end

function module.FadeOut(tweenInfo)
	FadeEffect:GridSquaresOut(tweenInfo)
end

function module.Traverse(tweenInfo, delayTime, delayFunction)
	local delayTime = delayTime or 0.5
	
	FadeEffect:GridSquaresIn(tweenInfo)
	task.delay(tweenInfo.Time, function()
		if delayFunction then 
			delayFunction()
		end
		task.delay(delayTime, function()		
			FadeEffect:GridSquaresOut(tweenInfo)
		end)
	end)
	
	--[[task.spawn(function()
		traverseModule.GridSquaresIn()
		task.wait(1)
		
		TraverseUI.Size = UDim2.new(3,0,3,0)
		TraverseUI.Visible = true
		TweenService:Create(TraverseUI, TweenInfo.new(0.2), {Size = UDim2.new(3,0,0,0)}):Play()
		task.wait(1)
		TweenService:Create(TraverseUI, TweenInfo.new(0.2), {Size = UDim2.new(3,0,3,0)}):Play()
		task.wait(0.2)
		TraverseUI.Visible = false
	end)--]]
end

FadeEffect:Init()
Remotes.Traverse.OnClientEvent:Connect(module.Traverse)

local Tween = TweenInfo.new(0.15)
module.Frames = {}

function module.SetupFrames(Frames : {})
	module.Frames = Frames
	for Frame,Information in pairs(module.Frames) do
		Information.Start = Frame.Position
	end

end

function module.ShowUI()
	for Frame,Information in pairs(module.Frames) do
		TweenService:Create(Frame, Tween, {Position = Information.Start}):Play()
	end
end

function module.HideUI(frames)
	if frames and #frames > 0 then
		for Frame, Information in pairs(module.Frames) do
			if table.find(frames, Frame.Name) then
				TweenService:Create(Frame, Tween, {Position = Information.Start + Information.Offset}):Play()
			end
		end
	else
		for Frame, Information in pairs(module.Frames) do
			TweenService:Create(Frame, Tween, {Position = Information.Start + Information.Offset}):Play()
		end
	end
end

local isCutsceneActive = false
local CanOpen = true
local CanClose = true

function module.DisableOpen()
	CanOpen = false
end

function module.EnableOpen()
	CanOpen = true
end

function module.DisableClose()
	CanClose = false
end

function module.EnableClose()
	CanClose = true
end

function module.ActivateUI(Gui)
	if Gui:GetAttribute("Open") then
		module.CloseUI(Gui)
	else
		module.OpenUI(Gui)
	end
end

function module.OpenUI(Gui)
	if isCutsceneActive then
		return
	end
	
	if not CanOpen then return end
	module.CloseAllUI(Gui)
	Gui:SetAttribute("Open", true)
end

function module.CloseUI(Gui)
	if not CanClose then return end
	Gui:SetAttribute("Open", false)
end

function module.CloseAllUI(Gui)
	for Frame,_ in pairs(Frames) do
		if Frame == Gui then continue end
		Frame:SetAttribute("Open", false)
	end
end

function module.SetCutsceneActive(active)
	isCutsceneActive = active
end

function module.PromptPurchase(id : number | string, productType : "GamePass" | "Product")
	local idToUse = id

	if type(id) == "string" then
		if productType == "GamePass" then
			idToUse = settingsConfig.GamePassId[id]
		elseif productType == "Product" then
			idToUse = settingsConfig.DevProductId[id]
		else
			warn(productType)
		end

		if not idToUse then
			error("Invalid product name: " .. id)
		end
	end
	
	if productType == "Product" then
		pcall(function()
			MarketplaceService:PromptProductPurchase(Player, idToUse)
			PurchaseUI.Parent = script.Parent	
		end)
	elseif productType == "GamePass" then
		pcall(function()
			MarketplaceService:PromptGamePassPurchase(Player, idToUse)
			PurchaseUI.Parent = script.Parent	
		end)
	end

end

Remotes.PromptPurchase.OnClientEvent:Connect(module.PromptPurchase)

function module.CreateProduct(Object, Id, Type)
	if Type == "Product" then
		Products[Object] = Id
	elseif Type == "GamePass" then
		GamePasses[Object] = Id
	end
end

function module.IsMouseHovering(Gui)
	return table.find(PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y), Gui)
end

function module.IsWithinBounds(Gui, Position)
	return table.find(PlayerGui:GetGuiObjectsAtPosition(Position), Gui)
end

function module.GetMousePosition()
	return UserInputService:GetMouseLocation()
end
local Tooltips = {}

function module.CreateTooltip(Gui, Text)
	Tooltips[Gui] = Text
end

functions.heartbeat(function()
	if Player:GetAttribute("Device") ~= "PC" then return end
	for _,Gui in pairs(PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)) do
		if Tooltips[Gui] and module.UIVisible(Gui) then
			Tip.Label.Text = Tooltips[Gui]
			TipDefine.Text = Tooltips[Gui]
			Tip.Size = UDim2.new(0, TipDefine.TextBounds.X+16, 0.05, 0)
			module.UpdateMouseOffset(Tip)
			Tip.Visible = true
			return
		end
	end
	Tip.Visible = false
end)

local Buttons = {}

function module.CreateButton(Button, Effect)
	Effect = Effect or 1
	UIEffects["ButtonEffects"..Effect](Button)
	Button.MouseButton1Down:Connect(function()
		functions.createTrigger(Button, "PressDown")
	end)

	Button.MouseButton1Up:Connect(function()
		functions.createTrigger(Button, "PressUp")
	end)

	functions.onTrigger(Button, "PressDown", function()
		if Buttons[Button] then
			module.ActivateUI(Buttons[Button])
		end
		if Button.Name == "Close" then
			Button.Parent:SetAttribute("Open", false)
		end
		module.PromptPurchase(Button)
	end)
end

function module.CreateFrame(Frame, Effect)
	Effect = Effect or 1
	Frames[Frame] = Effect
	UIEffects["FrameEffects"..Effect](Frame)
end

function module.ConnectButtonToFrame(Button, Frame)
	Buttons[Button] = Frame
end

--[[function module.MouseOffset(Frame, Offset, StayWithinBounds)
	MouseOffset[Frame] = {Offset = Offset, StayWithinBounds = StayWithinBounds}
end

module.MouseOffset(Tip, UDim2.new(0,20,0,0), true)--]]

local Rainbows = {}

-- property = backgroundcolor3
function module.Rainbow(Frame, Property, Speed, Saturation, Value)
	Speed = Speed and 9/Speed or 3
	Saturation = Saturation or 1
	Value = Value or 1
	Rainbows[Frame] = {Property = Property, Speed = Speed, Saturation = Saturation, Value = Value}
end

functions.heartbeat(function()
	for Frame,Info in pairs(Rainbows) do
		Frame[Info.Property] = Color3.fromHSV(time()%Info.Speed/Info.Speed, Info.Saturation, Info.Value)
	end
end)

--module.Rainbow(script.Parent.Parent.ScreenGui.Color, "BackgroundColor3")

local Values = {}

function module.CreateValue(TextLabel, Format)
	Format = Format or "%s"
	local Value = TextLabel:FindFirstChildOfClass("NumberValue") or Instance.new("NumberValue", TextLabel)
	if Values[Value] then Values[Value]:Disconnect() end

	TextLabel.Text = Format:format(functions.abbreviate(math.round(Value.Value), "K"))
	Values[Value] = Value.Changed:Connect(function()
		TextLabel.Text = Format:format(functions.abbreviate(math.round(Value.Value), "K"))
	end)
end

function module.SetValue(TextLabel, Number)
	local Value = TextLabel:FindFirstChildOfClass("NumberValue")
	if not Values[Value] then return end

	Value.Value = Number
end

function module.TweenValue(TextLabel, Number)
	local Value = TextLabel:FindFirstChildOfClass("NumberValue")
	if not Values[Value] then return end

	TweenService:Create(Value, TweenInfo.new(0.2), {Value = Number}):Play()	
end

function module.GetKeybind(KeyCode)
	if not KeyBinds[KeyCode] then return end
	table.sort(KeyBinds[KeyCode], function(A,B) return A.Priority > B.Priority end)

	for _,Keybind in pairs(KeyBinds[KeyCode]) do
		if not module.UIVisible(Keybind.Button) then continue end
		return Keybind
	end
end

function module.ConnectKeybind(Button, KeyCode, Priority)
	if not KeyBinds[KeyCode] then KeyBinds[KeyCode] = {} end
	table.insert(KeyBinds[KeyCode], {Button = Button, Priority = Priority or 1})
	return UserInputService:GetStringForKeyCode(KeyCode)
end

PromptUI.keybind.PCEnabled.Text = module.ConnectKeybind(PromptUI.keybind, PromptKeybind)
PromptUI.keybind.ConsoleEnabled.Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonX)
module.ConnectKeybind(PromptUI.keybind, Enum.KeyCode.ButtonX)

function module.PurchaseFinished(PromptPlayer, _, Bought)
	if PromptPlayer ~= Player and PromptPlayer ~= Player.UserId then return end
	PurchaseUI.Parent = script
	if not Bought then return end
	module.Confetti()
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(module.PurchaseFinished)
MarketplaceService.PromptProductPurchaseFinished:Connect(module.PurchaseFinished)

--> Hitboxes

local Hitboxes = {}
local Prompt

function module.PromptHitbox(Hitbox)
	Prompt = Hitbox
	functions.createTrigger(Hitbox, "Touched")
	PromptUI.Adornee = Hitbox
	PromptUI.label.Text = "~" .. Hitbox.Label.Value .. "~"
	PromptUI.Size = UDim2.new(0, 0, 0, 0)
	PromptUI.Enabled = true
	TweenService:Create(PromptUI, TweenInfo.new(0.05), {Size = UDim2.new(2.75, 0, 2.75, 0)}):Play()
end

function module.RemovePromptHitbox(Hitbox)
	functions.createTrigger(Hitbox, "TouchEnded")
	if Prompt ~= Hitbox then return end
	Prompt = nil
	TweenService:Create(PromptUI, TweenInfo.new(0.05), {Size = UDim2.new(0, 0, 0, 0)}):Play()
	task.wait(0.03)
	if Prompt then return end
	PromptUI.Enabled = false
end

--[[function module.CreateHitbox(Hitbox)
	if not Hitbox:IsA("BasePart") then return end

	if Hitboxes[Hitbox] then Hitboxes[Hitbox]:Disconnect() end
	Hitboxes[Hitbox] = Hitbox:WaitForChild("Label").Changed:Connect(function()

		if Prompt ~= Hitbox then return end
		PromptUI.label.Text = "~" .. Hitbox.Label.Value .. "~"
	end)
end

functions.childAdded(workspace, function(Child)
	if Child.Name ~= "Hitboxes" then return end
	functions.descendantAdded(Child, module.CreateHitbox)
end)--]]

functions.heartbeat(function()
	local Success, Character, HRP = functions.character(Player)
	if not Success then return end
	local Parts = workspace:GetPartBoundsInBox(HRP.CFrame, HRP.Size)
	if Prompt and table.find(Parts, Prompt) then return end

	for _, Part in pairs(Parts) do
		if not Hitboxes[Part] then continue end
		module.PromptHitbox(Part)
		return
	end

	if Prompt then
		module.RemovePromptHitbox(Prompt)
	end
end)

function InputChanged(Input, Chatted)
	if Chatted then return end

	local Keybind = module.GetKeybind(Input.KeyCode)
	if Keybind then
		if Input.KeyCode == PromptKeybind and not Prompt then return end
		local Pressed = Input.UserInputState == Enum.UserInputState.Begin
		functions.createTrigger(Keybind.Button, Pressed and "PressDown" or "PressUp")
	end
end

UserInputService.InputBegan:Connect(InputChanged)
UserInputService.InputEnded:Connect(InputChanged)

functions.onTrigger(PromptUI.keybind, "PressDown", function()
	if not Prompt then return end

	functions.createTrigger(Prompt, "Pressed")
	module.PromptPurchase(Prompt)
end)

--> Leaves

local WindblowingTag = "Windblown"
local WindblowingTable = {}

function module.Windblow(Object, Multiplier, Speed)
	Multiplier = Multiplier or Object:GetAttribute("WindblowMultiplier") or 1
	Speed = Speed or Object:GetAttribute("WindblowSpeed") or 3
	WindblowingTable[Object] = {Multiplier = Multiplier, Speed = Speed, CFrame = Object:GetPivot(), Last = 0}
end

functions.heartbeat(function()
	for Object,Info in pairs(WindblowingTable) do
		local Offset = Info.CFrame * CFrame.new(Vector3.new(Number(-1,1),Number(-1,1),Number(-1,1)) * Info.Multiplier)
		if tick() - Info.Last > 1 / Info.Speed then
			Info.Offset = Offset
			Info.Last = tick()
		else
			Offset = Info.Offset
		end
		Object:PivotTo(Object:GetPivot():lerp(Offset, 0.002*Info.Speed))
	end
end)

CollectionService:GetInstanceAddedSignal(WindblowingTag):Connect(function(Windblow)
	module.Windblow(Windblow)
end)
for _,Windblow in pairs(CollectionService:GetTagged(WindblowingTag)) do
	module.Windblow(Windblow)
end

--> Notification

local Colors = {
	["Red"] = Color3.fromRGB(255,60,60),
	["Orange"] = Color3.fromRGB(255,150,60),
	["Yellow"] = Color3.fromRGB(255,230,60),
	["Green"] = Color3.fromRGB(60,255,60),
	["Blue"] = Color3.fromRGB(60,180,255),
	["Magenta"] = Color3.fromRGB(255,100,255),
}

function module.Notify(Text, TextColor, Type : number)
	TextColor = Colors[TextColor] or TextColor or Color3.fromRGB(255,255,255)
	Type = Type or 1

	if not Text then 
		warn("No text given")
	end

	local NewNotification = Assets.GUI.Notifications[Type]:Clone()
	NewNotification.label.Text = Text
	NewNotification.label.TextColor3 = TextColor


	UIEffects[`NotificationEffects{Type}`](NewNotification)
end

Remotes.Notify.OnClientEvent:Connect(module.Notify)--]]

--[[task.spawn(function()
while wait(math.random(0,10)/10) do
	module.Notify("Hello, how are you?")
end
end) --]]


return module