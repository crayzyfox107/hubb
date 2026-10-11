-- FOX EGG AUTO V6 - experimental automation, no anti-cheat bypass
local Players=game:GetService('Players')
local PathfindingService=game:GetService('PathfindingService')
local UIS=game:GetService('UserInputService')
local VIM=game:GetService('VirtualInputManager')
local player=Players.LocalPlayer
local env=(getgenv and getgenv()) or _G
if type(env.FoxEggV6Unload)=='function' then pcall(env.FoxEggV6Unload) end
local active=true; local running=false; local busy=false; local selected={}; local failed={}; local conns={}
local function connect(sig,fn) local c=sig:Connect(fn);table.insert(conns,c);return c end
local function new(kind,props,parent) local o=Instance.new(kind);for k,v in pairs(props) do o[k]=v end;o.Parent=parent;return o end
local function corner(o,r) new('UICorner',{CornerRadius=UDim.new(0,r)},o) end
local colors={bg=Color3.fromRGB(16,18,30),panel=Color3.fromRGB(30,33,53),accent=Color3.fromRGB(132,93,229),text=Color3.fromRGB(244,243,255),muted=Color3.fromRGB(175,173,200)}
local gui=new('ScreenGui',{Name='FoxEggAutoV6',ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},(gethui and gethui()) or player:WaitForChild('PlayerGui'))
local frame=new('Frame',{Size=UDim2.fromOffset(470,420),Position=UDim2.new(.5,-235,.5,-210),BackgroundColor3=colors.bg,BorderSizePixel=0},gui);corner(frame,13)
local head=new('Frame',{Size=UDim2.new(1,0,0,47),BackgroundTransparency=1},frame)
new('TextLabel',{Size=UDim2.new(1,-70,1,0),Position=UDim2.fromOffset(16,0),BackgroundTransparency=1,Text='FOX EGG  /  AUTO V6',Font=Enum.Font.GothamBold,TextSize=17,TextColor3=colors.text,TextXAlignment=Enum.TextXAlignment.Left},head)
local x=new('TextButton',{Size=UDim2.fromOffset(31,30),Position=UDim2.new(1,-40,0,8),Text='X',Font=Enum.Font.GothamBold,TextSize=13,TextColor3=colors.text,BackgroundColor3=colors.panel},head);corner(x,7)
local function btn(t,xp,yp,w,h)
 local b=new('TextButton',{Text=t,Position=UDim2.fromOffset(xp,yp),Size=UDim2.fromOffset(w,h),BackgroundColor3=colors.panel,TextColor3=colors.text,Font=Enum.Font.GothamBold,TextSize=12},frame);corner(b,8);return b
