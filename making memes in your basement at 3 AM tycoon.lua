local GuiName = "made by stitch#8322 aka stitch lasagna"

for i, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == GuiName then 
        v:Destroy()
    end
end

local plr = game:GetService('Players').LocalPlayer
local char = plr.Character

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/GreenDeno/Venyx-UI-Library/main/source.lua"))()
local stitch = library.new(GuiName)

local themes = {
    Background = Color3.fromRGB(24, 24, 24),
    Glow = Color3.fromRGB(0, 0, 0),
    Accent = Color3.fromRGB(10, 10, 10),
    LightContrast = Color3.fromRGB(20, 20, 20),
    DarkContrast = Color3.fromRGB(14, 14, 14),
    TextColor = Color3.fromRGB(255, 255, 255)
}

tycoon = nil
local notified = false

while tycoon == nil and task.wait(.6) do
    for i, v  in pairs(workspace.Tycoons:GetChildren()) do
        if v:FindFirstChild("TycoonOwner") then
            if v.TycoonOwner.Value == plr.name then
                tycoon = workspace.Tycoons[tostring(v)]
                notified = true
            end
        end
    end
    
    if not notified then
        notified = true
        stitch:Notify("Notice", "Claim a tycoon first", function() notified = false end)
    end
end

local mainpage = stitch:addPage("Main", 5012544693)
local themepage = stitch:addPage("Theme", 5012544693)

local autofarmsection = mainpage:addSection("Autofarm")
local miscsection = mainpage:addSection("Misc")

local flags = {
    autoupload,
    instantupload,
    autopickup,
    autowakeup,
    autoupgrade = {enabled = false, advertiseOnly = false},
    autobuycheapestbutton
}

currentLevels = {
    Advertising = plr.Data.AdvertisingLevel.Value,
    UploadSpeed = plr.Data.UploadSpeedLevel.Value,
    HardDrive = plr.Data.HardDriveLevel.Value
}

local function cheapestUpgrade()
    plr.PlayerGui.PCGUI.Frame.Upgrades.Update:Fire();
    
    task.wait()

    local upgradeCost = require(game.ReplicatedStorage.UpgradeCosts).ReturnItemCost
    
    local cheapestName = nil
    local cheapestPrice = 9e9
    
    for i, v in pairs(currentLevels) do
        if plr.PlayerGui.PCGUI.Frame.Upgrades[tostring(i)].Cost.Text ~= "MAX LEVEL" then
            if upgradeCost(tostring(i), v)[2] < cheapestPrice then 
                cheapestPrice = upgradeCost(tostring(i), v)[2]
                cheapestName = tostring(i)
            end
        else currentLevels[i] = "max" end
    end
    
    return {cheapestName, cheapestPrice}
end
local function cheapestButton()
    local cheapestButtonCost = 9e9
    local cheapestButton = ''
    
    for i, v in pairs(tycoon.Purchases:GetChildren()) do
        if v:FindFirstChild("Cost") then
            if v.Cost.Value < cheapestButtonCost and v.Transparency == 0 then
                cheapestButtonCost = v.Cost.Value
                cheapestButton = v
            end
        end
    end
    return cheapestButton
end

smacking = false

local function autopickup()
    while flags.autopickup and task.wait() do
        for i = 1, 3 do
            local curBelt = tycoon.StaticItems["Belt"..i]
            
            if #tycoon.Drops["Belt"..i]:GetChildren() > 0 and not smacking and task.wait() then
                char.HumanoidRootPart.CFrame = curBelt.Collect.CollectPart.CFrame + Vector3.new(0, 2, 0)
                fireproximityprompt(curBelt.Collect.CollectPart.ProximityPrompt)
            end
        end
    end
    task.wait()
end
local function autoupload()
    while flags.autoupload and task.wait() do
        game.ReplicatedStorage.Events.MemeToStorage:FireServer();
    end
end
local function autowakeup()
    while flags.autowakeup and task.wait() do
        for i, v  in pairs(tycoon.Items:GetChildren()) do
            if v.Name ~= "Nas" and v.Sleeping.Value and task.wait() then
                smacking = true
                char.HumanoidRootPart.CFrame = v.Noob.HumanoidRootPart.CFrame + Vector3.new(0, 4, 0)
                fireproximityprompt(v.Noob.Torso.ProximityPrompt)
            end
            smacking = false
        end
    end
