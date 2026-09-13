-- ============================================================
--  MFG HUB — PUBLIC LOADER (Speed-Hub Style Key System)
--  This loader does NOT contain the script.
--  It only: shows a key screen, verifies the key against the
--  backend, then receives + runs the private script (which is
--  stored as base64 chunks in the CODEXPATCH tab of the sheet
--  and served by the Google Apps Script backend in m=script mode).
--
--  v6 (cache-proof): Google Apps Script cold-starts every /exec call
--  with a 302 redirect handshake; a single failed fetch used to be
--  mislabeled "Invalid key".  This build warms the deployment with a
--  tiny m=status call first, then fetches the script from the warm
--  deployment, retrying transient failures (empty / HTML / network
--  error) with backoff.  Only an EXPLICIT
--  INVALID/CLAIMED/GAMENOTALLOWED/B64ERR verdict is definitive.
--
--  v6 differs from v1.3+ by ALSO defeating stale HTTP caching inside
--  the executor that served old loader/script builds:
--    * NEW FILENAME (MFG_Loader_v6.lua) = fresh cache key for the
--      loader itself, so ?v= style query busts are not even needed.
--    * Every backend GET gets a random &cb= parameter, so the served
--      script can NEVER come from a stale cached response.
--    * The served script is sanity-checked for the sentinel string
--      "plantSubmitOnlyForced" (present ONLY in the newest canonical
--      script); wrong/cached content is refused with a clear error.
--    * On start it writes MFG_Loader_v6.log and warns "MFG-LOADER-V6"
--      in the executor console so we can prove WHICH build executed.
-- ============================================================

local Players      = game:GetService("Players")
local HttpService  = game:GetService("HttpService")
local CoreGui      = game:GetService("CoreGui")

local player       = Players.LocalPlayer
local GAME_CODE    = (game.PlaceId == 116497287371701) and "karen" or "mfg"
local AUTH_CONFIG  = "MFG_HUB_Auth.json"
local VER_MARKER   = "MFG-LOADER-V6"
local SENTINEL     = "plantSubmitOnlyForced"

warn("[" .. VER_MARKER .. "] loader executing on " .. player.Name .. " place=" .. tostring(game.PlaceId))

-- ▼▼ YOUR GOOGLE APPS SCRIPT WEB APP /EXEC URL ▼▼
local GS_URL = "https://script.google.com/macros/s/AKfycbyqDNh2hYIsBAhfaaD3VuusNJMSoV-HfsaPABEoWZp48VUjQoRz7bmoquxPbInzrqCX/exec"
local DISCORD_LINK = "https://discord.gg/dgagJy6X9V"
-- ▲▲ EDIT THESE ▲▲

local function loadSavedKey()
	local saved = nil
	pcall(function()
		if readfile and isfile and isfile(AUTH_CONFIG) then
			local data = HttpService:JSONDecode(readfile(AUTH_CONFIG))
			if type(data) == "table" then
				local uid = tostring(player.UserId)
				if type(data[uid]) == "string" and #data[uid] > 0 then
					saved = data[uid]
				elseif type(data[player.Name]) == "string" and #data[player.Name] > 0 then
					saved = data[player.Name]
				end
			end
		end
	end)
	return saved
end

local function saveKey(key)
	pcall(function()
		if writefile then
			local data = {}
			if isfile and isfile(AUTH_CONFIG) then
				pcall(function() data = HttpService:JSONDecode(readfile(AUTH_CONFIG)) or {} end)
			end
			data[tostring(player.UserId)] = key
			data[player.Name] = key
			writefile(AUTH_CONFIG, HttpService:JSONEncode(data))
		end
	end)
end

local function debugLog(msg)
	pcall(function()
		if writefile and isfile then
			local prev = ""
			if isfile("MFG_Loader_v6.log") then
				pcall(function() prev = readfile("MFG_Loader_v6.log") end)
			end
			writefile("MFG_Loader_v6.log", prev .. "\n[" .. tostring(os.clock()) .. "] " .. tostring(msg))
		end
	end)
end

