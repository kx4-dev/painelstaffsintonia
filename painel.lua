-- // ESP PARA STAFFS, DEVS E DONOS
local function adicionarESP(player, cor)
	if not player.Character or not player.Character:FindFirstChild("Head") then return end
	local head = player.Character.Head

	-- Evita duplicação
	if head:FindFirstChild("ESP") then head.ESP:Destroy() end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = player.Name
	label.TextColor3 = cor
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = billboard
end

-- Atualiza ESP para todos
local function atualizarESP()
	for _, player in ipairs(Players:GetPlayers()) do
		local teamName = player.Team and player.Team.Name or ""
		if table.find(STAFF_NAMES, teamName) then
			adicionarESP(player, Color3.fromRGB(200,200,255)) -- STAFF azul
		elseif table.find(DEV_NAMES, teamName) then
			adicionarESP(player, Color3.fromRGB(100,255,100)) -- DEV verde
		elseif table.find(DONO_NAMES, teamName) then
			adicionarESP(player, Color3.fromRGB(255,200,100)) -- DONO laranja
		end
	end
end

-- Atualiza ESP periodicamente
task.spawn(function()
	while true do
		atualizarESP()
		task.wait(UPDATE_INTERVAL)
	end
end)

-- Atualiza ESP quando jogador entra ou sai
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1) -- espera o character carregar
		atualizarESP()
	end)
end)
Players.PlayerRemoving:Connect(atualizarESP)
