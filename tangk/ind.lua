--==[ INISIALISASI LAYANAN DAN PEMAIN ]==--
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local spacing = 45
local baseY = 50
local buttonIndex = 0

--==[ UI UTAMA ]==--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainScriptGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

--==[ FUNGSI UTAMA UNTUK MEMBUAT BUTTON ]==--
local function createButton(text, posY, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 200, 0, 40)
	button.Position = UDim2.new(0, 20, 0, posY)
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 18
	button.Text = text
	button.Parent = screenGui
	button.MouseButton1Click:Connect(callback)
	return button
end

local function createTightButton(text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 200, 0, 40)
	button.Position = UDim2.new(0, 20, 0, baseY + spacing * buttonIndex)
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 18
	button.Text = text
	button.Parent = screenGui
	button.MouseButton1Click:Connect(callback)
	buttonIndex += 1
	return button
end

--==[ KOORDINAT PEMAIN ]==--
local coordLabel = Instance.new("TextLabel")
coordLabel.Size = UDim2.new(0, 250, 0, 30)
coordLabel.Position = UDim2.new(0, 10, 0, 10)
coordLabel.BackgroundTransparency = 0.5
coordLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
coordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
coordLabel.TextScaled = true
coordLabel.Font = Enum.Font.SourceSansBold
coordLabel.Text = "Koordinat: "
coordLabel.Parent = screenGui

