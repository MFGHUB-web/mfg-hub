-- ====================================================
--   ⚡ MFG HUB | My Farmer's Garden (v26 Supreme Edition)
--   - 🎨 Modern SpeedHub Left-Sidebar Navigation & Tabbed Interface
--   - 🌿 100% Strict Plant Merge (Merges Only Shoveled/Grown Plants, Never Seeds)
--   - 🌱 Fixed Auto Plant Seeds (Grid Placement on Unlocked Plots + Rarity Selectors)
--   - 🛡️ Safe Pet Protection (Never Deletes Selected Tiers / Mutated Pets)
--   - 🛡️ Safe Plant Protection (Never Sells Mutated or Merged/Star Plants)
--   - 💧 Auto Water Growing Plants (Extended Hold Duration for Guaranteed Success)
--   - 🗑️ Auto Delete Pets by Name or Rarity (Panda, Chicken, Rabbit, etc.)
--   - 💰 Auto Sell Harvested Plants by Rarity at Sell Area
--   - ☀️ Exact Plot Sunshine Storage Auto-Collect (Direct Silo Collection)
--   - 🌱 Rarity-Categorized Auto Buy Seeds (With Select All per Rarity)
--   - 🛠️ Dedicated Gear Shop Auto Buy (Watering Cans, Sprinklers, Shovels)
--   - 🎡 Smart Spin Wheel with 2M / 5M Reserve & Best Tier Auto-Select
--   - 🥚 Fixed Auto Place Eggs (Auto-Equips from Inventory)
--   - 🐣 Auto Hatch Incubated Eggs (Instant 0:00 Pet Claimer)
--   - 💾 100% Persistent Config & Checkbox Memory (Auto-Loads on Rejoin)
--   - ⚡ Fast VIP 10-Stall Merchant Reroller & Server Hopper
--   - 🧑‍🌾 Farmer Shop Auto Buy with Rarity Selectors
--   - 📋 Auto Quests & Daily Claim Engine
--   - 🛡️ 24/7 Triple-Layer Anti-AFK & Low RAM / FPS Boost Mode
-- ====================================================

local Players         = game:GetService("Players")
local RS              = game:GetService("ReplicatedStorage")
local UIS             = game:GetService("UserInputService")
local TweenSvc        = game:GetService("TweenService")
local HttpService     = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser     = game:GetService("VirtualUser")
local RunService      = game:GetService("RunService")
local player          = Players.LocalPlayer

-- ====================================================
--  🛡️ 24/7 TRIPLE-LAYER ANTI-AFK & RAM OPTIMIZER
-- ====================================================
pcall(function()
	player.Idled:Connect(function()
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new(0, 0))
		end)
	end)
end)

task.spawn(function()
	while true do
		task.wait(120)
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:Button2Down(Vector2.new(0, 0))
			task.wait(0.05)
			VirtualUser:Button2Up(Vector2.new(0, 0))
		end)
	end
end)

task.spawn(function()
	while true do
		task.wait(45)
		pcall(function() collectgarbage("collect") end)
	end
end)

-- ====================================================
--  CENTRALIZED STATE
-- ====================================================
local S = {
	lowMemOn              = false,
	speedOn               = false,
	
	-- Seeds & Planting
	selectedSeeds         = {},
	autoBuySeedsEnabled   = false,
	seedBoughtCount       = 0,
	autoOpenSeedsEnabled  = false,
	seedPacksOpened       = 0,
	
	selectedPlantSeeds    = {},
	selectedPlantRarities = {["Common"] = true, ["Rare"] = true, ["Epic"] = true, ["Legendary"] = true, ["Mythic"] = true},
	autoPlantSeedsEnabled = false,
	seedsPlantedCount     = 0,
	
	-- Watering
	autoWaterEnabled      = false,
	wateredCount          = 0,
	
	-- Plants Fusion / Merge
	autoMergePlantsEnabled = false,
	mergesCompletedCount   = 0,
	isMergingNow           = false,
	
	-- Auto Sell Plants & Safety Protections
	selectedSellRarities   = {["Common"] = true, ["Rare"] = true},
	keepMutatedPlants      = true, -- Protect Gold, Bubble, Snow Flakes, etc.
	keepMergedPlants       = true, -- Protect ★, ★★, ★★★+
	autoSellPlantsEnabled  = false,
	plantsSoldCount        = 0,
	
	-- Gears
	selectedGears         = {},
	autoBuyGearsEnabled   = false,
	gearBoughtCount       = 0,
	gearRestockEnd        = 0,
	
	-- Eggs & Pets
	selectedEggs          = {},
	autoBuyEggsEnabled    = false,
	autoPlaceEggsEnabled  = false,
	autoHatchEggsEnabled  = false,
	eggBoughtCount        = 0,
	eggsPlacedCount       = 0,
	eggsHatchedCount      = 0,
	
	-- Pet Deletion & Safety Protections
	selectedDeletePets    = {["Chicken"] = true, ["Rabbit"] = true},
	protectedPetRarities  = {["Legendary"] = true, ["Mythic"] = true, ["Secret"] = true},
	keepMutatedPets       = true, -- Protect Golden / Mutated Pets
	autoDeletePetsEnabled = false,
	petsDeletedCount      = 0,
	
	-- Farmers
	selectedRarities      = {},
	autoBuyEnabled        = false,
	autoBuyCount          = 0,
	farmerRestockEnd      = 0,
	autoEquipFarmersEnabled = false,
	webhookNotifyEnabled    = false,
	webhookUrl              = "",
	
	-- Sunshine & Spin Wheel
	autoCollectEnabled    = false,
	depositCount          = 0,
	autoSpinEnabled       = false,
	spinTier              = "best", -- "100k", "1m", "best"
	minSpinSunshine       = 2000000, -- 0, 2000000, 5000000, 10000000
	spinsCount            = 0,
	isSpinningNow         = false,
	
	-- Quests & Airdrop
	autoQuestEnabled      = false,
	questsCompletedCount  = 0,
	autoAirdropEnabled    = false,
	airdropsOpenedCount   = 0,
	
	-- VIP Reroller
	vipRerollEnabled      = false,
	vipTargetTiers        = {["Rainbow"] = true, ["Mythic"] = true, ["Legendary"] = true},
	vipRerollCount        = 0,
	vipAutoBuyOnFind      = true,
	vipAutoTpOnFind       = true,
	isRerollingNow        = false,
	isHopping             = false,
	
	-- Plants Merge Selection (by plant name)
	selectedMergePlants   = {},  -- e.g. {["Pastel Puff"] = true, ["Ember Sun"] = true}
	
	-- Auto Shovel
	autoShovelEnabled     = false,
	selectedShovelPlants  = {},  -- e.g. {["Pastel Puff"] = true}
	shovelRarities        = {},  -- e.g. {["Common"] = true, ["Worldseed"] = true} — shovel by rarity
	shovelsCount          = 0,
	shovelProtectHighTier = true,   -- skip plants above shovelMaxTier
	shovelMaxTier         = 2,      -- default: protect T3+ (shovel T1 & T2 only)
	shovelProtectMutated  = true,   -- skip plants with any mutation
	shovelProtectHighStars = true,  -- skip plants above shovelMaxStars
	shovelMaxStars        = 3,      -- default: protect 4+ stars (shovel 0-3★ only)
	
	-- UI State
	activeTab             = "Main",
	guiMinimized          = false,

	-- Auto Farm master mode (ordered plant -> water -> shovel -> merge pipeline)
	autoFarmEnabled       = false,
	farmPhaseActive       = false,
}

-- Safe Utility Helpers
local function safeNum(v, d)
	local n = tonumber(v)
	return (n and n == n) and n or (d or 0)
end

local function parseSuffixedNumber(text)
	if not text or type(text) ~= "string" then return nil end
	local clean = text:gsub(",", ""):gsub("%$", ""):gsub("☀️", ""):gsub("x", ""):match("[%d%.]+%s*[kKmMbBtT]?")
	if not clean then return nil end
	local numStr, suffix = clean:match("([%d%.]+)%s*([kKmMbBtT]?)")
	local base = tonumber(numStr)
	if not base then return nil end
	suffix = suffix:upper()
	if suffix == "K" then return base * 1000 end
	if suffix == "M" then return base * 1000000 end
	if suffix == "B" then return base * 1000000000 end
	if suffix == "T" then return base * 1000000000000 end
	return base
end

local function fmtNumber(num)
	num = safeNum(num, 0)
	if num >= 1000000000 then return string.format("%.2fB", num / 1000000000) end
	if num >= 1000000 then return string.format("%.2fM", num / 1000000) end
	if num >= 1000 then return string.format("%.1fK", num / 1000) end
	return tostring(math.floor(num))
end

-- ====================================================
--  SAFE REMOTE RESOLVER
-- ====================================================
local function getRemote(name)
	local r = RS:FindFirstChild(name) or RS:FindFirstChild(name, true)
	if not r then
		pcall(function() r = RS:WaitForChild(name, 1.5) end)
	end
	return r
end

local R = {
	GetFarmerStock       = getRemote("GetFarmerShopStockRequest"),
	BuyFarmerReq         = getRemote("BuyFarmerRequest"),
	FarmerRestocked      = getRemote("FarmerShopStockRefreshedEvent"),
	FarmerTimerEvt       = getRemote("FarmerShopTimerEvent"),
	GetGearState         = getRemote("GetGearShopStateRequest"),
	GearShopBuyReq       = getRemote("GearShopBuyRequest"),
	GearRestocked        = getRemote("GearShopRestocked"),
	GetMerchants         = getRemote("GetActiveMerchantsRequest"),
	ShopTimerReq         = getRemote("ShopTimerRequest"),
	MutationTimer        = getRemote("MutationTimerEvent"),
	DepositBurst         = getRemote("DepositBurstEvent"),
	GetPlaytime          = getRemote("GetPlaytimeStateRequest"),
	ClaimPlaytime        = getRemote("ClaimPlaytimeRewardRequest"),
	OpenSeedPack         = getRemote("OpenSeedPackRequest"),
	CrateOpenPuzzleEvt   = getRemote("CrateOpenPuzzleEvent"),
	CratePuzzleSolvedEvt = getRemote("CratePuzzleSolvedEvent"),
	AirdropRewardReveal  = getRemote("AirdropRewardRevealEvent"),
	QuestSyncEvt         = getRemote("QuestSyncEvent"),
	QuestSubmitReq       = getRemote("QuestSubmitRequest"),
	QuestClaimReq        = getRemote("QuestClaimRequest"),
	QuestRequestSync     = getRemote("QuestRequestSync"),
	SpinRequest          = getRemote("SpinRequest"),
	OpenWheelEvent       = getRemote("OpenWheelEvent"),
	AutoSpinToggle       = getRemote("AutoSpinToggle"),
	FusionMachineEvent   = getRemote("FusionMachineEvent"),
	FusionMergeConfirm   = getRemote("FusionMergeConfirm"),
	EggHatchPlayAnim     = getRemote("EggHatchPlayAnimation"),
	DeletePetRequest     = getRemote("DeletePetRequest"),
	SellRequest          = getRemote("SellRequest"),
	WateringCanUseReq    = getRemote("WateringCanUseRequest"),
	PlantPlacementReq    = getRemote("PlantPlacementRequest"),
	ShovelUprootRequest  = getRemote("ShovelUprootRequest"),
	GetOwnedFarmers      = getRemote("GetOwnedFarmersDetailedRequest"),
	ToggleEquipFarmer    = getRemote("ToggleEquipFarmerRequest"),
	GetMaxFarmers        = getRemote("GetMaxEquippedFarmersRequest"),
	GetFarmerPhase       = getRemote("GetFarmerShopPhaseRequest"),
}

-- ====================================================
--  🔐 MEGALO PER-USER KEY LOCK (SERVER-VERIFIED)
--  A key only works for the exact Roblox username it is
--  paired with on your Google Sheet backend. No sharing.
--  Set these two constants to YOUR endpoints.
-- ====================================================
local AUTH_API_URL   = "https://script.google.com/macros/s/AKfycbzSIEtLGRb7WKmGvBn8ZWjR3B3xXBb3YW6sMZjTGt9xwJ0MrTnDPVHrgeAtEc7OjW_D/exec"  -- your Google Web App (validates username+key)
local AUTH_WEBHOOK   = "https://discordapp.com/api/webhooks/1544132898716647507/c0RxASbeCqhhn_Fxh9DiPXVc5-7yYZYgWV_8n_E_WnOFDj9PbMjNA7AM4x25QVgx6xIv"  -- Discord webhook for auth logs
local AUTH_CONFIG    = "MFG_HUB_Auth.json"
local AUTH_UNLOCKED  = false

-- Verify a username+key against your Google backend.
-- Returns true only when the backend replies exactly VALID.
local function mfgVerifyKey(username, key)
	local ok = false
	pcall(function()
		local url = AUTH_API_URL .. "?u=" .. HttpService:UrlEncode(username) .. "&k=" .. HttpService:UrlEncode(key)
		local body = ""
		if request then
			local res = request({ Url = url, Method = "GET" })
			if type(res) == "table" then body = res.Body or "" end
		elseif HttpGet then
			body = HttpGet(url) or ""
		end
		-- Exact match: the backend replies "VALID" or "INVALID".
		-- Using an exact comparison avoids "INVALID" matching "VALID" as a substring.
		local cleaned = (body or ""):gsub("%s", ""):upper()
		ok = (cleaned == "VALID")
	end)
	return ok
end

-- Send an auth-log message to your Discord webhook.
local function mfgAuthLog(title, desc, color)
	pcall(function()
		local embed = {
			embeds = {{
				title = title,
				description = desc,
				color = color,
				footer = { text = "MFG HUB Key Log | " .. os.date("%Y-%m-%d %H:%M:%S") },
			}}
		}
		if request then
			request({
				Url = AUTH_WEBHOOK,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode(embed),
			})
		end
	end)
end

-- ALWAYS-VERIFY MODE: the local file only remembers the key so the user
-- doesn't retype it. It is NEVER trusted — every load re-validates against
-- your Google backend, so changing/revoking a row in your sheet takes effect
-- on the user's very next load even if they never clear their local file.

-- Returns the saved key (string) for this UserId, or nil if none saved.
local function mfgLoadSavedKey()
	local saved = nil
	pcall(function()
		if readfile and isfile and isfile(AUTH_CONFIG) then
			local data = HttpService:JSONDecode(readfile(AUTH_CONFIG))
			if type(data) == "table" and type(data[player.UserId]) == "string" then
				saved = data[player.UserId]
			end
		end
	end)
	return saved
end

local function mfgSaveKey(key)
	pcall(function()
		local data = {}
		if readfile and isfile and isfile(AUTH_CONFIG) then
			local ok, old = pcall(function() return HttpService:JSONDecode(readfile(AUTH_CONFIG)) end)
			if ok and type(old) == "table" then data = old end
		end
		data[player.UserId] = key
		if writefile then pcall(function() writefile(AUTH_CONFIG, HttpService:JSONEncode(data)) end) end
	end)
end

-- ====================================================
--  🔐 UNLOCK UI + GATE (ALWAYS VERIFY)
--  Every load re-validates against the backend. The
--  local file only pre-fills the key so it isn't retyped.
--  The lock screen is shown INSTANTLY so the user never
--  stares at a black screen while the server is checked.
-- ====================================================
local savedKey = mfgLoadSavedKey()
if not AUTH_UNLOCKED then
	task.spawn(function()
		if savedKey then
			-- Show a quick "Verifying saved key..." note while we check
			-- (see attempt() auto-run below)
		end
		-- Build the lock screen
		local lock = Instance.new("ScreenGui")
		lock.Name = "MFG_LOCK"
		lock.ResetOnSpawn = false
		lock.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		lock.DisplayOrder = 999
		lock.Parent = player:WaitForChild("PlayerGui")

		local bg = Instance.new("Frame")
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.BackgroundColor3 = Color3.fromRGB(8, 9, 14)
		bg.BackgroundTransparency = 0.15
		bg.Parent = lock

		local shade = Instance.new("Frame")
		shade.AnchorPoint = Vector2.new(0.5, 0.5)
		shade.Size = UDim2.new(0, 420, 0, 300)
		shade.Position = UDim2.new(0.5, 0, 0.45, 0)
		shade.BackgroundColor3 = Color3.fromRGB(18, 20, 31)
		shade.BorderSizePixel = 0
		shade.Parent = bg

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, 0, 0, 44)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.Text = "🔐 MFG HUB"
		title.TextColor3 = Color3.fromRGB(88, 101, 242)
		title.TextSize = 24
		title.Parent = shade

		local sub = Instance.new("TextLabel")
		sub.AnchorPoint = Vector2.new(0.5, 0)
		sub.Size = UDim2.new(1, -32, 0, 20)
		sub.Position = UDim2.new(0.5, 0, 0, 44)
		sub.BackgroundTransparency = 1
		sub.Font = Enum.Font.Gotham
		sub.Text = "Enter your private key  ·  " .. player.Name
		sub.TextColor3 = Color3.fromRGB(170, 175, 195)
		sub.TextSize = 13
		sub.Parent = shade

		local status = Instance.new("TextLabel")
		status.AnchorPoint = Vector2.new(0.5, 0)
		status.Size = UDim2.new(1, -32, 0, 20)
		status.Position = UDim2.new(0.5, 0, 0, 70)
		status.BackgroundTransparency = 1
		status.Font = Enum.Font.Gotham
		status.Text = ""
		status.TextColor3 = Color3.fromRGB(255, 90, 90)
		status.TextSize = 12
		status.Parent = shade

		local box = Instance.new("TextBox")
		box.AnchorPoint = Vector2.new(0.5, 0)
		box.Size = UDim2.new(1, -64, 0, 42)
		box.Position = UDim2.new(0.5, 0, 0, 100)
		box.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
		box.BorderColor3 = Color3.fromRGB(60, 66, 94)
		box.PlaceholderText = "Enter your key..."
		box.Font = Enum.Font.Gotham
		box.TextColor3 = Color3.fromRGB(230, 233, 245)
		box.TextSize = 16
		if savedKey and savedKey ~= "" then box.Text = savedKey end
		box.Parent = shade

		local button = Instance.new("TextButton")
		button.AnchorPoint = Vector2.new(0.5, 0)
		button.Size = UDim2.new(1, -64, 0, 44)
		button.Position = UDim2.new(0.5, 0, 0, 158)
		button.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
		button.Font = Enum.Font.GothamBold
		button.Text = "UNLOCK"
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 15
		button.Parent = shade

		local note = Instance.new("TextLabel")
		note.AnchorPoint = Vector2.new(0.5, 0)
		note.Size = UDim2.new(1, -32, 0, 24)
		note.Position = UDim2.new(0.5, 0, 0, 214)
		note.BackgroundTransparency = 1
		note.Font = Enum.Font.Gotham
		note.Text = "One key per user · keys are personal"
		note.TextColor3 = Color3.fromRGB(120, 126, 150)
		note.TextSize = 11
		note.Parent = shade

		local trying = false
		local function attempt(entered)
			if trying then return end
			trying = true
			button.Text = "VERIFYING..."
			status.Text = ""
			local enteredKey = (entered or box.Text or ""):gsub("%s", "")
			if enteredKey == "" then
				status.Text = "Please enter a key."
				button.Text = "UNLOCK"
				trying = false
				return
			end
			task.spawn(function()
				local valid = mfgVerifyKey(player.Name, enteredKey)
				if valid then
					AUTH_UNLOCKED = true
					mfgSaveKey(enteredKey)
					mfgAuthLog("✅ Unlocked", "**" .. player.Name .. "** unlocked MFG HUB.", 5763719)
					status.Text = "✅ Access granted!"
					status.TextColor3 = Color3.fromRGB(90, 220, 120)
					task.wait(0.6)
					lock:Destroy()
				else
					mfgAuthLog("❌ Invalid Key", "**" .. player.Name .. "** tried key `" .. enteredKey .. "` (failed).", 15548997)
					status.Text = "❌ Invalid key for this account."
					status.TextColor3 = Color3.fromRGB(255, 90, 90)
					button.Text = "UNLOCK"
					trying = false
				end
			end)
		end

		button.MouseButton1Click:Connect(function() attempt() end)
		box.FocusLost:Connect(function(enter) if enter then attempt() end end)

		-- Auto-verify a saved key in the background (shows the UI first, no black wait)
		if savedKey and savedKey ~= "" then
			status.Text = "Verifying saved key..."
			status.TextColor3 = Color3.fromRGB(240, 220, 120)
			button.Text = "VERIFYING..."
			task.spawn(function()
				task.wait(0.1)
				local valid = mfgVerifyKey(player.Name, savedKey)
				if valid then
					AUTH_UNLOCKED = true
					mfgAuthLog("✅ Unlocked", "**" .. player.Name .. "** unlocked MFG HUB (saved key).", 5763719)
					status.Text = "✅ Access granted!"
					status.TextColor3 = Color3.fromRGB(90, 220, 120)
					task.wait(0.5)
					lock:Destroy()
				else
					status.Text = "Saved key no longer valid. Enter a new key."
					status.TextColor3 = Color3.fromRGB(255, 90, 90)
					button.Text = "UNLOCK"
					trying = false
					box.Text = ""
				end
			end)
		end
	end)

	-- BLOCK the main script until the key is validated
	while not AUTH_UNLOCKED do
		task.wait(0.2)
	end
	task.wait(0.4)  -- let the lock screen fade
end

-- ====================================================
--  CONFIG PERSISTENCE (100% RELIABLE)
-- ====================================================
local CONFIG_FILE = "MFG_HUB_Config.json"

