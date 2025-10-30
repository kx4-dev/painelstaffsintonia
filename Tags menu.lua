--[[
  LOBOS HUB - SCRIPT COMPLETO
  Desenvolvido por: lobinho_nix
  Sistema educativo para servidor privado
]]

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =======================
-- CONFIGURAÇÕES INICIAIS
-- =======================
local config = {
    FOV = 70,
    SpeedFly = 50,
    AutoCL = true,
    ESP = true,
    StaffList = {9245189519, 2525676903, 8239853870},
    AutoRevistarItens = {
        "AK47","Uzi","PARAFAL","Pt","Faca","IA2","G3","Dinamite","Hi Power","Natalina",
        "HK416","Lockpick","Escudo","Skate","Saco de lixo","Peça de Arma","Tratamento",
        "AR-15","PS5","C4","USP","Ptdragon","Fuzil","FuzilPhantom","Joia",
        "camisinha","ArmaPDSecreta","FuzilTrovão","Glock"
    },
    WebhookURL = "https://discord.com/api/webhooks/1431420455021187093/7CYDAY6KlnJ_okmITIcomhwB_7n3SeaJxXS6tyzhFPEdI0rL52Td7XMTfAH9UOiDdHD2"
}

-- =======================
-- SISTEMA DE KEYS
-- =======================
local keys = {}
for i=1,1000 do
    keys["dailykey"..i] = {tipo="diaria", criada=os.time(), deviceId=nil}
    keys["weeklykey"..i] = {tipo="semanal", criada=os.time(), deviceId=nil}
    keys["tikiperm"..i] = {tipo="permanente", criada=os.time(), deviceId=nil}
end

local tempoExpira = {diaria=86400, semanal=604800, permanente=math.huge}

local function validarKey(inputKey)
    local data = keys[inputKey]
    if not data then return false,"❌ Key inválida!" end
    local tipo, criada, agora, deviceId = data.tipo, data.criada, os.time(), tostring(LocalPlayer.UserId)
    if data.deviceId and data.deviceId ~= deviceId then return false,"❌ Key já utilizada em outro dispositivo!" end
    if (agora - criada) > tempoExpira[tipo] then return false,"⏳ Key expirada (" .. tipo .. ")" end
    if not data.deviceId then data.deviceId = deviceId end
    return true,"✅ Acesso Liberado (" .. tipo .. ")"
end

-- =======================
-- FUNÇÃO DE NOTIFICAÇÃO
-- =======================
local function notificar(titulo, mensagem, duracao)
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "NotifyGui"
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,250,0,80)
    frame.Position = UDim2.new(0.5,-125,0.1,0)
    frame.BackgroundColor3 = Color3.fromRGB(0,50,100)
    frame.BorderSizePixel = 0
    local uicorner = Instance.new("UICorner", frame)
    uicorner.CornerRadius = UDim.new(0,8)

    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1,0,0,20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titulo
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14

    local messageLabel = Instance.new("TextLabel", frame)
    messageLabel.Size = UDim2.new(1,0,0,60)
    messageLabel.Position = UDim2.new(0,0,0,20)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = mensagem
    messageLabel.TextColor3 = Color3.fromRGB(255,255,255)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextWrapped = true

    task.delay(duracao, function() gui:Destroy() end)
end

-- =======================
-- ESP (NOME, DISTÂNCIA, ITENS)
-- =======================
local espTags = {}
local function getEquippedItems(player)
    local equipped = {}
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _,item in pairs(backpack:GetChildren()) do
            if #equipped >= 3 then break end
            if item:IsA("Tool") then table.insert(equipped,item.Name) end
        end
    end
    if player.Character then
        for _,item in pairs(player.Character:GetChildren()) do
            if #equipped >= 3 then break end
            if item:IsA("Tool") then
                if not table.find(equipped,item.Name) then table.insert(equipped,item.Name) end
            end
        end
    end
    while #equipped<3 do table.insert(equipped,"") end
    return equipped
end

