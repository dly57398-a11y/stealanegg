-- ==================================================
-- YOKUDO HUB | TABS MANAGER
-- ==================================================

local TweenService = game:GetService("TweenService")

local TabsManager = {}
TabsManager.Tabs = {}
TabsManager.Pages = {}
TabsManager.ActiveTab = nil
TabsManager.ActivePage = nil

-- ==================================================
-- REGISTER TAB
-- ==================================================
function TabsManager:RegisterTab(Name, Order, PageName)
    local Tab = CreateTab(Name, Order)
    local Page = CreatePage(PageName or Name:upper())
    
    table.insert(self.Tabs, { Tab = Tab, Page = Page, Name = Name })
    
    Tab.MouseButton1Click:Connect(function()
        self:SelectTab(Tab, Page)
    end)
    
    return Tab, Page
end

-- ==================================================
-- SELECT TAB
-- ==================================================
function TabsManager:SelectTab(SelectedTab, SelectedPage)
    for _, data in ipairs(self.Tabs) do
        data.Page.Visible = false
        local Indicator = data.Tab:FindFirstChild("Indicator")
        local TabText = data.Tab:FindFirstChild("TabText")
        TweenService:Create(data.Tab, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        if Indicator then
            TweenService:Create(Indicator, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
        if TabText then
            TweenService:Create(TabText, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(155, 155, 175)}):Play()
        end
    end

    SelectedPage.Visible = true
    task.wait(0.05)
    pcall(function()
        SelectedPage.CanvasPosition = Vector2.new(0, 0)
    end)

    TweenService:Create(SelectedTab, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    local Indicator = SelectedTab:FindFirstChild("Indicator")
    local TabText = SelectedTab:FindFirstChild("TabText")
    if Indicator then
        TweenService:Create(Indicator, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end
    if TabText then
        TweenService:Create(TabText, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end

    self.ActiveTab = SelectedTab
    self.ActivePage = SelectedPage
end

-- ==================================================
-- GET TAB BY NAME
-- ==================================================
function TabsManager:GetTab(Name)
    for _, data in ipairs(self.Tabs) do
        if data.Name == Name then
            return data.Tab, data.Page
        end
    end
    return nil, nil
end

-- ==================================================
-- SELECT TAB BY NAME
-- ==================================================
function TabsManager:SelectTabByName(Name)
    local Tab, Page = self:GetTab(Name)
    if Tab and Page then
        self:SelectTab(Tab, Page)
    end
end

-- ==================================================
-- EXPORT
-- ==================================================
_G.YOKUDO_TabsManager = TabsManager

print("✅ Tabs Manager Loaded")