local function saveConfig(isManual)
	local cfg = {
		selectedSeeds          = S.selectedSeeds,
		selectedPlantSeeds     = S.selectedPlantSeeds,
		selectedPlantRarities  = S.selectedPlantRarities,
		selectedGears          = S.selectedGears,
		selectedEggs           = S.selectedEggs,
		selectedRarities       = S.selectedRarities,
		selectedDeletePets     = S.selectedDeletePets,
		protectedPetRarities   = S.protectedPetRarities,
		keepMutatedPets        = S.keepMutatedPets,
		selectedSellRarities   = S.selectedSellRarities,
		keepMutatedPlants      = S.keepMutatedPlants,
		keepMergedPlants       = S.keepMergedPlants,
		autoBuySeedsEnabled    = S.autoBuySeedsEnabled,
		autoBuyGearsEnabled    = S.autoBuyGearsEnabled,
		autoBuyEggsEnabled     = S.autoBuyEggsEnabled,
		autoPlaceEggsEnabled   = S.autoPlaceEggsEnabled,
		autoHatchEggsEnabled   = S.autoHatchEggsEnabled,
		autoDeletePetsEnabled  = S.autoDeletePetsEnabled,
		autoSellPlantsEnabled  = S.autoSellPlantsEnabled,
		autoMergePlantsEnabled = S.autoMergePlantsEnabled,
		autoPlantSeedsEnabled  = S.autoPlantSeedsEnabled,
		autoWaterEnabled       = S.autoWaterEnabled,
		autoAirdropEnabled     = S.autoAirdropEnabled,
		autoQuestEnabled       = S.autoQuestEnabled,
		vipRerollEnabled       = S.vipRerollEnabled,
		vipTargetTiers         = S.vipTargetTiers,
		vipAutoBuyOnFind       = S.vipAutoBuyOnFind,
		vipAutoTpOnFind        = S.vipAutoTpOnFind,
		autoSpinEnabled        = S.autoSpinEnabled,
		spinTier               = S.spinTier,
		minSpinSunshine        = S.minSpinSunshine,
		autoBuyEnabled         = S.autoBuyEnabled,
		autoCollectEnabled     = S.autoCollectEnabled,
		autoOpenSeedsEnabled   = S.autoOpenSeedsEnabled,
		speedOn                = S.speedOn,
		lowMemOn               = S.lowMemOn,
		selectedMergePlants    = S.selectedMergePlants,
		autoShovelEnabled      = S.autoShovelEnabled,
		selectedShovelPlants   = S.selectedShovelPlants,
		shovelRarities         = S.shovelRarities,
		shovelProtectHighTier  = S.shovelProtectHighTier,
		shovelMaxTier          = S.shovelMaxTier,
		shovelProtectMutated   = S.shovelProtectMutated,
		shovelProtectHighStars = S.shovelProtectHighStars,
		shovelMaxStars         = S.shovelMaxStars,
		autoEquipFarmersEnabled = S.autoEquipFarmersEnabled,
		webhookNotifyEnabled    = S.webhookNotifyEnabled,
		webhookUrl              = S.webhookUrl,
		autoFarmEnabled         = S.autoFarmEnabled,
	}
	local ok, encoded = pcall(function() return HttpService:JSONEncode(cfg) end)
	if ok and encoded and writefile then
		pcall(function() writefile(CONFIG_FILE, encoded) end)
		if isManual and _G.MFGToast then
			_G.MFGToast("💾 Config Saved", "All settings & selections saved successfully!", Color3.fromRGB(80, 220, 120))
		end
	end
end

-- ====================================================
--  PROXIMITY & CLICK UTILITIES
-- ====================================================
local function clickButton(btn)
	if not btn then return end
	pcall(function()
		for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
		for _, c in ipairs(getconnections(btn.MouseButton1Down)) do c:Fire() end
		for _, c in ipairs(getconnections(btn.Activated)) do c:Fire() end
	end)
end

local function triggerPromptWithHold(prompt, holdDuration)
	if not prompt or not prompt.Enabled then return end
	local origHold = prompt.HoldDuration
	local origLos = prompt.RequiresLineOfSight
	local origDist = prompt.MaxActivationDistance
	local duration = holdDuration or 0.35
	
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 9999999
	prompt.HoldDuration = 0
	
	if fireproximityprompt then
		pcall(function() fireproximityprompt(prompt, 0) end)
		pcall(function() fireproximityprompt(prompt) end)
	end
	pcall(function()
		prompt:InputHoldBegin()
		local elapsed = 0
		while elapsed < duration do
			task.wait(0.05)
			elapsed = elapsed + 0.05
		end
		prompt:InputHoldEnd()
	end)
	
	task.delay(0.4, function()
		pcall(function()
			prompt.HoldDuration = origHold
			prompt.RequiresLineOfSight = origLos
			prompt.MaxActivationDistance = origDist
		end)
	end)
end

local function teleportTo(pos)
	local char = player.Character or (player.CharacterAdded and player.CharacterAdded:Wait())
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
	end
end

local _cachedPlot = nil
local _cachedPlotAt = 0
local function getMyGardenPlot()
	-- Cache the plot for up to 10s to avoid re-scanning every player's
	-- garden on every automation loop tick (biggest repeated cost in the script).
	if _cachedPlot and (_cachedPlot.Parent ~= nil) and (tick() - _cachedPlotAt < 10) then
		return _cachedPlot
	end

	local gardenFolder = workspace:FindFirstChild("PLAYERS GARDEN")
	if not gardenFolder then return nil end
	
	local myUserId = player.UserId
	local myName = player.Name
	
	-- Primary: Check attributes on GardenBase itself (OwnerUserId and OwnerName)
	for _, base in ipairs(gardenFolder:GetChildren()) do
		local uid = base:GetAttribute("OwnerUserId")
		local oname = base:GetAttribute("OwnerName") or base:GetAttribute("Owner")
		if uid == myUserId or oname == myName then
			_cachedPlot = base
			_cachedPlotAt = tick()
			return base
		end
	end
	
	-- Secondary: Check children/descendants of each base for ownership
	for _, base in ipairs(gardenFolder:GetChildren()) do
		for _, child in ipairs(base:GetChildren()) do
			local uid = child:GetAttribute("OwnerUserId")
			local oname = child:GetAttribute("OwnerName") or child:GetAttribute("Owner")
			if uid == myUserId or oname == myName then
				_cachedPlot = base
				_cachedPlotAt = tick()
				return base
			end
			-- Check plants inside plot parts
			if child.Name:lower():find("plot") then
				for _, model in ipairs(child:GetChildren()) do
					if model:IsA("Model") and (model:GetAttribute("OwnerUserId") == myUserId or model:GetAttribute("OwnerName") == myName) then
						_cachedPlot = base
						_cachedPlotAt = tick()
						return base
					end
				end
			end
		end
	end
	
	return nil
end

-- ====================================================
--  CATALOGS & DATA
-- ====================================================
local SEED_CATALOG = {
	{rarity="Common", color=Color3.fromRGB(255,255,255), seeds={"Bellsora","Coco Bloom","Cotton Bloom","Red Sta Rosa","Vasal Flower","White Sta Rosa"}},
	{rarity="Rare", color=Color3.fromRGB(70,160,255), seeds={"Curlvine Lily","Lily Flows","Star Sun","Starlantern Bloom","Sunwhisper"}},
	{rarity="Epic", color=Color3.fromRGB(180,80,230), seeds={"Candy Pop","Fanora Lily","Kineme Bloom","Nocturne","ShroomShie","Void Star"}},
	{rarity="Legendary", color=Color3.fromRGB(255,220,0), seeds={"Jelly Flower","Orchid","Plower Pop","Red Curly","Sepent Flower"}},
	{rarity="Mythic", color=Color3.fromRGB(255,28,32), seeds={"Ember Sun","Lily Bloom","Palm Star","Pastel Puff","Sunveil Blossora"}},
	{rarity="Eternal", color=Color3.fromRGB(255,140,0), seeds={"Eternal Bloom","Inferno Crown Flower","Moon Bloom","Solaris Bloom"}},
	{rarity="SuperPlants", color=Color3.fromRGB(0,255,220), seeds={"Blue Star Petal","Corally","Pink Star Petal","Ring Flare","Violetia Bloom","Yellow Star Petal"}},
	{rarity="Worldseed", color=Color3.fromRGB(120,255,120), seeds={"Mintora","Sweet Blossom","Triflow Bloom"}},
	{rarity="Ethereal Traveler", color=Color3.fromRGB(255,105,180), seeds={"Bee Flower","Lumina Flower","Rosal Bud","Twinkle Tulip","White Lily"}},
}

local VALID_PLANT_NAMES = {}
local PLANT_TO_RARITY = {}
for _, group in ipairs(SEED_CATALOG) do
	for _, s in ipairs(group.seeds) do
		VALID_PLANT_NAMES[s] = true
		PLANT_TO_RARITY[s] = group.rarity
	end
end

local GEAR_LIST = {
	"Watering Can", "Aqua Watering Can", "Shovel", "Reclaimer",
	"Basic Sprinkler", "Improved Sprinkler", "Hydro Sprinkler", "Precision Sprinkler"
}

local EGG_LIST = {"Common Egg", "Rare Egg", "Legendary Egg", "Mythic Egg", "Secret Egg"}

local PET_LIST = {"Chicken", "Rabbit", "Bee", "Panda", "Dog", "Cat", "Golden Bee", "Dragon"}

local PET_RARITIES_LIST = {"Common", "Rare", "Epic", "Legendary", "Mythic", "Secret"}

local FARMER_COLORS = {
	Common=Color3.fromRGB(255,255,255), Rare=Color3.fromRGB(70,160,255),
	Epic=Color3.fromRGB(180,80,230), Legendary=Color3.fromRGB(255,220,0),
	Mythic=Color3.fromRGB(255,28,32), Secret=Color3.fromRGB(100,100,115),
	Money=Color3.fromRGB(55,215,95), Angelic=Color3.fromRGB(255,240,120),
}
local RARITIES_LIST = {"Common","Rare","Epic","Legendary","Mythic","Secret","Money","Angelic"}

local LOCATIONS = {
	["Spin Wheel"]        = Vector3.new(207.13, 207.02, -42.33),
	["Farmer Shop"]       = Vector3.new(228, 203, -41),
	["Gear Shop"]         = Vector3.new(256, 197, -24),
	["Merchant Area"]     = Vector3.new(194, 203, -33),
	["Sunshine Storage"]  = Vector3.new(280.9, 185.0, 93.3),
	["Fusion Machine"]    = Vector3.new(165.0, 195.0, 45.0),
}

-- ====================================================
--  🌱 STRICT SEED TOOL IDENTIFIER (FOR PLANTING)
-- ====================================================
local function isSeedTool(t)
	if not t or not t:IsA("Tool") then return false end
	if t:GetAttribute("IsPet") or t:GetAttribute("IsEgg") or t:GetAttribute("IsSprinkler") or t:GetAttribute("IsSeedPack") or t:GetAttribute("IsWateringCan") then
		return false
	end
	if t:GetAttribute("RewardWeight") ~= nil then return true end
	for _, c in ipairs(t:GetChildren()) do
		if c:IsA("Model") and c.Name:lower():find("seed") then return true end
	end
	if t.Name:lower():find("seed") and not t.Name:lower():find("pack") then return true end
	return false
end

-- ====================================================
--  🌿 GROWN PLANT IDENTIFIER (OFFICIAL GAME LOGIC)
--  PlantID ~= nil  AND  SizeRolled == true  = harvested/grown plant
--  PlantID ~= nil  AND  SizeRolled ~= true  = seed/unrolled plant
-- ====================================================
local function isGrownPlantTool(t)
	if not t or not t:IsA("Tool") then return false end
	-- Must have a PlantID (excludes all gear, pets, sprinklers)
	if t:GetAttribute("PlantID") == nil then return false end
	-- SizeRolled == true means it's been shoveled/harvested (grown plant)
	-- SizeRolled ~= true means it's a seed
	return t:GetAttribute("SizeRolled") == true
end

-- Returns the numeric tier from SizeTier attr ("Scale +1" → 1, "Scale +2" → 2, nil → 0)
local function getPlantTier(t)
	local sizeTier = t:GetAttribute("SizeTier")
	if not sizeTier then return 0 end
	local num = sizeTier:match("%+(%d+)")
	return num and tonumber(num) or 0
end

-- ====================================================
--  🛠️ SAFE TOOL EQUIPPING HELPER
-- ====================================================
local function equipToolSafely(tool)
	if not tool or not tool.Parent then return false end
	local char = player.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if not hum then return false end
	if tool.Parent == char then return true end
	
	hum:EquipTool(tool)
	local start = tick()
	while tool.Parent ~= char and tick() - start < 1.8 do
		task.wait(0.05)
	end
	task.wait(0.25)
	return tool.Parent == char
end

-- ====================================================
--  🌱 FAST AUTO PLANT SEEDS (MAX 25 PLANTS PER PLOT)
-- ====================================================
local function findPlantableSeedTool()
	local bp = player:FindFirstChild("Backpack")
	local char = player.Character
	local function checkTool(t)
		if isSeedTool(t) then
			local tName = t.Name
			local seedRarity = PLANT_TO_RARITY[tName] or t:GetAttribute("Rarity") or "Common"
			if seedRarity == "" then seedRarity = "Common" end
			
			if S.selectedPlantSeeds[tName] == true or S.selectedPlantRarities[seedRarity] == true then
				return t, tName, seedRarity
			end
		end
		return nil, nil, nil
	end
	if char then
		for _, t in ipairs(char:GetChildren()) do
			local match, sName, r = checkTool(t)
			if match then return match, sName, r end
		end
	end
	if bp then
		for _, t in ipairs(bp:GetChildren()) do
			local match, sName, r = checkTool(t)
			if match then return match, sName, r end
		end
	end
	return nil, nil, nil
end

