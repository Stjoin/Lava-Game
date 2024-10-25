-->
local library = require(game:GetService("ReplicatedStorage").Library) 
local TweenService = library.TweenService
local musicSoundService = library.SoundService.Music

local random = Random.new()

local currentSong = nil
local intervalSong = nil
local isPlayingIntervalSong = false
--> 

local function tweenVolume(sound, targetVolume, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(sound, tweenInfo, {Volume = targetVolume})
	tween:Play()
	return tween
end

local function initializeDefaultVolumes()
	for _, song in ipairs(musicSoundService:GetChildren()) do
		if song:IsA("Sound") then
			if not song:GetAttribute("DefaultVolume") then
				song:SetAttribute("DefaultVolume", song.Volume)
			end
		end
	end
end

local function getRandomSong()
	local songs = musicSoundService:GetChildren()
	local availableSongs = {}

	for _, song in ipairs(songs) do
		if song:IsA("Sound") and song ~= currentSong and song ~= intervalSong then
			table.insert(availableSongs, song)
		end
	end

	if #availableSongs > 0 then
		local randomIndex = random:NextInteger(1, #availableSongs)
		return availableSongs[randomIndex]
	end

	return nil
end

local function stopCurrentSong(callback)
	if currentSong then
		local defaultVolume = currentSong:GetAttribute("DefaultVolume") or 1
		local tween = tweenVolume(currentSong, 0, 1)
		tween.Completed:Once(function()
			currentSong:Stop()
			currentSong.Volume = defaultVolume -- Reset to default volume
			currentSong = nil
			if callback then
				callback()
			end
		end)
	elseif callback then
		callback()
	end
end


local function playIntervalSong()
	if not intervalSong then
		warn("IntervalSong not found in Music service.")
		return
	end

	isPlayingIntervalSong = true
	stopCurrentSong(function()
		currentSong = intervalSong
		local defaultVolume = intervalSong:GetAttribute("DefaultVolume") or 1
		intervalSong.Volume = 0
		intervalSong.Looped = true
		intervalSong:Play()
		tweenVolume(intervalSong, defaultVolume, 1)
	end)
end

local function stopIntervalSong()
	if isPlayingIntervalSong then
		isPlayingIntervalSong = false
		playSong()
	end
end

function playSong()	
	stopCurrentSong(function()
		local selectedSong = getRandomSong()
		if not selectedSong then
			warn("No available songs to play.")
			return
		end

		local defaultVolume = selectedSong:GetAttribute("DefaultVolume") or 1
		currentSong = selectedSong

		selectedSong.Volume = 0
		selectedSong:Play()
		tweenVolume(selectedSong, defaultVolume, 1)

		selectedSong.Ended:Once(function()
			task.delay(0.2, playSong)
		end)
	end)
end

initializeDefaultVolumes()
task.wait(2)

intervalSong = musicSoundService:FindFirstChild("IntervalSong")
playSong()

library.Remotes.PlayIntervalSong.OnClientEvent:Connect(playIntervalSong)
library.Remotes.StopIntervalSong.OnClientEvent:Connect(stopIntervalSong)