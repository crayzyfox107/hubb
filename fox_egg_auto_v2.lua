-- Fox Egg Auto V2 | Steal An Egg (107778070777162)
-- No teleports, no anti-cheat bypass. Client-side best-effort pathfinding.
-- Auto-steal starts OFF. Does not invoke unknown RemoteEvents.
local Players = game:GetService('Players')
local PathfindingService = game:GetService('PathfindingService')
local UIS = game:GetService('UserInputService')
local player = Players.LocalPlayer
if game.PlaceId ~= 107778070777162 then warn('[Fox Egg] Wrong game'); return end
local env = (getgenv and getgenv()) or _G
if type(env.FoxEggStop)=='function' then pcall(env.FoxEggStop) end
local guiParent = (gethui and gethui()) or player:WaitForChild('PlayerGui')
local running, alive, busy = false, true, false
local connections, attempted = {}, {}
local function bind(sig,fn) local c=sig:Connect(fn); table.insert(connections,c); return c end
local function char() local c=player.Character; return c,c and c:FindFirstChildOfClass('Humanoid'),c and c:FindFirstChild('HumanoidRootPart') end
local gui=Instance.new('ScreenGui'); gui.Name='FoxEggAutoV2'; gui.ResetOnSpawn=false; gui.Parent=guiParent
local frame=Instance.new('Frame'); frame.Size=UDim2.fromOffset(340,235); frame.Position=UDim2.new(.5,-170,.5,-117); frame.BackgroundColor3=Color3.fromRGB(20,23,36); frame.BorderSizePixel=0; frame.Parent=gui
local corner=Instance.new('UICorner'); corner.CornerRadius=UDim.new(0,12); corner.Parent=frame
local function label(y,h,txt,size,col)
 local x=Instance.new('TextLabel'); x.Position=UDim2.fromOffset(16,y); x.Size=UDim2.new(1,-32,0,h); x.BackgroundTransparency=1; x.Text=txt; x.TextWrapped=true; x.TextXAlignment=Enum.TextXAlignment.Left; x.Font=Enum.Font.Gotham; x.TextSize=size; x.TextColor3=col or Color3.fromRGB(220,225,240); x.Parent=frame; return x
end
label(10,28,'FOX EGG  |  AUTO STEAL V2',19,Color3.fromRGB(182,149,255))
local status=label(42,42,'Status: OFF',13)
local detail=label(87,42,'Walks to nearby egg prompts. No teleport or anti-cheat bypass.',12,Color3.fromRGB(164,174,194))
local button=Instance.new('TextButton'); button.Size=UDim2.new(1,-32,0,44); button.Position=UDim2.fromOffset(16,141); button.Text='START AUTO STEAL'; button.Font=Enum.Font.GothamBold; button.TextSize=14; button.TextColor3=Color3.new(1,1,1); button.BackgroundColor3=Color3.fromRGB(100,77,179); button.Parent=frame
local bc=Instance.new('UICorner'); bc.CornerRadius=UDim.new(0,8); bc.Parent=button
label(195,28,'Right Shift: hide/show   |   X: unload',11,Color3.fromRGB(151,159,184))
local close=Instance.new('TextButton'); close.Text='X'; close.Size=UDim2.fromOffset(26,26); close.Position=UDim2.new(1,-32,0,5); close.BackgroundTransparency=1; close.TextColor3=Color3.new(1,1,1); close.Parent=frame
local function setStatus(s) if alive then status.Text='Status: '..s end end
local function stop() running=false; busy=false; if alive then button.Text='START AUTO STEAL'; setStatus('OFF') end end
local function unload() if not alive then return end; stop(); alive=false; for _,c in ipairs(connections) do c:Disconnect() end; gui:Destroy(); env.FoxEggStop=nil end
env.FoxEggStop=unload
local function promptPosition(prompt)
 local parent=prompt.Parent
 if parent:IsA('Attachment') then return parent.WorldPosition end
 if parent:IsA('BasePart') then return parent.Position end
 local part=parent:FindFirstAncestorWhichIsA('BasePart'); return part and part.Position