local function runAutoPlantSpecificSeedsCycle()
	if not S.autoFarmEnabled and not S.autoPlantSeedsEnabled then return end
	
	local myPlot = getMyGardenPlot()
	if not myPlot then return end
	
	local char = player.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local origCFrame = root and root.CFrame
	
	local plantedInCycle = 0
	for _, plotPart in ipairs(myPlot:GetChildren()) do
		if plantedInCycle >= 4 then break end
		if plotPart.Name:lower():find("plot") and not plotPart.Name:lower():find("egg") then
			local isLocked = false
			for _, p in ipairs(plotPart:GetDescendants()) do
				if p:IsA("ProximityPrompt") and (p.ActionText:lower():find("lock") or p.ObjectText:lower():find("lock")) then
					isLocked = true; break
				end
			end
			
			if not isLocked then
				local plantedModels = {}
				for _, c in ipairs(plotPart:GetChildren()) do
					if c:IsA("Model") and (c:GetAttribute("IsPlantedPlant") or c.Name ~= "GardenPlot") then
						table.insert(plantedModels, c)
					end
				end
				
				if #plantedModels < 25 then
					local gardenPlotPart = plotPart:FindFirstChild("GardenPlot") or plotPart:FindFirstChildWhichIsA("BasePart")
					if gardenPlotPart then
						local origin = gardenPlotPart.Position
						local size = gardenPlotPart.Size
						
						local existingPositions = {}
						for _, m in ipairs(plantedModels) do
							table.insert(existingPositions, m:GetPivot().Position)
						end
						
						local xStep = math.max(3.2, size.X / 6)
						local zStep = math.max(3.2, size.Z / 8)
						
						for x = -size.X/2 + 2, size.X/2 - 2, xStep do
							if plantedInCycle >= 4 or (#plantedModels + plantedInCycle) >= 25 then break end
							for z = -size.Z/2 + 2, size.Z/2 - 2, zStep do
								if plantedInCycle >= 4 or (#plantedModels + plantedInCycle) >= 25 then break end
								
								local spot = origin + Vector3.new(x, 0.5, z)
								local tooClose = false
								for _, ex in ipairs(existingPositions) do
									if (Vector3.new(spot.X, 0, spot.Z) - Vector3.new(ex.X, 0, ex.Z)).Magnitude < 3.0 then
										tooClose = true; break
									end
								end
								
								if not tooClose then
									local seedTool, seedName, seedRarity = findPlantableSeedTool()
									if not seedTool then break end
									
									equipToolSafely(seedTool)
									if root and hum then
										root.CFrame = CFrame.new(spot + Vector3.new(0, 2.5, 0))
										task.wait(0.12)
										if R.PlantPlacementReq then
											pcall(function() R.PlantPlacementReq:FireServer(spot, gardenPlotPart, seedTool) end)
										end
										seedTool:Activate()
										task.wait(0.18)
										
										table.insert(existingPositions, spot)
										plantedInCycle = plantedInCycle + 1
										S.seedsPlantedCount = S.seedsPlantedCount + 1
										if _G.MFGToast then
											_G.MFGToast("🌱 Seed Planted", "Planted " .. seedName .. " on " .. plotPart.Name .. " (" .. (#plantedModels + plantedInCycle) .. "/25)!", Color3.fromRGB(80, 220, 120))
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	if root and origCFrame and plantedInCycle > 0 then
		task.wait(0.15)
		root.CFrame = origCFrame
	end
end

task.spawn(function()
	while true do
		task.wait(1.5)
		if S.autoPlantSeedsEnabled then
			pcall(runAutoPlantSpecificSeedsCycle)
		end
	end
end)

-- ====================================================
--  💧 AUTO WATER GROWING PLANTS (THOROUGH WATERING)
-- ====================================================
local function findWateringCanTool()
	local bp = player:FindFirstChild("Backpack")
	local char = player.Character
	local basicCan = nil
	local function checkCan(t)
		if t:IsA("Tool") and t.Name == "Watering Can" then
			basicCan = t
		end
	end
	if char then for _, t in ipairs(char:GetChildren()) do checkCan(t) end end
	if bp then for _, t in ipairs(bp:GetChildren()) do checkCan(t) end end
	-- Fallback to any tool with IsWateringCan if basic named tool not found
	if not basicCan then
		local function checkFallback(t)
			if t:IsA("Tool") and t:GetAttribute("IsWateringCan") == true and not t.Name:lower():find("aqua") then
				basicCan = t
			end
		end
		if char then for _, t in ipairs(char:GetChildren()) do checkFallback(t) end end
		if bp then for _, t in ipairs(bp:GetChildren()) do checkFallback(t) end end
	end
	return basicCan
end

local function isPlantUngrown(model)
	if not model or not model:IsA("Model") then return false end
	if model.Name:lower():find("gardenplot") then return false end
	if model:GetAttribute("IsPlantedPlant") ~= true then return false end
	
	-- 1) JustPlanted = true means actively growing
	if model:GetAttribute("JustPlanted") == true then
		return true
	end
	-- 2) HasPlantingSequence = true means going through planting sequence
	if model:GetAttribute("HasPlantingSequence") == true then
		return true
	end
	-- 3) SizeTier or RolledSize is nil until fully grown
	if model:GetAttribute("SizeTier") == nil or model:GetAttribute("RolledSize") == nil then
		return true
	end
	return false
end

local function runAutoWaterCycle()
	if not S.autoFarmEnabled and not S.autoWaterEnabled then return end
	local canTool = findWateringCanTool()
	if not canTool then return end

	local myPlot = getMyGardenPlot()
	if not myPlot then return end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local origCFrame = root and root.CFrame
	if not root then return end

	-- Collect growing (ungrown) plants
	local ungrownPlants = {}
	for _, plotPart in ipairs(myPlot:GetChildren()) do
		if plotPart.Name:lower():find("plot") and not plotPart.Name:lower():find("egg") then
			for _, model in ipairs(plotPart:GetChildren()) do
				if model:IsA("Model") and isPlantUngrown(model) then
					table.insert(ungrownPlants, model)
				end
			end
		end
	end

	if #ungrownPlants == 0 then return end

	-- Equip basic watering can
	equipToolSafely(canTool)
	task.wait(0.25)

	-- Teleport directly to each individual growing plant and fire watering request
	for i, model in ipairs(ungrownPlants) do
		if not S.autoWaterEnabled then break end
		if not model.Parent then continue end

		local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
		if part then
			local pos = part.Position
			root.CFrame = CFrame.new(pos + Vector3.new(0, 1.8, 0))
			task.wait(0.2)

			if R.WateringCanUseReq then
				pcall(function()
					R.WateringCanUseReq:FireServer(pos)
				end)
			end
			pcall(function() canTool:Activate() end)

			S.wateredCount = S.wateredCount + 1
			if _G.MFGToast and (i == 1 or i == #ungrownPlants) then
				_G.MFGToast("💧 Watered Plant", model.Name .. " (" .. i .. "/" .. #ungrownPlants .. ")", Color3.fromRGB(80, 200, 255))
			end
			task.wait(0.25)
		end
	end

	if root and origCFrame then
		task.wait(0.2)
		root.CFrame = origCFrame
	end
end

task.spawn(function()
	while true do
		task.wait(4.5)
		if S.autoWaterEnabled then
			pcall(runAutoWaterCycle)
		end
	end
end)

-- ====================================================
--  🗑️ AUTO DELETE PETS (WITH SAFE TIER & MUTATION PROTECTION)
-- ====================================================
local function isPetProtected(tool)
	if not tool or not tool:IsA("Tool") then return true end
	local mutation = tool:GetAttribute("MutationType") or tool:GetAttribute("Mutation")
	if S.keepMutatedPets and mutation and mutation ~= "" and mutation ~= "None" then
		return true
	end
	local petRarity = tool:GetAttribute("PetRarity") or tool:GetAttribute("Rarity") or "Common"
	if S.protectedPetRarities[petRarity] == true then
		return true
	end
	return false
end

local function runAutoDeletePetsCycle()
	if not S.autoDeletePetsEnabled then return end
	local bp = player:FindFirstChild("Backpack")
	if not bp then return end
	
	for _, t in ipairs(bp:GetChildren()) do
		if t:IsA("Tool") and not isPetProtected(t) then
			local tName = t.Name
			for petName, isSel in pairs(S.selectedDeletePets) do
				if isSel and (tName:lower() == petName:lower() or tName:lower():find(petName:lower())) then
					if R.DeletePetRequest then
						pcall(function() R.DeletePetRequest:FireServer(t) end)
					end
					pcall(function() t:Destroy() end)
					S.petsDeletedCount = S.petsDeletedCount + 1
					if _G.MFGToast then
						_G.MFGToast("🗑️ Pet Deleted", "Purged unwanted pet: " .. tName, Color3.fromRGB(240, 71, 71))
					end
					task.wait(0.2)
				end
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(4)
		if S.autoDeletePetsEnabled then
			pcall(runAutoDeletePetsCycle)
		end
	end
end)

-- ====================================================
--  💰 AUTO SELL PLANTS (WITH MUTATION & STAR PROTECTION)
-- ====================================================
local function isPlantProtected(tool)
	if not tool or not tool:IsA("Tool") then return true end
	local mutation = tool:GetAttribute("MutationType") or tool:GetAttribute("Mutation")
	if S.keepMutatedPlants and mutation and mutation ~= "" and mutation ~= "None" then
		return true
	end
	local mergeCount = safeNum(tool:GetAttribute("MergeCount") or tool:GetAttribute("StarLevel") or tool:GetAttribute("Star"), 0)
	if S.keepMergedPlants and mergeCount > 0 then
		return true
	end
	local plantRarity = PLANT_TO_RARITY[tool.Name] or "Common"
	if not S.selectedSellRarities[plantRarity] then
		return true
	end
	return false
end

local function runAutoSellPlantsCycle()
	if not S.autoSellPlantsEnabled then return end
	local bp = player:FindFirstChild("Backpack")
	local char = player.Character
	if not bp then return end
	
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local origCFrame = root and root.CFrame
	
	local sellPart = workspace:FindFirstChild("Stalls") and workspace.Stalls:FindFirstChild("SellPart")
	local sellPos = sellPart and sellPart.Position or Vector3.new(245.67, 217.9, -41.5)
	
	local itemsToSell = {}
	for _, t in ipairs(bp:GetChildren()) do
		if isGrownPlantTool(t) and not isPlantProtected(t) then
			local plantRarity = PLANT_TO_RARITY[t.Name] or "Common"
			table.insert(itemsToSell, {tool = t, rarity = plantRarity})
		end
	end
	
	if #itemsToSell > 0 and root then
		root.CFrame = CFrame.new(sellPos + Vector3.new(0, 3, 0))
		task.wait(0.2)
		
		for _, item in ipairs(itemsToSell) do
			if item.tool and item.tool.Parent then
				equipToolSafely(item.tool)
				if R.SellRequest then
					pcall(function() R.SellRequest:InvokeServer("SellThis") end)
					pcall(function() R.SellRequest:InvokeServer(item.tool) end)
				end
				S.plantsSoldCount = S.plantsSoldCount + 1
				if _G.MFGToast then
					_G.MFGToast("💰 Plant Sold", "Sold " .. item.tool.Name .. " (" .. item.rarity .. ")!", Color3.fromRGB(55, 215, 95))
				end
				task.wait(0.15)
			end
		end
		
		if root and origCFrame then
			task.wait(0.15)
			root.CFrame = origCFrame
		end
	end
end

task.spawn(function()
	while true do
		task.wait(5)
		if S.autoSellPlantsEnabled then
			pcall(runAutoSellPlantsCycle)
		end
	end
end)

-- ====================================================
--  🌿 STRICT GROWN PLANT AUTO MERGE (SAME TIER & MUTATION)
-- ====================================================
local function triggerFusionPrompt(prompt)
	if not prompt or not prompt.Enabled then return end
	if fireproximityprompt then
		pcall(function() fireproximityprompt(prompt, 0) end)
	else
		pcall(function()
			prompt:InputHoldBegin()
			task.wait(0.1)
			prompt:InputHoldEnd()
		end)
	end
	task.wait(0.4)
end

local function findMatchingPlantPairInInventory()
	local bp = player:FindFirstChild("Backpack")
	local char = player.Character
	if not bp then return nil, nil end
	
	-- Check if a plant filter is set
	local hasFilter = false
	for _, v in pairs(S.selectedMergePlants) do
		if v then hasFilter = true; break end
	end
	
	local plantTools = {}
	local function scanContainer(cont)
		if not cont then return end
		for _, t in ipairs(cont:GetChildren()) do
			-- Official game logic: PlantID ~= nil AND SizeRolled == true = grown/shoveled plant
			if isGrownPlantTool(t) then
				-- Apply plant name filter if any are selected
				if hasFilter and not S.selectedMergePlants[t.Name] then
					-- Skip this plant — it's not selected for merging
				else
					local tier = getPlantTier(t)
					local mutation = t:GetAttribute("MutationType") or t:GetAttribute("Mutation") or ""
					local mergeCount = t:GetAttribute("MergeCount") or 0
					local key = t.Name .. "|T" .. tostring(tier) .. "|M" .. tostring(mutation) .. "|S" .. tostring(mergeCount)
					if not plantTools[key] then plantTools[key] = {} end
					table.insert(plantTools[key], t)
				end
			end
		end
	end
	
	scanContainer(bp)
	scanContainer(char)
	
	for key, tools in pairs(plantTools) do
		if #tools >= 2 then
			return tools[1], tools[2], key
		end
	end
	return nil, nil, nil
end

-- Returns true if the FusionMachine is fully clear and ready for a new merge
local function isMachineReadyForNewMerge()
	local fm = workspace:FindFirstChild("FusionMachine")
	if not fm then return false end
	local p1Part = fm:FindFirstChild("Plant1")
	local p2Part = fm:FindFirstChild("Plant2")
	local mergePart = fm:FindFirstChild("Merge")
	if not p1Part or not p2Part or not mergePart then return false end

	local p1Prompt = p1Part:FindFirstChildWhichIsA("ProximityPrompt", true)
	local p2Prompt = p2Part:FindFirstChildWhichIsA("ProximityPrompt", true)
	local mergePrompt = mergePart:FindFirstChildWhichIsA("ProximityPrompt", true)

	-- Both slots empty ("Add Plant") AND Merge says "Merge" not "Claim"
	local p1Empty = p1Prompt and p1Prompt.ActionText == "Add Plant"
	local p2Empty = p2Prompt and p2Prompt.ActionText == "Add Plant"
	local mergeReady = mergePrompt and mergePrompt.ActionText == "Merge"
	return p1Empty and p2Empty and mergeReady
end

local function claimFusionSeedOrResult()
	local fm = workspace:FindFirstChild("FusionMachine")
	if not fm then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- PRIMARY: After merge the Merge part itself switches to "Claim" ActionText
	-- This is where the merged result (or returned plant on fail) appears
	local mergePart = fm:FindFirstChild("Merge")
	if mergePart then
		local mergePrompt = mergePart:FindFirstChildWhichIsA("ProximityPrompt", true)
		if mergePrompt and mergePrompt.Enabled and mergePrompt.ActionText == "Claim" then
			root.CFrame = CFrame.new(mergePart.Position + Vector3.new(0, 1.5, 0))
			task.wait(0.3)
			triggerFusionPrompt(mergePrompt)
			task.wait(0.8)
		end
	end

	-- FALLBACK: Result part (may appear on success in some versions)
	local resultPart = fm:FindFirstChild("Result")
	if resultPart then
		local resultPrompt = resultPart:FindFirstChildWhichIsA("ProximityPrompt", true)
		if resultPrompt and resultPrompt.Enabled then
			root.CFrame = CFrame.new(resultPart.Position + Vector3.new(0, 1.5, 0))
			task.wait(0.25)
			triggerFusionPrompt(resultPrompt)
			task.wait(0.5)
		end
	end

	-- FALLBACK: ResultBin (seed reward on failure in some versions)
	local resultBin = fm:FindFirstChild("ResultBin")
	if resultBin then
		local binPrompt = resultBin:FindFirstChildWhichIsA("ProximityPrompt", true)
		if binPrompt and binPrompt.Enabled then
			root.CFrame = CFrame.new(resultBin.Position + Vector3.new(0, 1.5, 0))
			task.wait(0.25)
			triggerFusionPrompt(binPrompt)
			task.wait(0.5)
		end
	end
end

-- Helper: fire FusionMergeConfirm directly to skip GUI and animation
local function waitAndClickProceed(maxWait)
	pcall(function()
		R.FusionMergeConfirm:FireServer("proceed")
	end)
	task.wait(0.15)
	return true
end

local function runAutoMergeCycle()
	if S.isMergingNow then return end
	if not S.autoFarmEnabled and not S.autoMergePlantsEnabled then return end

	local fm = workspace:FindFirstChild("FusionMachine")
	if not fm then return end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local origCFrame = root and root.CFrame
	if not root then return end

	-- STEP 0: Close any leftover confirm GUI first
	local pg = player:FindFirstChild("PlayerGui")
	local fusionGui = pg and pg:FindFirstChild("Fusion")
	local mf = fusionGui and fusionGui:FindFirstChild("MainFrame")
	if mf and mf.Visible then
		pcall(function() R.FusionMergeConfirm:FireServer("cancel") end)
		task.wait(0.15)
	end

	-- STEP 0B: Claim any pending result/seed from previous merge
	claimFusionSeedOrResult()
	task.wait(0.2)

	-- STEP 0C: Wait until BOTH slots are empty (both show "Add Plant")
	local waitStart = tick()
	while not isMachineReadyForNewMerge() and tick() - waitStart < 4 do
		task.wait(0.15)
	end
	if not isMachineReadyForNewMerge() then return end

	S.isMergingNow = true

	local p1, p2, matchKey = findMatchingPlantPairInInventory()
	if not p1 or not p2 then
		S.isMergingNow = false
		return
	end

	local plant1Prompt = fm.Plant1:FindFirstChildWhichIsA("ProximityPrompt", true)
	local plant2Prompt = fm.Plant2:FindFirstChildWhichIsA("ProximityPrompt", true)
	local mergePrompt  = fm.Merge:FindFirstChildWhichIsA("ProximityPrompt", true)

	if _G.MFGToast then
		_G.MFGToast("🌿 Merging...", "Merging 2x " .. p1.Name, Color3.fromRGB(140, 200, 255))
	end

	-- STEP 1: Place Plant 1 in left slot
	equipToolSafely(p1)
	task.wait(0.15)
	root.CFrame = CFrame.new(fm.Plant1.Position + Vector3.new(0, 1.5, 0))
	task.wait(0.15)
	if plant1Prompt and plant1Prompt.Enabled then
		triggerFusionPrompt(plant1Prompt)
	end
	waitAndClickProceed(2)
	task.wait(0.2)

	-- STEP 2: Place Plant 2 in right slot
	equipToolSafely(p2)
	task.wait(0.15)
	root.CFrame = CFrame.new(fm.Plant2.Position + Vector3.new(0, 1.5, 0))
	task.wait(0.15)
	plant2Prompt = fm.Plant2:FindFirstChildWhichIsA("ProximityPrompt", true)
	if plant2Prompt and plant2Prompt.Enabled then
		triggerFusionPrompt(plant2Prompt)
	end
	waitAndClickProceed(2)
	task.wait(0.2)

	-- STEP 3: Wait for both slots to show "Remove Plant" (both loaded)
	local bothLoaded = false
	for _ = 1, 20 do
		local pp1 = fm.Plant1:FindFirstChildWhichIsA("ProximityPrompt", true)
		local pp2 = fm.Plant2:FindFirstChildWhichIsA("ProximityPrompt", true)
		if pp1 and pp1.ActionText == "Remove Plant" and pp2 and pp2.ActionText == "Remove Plant" then
			bothLoaded = true; break
		end
		task.wait(0.15)
	end

	if not bothLoaded then
		-- Something went wrong — bail out
		S.isMergingNow = false
		if root and origCFrame then root.CFrame = origCFrame end
		return
	end

	-- STEP 4: Press Merge
	mergePrompt = fm.Merge:FindFirstChildWhichIsA("ProximityPrompt", true)
	root.CFrame = CFrame.new(fm.Merge.Position + Vector3.new(0, 1.5, 0))
	task.wait(0.15)
	if mergePrompt and mergePrompt.Enabled then
		triggerFusionPrompt(mergePrompt)
	end
	waitAndClickProceed(2)
	task.wait(0.2)

	-- STEP 5: Wait for merge animation to finish
	-- The Merge part's ActionText changes to "Claim" when the result is ready
	local mergeFinished = false
	for _ = 1, 30 do  -- up to ~4.5 seconds
		local mp = fm.Merge:FindFirstChildWhichIsA("ProximityPrompt", true)
		if mp and mp.ActionText == "Claim" then
			mergeFinished = true; break
		end
		task.wait(0.15)
	end
	task.wait(0.15)

	-- STEP 6: Teleport to center and claim the result plant
	claimFusionSeedOrResult()
	task.wait(0.2)

	S.mergesCompletedCount = S.mergesCompletedCount + 1
	if _G.MFGToast then
		_G.MFGToast("🌿 Merge Done!", "Claimed result for " .. p1.Name, Color3.fromRGB(80, 240, 140))
	end

	if root and origCFrame then
		task.wait(0.2)
		root.CFrame = origCFrame
	end

	S.isMergingNow = false
end

task.spawn(function()
	while true do
		task.wait(2)
		if S.autoMergePlantsEnabled then
			pcall(runAutoMergeCycle)
		end
	end
end)

-- ====================================================
--  🪓 AUTO SHOVEL GROWN PLANTS (SELECTED PLANTS ONLY)
-- ====================================================
local function findShovelTool()
	local bp = player:FindFirstChild("Backpack")
	local char = player.Character
	if char then
		for _, t in ipairs(char:GetChildren()) do
			if t:IsA("Tool") and t.Name:lower():find("shovel") then return t end
		end
	end
	if bp then
		for _, t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") and t.Name:lower():find("shovel") then return t end
		end
	end
	return nil
end

local function runAutoShovelCycle()
	if not S.autoFarmEnabled and not S.autoShovelEnabled then return end

	local hasFilter = false
	for _, v in pairs(S.selectedShovelPlants) do
		if v then hasFilter = true; break end
	end
	for _, v in pairs(S.shovelRarities) do
		if v then hasFilter = true; break end
	end
	if not hasFilter then return end  -- Only shovel plants you explicitly checked OR checked rarities

	-- Match filter: shovel if this plant type is checked, OR its rarity group is checked
	local function shovelWantsPlant(model)
		if S.selectedShovelPlants[model.Name] == true then return true end
		if S.shovelRarities[PLANT_TO_RARITY[model.Name]] == true then return true end
		return false
	end

	-- Protection check: skip plants above tier, with mutation, or above star count
	local function isShovelProtected(model)
		-- Tier check: SizeTier = "Scale +1" → T1, "Scale +3" → T3 etc.
		if S.shovelProtectHighTier then
			local sizeTier = model:GetAttribute("SizeTier") or ""
			local tierNum = tonumber(sizeTier:match("%+(%d+)")) or 0
			if tierNum > S.shovelMaxTier then
				return true  -- above max tier → protected
			end
		end
		-- Mutation check
		if S.shovelProtectMutated then
			local mutation = model:GetAttribute("MutationType") or ""
			if mutation ~= "" and mutation ~= "None" then
				return true  -- has mutation → protected
			end
		end
		-- Stars check (MergeCount = number of merge stars)
		if S.shovelProtectHighStars then
			local stars = model:GetAttribute("MergeCount") or 0
			if stars > S.shovelMaxStars then
				return true  -- above max stars → protected
			end
		end
		return false
	end
	
	local shovelTool = findShovelTool()
	if not shovelTool then return end
	
	local myPlot = getMyGardenPlot()
	if not myPlot then return end
	
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local origCFrame = root and root.CFrame
	
	-- Collect models to shovel (IsPlantedPlant == true, selected, not protected)
	local toShovel = {}
	for _, plotPart in ipairs(myPlot:GetChildren()) do
		if plotPart.Name:lower():find("plot") and not plotPart.Name:lower():find("egg") then
			local isLocked = false
			for _, d in ipairs(plotPart:GetDescendants()) do
				if d:IsA("ProximityPrompt") and (d.ActionText:lower():find("lock") or d.ObjectText:lower():find("lock")) then
					isLocked = true; break
				end
			end
			if not isLocked then
				for _, model in ipairs(plotPart:GetChildren()) do
					if model:IsA("Model") and model.Name ~= "GardenPlot"
					   and model:GetAttribute("IsPlantedPlant") == true
					   and model:GetAttribute("RolledSize") == 1  -- fully grown/shovelable (planted models use RolledSize, not SizeRolled)
					   and shovelWantsPlant(model)
					   and not isShovelProtected(model) then  -- skip protected tiers, mutated, protected stars
						table.insert(toShovel, model)
					end
				end
			end
		end
	end
	
	if #toShovel == 0 then return end
	
	-- Equip shovel once
	equipToolSafely(shovelTool)
	task.wait(0.2)
	
	for _, model in ipairs(toShovel) do
		if not S.autoShovelEnabled then break end
		if model and model.Parent then
			local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
			if part and root then
				root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
				task.wait(0.2)
				-- Fire ShovelUprootRequest directly
				if R.ShovelUprootRequest then
					pcall(function() R.ShovelUprootRequest:FireServer(model) end)
				else
					-- Fallback: activate tool (clicks on the plant)
					shovelTool:Activate()
				end
				task.wait(0.25)
				S.shovelsCount = S.shovelsCount + 1
				if _G.MFGToast then
					_G.MFGToast("🪓 Shoveled!", "Dug up " .. model.Name .. "!", Color3.fromRGB(200, 160, 80))
				end
			end
		end
	end
	
	if root and origCFrame then
		task.wait(0.2)
		root.CFrame = origCFrame
	end
end

task.spawn(function()
	while true do
		task.wait(3)
		if S.autoShovelEnabled then
			pcall(runAutoShovelCycle)
		end
	end
end)

-- ====================================================
--  🌾 AUTO FARM MASTER MODE (ORDERED PIPELINE)
--  Runs: PLANT -> WATER -> SHOVEL -> MERGE
--  One phase at a time (guarded by farmPhaseActive) so
--  the character never teleports erratically between four
--  competing timers. Each phase only runs when it actually
--  has something to do.
-- ====================================================
local function plotStats()
	-- Returns {room = bool, growing = int, grown = int} across my plots
	local myPlot = getMyGardenPlot()
	if not myPlot then return {room = false, growing = 0, grown = 0} end
	local growing, grown = 0, 0
	local anyUnlockedRoom = false
	for _, plotPart in ipairs(myPlot:GetChildren()) do
		if plotPart.Name:lower():find("plot") and not plotPart.Name:lower():find("egg") then
			local isLocked = false
			for _, d in ipairs(plotPart:GetDescendants()) do
				if d:IsA("ProximityPrompt") and (d.ActionText:lower():find("lock") or d.ObjectText:lower():find("lock")) then
					isLocked = true; break
				end
			end
			if not isLocked then
				local count = 0
				for _, m in ipairs(plotPart:GetChildren()) do
					if m:IsA("Model") and m:GetAttribute("IsPlantedPlant") == true then
						count = count + 1
						if m:GetAttribute("RolledSize") == 1 then grown = grown + 1 else growing = growing + 1 end
					end
				end
				if count < 25 then anyUnlockedRoom = true end
			end
		end
	end
	return {room = anyUnlockedRoom, growing = growing, grown = grown}
end

local function runAutoFarmPipeline()
	if not S.autoFarmEnabled or S.farmPhaseActive then return end
	S.farmPhaseActive = true
	pcall(function()
		local stats = plotStats()
		if _G.MFGToast then
			_G.MFGToast("🌾 Auto Farm", "Plant→Water→Shovel→Merge | growing: " .. stats.growing .. ", grown: " .. stats.grown .. ", room: " .. tostring(stats.room), Color3.fromRGB(88, 240, 140))
		end

		-- PHASE 1: PLANT (only if a plot still has room)
		if stats.room then
			runAutoPlantSpecificSeedsCycle()
			task.wait(0.4)
		end

		-- PHASE 2: WATER (only if something is growing)
		stats = plotStats()
		if stats.growing > 0 then
			runAutoWaterCycle()
			task.wait(0.4)
		end

		-- PHASE 3: SHOVEL (only if something is grown & selected)
		stats = plotStats()
		if stats.grown > 0 then
			runAutoShovelCycle()
			task.wait(0.4)
		end

		-- PHASE 4: MERGE (uses inventory pairs; self-guards with isMergingNow)
		runAutoMergeCycle()
		task.wait(0.4)
	end)
	S.farmPhaseActive = false
end

task.spawn(function()
	task.wait(1)
	while true do
		task.wait(4)
		if S.autoFarmEnabled then
			pcall(runAutoFarmPipeline)
		end
	end
end)

-- ====================================================
--  🛠️ GEAR SHOP AUTO BUY
-- ====================================================
task.spawn(function()
	while true do
		task.wait(4)
		if S.autoBuyGearsEnabled and R.GetGearState and R.GearShopBuyReq then
			local ok, data = pcall(function() return R.GetGearState:InvokeServer() end)
			if ok and type(data) == "table" and data.stock then
				for gearKey, isSel in pairs(S.selectedGears) do
					if isSel and safeNum(data.stock[gearKey], 0) > 0 then
						local buyOk = pcall(function() R.GearShopBuyReq:FireServer(gearKey) end)
						if buyOk then
							S.gearBoughtCount = S.gearBoughtCount + 1
							if _G.MFGToast then
								_G.MFGToast("🛠️ Bought Gear", "Purchased " .. gearKey .. "!", Color3.fromRGB(80, 190, 255))
							end
							task.wait(0.5)
						end
					end
				end
			end
		end
	end
end)

-- ====================================================
--  🥚 FIXED AUTO PLACE EGGS (AUTO-EQUIP TOOL)
-- ====================================================
local function findEggToolInInventory()
	local bp = player:FindFirstChild("Backpack")
	local char = player.Character
	if char then
		for _, t in ipairs(char:GetChildren()) do
			if t:IsA("Tool") and t.Name:lower():find("egg") then return t end
		end
	end
	if bp then
		for _, t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") and t.Name:lower():find("egg") then return t end
		end
	end
	return nil
end

local function runAutoPlaceEggsCycle()
	if not S.autoPlaceEggsEnabled then return end
	local eggTool = findEggToolInInventory()
	if not eggTool then return end
	
	local myPlot = getMyGardenPlot()
	if not myPlot then return end
	
	local char = player.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local origCFrame = root and root.CFrame
	
	for _, child in ipairs(myPlot:GetChildren()) do
		if child.Name:lower():find("eggplot") or child.Name:lower():find("nest") then
			local prompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
			if prompt and prompt.Enabled and (prompt.ActionText:lower():find("place") or prompt.ObjectText:lower():find("place") or prompt.ActionText == "") then
				if eggTool.Parent == player.Backpack and hum then
					hum:EquipTool(eggTool)
					task.wait(0.15)
				end
				
				local part = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart")
				if part and root then
					root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2.5, 0))
					task.wait(0.15)
					triggerPromptWithHold(prompt, 0.3)
					task.wait(0.2)
					S.eggsPlacedCount = S.eggsPlacedCount + 1
					if _G.MFGToast then
						_G.MFGToast("🥚 Egg Placed", "Placed " .. eggTool.Name .. " in incubator nest!", Color3.fromRGB(255, 215, 80))
					end
					break
				end
			end
		end
	end
	
	if root and origCFrame then
		task.wait(0.15)
		root.CFrame = origCFrame
	end
end

task.spawn(function()
	while true do
		task.wait(3.5)
		if S.autoPlaceEggsEnabled then
			pcall(runAutoPlaceEggsCycle)
		end
	end
end)

