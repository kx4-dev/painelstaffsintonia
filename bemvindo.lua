local Links = {
    "https://raw.githubusercontent.com/kx4-dev/painelstaffsintonia/refs/heads/main/Tags%20menu.lua",
    "https://raw.githubusercontent.com/kx4-dev/painelstaffsintonia/refs/heads/main/painel.lua", -- Corrigido: aspas de fechamento
    "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
}

local KEY_TEXT = "permkey789"
local AUTO_CLOSE_SECONDS = 9

-- Função para executar um script remoto com tratamento de erro
local function executeRemote(url)
    local ok, res = pcall(function()
        local code = game:HttpGet(url, true) -- Adicionado parâmetro para timeout (opcional)
        if not code or #code < 10 then -- Verifica se a busca falhou ou o código é muito curto/vazio
            error("Conteúdo vazio ou falha na busca da URL: " .. url)
        end
        local fn = loadstring(code)
        if not fn then
            error("Falha ao carregar string (loadstring) da URL: " .. url)
        end
        return fn()
    end)
    return ok, res
end

-- Serviços e referências
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- Criar GUI (mantido como está, mas com um toque visual extra)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NotifKeyPainel"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Name = "Container"
frame.Size = UDim2.new(0, 360, 0, 110)
frame.Position = UDim2.new(0.5, -180, 0.2, 0)
frame.BackgroundTransparency = 0.05 -- Transparência sutil
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5,0)
frame.Parent = screenGui

-- Sombra / borda
local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 10)

-- Adicionar um Stroke para destacar a borda
local uistroke = Instance.new("UIStroke", frame)
uistroke.Color = Color3.fromRGB(50,50,50)
uistroke.Thickness = 1
uistroke.Transparency = 0

-- Título (restante da GUI mantido como está)
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
label.Text = "Carregando scripts remotos..." -- Mensagem inicial atualizada
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

-- Função para copiar (mantida)
local function tryCopy(text)
    local success, err = pcall(function()
        if setclipboard then
            setclipboard(text)
        else
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

-- Tornar frame arrastável (lógica mantida)
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
        -- Usar InputEnded para garantir que dragging seja falso
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

-- Executar os scripts remotos (mantido síncrono para replicar a ordem original, mas com aviso
