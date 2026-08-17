-- ============================================================
-- PS99 ULTIMATE HUB v4.0 (Delta Optimized)
-- Tabs: Auto Farm, Egg, Main, Backrooms, Automatic, Chest,
--       Minigames, Teleport, Player, Fly, Misc + HUGE HUNTER
-- Features: Anti-AFK, Auto Farm, Auto Hatch, Auto Boost, Auto Upgrade
--           Webhook, Huge/Titanic Tracker
-- ============================================================
local pl = game:GetService("Players").LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local vu = game:GetService("VirtualUser")
local uis = game:GetService("UserInputService")
local http = game:GetService("HttpService")
local ws = game:GetService("Workspace")
local cam = ws.CurrentCamera

-- ===== CONFIG =====
local webhookURL = ""  -- Paste your Discord Webhook URL here

-- ===== STATE =====
local toggles = {
    farm = true,
    hatch = true,
    boost = true,
    upgrade = true,
    backrooms = false,
    chest = false,
    minigames = false,
    teleport = false,
    fly = false,
    antiAFK = true,
    hugeNotify = true,
}
local stats = {huge = 0, titanic = 0, hatches = 0, lastHuges = {}}
local lastPets = {}
local running = true

-- ===== ANTI-AFK =====
local function antiAFK()
    if not toggles.antiAFK then return end
    pcall(function()
        local vp = cam.ViewportSize
        vu:CaptureController()
        vu:ClickButtonAt(Vector2.new(vp.X/2 + math.random(-5,5), vp.Y/2 + math.random(-5,5)))
        local char = pl.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            root.Velocity = root.Velocity + Vector3.new(math.random(-1,1)*0.5, 0, math.random(-1,1)*0.5)
        end
    end)
end

-- ===== WEBHOOK =====
local function sendWebhook(msg)
    if webhookURL == "" then return end
    pcall(function()
        local data = {content = msg}
        http:PostAsync(webhookURL, http:JSONEncode(data))
    end)
end

-- ===== PET SCANNER =====
local function getPetNames()
    local names = {}
    local containers = {pl.Backpack, pl:FindFirstChild("Inventory")}
    for _, cont in pairs(containers) do
        if cont then
            for _, pet in pairs(cont:GetChildren()) do
                if pet:IsA("Tool") and pet:FindFirstChild("Pet") then
                    table.insert(names, pet.Name)
                end
            end
        end
    end
    return names
end

local function checkPets()
    local current = getPetNames()
    for _, name in pairs(current) do
        local found = false
        for _, old in pairs(lastPets) do
            if old == name then found = true; break end
        end
        if not found then
            local lower = name:lower()
            if lower:find("titanic") then
                stats.titanic = stats.titanic + 1
                if toggles.hugeNotify then sendWebhook("🚀 TITANIC: " .. name .. " by " .. pl.Name) end
                table.insert(stats.lastHuges, "Titanic " .. name)
            elseif lower:find("huge") then
                stats.huge = stats.huge + 1
                if toggles.hugeNotify then sendWebhook("🔥 HUGE: " .. name .. " by " .. pl.Name) end
                table.insert(stats.lastHuges, "Huge " .. name)
            end
            table.insert(lastPets, name)
        end
    end
    if #stats.lastHuges > 5 then table.remove(stats.lastHuges, 1) end
end