-- ====================================================
--  🐣 AUTO HATCH EGGS (INSTANT PET CLAIMER)
-- ====================================================
local function runAutoHatchEggsCycle()
	if not S.autoHatchEggsEnabled then return end
	local myPlot = getMyGardenPlot()
	if not myPlot then return end
	
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local origCFrame = root and root.CFrame
	
	for _, child in ipairs(myPlot:GetChildren()) do
		if child.Name:lower():find("eggplot") or child.Name:lower():find("nest") then
			local prompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
			if prompt and prompt.Enabled then
				local fullText = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. child.Name):lower()
				local isReady = fullText:find("hatch") or fullText:find("claim") or fullText:find("open") or fullText:find("ready")
				
				if not isReady then
					for _, lbl in ipairs(child:GetDescendants()) do
						if lbl:IsA("TextLabel") and lbl.Visible and (lbl.Text:find("0:00") or lbl.Text:lower():find("ready")) then
							isReady = true
							break
						end
					end
				end
				
				if isReady then
					local part = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart")
					if part and root then
						root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2.5, 0))
						task.wait(0.15)
						triggerPromptWithHold(prompt, 0.35)
						task.wait(0.2)
						S.eggsHatchedCount = S.eggsHatchedCount + 1
						if _G.MFGToast then
							_G.MFGToast("🐣 Pet Hatched!", "Claimed ready pet from nest!", Color3.fromRGB(80, 240, 180))
						end
						break
					end
				end
			end
		end
	end
	
	if root and origCFrame then
		task.wait(0.15)
		root.CFrame = origCFrame
	end
end

task.spawn(function()
	while true do
		task.wait(2.5)
		if S.autoHatchEggsEnabled then
			pcall(runAutoHatchEggsCycle)
		end
	end
end)

-- ====================================================
--  🌱 DEEP UNDERGROUND GHOST SEED BUY (-12 STUDS)
-- ====================================================
local function getSeedFromPrompt(prompt)
	if not prompt or not prompt.Enabled then return nil end
	local texts = {prompt.ObjectText, prompt.ActionText}
	-- Walk up to find the seed model name (e.g. Bellsora, Cotton Bloom)
	-- Hierarchy: ProximityPrompt -> Handle -> SeedModel -> Shop
	local handle = prompt.Parent
	if handle then
		table.insert(texts, handle.Name or "")
		local seedModel = handle.Parent
		if seedModel then
			table.insert(texts, seedModel.Name or "")
			-- Also check the shop folder name
			local shopFolder = seedModel.Parent
			if shopFolder then
				table.insert(texts, shopFolder.Name or "")
			end
		end
	end
	if prompt.Parent then
		for _, child in ipairs(prompt.Parent:GetChildren()) do
			if child:IsA("TextLabel") and child.Text and child.Text ~= "" then table.insert(texts, child.Text) end
		end
	end
	local combined = table.concat(texts, " "):lower()
	for seedName, isSelected in pairs(S.selectedSeeds) do
		if isSelected and combined:find(seedName:lower()) then return seedName end
	end
	return nil
end

local function sweepMerchantStalls()
	if not S.autoBuySeedsEnabled or S.isBuyingActive then return end
	S.isBuyingActive = true
	
	local matchingPrompts = {}
	local targetFolder = workspace:FindFirstChild("GameShops") or workspace
	for _, prompt in ipairs(targetFolder:GetDescendants()) do
		if prompt:IsA("ProximityPrompt") and prompt.Enabled then
			local seedName = getSeedFromPrompt(prompt)
			if seedName then
				local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
				if part then table.insert(matchingPrompts, {seedName = seedName, prompt = prompt, pos = part.Position}) end
			end
		end
	end
	
	for _, item in ipairs(matchingPrompts) do
		if not S.autoBuySeedsEnabled then break end
		if S.selectedSeeds[item.seedName] and item.prompt and item.prompt.Enabled then
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local origCFrame = root and root.CFrame
			
			if root then root.CFrame = CFrame.new(item.pos - Vector3.new(0, 12, 0)) end
			task.wait(0.2)
			if not S.autoBuySeedsEnabled then break end
			triggerPromptWithHold(item.prompt, 0.35)
			task.wait(0.18)
			
			local pg = player:FindFirstChild("PlayerGui")
			if pg then
				for _, gui in ipairs(pg:GetChildren()) do
					if gui:IsA("ScreenGui") and gui.Enabled then
						for _, obj in ipairs(gui:GetChildren()) do
							if obj:IsA("GuiButton") and obj.Visible and obj.Active then
								local t = obj.Name:lower() .. " " .. (obj:IsA("TextButton") and obj.Text:lower() or "")
								if t:find("yes") or t:find("confirm") or t:find("buy") or t:find("accept") then clickButton(obj) end
							end
						end
					end
				end
			end
			task.wait(0.15)
			if root and origCFrame then root.CFrame = origCFrame end
			S.seedBoughtCount = S.seedBoughtCount + 1
			if _G.MFGToast then
				_G.MFGToast("🌱 Seed Bought", "Purchased " .. item.seedName .. "!", Color3.fromRGB(80, 220, 120))
			end
			task.wait(0.4)
		end
	end
	S.isBuyingActive = false
end

task.spawn(function()
	while true do
		task.wait(2.5)
		if S.autoBuySeedsEnabled then pcall(sweepMerchantStalls) end
	end
end)

-- ====================================================
--  🥚 EGG SHOP AUTO BUY (TELEPORT TO EGG POTS + PROMPT)
--  Egg pots live in Workspace as "Common Egg" etc. models,
--  each holding a ProximityPrompt with ActionText "Buy Common Egg".
--  We teleport next to each selected egg pot and fire its prompt,
--  mirroring the seed-buy flow.
-- ====================================================
local function getEggNameFromPrompt(prompt)
	if not prompt or not prompt.Enabled then return nil end
	local combined = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. (prompt.Parent and prompt.Parent.Name or "") .. " " .. (prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Name or "")):lower()
	for eggName, isSelected in pairs(S.selectedEggs) do
		if isSelected then
			-- "Buy Common Egg" contains "common egg"
			local base = eggName:lower()
			if combined:find(base) then return eggName end
		end
	end
	return nil
end

task.spawn(function()
	while true do
		task.wait(2.5)
		if S.autoBuyEggsEnabled then
			pcall(function()
				local matching = {}
				for _, prompt in ipairs(workspace:GetDescendants()) do
					if prompt:IsA("ProximityPrompt") and prompt.Enabled then
						local eggName = getEggNameFromPrompt(prompt)
						if eggName then
							local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
							if part and part:IsDescendantOf(workspace) then
								matching[#matching + 1] = {eggName = eggName, prompt = prompt, pos = part.Position}
							end
						end
					end
				end
				for _, item in ipairs(matching) do
					if not S.autoBuyEggsEnabled then break end
					if S.selectedEggs[item.eggName] and item.prompt and item.prompt.Enabled then
						local char = player.Character
						local root = char and char:FindFirstChild("HumanoidRootPart")
						local origCFrame = root and root.CFrame
						if root then root.CFrame = CFrame.new(item.pos + Vector3.new(0, 2, 0)) end
						task.wait(0.2)
						if not S.autoBuyEggsEnabled then break end
						triggerPromptWithHold(item.prompt, 0.35)
						task.wait(0.2)
						-- Confirm any Yes/Confirm/Buy dialog
						local pg = player:FindFirstChild("PlayerGui")
						if pg then
							for _, gui in ipairs(pg:GetChildren()) do
								if gui:IsA("ScreenGui") and gui.Enabled then
									for _, obj in ipairs(gui:GetChildren()) do
										if obj:IsA("GuiButton") and obj.Visible and obj.Active then
											local t = obj.Name:lower() .. " " .. (obj:IsA("TextButton") and obj.Text:lower() or "")
											if t:find("yes") or t:find("confirm") or t:find("buy") or t:find("accept") or t:find("purchase") then clickButton(obj) end
										end
									end
								end
							end
						end
						if root and origCFrame then root.CFrame = origCFrame end
						S.eggBoughtCount = (S.eggBoughtCount or 0) + 1
						if _G.MFGToast then
							_G.MFGToast("🥚 Egg Bought", "Purchased " .. item.eggName .. "!", Color3.fromRGB(255, 215, 80))
						end
						task.wait(0.4)
					end
				end
			end)
		end
	end
end)

-- ====================================================
--  ☀️ GHOST-TP AUTO SUNSHINE COLLECT (EXACT SUNSHINE STORAGE SILO)
-- ====================================================
local function getMySunshineStoragePosition()
	local myPlot = getMyGardenPlot()
	if myPlot then
		local storage = myPlot:FindFirstChild("SunshineStorage") or myPlot:FindFirstChild("MoneyStorage")
		if storage then
			return storage:GetPivot().Position
		end
		for _, child in ipairs(myPlot:GetChildren()) do
			if child.Name:lower():find("sunshine") or child.Name:lower():find("storage") or child.Name:lower():find("money") or child.Name:lower():find("bank") or child.Name:lower():find("safe") then
				return child:GetPivot().Position
			end
		end
		return myPlot:GetPivot().Position
	end
	return LOCATIONS["Sunshine Storage"]
end

task.spawn(function()
	while true do
		task.wait(4.5)
		if S.autoCollectEnabled then
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local origCFrame = root and root.CFrame
			if root and origCFrame then
				local storagePos = getMySunshineStoragePosition()
				root.CFrame = CFrame.new(storagePos + Vector3.new(0, 2.5, 0))
				task.wait(0.2)
				
				local myPlot = getMyGardenPlot()
				local targetFolder = myPlot or workspace
				for _, prompt in ipairs(targetFolder:GetDescendants()) do
					if prompt:IsA("ProximityPrompt") and prompt.Enabled then
						local t = (prompt.ObjectText .. " " .. prompt.ActionText .. " " .. (prompt.Parent and prompt.Parent.Name or "")):lower()
						if t:find("deposit") or t:find("storage") or t:find("sunshine") or t:find("collect") or t:find("claim") then
							triggerPromptWithHold(prompt, 0.2)
						end
					end
				end
				
				task.wait(0.15)
				if root and origCFrame then root.CFrame = origCFrame end
				S.depositCount = S.depositCount + 1
				if _G.MFGToast then
					_G.MFGToast("☀️ Auto Collect", "Deposits collected from your Sunshine Storage & returned!", Color3.fromRGB(55, 215, 95))
				end
			end
		end
	end
end)

-- ====================================================
--  🎡 SMART AUTO SPIN WHEEL (WITH 10X/1M BUTTON CLICK + REMOTES)
-- ====================================================
local cachedSunLabel = nil
local function getPlayerSunshine()
	local ls = player:FindFirstChild("leaderstats")
	if ls then
		for _, child in ipairs(ls:GetChildren()) do
			if child.Name:lower():find("sun") or child.Name:lower():find("coin") or child.Name:lower():find("money") then
				if child:IsA("ValueBase") then
					local v = child.Value
					if type(v) == "number" then return v end
					local num = parseSuffixedNumber(tostring(v))
					if num then return num end
				end
			end
		end
	end
	for name, val in pairs(player:GetAttributes()) do
		if name:lower():find("sun") or name:lower():find("coin") then
			if type(val) == "number" then return val end
			local num = parseSuffixedNumber(tostring(val))
			if num then return num end
		end
	end
	if cachedSunLabel and cachedSunLabel.Parent and cachedSunLabel.Visible then
		local parsed = parseSuffixedNumber(cachedSunLabel.Text)
		if parsed and parsed > 0 then return parsed end
	end
	local pg = player:FindFirstChild("PlayerGui")
	if pg then
		for _, obj in ipairs(pg:GetChildren()) do
			if obj:IsA("ScreenGui") and obj.Enabled then
				for _, sub in ipairs(obj:GetChildren()) do
					if sub:IsA("GuiObject") and sub.Visible then
						for _, lbl in ipairs(sub:GetChildren()) do
							if lbl:IsA("TextLabel") and lbl.Visible and lbl.Text ~= "" then
								local t = lbl.Text:lower()
								if (t:find("sun") or t:find("☀️")) and (t:find("%d") or t:find("m") or t:find("k")) then
									local parsed = parseSuffixedNumber(lbl.Text)
									if parsed and parsed > 0 then
										cachedSunLabel = lbl
										return parsed
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return 0
end

local function executeSpinAction(tier)
	local is1M = (tier == "1m" or tier == "1M" or tier == "10x" or tier == "10")
	local pg = player:FindFirstChild("PlayerGui")
	if pg then
		local sw = pg:FindFirstChild("SpinningWheel")
		if sw then
			local bf = sw:FindFirstChild("WheelFrame") and sw.WheelFrame:FindFirstChild("ButtonFrame")
			if bf then
				local targetBtn = is1M and bf:FindFirstChild("Spin10x") or bf:FindFirstChild("Spin3x")
				if targetBtn then
					clickButton(targetBtn)
				end
			end
		end
	end
	if R.SpinRequest then
		if is1M then
			pcall(function() R.SpinRequest:FireServer(10) end)
			pcall(function() R.SpinRequest:FireServer("10x") end)
			pcall(function() R.SpinRequest:FireServer("1M") end)
		else
			pcall(function() R.SpinRequest:FireServer(1) end)
			pcall(function() R.SpinRequest:FireServer("1x") end)
			pcall(function() R.SpinRequest:FireServer("100k") end)
		end
		return true
	end
	return false
end

task.spawn(function()
	while true do
		task.wait(1.8)
		if S.autoSpinEnabled and not S.isSpinningNow then
			local liveSun = safeNum(getPlayerSunshine(), 0)
			local spendable = liveSun - S.minSpinSunshine
			
			if liveSun >= S.minSpinSunshine and spendable > 0 then
				local chosenTier = S.spinTier
				if chosenTier == "best" then
					chosenTier = (spendable >= 1000000) and "1m" or "100k"
				end
				
				local reqSun = (chosenTier == "1m") and 1000000 or 100000
				if spendable >= reqSun then
					S.isSpinningNow = true
					local ok = executeSpinAction(chosenTier)
					if ok then
						S.spinsCount = S.spinsCount + 1
						if _G.MFGToast then
							_G.MFGToast("🎡 Wheel Spun", "Spun (" .. (chosenTier == "1m" and "1M / 10x" or "100k / 1x") .. ") | Total: " .. S.spinsCount, Color3.fromRGB(255, 200, 50))
						end
					end
					task.wait(0.5)
					S.isSpinningNow = false
				end
			end
		end
	end
end)

-- ====================================================
--  🎨 MFG HUB SPEEDHUB MODERN GUI
-- ====================================================
local guiParent = nil
pcall(function() if gethui then guiParent = gethui() end end)
if not guiParent then
	pcall(function() guiParent = game:GetService("CoreGui") end)
end
if not guiParent then
	guiParent = player:WaitForChild("PlayerGui")
end

pcall(function()
	local old = guiParent:FindFirstChild("MFG_HUB_GUI")
	if old then old:Destroy() end
end)
pcall(function()
	local oldPg = player.PlayerGui:FindFirstChild("MFG_HUB_GUI")
	if oldPg then oldPg:Destroy() end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MFG_HUB_GUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

local C_BG       = Color3.fromRGB(13, 15, 22)
local C_SIDEBAR  = Color3.fromRGB(18, 20, 31)
local C_HEADER   = Color3.fromRGB(22, 25, 38)
local C_CARD     = Color3.fromRGB(23, 27, 42)
local C_ACCENT   = Color3.fromRGB(88, 101, 242)
local C_GREEN    = Color3.fromRGB(0, 230, 153)
local C_RED      = Color3.fromRGB(240, 71, 71)
local C_TEXT     = Color3.fromRGB(240, 240, 255)
local C_SUBTEXT  = Color3.fromRGB(140, 145, 175)
local C_BORDER   = Color3.fromRGB(40, 46, 70)

local function mkCorner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = obj
	return c
end

local function mkStroke(obj, col, th)
	local s = Instance.new("UIStroke")
	s.Color = col or C_BORDER
	s.Thickness = th or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
	return s
end

local function tw(obj, duration, props)
	local t = TweenSvc:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

-- ====================================================
--  TOAST NOTIFICATION ENGINE
-- ====================================================
local toastContainer = Instance.new("Frame")
toastContainer.Size = UDim2.new(0, 320, 1, -20)
toastContainer.Position = UDim2.new(1, -330, 0, 10)
toastContainer.BackgroundTransparency = 1
toastContainer.Parent = screenGui

local toastLayout = Instance.new("UIListLayout")
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
toastLayout.Padding = UDim.new(0, 8)
toastLayout.Parent = toastContainer

_G.MFGToast = function(title, msg, col)
	task.spawn(function()
		local t = Instance.new("Frame")
		t.Size = UDim2.new(0, 300, 0, 52)
		t.BackgroundColor3 = C_CARD
		t.Parent = toastContainer
		mkCorner(t, 8)
		mkStroke(t, col or C_ACCENT, 1.5)
		
		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(0, 4, 1, 0)
		bar.BackgroundColor3 = col or C_ACCENT
		bar.Parent = t
		mkCorner(bar, 4)
		
		local tLbl = Instance.new("TextLabel")
		tLbl.Size = UDim2.new(1, -20, 0, 20)
		tLbl.Position = UDim2.new(0, 14, 0, 6)
		tLbl.BackgroundTransparency = 1
		tLbl.TextColor3 = C_TEXT
		tLbl.Font = Enum.Font.GothamBold
		tLbl.TextSize = 13
		tLbl.TextXAlignment = Enum.TextXAlignment.Left
		tLbl.Text = title
		tLbl.Parent = t
		
		local mLbl = Instance.new("TextLabel")
		mLbl.Size = UDim2.new(1, -20, 0, 20)
		mLbl.Position = UDim2.new(0, 14, 0, 26)
		mLbl.BackgroundTransparency = 1
		mLbl.TextColor3 = C_SUBTEXT
		mLbl.Font = Enum.Font.Gotham
		mLbl.TextSize = 11
		mLbl.TextXAlignment = Enum.TextXAlignment.Left
		mLbl.TextTruncate = Enum.TextTruncate.AtEnd
		mLbl.Text = msg
		mLbl.Parent = t
		
		task.wait(3.5)
		tw(t, 0.3, {BackgroundTransparency = 1})
		tw(tLbl, 0.3, {TextTransparency = 1})
		tw(mLbl, 0.3, {TextTransparency = 1})
		tw(bar, 0.3, {BackgroundTransparency = 1})
		task.wait(0.35)
		t:Destroy()
	end)
end

-- ====================================================
--  MAIN MFG HUB WINDOW
-- ====================================================
local MAIN_W = 690
local MAIN_H = 440

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
mainFrame.Position = UDim2.new(0.5, -MAIN_W/2, 0.5, -MAIN_H/2)
mainFrame.BackgroundColor3 = C_BG
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
mkCorner(mainFrame, 12)
mkStroke(mainFrame, C_BORDER, 1.5)

local isDragging, dragStart, startPos = false, nil, nil
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)
UIS.InputChanged:Connect(function(input)
	if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
end)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = C_HEADER
header.BorderSizePixel = 0
header.Parent = mainFrame
mkCorner(header, 12)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -120, 1, 0)
titleLbl.Position = UDim2.new(0, 16, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.TextColor3 = C_TEXT
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 14
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Text = "⚡ MFG HUB  |  My Farmer's Garden v26"
titleLbl.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 26)
minBtn.Position = UDim2.new(1, -66, 0.5, -13)
minBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
minBtn.TextColor3 = C_TEXT
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.Text = "-"
minBtn.Parent = header
mkCorner(minBtn, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = C_RED
closeBtn.TextColor3 = C_TEXT
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Text = "X"
closeBtn.Parent = header
mkCorner(closeBtn, 6)

minBtn.MouseButton1Click:Connect(function()
	S.guiMinimized = not S.guiMinimized
	minBtn.Text = S.guiMinimized and "+" or "-"
	tw(mainFrame, 0.3, {Size = UDim2.new(0, MAIN_W, 0, S.guiMinimized and 42 or MAIN_H)})
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Sidebar
local SIDEBAR_W = 160
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -42)
sidebar.Position = UDim2.new(0, 0, 0, 42)
sidebar.BackgroundColor3 = C_SIDEBAR
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarScroll = Instance.new("ScrollingFrame")
sidebarScroll.Size = UDim2.new(1, -10, 1, -10)
sidebarScroll.Position = UDim2.new(0, 5, 0, 5)
sidebarScroll.BackgroundTransparency = 1
sidebarScroll.ScrollBarThickness = 3
sidebarScroll.ScrollBarImageColor3 = C_BORDER
sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebarScroll.Parent = sidebar

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 6)
sideLayout.Parent = sidebarScroll
sideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, sideLayout.AbsoluteContentSize.Y + 15)
end)

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -SIDEBAR_W - 10, 1, -52)
contentArea.Position = UDim2.new(0, SIDEBAR_W + 5, 0, 47)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

local tabs = {}
local tabButtons = {}

local function createTab(tabId, tabName, icon)
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 5
	page.ScrollBarImageColor3 = C_ACCENT
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Visible = false
	page.Parent = contentArea
	
	local pLayout = Instance.new("UIListLayout")
	pLayout.Padding = UDim.new(0, 8)
	pLayout.Parent = page
	
	pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 40)
	end)
	
	tabs[tabId] = page
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = C_CARD
	btn.TextColor3 = C_SUBTEXT
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Text = "  " .. icon .. "  " .. tabName
	btn.Parent = sidebarScroll
	mkCorner(btn, 6)
	local strk = mkStroke(btn, C_BORDER, 1)
	
	local function selectTab()
		for id, p in pairs(tabs) do p.Visible = false end
		for id, b in pairs(tabButtons) do
			b.btn.BackgroundColor3 = C_CARD
			b.btn.TextColor3 = C_SUBTEXT
			b.strk.Color = C_BORDER
		end
		page.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(35, 42, 68)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		strk.Color = C_ACCENT
		S.activeTab = tabId
	end
	
	btn.MouseButton1Click:Connect(selectTab)
	tabButtons[tabId] = {btn = btn, strk = strk, select = selectTab}
	return page
end

local function createSection(parent, title)
	local sec = Instance.new("TextLabel")
	sec.Size = UDim2.new(1, 0, 0, 24)
	sec.BackgroundTransparency = 1
	sec.TextColor3 = C_ACCENT
	sec.Font = Enum.Font.GothamBold
	sec.TextSize = 12
	sec.TextXAlignment = Enum.TextXAlignment.Left
	sec.Text = "  " .. title:upper()
	sec.Parent = parent
	return sec