local function ativarESP()
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local billboard = Instance.new("BillboardGui", head)
            billboard.Name = "ESP_Tag"
            billboard.Size = UDim2.new(0,180,0,80)
            billboard.StudsOffset = Vector3.new(0,2,0)
            billboard.AlwaysOnTop = true

            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.new(1,0,0,24)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(0,170,255)
            label.Font = Enum.Font.GothamBold
            label.TextStrokeTransparency = 0
            label.TextSize = 16

            local itemsLabels = {}
            for i=1,3 do
                local itemLabel = Instance.new("TextLabel", billboard)
                itemLabel.Size = UDim2.new(1,0,0,18)
                itemLabel.Position = UDim2.new(0,0,0,24+((i-1)*18))
                itemLabel.BackgroundTransparency = 0.7
                itemLabel.BackgroundColor3 = Color3.new(0,0,0)
                itemLabel.TextColor3 = Color3.new(1,1,1)
                itemLabel.Font = Enum.Font.GothamBold
                itemLabel.TextStrokeTransparency = 0
                itemLabel.TextSize = 14
                table.insert(itemsLabels,itemLabel)
            end

            espTags[p.UserId] = {billboard=billboard,label=label,itemsLabels=itemsLabels}

            RunService:BindToRenderStep("ESP_Update_"..p.UserId,500,function()
                if p.Character and p.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = p.Character.Head.Position
                    local dist = (pos-LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    local equipped = getEquippedItems(p)
                    label.Text = p.Name.." | "..math.floor(dist).."m"
                    for i=1,3 do
                        itemsLabels[i].Text = (equipped[i]~="" and equipped[i]) or ""
                        itemsLabels[i].Visible = equipped[i]~=""
                    end
                else
                    RunService:UnbindFromRenderStep("ESP_Update_"..p.UserId)
                    if espTags[p.UserId] and espTags[p.UserId].billboard then espTags[p.UserId].billboard:Destroy() end
                    espTags[p.UserId] = nil
                end
            end)
        end
    end
end

-- =======================
-- AUTO CL / PUXAR ITENS / REVISTAR
-- =======================
local function autoCL()
    if not config.AutoCL then return end
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            for _,item in pairs(player.Backpack:GetChildren()) do
                if table.find(config.AutoRevistarItens,item.Name) then
                    notificar("Auto CL","Pegou "..item.Name.." de "..player.Name,2)
                end
            end
        end
    end
end

-- =======================
-- GERADOR DE KEYS E WEBHOOK
-- =======================
local function gerarKey()
    local key = "lobos_"..math.random(100000,999999)
    local nome = LocalPlayer.Name
    local userid = LocalPlayer.UserId
    local staff = (table.find(config.StaffList,userid) and "Sim") or "Não"

    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "🗝 Nova Key Gerada",
            ["fields"] = {
                {["name"]="Key",["value"]=key,["inline"]=true},
                {["name"]="Nome do Jogador",["value"]=nome,["inline"]=true},
                {["name"]="ID do Jogador",["value"]=tostring(userid),["inline"]=true},
                {["name"]="Dono / Staff ?",["value"]=staff,["inline"]=true}
            },
            ["color"] = 1127128
        }}
    }
    pcall(function()
        HttpService:PostAsync(config.WebhookURL,HttpService:JSONEncode(data),Enum.HttpContentType.ApplicationJson)
    end)
    notificar("Key Gerada","Sua key: "..key,5)
    return key
end

-- =======================
-- MENU ARRASTÁVEL
-- =======================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "LobosHubGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,300,0,450)
Frame.Position = UDim2.new(0.5,-150,0.5,-225)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Active = true
Frame.Draggable = true
local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0,12)

local ESPButton = Instance.new("TextButton", Frame)
ESPButton.Size = UDim2.new(0,280,0,40)
ESPButton.Position = UDim2.new(0,10,0,10)
ESPButton.Text = "Ativar / Desativar ESP"
ESPButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
ESPButton.TextColor3 = Color3.fromRGB(255,255,255)
ESPButton.Font = Enum.Font.GothamBold
ESPButton.TextSize = 16
ESPButton.MouseButton1Click:Connect(function()
    ativarESP()
end)

local KeyButton = Instance.new("TextButton", Frame)
KeyButton.Size = UDim2.new(0,280,0,40)
KeyButton.Position = UDim2.new(0,10,0,60)
KeyButton.Text = "Gerar Key"
KeyButton.BackgroundColor3 = Color3.fromRGB(0,255,85)
KeyButton.TextColor3 = Color3.fromRGB(0,0,0)
KeyButton.Font = Enum.Font.GothamBold
KeyButton.TextSize = 16
KeyButton.MouseButton1Click:Connect(function()
    gerarKey()
end)

