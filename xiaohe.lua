-- ============================================================
-- 小贺脚本 V9 · 飞行重写 + 防坠落精修 + 人物自转 + 透视修复
-- QQ交流群：1104880878
-- ============================================================
-- 说明：Roblox只能用Lua/Luau，不能用C++。防坠落我用更严谨的
-- 状态机逻辑重写，减少误判（跳跃保护期、自由落体检测、地面检测）。
-- ============================================================

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- 【魔幻开场动画】
-- ============================================================
local IntroGui = Instance.new("ScreenGui")
IntroGui.Name = "HeIntro"; IntroGui.IgnoreGuiInset = true
IntroGui.ResetOnSpawn = false; IntroGui.DisplayOrder = 9999
IntroGui.Parent = PlayerGui

local Bg = Instance.new("Frame")
Bg.Size = UDim2.fromScale(1,1); Bg.BackgroundColor3 = Color3.fromRGB(8,4,20)
Bg.BackgroundTransparency = 1; Bg.Parent = IntroGui

for i=1,80 do
    local s=Instance.new("Frame")
    s.Size=UDim2.fromOffset(math.random(1,3),math.random(1,3))
    s.Position=UDim2.fromScale(math.random(),math.random())
    s.BackgroundColor3=Color3.fromRGB(math.random(180,255),math.random(160,230),255)
    s.BackgroundTransparency=1; s.BorderSizePixel=0
    Instance.new("UICorner",s).CornerRadius=UDim.new(1,0)
    s.Parent=Bg
    task.spawn(function() task.wait(math.random(0,0.5))
        TweenService:Create(s,TweenInfo.new(0.4),{BackgroundTransparency=math.random(3,7)/10}):Play() end)
end

local Core=Instance.new("TextLabel")
Core.AnchorPoint=Vector2.new(0.5,0.5);Core.Position=UDim2.fromScale(0.5,0.4)
Core.Size=UDim2.fromOffset(120,120);Core.BackgroundTransparency=1
Core.Text="✦";Core.TextColor3=Color3.fromRGB(200,160,255);Core.TextSize=80
Core.Font=Enum.Font.GothamBold;Core.TextTransparency=1;Core.Parent=IntroGui

local function makeRing(size,color,thick)
    local r=Instance.new("Frame")
    r.AnchorPoint=Vector2.new(0.5,0.5);r.Position=UDim2.fromScale(0.5,0.4)
    r.Size=UDim2.fromOffset(size,size);r.BackgroundTransparency=1;r.Parent=IntroGui
    Instance.new("UICorner",r).CornerRadius=UDim.new(1,0)
    local s=Instance.new("UIStroke");s.Thickness=thick;s.Transparency=1;s.Color=color;s.Parent=r
    return r,s
end
local R1,S1=makeRing(100,Color3.fromRGB(140,180,255),2)
local R2,S2=makeRing(170,Color3.fromRGB(200,120,255),2)
local R3,S3=makeRing(240,Color3.fromRGB(255,120,200),1)

local Title=Instance.new("TextLabel")
Title.AnchorPoint=Vector2.new(0.5,0.5);Title.Position=UDim2.fromScale(0.5,0.56)
Title.Size=UDim2.fromOffset(400,50);Title.BackgroundTransparency=1;Title.Text=""
Title.TextColor3=Color3.new(1,1,1);Title.TextSize=34;Title.Font=Enum.Font.GothamBold;Title.Parent=IntroGui

local Sub=Instance.new("TextLabel")
Sub.AnchorPoint=Vector2.new(0.5,0.5);Sub.Position=UDim2.fromScale(0.5,0.62)
Sub.Size=UDim2.fromOffset(400,25);Sub.BackgroundTransparency=1;Sub.Text=""
Sub.TextColor3=Color3.fromRGB(180,160,255);Sub.TextSize=13;Sub.Font=Enum.Font.Code;Sub.Parent=IntroGui

local Pbg=Instance.new("Frame")
Pbg.AnchorPoint=Vector2.new(0.5,0.5);Pbg.Position=UDim2.fromScale(0.5,0.70)
Pbg.Size=UDim2.fromOffset(260,6);Pbg.BackgroundColor3=Color3.fromRGB(25,15,50)
Pbg.BackgroundTransparency=0.2;Pbg.Parent=IntroGui
Instance.new("UICorner",Pbg).CornerRadius=UDim.new(1,0)
local Pf=Instance.new("Frame")
Pf.Size=UDim2.new(0,0,1,0);Pf.BackgroundColor3=Color3.fromRGB(160,100,255);Pf.Parent=Pbg
Instance.new("UICorner",Pf).CornerRadius=UDim.new(1,0)
local Pt=Instance.new("TextLabel")
Pt.AnchorPoint=Vector2.new(0.5,0.5);Pt.Position=UDim2.fromScale(0.5,0.75)
Pt.Size=UDim2.fromOffset(200,20);Pt.BackgroundTransparency=1
Pt.Text="0%";Pt.TextColor3=Color3.fromRGB(180,160,255);Pt.TextSize=12;Pt.Font=Enum.Font.Code;Pt.Parent=IntroGui

local function tw(obj,text,speed) for i=1,#text do obj.Text=string.sub(text,1,i) task.wait(speed) end end