end

local function createToggle(parent, title, desc, defaultState, onToggle)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 48)
	card.BackgroundColor3 = C_CARD
	card.Parent = parent
	mkCorner(card, 8)
	local strk = mkStroke(card, defaultState and C_GREEN or C_BORDER, 1)
	
	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -70, 0, 20)
	tLbl.Position = UDim2.new(0, 12, 0, 6)
	tLbl.BackgroundTransparency = 1
	tLbl.TextColor3 = C_TEXT
	tLbl.Font = Enum.Font.GothamBold
	tLbl.TextSize = 12
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Text = title
	tLbl.Parent = card
	
	local dLbl = Instance.new("TextLabel")
	dLbl.Size = UDim2.new(1, -70, 0, 16)
	dLbl.Position = UDim2.new(0, 12, 0, 26)
	dLbl.BackgroundTransparency = 1
	dLbl.TextColor3 = C_SUBTEXT
	dLbl.Font = Enum.Font.Gotham
	dLbl.TextSize = 10
	dLbl.TextXAlignment = Enum.TextXAlignment.Left
	dLbl.Text = desc or ""
	dLbl.Parent = card
	
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 46, 0, 24)
	toggleBtn.Position = UDim2.new(1, -56, 0.5, -12)
	toggleBtn.BackgroundColor3 = defaultState and C_GREEN or Color3.fromRGB(40, 45, 60)
	toggleBtn.TextColor3 = defaultState and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = 11
	toggleBtn.Text = defaultState and "ON" or "OFF"
	toggleBtn.Parent = card
	mkCorner(toggleBtn, 12)
	
	local isToggled = defaultState
	local function setToggle(val)
		isToggled = val
		toggleBtn.Text = isToggled and "ON" or "OFF"
		toggleBtn.BackgroundColor3 = isToggled and C_GREEN or Color3.fromRGB(40, 45, 60)
		toggleBtn.TextColor3 = isToggled and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
		strk.Color = isToggled and C_GREEN or C_BORDER
	end
	
	toggleBtn.MouseButton1Click:Connect(function()
		isToggled = not isToggled
		setToggle(isToggled)
		if onToggle then onToggle(isToggled) end
		saveConfig(false)
	end)
	
	return {card = card, set = setToggle}
end

local function createActionButton(parent, title, btnText, col, onClick)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 44)
	card.BackgroundColor3 = C_CARD
	card.Parent = parent
	mkCorner(card, 8)
	mkStroke(card, C_BORDER, 1)
	
	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -120, 1, 0)
	tLbl.Position = UDim2.new(0, 12, 0, 0)
	tLbl.BackgroundTransparency = 1
	tLbl.TextColor3 = C_TEXT
	tLbl.Font = Enum.Font.GothamBold
	tLbl.TextSize = 12
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Text = title
	tLbl.Parent = card
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 95, 0, 28)
	btn.Position = UDim2.new(1, -105, 0.5, -14)
	btn.BackgroundColor3 = col or C_ACCENT
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.Text = btnText
	btn.Parent = card
	mkCorner(btn, 6)
	
	btn.MouseButton1Click:Connect(function() if onClick then onClick() end end)
	return card
end

-- ====================================================
--  BUILDING ALL SPEED HUB TABS
-- ====================================================
local UI_Toggles = {}

-- 1. MAIN / CONTROLS TAB
local tabMain = createTab("Main", "Main Hub", "🏠")
createSection(tabMain, "Player & Performance")

UI_Toggles.lowMem = createToggle(tabMain, "⚡ Low RAM / FPS Boost", "Disables 3D viewport while AFK (saves 50-70% RAM & GPU)", S.lowMemOn, function(val)
	S.lowMemOn = val
	pcall(function() RunService:Set3dRenderingEnabled(not val) end)
	if val then pcall(function() collectgarbage("collect") end) end
end)

UI_Toggles.speed = createToggle(tabMain, "🏃 Speed Boost (50 WalkSpeed)", "Increases character walkspeed to 50", S.speedOn, function(val)
	S.speedOn = val
	local hum = player.Character and player.Character:FindFirstChild("Humanoid")
	if hum then hum.WalkSpeed = val and 50 or 16 end
end)

UI_Toggles.autoCollect = createToggle(tabMain, "☀️ Auto Sunshine Collect (Ghost-TP)", "Teleports 0.15s to storage to claim deposits then returns to spot", S.autoCollectEnabled, function(val)
	S.autoCollectEnabled = val
end)

createSection(tabMain, "💎 Auto Farm Master Mode")
UI_Toggles.autoFarm = createToggle(tabMain, "🌾 AUTO FARM (Ordered Pipeline)", "Runs Plant → Water → Shovel → Merge in one clean loop — no random teleporting. Uses your selected seeds/plants & shovel protections.", S.autoFarmEnabled, function(val)
	S.autoFarmEnabled = val
	if val then task.spawn(runAutoFarmPipeline) end
	saveConfig(false)
end)

createSection(tabMain, "Quick Teleports")
createActionButton(tabMain, "Sunshine Storage (My Plot)", "Teleport", Color3.fromRGB(35, 95, 55), function() teleportTo(getMySunshineStoragePosition()) end)
createActionButton(tabMain, "Merchant Area", "Teleport", Color3.fromRGB(95, 65, 35), function() teleportTo(LOCATIONS["Merchant Area"]) end)
createActionButton(tabMain, "Fusion Machine", "Teleport", Color3.fromRGB(75, 45, 95), function() teleportTo(LOCATIONS["Fusion Machine"]) end)
createActionButton(tabMain, "Farmer Shop", "Teleport", Color3.fromRGB(45, 75, 95), function() teleportTo(LOCATIONS["Farmer Shop"]) end)

-- 2. SEEDS TAB (BUY & PLANT SPECIFIC SEEDS)
local tabSeeds = createTab("Seeds", "Seeds & Shop", "🌱")
createSection(tabSeeds, "Seed Automation")

UI_Toggles.autoBuySeeds = createToggle(tabSeeds, "🌱 Auto Buy Selected Seeds", "Auto-buys from active merchants (-12 studs underground)", S.autoBuySeedsEnabled, function(val)
	S.autoBuySeedsEnabled = val
	if val then task.spawn(sweepMerchantStalls) end
end)

UI_Toggles.autoOpenPacks = createToggle(tabSeeds, "📦 Auto Open Seed Packs", "Unpacks all Common/Legendary seed packs in inventory", S.autoOpenSeedsEnabled, function(val)
	S.autoOpenSeedsEnabled = val
	if val and R.OpenSeedPack then
		task.spawn(function()
			for _, t in ipairs(player.Backpack:GetChildren()) do
				if t.Name:lower():find("pack") then
					pcall(function() R.OpenSeedPack:FireServer(t.Name) end)
					task.wait(0.25)
				end
			end
		end)
	end
end)

UI_Toggles.autoPlant = createToggle(tabSeeds, "🌿 Auto Plant Seeds (Unlocked Plots)", "Auto-plants chosen seed rarities/species on open garden plots", S.autoPlantSeedsEnabled, function(val)
	S.autoPlantSeedsEnabled = val
	if val then task.spawn(runAutoPlantSpecificSeedsCycle) end
end)

UI_Toggles.autoWater = createToggle(tabSeeds, "💧 Auto Water Growing Plants", "Auto-equips Aqua/Basic can & waters un-grown plots with timers", S.autoWaterEnabled, function(val)
	S.autoWaterEnabled = val
	if val then task.spawn(runAutoWaterCycle) end
end)

-- Seed Rarities to Auto-Plant Section
createSection(tabSeeds, "Select Seed Rarities to Plant")
local plantRarityCheckboxes = {}
for _, group in ipairs(SEED_CATALOG) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 30)
	row.BackgroundColor3 = C_CARD
	row.Parent = tabSeeds
	mkCorner(row, 6)
	local isSel = S.selectedPlantRarities[group.rarity] == true
	local strk = mkStroke(row, isSel and group.color or C_BORDER, 1)
	
	local rLbl = Instance.new("TextLabel")
	rLbl.Size = UDim2.new(1, -50, 1, 0)
	rLbl.Position = UDim2.new(0, 10, 0, 0)
	rLbl.BackgroundTransparency = 1
	rLbl.TextColor3 = group.color
	rLbl.Font = Enum.Font.GothamBold
	rLbl.TextSize = 11
	rLbl.TextXAlignment = Enum.TextXAlignment.Left
	rLbl.Text = "🌱 Plant " .. group.rarity .. " Seeds"
	rLbl.Parent = row
	
	local chk = Instance.new("TextButton")
	chk.Size = UDim2.new(0, 24, 0, 22)
	chk.Position = UDim2.new(1, -30, 0.5, -11)
	chk.BackgroundColor3 = isSel and C_GREEN or Color3.fromRGB(40, 45, 60)
	chk.TextColor3 = isSel and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
	chk.Font = Enum.Font.GothamBold
	chk.TextSize = 11
	chk.Text = isSel and "X" or ""
	chk.Parent = row
	mkCorner(chk, 4)
	
	local function togglePlantRarity()
		local newState = not (S.selectedPlantRarities[group.rarity] == true)
		S.selectedPlantRarities[group.rarity] = newState or nil
		chk.Text = newState and "X" or ""
		chk.BackgroundColor3 = newState and C_GREEN or Color3.fromRGB(40, 45, 60)
		chk.TextColor3 = newState and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
		strk.Color = newState and group.color or C_BORDER
		saveConfig(false)
	end
	
	chk.MouseButton1Click:Connect(togglePlantRarity)
	row.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then togglePlantRarity() end end)
	plantRarityCheckboxes[group.rarity] = {chk = chk, strk = strk, group = group}
end

-- Global Select/Clear All Seeds Bar
local seedTopBar = Instance.new("Frame")
seedTopBar.Size = UDim2.new(1, -6, 0, 32)
seedTopBar.BackgroundTransparency = 1
seedTopBar.Parent = tabSeeds

local globalSelAll = Instance.new("TextButton")
globalSelAll.Size = UDim2.new(0.48, 0, 1, 0)
globalSelAll.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
globalSelAll.TextColor3 = Color3.fromRGB(255, 255, 255)
globalSelAll.Font = Enum.Font.GothamBold
globalSelAll.TextSize = 11
globalSelAll.Text = "Select All Seeds"
globalSelAll.Parent = seedTopBar
mkCorner(globalSelAll, 6)

local globalClrAll = Instance.new("TextButton")
globalClrAll.Size = UDim2.new(0.48, 0, 1, 0)
globalClrAll.Position = UDim2.new(0.52, 0, 0, 0)
globalClrAll.BackgroundColor3 = Color3.fromRGB(75, 35, 45)
globalClrAll.TextColor3 = Color3.fromRGB(255, 255, 255)
globalClrAll.Font = Enum.Font.GothamBold
globalClrAll.TextSize = 11
globalClrAll.Text = "Clear All Seeds"
globalClrAll.Parent = seedTopBar
mkCorner(globalClrAll, 6)

createSection(tabSeeds, "Select Specific Seeds for Buy & Plant")
local seedCheckboxes = {}

for _, group in ipairs(SEED_CATALOG) do
	local rHeader = Instance.new("Frame")
	rHeader.Size = UDim2.new(1, -6, 0, 28)
	rHeader.BackgroundColor3 = Color3.new(group.color.R * 0.2, group.color.G * 0.2, group.color.B * 0.2)
	rHeader.Parent = tabSeeds
	mkCorner(rHeader, 6)
	mkStroke(rHeader, group.color, 1)
	
	local gLbl = Instance.new("TextLabel")
	gLbl.Size = UDim2.new(1, -120, 1, 0)
	gLbl.Position = UDim2.new(0, 10, 0, 0)
	gLbl.BackgroundTransparency = 1
	gLbl.TextColor3 = group.color
	gLbl.Font = Enum.Font.GothamBold
	gLbl.TextSize = 11
	gLbl.TextXAlignment = Enum.TextXAlignment.Left
	gLbl.Text = "🌟 " .. group.rarity:upper() .. " SEEDS"
	gLbl.Parent = rHeader
	
	local selRarityBtn = Instance.new("TextButton")
	selRarityBtn.Size = UDim2.new(0, 50, 0, 20)
	selRarityBtn.Position = UDim2.new(1, -112, 0.5, -10)
	selRarityBtn.BackgroundColor3 = Color3.fromRGB(30, 90, 45)
	selRarityBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	selRarityBtn.Font = Enum.Font.GothamBold
	selRarityBtn.TextSize = 9
	selRarityBtn.Text = "All"
	selRarityBtn.Parent = rHeader
	mkCorner(selRarityBtn, 4)
	
	local clrRarityBtn = Instance.new("TextButton")
	clrRarityBtn.Size = UDim2.new(0, 50, 0, 20)
	clrRarityBtn.Position = UDim2.new(1, -56, 0.5, -10)
	clrRarityBtn.BackgroundColor3 = Color3.fromRGB(90, 30, 40)
	clrRarityBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	clrRarityBtn.Font = Enum.Font.GothamBold
	clrRarityBtn.TextSize = 9
	clrRarityBtn.Text = "Clear"
	clrRarityBtn.Parent = rHeader
	mkCorner(clrRarityBtn, 4)
	
	selRarityBtn.MouseButton1Click:Connect(function()
		for _, sName in ipairs(group.seeds) do
			S.selectedSeeds[sName] = true
			S.selectedPlantSeeds[sName] = true
			if seedCheckboxes[sName] then
				seedCheckboxes[sName].chk.Text = "X"
				seedCheckboxes[sName].chk.BackgroundColor3 = C_GREEN
				seedCheckboxes[sName].chk.TextColor3 = Color3.fromRGB(10, 25, 15)
				seedCheckboxes[sName].strk.Color = group.color
			end
		end
		saveConfig(false)
	end)
	
	clrRarityBtn.MouseButton1Click:Connect(function()
		for _, sName in ipairs(group.seeds) do
			S.selectedSeeds[sName] = nil
			S.selectedPlantSeeds[sName] = nil
			if seedCheckboxes[sName] then
				seedCheckboxes[sName].chk.Text = ""
				seedCheckboxes[sName].chk.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
				seedCheckboxes[sName].chk.TextColor3 = Color3.fromRGB(200, 200, 220)
				seedCheckboxes[sName].strk.Color = C_BORDER
			end
		end
		saveConfig(false)
	end)
	
	for _, seedName in ipairs(group.seeds) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -6, 0, 30)
		row.BackgroundColor3 = C_CARD
		row.Parent = tabSeeds
		mkCorner(row, 6)
		local strk = mkStroke(row, S.selectedSeeds[seedName] and group.color or C_BORDER, 1)
		
		local tag = Instance.new("TextLabel")
		tag.Size = UDim2.new(0, 75, 0, 18)
		tag.Position = UDim2.new(0, 8, 0.5, -9)
		tag.BackgroundColor3 = Color3.new(group.color.R * 0.25, group.color.G * 0.25, group.color.B * 0.25)
		tag.TextColor3 = group.color
		tag.Font = Enum.Font.GothamBold
		tag.TextSize = 9
		tag.Text = "[" .. group.rarity .. "]"
		tag.Parent = row
		mkCorner(tag, 4)
		
		local sLbl = Instance.new("TextLabel")
		sLbl.Size = UDim2.new(1, -135, 1, 0)
		sLbl.Position = UDim2.new(0, 90, 0, 0)
		sLbl.BackgroundTransparency = 1
		sLbl.TextColor3 = C_TEXT
		sLbl.Font = Enum.Font.Gotham
		sLbl.TextSize = 11
		sLbl.TextXAlignment = Enum.TextXAlignment.Left
		sLbl.Text = seedName
		sLbl.Parent = row
		
		local chk = Instance.new("TextButton")
		chk.Size = UDim2.new(0, 24, 0, 22)
		chk.Position = UDim2.new(1, -30, 0.5, -11)
		chk.BackgroundColor3 = S.selectedSeeds[seedName] and C_GREEN or Color3.fromRGB(40, 45, 60)
		chk.TextColor3 = S.selectedSeeds[seedName] and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
		chk.Font = Enum.Font.GothamBold
		chk.TextSize = 11
		chk.Text = S.selectedSeeds[seedName] and "X" or ""
		chk.Parent = row
		mkCorner(chk, 4)
		
		local function toggleSeed()
			local newState = not (S.selectedSeeds[seedName] == true)
			S.selectedSeeds[seedName] = newState or nil
			S.selectedPlantSeeds[seedName] = newState or nil
			chk.Text = newState and "X" or ""
			chk.BackgroundColor3 = newState and C_GREEN or Color3.fromRGB(40, 45, 60)
			chk.TextColor3 = newState and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
			strk.Color = newState and group.color or C_BORDER
			saveConfig(false)
		end
		
		chk.MouseButton1Click:Connect(toggleSeed)
		row.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then toggleSeed() end end)
		seedCheckboxes[seedName] = {chk = chk, strk = strk, group = group}
	end
end

globalSelAll.MouseButton1Click:Connect(function()
	for _, group in ipairs(SEED_CATALOG) do
		for _, sName in ipairs(group.seeds) do
			S.selectedSeeds[sName] = true
			S.selectedPlantSeeds[sName] = true
			if seedCheckboxes[sName] then
				seedCheckboxes[sName].chk.Text = "X"
				seedCheckboxes[sName].chk.BackgroundColor3 = C_GREEN
				seedCheckboxes[sName].chk.TextColor3 = Color3.fromRGB(10, 25, 15)
				seedCheckboxes[sName].strk.Color = group.color
			end
		end
	end
	saveConfig(false)
end)

globalClrAll.MouseButton1Click:Connect(function()
	S.selectedSeeds = {}
	S.selectedPlantSeeds = {}
	for sName, item in pairs(seedCheckboxes) do
		item.chk.Text = ""
		item.chk.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
		item.chk.TextColor3 = Color3.fromRGB(200, 200, 220)
		item.strk.Color = C_BORDER
	end
	saveConfig(false)
end)

-- 3. FUSION & AUTO SELL TAB
local tabFusion = createTab("Fusion", "Merge & Sell", "🌿")
createSection(tabFusion, "Fusion Machine Automation")

UI_Toggles.autoMerge = createToggle(tabFusion, "🌿 Strict Plant-Only Auto Merge", "Fuses identical shoveled plants (excludes seeds/packs/gear)", S.autoMergePlantsEnabled, function(val)
	S.autoMergePlantsEnabled = val
	if val then task.spawn(runAutoMergeCycle) end
end)

createActionButton(tabFusion, "Teleport to Fusion Machine", "Teleport", Color3.fromRGB(110, 55, 160), function() teleportTo(LOCATIONS["Fusion Machine"]) end)
createActionButton(tabFusion, "Manual Merge Cycle", "Merge Once", C_ACCENT, function() task.spawn(runAutoMergeCycle) end)

createSection(tabFusion, "Auto Sell Plants by Rarity")
UI_Toggles.autoSell = createToggle(tabFusion, "💰 Auto Sell Harvested Plants", "Automatically sells selected plant rarities for Sunshine", S.autoSellPlantsEnabled, function(val)
	S.autoSellPlantsEnabled = val
	if val then task.spawn(runAutoSellPlantsCycle) end
end)

createSection(tabFusion, "Plant Protection (Do NOT Sell)")
UI_Toggles.keepMutatedPlants = createToggle(tabFusion, "🛡️ Protect Mutated Plants", "Never sells plants with Gold, Bubble, Snow Flakes, etc.", S.keepMutatedPlants, function(val)
	S.keepMutatedPlants = val
end)

UI_Toggles.keepMergedPlants = createToggle(tabFusion, "⭐ Protect Merged Plants", "Never sells plants that have stars or merges (★, ★★, ★★★+)", S.keepMergedPlants, function(val)
	S.keepMergedPlants = val
end)

createSection(tabFusion, "Select Plant Rarities to Sell")
local sellCheckboxes = {}
for _, group in ipairs(SEED_CATALOG) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 30)
	row.BackgroundColor3 = C_CARD
	row.Parent = tabFusion
	mkCorner(row, 6)
	local strk = mkStroke(row, S.selectedSellRarities[group.rarity] and group.color or C_BORDER, 1)
	
	local rLbl = Instance.new("TextLabel")
	rLbl.Size = UDim2.new(1, -50, 1, 0)
	rLbl.Position = UDim2.new(0, 10, 0, 0)
	rLbl.BackgroundTransparency = 1
	rLbl.TextColor3 = group.color
	rLbl.Font = Enum.Font.GothamBold
	rLbl.TextSize = 11
	rLbl.TextXAlignment = Enum.TextXAlignment.Left
	rLbl.Text = "Sell " .. group.rarity .. " Plants"
	rLbl.Parent = row
	
	local chk = Instance.new("TextButton")
	chk.Size = UDim2.new(0, 24, 0, 22)
	chk.Position = UDim2.new(1, -30, 0.5, -11)
	chk.BackgroundColor3 = S.selectedSellRarities[group.rarity] and C_GREEN or Color3.fromRGB(40, 45, 60)
	chk.TextColor3 = S.selectedSellRarities[group.rarity] and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
	chk.Font = Enum.Font.GothamBold
	chk.TextSize = 11
	chk.Text = S.selectedSellRarities[group.rarity] and "X" or ""
	chk.Parent = row
	mkCorner(chk, 4)
	
	local function toggleSellRarity()
		local newState = not (S.selectedSellRarities[group.rarity] == true)
		S.selectedSellRarities[group.rarity] = newState or nil
		chk.Text = newState and "X" or ""
		chk.BackgroundColor3 = newState and C_GREEN or Color3.fromRGB(40, 45, 60)
		chk.TextColor3 = newState and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
		strk.Color = newState and group.color or C_BORDER
		saveConfig(false)
	end
	
	chk.MouseButton1Click:Connect(toggleSellRarity)
	row.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then toggleSellRarity() end end)
	sellCheckboxes[group.rarity] = {chk = chk, strk = strk, group = group}
end
-- ====================================================
--  🌿 MERGE PLANT SELECTION (choose which plants to merge)
-- ====================================================
createSection(tabFusion, "Select Plants to Merge (leave empty = merge all)")

local mergeSelectScroll = Instance.new("ScrollingFrame")
mergeSelectScroll.Size = UDim2.new(1, -6, 0, 160)
mergeSelectScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
mergeSelectScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
mergeSelectScroll.ScrollBarThickness = 4
mergeSelectScroll.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
mergeSelectScroll.BorderSizePixel = 0
mergeSelectScroll.Parent = tabFusion
mkCorner(mergeSelectScroll, 6)
Instance.new("UIListLayout", mergeSelectScroll).SortOrder = Enum.SortOrder.Name
Instance.new("UIPadding", mergeSelectScroll).PaddingTop = UDim.new(0, 2)

