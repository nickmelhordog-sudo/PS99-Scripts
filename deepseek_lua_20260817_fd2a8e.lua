-- ============================================================
-- PS99 PINATA RAID HUB v1.0 – Delta Friendly
-- Auto Farm, Auto Pinata, Auto Maze, Auto Upgrade, Anti-AFK
-- ============================================================
local pl = game:GetService("Players").LocalPlayer
local vu = game:GetService("VirtualUser")
local uis = game:GetService("UserInputService")
local cam = workspace.CurrentCamera

-- ===== STATE =====
local state = {
    farm = true,
    pinata = true,
    maze = true,
    upgrade = true,
    afk = true,
}
local stats = { huge = 0, titanic = 0, hatches = 0 }

-- ===== PET SCANNER =====
local lastPets = {}
local function getPets()
    local names = {}
    for _, c in pairs({pl.Backpack, pl:FindFirstChild("Inventory")}) do
        if c then
            for _, p in pairs(c:GetChildren()) do
                if p:IsA("Tool") and p:FindFirstChild("Pet") then
                    table.insert(names, p.Name)
                end
            end
        end
    end
    return names
end

local function scanPets()
    local cur = getPets()
    for _, name in pairs(cur) do
        local found = false
        for _, old in pairs(lastPets) do
            if old == name then found = true; break end
        end
        if not found then
            local low = name:lower()
            if low:find("titanic") then
                stats.titanic = stats.titanic + 1
                print("[🎉] TITANIC: " .. name)
            elseif low:find("huge") then
                stats.huge = stats.huge + 1
                print("[🔥] HUGE: " .. name)
            end
            table.insert(lastPets, name)
            stats.hatches = stats.hatches + 1
        end
    end
end

-- ===== PINATA UI HELPERS =====
local function getEventGUI()
    for _, g in pairs(pl.PlayerGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled and g.Visible then
            local n = g.Name:lower()
            if n:find("pinata") or n:find("raid") or n:find("event") or n:find("maze") then
                return g
            end
        end
    end
    return nil
end

local function findButton(gui, pattern)
    if not gui then return nil end
    for _, b in pairs(gui:GetDescendants()) do
        if b:IsA("TextButton") or b:IsA("ImageButton") then
            local t = (b.Text or b.Name or ""):lower()
            if t:find(pattern) then
                return b
            end
        end
    end
    return nil
end

local function click(pattern)
    local gui = getEventGUI()
    if not gui then return false end
    local btn = findButton(gui, pattern)
    if btn then
        pcall(btn.Click, btn)
        return true
    end
    return false
end

-- ===== MAIN LOOP =====
spawn(function()
    lastPets = getPets()
    while true do
        -- Anti-AFK
        if state.afk then
            pcall(function()
                local vp = cam.ViewportSize
                vu:CaptureController()
                vu:ClickButtonAt(Vector2.new(vp.X/2 + math.random(-10,10), vp.Y/2 + math.random(-10,10)))
            end)
        end

        local gui = getEventGUI()
        if gui then
            -- Auto Pinata (click on pinata, break, etc.)
            if state.pinata then
                click("pinata") or click("break") or click("hit") or click("smash")
            end

            -- Auto Maze (move through maze)
            if state.maze then
                click("maze") or click("move") or click("next")
                -- Also click center to walk forward
                pcall(function()
                    local vp = cam.ViewportSize
                    vu:CaptureController()
                    vu:ClickButtonAt(Vector2.new(vp.X/2, vp.Y*0.6))
                end)
            end

            -- Auto Upgrade
            if state.upgrade then
                click("upgrade") or click("boost") or click("luck")
            end
        end

        -- Auto Farm (click center to break/collect if no event GUI)
        if state.farm and not gui then
            pcall(function()
                local vp = cam.ViewportSize
                vu:CaptureController()
                vu:ClickButtonAt(Vector2.new(vp.X/2, vp.Y * 0.7))
            end)
        end

        scanPets()
        wait(0.2)
    end
end)

-- ============================================================
-- UI – Clean, Modern, Tabbed (Pinata Theme)
-- ============================================================
local scr = Instance.new("ScreenGui")
scr.Name = "PinataHub"
scr.ResetOnSpawn = false
scr.Parent = pl.PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 300)
main.Position = UDim2.new(1, -320, 0, 40)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255, 200, 0)  -- Pinata gold
main.Parent = scr

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
title.TextColor3 = Color3.new(0,0,0)
title.Text = "🎉 PINATA RAID HUB"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = main

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.Position = UDim2.new(0, 0, 0, 30)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main

local tabs = {"FARM", "PINATA", "HUNTER"}
local tabBtns = {}
local contentFrames = {}

local function switchTab(name)
    for i, btn in pairs(tabBtns) do
        local isActive = (tabs[i] == name)
        btn.BackgroundColor3 = isActive and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(40, 40, 60)
        btn.TextColor3 = isActive and Color3.new(0,0,0) or Color3.new(1,1,1)
    end
    for fname, frame in pairs(contentFrames) do
        frame.Visible = (fname == name)
    end
