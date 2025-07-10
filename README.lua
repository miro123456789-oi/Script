local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local userInput = game:GetService("UserInputService")
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "AutoUpgradeGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Variáveis
local upgradesSelecionados = {
	Bounce = player:GetAttribute("AutoUpgrade_Bounce") ~= false,
	Accuracy = player:GetAttribute("AutoUpgrade_Accuracy") ~= false,
	Power = player:GetAttribute("AutoUpgrade_Power") ~= false,
	Floor = player:GetAttribute("AutoUpgrade_Floor") ~= false,
}
local intervalo = player:GetAttribute("AutoUpgrade_Intervalo") or 1
local repeticaoAtiva = false
local loopThread = nil
local puloInfinito = false
local correndo = false

-- GUI Principal
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- Botão minimizar
local minimizar = Instance.new("TextButton", frame)
minimizar.Text = "-"
minimizar.Size = UDim2.new(0, 30, 0, 30)
minimizar.Position = UDim2.new(1, -30, 0, 0)
minimizar.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
minimizar.TextColor3 = Color3.new(1,1,1)

-- Botão reabrir
local reabrir = Instance.new("TextButton", screenGui)
reabrir.Text = "+"
reabrir.Size = UDim2.new(0, 40, 0, 40)
reabrir.Position = UDim2.new(0, 10, 0, 10)
reabrir.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
reabrir.TextColor3 = Color3.new(1,1,1)
reabrir.Visible = false

minimizar.MouseButton1Click:Connect(function()
	frame.Visible = false
	reabrir.Visible = true
end)
reabrir.MouseButton1Click:Connect(function()
	frame.Visible = true
	reabrir.Visible = false
end)

-- Criação de abas
local function criarAba(nome, posX)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0, 140, 0, 30)
	btn.Position = UDim2.new(0, posX, 0, 0)
	btn.Text = nome
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.MouseButton1Click:Connect(function()
		for _, gui in pairs(frame:GetChildren()) do
			if gui:IsA("Frame") and gui.Name ~= nome then
				gui.Visible = false
			end
		end
		frame:FindFirstChild(nome).Visible = true
	end)
end

criarAba("Upgrades", 0)
criarAba("Player Mods", 150)

-- Aba Upgrades
local upgradesFrame = Instance.new("Frame", frame)
upgradesFrame.Name = "Upgrades"
upgradesFrame.Position = UDim2.new(0, 0, 0, 30)
upgradesFrame.Size = UDim2.new(1, 0, 1, -30)
upgradesFrame.BackgroundTransparency = 1

local intervaloBox = Instance.new("TextBox", upgradesFrame)
intervaloBox.Text = tostring(intervalo)
intervaloBox.Size = UDim2.new(0, 100, 0, 25)
intervaloBox.Position = UDim2.new(0, 10, 0, 10)
intervaloBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
intervaloBox.ClearTextOnFocus = false

local function criarCheckbox(parent, nome, ordem)
	local box = Instance.new("TextButton", parent)
	box.Size = UDim2.new(1, -20, 0, 25)
	box.Position = UDim2.new(0, 10, 0, 40 + (ordem * 30))
	box.BackgroundColor3 = Color3.fromRGB(60,60,60)
	box.TextColor3 = Color3.new(1,1,1)

	local function atualizarTexto()
		box.Text = (upgradesSelecionados[nome] and "[✔] " or "[ ] ") .. nome
	end
	atualizarTexto()
	box.MouseButton1Click:Connect(function()
		upgradesSelecionados[nome] = not upgradesSelecionados[nome]
		atualizarTexto()
		player:SetAttribute("AutoUpgrade_"..nome, upgradesSelecionados[nome])
	end)
end

for i, nome in ipairs({"Bounce", "Accuracy", "Power", "Floor"}) do
	criarCheckbox(upgradesFrame, nome, i-1)
end

local toggleButton = Instance.new("TextButton", upgradesFrame)
toggleButton.Text = "Ativar Repetição"
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 180)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleButton.TextColor3 = Color3.new(1,1,1)