runService.RenderStepped:Connect(function()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local pos = player.Character.HumanoidRootPart.Position
		coordLabel.Text = string.format("Koordinat: X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z)
	end
end)

--==[ TELEPORT TANGKUBAN - DROPDOWN ]==--
local camps = {
	Camp1 = Vector3.new(863.5, 288.9, 736.4),
	Camp2 = Vector3.new(1086.7, 937.8, -886.1),
	Camp3 = Vector3.new(49.6, 1429.6, -1051.3)
}

local tangkubanFrame = Instance.new("Frame")
tangkubanFrame.Size = UDim2.new(0, 200, 0, 140)
tangkubanFrame.Position = UDim2.new(0, 240, 0, baseY + spacing * buttonIndex)
tangkubanFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
tangkubanFrame.BorderSizePixel = 0
tangkubanFrame.Visible = false
tangkubanFrame.Parent = screenGui

local listLayout = Instance.new("UIListLayout", tangkubanFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)

local tangkubanButton = createTightButton("Tangkuban TP [▼]", function()
	tangkubanFrame.Visible = not tangkubanFrame.Visible
end)

local function createCampButton(name, pos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 16
	btn.Text = name
	btn.BorderSizePixel = 0
	btn.Parent = tangkubanFrame
	btn.MouseButton1Click:Connect(function()
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = CFrame.new(pos) end
	end)
end

createCampButton("Camp 1", camps.Camp1)
createCampButton("Camp 2", camps.Camp2)
createCampButton("Camp 3", camps.Camp3)

buttonIndex += 1

--==[ NOCLIP REVISI ]==--
local noclip = false
local noclipButton

local function updateNoclipButton()
	noclipButton.Text = noclip and "NoClip [N] [Aktif]" or "NoClip [Mati]"
	noclipButton.BackgroundColor3 = noclip and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end

noclipButton = createTightButton("NoClip [N] [Mati]", function()
	noclip = not noclip
	updateNoclipButton()
end)

runService.Stepped:Connect(function()
	if noclip and player.Character then
		for _, v in pairs(player.Character:GetDescendants()) do
			if v:IsA("BasePart") and v.CanCollide == true then
				v.CanCollide = false
			end
		end
	end
end)

--==[ SPEED ]==--
local humanoidSpeed = 15
local function applySpeed()
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")
	humanoid.WalkSpeed = humanoidSpeed
end

applySpeed()
player.CharacterAdded:Connect(function()
	wait(1)
	applySpeed()
end)

--==[ BRIGHTNESS REVISI ]==--
local brightnessOn = false
local brightnessButton

local function setBrightnessLoop()
	runService:BindToRenderStep("BrightnessLoop", Enum.RenderPriority.Camera.Value + 1, function()
		if brightnessOn then
			lighting.Brightness = 5
			lighting.ClockTime = 14
			lighting.FogEnd = 100000
			lighting.GlobalShadows = false
		end
	end)
end

local function stopBrightnessLoop()
	runService:UnbindFromRenderStep("BrightnessLoop")
	lighting.Brightness = 1
	lighting.ClockTime = 12
	lighting.FogEnd = 1000
	lighting.GlobalShadows = true
end

local function updateBrightnessButton()
	brightnessButton.Text = brightnessOn and "Brightness [ON]" or "Brightness [OFF]"
	brightnessButton.BackgroundColor3 = brightnessOn and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end

brightnessButton = createTightButton("Brightness [OFF]", function()
	brightnessOn = not brightnessOn
	if brightnessOn then
		setBrightnessLoop()
	else
		stopBrightnessLoop()
	end
	updateBrightnessButton()
end)

--==[ TP PLAYER SEARCH (K) ]==--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportUI"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 360)
frame.Position = UDim2.new(0.5, -160, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Visible = false
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
title.Text = "Teleport ke Pemain"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local searchBox = Instance.new("TextBox")
searchBox.PlaceholderText = "Cari username..."
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 40)
searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.SourceSans
searchBox.TextSize = 18
searchBox.ClearTextOnFocus = false
searchBox.BorderSizePixel = 0
searchBox.Parent = frame
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -20, 1, -90)
playerList.Position = UDim2.new(0, 10, 0, 80)
playerList.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
playerList.BorderSizePixel = 0
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.ScrollBarThickness = 4
playerList.Parent = frame

local layout = Instance.new("UIListLayout", playerList)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

local function teleportToPlayer(targetPlayer)
	local myChar = player.Character
	local targetChar = targetPlayer.Character
	if myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
		myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
	end
end

local function createPlayerButton(p)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 18
	btn.Text = p.Name
	btn.BorderSizePixel = 0
	btn.Parent = playerList
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(function()
		teleportToPlayer(p)
	end)
end

local function refreshPlayerList()
	playerList:ClearAllChildren()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and string.find(string.lower(p.Name), string.lower(searchBox.Text)) then
			createPlayerButton(p)
		end
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshPlayerList)
Players.PlayerAdded:Connect(function()
	if gui.Enabled then refreshPlayerList() end
end)
Players.PlayerRemoving:Connect(function()
	if gui.Enabled then refreshPlayerList() end
end)

