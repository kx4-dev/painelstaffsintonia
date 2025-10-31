-- Tiki Menu (sem sistema de key) - Versão: lobinho_nix 💛
-- Funcionalidades: tema amarelo, arrastável, minimizar (M), botão 💻 mobile, Aba Config (Aimbot FOV, círculo, ESP linhas), lista staff demo

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

-- Config (salva só em runtime)
local Config = {
    ThemeColor = Color3.fromRGB(255,222,89), -- amarelo
    AccentColor = Color3.fromRGB(200,180,0),
    AimbotFOV = 100,
    ShowFOVCircle = true,
    AimbotTarget = "Head", -- "Head" or "Torso"
    ESPEnabled = true,
    ESPLines = false,
    ESPColor = Color3.fromRGB(0,170,255),
    FlySpeed = 50,
    CameraFOV = 70,
    ShowNotifications = true
}

-- Util: notify (in-GUI small)
local function notify(text, timeSec)
    if not Config.ShowNotifications then return end
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "TikiNotify"
    gui.ResetOnSpawn = false
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 300, 0, 36)
    frame.Position = UDim2.new(0.5, -150, 0.12, 0)
    frame.BackgroundColor3 = Config.ThemeColor
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5, 0)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0,8,0,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(0,0,0)
    label.TextSize = 14
    task.delay(timeSec or 2, function() if gui then gui:Destroy() end end)
end

-- Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TikiMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 420)
mainFrame.Position = UDim2.new(0.5, -300, 0.45, -210)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Config.ThemeColor
mainFrame.BorderSizePixel = 0
local mcorn = Instance.new("UICorner", mainFrame)
mcorn.CornerRadius = UDim.new(0, 14)
local mstroke = Instance.new("UIStroke", mainFrame)
mstroke.Color = Config.AccentColor
mstroke.Thickness = 2

-- Header
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 44)
header.Position = UDim2.new(0,0,0,0)
header.BackgroundTransparency = 1
local title = Instance.new("TextLabel", header)
title.Text = "Tiki Menu - Versão lobinho_nix 💛"
title.Position = UDim2.new(0, 12, 0, 8)
title.Size = UDim2.new(1, -80, 0, 28)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(0,0,0)

-- Minimize button (top-right)
local btnMin = Instance.new("TextButton", header)
btnMin.Text = "-"
btnMin.Size = UDim2.new(0, 34, 0, 28)
btnMin.Position = UDim2.new(1, -46, 0, 8)
btnMin.BackgroundColor3 = Config.AccentColor
btnMin.TextColor3 = Color3.fromRGB(0,0,0)
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 18
btnMin.BorderSizePixel = 0
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,6)

-- Close button (optional)
local btnClose = Instance.new("TextButton", header)
btnClose.Text = "✕"
btnClose.Size = UDim2.new(0, 34, 0, 28)
btnClose.Position = UDim2.new(1, -88, 0, 8)
btnClose.BackgroundColor3 = Config.AccentColor
btnClose.TextColor3 = Color3.fromRGB(0,0,0)
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 16
btnClose.BorderSizePixel = 0
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,6)

-- Sidebar (tabs)
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 150, 1, -44)
sidebar.Position = UDim2.new(0, 0, 0, 44)
sidebar.BackgroundTransparency = 1

local contentArea = Instance.new("Frame", mainFrame)
contentArea.Size = UDim2.new(1, -150, 1, -44)
contentArea.Position = UDim2.new(0, 150, 0, 44)
contentArea.BackgroundTransparency = 1

local tabs = {"Aimbot","ESP","Visual","Auto Farms","Config","Créditos"}
local currentTab = nil
local contentFrames = {}

