-- Fox Hub V1 | Client-side Roblox Luau
-- RightShift: show/hide interface | F: toggle flight
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local guiParent = (gethui and gethui()) or player:WaitForChild("PlayerGui")
local old = guiParent:FindFirstChild("FoxHubV1")
if old then old:Destroy() end
if _G.FoxHubCleanup then pcall(_G.FoxHubCleanup) end

local state = {fly=false, speed=false, noclip=false, flySpeed=60, walkSpeed=32}
local originalSpeed, originalCollisions = nil, {}
local flyVelocity, flyGyro
local connections = {}
local alive = true
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end
local function characterParts()
    local character = player.Character
    if not character then return nil end
    return character, character:FindFirstChild("HumanoidRootPart"), character:FindFirstChildOfClass("Humanoid")
end
local function stopFly()
    state.fly = false
    if flyVelocity then flyVelocity:Destroy(); flyVelocity=nil end
    if flyGyro then flyGyro:Destroy(); flyGyro=nil end
end
local function startFly()
    local _, root, humanoid = characterParts()
    if not root or not humanoid then return false end
    stopFly()
    state.fly = true
    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(1e8,1e8,1e8)
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = root
    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e8,1e8,1e8)
    flyGyro.P = 10000
    flyGyro.CFrame = root.CFrame
    flyGyro.Parent = root
    return true
end
local function restoreCollisions()
    for part, original in pairs(originalCollisions) do
        if part and part.Parent then pcall(function() part.CanCollide = original end) end
    end
    table.clear(originalCollisions)
end
local function setNoclip(enabled)
    state.noclip = enabled
    if not enabled then restoreCollisions() end
end
local function setSpeed(enabled)
    local _, _, humanoid = characterParts()
    state.speed = enabled
    if humanoid then
        if enabled then
            originalSpeed = originalSpeed or humanoid.WalkSpeed
            humanoid.WalkSpeed = state.walkSpeed
        else
            humanoid.WalkSpeed = originalSpeed or 16
            originalSpeed = nil
        end
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "FoxHubV1"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = guiParent
local function corner(obj, radius)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,radius); c.Parent=obj
end
local function stroke(obj, color, transparency)
    local s=Instance.new("UIStroke"); s.Color=color; s.Transparency=transparency or 0; s.Thickness=1; s.Parent=obj
end
local bg = Instance.new("Frame")
bg.Name="Window"; bg.Size=UDim2.fromOffset(420,365)
bg.Position=UDim2.new(.5,-210,.5,-182)
bg.BackgroundColor3=Color3.fromRGB(17,20,32)
bg.BorderSizePixel=0; bg.Parent=gui; corner(bg,14)
stroke(bg,Color3.fromRGB(83,100,152),.35)
local grad=Instance.new("UIGradient")
grad.Color=ColorSequence.new(Color3.fromRGB(24,30,50),Color3.fromRGB(12,15,25))
grad.Rotation=90; grad.Parent=bg
local header=Instance.new("Frame")
header.Size=UDim2.new(1,0,0,61); header.BackgroundTransparency=1; header.Parent=bg
local function text(parent, value, size, color, pos, bounds, bold)
    local t=Instance.new("TextLabel")
    t.BackgroundTransparency=1; t.Text=value; t.TextSize=size
    t.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    t.TextColor3=color; t.TextXAlignment=Enum.TextXAlignment.Left
    t.Position=pos; t.Size=bounds; t.Parent=parent
    return t
end
text(header,"FOX HUB",23,Color3.fromRGB(185,155,255),UDim2.fromOffset(20,9),UDim2.fromOffset(270,30),true)
text(header,"V1  •  Universal movement",11,Color3.fromRGB(150,160,186),UDim2.fromOffset(21,37),UDim2.fromOffset(260,16))
local close=Instance.new("TextButton")
close.Text="×"; close.TextSize=25; close.Font=Enum.Font.GothamBold
close.TextColor3=Color3.fromRGB(235,235,245)
close.BackgroundColor3=Color3.fromRGB(60,40,67)
close.Size=UDim2.fromOffset(34,32); close.Position=UDim2.new(1,-47,0,14)
close.Parent=header; corner(close,8)
local divider=Instance.new("Frame")
divider.BackgroundColor3=Color3.fromRGB(72,78,110); divider.BackgroundTransparency=.45
divider.BorderSizePixel=0; divider.Size=UDim2.new(1,-36,0,1)
divider.Position=UDim2.fromOffset(18,61); divider.Parent=bg
local content=Instance.new("Frame")
content.Position=UDim2.fromOffset(18,75); content.Size=UDim2.new(1,-36,1,-92)
content.BackgroundTransparency=1; content.Parent=bg
local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,10); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Parent=content
local refreshers={}
local function toggleRow(title, subtitle, key, onToggle)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,57); row.BackgroundColor3=Color3.fromRGB(33,39,60)
    row.BorderSizePixel=0; row.Parent=content; corner(row,9)
    text(row,title,15,Color3.fromRGB(244,245,255),UDim2.fromOffset(14,7),UDim2.new(1,-130,0,22),true)
    text(row,subtitle,11,Color3.fromRGB(158,170,195),UDim2.fromOffset(14,31),UDim2.new(1,-130,0,16))
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.fromOffset(82,33); btn.Position=UDim2.new(1,-94,.5,-16)
    btn.Font=Enum.Font.GothamBold; btn.TextSize=12; btn.Parent=row; corner(btn,8)
    local function refresh()
        btn.Text=state[key] and "ON" or "OFF"
        btn.BackgroundColor3=state[key] and Color3.fromRGB(110,81,210) or Color3.fromRGB(63,70,92)
        btn.TextColor3=Color3.fromRGB(255,255,255)
    end
    refreshers[key]=refresh
    connect(btn.MouseButton1Click,function() onToggle(not state[key]); refresh() end)
    refresh()