TweenService:Create(Bg,TweenInfo.new(0.5),{BackgroundTransparency=0}):Play()
task.wait(0.3)
TweenService:Create(Core,TweenInfo.new(0.8,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{TextTransparency=0,TextSize=100}):Play()
TweenService:Create(S1,TweenInfo.new(0.8),{Transparency=0}):Play()
TweenService:Create(S2,TweenInfo.new(0.8),{Transparency=0}):Play()
TweenService:Create(S3,TweenInfo.new(0.8),{Transparency=0.5}):Play()
task.wait(0.3)
tw(Title,"小贺脚本 V9",0.06)
task.wait(0.1)
tw(Sub,"SYSTEM LOADING...",0.04)

task.spawn(function() while IntroGui.Parent do R1.Rotation+=4;R2.Rotation-=3;R3.Rotation+=2;task.wait(0.02) end end)
task.spawn(function() while IntroGui.Parent do
    TweenService:Create(Core,TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{TextSize=110}):Play()
    task.wait(0.7)
    TweenService:Create(Core,TweenInfo.new(0.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{TextSize=95}):Play()
    task.wait(0.7)
end end)

for i=1,15 do
    task.spawn(function()
        local p=Instance.new("TextLabel")
        p.AnchorPoint=Vector2.new(0.5,0.5);p.Position=UDim2.fromScale(0.5,0.4)
        p.Size=UDim2.fromOffset(20,20);p.BackgroundTransparency=1;p.Text="✦"
        p.TextSize=math.random(8,18);p.TextColor3=Color3.fromRGB(math.random(150,255),math.random(100,200),255)
        p.Parent=IntroGui
        local a=math.rad(math.random(0,360));local d=math.random(100,280)
        TweenService:Create(p,TweenInfo.new(math.random(7,14)/10,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
            Position=UDim2.fromScale(0.5+math.cos(a)*d/1000,0.4+math.sin(a)*d/1000),
            TextTransparency=1,Rotation=math.random(-180,180)}):Play()
        game:GetService("Debris"):AddItem(p,1.5)
    end)
    task.wait(0.03)
end

for i=0,100,3 do
    Pf.Size=UDim2.new(i/100,0,1,0);Pt.Text=i.."%"
    task.wait(0.02)
end
Pt.Text="100% 完成"
task.wait(0.3)

local Flash=Instance.new("Frame")
Flash.Size=UDim2.fromScale(1,1);Flash.BackgroundColor3=Color3.fromRGB(200,160,255)
Flash.BackgroundTransparency=1;Flash.Parent=IntroGui
TweenService:Create(Flash,TweenInfo.new(0.2),{BackgroundTransparency=0}):Play()
task.wait(0.15)
TweenService:Create(Bg,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play()
TweenService:Create(Core,TweenInfo.new(0.5),{TextTransparency=1,TextSize=160}):Play()
TweenService:Create(S1,TweenInfo.new(0.5),{Transparency=1}):Play()
TweenService:Create(S2,TweenInfo.new(0.5),{Transparency=1}):Play()
TweenService:Create(S3,TweenInfo.new(0.5),{Transparency=1}):Play()
TweenService:Create(Title,TweenInfo.new(0.4),{TextTransparency=1}):Play()
TweenService:Create(Sub,TweenInfo.new(0.4),{TextTransparency=1}):Play()
TweenService:Create(Pbg,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
TweenService:Create(Pt,TweenInfo.new(0.4),{TextTransparency=1}):Play()
TweenService:Create(Flash,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
for _,s in ipairs(Bg:GetChildren()) do if s:IsA("Frame") then TweenService:Create(s,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play() end end
task.wait(0.6)
IntroGui:Destroy()

-- ============================================================
-- 反挂机
-- ============================================================
game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="反挂机已开启",Duration=3})
local vu=game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1);vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- ============================================================
-- 【横屏菜单 UI】
-- ============================================================
local MainGui=Instance.new("ScreenGui")
MainGui.Name="HeScriptUI";MainGui.IgnoreGuiInset=true;MainGui.ResetOnSpawn=false
MainGui.DisplayOrder=900;MainGui.Parent=PlayerGui

local COL={
    Bg=Color3.fromRGB(15,10,35), Bg2=Color3.fromRGB(25,18,50),
    Accent=Color3.fromRGB(160,100,255), Accent2=Color3.fromRGB(80,180,255),
    Text=Color3.fromRGB(240,235,255), TextDim=Color3.fromRGB(160,155,190),
    Button=Color3.fromRGB(30,22,55), ToggleOn=Color3.fromRGB(80,200,130),
    ToggleOff=Color3.fromRGB(55,48,80),
}

local FloatBtn=Instance.new("TextButton")
FloatBtn.Name="FloatBtn";FloatBtn.Size=UDim2.fromOffset(52,52)
FloatBtn.Position=UDim2.new(0,16,0.5,-26);FloatBtn.BackgroundColor3=COL.Accent
FloatBtn.Text="✦";FloatBtn.TextColor3=Color3.new(1,1,1)
FloatBtn.TextSize=26;FloatBtn.Font=Enum.Font.GothamBold
FloatBtn.AutoButtonColor=false;FloatBtn.Parent=MainGui
Instance.new("UICorner",FloatBtn).CornerRadius=UDim.new(1,0)
local FloatBorder=Instance.new("UIStroke")
FloatBorder.Thickness=2;FloatBorder.Color=COL.Accent2;FloatBorder.Transparency=0.4;FloatBorder.Parent=FloatBtn

task.spawn(function()
    while FloatBtn.Parent do
        TweenService:Create(FloatBtn,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundColor3=COL.Accent2}):Play()
        TweenService:Create(FloatBorder,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Color=COL.Accent}):Play()
        task.wait(1)
        TweenService:Create(FloatBtn,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundColor3=COL.Accent}):Play()
        TweenService:Create(FloatBorder,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Color=COL.Accent2}):Play()
        task.wait(1)
    end
end)

local Panel=Instance.new("Frame")
Panel.Name="Panel";Panel.AnchorPoint=Vector2.new(0.5,0.5)
Panel.Position=UDim2.new(0.5,0,0.5,0);Panel.Size=UDim2.new(0,620,0,400)
Panel.BackgroundColor3=COL.Bg;Panel.BackgroundTransparency=1
Panel.Visible=false;Panel.Parent=MainGui
Instance.new("UICorner",Panel).CornerRadius=UDim.new(0,16)
local PanelBorder=Instance.new("UIStroke")
PanelBorder.Thickness=2;PanelBorder.Color=COL.Accent;PanelBorder.Transparency=0.5;PanelBorder.Parent=Panel

local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,44);Header.BackgroundColor3=COL.Bg2;Header.Parent=Panel
Instance.new("UICorner",Header).CornerRadius=UDim.new(0,16)

local HeaderTitle=Instance.new("TextLabel")
HeaderTitle.Size=UDim2.new(1,-100,1,0);HeaderTitle.Position=UDim2.new(0,16,0,0)
HeaderTitle.BackgroundTransparency=1;HeaderTitle.Text="✦ 小贺脚本 V9"
HeaderTitle.TextColor3=COL.Text;HeaderTitle.TextSize=16;HeaderTitle.Font=Enum.Font.GothamBold
HeaderTitle.TextXAlignment=Enum.TextXAlignment.Left;HeaderTitle.ZIndex=2;HeaderTitle.Parent=Header

local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.fromOffset(36,36);CloseBtn.Position=UDim2.new(1,-42,0,4)
CloseBtn.BackgroundColor3=COL.Button;CloseBtn.Text="✕";CloseBtn.TextColor3=COL.TextDim
CloseBtn.TextSize=14;CloseBtn.AutoButtonColor=false;CloseBtn.Parent=Header
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(1,0)

local TabBar=Instance.new("Frame")
TabBar.Size=UDim2.new(0,110,1,-52);TabBar.Position=UDim2.new(0,8,0,50)
TabBar.BackgroundColor3=COL.Bg2;TabBar.BackgroundTransparency=0.3;TabBar.Parent=Panel
Instance.new("UICorner",TabBar).CornerRadius=UDim.new(0,10)
local TabList=Instance.new("UIListLayout")
TabList.Padding=UDim.new(0,6);TabList.SortOrder=Enum.SortOrder.LayoutOrder;TabList.Parent=TabBar
local TabPad=Instance.new("UIPadding")
TabPad.PaddingTop=UDim.new(0,8);TabPad.PaddingLeft=UDim.new(0,6);TabPad.PaddingRight=UDim.new(0,6);TabPad.Parent=TabBar

