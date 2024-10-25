-----: Variables
local isServer = game:GetService("RunService"):IsServer()
local isClient = game:GetService("RunService"):IsClient()
local runService = game:GetService("RunService")

local module = {}

-----: Module Variables

module.Players = game:GetService("Players")
module.ReplicatedStorage = game:GetService("ReplicatedStorage")
module.AssetService = game:GetService("AssetService")
module.BadgeService = game:GetService("BadgeService")
module.CollectionService = game:GetService("CollectionService")
module.ContextActionService = game:GetService("ContextActionService")
module.ControllerService = game:GetService("ControllerService")
module.FriendService = game:GetService("FriendService")
module.GamepadService = game:GetService("GamepadService")
module.GamePassService = game:GetService("GamePassService")
module.GroupService = game:GetService("GroupService")
module.GuiService = game:GetService("GuiService")
module.HapticService = game:GetService("HapticService")
module.HttpService = game:GetService("HttpService")
module.InsertService = game:GetService("InsertService")
module.KeyboardService = game:GetService("KeyboardService")
module.LocalizationService = game:GetService("LocalizationService")
module.LoginService = game:GetService("LoginService")
module.LogService = game:GetService("LogService")
module.MarketplaceService = game:GetService("MarketplaceService")
module.MouseService = game:GetService("MouseService")
module.MessagingService = game:GetService("MessagingService")
module.NotificationService = game:GetService("NotificationService")
module.PathfindingService = game:GetService("PathfindingService")
module.PhysicsService = game:GetService("PhysicsService")
module.PointsService = game:GetService("PointsService")
module.RunService = game:GetService("RunService")
module.SoundService = game:GetService("SoundService")
module.TeleportService = game:GetService("TeleportService")
module.TextService = game:GetService("TextService")
module.TweenService = game:GetService("TweenService")
module.TouchInputService = game:GetService("TouchInputService")
module.UserInputService = game:GetService("UserInputService")
module.VRService = game:GetService("VRService")
module.PolicyService = game:GetService("PolicyService")
module.ProximityPromptService = game:GetService("ProximityPromptService")
module.ContentProvider = game:GetService("ContentProvider")
module.AnalyticsService = game:GetService("AnalyticsService")
module.PermissionsService = game:GetService("PermissionsService")
module.SocialService = game:GetService("SocialService")
module.Debris = game:GetService("Debris")
module.TextChatService = game:GetService("TextChatService")
module.StarterGui = game:GetService("StarterGui")
module.AvatarEditorService = game:GetService("AvatarEditorService")

if isServer then
	module.ServerScriptService = game:GetService("ServerScriptService")
	module.ServerStorage = game:GetService("ServerStorage")
	module.ServerPackages = game.ReplicatedStorage.ServerPackages
	module.ServerModules = game.ServerScriptService.ServerModules
	--module.TycoonManager = require(game.ServerScriptService.ServerModules.tycoon_manager)
	
else
	module.LocalPlayer = module.Players.LocalPlayer
	module.PlayerGui = module.LocalPlayer.PlayerGui
	module.PlayerScripts = module.LocalPlayer.PlayerScripts
	module.Main = module.PlayerGui:WaitForChild("main")
	module.Frames = module.PlayerGui:WaitForChild("main"):WaitForChild("frames")

	module.UIFunctions = require(module.PlayerGui:WaitForChild("ui_manager").ui_functions)
	module.UIEffects = require(module.PlayerGui:WaitForChild("ui_manager").ui_functions.effects)
	
	module.ClientPackages = game.ReplicatedStorage.ClientPackages
	module.ClientModules = module.PlayerScripts.ClientModules
	
	module.Character = module.LocalPlayer.Character
	--module.HumanoidRootPart = module.Character.HumanoidRootPart
	
	module.LocalPlayer.CharacterAdded:Connect(function(Character)
		module.Character = Character
		--module.HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	end)
end

module.DataService = require(script.Shared.data_service)

module.Configurations = require(script.Configurations)
module.Functions = require(script.Packages.Functions)
module.Trove = require(script.Packages.Trove)
module.Shared = require(script.Shared)
module.Packages = require(script.Packages)

module.Remotes = module.ReplicatedStorage.Networking.Remotes
module.Bindables = module.ReplicatedStorage.Networking.Bindables

module.Assets = module.ReplicatedStorage.Assets

return module 