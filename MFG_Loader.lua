-- ============================================================
--  MFG HUB — PUBLIC LOADER (Speed-Hub Style Key System)
-- ============================================================

local Players      = game:GetService("Players")
local HttpService  = game:GetService("HttpService")
local CoreGui      = game:GetService("CoreGui")

local player       = Players.LocalPlayer
local AUTH_CONFIG  = "MFG_HUB_Auth.json"

-- ▼▼ YOUR GOOGLE APPS SCRIPT WEB APP /EXEC URL ▼▼
local GS_URL = "https://script.google.com/macros/s/AKfycbyrSDew8mAt2PqsxBgYsqtJNcawaQB6RNBjVqjg1viMPtpwHn-HPMfz8ydlpk3CL1x7/exec"
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

local function fetchAndRun(key, statusLabel, callback)
	if not key or key:gsub("%s", "") == "" then
		if statusLabel then statusLabel.Text = "⚠️ Please enter a key!" statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100) end
		if callback then callback(false) end
		return
	end

	key = key:gsub("^%s+", ""):gsub("%s+$", "")
	if statusLabel then statusLabel.Text = "⏳ Verifying key with server..." statusLabel.TextColor3 = Color3.fromRGB(255, 200, 80) end

	task.spawn(function()
		local url = string.format("%s?u=%s&k=%s&m=script&uid=%s&key=%s&name=%s",
			GS_URL,
			HttpService:UrlEncode(player.Name),
			HttpService:UrlEncode(key),
			tostring(player.UserId),
			HttpService:UrlEncode(key),
			HttpService:UrlEncode(player.Name)
		)

		local ok, res = pcall(function()
			return game:HttpGet(url, true)
		end)

		if not ok or not res or res == "" or res == "INVALID" or res:find("^B64ERR") or res:find("<!DOCTYPE") or res:find("<html") then
			if statusLabel then
				if res and res:find("^B64ERR") then
					statusLabel.Text = "❌ Server Error: " .. res
				else
					statusLabel.Text = "❌ Invalid key for account: " .. player.Name
				end
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
		if func then
			task.spawn(func)
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

local function showKeyGui()
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
end

local savedKey = loadSavedKey()
if savedKey then
	fetchAndRun(savedKey, nil, function(success)
		if not success then
			showKeyGui()
		end
	end)
else
	showKeyGui()
end