local mergeSelectRows = {}

local function rebuildMergePlantList()
	for _, c in ipairs(mergeSelectScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	mergeSelectRows = {}
	
	-- Collect unique grown plant names from backpack
	local bp = player:FindFirstChild("Backpack")
	local seen = {}
	if bp then
		for _, t in ipairs(bp:GetChildren()) do
			if isGrownPlantTool(t) and not seen[t.Name] then
				seen[t.Name] = true
			end
		end
	end
	
	local names = {}
	for n in pairs(seen) do table.insert(names, n) end
	table.sort(names)
	
	for _, plantName in ipairs(names) do
		local isSelected = S.selectedMergePlants[plantName] == true
		
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -4, 0, 26)
		row.BackgroundColor3 = isSelected and Color3.fromRGB(30, 60, 35) or Color3.fromRGB(22, 25, 38)
		row.BorderSizePixel = 0
		row.Parent = mergeSelectScroll
		mkCorner(row, 5)
		
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -40, 1, 0)
		lbl.Position = UDim2.new(0, 8, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = isSelected and Color3.fromRGB(100, 240, 120) or Color3.fromRGB(200, 200, 220)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Text = "🌿 " .. plantName
		lbl.Parent = row
		
		local chk = Instance.new("TextButton")
		chk.Size = UDim2.new(0, 26, 0, 22)
		chk.Position = UDim2.new(1, -32, 0.5, -11)
		chk.BackgroundColor3 = isSelected and C_GREEN or Color3.fromRGB(40, 45, 60)
		chk.TextColor3 = isSelected and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
		chk.Font = Enum.Font.GothamBold
		chk.TextSize = 11
		chk.Text = isSelected and "✓" or ""
		chk.Parent = row
		mkCorner(chk, 4)
		
		local function toggle()
			local newState = not (S.selectedMergePlants[plantName] == true)
			S.selectedMergePlants[plantName] = newState or nil
			chk.Text = newState and "✓" or ""
			chk.BackgroundColor3 = newState and C_GREEN or Color3.fromRGB(40, 45, 60)
			chk.TextColor3 = newState and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
			lbl.TextColor3 = newState and Color3.fromRGB(100, 240, 120) or Color3.fromRGB(200, 200, 220)
			row.BackgroundColor3 = newState and Color3.fromRGB(30, 60, 35) or Color3.fromRGB(22, 25, 38)
			saveConfig(false)
		end
		chk.MouseButton1Click:Connect(toggle)
		row.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then toggle() end
		end)
		mergeSelectRows[plantName] = {row = row, chk = chk, lbl = lbl}
	end
end

createActionButton(tabFusion, "Refresh Merge Plant List", "🔄 Refresh", Color3.fromRGB(60, 100, 160), function()
	rebuildMergePlantList()
end)
rebuildMergePlantList()

-- ====================================================
--  🪓 AUTO SHOVEL TAB SECTION
-- ====================================================
createSection(tabFusion, "Auto Shovel Plants")

UI_Toggles.autoShovel = createToggle(tabFusion, "🪓 Auto Shovel Selected Plants", "Automatically shovels selected grown plants from garden plots", S.autoShovelEnabled, function(val)
	S.autoShovelEnabled = val
	if val then task.spawn(runAutoShovelCycle) end
end)

-- Shovel by RARITY (quick & simple): tick a rarity to shovel ALL plants of that rarity
-- (works alongside the individual plant list below — a plant is shovelled if its type
--  OR its rarity is checked)
do
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, -6, 0, 18)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.Text = "🪓 Shovel by Rarity (ticks = shovelled)"
	rarityLabel.TextColor3 = Color3.fromRGB(230, 170, 70)
	rarityLabel.TextSize = 11
	rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
	rarityLabel.Parent = tabFusion

	local rarityFlow = Instance.new("UIGridLayout")
	rarityFlow.Parent = Instance.new("Frame", tabFusion)
	rarityFlow.FillDirection = Enum.FillDirection.Vertical
	rarityFlow.CellSize = UDim2.new(0.5, -4, 0, 26)
	rarityFlow.CellPadding = UDim2.new(0, 2, 0, 2)
	local rarityGrid = rarityFlow.Parent
	rarityGrid.Size = UDim2.new(1, -6, 0, 190)
	rarityGrid.BackgroundTransparency = 1
	rarityGrid.Parent = tabFusion

	-- distinct rarities from the seed catalog, in catalog order
	local shovelRaritiesList = {}
	local seenCat = {}
	for _, group in ipairs(SEED_CATALOG) do
		if not seenCat[group.rarity] then
			seenCat[group.rarity] = true
			table.insert(shovelRaritiesList, group.rarity)
		end
	end

	local rarityButtons = {}
	local function refreshRarityButtons()
		for i, rar in ipairs(shovelRaritiesList) do
			local btn = rarityButtons[rar]
			if btn then
				local on = S.shovelRarities[rar] == true
				btn.BackgroundColor3 = on and Color3.fromRGB(200, 130, 30) or Color3.fromRGB(40, 45, 60)
				btn.TextColor3 = on and Color3.fromRGB(10, 5, 0) or Color3.fromRGB(200, 200, 220)
				btn.Text = (on and "✓ " or "") .. rar
			end
		end
	end

	for i, rar in ipairs(shovelRaritiesList) do
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
		btn.Font = Enum.Font.GothamBold
		btn.TextColor3 = Color3.fromRGB(200, 200, 220)
		btn.TextSize = 10
		btn.Text = rar
		btn.Parent = rarityGrid
		mkCorner(btn, 5)
		btn.MouseButton1Click:Connect(function()
			local on = not (S.shovelRarities[rar] == true)
			S.shovelRarities[rar] = on or nil
			refreshRarityButtons()
			saveConfig(false)
		end)
		rarityButtons[rar] = btn
	end
	refreshRarityButtons()
end

-- Protection: Skip mutated plants
UI_Toggles.shovelProtectMutated = createToggle(tabFusion, "🛡️ Protect Mutated Plants", "Skip plants with Gold, Bubble, Snow Flakes, etc. mutations — never shovel them", S.shovelProtectMutated, function(val)
	S.shovelProtectMutated = val
	saveConfig(false)
end)

-- Protection: Skip high-tier plants (above max tier)
UI_Toggles.shovelProtectHighTier = createToggle(tabFusion, "🛡️ Protect High-Tier Plants", "Skip plants above the max tier setting below (e.g. T3+)", S.shovelProtectHighTier, function(val)
	S.shovelProtectHighTier = val
	saveConfig(false)
end)

-- Max tier row with - / + buttons
do
	local tierRow = Instance.new("Frame")
	tierRow.Size = UDim2.new(1, -6, 0, 32)
	tierRow.BackgroundColor3 = Color3.fromRGB(22, 25, 38)
	tierRow.BorderSizePixel = 0
	tierRow.Parent = tabFusion
	mkCorner(tierRow, 6)

	local tierLabel = Instance.new("TextLabel")
	tierLabel.Size = UDim2.new(0, 170, 1, 0)
	tierLabel.Position = UDim2.new(0, 10, 0, 0)
	tierLabel.BackgroundTransparency = 1
	tierLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	tierLabel.Font = Enum.Font.GothamBold
	tierLabel.TextSize = 11
	tierLabel.TextXAlignment = Enum.TextXAlignment.Left
	tierLabel.Text = "  Max Tier to shovel (T2 = skip T3+):"
	tierLabel.Parent = tierRow

	local tierVal = Instance.new("TextLabel")
	tierVal.Size = UDim2.new(0, 30, 1, 0)
	tierVal.Position = UDim2.new(1, -85, 0, 0)
	tierVal.BackgroundTransparency = 1
	tierVal.TextColor3 = Color3.fromRGB(255, 200, 80)
	tierVal.Font = Enum.Font.GothamBold
	tierVal.TextSize = 13
	tierVal.Text = "T" .. tostring(S.shovelMaxTier)
	tierVal.Parent = tierRow

	local minusBtn = Instance.new("TextButton")
	minusBtn.Size = UDim2.new(0, 26, 0, 22)
	minusBtn.Position = UDim2.new(1, -55, 0.5, -11)
	minusBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minusBtn.Font = Enum.Font.GothamBold
	minusBtn.TextSize = 14
	minusBtn.Text = "-"
	minusBtn.Parent = tierRow
	mkCorner(minusBtn, 5)

	local plusBtn = Instance.new("TextButton")
	plusBtn.Size = UDim2.new(0, 26, 0, 22)
	plusBtn.Position = UDim2.new(1, -26, 0.5, -11)
	plusBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
	plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	plusBtn.Font = Enum.Font.GothamBold
	plusBtn.TextSize = 14
	plusBtn.Text = "+"
	plusBtn.Parent = tierRow
	mkCorner(plusBtn, 5)

	minusBtn.MouseButton1Click:Connect(function()
		if S.shovelMaxTier > 1 then
			S.shovelMaxTier = S.shovelMaxTier - 1
			tierVal.Text = "T" .. tostring(S.shovelMaxTier)
			saveConfig(false)
		end
	end)
	plusBtn.MouseButton1Click:Connect(function()
		if S.shovelMaxTier < 10 then
			S.shovelMaxTier = S.shovelMaxTier + 1
			tierVal.Text = "T" .. tostring(S.shovelMaxTier)
			saveConfig(false)
		end
	end)
end

-- Protection: Skip high-stars plants (above max stars)
UI_Toggles.shovelProtectHighStars = createToggle(tabFusion, "🛡️ Protect High-Star Plants", "Skip plants above the max star count below (e.g. 4+★)", S.shovelProtectHighStars, function(val)
	S.shovelProtectHighStars = val
	saveConfig(false)
end)

-- Max stars row with - / + buttons
do
	local starRow = Instance.new("Frame")
	starRow.Size = UDim2.new(1, -6, 0, 32)
	starRow.BackgroundColor3 = Color3.fromRGB(22, 25, 38)
	starRow.BorderSizePixel = 0
	starRow.Parent = tabFusion
	mkCorner(starRow, 6)

	local starLabel = Instance.new("TextLabel")
	starLabel.Size = UDim2.new(0, 170, 1, 0)
	starLabel.Position = UDim2.new(0, 10, 0, 0)
	starLabel.BackgroundTransparency = 1
	starLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	starLabel.Font = Enum.Font.GothamBold
	starLabel.TextSize = 11
	starLabel.TextXAlignment = Enum.TextXAlignment.Left
	starLabel.Text = "  Max Stars to shovel (3★ = skip 4+★):"
	starLabel.Parent = starRow

	local starVal = Instance.new("TextLabel")
	starVal.Size = UDim2.new(0, 30, 1, 0)
	starVal.Position = UDim2.new(1, -85, 0, 0)
	starVal.BackgroundTransparency = 1
	starVal.TextColor3 = Color3.fromRGB(255, 200, 80)
	starVal.Font = Enum.Font.GothamBold
	starVal.TextSize = 13
	starVal.Text = tostring(S.shovelMaxStars) .. "★"
	starVal.Parent = starRow

	local minusBtn = Instance.new("TextButton")
	minusBtn.Size = UDim2.new(0, 26, 0, 22)
	minusBtn.Position = UDim2.new(1, -55, 0.5, -11)
	minusBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minusBtn.Font = Enum.Font.GothamBold
	minusBtn.TextSize = 14
	minusBtn.Text = "-"
	minusBtn.Parent = starRow
	mkCorner(minusBtn, 5)

	local plusBtn = Instance.new("TextButton")
	plusBtn.Size = UDim2.new(0, 26, 0, 22)
	plusBtn.Position = UDim2.new(1, -26, 0.5, -11)
	plusBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
	plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	plusBtn.Font = Enum.Font.GothamBold
	plusBtn.TextSize = 14
	plusBtn.Text = "+"
	plusBtn.Parent = starRow
	mkCorner(plusBtn, 5)

	minusBtn.MouseButton1Click:Connect(function()
		if S.shovelMaxStars > 0 then
			S.shovelMaxStars = S.shovelMaxStars - 1
			starVal.Text = tostring(S.shovelMaxStars) .. "★"
			saveConfig(false)
		end
	end)
	plusBtn.MouseButton1Click:Connect(function()
		if S.shovelMaxStars < 10 then
			S.shovelMaxStars = S.shovelMaxStars + 1
			starVal.Text = tostring(S.shovelMaxStars) .. "★"
			saveConfig(false)
		end
	end)
end

local shovelScrollLabel = Instance.new("TextLabel")
shovelScrollLabel.Size = UDim2.new(1, -6, 0, 18)
shovelScrollLabel.BackgroundTransparency = 1
shovelScrollLabel.TextColor3 = Color3.fromRGB(200, 160, 80)
shovelScrollLabel.Font = Enum.Font.GothamBold
shovelScrollLabel.TextSize = 10
shovelScrollLabel.TextXAlignment = Enum.TextXAlignment.Left
shovelScrollLabel.Text = "  Select plants to shovel — hit Refresh to scan your garden:"
shovelScrollLabel.Parent = tabFusion

local shovelSelectScroll = Instance.new("ScrollingFrame")
shovelSelectScroll.Size = UDim2.new(1, -6, 0, 160)
shovelSelectScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
shovelSelectScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
shovelSelectScroll.ScrollBarThickness = 4
shovelSelectScroll.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
shovelSelectScroll.BorderSizePixel = 0
shovelSelectScroll.Parent = tabFusion
mkCorner(shovelSelectScroll, 6)
Instance.new("UIListLayout", shovelSelectScroll).SortOrder = Enum.SortOrder.Name
Instance.new("UIPadding", shovelSelectScroll).PaddingTop = UDim.new(0, 2)

local shovelSelectRows = {}

local function rebuildShovelPlantList()
	for _, c in ipairs(shovelSelectScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	shovelSelectRows = {}
	
	local seen = {}
	-- Include all known game plant types so users can pre-select any plant
	for _, group in ipairs(SEED_CATALOG) do
		for _, s in ipairs(group.seeds) do
			seen[s] = true
		end
	end
	
	local myPlot = getMyGardenPlot()
	if myPlot then
		for _, plotPart in ipairs(myPlot:GetChildren()) do
			if plotPart.Name:lower():find("plot") then
				for _, model in ipairs(plotPart:GetChildren()) do
					if model:IsA("Model") and model.Name ~= "GardenPlot" 
					   and model:GetAttribute("IsPlantedPlant") == true then
						seen[model.Name] = true
					end
				end
			end
		end
	end
	
	local names = {}
	for n in pairs(seen) do table.insert(names, n) end
	table.sort(names)
	
	for _, plantName in ipairs(names) do
		local isSelected = S.selectedShovelPlants[plantName] == true
		
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -4, 0, 26)
		row.BackgroundColor3 = isSelected and Color3.fromRGB(55, 35, 10) or Color3.fromRGB(22, 25, 38)
		row.BorderSizePixel = 0
		row.Parent = shovelSelectScroll
		mkCorner(row, 5)
		
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -40, 1, 0)
		lbl.Position = UDim2.new(0, 8, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = isSelected and Color3.fromRGB(230, 160, 60) or Color3.fromRGB(200, 200, 220)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Text = "🪓 " .. plantName
		lbl.Parent = row
		
		local chk = Instance.new("TextButton")
		chk.Size = UDim2.new(0, 26, 0, 22)
		chk.Position = UDim2.new(1, -32, 0.5, -11)
		chk.BackgroundColor3 = isSelected and Color3.fromRGB(200, 130, 30) or Color3.fromRGB(40, 45, 60)
		chk.TextColor3 = isSelected and Color3.fromRGB(10, 5, 0) or Color3.fromRGB(200, 200, 220)
		chk.Font = Enum.Font.GothamBold
		chk.TextSize = 11
		chk.Text = isSelected and "✓" or ""
		chk.Parent = row
		mkCorner(chk, 4)
		
		local function toggle()
			local newState = not (S.selectedShovelPlants[plantName] == true)
			S.selectedShovelPlants[plantName] = newState or nil
			chk.Text = newState and "✓" or ""
			chk.BackgroundColor3 = newState and Color3.fromRGB(200, 130, 30) or Color3.fromRGB(40, 45, 60)
			chk.TextColor3 = newState and Color3.fromRGB(10, 5, 0) or Color3.fromRGB(200, 200, 220)
			lbl.TextColor3 = newState and Color3.fromRGB(230, 160, 60) or Color3.fromRGB(200, 200, 220)
			row.BackgroundColor3 = newState and Color3.fromRGB(55, 35, 10) or Color3.fromRGB(22, 25, 38)
			saveConfig(false)
		end
		chk.MouseButton1Click:Connect(toggle)
		row.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then toggle() end
		end)
		shovelSelectRows[plantName] = {row = row, chk = chk, lbl = lbl}
	end
end

createActionButton(tabFusion, "Refresh Shovel Plant List", "🔄 Refresh", Color3.fromRGB(140, 90, 30), function()
	rebuildShovelPlantList()
end)
createActionButton(tabFusion, "Shovel Once Now", "🪓 Shovel Now", Color3.fromRGB(160, 100, 30), function()
	task.spawn(runAutoShovelCycle)
end)
rebuildShovelPlantList()

-- 4. GEARS TAB (DEDICATED GEAR SHOP AUTO BUY)
local tabGears = createTab("Gears", "Gear Shop", "🛠️")
createSection(tabGears, "Gear Automation")

UI_Toggles.autoBuyGears = createToggle(tabGears, "🛠️ Auto Buy Selected Gears", "Purchases selected gears from Gear Shop when in stock", S.autoBuyGearsEnabled, function(val)
	S.autoBuyGearsEnabled = val
end)

createSection(tabGears, "Select Gears to Auto-Buy")
local gearCheckboxes = {}
for _, gearName in ipairs(GEAR_LIST) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 30)
	row.BackgroundColor3 = C_CARD
	row.Parent = tabGears
	mkCorner(row, 6)
	local strk = mkStroke(row, S.selectedGears[gearName] and Color3.fromRGB(80, 180, 255) or C_BORDER, 1)
	
	local gLbl = Instance.new("TextLabel")
	gLbl.Size = UDim2.new(1, -50, 1, 0)
	gLbl.Position = UDim2.new(0, 10, 0, 0)
	gLbl.BackgroundTransparency = 1
	gLbl.TextColor3 = C_TEXT
	gLbl.Font = Enum.Font.Gotham
	gLbl.TextSize = 11
	gLbl.TextXAlignment = Enum.TextXAlignment.Left
	gLbl.Text = gearName
	gLbl.Parent = row
	
	local chk = Instance.new("TextButton")
	chk.Size = UDim2.new(0, 24, 0, 22)
	chk.Position = UDim2.new(1, -30, 0.5, -11)
	chk.BackgroundColor3 = S.selectedGears[gearName] and C_GREEN or Color3.fromRGB(40, 45, 60)
	chk.TextColor3 = S.selectedGears[gearName] and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
	chk.Font = Enum.Font.GothamBold
	chk.TextSize = 11
	chk.Text = S.selectedGears[gearName] and "X" or ""
	chk.Parent = row
	mkCorner(chk, 4)
	
	local function toggleGear()
		local newState = not (S.selectedGears[gearName] == true)
		S.selectedGears[gearName] = newState or nil
		chk.Text = newState and "X" or ""
		chk.BackgroundColor3 = newState and C_GREEN or Color3.fromRGB(40, 45, 60)
		chk.TextColor3 = newState and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
		strk.Color = newState and Color3.fromRGB(80, 180, 255) or C_BORDER
		saveConfig(false)
	end
	
	chk.MouseButton1Click:Connect(toggleGear)
	row.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then toggleGear() end end)
	gearCheckboxes[gearName] = {chk = chk, strk = strk}
end

-- 5. EGGS & PETS TAB (WITH SAFE TIER PROTECTION)
local tabEggs = createTab("Eggs", "Eggs & Pets", "🥚")
createSection(tabEggs, "Egg Placement & Hatching")

UI_Toggles.autoPlaceEggs = createToggle(tabEggs, "🥚 Auto Place Eggs (Fixed)", "Auto-equips eggs from inventory & places into open garden nests", S.autoPlaceEggsEnabled, function(val)
	S.autoPlaceEggsEnabled = val
	if val then task.spawn(runAutoPlaceEggsCycle) end
end)

UI_Toggles.autoHatchEggs = createToggle(tabEggs, "🐣 Auto Hatch Eggs", "Automatically hatches & claims pets when incubator hits 0:00", S.autoHatchEggsEnabled, function(val)
	S.autoHatchEggsEnabled = val
	if val then task.spawn(runAutoHatchEggsCycle) end
end)

UI_Toggles.autoBuyEggs = createToggle(tabEggs, "🛒 Auto Buy Selected Eggs", "Teleports to Egg Shop pots & purchases selected egg types", S.autoBuyEggsEnabled, function(val)
	S.autoBuyEggsEnabled = val
	saveConfig(false)
end)

createSection(tabEggs, "Select Eggs to Auto-Buy")
local eggCheckboxes = {}
for _, eggName in ipairs(EGG_LIST) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 30)
	row.BackgroundColor3 = C_CARD
	row.Parent = tabEggs
	mkCorner(row, 6)
	local strk = mkStroke(row, S.selectedEggs[eggName] and Color3.fromRGB(255, 215, 80) or C_BORDER, 1)
	
	local eLbl = Instance.new("TextLabel")
	eLbl.Size = UDim2.new(1, -50, 1, 0)
	eLbl.Position = UDim2.new(0, 10, 0, 0)
	eLbl.BackgroundTransparency = 1
	eLbl.TextColor3 = C_TEXT
	eLbl.Font = Enum.Font.Gotham
	eLbl.TextSize = 11
	eLbl.TextXAlignment = Enum.TextXAlignment.Left
	eLbl.Text = eggName
	eLbl.Parent = row
	
	local chk = Instance.new("TextButton")
	chk.Size = UDim2.new(0, 24, 0, 22)
	chk.Position = UDim2.new(1, -30, 0.5, -11)
	chk.BackgroundColor3 = S.selectedEggs[eggName] and C_GREEN or Color3.fromRGB(40, 45, 60)
	chk.TextColor3 = S.selectedEggs[eggName] and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
	chk.Font = Enum.Font.GothamBold
	chk.TextSize = 11
	chk.Text = S.selectedEggs[eggName] and "X" or ""
	chk.Parent = row
	mkCorner(chk, 4)
	
	local function toggleEgg()
		local newState = not (S.selectedEggs[eggName] == true)
		S.selectedEggs[eggName] = newState or nil
		chk.Text = newState and "X" or ""
		chk.BackgroundColor3 = newState and C_GREEN or Color3.fromRGB(40, 45, 60)
		chk.TextColor3 = newState and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
		strk.Color = newState and Color3.fromRGB(255, 215, 80) or C_BORDER
		saveConfig(false)
	end
	
	chk.MouseButton1Click:Connect(toggleEgg)
	row.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then toggleEgg() end end)
	eggCheckboxes[eggName] = {chk = chk, strk = strk}
