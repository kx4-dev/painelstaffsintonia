-- // Serviços
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // CONFIGURAÇÕES
local STAFF_NAMES = {"Staff", "staff", "STAFF", "Mod", "Admin", "Moderador", "moderador"}
local DEV_NAMES = {"Dev", "DEV", "Developer", "Desenvolvedor"}
local DONO_NAMES = {"Dono", "Owner", "DONO", "OWNER"}
local UPDATE_INTERVAL = 1 -- segundos entre cada atualização automática

-- // FUNÇÃO PARA PEGAR LISTA DE CADA CARGO
local function getPlayersByTeamNames(list)
	local result = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team and table.find(list, player.Team.Name) then
			table.insert(result, player.DisplayName .. " (" .. player.Name .. ")")
		end
	end
	return result
end

-- // CRIAR GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PainelEquipes"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 320)
Frame.Position = UDim2.new(0.5, -150, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Bordas arredondadas e contorno
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 110, 255)
UIStroke.Parent = Frame

-- // TÍTULO
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "👑 Painel de Equipes"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Parent = Frame

-- // BOTÃO RECARREGAR
local ReloadButton = Instance.new("TextButton")
ReloadButton.Size = UDim2.new(0, 110, 0, 30)
ReloadButton.Position = UDim2.new(0.5, -55, 0, 40)
ReloadButton.Text = "🔄 Recarregar"
ReloadButton.Font = Enum.Font.GothamMedium
ReloadButton.TextSize = 14
ReloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ReloadButton.BackgroundColor3 = Color3.fromRGB(45, 45, 80)
ReloadButton.BorderSizePixel = 0
ReloadButton.Parent = Frame

local CornerBtn = Instance.new("UICorner")
CornerBtn.CornerRadius = UDim.new(0, 6)
CornerBtn.Parent = ReloadButton

ReloadButton.MouseEnter:Connect(function()
	ReloadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
end)
ReloadButton.MouseLeave:Connect(function()
	ReloadButton.BackgroundColor3 = Color3.fromRGB(45, 45, 80)
end)

-- // SCROLL CONTAINER
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 0, 230)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 75)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.BackgroundTransparency = 0.2
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Parent = Frame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = ScrollingFrame

-- // CRIADOR DE SEÇÃO
local function criarTituloSecao(texto, cor)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -10, 0, 25)
	title.Text = texto
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = cor
	title.BackgroundTransparency = 1
	title.Parent = ScrollingFrame
	return title
end

-- // ATUALIZAR LISTA
local function atualizarLista()
	for _, child in ipairs(ScrollingFrame:GetChildren()) do
		if child:IsA("TextLabel") and child ~= ListLayout then
			child:Destroy()
		end
	end

	local staffs = getPlayersByTeamNames(STAFF_NAMES)
	local devs = getPlayersByTeamNames(DEV_NAMES)
	local donos = getPlayersByTeamNames(DONO_NAMES)

	criarTituloSecao("🛡️ STAFFS (" .. #staffs .. ")", Color3.fromRGB(200, 200, 255))
	for _, nome in ipairs(staffs) do
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -10, 0, 25)
		lbl.Text = "⭐ " .. nome
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 14
		lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		lbl.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
		lbl.BorderSizePixel = 0
		lbl.Parent = ScrollingFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = lbl
	end

	criarTituloSecao("💻 DEVS (" .. #devs .. ")", Color3.fromRGB(200, 255, 200))
	for _, nome in ipairs(devs) do
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -10, 0, 25)
		lbl.Text = "💻 " .. nome
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 14
		lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		lbl.BackgroundColor3 = Color3.fromRGB(40, 70, 40)
		lbl.BorderSizePixel = 0
		lbl.Parent = ScrollingFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = lbl
	end

	criarTituloSecao("👑 DONOS (" .. #donos .. ")", Color3.fromRGB(255, 230, 150))
	for _, nome in ipairs(donos) do
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -10, 0, 25)
		lbl.Text = "👑 " .. nome
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 14
		lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		lbl.BackgroundColor3 = Color3.fromRGB(70, 50, 30)
		lbl.BorderSizePixel = 0
		lbl.Parent = ScrollingFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = lbl
	end

	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ( #staffs + #devs + #donos ) * 30 + 90)
end

-- // BOTÃO MANUAL
ReloadButton.MouseButton1Click:Connect(atualizarLista)

-- // AUTO UPDATE
task.spawn(function()
	while true do
		atualizarLista()
		task.wait(UPDATE_INTERVAL)
	end
end)

Players.PlayerAdded:Connect(atualizarLista)
Players.PlayerRemoving:Connect(atualizarLista)