-- ===== UI HELPERS =====
local function getEventGUI()
    for _, g in pairs(pl.PlayerGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled and g.Visible then
            local n = g.Name:lower()
            if n:find("event") or n:find("lucky") or n:find("pinata") or n:find("race") or n:find("hunt") then
                return g
            end
        end
    end
    return nil
end

local function clickButton(gui, pattern)
    if not gui then return false end
    for _, b in pairs(gui:GetDescendants()) do
        if b:IsA("TextButton") or b:IsA("ImageButton") then
            local t = (b.Text or b.Name or ""):lower()
            if t:find(pattern) then
                pcall(b.Click, b)
                return true
            end
        end
    end
    return false
end

local function useBoosts()
    local function findUse(container, pattern)
        for _, item in pairs(container:GetChildren()) do
            if item:IsA("Tool") or item:IsA("Item") then
                if (item.Name:lower()):find(pattern) then
                    pcall(item.Activate, item)
                    return true
                end
            end
        end
        return false
    end
    findUse(pl.Backpack, "lucky")
    findUse(pl.Backpack, "fruit")
    findUse(pl.Backpack, "potion")
    local inv = pl:FindFirstChild("Inventory")
    if inv then findUse(inv, "lucky") end
    local gui = getEventGUI()
    if gui then
        clickButton(gui, "use")
        clickButton(gui, "boost")
        clickButton(gui, "luck")
    end
end

-- ===== MAIN LOOP =====
spawn(function()
    lastPets = getPetNames()
    while running do
        if toggles.antiAFK then antiAFK() end
        local eventGUI = getEventGUI()
        if eventGUI then
            if toggles.hatch then
                clickButton(eventGUI, "hatch")
                clickButton(eventGUI, "open")
                clickButton(eventGUI, "egg")
                clickButton(eventGUI, "buy")
                clickButton(eventGUI, "claim")
                stats.hatches = stats.hatches + 1
            end
            if toggles.boost then useBoosts() end
            if toggles.upgrade then
                clickButton(eventGUI, "upgrade")
                clickButton(eventGUI, "luck")
            end
            if toggles.backrooms then
                clickButton(eventGUI, "backroom")
                clickButton(eventGUI, "maze")
            end
            if toggles.chest then
                clickButton(eventGUI, "chest")
                clickButton(eventGUI, "collect")
            end
            if toggles.minigames then
                clickButton(eventGUI, "minigame")
                clickButton(eventGUI, "play")
            end
            if toggles.teleport then
                clickButton(eventGUI, "teleport")
                clickButton(eventGUI, "best")
            end
        end
        if toggles.farm then
            pcall(function()
                local vp = cam.ViewportSize
                vu:CaptureController()
                vu:ClickButtonAt(Vector2.new(vp.X/2, vp.Y*0.7))
            end)
        end
        if toggles.fly then
            pcall(function()
                local char = pl.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.Velocity = Vector3.new(0, 10, 0)
                    end
                end
            end)
        end
        checkPets()
        wait(0.15)
    end
end)

-- ============================================================
-- SIDEBAR TAB UI
-- ============================================================
local scr = Instance.new("ScreenGui")
scr.Name = "PS99Hub"
scr.ResetOnSpawn = false
scr.Parent = pl.PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 350, 0, 400)
main.Position = UDim2.new(1, -370, 0, 30)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255, 200, 0)
main.Parent = scr

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
title.TextColor3 = Color3.new(0,0,0)
title.Text = "PS99 ULTIMATE HUB"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = main

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 80, 1, -30)
sidebar.Position = UDim2.new(0, 0, 0, 30)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -80, 1, -30)
content.Position = UDim2.new(0, 80, 0, 30)
content.BackgroundTransparency = 1
content.Parent = main

local tabNames = {"Auto Farm", "Egg", "Main", "Backrooms", "Automatic", "Chest", "Minigames", "Teleport", "Player", "Fly", "Misc", "Huge Hunter"}

local tabButtons = {}
local contentFrames = {}

local function switchTab(name)
    for i, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = (btn.Name == name) and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(40, 40, 60)
        btn.TextColor3 = (btn.Name == name) and Color3.new(0,0,0) or Color3.new(1,1,1)
    end
    for fname, frame in pairs(contentFrames) do
        frame.Visible = (fname == name)
    end
end

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*30)
    btn.BackgroundColor3 = (i==1) and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = (i==1) and Color3.new(0,0,0) or Color3.new(1,1,1)
    btn.Text = name
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Name = name
    btn.Parent = sidebar
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.TouchTap:Connect(function() switchTab(name) end)
    table.insert(tabButtons, btn)

    local cf = Instance.new("ScrollingFrame")
    cf.Size = UDim2.new(1, -8, 1, -8)
    cf.Position = UDim2.new(0, 4, 0, 4)
    cf.BackgroundTransparency = 1
    cf.BorderSizePixel = 0
    cf.CanvasSize = UDim2.new(0, 0, 0, 300)
    cf.ScrollBarThickness = 3
    cf.Visible = (i==1)
    cf.Name = name
    cf.Parent = content
    contentFrames[name] = cf
end

local function addToggle(frame, label, y, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -8, 0, 30)
    f.Position = UDim2.new(0, 4, 0, y)
    f.BackgroundTransparency = 1
    f.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 170, 0, 30)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Text = label
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.Parent = f

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 24)
    btn.Position = UDim2.new(0, 190, 0, 3)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(0,200,80) or Color3.fromRGB(50,50,70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = getter() and "ON" or "OFF"
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        btn.BackgroundColor3 = getter() and Color3.fromRGB(0,200,80) or Color3.fromRGB(50,50,70)
        btn.Text = getter() and "ON" or "OFF"
    end)
    btn.TouchTap:Connect(function()
        setter(not getter())
        btn.BackgroundColor3 = getter() and Color3.fromRGB(0,200,80) or Color3.fromRGB(50,50,70)
        btn.Text = getter() and "ON" or "OFF"
    end)
    return f
end

-- ===== POPULATE TABS =====
local y = 0
addToggle(contentFrames["Auto Farm"], "Auto Farm", y, function() return toggles.farm end, function(v) toggles.farm = v end); y = y + 35
addToggle(contentFrames["Auto Farm"], "Anti AFK", y, function() return toggles.antiAFK end, function(v) toggles.antiAFK = v end); y = y + 35

y = 0
addToggle(contentFrames["Egg"], "Auto Hatch", y, function() return toggles.hatch end, function(v) toggles.hatch = v end); y = y + 35

y = 0
addToggle(contentFrames["Main"], "Auto Boost", y, function() return toggles.boost end, function(v) toggles.boost = v end); y = y + 35
addToggle(contentFrames["Main"], "Auto Upgrade", y, function() return toggles.upgrade end, function(v) toggles.upgrade = v end); y = y + 35