end

createSection(tabEggs, "Auto Delete Unwanted Pets")
UI_Toggles.autoDeletePets = createToggle(tabEggs, "🗑️ Auto Delete Selected Pets", "Automatically deletes selected unwanted pets from inventory", S.autoDeletePetsEnabled, function(val)
	S.autoDeletePetsEnabled = val
	if val then task.spawn(runAutoDeletePetsCycle) end
end)

createSection(tabEggs, "Protected Pet Tiers (Do NOT Delete)")
UI_Toggles.keepMutatedPets = createToggle(tabEggs, "🛡️ Protect Mutated / Gold Pets", "Never deletes pets with Golden or mutation attributes", S.keepMutatedPets, function(val)
	S.keepMutatedPets = val
end)

local protectedPetCheckboxes = {}
for _, pRarity in ipairs(PET_RARITIES_LIST) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 30)
	row.BackgroundColor3 = C_CARD
	row.Parent = tabEggs
	mkCorner(row, 6)
	local isProtected = S.protectedPetRarities[pRarity] == true
	local strk = mkStroke(row, isProtected and Color3.fromRGB(80, 180, 255) or C_BORDER, 1)
	
	local rLbl = Instance.new("TextLabel")
	rLbl.Size = UDim2.new(1, -50, 1, 0)
	rLbl.Position = UDim2.new(0, 10, 0, 0)
	rLbl.BackgroundTransparency = 1
	rLbl.TextColor3 = Color3.fromRGB(120, 200, 255)
	rLbl.Font = Enum.Font.GothamBold
	rLbl.TextSize = 11
	rLbl.TextXAlignment = Enum.TextXAlignment.Left
	rLbl.Text = "Keep " .. pRarity .. " Pets"
	rLbl.Parent = row
	
	local chk = Instance.new("TextButton")
	chk.Size = UDim2.new(0, 24, 0, 22)
	chk.Position = UDim2.new(1, -30, 0.5, -11)
	chk.BackgroundColor3 = isProtected and C_GREEN or Color3.fromRGB(40, 45, 60)
	chk.TextColor3 = isProtected and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
	chk.Font = Enum.Font.GothamBold
	chk.TextSize = 11
	chk.Text = isProtected and "X" or ""
	chk.Parent = row
	mkCorner(chk, 4)
	
	local function toggleProtectedRarity()
		local newState = not (S.protectedPetRarities[pRarity] == true)
		S.protectedPetRarities[pRarity] = newState or nil
		chk.Text = newState and "X" or ""
		chk.BackgroundColor3 = newState and C_GREEN or Color3.fromRGB(40, 45, 60)
		chk.TextColor3 = newState and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
		strk.Color = newState and Color3.fromRGB(80, 180, 255) or C_BORDER
		saveConfig(false)
	end
	
	chk.MouseButton1Click:Connect(toggleProtectedRarity)
	row.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then toggleProtectedRarity() end end)
	protectedPetCheckboxes[pRarity] = {chk = chk, strk = strk}
end

createSection(tabEggs, "Select Pet Names to Delete")
local petCheckboxes = {}
for _, petName in ipairs(PET_LIST) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 30)
	row.BackgroundColor3 = C_CARD
	row.Parent = tabEggs
	mkCorner(row, 6)
	local strk = mkStroke(row, S.selectedDeletePets[petName] and C_RED or C_BORDER, 1)
	
	local pLbl = Instance.new("TextLabel")
	pLbl.Size = UDim2.new(1, -50, 1, 0)
	pLbl.Position = UDim2.new(0, 10, 0, 0)
	pLbl.BackgroundTransparency = 1
	pLbl.TextColor3 = C_TEXT
	pLbl.Font = Enum.Font.Gotham
	pLbl.TextSize = 11
	pLbl.TextXAlignment = Enum.TextXAlignment.Left
	pLbl.Text = "Delete " .. petName
	pLbl.Parent = row
	
	local chk = Instance.new("TextButton")
	chk.Size = UDim2.new(0, 24, 0, 22)
	chk.Position = UDim2.new(1, -30, 0.5, -11)
	chk.BackgroundColor3 = S.selectedDeletePets[petName] and C_RED or Color3.fromRGB(40, 45, 60)
	chk.TextColor3 = S.selectedDeletePets[petName] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
	chk.Font = Enum.Font.GothamBold
	chk.TextSize = 11
	chk.Text = S.selectedDeletePets[petName] and "X" or ""
	chk.Parent = row
	mkCorner(chk, 4)
	
	local function togglePet()
		local newState = not (S.selectedDeletePets[petName] == true)
		S.selectedDeletePets[petName] = newState or nil
		chk.Text = newState and "X" or ""
		chk.BackgroundColor3 = newState and C_RED or Color3.fromRGB(40, 45, 60)
		chk.TextColor3 = newState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
		strk.Color = newState and C_RED or C_BORDER
		saveConfig(false)
	end
	
	chk.MouseButton1Click:Connect(togglePet)
	row.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then togglePet() end end)
	petCheckboxes[petName] = {chk = chk, strk = strk}
end

-- 6. FARMERS TAB
local tabFarmers = createTab("Farmers", "Farmer Shop", "🧑‍🌾")
createSection(tabFarmers, "Auto Buy Farmers")

UI_Toggles.autoBuyFarmers = createToggle(tabFarmers, "🧑‍🌾 Auto Buy Farmers", "Purchases selected farmer tiers when in stock", S.autoBuyEnabled, function(val)
	S.autoBuyEnabled = val
	if val then task.spawn(autoBuyFarmersLoop) end
	saveConfig(false)
end)

UI_Toggles.autoEquipFarmers = createToggle(tabFarmers, "🧑‍🌾⭐ Auto Equip Best Farmers", "Automatically equips your highest-value farmers (by collect multiplier)", S.autoEquipFarmersEnabled, function(val)
	S.autoEquipFarmersEnabled = val
	if val then task.spawn(autoEquipBestFarmers) end
	saveConfig(false)
end)

-- Background loop: auto-buy selected farmer rarities from the farmer shop
function autoBuyFarmersLoop()
	while true do
		task.wait(3)
		if not S.autoBuyEnabled then continue end
		pcall(function()
			local stock = R.GetFarmerStock:InvokeServer()
			if type(stock) ~= "table" then return end
			for key, info in pairs(stock) do
				if type(info) == "table" and info.stock and info.stock > 0 then
					local rarity = info.rarity or info.name
					if rarity and S.selectedRarities[rarity] then
						local ok, result = pcall(function() return R.BuyFarmerReq:InvokeServer(key) end)
						if ok and result and result.success then
							S.autoBuyCount = S.autoBuyCount + 1
							if _G.MFGToast then
								_G.MFGToast("🧑‍🌾 Farmer Bought", "Purchased " .. rarity .. " farmer!", Color3.fromRGB(100, 200, 100))
							end
						end
						task.wait(0.5)
					end
				end
			end
		end)
	end
end

