-- Tiki Menu Loader Simplificado
local Links = {
    "https://raw.githubusercontent.com/kx4-dev/painelstaffsintonia/refs/heads/main/Tags%20menu.lua",
    "https://raw.githubusercontent.com/kx4-dev/painelstaffsintonia/refs/heads/main/painel.lua",
}

local KEY_TEXT = "permkey789"
local AUTO_CLOSE_SECONDS = 60

-- Função para executar scripts remotos
local function executeRemote(url)
    local ok, res = pcall(function()
        local code = game:HttpGet(url, true)
        if not code or #code < 10 then
            error("Falha ao carregar: " .. url)
        end
        return loadstring(code)()
    end)
    return ok, res
end

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NotifKeyPainel"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Name = "Container"
frame.Size = UDim2.new(0, 360, 0, 110)
frame.Position = UDim2.new(0.5, -180, 0.2, 0)
frame.BackgroundTransparency = 0.05
frame.BackgroundColor3 = Color3.fromRGB(255, 222, 89)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local uistroke = Instance.new("UIStroke", frame)
uistroke.Color = Color3.fromRGB(200, 180, 0)
uistroke.Thickness = 2

-- Título
local title = Instance.new("TextLabel", frame)
title.Text = "Tiki Menu"
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0, 0, 0)

-- Mensagem
local label = Instance.new("TextLabel", frame)
label.Name = "Message"
label.Text = "Carregando scripts remotos..."
label.Size = UDim2.new(1, -20, 0, 44)
label.Position = UDim2.new(0, 10, 0, 36)
label.BackgroundTransparency = 1
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.Font = Enum.Font.Gotham
label.TextSize = 15
label.TextColor3 = Color3.fromRGB(0, 0, 0)
label.TextWrapped = true

-- Botão copiar key
local copyBtn = Instance.new("TextButton", frame)
copyBtn.Name = "CopyBtn"
copyBtn.Text = "Copiar key"
copyBtn.Size = UDim2.new(0, 110, 0, 28)
copyBtn.Position = UDim2.new(1, -120, 1, -36)
copyBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
copyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
copyBtn.Font = Enum.Font.Gotham
copyBtn.TextSize = 14
copyBtn.BorderSizePixel = 0
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 8)

-- Botão fechar
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Name = "CloseBtn"
closeBtn.Text = "Fechar"
closeBtn.Size = UDim2.new(0, 70, 0, 28)
closeBtn.Position = UDim2.new(1, -200, 1, -36)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
closeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Função copiar key
copyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then setclipboard(KEY_TEXT) end
    end)
    label.Text = "Key copiada: "..KEY_TEXT
end)

-- Fechar GUI
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Tornar frame arrastável
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Executar scripts remotos automaticamente
for _, url in pairs(Links) do
    label.Text = "Carregando: "..url
    local ok, res = executeRemote(url)
    if ok then
        label.Text = "Carregado: "..url
    else
        label.Text = "Falha ao carregar: "..url
        warn(res)
    end
end

-- Fechar automaticamente após X segundos
task.delay(AUTO_CLOSE_SECONDS, function()
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
end)