end

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 28)
    btn.Position = UDim2.new(0, (i-1)*100, 0, 0)
    btn.BackgroundColor3 = (i==1) and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = (i==1) and Color3.new(0,0,0) or Color3.new(1,1,1)
    btn.Text = name
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    table.insert(tabBtns, btn)
end

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -10, 1, -70)
contentArea.Position = UDim2.new(0, 5, 0, 65)
contentArea.BackgroundTransparency = 1
contentArea.Parent = main

for _, name in ipairs(tabs) do
    local cf = Instance.new("ScrollingFrame")
    cf.Size = UDim2.new(1, 0, 1, 0)
    cf.BackgroundTransparency = 1
    cf.BorderSizePixel = 0
    cf.CanvasSize = UDim2.new(0, 0, 0, 200)
    cf.ScrollBarThickness = 2
    cf.Visible = (name == "FARM")
    cf.Name = name
    cf.Parent = contentArea
    contentFrames[name] = cf
end

-- ===== ADD TOGGLE HELPER =====
local function addToggle(frame, label, y, getter, setter)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -8, 0, 30)
    f.Position = UDim2.new(0, 4, 0, y)
    f.BackgroundTransparency = 1
    f.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 180, 0, 30)
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
    btn.Position = UDim2.new(0, 210, 0, 3)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(50, 50, 70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = getter() and "ON" or "OFF"
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        btn.BackgroundColor3 = getter() and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(50, 50, 70)
        btn.Text = getter() and "ON" or "OFF"
    end)
    return f
end

-- POPULATE FARM TAB
local y = 0
addToggle(contentFrames["FARM"], "Auto Farm", y, function() return state.farm end, function(v) state.farm = v end)
y = y + 35
addToggle(contentFrames["FARM"], "Auto Pinata", y, function() return state.pinata end, function(v) state.pinata = v end)
y = y + 35
addToggle(contentFrames["FARM"], "Auto Maze", y, function() return state.maze end, function(v) state.maze = v end)
y = y + 35
addToggle(contentFrames["FARM"], "Auto Upgrade", y, function() return state.upgrade end, function(v) state.upgrade = v end)
y = y + 35
addToggle(contentFrames["FARM"], "Anti-AFK", y, function() return state.afk end, function(v) state.afk = v end)
contentFrames["FARM"].CanvasSize = UDim2.new(0, 0, 0, y + 20)

-- PINATA TAB – info + instructions
local pinataFrame = contentFrames["PINATA"]
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -8, 0, 80)
info.Position = UDim2.new(0, 4, 0, 0)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.new(1,1,1)
info.Text = "🔹 Auto Pinata: clicks pinata buttons\n🔹 Auto Maze: moves through maze\n🔹 Auto Upgrade: spends event currency\n\nEnable/disable above in FARM tab."
info.TextScaled = false
info.TextSize = 14
info.Font = Enum.Font.Gotham
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = pinataFrame
pinataFrame.CanvasSize = UDim2.new(0, 0, 0, 120)

-- HUNTER TAB – stats
local hunterFrame = contentFrames["HUNTER"]
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -8, 0, 120)
statsLabel.Position = UDim2.new(0, 4, 0, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.TextColor3 = Color3.new(1,1,1)
statsLabel.Text = "HUGES: 0\nTITANICS: 0\nHATCHES: 0\nNEWEST: None"
statsLabel.TextScaled = false
statsLabel.TextSize = 15
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.TextYAlignment = Enum.TextYAlignment.Top
statsLabel.Parent = hunterFrame

local function updateStats()
    local last = ""
    if #lastPets > 0 then last = lastPets[#lastPets] else last = "None" end
    statsLabel.Text = "HUGES: " .. stats.huge .. "\nTITANICS: " .. stats.titanic .. "\nHATCHES: " .. stats.hatches .. "\nNEWEST: " .. last
end

spawn(function()
    while true do
        updateStats()
        wait(1)
    end
end)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0, 120, 0, 30)
resetBtn.Position = UDim2.new(0, 4, 0, 130)
resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.Text = "RESET STATS"
resetBtn.TextScaled = true
resetBtn.Font = Enum.Font.GothamBold
resetBtn.BorderSizePixel = 0
resetBtn.Parent = hunterFrame
resetBtn.MouseButton1Click:Connect(function()
    stats.huge = 0; stats.titanic = 0; stats.hatches = 0; lastPets = {}
    updateStats()
end)
hunterFrame.CanvasSize = UDim2.new(0, 0, 0, 180)

-- Close button
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -30, 0, 5)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.fromRGB(200, 200, 200)
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.Parent = main
close.MouseButton1Click:Connect(function() scr.Enabled = false end)

uis.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.F4 then scr.Enabled = true end
end)

print("[PINATA HUB] Loaded – F4 to reopen GUI")