-- ====================================================
--  🧑‍🌾 AUTO EQUIP BEST FARMERS (BY COLLECT MULTIPLIER)
-- ====================================================
function autoEquipBestFarmers()
	if not R.GetOwnedFarmers or not R.ToggleEquipFarmer or not R.GetMaxFarmers then return end
	local ok, owned = pcall(function() return R.GetOwnedFarmers:InvokeServer() end)
	if not ok or type(owned) ~= "table" or #owned == 0 then return end

	local maxOK, maxEq = pcall(function() return R.GetMaxFarmers:InvokeServer() end)
	local maxEquipped = (maxOK and type(maxEq) == "number" and maxEq > 0) and maxEq or 5

	-- rank best-first by collectMultiplier (fall back to rarity order)
	local rank = {Secret=8, Money=7, Angelic=7, Mythic=6, Legendary=5, Epic=4, Rare=3, Common=2}
	local list = {}
	for _, f in ipairs(owned) do
		if type(f) == "table" and f.instanceId then
			local mult = tonumber(f.collectMultiplier) or 0
			local r = rank[f.rarity] or 1
			list[#list + 1] = {id = f.instanceId, mult = mult, rarity = f.rarity, equipped = f.isEquipped == true, tier = r}
		end
	end
	table.sort(list, function(a, b)
		if a.mult ~= b.mult then return a.mult > b.mult end
		return a.tier > b.tier
	end)

	local keep = {}
	for i = 1, maxEquipped do
		if list[i] then keep[list[i].id] = true end
	end

	-- unequip farmers that are equipped but not in the top-N (free slots)
	for _, f in ipairs(list) do
		if f.equipped and not keep[f.id] then
			pcall(function() R.ToggleEquipFarmer:InvokeServer(f.id) end)
			task.wait(0.25)
		end
	end

	-- equip the best farmers that aren't equipped yet
	local changes = 0
	for _, f in ipairs(list) do
		if not S.autoEquipFarmersEnabled then break end
		if keep[f.id] and not f.equipped then
			local ok2, res = pcall(function() return R.ToggleEquipFarmer:InvokeServer(f.id) end)
			if ok2 and type(res) == "table" and res.success then
				changes = changes + 1
				if _G.MFGToast then
					_G.MFGToast("🧑‍🌾 Equipped", "Best farmer equipped (" .. tostring(f.rarity or "?") .. ")!", Color3.fromRGB(100, 200, 100))
				end
				task.wait(0.3)
			end
		end
	end

	if changes > 0 and _G.MFGToast then
		_G.MFGToast("🧑‍🌾 Auto Equip", "Equipped top " .. maxEquipped .. " farmers by value!", Color3.fromRGB(100, 200, 100))
	end
end

task.spawn(function()
	task.wait(1)
	while true do
		task.wait(10)
		if S.autoEquipFarmersEnabled then pcall(autoEquipBestFarmers) end
	end
end)

-- ====================================================
--  📢 DISCORD WEBHOOK NOTIFIER (FARMER SHOP STOCK)
-- ====================================================
local lastStockHash = ""
local sendInFlight = false

local function farmerStockHash(stock)
	if type(stock) ~= "table" then return "" end
	local lines = {}
	for k, v in pairs(stock) do
		if type(v) == "table" then
			lines[#lines + 1] = tostring(k) .. "=" .. tostring(v.stock or 0)
		end
	end
	table.sort(lines)
	return table.concat(lines, "|")
end

local function sendDiscordWebhook(embed)
	local url = S.webhookUrl or ""
	if url == "" or not (url:lower():find("discord") and url:lower():find("api/webhooks")) then return false end
	if sendInFlight then return false end
	sendInFlight = true
	local ok = false
	pcall(function()
		if request then
			local res = request({
				Url = url,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode(embed),
			})
			ok = type(res) == "table" and res.Success == true
		else
			local body = HttpService:JSONEncode(embed)
			local resp = HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
			ok = resp ~= nil
		end
	end)
	sendInFlight = false
	return ok
end

task.spawn(function()
	task.wait(2)
	while true do
		task.wait(15)
		if S.webhookNotifyEnabled and S.webhookUrl and S.webhookUrl ~= "" then
			pcall(function()
				if not R.GetFarmerStock then return end
				local ok, stock = pcall(function() return R.GetFarmerStock:InvokeServer() end)
				if not ok or type(stock) ~= "table" then return end
				local hash = farmerStockHash(stock)
				if hash ~= "" and hash ~= lastStockHash then
					lastStockHash = hash
					local lines = {}
					for k, v in pairs(stock) do
						if type(v) == "table" and v.stock and v.stock > 0 then
							lines[#lines + 1] = "**" .. tostring(v.rarity or k) .. "**: " .. tostring(v.stock) .. " in stock"
							.. (v.price and (" ($" .. tostring(v.price) .. ")") or "")
						end
					end
				if #lines > 0 then
					-- Append the real in-game restock countdown (from GetFarmerShopPhaseRequest)
					local restockLine = ""
					local okP, phase = pcall(function() return R.GetFarmerPhase:InvokeServer() end)
					if okP and type(phase) == "table" and type(phase.remainingSeconds) == "number" then
						local rem = math.floor(phase.remainingSeconds)
						if phase.phase and phase.phase ~= "available" then
							restockLine = "🔄 Shop is **" .. tostring(phase.phase) .. "**"
						elseif rem > 0 then
							local mm = math.floor(rem / 60)
							local ss = rem % 60
							if mm >= 60 then
								restockLine = "⏳ New stock in **" .. math.floor(mm / 60) .. "h " .. (mm % 60) .. "m " .. string.format("%02d", ss) .. "s**"
							elseif mm > 0 then
								restockLine = "⏳ New stock in **" .. mm .. "m " .. string.format("%02d", ss) .. "s**"
							else
								restockLine = "⏳ New stock in **" .. ss .. "s**"
							end
							restockLine = restockLine .. " (restock at " .. os.date("%H:%M:%S", os.time() + rem) .. ")"
						else
							restockLine = "🔄 New stock now!"
						end
					end
					if restockLine ~= "" then
						lines[#lines + 1] = ""
						lines[#lines + 1] = restockLine
					end
					local embed = {
						embeds = {{
							title = "🧑‍🌾 Farmer Shop Updated",
							description = table.concat(lines, "\n"),
							color = 5763719,
							footer = { text = "MFG HUB | " .. os.date("%H:%M:%S") },
						}}
					}
					sendDiscordWebhook(embed)
				end
				end
			end)
		end
	end
end)

-- ====================================================
--  🛠️ GEAR SHOP STOCK NOTIFIER (DISCORD WEBHOOK)
--  Mirrors the farmer notifier but reads GetGearShopStateRequest,
--  which returns {stock, prices, displayNames, restockEndTime}.
-- ====================================================
local gearLastStockHash = ""

local function gearStockHash(stock)
	if type(stock) ~= "table" then return "" end
	local lines = {}
	for k, v in pairs(stock) do
		lines[#lines + 1] = tostring(k) .. "=" .. tostring(v)
	end
	table.sort(lines)
	return table.concat(lines, "|")
end

task.spawn(function()
	task.wait(2)
	while true do
		task.wait(15)
		if S.webhookNotifyEnabled and S.webhookUrl and S.webhookUrl ~= "" and R.GetGearState then
			pcall(function()
				local ok, data = pcall(function() return R.GetGearState:InvokeServer() end)
				if not ok or type(data) ~= "table" or type(data.stock) ~= "table" then return end
				local hash = gearStockHash(data.stock)
				if hash ~= "" and hash ~= gearLastStockHash then
					gearLastStockHash = hash
					local lines = {}
					for k, v in pairs(data.stock) do
						local display = data.displayNames and data.displayNames[k] or k
						if v and tonumber(v) and tonumber(v) > 0 then
							lines[#lines + 1] = "🛠️ **" .. tostring(display or k) .. "**: " .. tostring(v) .. " in stock"
								.. (data.prices and data.prices[k] and (" ($" .. tostring(data.prices[k]) .. ")") or "")
						end
					end
					if #lines > 0 then
						local restockLine = ""
						if type(data.restockEndTime) == "number" then
							local rem = data.restockEndTime - os.time()
							if rem > 0 then
								local mm = math.floor(rem / 60)
								local ss = rem % 60
								if mm >= 60 then
									restockLine = "⏳ New gear stock in **" .. math.floor(mm / 60) .. "h " .. (mm % 60) .. "m " .. string.format("%02d", ss) .. "s**"
								elseif mm > 0 then
									restockLine = "⏳ New gear stock in **" .. mm .. "m " .. string.format("%02d", ss) .. "s**"
								else
									restockLine = "⏳ New gear stock in **" .. ss .. "s**"
								end
								restockLine = restockLine .. " (restock at " .. os.date("%H:%M:%S", data.restockEndTime) .. ")"
							else
								restockLine = "🔄 New gear stock now!"
							end
						end
						if restockLine ~= "" then
							lines[#lines + 1] = ""
							lines[#lines + 1] = restockLine
						end
						local embed = {
							embeds = {{
								title = "🛠️ Gear Shop Updated",
								description = table.concat(lines, "\n"),
								color = 3892863,
								footer = { text = "MFG HUB | " .. os.date("%H:%M:%S") },
							}}
						}
						sendDiscordWebhook(embed)
					end
				end
			end)
		end
	end
end)

local farmerCheckboxes = {}
for _, rarity in ipairs(RARITIES_LIST) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 30)
	row.BackgroundColor3 = C_CARD
	row.Parent = tabFarmers
	mkCorner(row, 6)
	local strk = mkStroke(row, S.selectedRarities[rarity] and (FARMER_COLORS[rarity] or C_GREEN) or C_BORDER, 1)
	
	local fLbl = Instance.new("TextLabel")
	fLbl.Size = UDim2.new(1, -50, 1, 0)
	fLbl.Position = UDim2.new(0, 10, 0, 0)
	fLbl.BackgroundTransparency = 1
	fLbl.TextColor3 = FARMER_COLORS[rarity] or C_TEXT
	fLbl.Font = Enum.Font.GothamBold
	fLbl.TextSize = 11
	fLbl.TextXAlignment = Enum.TextXAlignment.Left
	fLbl.Text = rarity .. " Farmer"
	fLbl.Parent = row
	
	local chk = Instance.new("TextButton")
	chk.Size = UDim2.new(0, 24, 0, 22)
	chk.Position = UDim2.new(1, -30, 0.5, -11)
	chk.BackgroundColor3 = S.selectedRarities[rarity] and C_GREEN or Color3.fromRGB(40, 45, 60)
	chk.TextColor3 = S.selectedRarities[rarity] and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
	chk.Font = Enum.Font.GothamBold
	chk.TextSize = 11
	chk.Text = S.selectedRarities[rarity] and "X" or ""
	chk.Parent = row
	mkCorner(chk, 4)
	
	local function toggleFarmer()
		local newState = not (S.selectedRarities[rarity] == true)
		S.selectedRarities[rarity] = newState or nil
		chk.Text = newState and "X" or ""
		chk.BackgroundColor3 = newState and C_GREEN or Color3.fromRGB(40, 45, 60)
		chk.TextColor3 = newState and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
		strk.Color = newState and (FARMER_COLORS[rarity] or C_GREEN) or C_BORDER
		saveConfig(false)
	end
	
	chk.MouseButton1Click:Connect(toggleFarmer)
	row.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then toggleFarmer() end end)
	farmerCheckboxes[rarity] = {chk = chk, strk = strk, rarity = rarity}
end

-- Discord Webhook Notifier
createSection(tabFarmers, "Discord Webhook Notifier")
UI_Toggles.webhookNotify = createToggle(tabFarmers, "<-> Notify Stock Changes on Discord", "Posts farmer shop stock to your Discord webhook whenever it changes", S.webhookNotifyEnabled, function(val)
	S.webhookNotifyEnabled = val
	saveConfig(false)
end)

local webhookRow = Instance.new("Frame")
webhookRow.Size = UDim2.new(1, -6, 0, 36)
webhookRow.BackgroundColor3 = C_CARD
webhookRow.Parent = tabFarmers
mkCorner(webhookRow, 6)
mkStroke(webhookRow, C_BORDER, 1)

local webhookInput = Instance.new("TextBox")
webhookInput.Size = UDim2.new(1, -95, 1, -8)
webhookInput.Position = UDim2.new(0, 8, 0, 4)
webhookInput.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
webhookInput.TextColor3 = Color3.fromRGB(255, 255, 255)
webhookInput.PlaceholderColor3 = Color3.fromRGB(140, 140, 160)
webhookInput.PlaceholderText = "Discord webhook URL (https://discord.com/api/webhooks/...)"
webhookInput.Font = Enum.Font.Gotham
webhookInput.TextSize = 11
webhookInput.ClearTextOnFocus = false
webhookInput.TextXAlignment = Enum.TextXAlignment.Left
webhookInput.Text = S.webhookUrl
webhookInput.Parent = webhookRow
mkCorner(webhookInput, 4)

local webhookSave = Instance.new("TextButton")
webhookSave.Size = UDim2.new(0, 80, 1, -8)
webhookSave.Position = UDim2.new(1, -84, 0, 4)
webhookSave.BackgroundColor3 = Color3.fromRGB(55, 95, 160)
webhookSave.TextColor3 = Color3.fromRGB(255, 255, 255)
webhookSave.Font = Enum.Font.GothamBold
webhookSave.TextSize = 11
webhookSave.Text = "Save"
webhookSave.Parent = webhookRow
mkCorner(webhookSave, 4)

webhookSave.MouseButton1Click:Connect(function()
	S.webhookUrl = webhookInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
	saveConfig(false)
	if _G.MFGToast then
		_G.MFGToast("<-> Webhook Saved", "Webhook URL stored!", Color3.fromRGB(80, 180, 255))
	end
end)

createActionButton(tabFarmers, "Send a test notification to your Discord webhook", "Test Webhook", Color3.fromRGB(55, 95, 160), function()
	S.webhookUrl = webhookInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
	local embed = {
		embeds = {{
			title = "MFG HUB Test",
			description = "Webhook is working! Farmer Shop changes will notify here.",
			color = 5763719,
			footer = { text = os.date("%H:%M:%S") },
		}}
	}
	if sendDiscordWebhook(embed) then
		if _G.MFGToast then _G.MFGToast("<-> Webhook", "Test notification sent!", Color3.fromRGB(80, 200, 120)) end
	else
		if _G.MFGToast then _G.MFGToast("<-> Webhook", "Failed to send (check URL / Discord rate limit)", Color3.fromRGB(255, 100, 100)) end
	end
end)

-- 7. WHEEL & QUESTS TAB
local tabWheel = createTab("Wheel", "Wheel & Quests", "🎡")
createSection(tabWheel, "Smart Auto Spin Wheel")

UI_Toggles.autoSpin = createToggle(tabWheel, "🎡 Smart Auto Spin Wheel", "Spins wheel when sunshine exceeds selected reserve", S.autoSpinEnabled, function(val)
	S.autoSpinEnabled = val
end)

createSection(tabWheel, "Min Sunshine Reserve (Stop Threshold)")
local reserveFrame = Instance.new("Frame")
reserveFrame.Size = UDim2.new(1, -6, 0, 32)
reserveFrame.BackgroundTransparency = 1
reserveFrame.Parent = tabWheel

local reserveBtns = {}
local function updateReserveUI()
	for amt, b in pairs(reserveBtns) do
		local isSel = (S.minSpinSunshine == amt)
		b.BackgroundColor3 = isSel and C_GREEN or C_CARD
		b.TextColor3 = isSel and Color3.fromRGB(10, 25, 15) or C_TEXT
	end
end

local function addReserveBtn(xScale, wScale, amt, label)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(wScale, -4, 1, 0)
	b.Position = UDim2.new(xScale, 2, 0, 0)
	b.BackgroundColor3 = (S.minSpinSunshine == amt) and C_GREEN or C_CARD
	b.TextColor3 = (S.minSpinSunshine == amt) and Color3.fromRGB(10, 25, 15) or C_TEXT
	b.Font = Enum.Font.GothamBold
	b.TextSize = 10
	b.Text = label
	b.Parent = reserveFrame
	mkCorner(b, 6)
	mkStroke(b, C_BORDER, 1)
	
	b.MouseButton1Click:Connect(function()
		S.minSpinSunshine = amt
		updateReserveUI()
		saveConfig(false)
		if _G.MFGToast then
			_G.MFGToast("🎡 Reserve Set", "Will keep at least " .. label .. " Sunshine in reserve!", Color3.fromRGB(255, 200, 50))
		end
	end)
	reserveBtns[amt] = b
end

addReserveBtn(0, 0.25, 0, "No Reserve")
addReserveBtn(0.25, 0.25, 2000000, "2M Reserve")
addReserveBtn(0.50, 0.25, 5000000, "5M Reserve")
addReserveBtn(0.75, 0.25, 10000000, "10M Reserve")

createSection(tabWheel, "Spin Tier Selection")
local tierFrame = Instance.new("Frame")
tierFrame.Size = UDim2.new(1, -6, 0, 32)
tierFrame.BackgroundTransparency = 1
tierFrame.Parent = tabWheel

local tierBtns = {}
local function updateTierUI()
	for tKey, b in pairs(tierBtns) do
		local isSel = (S.spinTier == tKey)
		b.BackgroundColor3 = isSel and C_ACCENT or C_CARD
		b.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or C_SUBTEXT
	end
end

local function addTierBtn(xScale, wScale, tKey, label)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(wScale, -4, 1, 0)
	b.Position = UDim2.new(xScale, 2, 0, 0)
	b.BackgroundColor3 = (S.spinTier == tKey) and C_ACCENT or C_CARD
	b.TextColor3 = (S.spinTier == tKey) and Color3.fromRGB(255, 255, 255) or C_SUBTEXT
	b.Font = Enum.Font.GothamBold
	b.TextSize = 10
	b.Text = label
	b.Parent = tierFrame
	mkCorner(b, 6)
	mkStroke(b, C_BORDER, 1)
	
	b.MouseButton1Click:Connect(function()
		S.spinTier = tKey
		updateTierUI()
		saveConfig(false)
		if _G.MFGToast then
			_G.MFGToast("🎡 Tier Set", "Spinning " .. label .. "!", Color3.fromRGB(88, 101, 242))
		end
	end)
	tierBtns[tKey] = b
end

addTierBtn(0, 0.33, "100k", "100k Spin")
addTierBtn(0.33, 0.33, "1m", "1M Spin")
addTierBtn(0.66, 0.34, "best", "⚡ Best (1M if able)")

createSection(tabWheel, "Quest Automation")
UI_Toggles.autoQuest = createToggle(tabWheel, "📋 Auto Quests & Claim", "Auto-submits completed quests and claims rewards", S.autoQuestEnabled, function(val)
	S.autoQuestEnabled = val
	if val and R.QuestRequestSync then pcall(function() R.QuestRequestSync:FireServer() end) end
end)

UI_Toggles.autoAirdrop = createToggle(tabWheel, "📦 Auto Airdrop Crate Solver", "Auto-solves and collects falling airdrop crates", S.autoAirdropEnabled, function(val)
	S.autoAirdropEnabled = val
end)

-- 8. VIP REROLL TAB
local tabVip = createTab("VIP", "VIP Reroller", "⚡")
createSection(tabVip, "Fast VIP Server Reroller")

UI_Toggles.vipReroll = createToggle(tabVip, "⚡ Fast VIP Auto-Reroll", "Checks all 10 stalls on join; auto-hops if no target merchant spawns", S.vipRerollEnabled, function(val)
	S.vipRerollEnabled = val
end)

createActionButton(tabVip, "Rejoin Current Server", "Rejoin", Color3.fromRGB(45, 80, 140), function()
	TeleportService:Teleport(game.PlaceId, player)
end)

-- 9. CONFIG & SETTINGS TAB
local tabConfig = createTab("Config", "Settings", "⚙️")
createSection(tabConfig, "Configuration Management")

createActionButton(tabConfig, "Save Configuration", "Save", Color3.fromRGB(35, 95, 55), function() saveConfig(true) end)
createActionButton(tabConfig, "Load Configuration", "Load", Color3.fromRGB(45, 65, 120), function()
	loadConfig(false)
end)

-- 10. SECRET ADMIN & GLOBAL CHAT TOOLS
createSection(tabConfig, "Game Admin & Global Chat")

createActionButton(tabConfig, "Open Secret Admin Panel (or press F2)", "👑 Open Admin Panel", Color3.fromRGB(150, 40, 40), function()
	local pg = player:FindFirstChild("PlayerGui")
	local ap = pg and pg:FindFirstChild("AdminPanel")
	local mf = ap and ap:FindFirstChild("MainFrame")
	if mf then
		mf.Visible = not mf.Visible
		if _G.MFGToast then
			_G.MFGToast("👑 Admin Panel", mf.Visible and "Opened Admin Panel!" or "Closed Admin Panel!", Color3.fromRGB(255, 60, 60))
		end
	end
end)

-- Global Chat Input
local gChatRow = Instance.new("Frame")
gChatRow.Size = UDim2.new(1, -6, 0, 36)
gChatRow.BackgroundColor3 = C_CARD
gChatRow.Parent = tabConfig
mkCorner(gChatRow, 6)
mkStroke(gChatRow, C_BORDER, 1)

local gChatInput = Instance.new("TextBox")
gChatInput.Size = UDim2.new(1, -95, 1, -8)
gChatInput.Position = UDim2.new(0, 8, 0, 4)
gChatInput.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
gChatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
gChatInput.PlaceholderColor3 = Color3.fromRGB(140, 140, 160)
gChatInput.PlaceholderText = "Type global message to broadcast..."
gChatInput.Font = Enum.Font.Gotham
gChatInput.TextSize = 11
gChatInput.ClearTextOnFocus = false
gChatInput.TextXAlignment = Enum.TextXAlignment.Left
gChatInput.Parent = gChatRow
mkCorner(gChatInput, 4)

local gChatSend = Instance.new("TextButton")
gChatSend.Size = UDim2.new(0, 80, 1, -8)
gChatSend.Position = UDim2.new(1, -84, 0, 4)
gChatSend.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
gChatSend.TextColor3 = Color3.fromRGB(255, 255, 255)
gChatSend.Font = Enum.Font.GothamBold
gChatSend.TextSize = 11
gChatSend.Text = "📢 Send"
gChatSend.Parent = gChatRow
mkCorner(gChatSend, 4)

local function sendGlobalChat()
	local msg = gChatInput.Text
	if not msg or msg:gsub("%s", "") == "" then return end
	if #msg > 150 then msg = msg:sub(1, 150) end
	local gce = RS:FindFirstChild("GlobalChatEvent")
	if gce then
		pcall(function() gce:FireServer(msg) end)
		gChatInput.Text = ""
		if _G.MFGToast then
			_G.MFGToast("📢 Global Chat", "Broadcast sent to server!", Color3.fromRGB(255, 80, 80))
		end
	end
end

gChatSend.MouseButton1Click:Connect(sendGlobalChat)
gChatInput.FocusLost:Connect(function(enter)
	if enter then sendGlobalChat() end
end)

-- Global Keybind & Chat Commands for Admin Panel
UIS.InputBegan:Connect(function(inp, gpe)
	if gpe then return end
	if inp.KeyCode == Enum.KeyCode.F2 then
		local pg = player:FindFirstChild("PlayerGui")
		local ap = pg and pg:FindFirstChild("AdminPanel")
		local mf = ap and ap:FindFirstChild("MainFrame")
		if mf then mf.Visible = not mf.Visible end
	end
end)

player.Chatted:Connect(function(msg)
	local clean = msg:gsub("^%s+", ""):gsub("%s+$", ""):lower()
	if clean == "/panel" or clean == "!panel" or clean == ":panel" then
		local pg = player:FindFirstChild("PlayerGui")
		local ap = pg and pg:FindFirstChild("AdminPanel")
		local mf = ap and ap:FindFirstChild("MainFrame")
		if mf then mf.Visible = not mf.Visible end
	end
end)

-- ====================================================
--  CONFIG LOADER & SYNC ENGINE
-- ====================================================
function loadConfig(silent)
	if not (readfile and isfile and isfile(CONFIG_FILE)) then return end
	local ok, content = pcall(function() return readfile(CONFIG_FILE) end)
	if not ok or not content or content == "" then return end
	local jsonOk, data = pcall(function() return HttpService:JSONDecode(content) end)
	if jsonOk and type(data) == "table" then
		if type(data.selectedSeeds) == "table" then S.selectedSeeds = data.selectedSeeds end
		if type(data.selectedPlantSeeds) == "table" then S.selectedPlantSeeds = data.selectedPlantSeeds end
		if type(data.selectedPlantRarities) == "table" then S.selectedPlantRarities = data.selectedPlantRarities end
		if type(data.selectedGears) == "table" then S.selectedGears = data.selectedGears end
		if type(data.selectedEggs) == "table" then S.selectedEggs = data.selectedEggs end
		if type(data.selectedRarities) == "table" then S.selectedRarities = data.selectedRarities end
		if type(data.selectedDeletePets) == "table" then S.selectedDeletePets = data.selectedDeletePets end
		if type(data.protectedPetRarities) == "table" then S.protectedPetRarities = data.protectedPetRarities end
		if data.keepMutatedPets ~= nil then S.keepMutatedPets = data.keepMutatedPets end
		if type(data.selectedSellRarities) == "table" then S.selectedSellRarities = data.selectedSellRarities end
		if data.keepMutatedPlants ~= nil then S.keepMutatedPlants = data.keepMutatedPlants end
		if data.keepMergedPlants ~= nil then S.keepMergedPlants = data.keepMergedPlants end
		if data.autoBuySeedsEnabled ~= nil then S.autoBuySeedsEnabled = data.autoBuySeedsEnabled end
		if data.autoBuyGearsEnabled ~= nil then S.autoBuyGearsEnabled = data.autoBuyGearsEnabled end
		if data.autoBuyEggsEnabled ~= nil then S.autoBuyEggsEnabled = data.autoBuyEggsEnabled end
		if data.autoPlaceEggsEnabled ~= nil then S.autoPlaceEggsEnabled = data.autoPlaceEggsEnabled end
		if data.autoHatchEggsEnabled ~= nil then S.autoHatchEggsEnabled = data.autoHatchEggsEnabled end
		if data.autoDeletePetsEnabled ~= nil then S.autoDeletePetsEnabled = data.autoDeletePetsEnabled end
		if data.autoSellPlantsEnabled ~= nil then S.autoSellPlantsEnabled = data.autoSellPlantsEnabled end
		if data.autoMergePlantsEnabled ~= nil then S.autoMergePlantsEnabled = data.autoMergePlantsEnabled end
		if data.autoPlantSeedsEnabled ~= nil then S.autoPlantSeedsEnabled = data.autoPlantSeedsEnabled end
		if data.autoWaterEnabled ~= nil then S.autoWaterEnabled = data.autoWaterEnabled end
		if data.autoAirdropEnabled ~= nil then S.autoAirdropEnabled = data.autoAirdropEnabled end
		if data.autoQuestEnabled ~= nil then S.autoQuestEnabled = data.autoQuestEnabled end
		if data.vipRerollEnabled ~= nil then S.vipRerollEnabled = data.vipRerollEnabled end
		if type(data.vipTargetTiers) == "table" then S.vipTargetTiers = data.vipTargetTiers end
		if data.autoSpinEnabled ~= nil then S.autoSpinEnabled = data.autoSpinEnabled end
		if data.spinTier ~= nil then S.spinTier = data.spinTier end
		if data.minSpinSunshine ~= nil then S.minSpinSunshine = safeNum(data.minSpinSunshine, 2000000) end
		if data.autoBuyEnabled ~= nil then S.autoBuyEnabled = data.autoBuyEnabled end
		if data.autoCollectEnabled ~= nil then S.autoCollectEnabled = data.autoCollectEnabled end
		if data.autoOpenSeedsEnabled ~= nil then S.autoOpenSeedsEnabled = data.autoOpenSeedsEnabled end
		if data.speedOn ~= nil then S.speedOn = data.speedOn end
		if data.lowMemOn ~= nil then S.lowMemOn = data.lowMemOn end
		if type(data.selectedMergePlants) == "table" then S.selectedMergePlants = data.selectedMergePlants end
		if data.autoShovelEnabled ~= nil then S.autoShovelEnabled = data.autoShovelEnabled end
		if type(data.selectedShovelPlants) == "table" then S.selectedShovelPlants = data.selectedShovelPlants end
		if type(data.shovelRarities) == "table" then S.shovelRarities = data.shovelRarities end
		if data.shovelProtectHighTier ~= nil then S.shovelProtectHighTier = data.shovelProtectHighTier end
		if data.shovelMaxTier ~= nil then S.shovelMaxTier = safeNum(data.shovelMaxTier, 2) end
		if data.shovelProtectMutated ~= nil then S.shovelProtectMutated = data.shovelProtectMutated end
		if data.shovelProtectHighStars ~= nil then S.shovelProtectHighStars = data.shovelProtectHighStars end
		if data.shovelMaxStars ~= nil then S.shovelMaxStars = safeNum(data.shovelMaxStars, 3) end
		if data.autoEquipFarmersEnabled ~= nil then S.autoEquipFarmersEnabled = data.autoEquipFarmersEnabled end
		if data.webhookNotifyEnabled ~= nil then S.webhookNotifyEnabled = data.webhookNotifyEnabled end
		if data.webhookUrl ~= nil then S.webhookUrl = data.webhookUrl end
		if data.autoFarmEnabled ~= nil then S.autoFarmEnabled = data.autoFarmEnabled end
		
		-- Sync UI Toggles
		if UI_Toggles.lowMem then UI_Toggles.lowMem.set(S.lowMemOn) end
		if UI_Toggles.speed then UI_Toggles.speed.set(S.speedOn) end
		if UI_Toggles.autoCollect then UI_Toggles.autoCollect.set(S.autoCollectEnabled) end
		if UI_Toggles.autoBuySeeds then UI_Toggles.autoBuySeeds.set(S.autoBuySeedsEnabled) end
		if UI_Toggles.autoOpenPacks then UI_Toggles.autoOpenPacks.set(S.autoOpenSeedsEnabled) end
		if UI_Toggles.autoPlant then UI_Toggles.autoPlant.set(S.autoPlantSeedsEnabled) end
		if UI_Toggles.autoWater then UI_Toggles.autoWater.set(S.autoWaterEnabled) end
		if UI_Toggles.autoMerge then UI_Toggles.autoMerge.set(S.autoMergePlantsEnabled) end
		if UI_Toggles.autoShovel then UI_Toggles.autoShovel.set(S.autoShovelEnabled) end
		if UI_Toggles.shovelProtectMutated then UI_Toggles.shovelProtectMutated.set(S.shovelProtectMutated) end
		if UI_Toggles.shovelProtectHighTier then UI_Toggles.shovelProtectHighTier.set(S.shovelProtectHighTier) end
		if UI_Toggles.shovelProtectHighStars then UI_Toggles.shovelProtectHighStars.set(S.shovelProtectHighStars) end
		if UI_Toggles.autoSell then UI_Toggles.autoSell.set(S.autoSellPlantsEnabled) end
		if UI_Toggles.keepMutatedPlants then UI_Toggles.keepMutatedPlants.set(S.keepMutatedPlants) end
		if UI_Toggles.keepMergedPlants then UI_Toggles.keepMergedPlants.set(S.keepMergedPlants) end
		if UI_Toggles.autoPlaceEggs then UI_Toggles.autoPlaceEggs.set(S.autoPlaceEggsEnabled) end
		if UI_Toggles.autoHatchEggs then UI_Toggles.autoHatchEggs.set(S.autoHatchEggsEnabled) end
		if UI_Toggles.autoDeletePets then UI_Toggles.autoDeletePets.set(S.autoDeletePetsEnabled) end
		if UI_Toggles.keepMutatedPets then UI_Toggles.keepMutatedPets.set(S.keepMutatedPets) end
		if UI_Toggles.autoBuyEggs then UI_Toggles.autoBuyEggs.set(S.autoBuyEggsEnabled) end
		if UI_Toggles.autoBuyGears then UI_Toggles.autoBuyGears.set(S.autoBuyGearsEnabled) end
		if UI_Toggles.autoBuyFarmers then UI_Toggles.autoBuyFarmers.set(S.autoBuyEnabled) end
		if UI_Toggles.autoEquipFarmers then UI_Toggles.autoEquipFarmers.set(S.autoEquipFarmersEnabled) end
		if UI_Toggles.webhookNotify then UI_Toggles.webhookNotify.set(S.webhookNotifyEnabled) end
		if UI_Toggles.autoFarm then UI_Toggles.autoFarm.set(S.autoFarmEnabled) end
		if UI_Toggles.autoSpin then UI_Toggles.autoSpin.set(S.autoSpinEnabled) end
		if UI_Toggles.autoQuest then UI_Toggles.autoQuest.set(S.autoQuestEnabled) end
		if UI_Toggles.autoAirdrop then UI_Toggles.autoAirdrop.set(S.autoAirdropEnabled) end
		if UI_Toggles.vipReroll then UI_Toggles.vipReroll.set(S.vipRerollEnabled) end
		
		-- Sync Checkboxes
		for sName, item in pairs(seedCheckboxes) do
			local isSel = S.selectedSeeds[sName] == true
			item.chk.Text = isSel and "X" or ""
			item.chk.BackgroundColor3 = isSel and C_GREEN or Color3.fromRGB(40, 45, 60)
			item.chk.TextColor3 = isSel and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
			item.strk.Color = isSel and item.group.color or C_BORDER
		end
		for rName, item in pairs(plantRarityCheckboxes) do
			local isSel = S.selectedPlantRarities[rName] == true
			item.chk.Text = isSel and "X" or ""
			item.chk.BackgroundColor3 = isSel and C_GREEN or Color3.fromRGB(40, 45, 60)
			item.chk.TextColor3 = isSel and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
			item.strk.Color = isSel and item.group.color or C_BORDER
		end
		for gName, item in pairs(gearCheckboxes) do
			local isSel = S.selectedGears[gName] == true
			item.chk.Text = isSel and "X" or ""
			item.chk.BackgroundColor3 = isSel and C_GREEN or Color3.fromRGB(40, 45, 60)
			item.chk.TextColor3 = isSel and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
			item.strk.Color = isSel and Color3.fromRGB(80, 180, 255) or C_BORDER
		end
		for eName, item in pairs(eggCheckboxes) do
			local isSel = S.selectedEggs[eName] == true
			item.chk.Text = isSel and "X" or ""
			item.chk.BackgroundColor3 = isSel and C_GREEN or Color3.fromRGB(40, 45, 60)
			item.chk.TextColor3 = isSel and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
			item.strk.Color = isSel and Color3.fromRGB(255, 215, 80) or C_BORDER
		end
		for pName, item in pairs(petCheckboxes) do
			local isSel = S.selectedDeletePets[pName] == true
			item.chk.Text = isSel and "X" or ""
			item.chk.BackgroundColor3 = isSel and C_RED or Color3.fromRGB(40, 45, 60)
			item.chk.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
			item.strk.Color = isSel and C_RED or C_BORDER
		end
		for pRarity, item in pairs(protectedPetCheckboxes) do
			local isProtected = S.protectedPetRarities[pRarity] == true
			item.chk.Text = isProtected and "X" or ""
			item.chk.BackgroundColor3 = isProtected and C_GREEN or Color3.fromRGB(40, 45, 60)
			item.chk.TextColor3 = isProtected and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
			item.strk.Color = isProtected and Color3.fromRGB(80, 180, 255) or C_BORDER
		end
		for rName, item in pairs(sellCheckboxes) do
			local isSel = S.selectedSellRarities[rName] == true
			item.chk.Text = isSel and "X" or ""
			item.chk.BackgroundColor3 = isSel and C_GREEN or Color3.fromRGB(40, 45, 60)
			item.chk.TextColor3 = isSel and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
			item.strk.Color = isSel and item.group.color or C_BORDER
		end
		for rName, item in pairs(farmerCheckboxes) do
			local isSel = S.selectedRarities[rName] == true
			item.chk.Text = isSel and "X" or ""
			item.chk.BackgroundColor3 = isSel and C_GREEN or Color3.fromRGB(40, 45, 60)
			item.chk.TextColor3 = isSel and Color3.fromRGB(10, 25, 15) or Color3.fromRGB(200, 200, 220)
			item.strk.Color = isSel and (FARMER_COLORS[rName] or C_GREEN) or C_BORDER
		end
		
		updateReserveUI()
		updateTierUI()
		
		if not silent and _G.MFGToast then
			_G.MFGToast("📥 Config Loaded", "All settings & selections restored.", Color3.fromRGB(80, 180, 255))
		end
	end
end

-- ====================================================
--  BOOTSTRAP MFG HUB
-- ====================================================
task.spawn(function()
	task.wait(0.3)
	if tabButtons["Main"] then tabButtons["Main"].select() end
	loadConfig(true)
	if webhookInput then webhookInput.Text = S.webhookUrl end
	if _G.MFGToast then
		_G.MFGToast("⚡ MFG HUB v26 Loaded", "Welcome, " .. player.DisplayName .. "!", Color3.fromRGB(88, 101, 242))
	end
end)