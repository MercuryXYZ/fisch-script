-- Initial Loading Checks
repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer.Character
repeat wait() until game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
repeat wait() until game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- Check for existing UI and clean up
if _G.FxnnUI then
    _G.FxnnUI:Destroy()
    autoShake = false
    autoReel = false
    AutoReelEnabled = false
    autoCastEnabled = false
    getgenv().giftloop = false
    getgenv().autoconfirm = false
    
    if shakeConnection then
        shakeConnection:Disconnect()
    end
    if AutoReelConnection then
        AutoReelConnection:Disconnect()
    end
    if autoCastConnection then
        autoCastConnection:Disconnect()
    end
end

-- Store new UI instance
_G.FxnnUI = Window

-- Core Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGUI = Player:WaitForChild("PlayerGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

Player.Idled:Connect(function()
    print("Idled, try to click...")
    VirtualUser:ClickButton1(Vector2.new(0, 0))
    print("clicked")
end)

-- UI Loading
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Variables
local selectedPlayer = ""
local currentPlayerList = {}
local Options = {}
local autoShake = false
local shakeConnection = nil
local autoShakeDelay = 0.05
local autoReel = false
local autoReelDelay = 2
local AutoReelEnabled = false
local AutoReelConnection = nil
local autoCastEnabled = false
local autoCastConnection = nil

-- Window Setup
local Window = Fluent:CreateWindow({
    Title = "Fisch {🐟}",
    SubTitle = "by mercuryxyz & fxnnxyz",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeConfig = {
        Side = "Left",
        Position = UDim2.new(0, 0, 0.5, 0)
    },
    MinimizeKey = Enum.KeyCode.LeftControl
})
_G.FxnnUI = Window

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Gifting = Window:AddTab({ Title = "Gifting", Icon = "gift" })
}

Window:SelectTab(Tabs.Main)

-- Auto Cast Function
Tabs.Main:AddToggle("AutoCast", {
    Title = "Auto Cast",
    Default = false,
    Callback = function(Value)
        autoCastEnabled = Value
        
        if autoCastConnection then
            autoCastConnection:Disconnect()
            autoCastConnection = nil
        end
        
        if Value then
            local function performCast()
                if not autoCastEnabled then return end
                local tool = Player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local castEvent = tool:FindFirstChild("events") and tool.events:FindFirstChild("cast")
                    if castEvent then
                        local Random2 = math.random(90, 99)
                        castEvent:FireServer(Random2)
                    end
                end
            end

            Player.Character.ChildAdded:Connect(function(child)
                if not autoCastEnabled then return end
                if child:IsA("Tool") then
                    task.wait(0.1)
                    performCast()
                end
            end)
            
            ReplicatedStorage.events.reelfinished.OnClientEvent:Connect(function()
                if not autoCastEnabled then return end
                task.wait(0.1)
                performCast()
            end)
            
            RunService.Heartbeat:Connect(function()
                if not autoCastEnabled then return end
                local tool = Player.Character:FindFirstChildOfClass("Tool")
                if tool and not tool:FindFirstChild("bobber") then
                    task.wait(0.1)
                    performCast()
                end
            end)
        end
    end
})

-- Auto Shake Function
local function handleButtonClick(button)
    if not button.Visible then return end
    
    GuiService.SelectedObject = button
    task.wait(autoShakeDelay)
    
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
end

-- Main Tab Elements
local autoShakeToggle = Tabs.Main:AddToggle("AutoShake", {
    Title = "Auto Shake",
    Default = false,
    Callback = function(Value)
        autoShake = Value
        
        if Value then
            PlayerGUI.ChildAdded:Connect(function(GUI)
                if GUI:IsA("ScreenGui") and GUI.Name == "shakeui" then
                    local safezone = GUI:WaitForChild("safezone", 5)
                    if safezone then
                        safezone.ChildAdded:Connect(function(child)
                            if child:IsA("ImageButton") and child.Name == "button" then
                                task.spawn(function()
                                    if autoShake then
                                        handleButtonClick(child)
                                    end
                                end)
                            end
                        end)
                    end
                end
            end)
        end
    end
})


