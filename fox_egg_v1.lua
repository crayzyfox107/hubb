-- Fox Egg V1: Steal An Egg movement diagnostics and utilities
-- Place: 107778070777162. Client-side only; does not bypass server checks.
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local RS = game:GetService('RunService')
local player = Players.LocalPlayer
if game.PlaceId ~= 107778070777162 then
    warn('[Fox Egg] This build is for Steal An Egg (107778070777162).')
    return
end
local pg = player:WaitForChild('PlayerGui')
if _G.FoxEggStop then pcall(_G.FoxEggStop) end
local old = pg:FindFirstChild('FoxEggV1')
if old then old:Destroy() end
local alive, flying, noclip, speedEnabled = true, false, false, false
local flySpeed, walkSpeed = 24, 24
local conns, collisions = {}, {}
local vel, att, orient, flyConn
local lastPos, correctionCount = nil, 0
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(conns,c)
    return c
end
local function parts()
    local ch=player.Character
    return ch, ch and ch:FindFirstChild('HumanoidRootPart'), ch and ch:FindFirstChildOfClass('Humanoid')
end
local gui=Instance.new('ScreenGui')
gui.Name='FoxEggV1'; gui.ResetOnSpawn=false; gui.Parent=pg
local frame=Instance.new('Frame')
frame.Size=UDim2.fromOffset(370,335); frame.Position=UDim2.new(.5,-185,.5,-167)
frame.BackgroundColor3=Color3.fromRGB(19,22,34); frame.BorderSizePixel=0; frame.Parent=gui
local cr=Instance.new('UICorner'); cr.CornerRadius=UDim.new(0,14); cr.Parent=frame
local border=Instance.new('UIStroke'); border.Color=Color3.fromRGB(122,94,220); border.Thickness=1; border.Parent=frame
local function label(txt,y,height,size,color)
    local x=Instance.new('TextLabel'); x.Text=txt; x.TextColor3=color or Color3.fromRGB(230,233,248)
    x.TextSize=size or 14; x.Font=Enum.Font.Gotham; x.BackgroundTransparency=1
    x.TextXAlignment=Enum.TextXAlignment.Left; x.Position=UDim2.fromOffset(16,y)
    x.Size=UDim2.new(1,-32,0,height); x.Parent=frame; return x
end
label('FOX EGG  |  Steal An Egg',12,28,20,Color3.fromRGB(188,157,255))
local status=label('Ready • no bypass claimed',43,24,12,Color3.fromRGB(157,178,206))
local function button(text,y,callback)
    local b=Instance.new('TextButton'); b.Text=text; b.Font=Enum.Font.GothamBold
    b.TextSize=14; b.TextColor3=Color3.fromRGB(240,241,250)
    b.BackgroundColor3=Color3.fromRGB(45,51,77); b.BorderSizePixel=0
    b.Position=UDim2.fromOffset(16,y); b.Size=UDim2.new(1,-32,0,37); b.Parent=frame
    local c=Instance.new('UICorner'); c.CornerRadius=UDim.new(0,8); c.Parent=b
    bind(b.MouseButton1Click,callback)
    return b
end
local stopFly
local flyButton
local function startFly()
    local ch,root,hum=parts()
    if not root or not hum then status.Text='Character not ready'; return end
    if flying then return end
    flying=true; correctionCount=0; lastPos=root.Position
    att=Instance.new('Attachment'); att.Name='FoxEggAttachment'; att.Parent=root
    vel=Instance.new('LinearVelocity'); vel.Name='FoxEggVelocity'; vel.Attachment0=att
    vel.RelativeTo=Enum.ActuatorRelativeTo.World; vel.MaxForce=100000
    vel.VectorVelocity=Vector3.zero; vel.Parent=root
    orient=Instance.new('AlignOrientation'); orient.Name='FoxEggOrientation'; orient.Attachment0=att
    orient.Mode=Enum.OrientationAlignmentMode.OneAttachment
    orient.MaxTorque=100000; orient.Responsiveness=12; orient.Parent=root
    hum.AutoRotate=false
    flyButton.Text='FLY: ON (F)'
    status.Text='Flying slowly • server may correct movement'
    flyConn=RS.Heartbeat:Connect(function(dt)
        local _,r,h=parts()
        if not alive or not flying or r~=root or not r.Parent then stopFly(); return end
        local cam=workspace.CurrentCamera
        if not cam then return end
        local m=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then m+=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then m-=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then m+=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then m-=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then m+=Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then m-=Vector3.yAxis end
        local target=m.Magnitude>0 and m.Unit*flySpeed or Vector3.zero
        vel.VectorVelocity=vel.VectorVelocity:Lerp(target,math.clamp(dt*6,0,1))
        orient.CFrame=CFrame.lookAt(Vector3.zero,cam.CFrame.LookVector)
        -- Detect large unexpected displacement; avoid fighting server correction indefinitely.
        if lastPos and dt<.15 and (root.Position-lastPos).Magnitude>math.max(16,flySpeed*dt*7) then
            correctionCount+=1
            status.Text='Position correction detected ('..correctionCount..')'
            if correctionCount>=3 then
                stopFly(); status.Text='Fly stopped: repeated position corrections'
                return
            end
        end
        lastPos=root.Position
    end)
