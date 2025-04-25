local player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Системные переменные
local dragging = false
local dragStart, startPos
local currentSpeed = 150
local activeMode = "NONE" -- NONE/NORMAL/SPEED
local bodyVelocity
local connection

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportPro"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 40)
mainFrame.Position = UDim2.new(0.5, -110, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Панель перемещения
local dragHandle = Instance.new("TextButton")
dragHandle.Size = UDim2.new(1, 0, 0, 25)
dragHandle.Text = "🚀 ТЕЛЕПОРТ"
dragHandle.TextColor3 = Color3.new(1, 1, 1)
dragHandle.BackgroundTransparency = 1
dragHandle.Parent = mainFrame

-- Кнопки управления
local quickAccessButton = Instance.new("TextButton")
quickAccessButton.Size = UDim2.new(0, 25, 0, 25)
quickAccessButton.Position = UDim2.new(1, -55, 0, 0)
quickAccessButton.Text = "+"
quickAccessButton.TextColor3 = Color3.new(1, 1, 1)
quickAccessButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
quickAccessButton.Parent = mainFrame

local settingsButton = Instance.new("TextButton")
settingsButton.Size = UDim2.new(0, 25, 0, 25)
settingsButton.Position = UDim2.new(1, -25, 0, 0)
settingsButton.Text = "+"
settingsButton.TextColor3 = Color3.new(1, 1, 1)
settingsButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
settingsButton.Parent = mainFrame

-- Меню 1: Быстрые действия
local quickPanel = Instance.new("Frame")
quickPanel.Size = UDim2.new(1, 0, 0, 80)
quickPanel.Position = UDim2.new(0, 0, 0, 30)
quickPanel.BackgroundTransparency = 1
quickPanel.Visible = false
quickPanel.Parent = mainFrame

local btnNormal = Instance.new("TextButton")
btnNormal.Size = UDim2.new(0.9, 0, 0, 35)
btnNormal.Position = UDim2.new(0.05, 0, 0.1, 0)
btnNormal.Text = "Обычная"
btnNormal.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
btnNormal.Parent = quickPanel

local btnSpeed = Instance.new("TextButton")
btnSpeed.Size = UDim2.new(0.9, 0, 0, 35)
btnSpeed.Position = UDim2.new(0.05, 0, 0.6, 0)
btnSpeed.Text = "Скоростная"
btnSpeed.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
btnSpeed.Parent = quickPanel

-- Меню 2: Настройки
local settingsPanel = Instance.new("Frame")
settingsPanel.Size = UDim2.new(1, 0, 0, 120)
settingsPanel.Position = UDim2.new(0, 0, 0, 30)
settingsPanel.BackgroundTransparency = 1
settingsPanel.Visible = false
settingsPanel.Parent = mainFrame

local txtTarget = Instance.new("TextBox")
txtTarget.Size = UDim2.new(0.9, 0, 0, 25)
txtTarget.Position = UDim2.new(0.05, 0, 0.1, 0)
txtTarget.PlaceholderText = "Ник игрока"
txtTarget.Parent = settingsPanel

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.9, 0, 0, 25)
speedInput.Position = UDim2.new(0.05, 0, 0.4, 0)
speedInput.PlaceholderText = "Скорость (150)"
speedInput.Parent = settingsPanel

local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(0.9, 0, 0, 25)
applyButton.Position = UDim2.new(0.05, 0, 0.7, 0)
applyButton.Text = "Применить"
applyButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
applyButton.Parent = settingsPanel

-- Система перемещения
dragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Логика меню
local function updateMenuSize()
    local totalHeight = 40
    local yOffset = 30
    
    if quickPanel.Visible then
        quickPanel.Position = UDim2.new(0, 0, 0, yOffset)
        yOffset += 80
        totalHeight += 80
    end
    
    if settingsPanel.Visible then
        settingsPanel.Position = UDim2.new(0, 0, 0, yOffset)
        totalHeight += 120
    end
    
    mainFrame.Size = UDim2.new(0, 220, 0, totalHeight)
end

quickAccessButton.MouseButton1Click:Connect(function()
    quickPanel.Visible = not quickPanel.Visible
    quickAccessButton.Text = quickPanel.Visible and "-" or "+"
    updateMenuSize()
end)

settingsButton.MouseButton1Click:Connect(function()
    settingsPanel.Visible = not settingsPanel.Visible
    settingsButton.Text = settingsPanel.Visible and "-" or "+"
    updateMenuSize()
end)

-- Основные функции
local function updateUI()
    btnNormal.BackgroundColor3 = activeMode == "NORMAL" and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
    btnSpeed.BackgroundColor3 = activeMode == "SPEED" and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
end

local function findTarget()
    local targetName = txtTarget.Text
    local targetPlayer = nil
    
    if targetName ~= "" then
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr.Name:lower() == targetName:lower() then
                targetPlayer = plr
                break
            end
        end
    else
        local closestDistance = math.huge
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local distance = (myRoot.Position - hrp.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            targetPlayer = plr
                        end
                    end
                end
            end
        end
    end
    return targetPlayer
end

local function stopMovement()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end

local function startMovement(target)
    stopMovement()
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = player.Character.HumanoidRootPart
    
    connection = runService.Stepped:Connect(function()
        if not target.Character then return end
        local targetPos = target.Character.HumanoidRootPart.Position
        local myPos = player.Character.HumanoidRootPart.Position
        
        local direction = (targetPos - myPos).Unit
        bodyVelocity.Velocity = direction * currentSpeed + Vector3.new(0, 25, 0)
    end)
end

local function teleportAction(movement)
    local target = findTarget()
    if not target or not target.Character then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Ошибка",
            Text = "Цель не найдена!",
            Duration = 3
        })
        return
    end

    local myCharacter = player.Character
    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then return end

    -- Телепортация
    myCharacter.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
    
    -- Активация движения
    if movement then
        startMovement(target)
    else
        stopMovement()
    end
end

-- Обработчики кнопок
btnNormal.MouseButton1Click:Connect(function()
    if activeMode == "NORMAL" then
        activeMode = "NONE"
        stopMovement()
    else
        activeMode = "NORMAL"
        teleportAction(false)
    end
    updateUI()
end)

btnSpeed.MouseButton1Click:Connect(function()
    if activeMode == "SPEED" then
        activeMode = "NONE"
        stopMovement()
    else
        activeMode = "SPEED"
        teleportAction(true)
    end
    updateUI()
end)

applyButton.MouseButton1Click:Connect(function()
    currentSpeed = tonumber(speedInput.Text) or 150
    speedInput.Text = ""
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Успех",
        Text = "Скорость: "..currentSpeed,
        Duration = 2
    })
end)

-- Защита интерфейса
player.CharacterAdded:Connect(function()
    if not screenGui.Parent then
        screenGui.Parent = game:GetService("CoreGui")
    end
end)

while true do
    wait(5)
    if not screenGui.Parent then
        screenGui.Parent = game:GetService("CoreGui")
    end
end