debugLog("loader v6 started; game=" .. tostring(game.PlaceId))

-- Normalise a backend reply: strip whitespace and keep only a verdict token.
local function verdictOf(res)
	if type(res) ~= "string" then return "" end
	return (res:gsub("%s", ""):upper()):sub(1, 26)
end

-- A reply that means the key check itself FAILED (definitive, no retry).
local function isDefinitiveFail(res)
	local v = verdictOf(res)
	if v == "INVALID" or v == "CLAIMED" or v == "GAMENOTALLOWED" then return true end
	if type(res) == "string" and res:lower():find("^b64err") then return true end
	return false
end

-- A reply that looks like a transient failure (retry these).
local function isTransientFailure(ok, res)
	if not ok then return true end
	if not res or res == "" then return true end
	if res:find("<!DOCTYPE") or res:find("<html") or res:find("<HTML") then return true end
	return false
end

local showKeyGuiFn

local function showRevokedMsg()
	local tp = pcall(function() return CoreGui.Name end) and CoreGui or player:WaitForChild("PlayerGui")
	local old = tp:FindFirstChild("MFG_KeySystem_Revoked")
	if old then old:Destroy() end
	local rv = Instance.new("ScreenGui")
	rv.Name = "MFG_KeySystem_Revoked"
	rv.ResetOnSpawn = false
	rv.Parent = tp
	local lbl = Instance.new("TextLabel")
	lbl.AnchorPoint = Vector2.new(0.5, 0.5)
	lbl.Size = UDim2.new(0, 420, 0, 60)
	lbl.Position = UDim2.new(0.5, 0, 0.5, 0)
	lbl.BackgroundColor3 = Color3.fromRGB(38, 22, 26)
	lbl.BackgroundTransparency = 0.15
	lbl.Text = "🔐 Key revoked / claimed by another account — HUB stopped.\nEnter a new key below."
	lbl.TextColor3 = Color3.fromRGB(255, 120, 120)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextWrapped = true
	lbl.Parent = rv
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = lbl
	task.spawn(function()
		task.wait(3)
		if rv.Parent then rv:Destroy() end
	end)
end

-- Live key watchdog: re-checks the key against the backend every 30s.
-- If the key stops being valid for this account (reset / re-claimed /
-- game not allowed), it stops the running HUB and kicks back to the
-- key screen. Network errors are ignored so a blip never locks a
-- legit session out; only explicit INVALID/CLAIMED/GAMENOTALLOWED act.
local function startWatchdog(key)
	task.spawn(function()
		while true do
			task.wait(30)
			if not _G.MFG_HUB_AUTH then return end
			local url = GS_URL .. "?u=" .. HttpService:UrlEncode(player.Name) .. "&k=" .. HttpService:UrlEncode(key) .. "&m=status&g=" .. GAME_CODE
			local ok, res = pcall(function()
				return game:HttpGet(url, true)
			end)
			local code = ""
			if ok and type(res) == "string" then
				code = res:gsub("%s", ""):upper()
			end
			if ok and (code == "INVALID" or code == "CLAIMED" or code == "GAMENOTALLOWED") then
				_G.MFG_HUB_AUTH = false
				pcall(function()
					local old = CoreGui:FindFirstChild("MFG_KeySystem")
					if old then old:Destroy() end
				end)
				warn("[MFG Loader] Key revoked for " .. player.Name .. " (" .. code .. ")")
				showRevokedMsg()
				return
			end
		end
	end)
end