end
local function candidate(prompt)
 if not prompt:IsA('ProximityPrompt') or not prompt.Enabled then return false end
 local s=(prompt.Name..' '..prompt.ActionText..' '..prompt.ObjectText..' '..prompt.Parent.Name):lower()
 if not s:find('egg') and not s:find('steal') and not s:find('collect') then return false end
 if s:find('hatch') or s:find('place') or s:find('sell') or s:find('buy') then return false end
 local c=player.Character
 if c and prompt:IsDescendantOf(c) then return false end
 return promptPosition(prompt)~=nil
end
local function nearestPrompt(root)
 local best,dist=nil,math.huge
 for _,v in ipairs(workspace:GetDescendants()) do
  if candidate(v) and (attempted[v] or 0)<os.clock() then
   local pos=promptPosition(v)
   if pos then local d=(root.Position-pos).Magnitude; if d<dist then best,dist=v,d end end
  end
 end
 return best,dist
end
local function walkTo(pos,hum,root)
 local ok,path=pcall(function()
  local p=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true,WaypointSpacing=5}); p:ComputeAsync(root.Position,pos); return p
 end)
 if not ok or path.Status~=Enum.PathStatus.Success then return false,'no path' end
 for _,waypoint in ipairs(path:GetWaypoints()) do
  if not running or not alive or hum.Health<=0 then return false,'stopped' end
  if waypoint.Action==Enum.PathWaypointAction.Jump then hum.Jump=true end
  hum:MoveTo(waypoint.Position)
  local deadline=os.clock()+3.5
  while os.clock()<deadline do
   if not running or not alive or hum.Health<=0 then return false,'stopped' end
   if (root.Position-waypoint.Position).Magnitude<3.5 then break end
   task.wait(.1)
  end
  if (root.Position-waypoint.Position).Magnitude>=5 then return false,'movement blocked or corrected' end
 end
 return true
end
local function activate(prompt)
 if type(fireproximityprompt)~='function' then return false,'executor has no fireproximityprompt' end
 local ok,err=pcall(function() fireproximityprompt(prompt) end)
 return ok,ok and 'interaction sent (not server-confirmed)' or tostring(err)
end
local function loop()
 while alive and running do
  local _,hum,root=char()
  if not hum or not root or hum.Health<=0 then setStatus('waiting for character'); task.wait(1)
  else
   local prompt,d=nearestPrompt(root)
   if not prompt then setStatus('no matching egg prompts'); task.wait(2)
   else
    attempted[prompt]=os.clock()+12
    setStatus('walking to '..prompt.Parent.Name)
    local pos=promptPosition(prompt)
    local ok,why=walkTo(pos,hum,root)
    if ok and running and prompt.Parent then
     local current=promptPosition(prompt)
     if current and (root.Position-current).Magnitude<=math.max(prompt.MaxActivationDistance,8) then
      local success,msg=activate(prompt); setStatus(success and 'interaction attempted' or 'cannot interact'); detail.Text=msg
     else setStatus('egg moved / out of range') end
    elseif why~='stopped' then setStatus(why) end
    task.wait(1)
   end
  end
 end
 busy=false
end
bind(button.MouseButton1Click,function()
 if running then stop(); return end
 running=true; button.Text='STOP AUTO STEAL'; setStatus('searching');
 if not busy then busy=true; task.spawn(loop) end
end)
bind(close.MouseButton1Click,unload)
bind(UIS.InputBegan,function(input,processed) if not processed and input.KeyCode==Enum.KeyCode.RightShift then gui.Enabled=not gui.Enabled end end)
bind(player.CharacterAdded,function() if running then setStatus('respawn; resuming search') end end)
-- Drag header only.
local drag=false; local dragStart,frameStart
bind(frame.InputBegan,function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; dragStart=input.Position; frameStart=frame.Position end
end)
bind(UIS.InputChanged,function(input)
 if drag and input.UserInputType==Enum.UserInputType.MouseMovement then local d=input.Position-dragStart; frame.Position=UDim2.new(frameStart.X.Scale,frameStart.X.Offset+d.X,frameStart.Y.Scale,frameStart.Y.Offset+d.Y) end
end)
bind(UIS.InputEnded,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