for i, name in ipairs(tabs) do
    -- create button
    local b = Instance.new("TextButton", sidebar)
    b.Text = name
    b.Size = UDim2.new(1, -12, 0, 36)
    b.Position = UDim2.new(0, 6, 0, 8 + (i-1)*42)
    b.BackgroundColor3 = Color3.fromRGB(255,240,150)
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    b.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    -- content frame
    local cf = Instance.new("ScrollingFrame", contentArea)
    cf.Size = UDim2.new(1, -20, 1, -20)
    cf.Position = UDim2.new(0, 10, 0, 10)
    cf.BackgroundTransparency = 1
    cf.Visible = false
    cf.ScrollBarThickness = 6
    contentFrames[name] = cf
    b.MouseButton1Click:Connect(function()
        if currentTab then contentFrames[currentTab].Visible = false end
        contentFrames[name].Visible = true
        currentTab = name
    end)
end

-- Helper to create UI elements inside a scrolling frame (vertical stacking)
local function addLabel(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -20, 0, 24)
    lbl.Position = UDim2.new(0, 10, 0, parent.CanvasSize.Y.Offset)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(0,0,0)
    lbl.TextSize = 14
    parent.CanvasSize = UDim2.new(0,0,0,parent.CanvasSize.Y.Offset + 30)
    return lbl
end

local function addToggle(parent, labelText, initial, callback)
    local y = parent.CanvasSize.Y.Offset
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(0.7, -10, 0, 28)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(0,0,0)
    lbl.TextSize = 14

    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.25, -10, 0, 28)
    btn.Position = UDim2.new(0.75, 0, 0, y)
    btn.BackgroundColor3 = initial and Config.AccentColor or Color3.fromRGB(220,220,220)
    btn.Text = initial and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    local state = initial
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Config.AccentColor or Color3.fromRGB(220,220,220)
        btn.Text = state and "ON" or "OFF"
        pcall(callback, state)
    end)
    parent.CanvasSize = UDim2.new(0,0,0,parent.CanvasSize.Y.Offset + 36)
    return btn
end

local function addSlider(parent, labelText, min, max, initial, callback)
    local y = parent.CanvasSize.Y.Offset
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.Text = labelText .. " : " .. tostring(initial)
    lbl.TextColor3 = Color3.fromRGB(0,0,0)
    lbl.TextSize = 14

    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1, -20, 0, 24)
    box.Position = UDim2.new(0, 10, 0, y + 22)
    box.BackgroundColor3 = Color3.fromRGB(255,240,150)
    box.Text = tostring(initial)
    box.Font = Enum.Font.Gotham
    box.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
    box.ClearTextOnFocus = false
    box.FocusLost:Connect(function(enter)
        local v = tonumber(box.Text)
        if v then
            v = math.clamp(v, min, max)
            box.Text = tostring(v)
            lbl.Text = labelText .. " : " .. tostring(v)
            pcall(callback, v)
        else
            box.Text = tostring(initial)
        end
    end)
    parent.CanvasSize = UDim2.new(0,0,0,parent.CanvasSize.Y.Offset + 56)
    return box
end