local Content=Instance.new("ScrollingFrame")
Content.Size=UDim2.new(1,-130,1,-52);Content.Position=UDim2.new(0,122,0,50)
Content.BackgroundTransparency=1;Content.BorderSizePixel=0
Content.ScrollBarThickness=6;Content.ScrollBarImageColor3=COL.Accent
Content.CanvasSize=UDim2.new(0,0,0,0);Content.AutomaticCanvasSize=Enum.AutomaticSize.Y;Content.Parent=Panel

local Tabs={};local TabBtns={};CurrentTab=nil
local function createTab(name)
    local c=Instance.new("Frame")
    c.Name=name;c.Size=UDim2.new(1,0,0,0);c.BackgroundTransparency=1
    c.AutomaticSize=Enum.AutomaticSize.Y;c.Visible=false;c.Parent=Content
    local ll=Instance.new("UIListLayout");ll.Padding=UDim.new(0,6);ll.SortOrder=Enum.SortOrder.LayoutOrder;ll.Parent=c
    local pad=Instance.new("UIPadding");pad.PaddingTop=UDim.new(0,4);pad.PaddingBottom=UDim.new(0,10);pad.PaddingRight=UDim.new(0,4);pad.Parent=c
    Tabs[name]=c;return c
end
local function switchTab(name)
    for n,t in pairs(Tabs) do t.Visible=(n==name) end
    for n,b in pairs(TabBtns) do
        if n==name then b.BackgroundColor3=COL.Accent;b.TextColor3=Color3.new(1,1,1)
        else b.BackgroundColor3=COL.Button;b.TextColor3=COL.TextDim end
    end
    CurrentTab=name
end
local function addTabBtn(name,idx)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,40);b.BackgroundColor3=COL.Button
    b.Text=name;b.TextColor3=COL.TextDim;b.TextSize=13
    b.Font=Enum.Font.GothamBold;b.AutoButtonColor=false;b.LayoutOrder=idx;b.Parent=TabBar
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    b.MouseButton1Click:Connect(function() switchTab(name) end)
    TabBtns[name]=b;return b
end

local function addLabel(c,text)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,0,22);l.BackgroundTransparency=1
    l.Text=text;l.TextColor3=COL.TextDim;l.TextSize=12
    l.Font=Enum.Font.Gotham;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=c
    return l
end
local function addPara(c,title,text)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,46);f.BackgroundColor3=COL.Bg2;f.Parent=c
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
    local t=Instance.new("TextLabel");t.Size=UDim2.new(1,-12,0,18);t.Position=UDim2.new(0,10,0,5)
    t.BackgroundTransparency=1;t.Text=title;t.TextColor3=COL.Accent;t.TextSize=13
    t.Font=Enum.Font.GothamBold;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=f
    local d=Instance.new("TextLabel");d.Size=UDim2.new(1,-12,0,18);d.Position=UDim2.new(0,10,0,24)
    d.BackgroundTransparency=1;d.Text=text;d.TextColor3=COL.Text;d.TextSize=12
    d.Font=Enum.Font.Gotham;d.TextXAlignment=Enum.TextXAlignment.Left;d.Parent=f
    return f
end
local function addBtn(c,name,cb)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,40);b.BackgroundColor3=COL.Button
    b.Text="  "..name;b.TextColor3=COL.Text;b.TextSize=13
    b.Font=Enum.Font.Gotham;b.TextXAlignment=Enum.TextXAlignment.Left;b.AutoButtonColor=false;b.Parent=c
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
    b.MouseButton1Click:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=COL.Accent}):Play()
        task.wait(0.1);TweenService:Create(b,TweenInfo.new(0.2),{BackgroundColor3=COL.Button}):Play()
        cb()
    end)
    return b
end
local function addToggle(c,name,default,cb)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,40);f.BackgroundColor3=COL.Button;f.Parent=c
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
    local l=Instance.new("TextLabel");l.Size=UDim2.new(1,-60,1,0);l.Position=UDim2.new(0,12,0,0)
    l.BackgroundTransparency=1;l.Text=name;l.TextColor3=COL.Text;l.TextSize=13
    l.Font=Enum.Font.Gotham;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=f
    local t=Instance.new("TextButton");t.Size=UDim2.fromOffset(44,22);t.Position=UDim2.new(1,-52,0,9)
    t.BackgroundColor3=default and COL.ToggleOn or COL.ToggleOff;t.Text="";t.AutoButtonColor=false;t.Parent=f
    Instance.new("UICorner",t).CornerRadius=UDim.new(1,0)
    local k=Instance.new("Frame");k.Size=UDim2.fromOffset(16,16)
    k.Position=default and UDim2.new(1,-19,0,3) or UDim2.new(0,3,0,3)
    k.BackgroundColor3=Color3.new(1,1,1);k.BorderSizePixel=0;k.Parent=t
    Instance.new("UICorner",k).CornerRadius=UDim.new(1,0)
    local state=default
    t.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(t,TweenInfo.new(0.2),{BackgroundColor3=state and COL.ToggleOn or COL.ToggleOff}):Play()
        TweenService:Create(k,TweenInfo.new(0.2),{Position=state and UDim2.new(1,-19,0,3) or UDim2.new(0,3,0,3)}):Play()
        cb(state)
    end)
    return f
end
local function addSlider(c,name,min,max,default,cb)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,50);f.BackgroundColor3=COL.Button;f.Parent=c
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
    local l=Instance.new("TextLabel");l.Size=UDim2.new(1,-12,0,16);l.Position=UDim2.new(0,10,0,5)
    l.BackgroundTransparency=1;l.Text=name.." : "..default;l.TextColor3=COL.Text;l.TextSize=12
    l.Font=Enum.Font.Gotham;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=f
    local bar=Instance.new("Frame");bar.Size=UDim2.new(1,-20,0,6);bar.Position=UDim2.new(0,10,0,30)
    bar.BackgroundColor3=Color3.fromRGB(15,10,35);bar.Parent=f
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame");fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3=COL.Accent;fill.Parent=bar
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton");btn.Size=UDim2.new(1,0,1,0);btn.BackgroundTransparency=1;btn.Text="";btn.Parent=bar
    local dragging=false
    btn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
            local p=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            fill.Size=UDim2.new(p,0,1,0)
            local val=math.floor(min+p*(max-min))
            l.Text=name.." : "..val
            cb(val)
        end
    end)
    return f
end

