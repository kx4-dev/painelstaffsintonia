-- Colocar este LocalScript em StarterPlayerScripts
local Links = {
    "https://raw.githubusercontent.com/lobinho147/painelstaffsintonia/refs/heads/main/painel.lua",
    "https://raw.githubusercontent.com/lobinho147/painelstaffsintonia/refs/heads/main/Tags%20menu.lua"
}

local KEY_TEXT = "permkey789"
local AUTO_CLOSE_SECONDS = 9

-- Função para executar um script remoto com tratamento de erro
local function executeRemote(url)
    local ok, res = pcall(function()
        local code = game:HttpGet(url)
        local fn = loadstring(code)
        return fn()
    end)
    return ok, res
end

-- Criar GUI
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NotifKeyPainel"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Name = "Container"
frame.Size = UDim2.new(0, 360, 0, 110)
frame.Position = UDim2.new(0.5, -180, 0.2, 0)
frame.BackgroundTransparency = 0
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5,0)
frame.Parent = screenGui

-- Sombra / borda
local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Text = "Notificação"
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(240,240,240)

local label = Instance.new("TextLabel", frame)
label.Name = "Message"
label.Text = "Carregando..."
label.Size = UDim2.new(1, -20, 0, 44)
label.Position = UDim2.new(0, 10, 0, 36)
label.BackgroundTransparency = 1
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.Font = Enum.Font.Gotham
label.TextSize = 15
label.TextColor3 = Color3.fromRGB(220,220,220)
label.TextWrapped = true

local copyBtn = Instance.new("TextButton", frame)
copyBtn.Name = "CopyBtn"
copyBtn.Text = "Copiar key"
copyBtn.Size = UDim2.new(0, 110, 0, 28)
copyBtn.Position = UDim2.new(1, -120, 1, -36)
copyBtn.AnchorPoint = Vector2.new(0,0)
copyBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
copyBtn.TextColor3 = Color3.fromRGB(240,240,240)
copyBtn.Font = Enum.Font.Gotham
copyBtn.TextSize = 14
copyBtn.BorderSizePixel = 0
copyBtn.AutoButtonColor = true
local copyCorner = Instance.new("UICorner", copyBtn)
copyCorner.CornerRadius = UDim.new(0,8)

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Name = "CloseBtn"
closeBtn.Text = "Fechar"
closeBtn.Size = UDim2.new(0, 70, 0, 28)
closeBtn.Position = UDim2.new(1, -200, 1, -36)
closeBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
closeBtn.TextColor3 = Color3.fromRGB(240,240,240)
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0,8)

-- Função para copiar (alguns ambientes de execução permitem setclipboard)
local function tryCopy(text)
    local success, err = pcall(function()
        if setclipboard then
            setclipboard(text)
        else
            -- alternativa para ambientes seguros: Roblox não permite nativamente
            -- então apenas falharemos graciosamente
            error("setclipboard não disponível neste ambiente")
        end
    end)
    return success, err
end

copyBtn.MouseButton1Click:Connect(function()
    local ok, e = tryCopy(KEY_TEXT)
    if ok then
        label.Text = "Key copiada para o clipboard: "..KEY_TEXT
    else
        label.Text = "Não foi possível copiar automaticamente. Key: "..KEY_TEXT
        warn("Falha ao copiar: ", e)
    end
end)

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

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Executar os scripts remotos
local results = {}
for i, url in ipairs(Links) do
    local ok, res = executeRemote(url)
    results[i] = {ok = ok, res = res, url = url}
end

-- Montar mensagem final
local function buildMessage()
    local msg = "Key do painel tags: "..KEY_TEXT.."\n\n"
    for i, r in ipairs(results) do
        if r.ok then
            msg = msg .. ("Script %d: executado com sucesso.\n"):format(i)
        else
            msg = msg .. ("Script %d: falhou. Erro: %s\n"):format(i, tostring(r.res))
        end
    end
    return msg
end

label.Text = buildMessage()

-- Auto fechar depois de X segundos
spawn(function()
    wait(AUTO_CLOSE_SECONDS)
    if screenGui and screenGui.Parent then
        pcall(function() screenGui:Destroy() end)
    end
end)