y = 0
addToggle(contentFrames["Backrooms"], "Backrooms Event", y, function() return toggles.backrooms end, function(v) toggles.backrooms = v end); y = y + 35

y = 0
addToggle(contentFrames["Chest"], "Auto Collect Chests", y, function() return toggles.chest end, function(v) toggles.chest = v end); y = y + 35

y = 0
addToggle(contentFrames["Minigames"], "Auto Play Minigames", y, function() return toggles.minigames end, function(v) toggles.minigames = v end); y = y + 35

y = 0
addToggle(contentFrames["Teleport"], "Auto Teleport", y, function() return toggles.teleport end, function(v) toggles.teleport = v end); y = y + 35

y = 0
addToggle(contentFrames["Player"], "Fly", y, function() return toggles.fly end, function(v) toggles.fly = v end); y = y + 35

y = 0
addToggle(contentFrames["Fly"], "Fly Toggle", y, function() return toggles.fly end, function(v) toggles.fly = v end); y = y + 35

y = 0
addToggle(contentFrames["Misc"], "Webhook Notifications", y, function() return toggles.hugeNotify end, function(v) toggles.hugeNotify = v end); y = y + 35

local hunterFrame = contentFrames["Huge Hunter"]
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -8, 0, 150)
statsLabel.Position = UDim2.new(0, 4, 0, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.TextColor3 = Color3.new(1,1,1)
statsLabel.Text = "HUGES: 0\nTITANICS: 0\nHATCHES: 0\nLAST HUGES: None"
statsLabel.TextScaled = false
statsLabel.TextSize = 14
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.TextYAlignment = Enum.TextYAlignment.Top
statsLabel.Parent = hunterFrame

local function updateStats()
    local last = table.concat(stats.lastHuges, ", ")
    if last == "" then last = "None" end
    statsLabel.Text = "HUGES: " .. stats.huge .. "\nTITANICS: " .. stats.titanic .. "\nHATCHES: " .. stats.hatches .. "\nLAST HUGES: " .. last
end

spawn(function()
    while running do
        updateStats()
        wait(1)
    end
end)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0, 150, 0, 30)
resetBtn.Position = UDim2.new(0, 4, 0, 160)
resetBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.Text = "RESET STATS"
resetBtn.TextScaled = true
resetBtn.Font = Enum.Font.GothamBold
resetBtn.BorderSizePixel = 0
resetBtn.Parent = hunterFrame
resetBtn.MouseButton1Click:Connect(function()
    stats.huge = 0; stats.titanic = 0; stats.hatches = 0; stats.lastHuges = {}
    updateStats()
end)
resetBtn.TouchTap:Connect(function()
    stats.huge = 0; stats.titanic = 0; stats.hatches = 0; stats.lastHuges = {}
    updateStats()
end)

local miscFrame = contentFrames["Misc"]
local wbLabel = Instance.new("TextLabel")
wbLabel.Size = UDim2.new(1, -8, 0, 20)
wbLabel.Position = UDim2.new(0, 4, 0, 80)
wbLabel.BackgroundTransparency = 1
wbLabel.TextColor3 = Color3.new(1,1,1)
wbLabel.Text = "Webhook URL"
wbLabel.TextScaled = true
wbLabel.Font = Enum.Font.Gotham
wbLabel.Parent = miscFrame

local wbInput = Instance.new("TextBox")
wbInput.Size = UDim2.new(1, -16, 0, 25)
wbInput.Position = UDim2.new(0, 8, 0, 105)
wbInput.BackgroundColor3 = Color3.fromRGB(30,30,50)
wbInput.TextColor3 = Color3.new(1,1,1)
wbInput.Text = webhookURL
wbInput.PlaceholderText = "https://discord.com/api/webhooks/..."
wbInput.Font = Enum.Font.Gotham
wbInput.TextScaled = false
wbInput.TextSize = 11
wbInput.Parent = miscFrame
wbInput.FocusLost:Connect(function()
    webhookURL = wbInput.Text
    print("[PS99] Webhook set")
end)

local saveWb = Instance.new("TextButton")
saveWb.Size = UDim2.new(0, 80, 0, 25)
saveWb.Position = UDim2.new(0, 4, 0, 140)
saveWb.BackgroundColor3 = Color3.fromRGB(0,150,50)
saveWb.TextColor3 = Color3.new(1,1,1)
saveWb.Text = "SAVE"
saveWb.TextScaled = true
saveWb.Font = Enum.Font.GothamBold
saveWb.BorderSizePixel = 0
saveWb.Parent = miscFrame
saveWb.MouseButton1Click:Connect(function()
    webhookURL = wbInput.Text
    print("[PS99] Webhook saved")
end)
saveWb.TouchTap:Connect(function()
    webhookURL = wbInput.Text
    print("[PS99] Webhook saved")
end)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -30, 0, 5)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.fromRGB(200,200,200)
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.Parent = main
close.MouseButton1Click:Connect(function() scr.Enabled = false end)
close.TouchTap:Connect(function() scr.Enabled = false end)

uis.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.F4 then scr.Enabled = true end
end)

print("[PS99] Ultimate Hub loaded with Anti-AFK and Huge Hunter")