-- 玩家选择器
local function selectPlayer(cb, title)
    local plrs = Players:GetPlayers()
    local others = {}
    for _, p in ipairs(plrs) do
        if p ~= LocalPlayer then table.insert(others, p) end
    end
    if #others == 0 then
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="服务器里没有其他玩家",Duration=3})
        return
    end
    local selGui = Instance.new("ScreenGui")
    selGui.Name = "PlayerSelect"; selGui.IgnoreGuiInset = true
    selGui.DisplayOrder = 9998; selGui.Parent = PlayerGui
    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1,1); bg.BackgroundColor3 = Color3.new(0,0,0)
    bg.BackgroundTransparency = 0.5; bg.Parent = selGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,300,0,400); frame.Position = UDim2.new(0.5,-150,0.5,-200)
    frame.BackgroundColor3 = COL.Bg; frame.Parent = selGui
    Instance.new("UICorner",frame).CornerRadius = UDim.new(0,14)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,0,0,40); t.BackgroundTransparency = 1
    t.Text = (title or "选择玩家").." ("..#others.."人)"
    t.TextColor3 = COL.Text; t.TextSize = 16; t.Font = Enum.Font.GothamBold; t.Parent = frame
    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(32,32); close.Position = UDim2.new(1,-36,0,4)
    close.BackgroundTransparency = 1; close.Text = "✕"; close.TextColor3 = COL.TextDim; close.Parent = frame
    close.MouseButton1Click:Connect(function() selGui:Destroy() end)
    bg.MouseButton1Click:Connect(function() selGui:Destroy() end)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,-16,1,-52); scroll.Position = UDim2.new(0,8,0,44)
    scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4; scroll.ScrollBarImageColor3 = COL.Accent
    scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = frame
    local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0,5); ll.Parent = scroll
    for _, p in ipairs(others) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,42); b.BackgroundColor3 = COL.Button
        local displayName = p.Name
        if p.Team then displayName = displayName .. "  [" .. p.Team.Name .. "]" end
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local theirRoot = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and theirRoot then
            local dist = (theirRoot.Position - myRoot.Position).Magnitude
            displayName = displayName .. string.format("  %.0fm", dist)
        end
        b.Text = "  " .. displayName
        b.TextColor3 = p.Team and p.Team.TeamColor.Color or COL.Text
        b.TextSize = 13; b.Font = Enum.Font.Gotham
        b.TextXAlignment = Enum.TextXAlignment.Left; b.Parent = scroll
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
        if p.Team then
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0,4,1,-8); bar.Position = UDim2.new(0,4,0,4)
            bar.BackgroundColor3 = p.Team.TeamColor.Color; bar.BorderSizePixel = 0; bar.Parent = b
        end
        b.MouseButton1Click:Connect(function()
            selGui:Destroy()
            if p and p.Parent then cb(p)
            else game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="目标已离开",Duration=2}) end
        end)
    end
end

-- 面板开关
local panelOpen=false
local function openPanel()
    panelOpen=true;FloatBtn.Visible=false;Panel.Visible=true
    Panel.BackgroundTransparency=1;PanelBorder.Transparency=1
    TweenService:Create(Panel,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play()
    TweenService:Create(PanelBorder,TweenInfo.new(0.3),{Transparency=0.4}):Play()
end
local function closePanel()
    panelOpen=false
    TweenService:Create(Panel,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
    TweenService:Create(PanelBorder,TweenInfo.new(0.25),{Transparency=1}):Play()
    task.wait(0.25);Panel.Visible=false;FloatBtn.Visible=true
end
FloatBtn.MouseButton1Click:Connect(function() if panelOpen then closePanel() else openPanel() end end)
CloseBtn.MouseButton1Click:Connect(closePanel)

local dragging=false;local dragStart=nil;local startPos=nil;local dragTarget=nil
FloatBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;dragStart=i.Position;startPos=FloatBtn.Position;dragTarget=FloatBtn end end)
Header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;dragStart=i.Position;startPos=Panel.Position;dragTarget=Panel end end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
        local d=i.Position-dragStart
        dragTarget.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

-- ============================================================
-- 【核心工具函数】
-- ============================================================
local function getChar() return LocalPlayer.Character end
local function getHum() local c=getChar();return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c=getChar();return c and c:FindFirstChild("HumanoidRootPart") end

-- ============================================================
-- 【飞行 V9 · 基于手机控制中心架构重写】
-- 原理：BodyVelocity控制速度 + BodyGyro保持姿态
-- 摇杆控制水平移动，视角控制上下
-- ============================================================
local flySpeed = 60
local flying = false
local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil
local flyDiedConn = nil

local function startFly()
    local hum = getHum(); local root = getRoot()
    if not hum or not root then
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="等待角色加载...",Duration=2})
        return false
    end

    flying = true
    hum.PlatformStand = false
    hum.GravityScale = 0
    hum.JumpPower = 0

    -- BodyVelocity
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyBodyVelocity"
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.P = 12000
    bodyVelocity.Parent = root

    -- BodyGyro 保持姿态
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "FlyBodyGyro"
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    -- 死亡自动关闭
    flyDiedConn = hum.Died:Connect(function() stopFly() end)

    -- 主循环
    flyConnection = RunService.Heartbeat:Connect(function()
        local h = getHum(); local r = getRoot()
        if not h or not r or not bodyVelocity or not bodyGyro then return end

        local cam = workspace.CurrentCamera
        local moveDir = h.MoveDirection
        local vel = Vector3.new(0,0,0)

        -- 摇杆水平移动
        if moveDir.Magnitude > 0.1 then
            vel = moveDir * flySpeed
        end

        -- 视角控制上下
        local camY = cam.CFrame.LookVector.Y
        if math.abs(camY) > 0.08 then
            vel = vel + Vector3.new(0, camY * flySpeed * 1.2, 0)
        end

        bodyVelocity.Velocity = vel

        -- 保持角色朝向相机水平方向
        local lookDir = cam.CFrame.LookVector * Vector3.new(1,0,1)
        if lookDir.Magnitude > 0.01 then
            bodyGyro.CFrame = CFrame.new(r.Position, r.Position + lookDir)
        end
    end)

    game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="✈ 飞行已开启（视角上下控制升降）",Duration=3})
    return true
end

local function stopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyDiedConn then flyDiedConn:Disconnect(); flyDiedConn = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    local hum = getHum()
    if hum then
        hum.PlatformStand = false
        hum.GravityScale = 1
        hum.JumpPower = 50
    end
end

local function setFly(v)
    if v then startFly() else stopFly() end
end

-- ============================================================
-- 【防坠落 V9 · 状态机精修版】
-- 减少误判：跳跃保护期 + 自由落体状态检测 + 地面检测 + 下落距离
-- ============================================================
local antiFallEnabled = false
local antiFallConn = nil
local lastSafeCFrame = nil
local jumpProtectTime = 0  -- 跳跃后保护期时间戳
local fallStartTime = nil  -- 开始下落的时间戳
local FALL_THRESHOLD = -90  -- 下落速度阈值
local FALL_DISTANCE = 15   -- 下落距离阈值（格）
local JUMP_PROTECT = 0.6   -- 跳跃保护期（秒）
local FALL_CONFIRM = 0.4   -- 持续下落确认时间（秒）