end
local function autoupgrade()
    local notified = false
    while flags.autoupgrade.enabled and task.wait(.4) do
        cu = cheapestUpgrade()[1]
        
        if cu == nil then
            stitch:Notify("Notice", "All upgrades are max level")
            break
        end
        
        cul = currentLevels[cu]
        
        if cu ~= "Advertising" and flags.autoupgrade.advertiseOnly == false then
            game.ReplicatedStorage.Events.UpgradeItem:FireServer(cu, cul)
        end
        
        if flags.autoupgrade.advertiseOnly and currentLevels["Advertising"] ~= "max" then
            game.ReplicatedStorage.Events.UpgradeItem:FireServer("Advertising", currentLevels.Advertising)
            
        elseif flags.autoupgrade.advertiseOnly and currentLevels["Advertising"] == "max" and notified == false then
            stitch:Notify("Notice", "Advertising upgrade is max level", function() 
                notified = false
            end)
            notified = true
        end
    end
end
local function autobuycheapestbutton()
    while flags.autobuycheapestbutton and task.wait() do
        local button = cheapestButton()
        
        if plr.Data.Coins.Value >= button.Cost.Value then
            firetouchinterest(char.HumanoidRootPart, button, 0)
            firetouchinterest(char.HumanoidRootPart, button, 1)
        end
    end
end

autofarmsection:addToggle("Auto Pickup Memes", false, function(value)
    flags.autopickup = value
    autopickup()
end)
autofarmsection:addToggle("Auto Upload Memes", false, function(value)
    flags.autoupload = value
    autoupload()
end)
autofarmsection:addToggle("Auto Wakeup Workers", false, function(value)
    flags.autowakeup = value
    autowakeup()
end)
autofarmsection:addToggle("Auto Upgrade Cheapest", false, function(value)
    flags.autoupgrade.enabled = value
    autoupgrade()
end)
autofarmsection:addToggle("Auto Buy Cheapest Button", false, function(value)
    flags.autobuycheapestbutton = value
    autobuycheapestbutton()
end)

local function instantupload()
    while flags.instantupload and task.wait() do
        game.ReplicatedStorage.Events.UploadCurrentMemes:FireServer();
    end
end

antiafkEnabled = false

miscsection:addToggle("Instantly Upload Memes", false, function(value)
    flags.instantupload = value
    instantupload()
end)
miscsection:addToggle("Only Auto Upgrade Advertising", false, function(value)
    flags.autoupgrade.advertiseOnly = value
end)
miscsection:addKeybind("Toggle Gui Keybind", Enum.KeyCode.One, function()
    stitch:toggle()
end)
miscsection:addSlider("Player WalkSpeed", char.Humanoid.WalkSpeed, 0, 150, function(v)
    char.Humanoid.WalkSpeed = v
end)
miscsection:addButton("Teleport To Tycoon", function() char.HumanoidRootPart.CFrame = tycoon.FollowerItems.Toilet.Seat.CFrame end)
miscsection:addButton("Anti Afk", function()
    if antiafkEnabled then
        stitch:Notify("Notice", "Anti Afk already enabled")
    else
        local idledEvent = plr.Idled
        local function disable()
            for _, cn in ipairs(getconnections(idledEvent)) do
                cn:Disable()
            end
        end
        
        oldConnect = hookfunction(idledEvent.Connect, function(self, ...)
            local cn = oldConnect(self, ...); disable()
            return cn
        end)
        
        namecall = hookmetamethod(game, "__namecall", function(self, ...)
            if self == idledEvent and getnamecallmethod() == "Connect" then
                local cn = oldConnect(self, ...); disable()
                return cn
            end
            return namecall(self, ...)
        end)
        
        disable()
        
        antiafkEnabled = true
    end
end)

local colors = themepage:addSection("Colors")

for theme, color in pairs(themes) do
    colors:addColorPicker(theme, color, function(color3)
        stitch:setTheme(theme, color3)
    end)
end

stitch:SelectPage(stitch.pages[1], true)  