-- Fill Aimbot tab
do
    local cf = contentFrames["Aimbot"]
    cf.CanvasSize = UDim2.new(0,0,0,0)
    addLabel(cf, "Aimbot Configurações")
    addSlider(cf, "FOV do Aimbot", 20, 1000, Config.AimbotFOV, function(v) Config.AimbotFOV = v end)
    addToggle(cf, "Mostrar Círculo do FOV", Config.ShowFOVCircle, function(state) Config.ShowFOVCircle = state end)
    -- Target mode toggle (Head/Torso)
    local ybtn = cf.CanvasSize.Y.Offset
    local lbl = Instance.new("TextLabel", cf)
    lbl.Size = UDim2.new(0.6, -10, 0, 28)
    lbl.Position = UDim2.new(0, 10, 0, ybtn)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.Text = "Modo de Mira"
    lbl.TextColor3 = Color3.fromRGB(0,0,0)
    lbl.TextSize = 14

    local headBtn = Instance.new("TextButton", cf)
    headBtn.Text = "Head"
    headBtn.Size = UDim2.new(0.18, -6, 0, 28)
    headBtn.Position = UDim2.new(0.62, 6, 0, ybtn)
    headBtn.BackgroundColor3 = Color3.fromRGB(200,180,0)
    headBtn.Font = Enum.Font.GothamBold
    headBtn.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", headBtn).CornerRadius = UDim.new(0,6)

    local torsoBtn = Instance.new("TextButton", cf)
    torsoBtn.Text = "Torso"
    torsoBtn.Size = UDim2.new(0.18, -6, 0, 28)
    torsoBtn.Position = UDim2.new(0.8, 6, 0, ybtn)
    torsoBtn.BackgroundColor3 = Color3.fromRGB(255,240,150)
    torsoBtn.Font = Enum.Font.GothamBold
    torsoBtn.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", torsoBtn).CornerRadius = UDim.new(0,6)

    headBtn.MouseButton1Click:Connect(function()
        Config.AimbotTarget = "Head"
        headBtn.BackgroundColor3 = Config.AccentColor
        torsoBtn.BackgroundColor3 = Color3.fromRGB(255,240,150)
    end)
    torsoBtn.MouseButton1Click:Connect(function()
        Config.AimbotTarget = "Torso"
        torsoBtn.BackgroundColor3 = Config.AccentColor
        headBtn.BackgroundColor3 = Color3.fromRGB(255,240,150)
    end)
    cf.CanvasSize = UDim2.new(0,0,0,cf.CanvasSize.Y.Offset + 40)
end

-- Fill ESP tab
do
    local cf = contentFrames["ESP"]
    cf.CanvasSize = UDim2.new(0,0,0,0)
    addLabel(cf, "ESP Configurações")
    addToggle(cf, "Ativar ESP", Config.ESPEnabled, function(s) Config.ESPEnabled = s end)
    addToggle(cf, "Mostrar Linhas (to localplayer)", Config.ESPLines, function(s) Config.ESPLines = s end)
    addSlider(cf, "Cor ESP - component R (0..255)", 0, 255, 0, function(v)
        Config.ESPColor = Color3.fromRGB(v, Config.ESPColor.G * 255, Config.ESPColor.B * 255)
    end)
    addSlider(cf, "Cor ESP - component G (0..255)", 0, 255, 170, function(v)
        Config.ESPColor = Color3.fromRGB(Config.ESPColor.R * 255, v, Config.ESPColor.B * 255)
    end)
    addSlider(cf, "Cor ESP - component B (0..255)", 0, 255, 255, function(v)
        Config.ESPColor = Color3.fromRGB(Config.ESPColor.R * 255, Config.ESPColor.G * 255, v)
    end)
end

-- Fill Visual tab
do
    local cf = contentFrames["Visual"]
    cf.CanvasSize = UDim2.new(0,0,0,0)
    addLabel(cf, "Visual")
    addSlider(cf, "FOV da Câmera", 50, 120, Config.CameraFOV, function(v)
        Config.CameraFOV = v
        pcall(function() workspace.CurrentCamera.FieldOfView = v end)
    end)
    addSlider(cf, "Velocidade do Fly", 10, 300, Config.FlySpeed, function(v)
        Config.FlySpeed = v
    end)
end

-- Fill Config tab
do
    local cf = contentFrames["Config"]
    cf.CanvasSize = UDim2.new(0,0,0,0)
    addLabel(cf, "Configurações Gerais")
    addToggle(cf, "Mostrar notificações", Config.ShowNotifications, function(s) Config.ShowNotifications = s end)
    addToggle(cf, "Mostrar Círculo do FOV (global)", Config.ShowFOVCircle, function(s) Config.ShowFOVCircle = s end)
    addLabel(cf, "Resetar para padrão")
    local resetBtn = Instance.new("TextButton", cf)
    resetBtn.Text = "Resetar"
    resetBtn.Size = UDim2.new(0.3, 0, 0, 28)
    resetBtn.Position = UDim2.new(0.35, 0, 0, cf.CanvasSize.Y.Offset)
    resetBtn.BackgroundColor3 = Config.AccentColor
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,6)
    resetBtn.MouseButton1Click:Connect(function()
        -- minimal reset
        Config.AimbotFOV = 100
        Config.ShowFOVCircle = true
        Config.ESPEnabled = true
        Config.ESPLines = false
        Config.FlySpeed = 50
        Config.CameraFOV = 70
        notify("Config resetadas", 2)
    end)
    cf.CanvasSize = UDim2.new(0,0,0,cf.CanvasSize.Y.Offset + 40)