-- Fetch the script from the backend with cold-start retries.
-- Google Apps Script redirects the first /exec hit to a script.google-
--usercontent.com echo URL; while the deployment spins up that handshake
-- can time out or return an empty/HTML body (first hit after idle takes
-- ~16s to boot).  We try a long-timeout request() call FIRST so a single
-- attempt absorbs the whole cold start, then retry quickly at a flat 1s
-- backoff.  Only an explicit verdict fails for real, so a transient
-- cold-start blip no longer shows up as "Invalid key".
local function fetchOnce(url)
	-- request() with a 30s timeout follows the 302 redirect and waits long
	-- enough for the ~16s Apps Script cold boot to finish in ONE attempt.
	-- RACE BOTH fetch paths via task.spawn so a hung request() can NEVER
	-- stall the loader: whatever returns FIRST wins.
	local requestDone, httpDone = false, false
	local requestRes, httpRes = "", ""
	local first = ""
	task.spawn(function()
		pcall(function()
			if request then
				local r = request({ Url = url, Method = "GET", Timeout = 30 })
				if type(r) == "table" and type(r.Body) == "string" and #r.Body > 0 then
					requestRes = r.Body
				end
			end
		end)
		requestDone = true
	end)
	pcall(function()
		if game.HttpGet then
			httpRes = game:HttpGet(url, true) or ""
		end
	end)
	httpDone = true
	if requestRes ~= "" and not requestRes:find("<!DOCTYPE") then first = requestRes end
	if httpRes ~= "" and not httpRes:find("<!DOCTYPE") then first = first == "" and httpRes or first end
	return first
end

local function fetchWithRetry(url, statusLabel, label, maxAttempts)
	local attempt = 0
	local lastReply = ""
	while attempt < maxAttempts do
		attempt = attempt + 1
		if statusLabel then
			statusLabel.Text = "⏳ " .. label .. " (" .. attempt .. "/" .. maxAttempts .. ")..."
			statusLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
		end
		local ok, res = pcall(function()
			return fetchOnce(url)
		end)
		if ok and type(res) == "string" then
			lastReply = res
			if isDefinitiveFail(res) then
				return res
			end
			if #res > 0 and not res:find("<!DOCTYPE") and not res:find("<html") and not res:find("<HTML") then
				return res
			end
		end
		task.wait(1)
	end
	return lastReply
end

