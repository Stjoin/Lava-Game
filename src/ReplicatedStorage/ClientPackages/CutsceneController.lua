local TweenService = game:GetService("TweenService")
local DefualtCamera = workspace.CurrentCamera

local CutsceneModule = {}

function CutsceneModule.GetCameraCFrame()
	return DefualtCamera.CFrame
end

function CutsceneModule.PrimeCamera()
	DefualtCamera.CameraType = Enum.CameraType.Scriptable
	game.Players.LocalPlayer.Character.PrimaryPart.Anchored = true
end
function CutsceneModule.SetCamera(Cam)
	DefualtCamera.CFrame = Cam.CFrame
end

--[[
    TweenCamera function
    Tweens the camera to the given CFrame or Part.

    Parameters:
    - Cam: The target CFrame or Part for the camera to tween to.
    - Speed: The speed of the tween.
    - EasingStyle: The easing style of the tween.
    - EasingDirection: The easing direction of the tween.
--]]
function CutsceneModule.TweenCamera(Cam, Speed, EasingStyle, EasingDirection)
	local targetCFrame

	-- Check if Cam is a CFrame
	if typeof(Cam) == "CFrame" then
		targetCFrame = Cam
		-- Check if Cam is a Part
	elseif typeof(Cam) == "Instance" and Cam:IsA("BasePart") then
		targetCFrame = Cam.CFrame
	else
		error("Cam must be a CFrame or a BasePart")
	end

	-- Create and play the tween
	local tweenInfo = TweenInfo.new(Speed, EasingStyle, EasingDirection)
	local tween = TweenService:Create(workspace.CurrentCamera, tweenInfo, {CFrame = targetCFrame})
	tween:Play()
end

function CutsceneModule.TweenFOV(Amount, Speed, EasingStyle, EasingDirection)
	local TFOV = TweenService:Create(DefualtCamera, TweenInfo.new(Speed, EasingStyle, EasingDirection), {FieldOfView = Amount}):Play()
end
function CutsceneModule.ResetCamera()
	DefualtCamera.CameraType = Enum.CameraType.Custom
	game.Players.LocalPlayer.Character.PrimaryPart.Anchored = false
end
function CutsceneModule.ResetFOV(Amount)
	DefualtCamera.FieldOfView = Amount
end

return CutsceneModule