end
local function sliderRow(title, key, minValue, maxValue, step)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,47); row.BackgroundColor3=Color3.fromRGB(30,36,55)
    row.BorderSizePixel=0; row.Parent=content; corner(row,9)
    text(row,title,13,Color3.fromRGB(210,218,241),UDim2.fromOffset(14,4),UDim2.fromOffset(210,20),true)
    local valueLabel=text(row,tostring(state[key]),13,Color3.fromRGB(194,164,255),UDim2.new(1,-57,0,4),UDim2.fromOffset(45,20),true)
    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-28,0,7); track.Position=UDim2.fromOffset(14,31)
    track.BackgroundColor3=Color3.fromRGB(65,70,97); track.BorderSizePixel=0; track.Parent=row; corner(track,5)
    local fill=Instance.new("Frame")
    fill.BackgroundColor3=Color3.fromRGB(165,124,255)
    fill.BorderSizePixel=0; fill.Parent=track; corner(fill,5)
    local dragging=false
    local function update(value)
        value=math.clamp(math.floor(value/step+.5)*step,minValue,maxValue)
        state[key]=value; valueLabel.Text=tostring(value)
        fill.Size=UDim2.fromScale((value-minValue)/(maxValue-minValue),1)
        if key=="walkSpeed" and state.speed then
            local _,_,h=characterParts(); if h then h.WalkSpeed=value end
        end
    end
    local function pointer(input)
        local fraction=(input.Position.X-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1)
        update(minValue+math.clamp(fraction,0,1)*(maxValue-minValue))
    end
    connect(track.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; pointer(input)
        end
    end)
    connect(UIS.InputChanged,function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then pointer(input) end
    end)
    connect(UIS.InputEnded,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    update(state[key])
end

toggleRow("FLY","F • WASD • Space / Ctrl","fly",function(enabled)
    if enabled then startFly() else stopFly() end
end)
toggleRow("SPEED","Adjust character walking speed","speed",setSpeed)
toggleRow("NOCLIP","Pass through collidable parts","noclip",setNoclip)
sliderRow("Flight speed","flySpeed",20,200,10)
sliderRow("Walk speed","walkSpeed",16,100,4)

connect(RunService.RenderStepped,function()
    if not alive or not state.fly then return end
    local _,root=characterParts()
    if not root or not flyVelocity or not flyGyro then stopFly(); if refreshers.fly then refreshers.fly() end; return end
    local camera=workspace.CurrentCamera
    if not camera then return end
    local move=Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then move+=camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move-=camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move-=camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move+=camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then move+=Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move-=Vector3.yAxis end
    flyVelocity.Velocity=move.Magnitude>0 and move.Unit*state.flySpeed or Vector3.zero
    flyGyro.CFrame=camera.CFrame
end)
connect(RunService.Stepped,function()
    if not alive or not state.noclip then return end
    local char=player.Character
    if not char then return end
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if originalCollisions[part]==nil then originalCollisions[part]=part.CanCollide end
            part.CanCollide=false
        end
    end
end)
connect(player.CharacterAdded,function()
    stopFly(); restoreCollisions(); originalSpeed=nil
    state.speed=false; state.noclip=false
    for _,refresh in pairs(refreshers) do refresh() end
end)
connect(UIS.InputBegan,function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.RightShift then gui.Enabled=not gui.Enabled end
    if input.KeyCode==Enum.KeyCode.F then
        if state.fly then stopFly() else startFly() end
        refreshers.fly()
    end
end)
-- Drag the window by its header.
local dragging, dragStart, startPos = false, nil, nil
connect(header.InputBegan,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=input.Position; startPos=bg.Position
    end
end)
connect(UIS.InputChanged,function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-dragStart
        bg.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)
connect(UIS.InputEnded,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
local function cleanup()
    if not alive then return end
    alive=false; stopFly(); setSpeed(false); setNoclip(false)
    for _,c in ipairs(connections) do c:Disconnect() end
    gui:Destroy()
    _G.FoxHubCleanup=nil
end
_G.FoxHubCleanup=cleanup
connect(close.MouseButton1Click,cleanup)
(LayoutOrder)
1(start)
2(startFly)