local function toggleGui(show)
	if show then
		gui.Enabled = true
		frame.Visible = true
		frame.BackgroundTransparency = 1
		for _, child in ipairs(frame:GetDescendants()) do
			if child:IsA("TextLabel") or child:IsA("") or child:IsA("TextButton") then
				child.TextTransparency = 1
			end
		end
		TweenService:Create(frame, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
		for _, child in ipairs(frame:GetDescendants()) do
			if child:IsA("TextLabel") or child:IsA("") or child:IsA("TextButton") then
				TweenService:Create(child, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
			end
		end
		refreshPlayerList()
	else
		TweenService:Create(frame, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
		for _, child in ipairs(frame:GetDescendants()) do
			if child:IsA("TextLabel") or child:IsA("") or child:IsA("TextButton") then
				TweenService:Create(child, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
			end
		end
		wait(0.3)
		gui.Enabled = false
		frame.Visible = false
	end
end

local playerSearchUIVisible = false
createTightButton("TP ke Pemain [K]", function()
	playerSearchUIVisible = not playerSearchUIVisible
	toggleGui(playerSearchUIVisible)
end)

uis.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.K then
		playerSearchUIVisible = not playerSearchUIVisible
		toggleGui(playerSearchUIVisible)
	end
end)

--==[ FLY ]==--
local flying = false
local bodyGyro, bodyVelocity
local flyButton

local function updateFlyButton()
	flyButton.Text = flying and "Fly [ON]" or "Fly [OFF]"
	flyButton.BackgroundColor3 = flying and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end

local function toggleFly()
	flying = not flying
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if flying then
		bodyGyro = Instance.new("BodyGyro", root)
		bodyGyro.P = 9e4
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.CFrame = root.CFrame

		bodyVelocity = Instance.new("BodyVelocity", root)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

		flyConnection = runService.RenderStepped:Connect(function()
			if flying and bodyVelocity and root then
				bodyGyro.CFrame = workspace.CurrentCamera.CFrame
				bodyVelocity.Velocity = workspace.CurrentCamera.CFrame.LookVector * 50
			end
		end)
	else
		if bodyGyro then bodyGyro:Destroy() end
		if bodyVelocity then bodyVelocity:Destroy() end
		if flyConnection then flyConnection:Disconnect() end
	end

	updateFlyButton()
end

flyButton = createTightButton("Fly [OFF]", function()
	toggleFly()
end)

updateFlyButton()

--==[ SPEED SLIDER ]==--
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 200, 0, 20)
speedLabel.Position = UDim2.new(0, 20, 0, 90)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.TextSize = 16
speedLabel.Text = "Speed: 15"
speedLabel.Parent = screenGui

local slider = Instance.new("TextButton")
slider.Size = UDim2.new(0, 200, 0, 20)
slider.Position = UDim2.new(0, 20, 0, 110)
slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
slider.Text = ""
slider.AutoButtonColor = false
slider.Parent = screenGui

local fill = Instance.new("Frame")
fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
fill.Size = UDim2.new(0.15, 0, 1, 0)
fill.Position = UDim2.new(0, 0, 0, 0)
fill.BorderSizePixel = 0
fill.Parent = slider

local dragging = false

slider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end
end)

uis.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

runService.RenderStepped:Connect(function()
	if dragging then
		local mouse = uis:GetMouseLocation().X
		local sliderPos = slider.AbsolutePosition.X
		local sliderWidth = slider.AbsoluteSize.X
		local percent = math.clamp((mouse - sliderPos) / sliderWidth, 0, 1)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		humanoidSpeed = math.floor(percent * 100)
		speedLabel.Text = "Speed: " .. humanoidSpeed
		local char = player.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = humanoidSpeed
		end
	end
end)

--==[ TOGGLE UI ]==--
local uiVisible = true
local toggleUIButton = Instance.new("TextButton")
toggleUIButton.Size = UDim2.new(0, 100, 0, 30)
toggleUIButton.Position = UDim2.new(0, 260, 0, 10)
toggleUIButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleUIButton.Font = Enum.Font.SourceSansBold
toggleUIButton.TextSize = 16
toggleUIButton.Text = "Hide [H] "
toggleUIButton.Parent = screenGui

local function setUIVisibility(state)
	uiVisible = state
	for _, element in pairs(screenGui:GetChildren()) do
		if element ~= toggleUIButton then
			element.Visible = uiVisible
		end
	end
	toggleUIButton.Text = uiVisible and "Hide [H] " or "Show [H] "
end

toggleUIButton.MouseButton1Click:Connect(function()
	setUIVisibility(not uiVisible)
end)

uis.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if input.KeyCode == Enum.KeyCode.H then
		setUIVisibility(not uiVisible)
	end
end)
--==[ INFINITE JUMP TOGGLE BUTTON ]==--
local infiniteJumpEnabled = false
local infiniteJumpButton

local function updateInfiniteJumpButton()
	infiniteJumpButton.Text = infiniteJumpEnabled and "Infinite Jump [ON]" or "Infinite Jump [OFF]"
	infiniteJumpButton.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end

infiniteJumpButton = createTightButton("Infinite Jump [OFF]", function()
	infiniteJumpEnabled = not infiniteJumpEnabled
	updateInfiniteJumpButton()
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
	if infiniteJumpEnabled then
		local char = player.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState("Jumping")
		end
	end
end)