end

-- Fill Credits tab
do
    local cf = contentFrames["Créditos"]
    cf.CanvasSize = UDim2.new(0,0,0,0)
    addLabel(cf, "Créditos")
    addLabel(cf, "Tiki Menu - Versão lobinho_nix 💛")
    addLabel(cf, "GUI tema amarelo: por você (Alexa)")
end

-- Set default tab
contentFrames["Aimbot"].Visible = true
currentTab = "Aimbot"

-- STAFF list (simple demo)
do
    local sf = Instance.new("Frame", contentFrames["Créditos"]) -- place in credits for demo
    sf.Size = UDim2.new(1, -20, 0, 120)
    sf.Position = UDim2.new(0, 10, 0, contentFrames["Créditos"].CanvasSize.Y.Offset)
    sf.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", sf)
    lbl.Size = UDim2.new(1,0,0,20)
    lbl.Position = UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Staff (demo):"
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = Color3.fromRGB(0,0,0)
    -- we won't implement full staff detection here; show players with keywords
    local list = Instance.new("UIListLayout", sf)
    list.Padding = UDim.new(0,4)
    sf.CanvasSize = UDim2.new(0,0,0,0)
    local function refreshStaffList()
        -- cleanup old labels
        for _,c in ipairs(sf:GetChildren()) do
            if c:IsA("TextLabel") and c ~= lbl then c:Destroy() end
        end
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Name:lower():find("staff") or p.Name:lower():find("dev") then
                local l = Instance.new("TextLabel", sf)
                l.Size = UDim2.new(1, 0, 0, 22)
                l.BackgroundColor3 = Color3.fromRGB(255,240,150)
                l.Text = p.Name
                l.Font = Enum.Font.Gotham
                l.TextColor3 = Color3.fromRGB(0,0,0)
                Instance.new("UICorner", l).CornerRadius = UDim.new(0,6)
            end
        end
    end
    Players.PlayerAdded:Connect(refreshStaffList)
    Players.PlayerRemoving:Connect(refreshStaffList)
    refreshStaffList()
end

-- Dragging mainFrame
do
    local dragging = false
    local dragStart
    local startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging and dragStart then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

-- Mobile floating button (emoji 💻)
local floatingBtnGui = Instance.new("ScreenGui", PlayerGui)
floatingBtnGui.Name = "TikiFloatBtn"
floatingBtnGui.ResetOnSpawn = false
local floatBtn = Instance.new("TextButton", floatingBtnGui)
floatBtn.Size = UDim2.new(0,56,0,56)
floatBtn.Position = UDim2.new(0.9, 0, 0.82, 0)
floatBtn.Text = "💻"
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 28
floatBtn.TextColor3 = Color3.fromRGB(0,0,0)
floatBtn.BackgroundColor3 = Config.ThemeColor
floatBtn.BorderSizePixel = 0
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1,0)

-- Toggle visibility via floating button
floatBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Minimize / Restore with M key (PC)
local minimized = false
local function toggleMinimize()
    minimized = not minimized
    mainFrame.Visible = not minimized
    floatBtn.Visible = minimized -- keep float visible when minimized for mobile usage too
    if minimized then
        notify("Minimizado (M para abrir)", 2)
    else
        notify("Tiki Menu restaurado", 2)
    end
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        toggleMinimize()
    end
end)
btnMin.MouseButton1Click:Connect(toggleMinimize)
btnClose.MouseButton1Click:Connect(function() screenGui:Destroy(); floatingBtnGui:Destroy() end)