-- =======================
-- LOOP PRINCIPAL
-- =======================
RunService.RenderStepped:Connect(function()
    if config.AutoCL then
        autoCL()
    end
end)
--[[
  LOBOS HUB - SCRIPT COMPLETO
  Desenvolvido por: lobinho_nix
  Sistema educativo para servidor privado
]]

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =======================
-- CONFIGURAÇÕES INICIAIS
-- =======================
local config = {
    FOV = 70,
    SpeedFly = 50,
    AutoCL = true,
    ESP = true,
    StaffList = {9245189519, 2525676903, 8239853870},
    AutoRevistarItens = {
        "AK47","Uzi","PARAFAL","Pt","Faca","IA2","G3","Dinamite","Hi Power","Natalina",
        "HK416","Lockpick","Escudo","Skate","Saco de lixo","Peça de Arma","Tratamento",
        "AR-15","PS5","C4","USP","Ptdragon","Fuzil","FuzilPhantom","Joia",
        "camisinha","ArmaPDSecreta","FuzilTrovão","Glock"
    },
    WebhookURL = "https://discord.com/api/webhooks/1431420455021187093/7CYDAY6KlnJ_okmITIcomhwB_7n3SeaJxXS6tyzhFPEdI0rL52Td7XMTfAH9UOiDdHD2"
}

-- =======================
-- SISTEMA DE KEYS
-- =======================
local keys = {}
for i=1,1000 do
    keys["dailykey"..i] = {tipo="diaria", criada=os.time(), deviceId=nil}
    keys["weeklykey"..i] = {tipo="semanal", criada=os.time(), deviceId=nil}
    keys["tikiperm"..i] = {tipo="permanente", criada=os.time(), deviceId=nil}
end

local tempoExpira = {diaria=86400, semanal=604800, permanente=math.huge}

local function validarKey(inputKey)
    local data = keys[inputKey]
    if not data then return false,"❌ Key inválida!" end
    local tipo, criada, agora, deviceId = data.tipo, data.criada, os.time(), tostring(LocalPlayer.UserId)
    if data.deviceId and data.deviceId ~= deviceId then return false,"❌ Key já utilizada em outro dispositivo!" end
    if (agora - criada) > tempoExpira[tipo] then return false,"⏳ Key expirada (" .. tipo .. ")" end
    if not data.deviceId then data.deviceId = deviceId end
    return true,"✅ Acesso Liberado (" .. tipo .. ")"
end

-- =======================
-- FUNÇÃO DE NOTIFICAÇÃO
-- =======================
local function notificar(titulo, mensagem, duracao)
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "NotifyGui"
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,250,0,80)
    frame.Position = UDim2.new(0.5,-125,0.1,0)
    frame.BackgroundColor3 = Color3.fromRGB(0,50,100)
    frame.BorderSizePixel = 0
    local uicorner = Instance.new("UICorner", frame)
    uicorner.CornerRadius = UDim.new(0,8)

    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1,0,0,20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titulo
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14

    local messageLabel = Instance.new("TextLabel", frame)
    messageLabel.Size = UDim2.new(1,0,0,60)
    messageLabel.Position = UDim2.new(0,0,0,20)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = mensagem
    messageLabel.TextColor3 = Color3.fromRGB(255,255,255)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextWrapped = true

    task.delay(duracao, function() gui:Destroy() end)
end

-- =======================
-- ESP (NOME, DISTÂNCIA, ITENS)
-- =======================
local espTags = {}
local function getEquippedItems(player)
    local equipped = {}
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _,item in pairs(backpack:GetChildren()) do
            if #equipped >= 3 then break end
            if item:IsA("Tool") then table.insert(equipped,item.Name) end
        end
    end
    if player.Character then
        for _,item in pairs(player.Character:GetChildren()) do
            if #equipped >= 3 then break end
            if item:IsA("Tool") then
                if not table.find(equipped,item.Name) then table.insert(equipped,item.Name) end
            end
        end
    end
    while #equipped<3 do table.insert(equipped,"") end
    return equipped
end