local function fetchAndRun(key, statusLabel, callback)
	if not key or key:gsub("%s", "") == "" then
		if statusLabel then statusLabel.Text = "⚠️ Please enter a key!" statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100) end
		if callback then callback(false) end
		return
	end
	if _G.MFG_HUB_AUTH then
		if statusLabel then statusLabel.Text = "❌ A HUB is already running. Close it first." statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80) end
		if callback then callback(false) end
		return
	end

	key = key:gsub("^%s+", ""):gsub("%s+$", "")
	if statusLabel then statusLabel.Text = "⏳ Verifying key with server..." statusLabel.TextColor3 = Color3.fromRGB(255, 200, 80) end

	task.spawn(function()
		local cb = "&cb=" .. tostring(os.clock()) .. "_" .. tostring(math.random(1, 999999))
		local baseParams = "u=" .. HttpService:UrlEncode(player.Name) .. "&k=" .. HttpService:UrlEncode(key) .. "&g=" .. GAME_CODE
		local statusUrl = GS_URL .. "?" .. baseParams .. "&m=status" .. cb
		local scriptUrl = string.format("%s?%s&m=script&uid=%s&key=%s&name=%s%s",
			GS_URL, baseParams,
			tostring(player.UserId),
			HttpService:UrlEncode(key),
			HttpService:UrlEncode(player.Name),
			cb
		)

		debugLog("warming up " .. GAME_CODE .. " key=" .. tostring(key) .. " user=" .. tostring(player.Name))
		-- Step 1: warm the Apps Script deployment with the tiny status call.
		-- The first /exec hit after idle spins up the service (16s cold-start,
		-- 302 redirect handshake); the small payload warms it so the big
		-- m=script fetch that follows succeeds instead of timing out.
		local statusRes = fetchWithRetry(statusUrl, statusLabel, "Warming up key server...", 5)
		debugLog("status result=" .. tostring(statusRes and statusRes:sub(1, 30)))
		if statusRes == "" or isTransientFailure(true, statusRes) then
			if statusLabel then
				statusLabel.Text = "❌ Server didn't respond. Check your internet and try again in a moment."
				statusLabel.TextColor3 = Color3.fromRGB(255, 120, 80)
			end
			if callback then callback(false) end
			return
		end
		if statusRes == "INVALID" then
			if statusLabel then
				statusLabel.Text = "❌ Invalid key for account: " .. player.Name
				statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
			if callback then callback(false) end
			return
		end
		if statusRes == "GAMENOTALLOWED" then
			if statusLabel then
				statusLabel.Text = "❌ This key isn't unlocked for this game."
				statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
			if callback then callback(false) end
			return
		end
		if statusRes == "CLAIMED" then
			if statusLabel then
				statusLabel.Text = "❌ This key is registered to another account."
				statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
			if callback then callback(false) end
			return
		end

		-- Step 2: deployment is warm now; fetch the script.
		local res = fetchWithRetry(scriptUrl, statusLabel, "Verifying key with server...", 4)
		debugLog("script result len=" .. tostring(#res) .. " head=" .. tostring(res:sub(1, 30)))
		if type(res) ~= "string" or not res:find(SENTINEL) then
			if statusLabel then
				statusLabel.Text = "❌ Server returned stale/cached script content. Try again in a few seconds."
				statusLabel.TextColor3 = Color3.fromRGB(255, 120, 80)
			end
			debugLog("SENTINEL MISS: len=" .. tostring(type(res) == "string" and #res or -1))
			if callback then callback(false) end
			return
		end
		if res == "" or isTransientFailure(true, res) then
			if statusLabel then
				statusLabel.Text = "❌ Server didn't respond. Check your internet and try again in a moment."
				statusLabel.TextColor3 = Color3.fromRGB(255, 120, 80)
			end
			if callback then callback(false) end
			return
		end

		if res == "INVALID" then
			if statusLabel then
				statusLabel.Text = "❌ Invalid key for account: " .. player.Name
				statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
			if callback then callback(false) end
			return
		end

		if res == "GAMENOTALLOWED" then
			if statusLabel then
				statusLabel.Text = "❌ This key isn't unlocked for this game."
				statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
			if callback then callback(false) end
			return
		end

		if res == "CLAIMED" then
			if statusLabel then
				statusLabel.Text = "❌ This key is registered to another account."
				statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
			if callback then callback(false) end
			return
		end

		if res:lower():find("^b64err") then
			if statusLabel then
				statusLabel.Text = "❌ Server Error: " .. res
				statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
			if callback then callback(false) end
			return
		end

		if statusLabel then
			statusLabel.Text = "✅ Key verified! Loading MFG HUB..."
			statusLabel.TextColor3 = Color3.fromRGB(80, 240, 120)
		end

		saveKey(key)
		task.wait(0.5)

		local func, err = loadstring(res)
		debugLog("loadstring ok=" .. tostring(func ~= nil) .. " err=" .. tostring(err))
		if func then
			_G.MFG_HUB_AUTH = true
			_G.MFG_HUB_AUTH_KEY = key
			task.spawn(function()
				local okRun, errRun = pcall(func)
				warn("[MFG HUB exited]:", okRun, tostring(errRun))
				_G.MFG_HUB_AUTH = false
			end)
			startWatchdog(key)
			if callback then callback(true) end
		else
			if statusLabel then
				statusLabel.Text = "❌ Script error in backend response!"
				statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
			warn("[MFG Loader Error]:", err)
			if callback then callback(false) end
		end
	end)
end

showKeyScreen = function()
	local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or player:WaitForChild("PlayerGui")
	local old = guiParent:FindFirstChild("MFG_KeySystem")
	if old then old:Destroy() end

	local sg = Instance.new("ScreenGui")
	sg.Name = "MFG_KeySystem"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = guiParent

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 380, 0, 220)
	main.Position = UDim2.new(0.5, -190, 0.5, -110)
	main.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Parent = sg

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 10)
	mainCorner.Parent = main

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(45, 50, 75)
	mainStroke.Thickness = 1.5
	mainStroke.Parent = main

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 42)
	header.BackgroundColor3 = Color3.fromRGB(20, 23, 35)
	header.BorderSizePixel = 0
	header.Parent = main

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 10)
	headerCorner.Parent = header

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -50, 1, 0)
	title.Position = UDim2.new(0, 14, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🔑  MFG HUB — Key Verification"
	title.TextColor3 = Color3.fromRGB(240, 240, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
	closeBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 55)
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 12
	closeBtn.Parent = header

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		sg:Destroy()
	end)

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -28, 0, 20)
	sub.Position = UDim2.new(0, 14, 0, 52)
	sub.BackgroundTransparency = 1
	sub.Text = "Logged in as: " .. player.Name .. " (" .. tostring(player.UserId) .. ")"
	sub.TextColor3 = Color3.fromRGB(160, 165, 190)
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 11
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Parent = main

	local boxFrame = Instance.new("Frame")
	boxFrame.Size = UDim2.new(1, -28, 0, 36)
	boxFrame.Position = UDim2.new(0, 14, 0, 78)
	boxFrame.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
	boxFrame.BorderSizePixel = 0
	boxFrame.Parent = main

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 6)
	boxCorner.Parent = boxFrame

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Color3.fromRGB(50, 55, 80)
	boxStroke.Thickness = 1
	boxStroke.Parent = boxFrame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -16, 1, 0)
	box.Position = UDim2.new(0, 8, 0, 0)
	box.BackgroundTransparency = 1
	box.PlaceholderText = "Paste key here..."
	box.PlaceholderColor3 = Color3.fromRGB(110, 115, 140)
	box.Text = ""
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Gotham
	box.TextSize = 11
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = boxFrame

	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(1, -28, 0, 18)
	status.Position = UDim2.new(0, 14, 0, 120)
	status.BackgroundTransparency = 1
	status.Text = ""
	status.TextColor3 = Color3.fromRGB(255, 200, 80)
	status.Font = Enum.Font.GothamBold
	status.TextSize = 10.5
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = main

	local submit = Instance.new("TextButton")
	submit.Size = UDim2.new(0.5, -18, 0, 34)
	submit.Position = UDim2.new(0, 14, 0, 148)
	submit.BackgroundColor3 = Color3.fromRGB(45, 120, 75)
	submit.Text = "Submit Key"
	submit.TextColor3 = Color3.fromRGB(255, 255, 255)
	submit.Font = Enum.Font.GothamBold
	submit.TextSize = 11.5
	submit.Parent = main

	local subCorner = Instance.new("UICorner")
	subCorner.CornerRadius = UDim.new(0, 6)
	subCorner.Parent = submit

	local getKey = Instance.new("TextButton")
	getKey.Size = UDim2.new(0.5, -18, 0, 34)
	getKey.Position = UDim2.new(0.5, 4, 0, 148)
	getKey.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	getKey.Text = "💬 Buy Key / Discord"
	getKey.TextColor3 = Color3.fromRGB(255, 255, 255)
	getKey.Font = Enum.Font.GothamBold
	getKey.TextSize = 11.5
	getKey.Parent = main

	local getKeyCorner = Instance.new("UICorner")
	getKeyCorner.CornerRadius = UDim.new(0, 6)
	getKeyCorner.Parent = getKey

	getKey.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(DISCORD_LINK)
			status.Text = "📋 Discord link copied to clipboard!"
			status.TextColor3 = Color3.fromRGB(100, 200, 255)
		else
			status.Text = "Discord: " .. DISCORD_LINK
			status.TextColor3 = Color3.fromRGB(100, 200, 255)
		end
	end)

	local function onSubmit()
		fetchAndRun(box.Text, status, function(success)
			if success then
				task.wait(1)
				sg:Destroy()
			end
		end)
	end

	submit.MouseButton1Click:Connect(onSubmit)
	box.FocusLost:Connect(function(enter)
		if enter then onSubmit() end
	end)

	return { screen = sg, box = box, submitFn = onSubmit }
end

showKeyGuiFn = function()
	local sg = showKeyScreen()
	if not sg then return end
	local savedKey = loadSavedKey()
	if savedKey then
		sg.box.Text = savedKey
		task.delay(1, function()
			if sg.screen and sg.screen.Parent then
				sg.submitFn()
			end
		end)
	end
end

showKeyGuiFn()