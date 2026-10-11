-- Fox Egg V3 | Steal An Egg | experimental client-side helper
-- Select visible egg prompts, then walk to and HOLD E. No teleport or anti-cheat bypass.
local Players = game:GetService('Players')
local PathfindingService = game:GetService('PathfindingService')
local UIS = game:GetService('UserInputService')
local VIM = game:GetService('VirtualInputManager')
local player = Players.LocalPlayer
if game.PlaceId ~= 107778070777162 then warn('[Fox Egg V3] Wrong PlaceId:', game.PlaceId); return end
local env = (getgenv and getgenv()) or _G
if type(env.FoxEggV3Stop)=='function' then pcall(env.FoxEggV3Stop) end
local parent = (gethui and gethui()) or player:WaitForChild('PlayerGui')
local alive, running, worker = true, false, false
local conns, selected, candidates, cooldown = {}, {}, {}, {}
local function bind(signal,fn) local c=signal:Connect(fn); conns[#conns+1]=c; return c end
local function character() local c=player.Character; return c and c:FindFirstChildOfClass('Humanoid'),c and c:FindFirstChild('HumanoidRootPart') end
local function rounded(parentObj,r) local c=Instance.new('UICorner'); c.CornerRadius=UDim.new(0,r); c.Parent=parentObj end
local function new(class,props,into)
 local o=Instance.new(class); for k,v in pairs(props) do o[k]=v end; o.Parent=into; return o
end
local C={bg=Color3.fromRGB(17,21,33), panel=Color3.fromRGB(31,37,56), purple=Color3.fromRGB(117,84,213), muted=Color3.fromRGB(170,181,206), white=Color3.fromRGB(244,246,255)}
local gui=new('ScreenGui',{Name='FoxEggV3',ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
local win=new('Frame',{Size=UDim2.fromOffset(455,480),Position=UDim2.new(.5,-227,.5,-240),BackgroundColor3=C.bg,BorderSizePixel=0},gui); rounded(win,12)
local head=new('Frame',{Size=UDim2.new(1,0,0,54),BackgroundTransparency=1},win)
new('TextLabel',{Text='FOX EGG  /  SELECT V3',Size=UDim2.new(1,-80,0,35),Position=UDim2.fromOffset(16,8),BackgroundTransparency=1,TextColor3=C.white,Font=Enum.Font.GothamBold,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left},head)
local close=new('TextButton',{Text='X',Size=UDim2.fromOffset(32,30),Position=UDim2.new(1,-43,0,11),BackgroundColor3=C.panel,TextColor3=C.white,Font=Enum.Font.GothamBold,TextSize=14},head);rounded(close,7)
local function button(text,y,width,x)
 local b=new('TextButton',{Text=text,Size=UDim2.fromOffset(width,34),Position=UDim2.fromOffset(x,y),BackgroundColor3=C.panel,TextColor3=C.white,Font=Enum.Font.GothamBold,TextSize=12},win); rounded(b,7);return b
end
local refresh=button('SCAN EGGS',61,131,14)
local selectAll=button('SELECT ALL',61,131,159)
local clear=button('CLEAR',61,131,304)
local hint=new('TextLabel',{Text='Choose egg prompts below. Only streamed-in objects can appear.',Size=UDim2.new(1,-28,0,32),Position=UDim2.fromOffset(14,101),BackgroundTransparency=1,TextColor3=C.muted,Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},win)
local scroll=new('ScrollingFrame',{Size=UDim2.new(1,-28,0,252),Position=UDim2.fromOffset(14,137),BackgroundColor3=C.panel,BorderSizePixel=0,ScrollBarThickness=5,CanvasSize=UDim2.fromOffset(0,0)},win);rounded(scroll,7)
local layout=new('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
local status=new('TextLabel',{Text='Status: scan to find eggs',Size=UDim2.new(1,-28,0,33),Position=UDim2.fromOffset(14,392),BackgroundTransparency=1,TextColor3=C.muted,Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},win)
local start=button('START SELECTED',432,425,14);start.BackgroundColor3=C.purple
local function setStatus(s) if alive then status.Text='Status: '..s end end
local function position(prompt)
 if not prompt or not prompt.Parent then return nil end
 local p=prompt.Parent
 if p:IsA('Attachment') then return p.WorldPosition end
 if p:IsA('BasePart') then return p.Position end
 local base=p:FindFirstAncestorWhichIsA('BasePart');return base and base.Position
end
local function isEggPrompt(p)
 if not p:IsA('ProximityPrompt') or not p.Enabled or not position(p) then return false end
 local names={p.Name,p.ActionText,p.ObjectText}
 local obj=p.Parent
 for _=1,3 do if not obj or obj==workspace then break end;names[#names+1]=obj.Name;obj=obj.Parent end
 local s=table.concat(names,' '):lower()
 if s:find('hatch') or s:find('sell') or s:find('place') or s:find('buy') then return false end
 return s:find('egg')~=nil or s:find('steal')~=nil
end
local function describe(p)
 local path={};local node=p.Parent
 for _=1,4 do if not node or node==workspace then break end;table.insert(path,1,node.Name);node=node.Parent end
 return table.concat(path,' / ')..'  ['..(p.ActionText~='' and p.ActionText or p.Name)..']'
end
local function redraw()
 for _,ch in ipairs(scroll:GetChildren()) do if ch:IsA('TextButton') then ch:Destroy() end end
 for i,p in ipairs(candidates) do
  local row=new('TextButton',{Name='Egg'..i,LayoutOrder=i,Size=UDim2.new(1,-8,0,39),BackgroundColor3=C.bg,TextColor3=C.white,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd},scroll);rounded(row,5)
  local function update() row.Text=(selected[p] and '  [X]  ' or '  [ ]  ')..describe(p) end
  update();bind(row.MouseButton1Click,function() selected[p]=not selected[p];update() end)
 end
 scroll.CanvasSize=UDim2.fromOffset(0,#candidates*44)
 hint.Text=('Found %d egg interactions. Select individual eggs or all.'):format(#candidates)
end
local function scan()
 candidates={}
 for _,p in ipairs(workspace:GetDescendants()) do if isEggPrompt(p) then candidates[#candidates+1]=p end end
 table.sort(candidates,function(a,b)return describe(a)<describe(b) end)
 redraw();setStatus(('found %d prompts; choose targets'):format(#candidates))
end
local function walk(pos,hum,root)
 local ok,path=pcall(function()local p=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true,WaypointSpacing=4});p:ComputeAsync(root.Position,pos);return p end)
 if not ok or path.Status~=Enum.PathStatus.Success then return false,'no walking path' end
 for _,wp in ipairs(path:GetWaypoints()) do
  if not running or not alive or hum.Health<=0 then return false,'stopped' end
  if wp.Action==Enum.PathWaypointAction.Jump then hum.Jump=true end
  hum:MoveTo(wp.Position)
  local deadline=os.clock()+4
  repeat task.wait(.1) until not running or not alive or (root.Position-wp.Position).Magnitude<3.5 or os.clock()>deadline
  if not running or not alive then return false,'stopped' end
  if (root.Position-wp.Position).Magnitude>5 then return false,'movement blocked' end
 end
 return true
end
local function holdE(prompt)
 local duration=math.clamp(prompt.HoldDuration+0.3,0.3,15)
 -- Virtual input works only if executor permits it and server accepts normal prompt input.
 local ok,err=pcall(function()
  VIM:SendKeyEvent(true,Enum.KeyCode.E,false,game)
  task.wait(duration)
  VIM:SendKeyEvent(false,Enum.KeyCode.E,false,game)
 end)
 if not ok then pcall(function()VIM:SendKeyEvent(false,Enum.KeyCode.E,false,game)end) end
 return ok,ok and 'held E (server result unknown)' or tostring(err)
end
local function loop()
 while alive and running do
  local hum,root=character()
  if not hum or not root or hum.Health<=0 then setStatus('waiting for character');task.wait(1)
  else
   local best,dist=nil,math.huge
   for p,on in pairs(selected) do
    if on and isEggPrompt(p) and (cooldown[p] or 0)<os.clock() then
     local pos=position(p);if pos then local d=(root.Position-pos).Magnitude;if d<dist then best,dist=p,d end end
    end
   end
   if not best then setStatus('no available selected eggs; rescan if needed');task.wait(2)
   else
    cooldown[best]=os.clock()+15
    setStatus('walking: '..best.Parent.Name)
    local ok,reason=walk(position(best),hum,root)
    if ok and running and best.Parent and best.Enabled then
     local pos=position(best)
     if pos and (root.Position-pos).Magnitude<=best.MaxActivationDistance then
      setStatus('holding E: '..best.Parent.Name)
      local sent,msg=holdE(best);setStatus(sent and 'E held; success not confirmed' or ('input failed: '..msg))
     else setStatus('out of interaction range') end
    elseif reason~='stopped' then setStatus(reason) end
    task.wait(.8)
   end
  end
 end
 worker=false
end
local function stop() running=false;start.Text='START SELECTED';setStatus('stopped') end
local function unload()
 if not alive then return end
 stop();alive=false
 pcall(function()VIM:SendKeyEvent(false,Enum.KeyCode.E,false,game)end)
 for _,c in ipairs(conns) do c:Disconnect() end
 gui:Destroy();env.FoxEggV3Stop=nil
end
env.FoxEggV3Stop=unload
bind(refresh.MouseButton1Click,scan)
bind(selectAll.MouseButton1Click,function()for _,p in ipairs(candidates) do selected[p]=true end;redraw() end)
bind(clear.MouseButton1Click,function()selected={};redraw() end)
bind(start.MouseButton1Click,function()
 if running then stop();return end
 local count=0;for _,on in pairs(selected) do if on then count+=1 end end
 if count==0 then setStatus('select at least one egg first');return end
 running=true;start.Text='STOP';setStatus('starting')
 if not worker then worker=true;task.spawn(loop) end
end)
bind(close.MouseButton1Click,unload)
bind(UIS.InputBegan,function(input,processed)if not processed and input.KeyCode==Enum.KeyCode.RightShift then gui.Enabled=not gui.Enabled end end)
local dragging=false;local dragStart,winStart
bind(head.InputBegan,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;dragStart=input.Position;winStart=win.Position end end)
bind(UIS.InputChanged,function(input)if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then local d=input.Position-dragStart;win.Position=UDim2.new(winStart.X.Scale,winStart.X.Offset+d.X,winStart.Y.Scale,winStart.Y.Offset+d.Y) end end)
bind(UIS.InputEnded,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
scan()