local function setAntiFall(v)
    antiFallEnabled = v
    if v then
        -- 记录初始安全位置
        local root = getRoot()
        if root then lastSafeCFrame = root.CFrame end

        -- 跳跃时记录保护期
        local jumpConn
        jumpConn = UserInputService.JumpRequest:Connect(function()
            jumpProtectTime = tick()
        end)

        antiFallConn = RunService.Heartbeat:Connect(function()
            if flying then return end  -- 飞行中不触发
            local root = getRoot(); local hum = getHum()
            if not root or not hum then return end

            local vel = root.AssemblyLinearVelocity
            local onGround = hum.FloorMaterial ~= Enum.Material.Air
            local now = tick()

            -- 在地面上且速度低 → 更新安全位置
            if onGround and vel.Magnitude < 30 then
                lastSafeCFrame = root.CFrame
                fallStartTime = nil
                return
            end

            -- 跳跃保护期内不触发
            if now - jumpProtectTime < JUMP_PROTECT then
                fallStartTime = nil
                return
            end

            -- 检测自由落体状态
            local isFreeFalling = hum:GetState() == Enum.HumanoidStateType.FreeFall

            -- 高速下落确认
            if vel.Y < FALL_THRESHOLD and isFreeFalling then
                if not fallStartTime then
                    fallStartTime = now
                elseif now - fallStartTime > FALL_CONFIRM then
                    -- 确认是危险坠落，拉回安全位置
                    if lastSafeCFrame then
                        root.CFrame = lastSafeCFrame
                        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        root.AssemblyAngularVelocity = Vector3.new(0,0,0)
                        fallStartTime = nil
                        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="🛡 防坠落已触发",Duration=2})
                    end
                end
            else
                fallStartTime = nil
            end
        end)

        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="🛡 防坠落已开启",Duration=2})
    else
        if antiFallConn then antiFallConn:Disconnect(); antiFallConn = nil end
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="防坠落已关闭",Duration=2})
    end
end

-- ============================================================
-- 【人物自转 V9 · 新功能】
-- 角色持续旋转，别人可见，自己视角和移动不受影响
-- ============================================================
local spinEnabled = false
local spinConn = nil
local spinSpeed = 2  -- 每帧旋转弧度

local function setSpin(v)
    spinEnabled = v
    if v then
        spinConn = RunService.Heartbeat:Connect(function()
            local root = getRoot()
            if not root then return end
            if flying then return end  -- 飞行时不旋转（飞行已有姿态控制）
            -- 绕Y轴旋转，不影响位置和移动
            root.CFrame = root.CFrame * CFrame.Angles(0, spinSpeed * 0.03, 0)
        end)
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="🔄 人物自转已开启",Duration=2})
    else
        if spinConn then spinConn:Disconnect(); spinConn = nil end
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="人物自转已关闭",Duration=2})
    end
end