--ist jetzt nicht die beste lösung aber ich bin dran
task.spawn(function()
    task.wait(0.1)

    local value = true
    autoShakeToggle.SetValue(value) -- Toggle it on
    print("AutoShake set to " .. tostring(value))

    task.wait(0.05)

    value = false
    autoShakeToggle.SetValue(value) -- Toggle it off
    print("AutoShake set to " .. tostring(value))
end)

Tabs.Main:AddSlider("ShakeDelay", {
    Title = "Auto Shake Delay",
    Default = 0.05,
    Min = 0.01,
    Max = 2,
    Rounding = 2,
    Decimals = 2,
    Description = "Adjust the delay between shakes",
    Callback = function(Value)
        autoShakeDelay = Value
    end
})

--ist jetzt nicht die beste lösung aber ich bin dran
task.spawn(function()
    task.wait(0.1)

    local value = true
    autoShakeToggle.SetValue(value) -- Toggle it on
    print("AutoShake set to " .. tostring(value))

    task.wait(0.05)

    value = false
    autoShakeToggle.SetValue(value) -- Toggle it off
    print("AutoShake set to " .. tostring(value))
end)

Tabs.Main:AddToggle("AutoReel", {
    Title = "Auto Reel",
    Default = false,
    Callback = function(Value)
        autoReel = Value
        
        if Value then
            PlayerGUI.ChildAdded:Connect(function(GUI)
                if GUI:IsA("ScreenGui") and GUI.Name == "reel" then
                    if autoReel then
                        local reelEvent = ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished")
                        if reelEvent then
                            repeat
                                task.wait(autoReelDelay)
                                reelEvent:FireServer(100, false)
                            until GUI == nil or not autoReel
                        end
                    end
                end
            end)
        end
    end
})

Tabs.Main:AddSlider("ReelDelay", {
    Title = "Auto Reel Delay",
    Default = 2,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Decimals = 1,
    Description = "Adjust the delay between reels",
    Callback = function(Value)
        autoReelDelay = Value
    end
})

--legit Reel

Tabs.Main:AddToggle("LegitAutoReel", {
    Title = "Legit Auto Reel",
    Default = false,
    Callback = function(Value)
        AutoReelEnabled = Value
        if Value then
            AutoReelConnection = RunService.RenderStepped:Connect(function()
                local reel = PlayerGUI:FindFirstChild("reel")
                if not reel then return end

                local bar = reel:FindFirstChild("bar")
                local playerbar = bar and bar:FindFirstChild("playerbar")
                local fish = bar and bar:FindFirstChild("fish")

                if playerbar and fish then
                    playerbar.Position = fish.Position
                end
            end)
        else
            if AutoReelConnection then
                AutoReelConnection:Disconnect()
                AutoReelConnection = nil
            end
        end
    end
})

PlayerGUI.DescendantAdded:Connect(function(descendant)
    if AutoReelEnabled and descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
        if AutoReelConnection then return end
        AutoReelConnection = RunService.RenderStepped:Connect(function()
            local reel = PlayerGUI:FindFirstChild("reel")
            if not reel then return end

            local bar = reel:FindFirstChild("bar")
            local playerbar = bar and bar:FindFirstChild("playerbar")
            local fish = bar and bar:FindFirstChild("fish")

            if playerbar and fish then
                playerbar.Position = fish.Position
            end
        end)
    end   
end)

PlayerGUI.DescendantRemoving:Connect(function(descendant) 
    if descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
        if AutoReelConnection then
            AutoReelConnection:Disconnect()
            AutoReelConnection = nil
        end
    end
end)

-- Functions
local function UpdatePlayerList()
    local newPlayerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(newPlayerList, player.Name)
        end
    end
    currentPlayerList = newPlayerList
    if Options.PlayerSelect then
        Options.PlayerSelect:SetValues(newPlayerList)
    end
end