local function ativarESP()
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local billboard = Instance.new("BillboardGui", head)
            billboard.Name = "ESP_Tag"
            billboard.Size = UDim2.new(0,180,0,80)
            billboard.StudsOffset = Vector3.new(0,2,0)
            billboard.AlwaysOnTop = true

            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.new(1,0,0,24)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(0,170,255)
            label.Font = Enum.Font.GothamBold
            label.TextStrokeTransparency = 0
            label.TextSize = 16

            local itemsLabels = {}
            for i=1,3 do
                local itemLabel = Instance.new("TextLabel", billboard)
                itemLabel.Size = UDim2.new(1,0,0,18)
                itemLabel.Position = UDim2.new(0,0,0,24+((i-1)*18))
                itemLabel.BackgroundTransparency = 0.7
                itemLabel.BackgroundColor3 = Color3.new(0,0,0)
                itemLabel.TextColor3 = Color3.new(1,1,1)
                itemLabel.Font = Enum.Font.GothamBold
                itemLabel.TextStrokeTransparency = 0
                itemLabel.TextSize = 14
                table.insert(itemsLabels,itemLabel)
            end

            espTags[p.UserId] = {billboard=billboard,label=label,itemsLabels=itemsLabels}

            RunService:BindToRenderStep("ESP_Update_"..p.UserId,500,function()
                if p.Character and p.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = p.Character.Head.Position
                    local dist = (pos-LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    local equipped = getEquippedItems(p)
                    label.Text = p.Name.." | "..math.floor(dist).."m"
                    for i=1,3 do
                        itemsLabels[i].Text = (equipped[i]~="" and equipped[i]) or ""
                        itemsLabels[i].Visible = equipped[i]~=""
                    end
                else
                    RunService:UnbindFromRenderStep("ESP_Update_"..p.UserId)
                    if espTags[p.UserId] and espTags[p.UserId].billboard then espTags[p.UserId].billboard:Destroy() end
                    espTags[p.UserId] = nil
                end
            end)
        end
    end
end

-- =======================
-- AUTO CL / PUXAR ITENS / REVISTAR
-- =======================
local function autoCL()
    if not config.AutoCL then return end
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            for _,item in pairs(player.Backpack:GetChildren()) do
                if table.find(config.AutoRevistarItens,item.Name) then
                    notificar("Auto CL","Pegou "..item.Name.." de "..player.Name,2)
                end
            end
        end
    end
end

-- =======================
-- GERADOR DE KEYS E WEBHOOK
-- =======================
local function gerarKey()
    local key = "lobos_"..math.random(100000,999999)
    local nome = LocalPlayer.Name
    local userid = LocalPlayer.UserId
    local staff = (table.find(config.StaffList,userid) and "Sim") or "Não"

    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "🗝 Nova Key Gerada",
            ["fields"] = {
                {["name"]="Key",["value"]=key,["inline"]=true},
                {["name"]="Nome do Jogador",["value"]=nome,["inline"]=true},
                {["name"]="ID do Jogador",["value"]=tostring(userid),["inline"]=true},
                {["name"]="Dono / Staff ?",["value"]=staff,["inline"]=true}
            },
            ["color"] = 1127128
        }}
    }
    pcall(function()
        HttpService:PostAsync(config.WebhookURL,HttpService:JSONEncode(data),Enum.HttpContentType.ApplicationJson)
    end)
    notificar("Key Gerada","Sua key: "..key,5)
    return key
end

-- =======================
-- MENU ARRASTÁVEL
-- =======================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "LobosHubGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,300,0,450)
Frame.Position = UDim2.new(0.5,-150,0.5,-225)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Active = true
Frame.Draggable = true
local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0,12)

local ESPButton = Instance.new("TextButton", Frame)
ESPButton.Size = UDim2.new(0,280,0,40)
ESPButton.Position = UDim2.new(0,10,0,10)
ESPButton.Text = "Ativar / Desativar ESP"
ESPButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
ESPButton.TextColor3 = Color3.fromRGB(255,255,255)
ESPButton.Font = Enum.Font.GothamBold
ESPButton.TextSize = 16
ESPButton.MouseButton1Click:Connect(function()
    ativarESP()
end)

local KeyButton = Instance.new("TextButton", Frame)
KeyButton.Size = UDim2.new(0,280,0,40)
KeyButton.Position = UDim2.new(0,10,0,60)
KeyButton.Text = "Gerar Key"
KeyButton.BackgroundColor3 = Color3.fromRGB(0,255,85)
KeyButton.TextColor3 = Color3.fromRGB(0,0,0)
KeyButton.Font = Enum.Font.GothamBold
KeyButton.TextSize = 16
KeyButton.MouseButton1Click:Connect(function()
    gerarKey()
end)

-- =======================
-- LOOP PRINCIPAL
-- =======================
RunService.RenderStepped:Connect(function()
    if config.AutoCL then
        autoCL()
    end
end)