--==[ ANTI AFK ]==--
local antiAfkEnabled = false
local antiAfkButton
local virtualUser = game:GetService("VirtualUser")
local player = game.Players.LocalPlayer

local function updateAntiAfkButton()
	antiAfkButton.Text = antiAfkEnabled and "Anti AFK [ON]" or "Anti AFK [OFF]"
	antiAfkButton.BackgroundColor3 = antiAfkEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end

antiAfkButton = createTightButton("Anti AFK [OFF]", function()
	antiAfkEnabled = not antiAfkEnabled
	updateAntiAfkButton()
end)

player.Idled:Connect(function()
	if antiAfkEnabled then
		virtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
		wait(1)
		virtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
	end
end)

updateAntiAfkButton()

--==[ TELEPORT TO CURSOR ]==--
local teleportToCursorEnabled = false
local teleportToCursorButton

local function updateTeleportToCursorButton()
	teleportToCursorButton.Text = teleportToCursorEnabled and "Teleport Cursor [ON]" or "Teleport Cursor [OFF]"
	teleportToCursorButton.BackgroundColor3 = teleportToCursorEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end

teleportToCursorButton = createTightButton("Teleport Cursor [OFF]", function()
	teleportToCursorEnabled = not teleportToCursorEnabled
	updateTeleportToCursorButton()
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if teleportToCursorEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mouse = player:GetMouse()
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local ray = workspace:Raycast(mouse.Origin.Position, mouse.Origin.LookVector * 1000, RaycastParams.new())
			local targetPos = ray and ray.Position or mouse.Hit.p
			char.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
		end
	end
end)

updateTeleportToCursorButton()

--==[ ESP (NAME + DISTANCE) ]==--
local espEnabled = false
local espButton = nil
local espLabels = {}
local localPlayer = game.Players.LocalPlayer