local function TradeEquipped()
    if selectedPlayer == "" then
        Fluent:Notify({
            Title = "Error",
            Content = "Select a player first!",
            Duration = 3
        })
        return
    end

    local targetPlayer = Players:FindFirstChild(selectedPlayer)
    if targetPlayer then
        local equippedTool = Player.Character:FindFirstChildWhichIsA("Tool")
        if equippedTool and equippedTool:FindFirstChild("offer") then
            equippedTool.offer:FireServer(targetPlayer)
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Hold an item first!",
                Duration = 3
            })
        end
    end
end

local function GiftAll()
    if selectedPlayer == "" then
        Fluent:Notify({
            Title = "Error",
            Content = "Select a player first!",
            Duration = 3
        })
        getgenv().giftloop = false
        return
    end

    local targetPlayer = Players:FindFirstChild(selectedPlayer)
    if targetPlayer then
        while getgenv().giftloop do
            for _, item in pairs(Player.Backpack:GetChildren()) do
                if not getgenv().giftloop then break end
                if item:FindFirstChild("offer") then
                    Player.PlayerGui.hud.safezone.backpack.events.equip:FireServer(item)
                    wait(0.1)
                    item.offer:FireServer(targetPlayer)
                    wait(0.2)
                end
            end
            wait(0.5)
        end
    end
end

local function startAutoConfirm()
    PlayerGUI.hud.safezone.bodyannouncements.ChildAdded:Connect(function(child)
        if getgenv().autoconfirm and child:IsA("Frame") and child.Name == "offer" then
            local confirmButton = child:FindFirstChild("confirm")
            local shouldStop = false
            
            child.AncestryChanged:Connect(function(_, parent)
                if not parent then shouldStop = true end
            end)
            
            if confirmButton then
                confirmButton.AncestryChanged:Connect(function(_, parent)
                    if not parent then shouldStop = true end
                end)
                
                while not shouldStop and getgenv().autoconfirm do
                    if confirmButton.Visible then
                        local pos = confirmButton.AbsolutePosition
                        local size = confirmButton.AbsoluteSize
                        local x = pos.X + size.X / 2
                        local y = pos.Y + size.Y / 2 + 58
                        
                        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, Player, 0)
                        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, Player, 0)
                    end
                    task.wait(0.01)
                end
            end
        end
    end)
end

-- Gifting Tab Elements
Options.PlayerSelect = Tabs.Gifting:AddDropdown("PlayerSelect", {
    Title = "Select Player",
    Values = {},
    Multi = false,
    Default = "",
    Callback = function(Value)
        selectedPlayer = Value
    end
})

Tabs.Gifting:AddButton({
    Title = "Refresh Player List",
    Callback = UpdatePlayerList
})

Tabs.Gifting:AddToggle("AutoGift", {
    Title = "Auto Gift All Items",
    Default = false,
    Callback = function(Value)
        getgenv().giftloop = Value
        if Value then
            spawn(GiftAll)
        end
    end
})

Tabs.Gifting:AddButton({
    Title = "Gift Equipped Fish",
    Callback = TradeEquipped
})

Tabs.Gifting:AddToggle("AutoConfirm", {
    Title = "Auto Confirm Gifts",
    Default = false,
    Callback = function(Value)
        getgenv().autoconfirm = Value
        if Value then
            startAutoConfirm()
        end
    end
})

-- Player Events
Players.PlayerAdded:Connect(function(player)
    if player ~= Player then
        table.insert(currentPlayerList, player.Name)
        Options.PlayerSelect:SetValues(currentPlayerList)
        Fluent:Notify({
            Title = "Player Joined",
            Content = player.Name .. " joined!",
            Duration = 3
        })
    end
end)

Players.PlayerRemoving:Connect(function(player)
    for i, name in ipairs(currentPlayerList) do
        if name == player.Name then
            table.remove(currentPlayerList, i)
            Options.PlayerSelect:SetValues(currentPlayerList)
            Fluent:Notify({
                Title = "Player Left",
                Content = player.Name .. " left!",
                Duration = 3
            })
            break
        end
    end
end)

-- Initial Setup
UpdatePlayerList()