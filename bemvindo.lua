-- LobosHub Remote Panels GUI
-- Criado para executar scripts e gerar keys do Tiki Menu

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- =================================
-- CONFIGURAÇÃO DAS KEYS
-- =================================
local keys = {}
local function gerarKey(tipo)
    local key = tipo .. "_" .. tostring(math.random(1000,9999)) .. tostring(os.time())
    keys[key] = {tipo=tipo, gerada=LocalPlayer.Name}
    return key
end

-- =================================
-- FUNÇÕES AUXILIARES
-- =================================
local function try_notify(title,text)
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        if StarterGui and StarterGui.SetCore then
            StarterGui:SetCore("SendNotification",{
                Title=title or "Script",
                Text=text or "",
                Duration=5
            })
        end
    end)
end

local function try_set_clipboard(text)
    local handlers = {
        function(t) if setclipboard then setclipboard(t); return true end end,
        function(t) if set_clipboard then set_clipboard(t); return true end end,
        function(t) if syn and syn.set_clipboard then syn.set_clipboard(t); return true end end,
        function(t) if PROT and PROT.SetClipboard then PROT.SetClipboard(t); return true end end,
    }
    for _,h in ipairs(handlers) do
        local ok, res = pcall(h,text)
        if ok and res then return true end
    end
    return false
end

local urls = {
    ["Tags Menu"]="https://raw.githubusercontent.com/lobinho147/painelstaffsintonia/refs/heads/main/Tags%20menu.lua",
    ["Painel"]="https://raw.githubusercontent.com/lobinho147/painelstaffsintonia/refs/heads/main/painel.lua"
}

local function executarScript(url)
    local ok, err = pcall(function()
        local body = game:HttpGet(url)
        local f = loadstring(body)
        f()
    end)
    if ok then
        try_notify("Executado","Script rodado com sucesso!")
    else
        try_notify("Erro",tostring(err))
    end
end

-- =================================
-- CRIAÇÃO DA GUI
-- =================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "LobosHubRemoteGUI"

local MainFrame = Instance.new("Frame",ScreenGui)
MainFrame.Size = UDim2.new(0,400,0,350)
MainFrame.Position = UDim2.new(0.5,-200,0.5,-175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.Active = true
MainFrame.Draggable = true
local UICorner = Instance.new("UICorner",MainFrame)
UICorner.CornerRadius = UDim.new(0,12)

-- Título
local Title = Instance.new("TextLabel",MainFrame)
Title.Size = UDim2.new(1,0,0,30)
Title.Position = UDim2.new(0,0,0,0)
Title.Text = "LobosHub Remote Panels"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

-- Container para abas
local Pages = Instance.new("Folder",MainFrame)
Pages.Name = "Pages"

-- Função para criar páginas
local function criarPagina(nome)
    local frame = Instance.new("Frame",Pages)
    frame.Name = nome
    frame.Size = UDim2.new(1,0,1,-30)
    frame.Position = UDim2.new(0,0,0,30)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    return frame
end

-- Criando as 5 abas
local infoPage = criarPagina("Informacao")
local scriptsPage = criarPagina("Scripts")
local byPage = criarPagina("ByScript")
local keysPage = criarPagina("Keys")
local gerarKeysPage = criarPagina("GerarKeys")

-- Mostrar primeira página
infoPage.Visible = true

-- Botões de navegação
local nomesAbas = {"Informação","Scripts","By Script","Keys","Gerar Keys"}
for i,nome in ipairs(nomesAbas) do
    local btn = Instance.new("TextButton",MainFrame)
    btn.Size = UDim2.new(0,75,0,30)
    btn.Position = UDim2.new(0,(i-1)*80,0,30)
    btn.Text = nome
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.MouseButton1Click:Connect(function()
        for _,page in pairs(Pages:GetChildren()) do page.Visible = false end
        if i==1 then infoPage.Visible=true
        elseif i==2 then scriptsPage.Visible=true
        elseif i==3 then byPage.Visible=true
        elseif i==4 then keysPage.Visible=true
        elseif i==5 then gerarKeysPage.Visible=true end
    end)
end

-- =================================
-- Conteúdo das páginas
-- =================================

-- Informação
local infoLabel = Instance.new("TextLabel",infoPage)
infoLabel.Size = UDim2.new(1,0,1,0)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(255,255,255)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 14
infoLabel.TextWrapped = true
infoLabel.Text = "LobosHub Remote Panels GUI\nUse as abas para executar scripts, gerar keys e visualizar informações.\nModificado apenas nome e key conforme solicitado."

-- Scripts
local y=10
for name,url in pairs(urls) do
    local btn = Instance.new("TextButton",scriptsPage)
    btn.Size = UDim2.new(0,150,0,30)
    btn.Position = UDim2.new(0,10,0,y)
    btn.Text = "Executar "..name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.MouseButton1Click:Connect(function()
        executarScript(url)
    end)
    y=y+40
end

-- By Script
local byLabel = Instance.new("TextLabel",byPage)
byLabel.Size = UDim2.new(1,0,1,0)
byLabel.BackgroundTransparency = 1
byLabel.TextColor3 = Color3.fromRGB(255,255,255)
byLabel.Font = Enum.Font.Gotham
byLabel.TextSize = 14
byLabel.TextWrapped = true
byLabel.Text = "Scripts criados por: lobinho_nix"

-- Keys
local keyLabel = Instance.new("TextLabel",keysPage)
keyLabel.Size = UDim2.new(1,0,1,0)
keyLabel.BackgroundTransparency = 1
keyLabel.TextColor3 = Color3.fromRGB(255,255,255)
keyLabel.Font = Enum.Font.Gotham
keyLabel.TextSize = 14
keyLabel.TextWrapped = true
keyLabel.Text = "Key atual: permkey789"

-- Gerar Keys
local staffBtn = Instance.new("TextButton",gerarKeysPage)
staffBtn.Size = UDim2.new(0,150,0,30)
staffBtn.Position = UDim2.new(0,10,0,10)
staffBtn.Text = "Gerar Key Staff"
staffBtn.Font = Enum.Font.GothamBold
staffBtn.TextSize = 14
staffBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
staffBtn.TextColor3 = Color3.fromRGB(255,255,255)
staffBtn.MouseButton1Click:Connect(function()
    local key = gerarKey("Staff")
    try_set_clipboard(key)
    try_notify("Key Gerada","Staff key copiada: "..key)
end)

local donoBtn = Instance.new("TextButton",gerarKeysPage)
donoBtn.Size = UDim2.new(0,150,0,30)
donoBtn.Position = UDim2.new(0,10,0,50)
donoBtn.Text = "Gerar Key Dono"
donoBtn.Font = Enum.Font.GothamBold
donoBtn.TextSize = 14
donoBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
donoBtn.TextColor3 = Color3.fromRGB(255,255,255)
donoBtn.MouseButton1Click:Connect(function()
    local key = gerarKey("Dono")
    try_set_clipboard(key)
    try_notify("Key Gerada","Dono key copiada: "..key)
end)