local function executarRepeticao()
	while repeticaoAtiva do
		pcall(function()
			local rs = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index")
				:WaitForChild("sleitnick_knit@1.5.1"):WaitForChild("knit"):WaitForChild("Services")
				:WaitForChild("DataService"):WaitForChild("RF")
			for _, stat in ipairs({"Bounce", "Accuracy", "Power", "Floor"}) do
				if upgradesSelecionados[stat] then
					rs:WaitForChild("UpgradeStat"):InvokeServer(stat)
				end
			end
		end)
		wait(intervalo)
	end
end

toggleButton.MouseButton1Click:Connect(function()
	local novo = tonumber(intervaloBox.Text)
	if novo and novo > 0 then
		intervalo = novo
		player:SetAttribute("AutoUpgrade_Intervalo", intervalo)
	end
	repeticaoAtiva = not repeticaoAtiva
	toggleButton.Text = repeticaoAtiva and "Desativar Repetição" or "Ativar Repetição"
	toggleButton.BackgroundColor3 = repeticaoAtiva and Color3.fromRGB(170,0,0) or Color3.fromRGB(0,170,0)
	if repeticaoAtiva then
		loopThread = task.spawn(executarRepeticao)
	end
end)

-- Aba Player Mods
local modsFrame = Instance.new("Frame", frame)
modsFrame.Name = "Player Mods"
modsFrame.Position = UDim2.new(0, 0, 0, 30)
modsFrame.Size = UDim2.new(1, 0, 1, -30)
modsFrame.BackgroundTransparency = 1
modsFrame.Visible = false

local function criarModInput(nome, atributo, valorPadrao, posY)
	local label = Instance.new("TextLabel", modsFrame)
	label.Text = nome
	label.Position = UDim2.new(0, 10, 0, posY)
	label.Size = UDim2.new(0, 100, 0, 25)
	label.TextColor3 = Color3.new(1,1,1)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left

	local box = Instance.new("TextBox", modsFrame)
	box.Text = tostring(valorPadrao)
	box.Size = UDim2.new(0, 100, 0, 25)
	box.Position = UDim2.new(0, 120, 0, posY)
	box.BackgroundColor3 = Color3.fromRGB(255,255,255)
	box.ClearTextOnFocus = false

	box.FocusLost:Connect(function()
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		local novo = tonumber(box.Text)
		if humanoid and novo then
			if atributo == "WalkSpeed" then
				humanoid.WalkSpeed = novo
			elseif atributo == "JumpPower" then
				humanoid.JumpPower = novo
			elseif atributo == "Gravity" then
				game.Workspace.Gravity = novo
			end
		end
	end)
end

criarModInput("Velocidade", "WalkSpeed", 16, 10)
criarModInput("Pulo", "JumpPower", 50, 45)
criarModInput("Gravidade", "Gravity", 196.2, 80)

-- Pulo infinito
local puloBtn = Instance.new("TextButton", modsFrame)
puloBtn.Text = "Pulo Infinito: OFF"
puloBtn.Size = UDim2.new(1, -20, 0, 30)
puloBtn.Position = UDim2.new(0, 10, 0, 120)
puloBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
puloBtn.TextColor3 = Color3.new(1,1,1)

puloBtn.MouseButton1Click:Connect(function()
	puloInfinito = not puloInfinito
	puloBtn.Text = "Pulo Infinito: " .. (puloInfinito and "ON" or "OFF")
end)

userInput.JumpRequest:Connect(function()
	if puloInfinito then
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- Correr com Shift ou botão (visual)
local botaoCorrer = Instance.new("TextButton", screenGui)
botaoCorrer.Size = UDim2.new(0, 100, 0, 40)
botaoCorrer.Position = UDim2.new(1, -110, 1, -50)
botaoCorrer.AnchorPoint = Vector2.new(0,1)
botaoCorrer.Text = "Correr"
botaoCorrer.BackgroundColor3 = Color3.fromRGB(0,0,150)
botaoCorrer.TextColor3 = Color3.new(1,1,1)

botaoCorrer.MouseButton1Down:Connect(function()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.WalkSpeed = 32 end
end)
botaoCorrer.MouseButton1Up:Connect(function()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.WalkSpeed = 16 end
end)
