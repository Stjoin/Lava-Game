--> Variables

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local PlayerScripts = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts")

local library = require(game:GetService("ReplicatedStorage").Library) 
local effects = require(library.PlayerGui.ui_manager.ui_functions.effects)

local functions = library.Functions
local dataService = library.DataService

local UIFunctions = library.UIFunctions
local Main = library.Main

--> UI

UIFunctions.SetupFrames( {
	[Main.Left] = {Offset = UDim2.new(-0.4,0,0,0)},
	[Main.Right] = {Offset = UDim2.new(0.4,0,0,0)},
	[Main.Boosts] = {Offset = UDim2.new(0,0,0.4,0)},
})

function DescendantAdded(Button)
	if not Button:IsA("GuiButton") then return end
	UIFunctions.CreateButton(Button, Button:GetAttribute("Effect"))
end

functions.childAdded(library.PlayerGui, function(LayerCollector)
	if not LayerCollector:GetAttribute("StarterGui") then return end
	functions.descendantAdded(LayerCollector, DescendantAdded)
end)

local frames = library.Main.frames
for _, frame in frames:GetChildren() do
	UIFunctions.CreateFrame(frame, frame:GetAttribute("Effect") or 1)
end

UIFunctions.ConnectButtonToFrame(Main.Left.Buttons.B.Pets, Main.frames.Pets)
UIFunctions.ConnectButtonToFrame(Main.Left.Buttons.A.Daily, Main.frames.Daily)
UIFunctions.ConnectButtonToFrame(Main.Left.Buttons.A.Shop, Main.frames.Shop)
UIFunctions.ConnectButtonToFrame(Main.Left.Buttons.B.Invite, Main.frames.Invite)

--> Currencies

if not dataService.clientReplica then
	dataService:RequestData()
end

dataService:GetDataAsync():await()

local cashIndicator = library.Main.Left.Coins
UIFunctions.CreateValue(cashIndicator.amount_text)
dataService:ConnectToSignal(library.LocalPlayer, "Coins", function(new_value)
	UIFunctions.TweenValue(cashIndicator.amount_text, new_value)
	effects.CurrencyChangedTween(cashIndicator)
end)

--> Opening roblox settings

UIFunctions.onSettingsToggled(
	function()
		script.Parent.onLeave.Visible = true
		UIFunctions.HideUI()
	end,
	function()
		script.Parent.onLeave.Visible = false
		UIFunctions.ShowUI() 
	end
)


--> Click Effect

local TweenService = game:GetService("TweenService")
local Mouse = library.LocalPlayer:GetMouse()

UserInputService.InputBegan:Connect(function(Input)
	local InputType = Input.UserInputType
	if InputType == Enum.UserInputType.MouseButton1 or InputType == Enum.UserInputType.Touch then
		local Click = script.ClickEffect:Clone()
		Click.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
		Click.Visible = true
		Click.Parent = script.Parent
		TweenService:Create(Click, TweenInfo.new(0.1), {Size = UDim2.new(0,25,0,25), BackgroundTransparency = 1}):Play()
		task.wait(0.15)
		Click:Destroy()
	end
end)

--> Mobile Device
local infinityImage = library.PlayerGui.ui_manager:WaitForChild("InfinityImage")
local device = library.LocalPlayer:GetAttribute("Device")

if device and device == "Mobile" then
	infinityImage:SetAttribute("enabled", true)
end

UserInputService.InputBegan:Once(function()
	infinityImage:SetAttribute("enabled", false)
end)

--]]
print("UI LOADED")
-->