-- Simple Aimbot visual behavior (no shooting) - rotates camera toward target while mouse held
local Camera = workspace.CurrentCamera
local aimbotEnabled = false
local mouseDown = false
local aimbotLock = nil
-- FOV visual circle
local fovGui = Instance.new("ScreenGui", PlayerGui)
fovGui.Name = "TikiFOVGui"
fovGui.Enabled = true
local fovFrame = Instance.new("Frame", fovGui)
fovFrame.AnchorPoint = Vector2.new(0.5,0.5)
fovFrame.Size = UDim2.new(0, 0, 0, 0)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.BackgroundTransparency = 0.7
fovFrame.BorderSizePixel = 2
fovFrame.BorderColor3 = Config.AccentColor
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1,0)
fovFrame.Visible = Config.ShowFOVCircle

local function updateFOVVisual()
    local s = math.clamp(Config.AimbotFOV, 10, 1000)
    fovFrame.Size = UDim2.new(0, s*2, 0, s*2)
    fovFrame.Position = UDim2.new(0.5, -s, 0.5, -s)
    fovFrame.Visible = Config.ShowFOVCircle
end
updateFOVVisual()

-- Utility: get nearest player in screen within FOV
local function getNearestInFOV()
    local mousePos = UserInputService:GetMouseLocation()
    local shortest, best = math.huge, nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = (Config.AimbotTarget == "Head" and p.Character:FindFirstChild("Head")) or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local pos, vis = Camera:WorldToViewportPoint(targetPart.Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if dist < shortest and dist <= Config.AimbotFOV then
                        shortest = dist
                        best = p
                    end
                end
            end
        end
    end
    return best
end

-- Mouse down tracking for aimbot (basic; real aimbot would integrate raycast/fire)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        mouseDown = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        mouseDown = false
        aimbotLock = nil
    end
end)

RunService.RenderStepped:Connect(function()
    -- update FOV visual size in runtime
    updateFOVVisual()
    -- Aimbot lock behavior when mouse held (camera faces target)
    if mouseDown then
        if not aimbotLock or not aimbotLock.Character then
            aimbotLock = getNearestInFOV()
        end
        if aimbotLock and aimbotLock.Character then
            local targetPart = (Config.AimbotTarget == "Head" and aimbotLock.Character:FindFirstChild("Head")) or aimbotLock.Character:FindFirstChild("Torso") or aimbotLock.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local camPos = Camera.CFrame.Position
                local lookAt = CFrame.new(camPos, targetPart.Position)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
        end
    end
    -- simple ESP drawing (Billboard + optional line)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local tagName = "TikiESP_" .. p.UserId
            local existing = p.Character.Head:FindFirstChild(tagName)
            if Config.ESPEnabled then
                if not existing then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = tagName
                    billboard.Adornee = p.Character.Head
                    billboard.Size = UDim2.new(0, 140, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 2.4, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = p.Character.Head
                    local txt = Instance.new("TextLabel", billboard)
                    txt.Size = UDim2.new(1,0,1,0)
                    txt.BackgroundTransparency = 1
                    txt.Font = Enum.Font.GothamBold
                    txt.TextColor3 = Config.ESPColor
                    txt.TextSize = 14
                    txt.Text = p.Name
                    txt.TextStrokeTransparency = 0
                    -- line (optional)
                    if Config.ESPLines then
                        local drawingOk, line = pcall(function()
                            return Drawing and Drawing.new and Drawing.new("Line")
                        end)
                        -- Drawing API may not be available in all executors; skip gracefully
                        -- (we won't implement full Drawing fallback here)
                    end
                else
                    -- update color / text
                    local txt = existing:FindFirstChildOfClass("TextLabel")
                    if txt then
                        txt.TextColor3 = Config.ESPColor
                        txt.Text = p.Name
                    end
                end
            else
                if existing then existing:Destroy() end
            end
        end
    end
end)

-- Final notify
notify("Bem-vindo ao Tiki Menu 💛", 3)

-- Done
--- key !  : permkey789