-- ============================================================
-- 【无限跳】
-- ============================================================
local ijConn=nil
local function setInfiniteJump(v)
    if v then
        ijConn=UserInputService.JumpRequest:Connect(function()
            local h=getHum();if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if ijConn then ijConn:Disconnect();ijConn=nil end
    end
end

-- ============================================================
-- 【穿墙】
-- ============================================================
local ncConn=nil
local function setNoclip(v)
    if v then
        ncConn=RunService.Stepped:Connect(function()
            local c=getChar();if not c then return end
            for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    else
        if ncConn then ncConn:Disconnect();ncConn=nil end
        local c=getChar();if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.CanCollide=true end end end
    end
end

-- ============================================================
-- 【ESP 透视 V9 · 修复版】
-- 修复：改用PlayerGui（更稳定）+ Highlight保底 + 2D方框可选
-- 某些服务器CoreGui被限制，改用PlayerGui
-- ============================================================
local espEnabled = false
local espBoxEnabled = true
local espTracerEnabled = true
local espInfoEnabled = true
local espHealthEnabled = true
local espTeamCheckEnabled = false

local espGui = nil
local espRenderConn = nil
local espHighlightFolder = nil  -- Highlight保底方案

local function createEspGui()
    local g = Instance.new("ScreenGui")
    g.Name = "ESP_V9"; g.IgnoreGuiInset = true
    g.ResetOnSpawn = false; g.DisplayOrder = 800
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    g.Parent = PlayerGui  -- 改用PlayerGui，比CoreGui更稳定
    return g
end

local function isTeammate(plr)
    if not espTeamCheckEnabled then return false end
    if not plr.Team or not LocalPlayer.Team then return false end
    return plr.Team == LocalPlayer.Team
end

local function getCharacterBox(char)
    local cam = workspace.CurrentCamera
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root then return nil end
    local topPart = head or root
    local bottomPos = root.Position - Vector3.new(0, 3, 0)
    local topPos = topPart.Position + Vector3.new(0, 1.5, 0)
    local bottomScreen, onScreen1 = cam:WorldToViewportPoint(bottomPos)
    local topScreen, onScreen2 = cam:WorldToViewportPoint(topPos)
    if not onScreen1 and not onScreen2 then return nil end
    if bottomScreen.Z <= 0 or topScreen.Z <= 0 then return nil end
    local height = math.abs(bottomScreen.Y - topScreen.Y)
    if height < 5 then return nil end  -- 太小不显示
    local width = height * 0.55
    local centerX = (bottomScreen.X + topScreen.X) / 2
    local centerY = (bottomScreen.Y + topScreen.Y) / 2
    return {
        x = centerX - width / 2, y = centerY - height / 2,
        w = width, h = height,
        centerX = centerX, centerY = centerY,
        bottomY = bottomScreen.Y, onScreen = onScreen1 or onScreen2,
    }
end

local function drawLine(parent, x1, y1, x2, y2, color, thickness)
    local len = math.sqrt((x2-x1)^2 + (y2-y1)^2)
    if len < 1 then return nil end
    local angle = math.atan2(y2-y1, x2-x1)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, len, 0, thickness or 1)
    frame.Position = UDim2.new(0, x1, 0, y1)
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.3
    frame.Rotation = math.deg(angle)
    frame.AnchorPoint = Vector2.new(0, 0.5)
    frame.Parent = parent
    return frame
end

local function renderESP()
    if not espGui then return end
    -- 清理2D元素
    for _, child in ipairs(espGui:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
    local cam = workspace.CurrentCamera
    local myRoot = getRoot()
    if not myRoot then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if isTeammate(plr) then continue end

        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then continue end

        -- Highlight保底（始终显示，确保某些服务器也能看到）
        if espHighlightFolder and not espHighlightFolder:FindFirstChild(plr.Name) then
            local hl = Instance.new("Highlight")
            hl.Name = plr.Name
            hl.FillColor = Color3.fromRGB(180, 80, 255)
            hl.FillTransparency = 0.7
            hl.OutlineColor = Color3.fromRGB(255, 80, 80)
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = char
            hl.Parent = espHighlightFolder
        end

        local box = getCharacterBox(char)
        if not box or not box.onScreen then continue end

        local dist = (root.Position - myRoot.Position).Magnitude
        local healthPct = hum.Health / hum.MaxHealth

        local boxColor
        if plr.Team and LocalPlayer.Team and plr.Team ~= LocalPlayer.Team then
            boxColor = Color3.fromRGB(255, 80, 80)
        else
            boxColor = Color3.fromRGB(180, 100, 255)
        end

        -- 方框
        if espBoxEnabled then
            local bx = Instance.new("Frame")
            bx.Size = UDim2.new(0, box.w, 0, box.h)
            bx.Position = UDim2.new(0, box.x, 0, box.y)
            bx.BackgroundTransparency = 1; bx.BorderSizePixel = 0; bx.Parent = espGui
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1.5; stroke.Color = boxColor; stroke.Transparency = 0.1; stroke.Parent = bx
            local cornerSize = math.min(box.w, box.h) * 0.15
            local corners = {
                {box.x, box.y}, {box.x + box.w - cornerSize, box.y},
                {box.x, box.y + box.h - cornerSize}, {box.x + box.w - cornerSize, box.y + box.h - cornerSize},
            }
            for _, c in ipairs(corners) do
                local cf = Instance.new("Frame")
                cf.Size = UDim2.new(0, cornerSize, 0, cornerSize)
                cf.Position = UDim2.new(0, c[1], 0, c[2])
                cf.BackgroundColor3 = boxColor; cf.BorderSizePixel = 0
                cf.BackgroundTransparency = 0.5; cf.Parent = espGui
            end
        end

        -- 射线
        if espTracerEnabled then
            drawLine(espGui,
                cam.ViewportSize.X / 2, cam.ViewportSize.Y,
                box.centerX, box.y + box.h,
                boxColor, 1)
        end

        -- 信息
        if espInfoEnabled then
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0, box.w + 40, 0, 16)
            nameLabel.Position = UDim2.new(0, box.x - 20, 0, box.y - 18)
            nameLabel.BackgroundTransparency = 1
            local teamTag = plr.Team and "["..plr.Team.Name.."]" or ""
            nameLabel.Text = plr.Name .. teamTag .. "  [" .. string.format("%.0fm", dist) .. "]"
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.TextSize = 12; nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextStrokeTransparency = 0.5; nameLabel.Parent = espGui
        end

        -- 血量
        if espHealthEnabled then
            local hpBg = Instance.new("Frame")
            hpBg.Size = UDim2.new(0, 5, 0, box.h)
            hpBg.Position = UDim2.new(0, box.x - 10, 0, box.y)
            hpBg.BackgroundColor3 = Color3.fromRGB(30,30,30)
            hpBg.BorderSizePixel = 0; hpBg.BackgroundTransparency = 0.3; hpBg.Parent = espGui
            local hpFill = Instance.new("Frame")
            hpFill.Size = UDim2.new(1, 0, healthPct, 0)
            hpFill.Position = UDim2.new(0, 0, 1 - healthPct, 0)
            hpFill.BackgroundColor3 = healthPct > 0.5 and Color3.fromRGB(80,220,80)
                or healthPct > 0.25 and Color3.fromRGB(220,200,60)
                or Color3.fromRGB(220,60,60)
            hpFill.BorderSizePixel = 0; hpFill.Parent = hpBg
            local hpText = Instance.new("TextLabel")
            hpText.Size = UDim2.new(0, 40, 0, 12)
            hpText.Position = UDim2.new(0, box.x - 32, 0, box.y + box.h / 2 - 6)
            hpText.BackgroundTransparency = 1
            hpText.Text = string.format("%d", math.floor(hum.Health))
            hpText.TextColor3 = Color3.new(1,1,1); hpText.TextSize = 10
            hpText.Font = Enum.Font.Code; hpText.TextStrokeTransparency = 0.6; hpText.Parent = espGui
        end
    end
end

local function setESP(v)
    espEnabled = v
    if v then
        if not espGui then espGui = createEspGui() end
        if not espHighlightFolder then
            espHighlightFolder = Instance.new("Folder")
            espHighlightFolder.Name = "ESP_Highlights"
            espHighlightFolder.Parent = game:GetService("CoreGui")
        end
        if not espRenderConn then
            espRenderConn = RunService.RenderStepped:Connect(renderESP)
        end
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="透视已开启",Duration=2})
    else
        if espRenderConn then espRenderConn:Disconnect(); espRenderConn = nil end
        if espGui then espGui:Destroy(); espGui = nil end
        if espHighlightFolder then espHighlightFolder:Destroy(); espHighlightFolder = nil end
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="透视已关闭",Duration=2})
    end
end

-- ============================================================
-- 【甩飞玩家】
-- ============================================================
local function flingPlayer(plr)
    local myRoot=getRoot()
    if not myRoot then
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="角色未加载",Duration=2});return
    end
    local targetChar=plr.Character
    if not targetChar then
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="目标未加载",Duration=2});return
    end
    local targetRoot=targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="找不到目标",Duration=2});return
    end
    local targetPos=targetRoot.Position

    for i=1,8 do
        task.spawn(function()
            local part=Instance.new("Part")
            part.Size=Vector3.new(6,6,6)
            part.CanCollide=true;part.CanTouch=true;part.CanQuery=true
            part.Massless=false
            part.CustomPhysicalProperties=PhysicalProperties.new(100,0,0,100,100)
            part.Transparency=0.7;part.Color=Color3.fromRGB(255,80,80)
            part.Material=Enum.Material.Neon;part.Parent=workspace
            local angle=(i/8)*math.pi*2
            local startPos=targetPos+Vector3.new(math.cos(angle)*12,math.random(2,6),math.sin(angle)*12)
            part.Position=startPos
            local dir=(targetPos-startPos).Unit
            part.AssemblyLinearVelocity=dir*2500
            part.AssemblyAngularVelocity=Vector3.new(math.random(-800,800),math.random(-800,800),math.random(-800,800))
            game:GetService("Debris"):AddItem(part,2)
        end)
        task.wait(0.03)
    end

    task.delay(0.15,function()
        for i=1,3 do
            task.spawn(function()
                local part=Instance.new("Part")
                part.Size=Vector3.new(10,10,10)
                part.CanCollide=true;part.CanTouch=true;part.Massless=false
                part.CustomPhysicalProperties=PhysicalProperties.new(100,0,0,100,100)
                part.Transparency=0.6;part.Color=Color3.fromRGB(255,200,80)
                part.Material=Enum.Material.Neon;part.Parent=workspace
                local angle=math.random(0,math.pi*2)
                local startPos=targetPos+Vector3.new(math.cos(angle)*18,math.random(3,8),math.sin(angle)*18)
                part.Position=startPos
                local dir=(targetPos-startPos).Unit+Vector3.new(0,1.5,0)
                part.AssemblyLinearVelocity=dir.Unit*3000
                game:GetService("Debris"):AddItem(part,1.5)
            end)
            task.wait(0.04)
        end
        if targetRoot and targetRoot.Parent then
            targetRoot.AssemblyLinearVelocity=Vector3.new(math.random(-900,900),1200,math.random(-900,900))
            targetRoot.AssemblyAngularVelocity=Vector3.new(math.random(-600,600),math.random(-600,600),math.random(-600,600))
        end
    end)

    game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="💥 已甩飞 "..plr.Name,Duration=3})