end
local scanButton=btn('SCAN',14,52,100,33)
local allButton=btn('SELECT ALL',121,52,108,33)
local clearButton=btn('CLEAR',236,52,92,33)
local spawnButton=btn('SET SPAWN',335,52,120,33)
local scroll=new('ScrollingFrame',{Position=UDim2.fromOffset(14,94),Size=UDim2.fromOffset(441,235),BackgroundColor3=colors.panel,BorderSizePixel=0,ScrollBarThickness=5,CanvasSize=UDim2.fromOffset(0,0)},frame);corner(scroll,8)
new('UIListLayout',{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
local status=new('TextLabel',{Position=UDim2.fromOffset(14,333),Size=UDim2.fromOffset(441,38),BackgroundTransparency=1,Text='Scan to find E / Steal prompts',Font=Enum.Font.Gotham,TextSize=12,TextColor3=colors.muted,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},frame)
local toggle=btn('START AUTO',14,377,441,32);toggle.BackgroundColor3=colors.accent
local prompts={};local spawnPosition=nil
local function setStatus(t) if active then status.Text=t end end
local function char() local c=player.Character;return c and c:FindFirstChildOfClass('Humanoid'),c and c:FindFirstChild('HumanoidRootPart') end
local function pos(p)
 if not p or not p.Parent then return nil end
 local parent=p.Parent
 if parent:IsA('Attachment') then return parent.WorldPosition end
 if parent:IsA('BasePart') then return parent.Position end
 local part=parent:FindFirstAncestorWhichIsA('BasePart')
 return part and part.Position or nil
end
local function isEgg(p)
 if not p:IsA('ProximityPrompt') or not p.Enabled or not pos(p) then return false end
 local parts={p.Name,p.ActionText,p.ObjectText};local n=p.Parent
 for i=1,5 do if not n or n==workspace then break end;parts[#parts+1]=n.Name;n=n.Parent end
 local s=table.concat(parts,' '):lower()
 if s:find('sell') or s:find('buy') or s:find('hatch') or s:find('upgrade') or s:find('place') then return false end
 return s:find('steal')~=nil or s:find('украсть')~=nil or s:find('egg')~=nil or s:find('яйцо')~=nil
end
local function label(p)
 local n=p.Parent;local parts={}
 for i=1,3 do if not n or n==workspace then break end;table.insert(parts,1,n.Name);n=n.Parent end
 return table.concat(parts,' / ')..'  ['..(p.ActionText~='' and p.ActionText or 'E')..']'
end
local function draw()
 for _,v in ipairs(scroll:GetChildren()) do if v:IsA('TextButton') then v:Destroy() end end
 for i,p in ipairs(prompts) do
  local row=new('TextButton',{LayoutOrder=i,Size=UDim2.new(1,-7,0,36),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextSize=11,Font=Enum.Font.Gotham,TextColor3=colors.text,BackgroundColor3=colors.bg},scroll);corner(row,5)
  local function update() row.Text=(selected[p] and '  [X]  ' or '  [ ]  ')..label(p) end
  update();connect(row.MouseButton1Click,function() selected[p]=not selected[p];update() end)
 end
 scroll.CanvasSize=UDim2.fromOffset(0,#prompts*40)
end
local function scan()
 prompts={}
 for _,v in ipairs(workspace:GetDescendants()) do if isEgg(v) then table.insert(prompts,v) end end
 local _,root=char()
 table.sort(prompts,function(a,b)
  local pa,pb=pos(a),pos(b)
  if root and pa and pb then return (root.Position-pa).Magnitude<(root.Position-pb).Magnitude end
  return label(a)<label(b)
 end)
 draw();setStatus('Found '..#prompts..' interaction prompts. Select targets, then START.')
end
local function getSpawn()
 if spawnPosition then return spawnPosition end
 local _,root=char()
 local nearest,dist=nil,math.huge
 for _,v in ipairs(workspace:GetDescendants()) do
  if v:IsA('SpawnLocation') then
   local d=root and (v.Position-root.Position).Magnitude or 0
   if d<dist then nearest=v.Position+Vector3.new(0,3,0);dist=d end
  end
 end
 return nearest
end
local function moveTo(destination,stopDistance,timeout)
 local hum,root=char();if not hum or not root or not destination then return false,'no character/target' end
 local start=os.clock();stopDistance=stopDistance or 5;timeout=timeout or 35
 while active and running and hum.Health>0 and os.clock()-start<timeout do
  if (root.Position-destination).Magnitude<=stopDistance then hum:Move(Vector3.zero);return true end
  local path=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true,WaypointSpacing=5})
  local ok=pcall(function()path:ComputeAsync(root.Position,destination)end)
  local waypoints=(ok and path.Status==Enum.PathStatus.Success) and path:GetWaypoints() or {{Position=destination}}
  local repath=false
  for _,wp in ipairs(waypoints) do
   if not running or not active then return false,'stopped' end
   if (root.Position-destination).Magnitude<=stopDistance then return true end
   if wp.Action==Enum.PathWaypointAction.Jump then hum.Jump=true end
   hum:MoveTo(wp.Position)
   local untilTime=os.clock()+3.5
   while active and running and os.clock()<untilTime and (root.Position-wp.Position).Magnitude>3.5 do task.wait(.12) end
   if not active or not running then return false,'stopped' end
   if (root.Position-wp.Position).Magnitude>5 then repath=true;break end
  end
  task.wait(repath and .2 or .1)
 end
 return (root.Position-destination).Magnitude<=stopDistance,'path timeout'
end
local function carried()
 local c=player.Character
 if not c then return false end
 for _,v in ipairs(c:GetDescendants()) do
  local s=v.Name:lower()
  if (v:IsA('Tool') or v:IsA('Model')) and (s:find('egg') or s:find('яйц') or s:find('carry') or s:find('held')) then return true end
 end
 return false
end
local function trigger(p)
 if not p or not p.Parent then return false,'prompt vanished' end
 if type(fireproximityprompt)=='function' then
  local ok,err=pcall(function()fireproximityprompt(p,math.max(p.HoldDuration,0)+.1)end)
  if ok then return true,'prompt activated (not server-confirmed)' end
 end
 local ok,err=pcall(function()
  VIM:SendKeyEvent(true,Enum.KeyCode.E,false,game)
  task.wait(math.max(.25,p.HoldDuration+.2))
  VIM:SendKeyEvent(false,Enum.KeyCode.E,false,game)
 end)
 if not ok then pcall(function()VIM:SendKeyEvent(false,Enum.KeyCode.E,false,game)end) end
 return ok,ok and 'E held (not server-confirmed)' or tostring(err)
end
local function run()
 while active and running do
  local hum,root=char()
  if not hum or not root or hum.Health<=0 then setStatus('Waiting for character...');task.wait(1)
  else
   if carried() then
    local sp=getSpawn()
    if sp then setStatus('Egg detected in character: returning to spawn');moveTo(sp,9,50);task.wait(2)
    else setStatus('Spawn unknown. Stand at spawn and press SET SPAWN.');running=false end
   else
    local best,bestDist=nil,math.huge
    for p,on in pairs(selected) do
     if on and isEgg(p) and (failed[p] or 0)<os.clock() then
      local at=pos(p)
      if at then local d=(at-root.Position).Magnitude;if d<bestDist then best,bestDist=p,d end end
     end
    end
    if not best then setStatus('No eligible selected prompts; SCAN or wait');task.wait(2)
    else
     failed[best]=os.clock()+12
     setStatus('Walking to '..label(best))
     local at=pos(best)
     local ok,reason=moveTo(at,math.max(2,math.min(best.MaxActivationDistance-1,6)),45)
     if ok and running and best.Parent and best.Enabled then
      local at2=pos(best)
      if at2 and (root.Position-at2).Magnitude<=best.MaxActivationDistance then
       setStatus('Trying E: '..label(best))
       local sent,detail=trigger(best)
       if sent then
        task.wait(1.2)
        if carried() then
         local sp=getSpawn()
         if sp then setStatus('Carrying egg -> spawn');moveTo(sp,9,50);task.wait(2)
         else setStatus('Egg carried but spawn unknown: use SET SPAWN');running=false end
        else
         setStatus('E attempted; carrying not detected. '..detail)
         -- Some games attach carried egg outside character. Do not falsely claim success.
        end
       else setStatus('Interaction failed: '..detail) end
      else setStatus('Prompt out of range') end
     else setStatus('Movement failed: '..tostring(reason)) end
     task.wait(.4)
    end
   end
  end
 end
 busy=false
end
local function stop() running=false;toggle.Text='START AUTO';setStatus('Stopped') end
local function unload()
 if not active then return end
 stop();active=false
 pcall(function()VIM:SendKeyEvent(false,Enum.KeyCode.E,false,game)end)
 for _,c in ipairs(conns) do pcall(function()c:Disconnect()end) end
 gui:Destroy();env.FoxEggV6Unload=nil
end
env.FoxEggV6Unload=unload
connect(scanButton.MouseButton1Click,scan)
connect(allButton.MouseButton1Click,function()for _,p in ipairs(prompts) do selected[p]=true end;draw() end)
connect(clearButton.MouseButton1Click,function()selected={};draw() end)
connect(spawnButton.MouseButton1Click,function()local _,r=char();if r then spawnPosition=r.Position;setStatus('Spawn saved at current position')end end)
connect(toggle.MouseButton1Click,function()
 if running then stop();return end
 local count=0;for _,v in pairs(selected) do if v then count+=1 end end
 if count==0 then setStatus('Select at least one egg prompt') return end
 running=true;toggle.Text='STOP AUTO'
 if not busy then busy=true;task.spawn(run) end
end)
connect(x.MouseButton1Click,unload)
connect(UIS.InputBegan,function(input,processed)if not processed and input.KeyCode==Enum.KeyCode.RightShift then gui.Enabled=not gui.Enabled end end)
local drag=false;local origin,initial
connect(head.InputBegan,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;origin=input.Position;initial=frame.Position end end)
connect(UIS.InputChanged,function(input)if drag and input.UserInputType==Enum.UserInputType.MouseMovement then local d=input.Position-origin;frame.Position=UDim2.new(initial.X.Scale,initial.X.Offset+d.X,initial.Y.Scale,initial.Y.Offset+d.Y) end end)
connect(UIS.InputEnded,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
scan()