end
stopFly=function()
    flying=false
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    if vel then vel:Destroy(); vel=nil end
    if orient then orient:Destroy(); orient=nil end
    if att then att:Destroy(); att=nil end
    local _,_,hum=parts(); if hum then hum.AutoRotate=true end
    if flyButton then flyButton.Text='FLY: OFF (F)' end
end
flyButton=button('FLY: OFF (F)',77,function() if flying then stopFly() else startFly() end end)
local speedButton=button('SPEED: OFF',119,function()
    speedEnabled=not speedEnabled
    local _,_,h=parts()
    if h then h.WalkSpeed=speedEnabled and walkSpeed or 16 end
    speedButton.Text=speedEnabled and ('SPEED: ON ('..walkSpeed..')') or 'SPEED: OFF'
end)
local noclipButton=button('NOCLIP: OFF',161,function()
    noclip=not noclip
    if not noclip then
        for p,v in pairs(collisions) do if p.Parent then p.CanCollide=v end end
        table.clear(collisions)
    end
    noclipButton.Text=noclip and 'NOCLIP: ON' or 'NOCLIP: OFF'
end)
local faster=button('FLY SPEED: 24  |  click to increase',203,function()
    flySpeed=flySpeed+6
    if flySpeed>48 then flySpeed=12 end
    faster.Text='FLY SPEED: '..flySpeed..'  |  click to increase'
end)
local speedSetting=button('WALK SPEED: 24  |  click to increase',245,function()
    walkSpeed=walkSpeed+4
    if walkSpeed>40 then walkSpeed=16 end
    speedSetting.Text='WALK SPEED: '..walkSpeed..'  |  click to increase'
    if speedEnabled then local _,_,h=parts(); if h then h.WalkSpeed=walkSpeed end end
    if speedEnabled then speedButton.Text='SPEED: ON ('..walkSpeed..')' end
end)
label('Right Shift: hide GUI  •  F: toggle Fly',290,20,11,Color3.fromRGB(145,155,182))
bind(RS.Stepped,function()
    if not alive or not noclip then return end
    local ch=player.Character; if not ch then return end
    for _,p in ipairs(ch:GetDescendants()) do
        if p:IsA('BasePart') then
            if collisions[p]==nil then collisions[p]=p.CanCollide end
            p.CanCollide=false
        end
    end
end)
bind(UIS.InputBegan,function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.RightShift then gui.Enabled=not gui.Enabled end
    if input.KeyCode==Enum.KeyCode.F then if flying then stopFly() else startFly() end end
end)
bind(player.CharacterAdded,function()
    stopFly(); noclip=false; speedEnabled=false
    table.clear(collisions); noclipButton.Text='NOCLIP: OFF'; speedButton.Text='SPEED: OFF'
end)
-- Drag window by title area
local dragging,startMouse,startFrame=false,nil,nil
bind(frame.InputBegan,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 and input.Position.Y < frame.AbsolutePosition.Y+70 then
        dragging=true; startMouse=input.Position; startFrame=frame.Position
    end
end)
bind(UIS.InputEnded,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
bind(UIS.InputChanged,function(input)
    if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local d=input.Position-startMouse
        frame.Position=UDim2.new(startFrame.X.Scale,startFrame.X.Offset+d.X,startFrame.Y.Scale,startFrame.Y.Offset+d.Y)
    end
end)
local function cleanup()
    if not alive then return end
    alive=false; stopFly()
    local _,_,h=parts(); if h and speedEnabled then h.WalkSpeed=16 end
    for p,v in pairs(collisions) do if p.Parent then p.CanCollide=v end end
    for _,c in ipairs(conns) do c:Disconnect() end
    gui:Destroy(); _G.FoxEggStop=nil
end
_G.FoxEggStop=cleanup