end

-- ============================================================
-- 【传送玩家】
-- ============================================================
local function teleportToPlayer(plr)
    local myRoot=getRoot()
    if not myRoot then
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="角色未加载",Duration=2});return
    end
    if not plr.Character then
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="目标未加载",Duration=2});return
    end
    local targetRoot=plr.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="找不到目标位置",Duration=2});return
    end
    local wasFlying=flying
    if wasFlying and bodyVelocity then bodyVelocity.Velocity=Vector3.new(0,0,0) end
    myRoot.CFrame=targetRoot.CFrame*CFrame.new(0,3,0)
    myRoot.AssemblyLinearVelocity=Vector3.new(0,0,0)
    game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="已传送到 "..plr.Name,Duration=2})
end

-- ============================================================
-- 【防甩飞】
-- ============================================================
local antiFlyConn=nil
local antiFlyFrozen=false
local function setAntiFly(v)
    if v then
        antiFlyConn=RunService.Heartbeat:Connect(function()
            if flying then return end
            local root=getRoot();local hum=getHum()
            if not root or not hum then return end
            local vel=root.AssemblyLinearVelocity
            local angVel=root.AssemblyAngularVelocity
            local speed=vel.Magnitude
            local angSpeed=angVel.Magnitude
            local isFlinging=speed>150 or angSpeed>30 or vel.Y>200
            if isFlinging and not antiFlyFrozen then
                antiFlyFrozen=true
                root.AssemblyLinearVelocity=Vector3.new(0,0,0)
                root.AssemblyAngularVelocity=Vector3.new(0,0,0)
                root.Anchored=true
                hum.PlatformStand=true
                task.delay(0.35,function()
                    local r=getRoot();local h=getHum()
                    if r and h and antiFlyConn then
                        r.Anchored=false;h.PlatformStand=false;antiFlyFrozen=false
                    end
                end)
            end
            if speed>80 and speed<=150 and not antiFlyFrozen then
                root.AssemblyLinearVelocity=vel*0.3
            end
            if angSpeed>10 and angSpeed<=30 and not antiFlyFrozen then
                root.AssemblyAngularVelocity=angVel*0.3
            end
        end)
    else
        if antiFlyConn then antiFlyConn:Disconnect();antiFlyConn=nil end
        antiFlyFrozen=false
        local r=getRoot();local h=getHum()
        if r then r.Anchored=false end
        if h then h.PlatformStand=false end
    end
end

-- ============================================================
-- 【FPS显示】
-- ============================================================
local fpsLabel=nil;local fpsConn=nil
local function setFPS(v)
    if v then
        fpsLabel=Instance.new("TextLabel")
        fpsLabel.Size=UDim2.fromOffset(90,28);fpsLabel.Position=UDim2.new(1,-100,0,60)
        fpsLabel.BackgroundColor3=COL.Bg;fpsLabel.BackgroundTransparency=0.4
        fpsLabel.Text="FPS: 0";fpsLabel.TextColor3=Color3.fromRGB(120,255,170)
        fpsLabel.TextSize=13;fpsLabel.Font=Enum.Font.Code;fpsLabel.Parent=MainGui
        Instance.new("UICorner",fpsLabel).CornerRadius=UDim.new(0,7)
        local last=tick();local frames=0
        fpsConn=RunService.RenderStepped:Connect(function()
            frames+=1
            if tick()-last>=1 then fpsLabel.Text="FPS: "..frames;frames=0;last=tick() end
        end)
    else
        if fpsLabel then fpsLabel:Destroy();fpsLabel=nil end
        if fpsConn then fpsConn:Disconnect();fpsConn=nil end
    end
end

-- ============================================================
-- 【全亮夜视】
-- ============================================================
local function setFullBright(v)
    if v then
        game.Lighting.Ambient=Color3.new(1,1,1)
        game.Lighting.OutdoorAmbient=Color3.new(1,1,1)
        game.Lighting.Brightness=3
        game.Lighting.GlobalShadows=false
    else
        game.Lighting.Ambient=Color3.new(0,0,0)
        game.Lighting.OutdoorAmbient=Color3.fromRGB(70,70,70)
        game.Lighting.Brightness=1
        game.Lighting.GlobalShadows=true
    end
end

-- ============================================================
-- 【无坠落伤害】
-- ============================================================
local nfConn=nil
local function setNoFall(v)
    if v then
        nfConn=RunService.Stepped:Connect(function() local h=getHum();if h then h.FallDamagePerSecond=0 end end)
    else
        if nfConn then nfConn:Disconnect();nfConn=nil end
        local h=getHum();if h then h.FallDamagePerSecond=math.huge end
    end
end

-- ============================================================
-- 【自动跳】
-- ============================================================
local function setAutoJump(v) local h=getHum();if h then h.AutoJumpEnabled=v end end

-- ============================================================
-- 【标签页】
-- ============================================================
local T1=createTab("公告");addTabBtn("公告",1)
addPara(T1,"作者","小贺")
addLabel(T1,"此脚本完全免费")
addLabel(T1,"禁止倒卖、二次售卖")
addLabel(T1,"QQ交流群：1104880878")
addLabel(T1,"注入器："..(identifyexecutor and identifyexecutor() or "未知"))
addLabel(T1,"用户名："..LocalPlayer.Name)
addLabel(T1,"版本：V9 飞行重写+防坠落精修")
addLabel(T1,"新增：人物自转、透视稳定性修复")

