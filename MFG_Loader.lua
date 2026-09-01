-- ============================================================
--  MFG HUB — PUBLIC LOADER  (Speed-Hub style)
--  This is the ONLY file on GitHub. It contains NO script logic
--  and NO secrets. It just asks your Google backend for the real
--  script, and the backend returns it ONLY when the request has a
--  valid per-user key that is in your Google Sheet.
--
--  SETUP (edit the two lines below):
--    GS_URL  = your Google Apps Script Web App /exec URL
--    GAME_ID = the placeId your backend should target (optional use)
-- ============================================================

local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")

-- ▼▼ EDIT THESE ▼▼
local GS_URL = "https://script.google.com/macros/s/AKfycbyrSDew8mAt2PqsxBgYsqtJNcawaQB6RNBjVqjg1viMPtpwHn-HPMfz8ydlpk3CL1x7/exec"
-- ▲▲ EDIT THESE ▲▲

local player = Players.LocalPlayer
local AUTH_CONFIG = "MFG_HUB_Auth.json"

-- Read the key previously saved by MFG HUB (per Roblox UserId)
local function loadSavedKey()
	local saved = nil
	pcall(function()
		if readfile and isfile and isfile(AUTH_CONFIG) then
			local data = HttpService:JSONDecode(readfile(AUTH_CONFIG))
			if type(data) == "table" then
				local uid = tostring(player.UserId)
				if type(data[uid]) == "string" then
					saved = data[uid]
				elseif type(data[player.UserId]) == "string" then
					saved = data[player.UserId]
				else
					for k, v in pairs(data) do
						if tostring(k) == uid and type(v) == "string" then saved = v end
					end
				end
			end
		end
	end)
	return saved
end

local key = loadSavedKey()
if not key or key == "" then
	warn("MFG HUB: no saved key. Run MFG HUB once and enter your key, then re-run this loader.")
	return
end

local function fetch(mode)
	local url = GS_URL
		.. "?u=" .. HttpService:UrlEncode(player.Name)
		.. "&k=" .. HttpService:UrlEncode(key)
		.. (mode == "script" and "&m=script" or "")
	local body = ""
	pcall(function()
		if request then
			local res = request({ Url = url, Method = "GET", Timeout = 15 })
			if type(res) == "table" then body = res.Body or "" end
		elseif HttpGet then
			body = HttpGet(game, url) or ""
		end
	end)
	return body
end

-- 1) Quick auth check so we fail fast with a friendly message
local check = fetch("")
if check:gsub("%s", ""):upper() ~= "VALID" then
	warn("MFG HUB: your key did not verify. Re-run MFG HUB and enter a valid key.")
	return
end

-- 2) Fetch the real script from the private backend
local script = fetch("script")
if not script or script:gsub("%s", "") == "" or script:gsub("%s", ""):upper() == "INVALID" then
	warn("MFG HUB: could not load script from backend.")
	return
end

local fn, err = loadstring(script)
if not fn then
	warn("MFG HUB: script failed to compile: " .. tostring(err))
	return
end

-- Run the script on its own thread so a slow or busy boot can never wedge
-- the executor's main thread (the usual cause of "freeze after rejoin").
task.spawn(fn)
