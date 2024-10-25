local module = {}
local abbreviations = {"K","M","B","T","Q","QN","S","SP","O","N","D","U","DD","TD","QT","QD","SD","ST"}
local key = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
local names = require(script.names)

local settingsConfig = require(script.Parent.Parent.Configurations.settings)
local dataService = require(script.Parent.Parent.Shared.data_service)

local types = {
	["boolean"] = "BoolValue",
	["number"] = "NumberValue",
	["string"] = "StringValue",
}
local rng = Random.new()
local debris = game:GetService("Debris")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local marketplaceService = game:GetService("MarketplaceService")
local collectionService = game:GetService("CollectionService")

function module.abbreviate(number, firstAbbreviation, lastAbbreviation)
	firstAbbreviation = table.find(abbreviations, (firstAbbreviation or ""):upper())
	lastAbbreviation = table.find(abbreviations, (lastAbbreviation or ""):upper()) or #abbreviations
	number = ("%f"):format(number)
	number = number:sub(0, #number-7)

	if firstAbbreviation then
		local abbreviation = math.clamp(math.floor((#number-1)/3), firstAbbreviation, lastAbbreviation)

		if #number > abbreviation * 3 then
			local left = number:sub(0, #number - abbreviation * 3)
			local right = ""

			if #left < 3 then
				right = "."..number:sub(#left+1,#left+(3-#left))
			end

			number = tonumber(left..right)..abbreviations[abbreviation].."+"
		end
	end

	local left, num, right = number:match('^([^%d]*%d)(%d*)(.-)$')
	number = left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right

	return number
end

function module.commas(value, useAltCommas)
	local wholeComponent = tostring(math.floor(math.abs(value)))
	local decimalComponent = tostring(value - math.floor(value))
	local comma = useAltCommas and "." or ","
	local period = useAltCommas and "," or "."
	local newString = ""
	local digits = 0
	for idx = #wholeComponent, 1, -1 do
		newString = wholeComponent:sub(idx, idx) .. newString
		digits += 1
		if digits == 3 and idx ~= 1 then
			newString = comma .. newString
			digits = 0
		end
	end
	if decimalComponent ~= "0" and #decimalComponent > 2 then
		newString = newString .. period .. decimalComponent:sub(3)
	end
	if math.sign(value) == -1 then
		newString = "-" .. newString
	end
	return newString
end

local timeFormats = {
	{":", ":", ":", ":", ":", ""},
	{"y", "mo", "d", "h", "m", "s"},
	{" years ", " months ", " days ", " hours ", " minutes ", " seconds"}
}

local timeSeconds = {31536000, 2628028.8, 86400, 3600, 60}

function module.timer(seconds, format, forcePlacement, keep)
	format = timeFormats[format or 1]
	local function get(placement)
		local unit = math.floor(seconds/timeSeconds[placement])
		seconds, keep = seconds % timeSeconds[placement], keep or placement == forcePlacement or unit > 0
		return keep and ("%02i"):format(unit)..format[placement] or ""
	end

	return get(1)..get(2)..get(3)..get(4)..get(5)..tostring(100+math.floor(seconds*100)/100):match("1(.+)")..format[6]
end

function module.removeNumbers(string)
	return string.gsub(string, "%d+", "")
end

function module.roundToDecimals(number)
	return math.floor(number * 10) / 10
end

function module.timePassed(start)
	return os.time() - start
end

function module.incrementZIndex(gui, amount)
	local descendants = gui:GetDescendants()
	table.insert(descendants, gui)
	for _,descendant in pairs(descendants) do
		if not descendant:IsA("GuiObject") then continue end
		descendant.ZIndex += amount
	end
end

local cachedProductInfo = {}
local emptyProductInfo = {
	Description = "error",
	Name = "error",
	IconImageAssetId = 0,
	PriceInRobux = "nil",
}


function module.productInfo(id : number | string, productType : "GamePass" | "Product")
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

	local cached = cachedProductInfo[idToUse .. productType]
	if not cached then
		module.attemptPcall(5, 0.5, function()
			local Info = marketplaceService:GetProductInfo(idToUse, Enum.InfoType[productType])
			cachedProductInfo[idToUse .. productType] = Info
			cached = Info
		end)
	end
	return cached or emptyProductInfo
end

function module.serverTouched(part, touchedFunction, debounceTime)
	debounceTime = debounceTime or 1
	local debounce = false
	part.Touched:Connect(function(hit)
		if debounce then return end
		local player = players:GetPlayerFromCharacter(hit.Parent)
		if player then
			debounce = true
			touchedFunction(player, hit.Parent)
			task.delay(debounceTime, function()
				debounce = false
			end)
		end
	end)
end


function module.touched(part, player, touchedFunction)
	part.Touched:Connect(function(touched)
		if touched.Name ~= "HumanoidRootPart" then return end
		if players:GetPlayerFromCharacter(touched.Parent) ~= player then return end
		touchedFunction()
	end)
end

function module.touchEnded(part, player, touchedEndedFunction)
	part.TouchEnded:Connect(function(touched)
		if touched.Name ~= "HumanoidRootPart" then return end
		if players:GetPlayerFromCharacter(touched.Parent) ~= player then return end
		touchedEndedFunction()
	end)
end

function module.childrenChanged(instance, changedFunction)
	task.spawn(changedFunction)
	instance.ChildRemoved:Connect(changedFunction)
	instance.ChildAdded:Connect(changedFunction)
end

function module.attributeChanged(instance, attributeChangedFunction)
	instance.AttributeChanged:Connect(attributeChangedFunction)
	for attribute, _ in pairs(instance:GetAttributes()) do
		task.spawn(function()
			attributeChangedFunction(attribute)
		end)
	end
end

function module.tagInstanceAdded(tag, tagInstanceAddedFunction )
	for _, instance in collectionService:GetTagged(tag) do
		tagInstanceAddedFunction(instance)
	end	
	collectionService:GetInstanceAddedSignal(tag):Connect(tagInstanceAddedFunction)
end

function module.childAdded(instances, childAddedFunction)
	local function connectChildAdded(instance, childAddedFunction)
		instance.ChildAdded:Connect(childAddedFunction)
		for _, child in pairs(instance:GetChildren()) do
			task.spawn(function()
				childAddedFunction(child)
			end)
		end
	end
	if type(instances) == "table" then
		for _, instance in instances do
			connectChildAdded(instance, childAddedFunction)
		end
	else
		-- If instances is a single instance
		connectChildAdded(instances, childAddedFunction)
	end
end

function module.descendantAdded(instance, descendantAddedFunction)
	instance.DescendantAdded:Connect(descendantAddedFunction)
	for _,descendant in pairs(instance:GetDescendants()) do
		task.spawn(function()
			descendantAddedFunction(descendant)
		end)
	end
end

function module.clampPositive(num)
	return math.clamp(num, 0, math.huge)
end

function module.clampNegative(num)
	return math.clamp(num, -math.huge, 0)
end

function module.clampOne(num)
	return math.clamp(num, 0, 1)
end

function module.createTrigger(instance, name)
	debris:AddItem(module.create("StringValue", instance, name), 1)
end

function module.onTrigger(instance, name : "PressDown", triggerFunction)
	local connection = instance.ChildAdded:Connect(function(child)
		if child.Name ~= name then return end
		triggerFunction()
	end)

	return connection
end

function module.findFirstAncestorOfChild(instance, parent)
	repeat
		if instance.Parent == parent then return instance end
		instance = instance.Parent
	until not instance
end

function module.findFirstChildWithTimeout(parent, childName)
	if not parent then
		warn("Failed to grab " .. childName .. " (parent is nil)")
		return nil
	end

	local startTime = os.clock()
	while os.clock() - startTime <= 5 do
		local child = parent:FindFirstChild(childName)
		if child then
			return child
		end
		task.wait(0.1)
	end

	warn("Failed to grab " .. childName)
	return nil
end


function module.getRandomInPart(part, offset)
	local MinX, MaxX = part.Position.X - part.Size.X/2, part.Position.X + part.Size.X/2
	local MinZ, MaxZ = part.Position.Z - part.Size.Z/2, part.Position.Z + part.Size.Z/2


	local RNG = Random.new()
	local RandomX = RNG:NextNumber(MinX, MaxX)
	local RandomZ = RNG:NextNumber(MinZ, MaxZ)

	return Vector3.new(RandomX, part.Position.Y, RandomZ)
end


function module.weld(part0, part1)
	local weld = Instance.new("Weld")
	weld.C0 = part0.CFrame:ToObjectSpace(part1)
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = part1
end

function module.DeepCopy(duping)
	local duped = {}
	for index,value in pairs(duping) do
		if type(value) == "table" then
			value = module.DeepCopy(value)
		end
		duped[index] = value
	end
	return duped
end

local faces = {
	["Front"] = {"X", "Y"},
	["Back"] = {"X", "Y"},
	["Left"] = {"Z", "Y"},
	["Right"] = {"Z", "Y"},
	["Top"] = {"X", "Z"},
	["Bottom"] = {"X", "Z"},
}

function module.flipBook(instance, framerate, grid, image)
	task.spawn(function()
		local texture = instance:IsA("Texture")
		local image = instance:IsA("ImageLabel") or instance:IsA("ImageButton")

		if texture then
			instance.StudsPerTileU = instance.Parent.Size[faces[module.fromEnum(instance.Face)][1]]*grid
			instance.StudsPerTileV = instance.Parent.Size[faces[module.fromEnum(instance.Face)][2]]*grid
		elseif image then
			instance.ScaleType = Enum.ScaleType.Fit
			instance.ImageRectSize = instance.AbsoluteSize
		end

		local frame = 0

		while instance.Parent do
			frame = frame % (grid ^ 2) + 1
			local row = math.ceil(frame/grid)
			local column = frame - ((row - 1) * grid)
			local offset = Vector2.new(column - 1, row - 1)

			if texture then
				instance.OffsetStudsU = instance.StudsPerTileU / grid * offset.X
				instance.OffsetStudsV = instance.StudsPerTileV / grid * offset.Y
			elseif image then
				instance.ImageRectOffset = instance.ImageRectSize * offset
			end
			task.wait(1/framerate)
		end
	end)
end

function module.emitAttachment(attachment)
	local descendants = attachment:GetDescendants()
	table.insert(descendants, attachment)

	for _,descendant in pairs(descendants) do
		local emitIntervals = descendant:GetAttribute("EmitIntervals") or 1
		local emitRepeats = descendant:GetAttribute("EmitRepeats") or 1
		local enableTime = descendant:GetAttribute("EnableTime")
		local emitDelay = descendant:GetAttribute("EmitDelay")
		local emitCount = descendant:GetAttribute("EmitCount")

		task.spawn(function()
			if emitDelay and emitDelay > 0 then
				task.wait(emitDelay)
			end

			while emitRepeats ~= 0 do
				emitRepeats -= 1
				if descendant:IsA("ParticleEmitter") then
					if enableTime then
						descendant.Enabled = true
						task.delay(enableTime, function()
							descendant.Enabled = false
						end)
					else
						descendant:Emit(emitCount)
					end
				elseif descendant:IsA("Light") then
					descendant.Enabled = true
					task.delay(enableTime or 1, function()
						descendant.Enabled = false
					end)
				end
				task.wait(emitIntervals)
			end
		end)
	end
end

local resizeAttachmentModel = Instance.new("Model")

function module.resizeAttachment(attachment, scale)
	local descendants = attachment:GetDescendants()
	table.insert(descendants, attachment)

	resizeAttachmentModel:ScaleTo(1)

	local resizing = {}

	for _,descendant in pairs(descendants) do
		local clone = attachment:Clone()
		clone.Parent = resizeAttachmentModel
		resizing[clone] = attachment
	end

	resizeAttachmentModel:ScaleTo(scale)

	for clone,attachment in pairs(resizing) do
		if attachment:IsA("ParticleEmitter") then
			attachment.Size = clone.Size
			attachment.Speed = clone.Speed
		elseif attachment:IsA("Beam") then
			attachment.Width0 = clone.Width0
			attachment.Width1 = clone.Width1
		elseif attachment:IsA("Trail") then
			attachment.MinLength = clone.MinLength
			attachment.WidthScale = clone.WidthScale
			attachment.TextureLength = clone.TextureLength
		end
		clone:Destroy()
	end
end

--Disable Player Input
if runService:IsClient() then
	function module.disableControls()
		local Controls = require(players.LocalPlayer.PlayerScripts.PlayerModule):GetControls()

		Controls:Disable()
	end
	
	function module.enableControls()
		local Controls = require(players.LocalPlayer.PlayerScripts.PlayerModule):GetControls()

		Controls:Enable()
	end
end

local savedTransparencies = {}
local transparencyProperties = {
	["TextButton"] = {["TextTransparency"] = 1, ["TextStrokeTransparency"] = 1},
	["TextLabel"] = {["TextTransparency"] = 1, ["TextStrokeTransparency"] = 1},
	["TextBox"] = {["TextTransparency"] = 1, ["TextStrokeTransparency"] = 1},
	["ScrollingFrame"] = {["ScrollBarImageTransparency"] = 1},
	["GuiObject"] = {["BackgroundTransparency"] = 1},
	["ImageButton"] = {["ImageTransparency"] = 1},
	["ImageLabel"] = {["ImageTransparency"] = 1},
	["UIStroke"] = {["Transparency"] = 1},

	["ProximityPrompt"] = {["Enabled"] = false},
	["ForceField"] = {["Visible"] = false},
	["BasePart"] = {["Transparency"] = 1, ["CanCollide"] = false, ["CanTouch"] = false, ["CanQuery"] = false},
	["Texture"] = {["Transparency"] = 1},
	["Decal"] = {["Transparency"] = 1},

	["ParticleEmitter"] = {["Transparency"] = NumberSequence.new(1)},
	["Trail"] = {["Transparency"] = NumberSequence.new(1)},
	["Beam"] = {["Transparency"] = NumberSequence.new(1)},
}

function module.invisible(model)
	if not model then return end
	local descendants = model:GetDescendants()
	table.insert(descendants, model)
	for _,descendant in pairs(descendants) do
		if not savedTransparencies[descendant] then
			savedTransparencies[descendant] = {}
		end
		for class,properties in pairs(transparencyProperties) do
			if not descendant:IsA(class) then continue end
			for property,value in pairs(properties) do
				if savedTransparencies[descendant][property] then continue end
				savedTransparencies[descendant][property] = descendant[property]
				descendant[property] = value
			end
		end
	end
end

function module.visible(model)
	if not model then return end
	local descendants = model:GetDescendants()
	table.insert(descendants, model)
	for _,descendant in pairs(descendants) do
		if not savedTransparencies[descendant] then continue end
		for class,properties in pairs(transparencyProperties) do
			if not descendant:IsA(class) then continue end
			for property,_ in pairs(properties) do
				if not savedTransparencies[descendant][property] then continue end
				descendant[property] = savedTransparencies[descendant][property]
				savedTransparencies[descendant][property] = nil
			end
		end
		savedTransparencies[descendant] = nil
	end
end

function module.setCanvasSize(canvas, size)
	canvas.CanvasSize = UDim2.new(1,0,1,0)
	size = size/canvas.AbsoluteWindowSize*(canvas.AbsoluteWindowSize/canvas.AbsoluteCanvasSize)
	canvas.CanvasSize = UDim2.fromScale(size.X,size.Y)
end

function module.hasPass(gamePass, player)
	local player = player or players.LocalPlayer
	local gamePassName = type(gamePass) == "string" and gamePass or settingsConfig.GamePasses[gamePass]

	local profileData
	if runService:IsServer() then
		local dataSet = dataService:GetDataSet(player)
		profileData = dataSet and dataSet.Profile.Data
	else
		profileData = dataService.clientReplica and dataService.clientReplica.Data
	end

	if not profileData then
		return false
	end

	return profileData.GamePasses and profileData.GamePasses[gamePassName] == true
end

local gamePassPurchaseFunctions = {}

function module.gamePassPurchase(gamePassPurchaseFunction)
	table.insert(gamePassPurchaseFunctions, gamePassPurchaseFunction)
end

--[[local Robux
local Notify

task.spawn(function()
	Robux = script.Parent.leaderboards.Leaderboards:WaitForChild("Robux")
	Notify = script.Parent.Parent.Remotes.Handler.Notify
end)--]]

marketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, bought)
	if not bought then return end
	
	--[[
	if runService:IsServer() then
		player.Data.RobuxSpent.Value += tonumber(module.productInfo(id, "GamePass").PriceInRobux) or 0
		local Difference = Robux.Value - player.Data.RobuxSpent.Value
		if Difference > 0 then
			Notify:FireClient(player, `Spend {module.abbreviate(Difference)} more Robux to be on the leaderobard`, "Blue")
		else
			for _,Child in pairs(Robux:GetChildren()) do
				if Child.Value == player.Name then
					Notify:FireClient(player, `You are now #{Child.Name} on the leaderboard!`, "Green")
					break
				end
			end
		end
	end--]]

	for _,gamePassPurchaseFunction in pairs(gamePassPurchaseFunctions) do
		gamePassPurchaseFunction(player, id)
	end
end)

local productPurchaseFunctions = {}

function module.productPurchase(productPurchaseFunction)
	table.insert(productPurchaseFunctions, productPurchaseFunction)
end

marketplaceService.PromptProductPurchaseFinished:Connect(function(userId, id, bought)
	if not bought then return end
	local player = players:GetPlayerByUserId(userId)
	
	if runService:IsServer() then
		--player.Data.RobuxSpent.Value += tonumber(module.productInfo(id, "GamePass").PriceInRobux) or 0
		--[[local Difference = Robux.Value - player.Data.RobuxSpent.Value
		if Difference > 0 then
			Notify:FireClient(player, `Spend {module.abbreviate(Difference)} more Robux to be on the leaderobard`, "Blue")
		else
			for _,Child in pairs(Robux:GetChildren()) do
				if Child.Value == player.Name then
					Notify:FireClient(player, `You are now #{Child.Name} on the leaderboard!`, "Green")
					break
				end
			end
		end--]]
	end

	for _,productPurchaseFunction in pairs(productPurchaseFunctions) do
		local gifting = player:FindFirstChild("Gifting")
		productPurchaseFunction(gifting and gifting.Value or player, id, player)
	end
end)

function module.fireOtherClients(event, player, ...)
	for _,player in pairs(module.otherPlayers(player)) do
		event:FireClient(player, ...)
	end
end

function module.headshotAsync(userId, thumbnailType, thumbnailSize)
	thumbnailType = thumbnailType or "AvatarHeadShot"
	thumbnailSize = thumbnailSize or "420"
	return ("rbxthumb://type=%s&id=%s&w=%s&h=%s"):format(thumbnailType, userId, thumbnailSize, thumbnailSize)
end

function module.character(player)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	return character and hrp and humanoid, character, hrp, humanoid
end

function module.playerData(player)
	local data,start = player:WaitForChild("Data", 60),tick()
	if not data then return end
	while #data:GetDescendants() < (data:GetAttribute("Descendants") or math.huge) do
		task.wait()
		if tick() - start > 60 then return end
	end
	return data
end

local playerAddedFunctions = {}
local playersRegistered = {}

function module.playerAddedFunction(playerAddedFunction)
	local players = players:GetPlayers()
	local index = #playerAddedFunctions+1
	playersRegistered[index] = players
	playerAddedFunctions[index] = playerAddedFunction

	for _,player in pairs(players) do
		task.spawn(function()
			playerAddedFunction(player)
		end)
	end
end

players.PlayerAdded:Connect(function(player)
	for index,playerAddedFunction in pairs(playerAddedFunctions) do
		if table.find(playersRegistered[index], player) then continue end
		table.insert(playersRegistered[index], player)
		task.spawn(function()
			playerAddedFunction(player)
		end)
	end
end)

local playerRemovingFunctions = {}

function module.playerRemovingFunction(playerRemovingFunction)
	table.insert(playerRemovingFunctions, playerRemovingFunction)
end

players.PlayerRemoving:Connect(function(player)
	for _,playerRemovingFunction in pairs(playerRemovingFunctions) do
		task.spawn(function()
			playerRemovingFunction(player)
		end)
	end
	for _,players in pairs(playersRegistered) do
		local found = table.find(players, player)
		if found then
			table.remove(players, found)
		end
	end
end)

function module.characterAddedFunction(player, characterAddedFunction)
	player.CharacterAdded:Connect(characterAddedFunction)

	if player.Character then
		characterAddedFunction(player.Character)
	end
end

local renderSteppedFunctions = {}

function module.renderStepped(renderSteppedFunction)
	table.insert(renderSteppedFunctions, renderSteppedFunction)
end

if runService:IsClient() then
	runService.RenderStepped:Connect(function()
		for _,renderSteppedFunction in pairs(renderSteppedFunctions) do
			task.spawn(renderSteppedFunction)
		end
	end)
else
	runService.Stepped:Connect(function()
		for _,renderSteppedFunction in pairs(renderSteppedFunctions) do
			task.spawn(renderSteppedFunction)
		end
	end)
end

local heartbeatFunctions = {}

function module.heartbeat(heartbeatFunction)
	table.insert(heartbeatFunctions, heartbeatFunction)
end

runService.Heartbeat:Connect(function()
	for _,heartbeatFunction in pairs(heartbeatFunctions) do
		task.spawn(heartbeatFunction)
	end
end)

local loopManager = {
	loops = {},
	connection = nil
}

function module.loop(callback, interval, startNow)
	local loopId = #loopManager.loops + 1
	local loop = {
		callback = callback,
		interval = interval,
		nextTick = time() + interval,
	}

	loopManager.loops[loopId] = loop

	if startNow then
		task.spawn(function()
			local shouldStop = callback()
			if shouldStop then
				loopManager.loops[loopId] = nil
				return
			end
		end)
	end

	module._ensureRunning()

	local loopHandle = {}
	function loopHandle:Disconnect()
		loopManager.loops[loopId] = nil
	end

	return loopHandle
end

function module._ensureRunning()
	if not loopManager.connection then
		loopManager.connection = runService.Heartbeat:Connect(function()
			local now = time()
			for id, loop in pairs(loopManager.loops) do
				if now >= loop.nextTick then
					loop.nextTick = now + loop.interval
					local shouldStop = loop.callback()
					if shouldStop then
						loopManager.loops[id] = nil
					end
				end
			end

			if not next(loopManager.loops) then
				loopManager.connection:Disconnect()
				loopManager.connection = nil
			end
		end)
	end
end

function module.create(class, parent, name, value)
	local instance = Instance.new(class)
	if value then
		instance.Value = value or ""
	end
	instance.Name = name
	instance.Parent = parent
	return instance
end

function module.attemptPcall(attempts, debounce, pcallFunction)
	local handleError
	for _ = 1, attempts do
		local success, error = pcall(pcallFunction)
		handleError = error
		if success then
			return true
		end
		task.wait(debounce)
	end
	warn(handleError)
end

function module.fromEnum(enum)
	return tostring(enum):match("%..+%.(.+)")
end

function module.roundToNumber(start, grid)
	return math.floor(((start+grid/2)/(grid)))*(grid)
end

local debugParts = {}

function module.debugPart(cframe, index)
	index = index or 1
	local debugPart = debugParts[index]
	if not debugPart then
		debugPart = Instance.new("Part", workspace)
		debugPart.Size = Vector3.one
		debugPart.Color = Color3.fromHSV((index/15)%1,1,1)
		debugPart.Anchored = true
		debugPart.CanCollide = false
		debugPart.CanTouch = false
		debugPart.CanQuery = false
		debugPart.CastShadow = false
		debugParts[index] = debugPart
	end
	cframe = typeof(cframe) == "Vector3" and CFrame.new(cframe) or cframe
	debugPart.CFrame = cframe
end

function module.onDestroy(part, event)
	local function run()
		if part.Parent then return end

		if typeof(event) == "function" then
			event()
		elseif typeof(event) == "Instance" then
			event:Destroy()
		end

	end

	part.AncestryChanged:Connect(run)
	run()
end

function module.onParentChanged(part, event)
	local initialParent = part.Parent
	local connection

	local function run()
		if part.Parent == initialParent then return end

		if typeof(event) == "function" then
			event()
		elseif typeof(event) == "Instance" then
			event:Destroy()
		end
		connection:Disconnect()
	end

	connection = part.AncestryChanged:Connect(run)
	run()
end

function module.otherPlayers(player)
	local allPlayers = players:GetPlayers()
	table.remove(allPlayers, table.find(allPlayers, players.LocalPlayer or player))
	return allPlayers
end

function module.modelToGround(part, model)
	local cf = part.CFrame * CFrame.new(0,-part.Size.Y/2,0)
	local pivot,boundingBox = model:GetPivot(),model:GetBoundingBox()
	local pivotOffset = pivot:ToObjectSpace(boundingBox)
	model:PivotTo(cf * pivotOffset:Inverse() * CFrame.new(0,model:GetExtentsSize().Y/2,0))
end

function module.modelToGroundUsingAttachment(attachment, model)
	local cf = attachment.WorldCFrame
	local pivot, boundingBox = model:GetPivot(), model:GetBoundingBox()
	local modelHeight = model:GetExtentsSize().Y / 2
	model:PivotTo(cf * CFrame.new(0, modelHeight, 0))
end

function module.changed(value, changedFunction)
	task.spawn(function()
		changedFunction(value.Value)
	end)
	value.Changed:Connect(function()
		changedFunction(value.Value)
	end)
end


--[[

chanceDictionary = {

	["Cash"] = {
		Chance = 50
	}
	
}--]]

function module.chance(chanceDictionnary)
	local chanceTable = {}
	for name,data in pairs(chanceDictionnary) do
		table.insert(chanceTable, {Name = name, Chance = data.Chance})
	end

	table.sort(chanceTable, function(a,b) return a.Chance < b.Chance end)

	local totalChance = 0
	for i,data in pairs(chanceTable) do
		totalChance += data.Chance
	end

	local chosenChance = rng:NextNumber(0,totalChance)
	local currentChance = 0

	for i,data in pairs(chanceTable) do
		currentChance += data.Chance
		if chosenChance < currentChance then
			return data.Name
		end
	end
end

function module.createKey(characters)
	local createdKey = ""
	for i = 1,characters or 64 do
		local chosen = rng:NextInteger(0, #key)
		createdKey = createdKey..key:sub(chosen, chosen)
	end
	return createdKey
end

function module.name()
	local createdName = names[rng:NextInteger(0, #names)]
	return createdName
end

function module.tableToObject(Table, Name)
	local data = module.create("Folder", nil, Name)
	for i,value in pairs(Table) do
		local Type = typeof(value)
		if Type == "table" then
			module.tableToObject(value, i).Parent = data
		else
			module.create(types[Type], data, i, value)
		end
	end
	return data
end

function module.objectToTable(Object)
	local data = {}
	for i,value in pairs(Object:GetChildren()) do
		if value.ClassName == "Folder" then
			data[value.Name] = module.objectToTable(value)
		else
			data[value.Name] = value.Value
		end
	end
	return data
end

function module.dictionnaryLength(dictionnary)
	local length = 0
	for i,value in pairs(dictionnary) do
		length += 1
	end
	return length
end

function module.searchArray(table, value)
	for key, item in table do
		if item == value then
			return key
		end
	end
end

function module.randomizeTable(inputList)
	for i = #inputList, 2, -1 do
		local j = math.random(i)
		inputList[i], inputList[j] = inputList[j], inputList[i]
	end
	return inputList
end

function module.randomWait(startRange, endRange)
	if endRange then
		startRange = rng:NextNumber(startRange, endRange)
	end
	task.wait(startRange)
end

-----: animations

function module.getAll(hum)
	return hum:GetPlayingAnimationTracks()
end

function module.getSpecByName(hum, animName)
	local animsList = module.getAll(hum)
	for i, track in pairs(animsList) do
		if track.Name == animName then return track end 
	end
end

function module.getSpecById(hum, animId)
	local animsList = module.getAll(hum)
	for i, track in pairs(animsList) do
		if track.Animation.AnimationId == animId then return track end
	end
end

function module.playAnimation(animationIdOrObject : number | Animation, target : Humanoid | Player | AnimationController, looped : boolean)
	local humanoidOrController = nil

	if target.ClassName == "Humanoid" then
		humanoidOrController = target
	elseif target:FindFirstChildOfClass("Humanoid") then
		humanoidOrController = target:FindFirstChildOfClass("Humanoid")
	elseif target:FindFirstChildOfClass("AnimationController") then
		humanoidOrController = target:FindFirstChildOfClass("AnimationController")
	elseif target.ClassName == "AnimationController" then
		humanoidOrController = target
	end

	if not humanoidOrController then
		warn("animation issues")
		return
	end
	
	local animation, animationId
	
	if typeof(animationIdOrObject) == "string" then
		animation = Instance.new("Animation")
		animation.AnimationId = animationIdOrObject		
		animationId = animationIdOrObject
	else 
		animation = animationIdOrObject		
		animationId = animationIdOrObject .AnimationId 
	end
	
	for _, track in humanoidOrController:GetPlayingAnimationTracks() do
		if animationId == track.Animation.AnimationId then
			return
		end
	end
	
	local animationTrack = humanoidOrController:LoadAnimation(animation)
	
	if looped then
		animationTrack.Looped = true
	end
	
	animationTrack:Play()
end

function module.stopAnimation(animationIdOrObject : number | Animation, target : Humanoid | AnimationController)
	local humanoidOrController = nil

	if target.ClassName == "Humanoid" then
		humanoidOrController = target
	elseif target:FindFirstChildOfClass("Humanoid") then
		humanoidOrController = target:FindFirstChildOfClass("Humanoid")
	elseif target:FindFirstChildOfClass("AnimationController") then
		humanoidOrController = target:FindFirstChildOfClass("AnimationController")
	elseif target.ClassName == "AnimationController" then
		humanoidOrController = target
	end

	if not humanoidOrController then
		warn("animation issues")
		return
	end

	local animationId

	if typeof(animationIdOrObject) == "string" then
		animationId = animationIdOrObject
	else 
		animationId = animationIdOrObject.AnimationId
	end

	local animationTracks = humanoidOrController:GetPlayingAnimationTracks()

	for _, track in ipairs(animationTracks) do
		if track.Animation.AnimationId == animationId then
			track:Stop()
		end
	end
end



return module