local T2=createTab("移动");addTabBtn("移动",2)
addToggle(T2,"飞行（视角控制上下）",false,function(v) setFly(v) end)
addSlider(T2,"飞行速度",10,300,60,function(v) flySpeed=v end)
addToggle(T2,"防坠落(精修版)",false,function(v) setAntiFall(v) end)
addToggle(T2,"人物自转",false,function(v) setSpin(v) end)
addToggle(T2,"无限跳",false,function(v) setInfiniteJump(v) end)
addToggle(T2,"穿墙",false,function(v) setNoclip(v) end)
addToggle(T2,"无坠落伤害",false,function(v) setNoFall(v) end)
addToggle(T2,"自动跳跃",false,function(v) setAutoJump(v) end)
addSlider(T2,"移动速度",0,200,16,function(v) local h=getHum();if h then h.WalkSpeed=v end end)
addSlider(T2,"跳跃高度",0,500,50,function(v) local h=getHum();if h then h.JumpPower=v end end)
addSlider(T2,"重力设置",0,500,196,function(v) game.Workspace.Gravity=v end)
addBtn(T2,"重置速度",function() local h=getHum();if h then h.WalkSpeed=16 end end)
addBtn(T2,"重置跳跃",function() local h=getHum();if h then h.JumpPower=50 end end)
addBtn(T2,"重置重力",function() game.Workspace.Gravity=196.2 end)

local T3=createTab("视觉");addTabBtn("视觉",3)
addToggle(T3,"全亮夜视",false,function(v) setFullBright(v) end)
addToggle(T3,"透视总开关",false,function(v) setESP(v) end)
addToggle(T3,"  └ 只透视敌人(队伍检测)",false,function(v) espTeamCheckEnabled=v end)
addToggle(T3,"  └ 方框",true,function(v) espBoxEnabled=v end)
addToggle(T3,"  └ 射线(追踪线)",true,function(v) espTracerEnabled=v end)
addToggle(T3,"  └ 信息(名字+队伍+距离)",true,function(v) espInfoEnabled=v end)
addToggle(T3,"  └ 血量条",true,function(v) espHealthEnabled=v end)
addToggle(T3,"FPS显示",false,function(v) setFPS(v) end)
addSlider(T3,"FOV视角",50,120,70,function(v) workspace.CurrentCamera.FieldOfView=v end)
addBtn(T3,"重置FOV",function() workspace.CurrentCamera.FieldOfView=70 end)
addSlider(T3,"时间(小时)",0,24,12,function(v) game.Lighting.ClockTime=v end)
addBtn(T3,"白天",function() game.Lighting.ClockTime=12 end)
addBtn(T3,"夜晚",function() game.Lighting.ClockTime=0 end)
addBtn(T3,"画质拉满",function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level21 end)
addBtn(T3,"画质最低",function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)

local T4=createTab("玩家");addTabBtn("玩家",4)
addToggle(T4,"防甩飞(优化版)",false,function(v) setAntiFly(v) end)
addBtn(T4,"传送玩家",function() selectPlayer(function(plr) teleportToPlayer(plr) end,"传送目标") end)
addBtn(T4,"甩飞玩家(修复版)",function() selectPlayer(function(plr) flingPlayer(plr) end,"甩飞目标") end)
addBtn(T4,"自杀",function() local h=getHum();if h then h.Health=0 end end)
addBtn(T4,"重置角色",function() LocalPlayer.Character:BreakJoints() end)
addBtn(T4,"清除背包",function() LocalPlayer.Backpack:ClearAllChildren() end)
addSlider(T4,"人物大小",0.5,3,1,function(v)
    local c=getChar();if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then h.HeadScale.Value=v;h.BodyDepthScale.Value=v;h.BodyWidthScale.Value=v;h.BodyHeightScale.Value=v end
end)
addBtn(T4,"恢复大小",function()
    local c=getChar();if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then h.HeadScale.Value=1;h.BodyDepthScale.Value=1;h.BodyWidthScale.Value=1;h.BodyHeightScale.Value=1 end
end)
addBtn(T4,"在线玩家",function()
    local list=""
    for _,p in ipairs(Players:GetPlayers()) do list=list..p.Name.."\n" end
    game:GetService("StarterGui"):SetCore("SendNotification",{Title="在线("..#Players:GetPlayers()..")",Text=list,Duration=10})
end)
addBtn(T4,"关闭全部功能",function()
    setFly(false);setInfiniteJump(false);setNoclip(false);setESP(false)
    setFPS(false);setFullBright(false);setNoFall(false);setAutoJump(false)
    setAntiFly(false);setAntiFall(false);setSpin(false)
    game:GetService("StarterGui"):SetCore("SendNotification",{Title="小贺脚本",Text="全部功能已关闭",Duration=3})
end)

local T5=createTab("外部");addTabBtn("外部",5)
addLabel(T5,"外部脚本（可能失效，优先用内置）")
addBtn(T5,"光影",function() loadstring(game:HttpGet("https://pastebin.com/raw/arzRCgwS"))() end)
addBtn(T5,"画质增强",function() loadstring(game:HttpGet("https://pastebin.com/raw/jHBfJYmS"))() end)
addBtn(T5,"旋转",function() loadstring(game:HttpGet('https://pastebin.com/raw/r97d7dS0',true))() end)
addBtn(T5,"飞车",function() loadstring(game:HttpGet("https://pastebin.com/raw/MHE1cbWF"))() end)
addBtn(T5,"工具挂",function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/BeboScripts/main/StandAwekening.lua"))() end)
addBtn(T5,"人物无敌",function() loadstring(game:HttpGet('https://pastebin.com/raw/H3RLCWWZ'))() end)
addBtn(T5,"飞行(外部)",function() loadstring(game:HttpGet("https://pastebin.com/raw/U27yQRxS"))() end)
addBtn(T5,"速度更改",function() loadstring(game:HttpGet("https://pastebin.com/raw/Zuw5T7DP",true))() end)
addBtn(T5,"爬墙",function() loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))() end)
addBtn(T5,"动作",function() loadstring(game:HttpGet("https://pastebin.com/raw/Zj4NnKs6"))() end)
addBtn(T5,"电脑键盘",function() loadstring(game:HttpGet("https://raw.githubusercontent.com/advxzivhsjjdhxhsidifvsh/mobkeyboard/main/main.txt",true))() end)
addBtn(T5,"铁拳",function() loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe/main/obf_rf6iQURzu1fqrytcnLBAvW34C9N55kS9g9G3CKz086rC47M6632sEd4ZZYB0AYgV.lua.txt'))() end)
addBtn(T5,"吸取全部玩家",function() loadstring(game:HttpGet('https://pastebin.com/raw/hQSBGsw2'))() end)
addBtn(T5,"死亡笔记",function() loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/tt/main/%E6%AD%BB%E4%BA%A1%E7%AC%94%E8%AE%B0%20(1).txt"))() end)
addBtn(T5,"踏空",function() loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float'))() end)
addBtn(T5,"建筑工具",function()
    local h=Instance.new("HopperBin");h.Name="锤子";h.BinType=4;h.Parent=LocalPlayer.Backpack
    local c=Instance.new("HopperBin");c.Name="克隆";c.BinType=3;c.Parent=LocalPlayer.Backpack
    local g=Instance.new("HopperBin");g.Name="抓取";g.BinType=2;g.Parent=LocalPlayer.Backpack
end)

switchTab("公告")
print("✦ 小贺脚本 V9 加载完成 ✦")