local function createESPForPlayer(p)
	if p == localPlayer then return end

	local function addESP(char)
		if char:FindFirstChild("Head") then
			local head = char.Head

			local billboard = Instance.new("BillboardGui")
			billboard.Name = "ESP_Label"
			billboard.Adornee = head
			billboard.Size = UDim2.new(0, 100, 0, 40)
			billboard.StudsOffset = Vector3.new(0, 2.5, 0)
			billboard.AlwaysOnTop = true
			billboard.Parent = head

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
			nameLabel.Position = UDim2.new(0, 0, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.TextColor3 = Color3.new(1, 1, 1)
			nameLabel.TextStrokeTransparency = 0
			nameLabel.Text = p.Name
			nameLabel.Font = Enum.Font.SourceSansBold
			nameLabel.TextScaled = true
			nameLabel.Parent = billboard

			local distanceLabel = Instance.new("TextLabel")
			distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
			distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
			distanceLabel.BackgroundTransparency = 1
			distanceLabel.TextColor3 = Color3.new(1, 1, 1)
			distanceLabel.TextStrokeTransparency = 0.5
			distanceLabel.Text = "0"
			distanceLabel.Font = Enum.Font.SourceSans
			distanceLabel.TextScaled = true
			distanceLabel.Parent = billboard

			-- Update jarak terus-menerus
			local connection = game:GetService("RunService").RenderStepped:Connect(function()
				if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and head then
					local dist = (localPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
					distanceLabel.Text = string.format("%.1f studs", dist)
				end
			end)

			espLabels[p] = {
				gui = billboard,
				connection = connection
			}
		end
	end

	p.CharacterAdded:Connect(function(char)
		if espEnabled then
			wait(1)
			addESP(char)
		end
	end)

	if p.Character then
		addESP(p.Character)
	end
end

local function removeAllESP()
	for _, data in pairs(espLabels) do
		if data.gui then data.gui:Destroy() end
		if data.connection then data.connection:Disconnect() end
	end
	espLabels = {}
end

local function updateESPButton()
	espButton.Text = espEnabled and "ESP [ON]" or "ESP [OFF]"
	espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end

espButton = createTightButton("ESP [OFF]", function()
	espEnabled = not espEnabled
	updateESPButton()

	if espEnabled then
		for _, p in pairs(game.Players:GetPlayers()) do
			createESPForPlayer(p)
		end
	else
		removeAllESP()
	end
end)

game.Players.PlayerAdded:Connect(function(p)
	if espEnabled then
		createESPForPlayer(p)
	end
end)

updateESPButton()

--==[ GUI SPECTATE PEMAIN DENGAN STOP BUTTON ]==--
local spectateGui = Instance.new("ScreenGui")
spectateGui.Name = "SpectateUI"
spectateGui.ResetOnSpawn = false
spectateGui.Enabled = false
spectateGui.Parent = player:WaitForChild("PlayerGui")

local spectateFrame = frame:Clone()
spectateFrame.Parent = spectateGui
spectateFrame.Visible = false
spectateFrame:FindFirstChild("TextLabel").Text = "Spectate Pemain"
spectateFrame.Position = UDim2.new(0.5, -160, 0.5, -180)

local spectateSearchBox = spectateFrame:FindFirstChildOfClass("")
local spectatePlayerList = spectateFrame:FindFirstChildOfClass("ScrollingFrame")

-- Tombol stop spectate
local stopSpectateButton = Instance.new("TextButton")
stopSpectateButton.Size = UDim2.new(1, -10, 0, 30)
stopSpectateButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
stopSpectateButton.TextColor3 = Color3.new(1, 1, 1)
stopSpectateButton.Font = Enum.Font.SourceSansBold
stopSpectateButton.TextSize = 18
stopSpectateButton.Text = "🛑 Stop Spectate"
stopSpectateButton.BorderSizePixel = 0
Instance.new("UICorner", stopSpectateButton).CornerRadius = UDim.new(0, 6)
stopSpectateButton.Parent = spectatePlayerList
stopSpectateButton.MouseButton1Click:Connect(function()
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
	end
	spectateGui.Enabled = false
	spectateFrame.Visible = false
end)

-- Refresh list
local function refreshSpectateList()
	for _, item in pairs(spectatePlayerList:GetChildren()) do
		if item:IsA("TextButton") and item ~= stopSpectateButton then
			item:Destroy()
		end
	end

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and string.find(string.lower(p.Name), string.lower(spectateSearchBox.Text)) then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -10, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.SourceSans
			btn.TextSize = 18
			btn.Text = p.Name
			btn.BorderSizePixel = 0
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
			btn.Parent = spectatePlayerList
			btn.MouseButton1Click:Connect(function()
				if p.Character and p.Character:FindFirstChild("Humanoid") then
					workspace.CurrentCamera.CameraSubject = p.Character.Humanoid
				end
			end)
		end
	end
	stopSpectateButton.Parent = spectatePlayerList -- agar tetap di bawah
end

spectateSearchBox:GetPropertyChangedSignal("Text"):Connect(refreshSpectateList)
Players.PlayerAdded:Connect(function() if spectateGui.Enabled then refreshSpectateList() end end)
Players.PlayerRemoving:Connect(function() if spectateGui.Enabled then refreshSpectateList() end end)

-- Tombol toggle GUI
local spectateVisible = false
createTightButton("Spectate Pemain", function()
	spectateVisible = not spectateVisible
	spectateGui.Enabled = spectateVisible
	spectateFrame.Visible = spectateVisible
	if spectateVisible then refreshSpectateList() end
end)
--==[ TELEPORTASI ]==--
local teleportPosition = Vector3.new(-884.0, 844.3, -216.5)
createButton("TP Parasut (T)", 150, function()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then hrp.CFrame = CFrame.new(teleportPosition) end
end)

uis.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.T then
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = CFrame.new(teleportPosition) end
	end
end)
