-- Fox Egg Scout V4: visual-only egg finder for Steal An Egg.
-- Does not move the character, fire prompts, simulate E, or bypass anti-cheat.
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local player = Players.LocalPlayer
local guiParent = player:WaitForChild('PlayerGui')
local old = guiParent:FindFirstChild('FoxEggScoutV4')
if old then old:Destroy() end
local gui = Instance.new('ScreenGui')
gui.Name = 'FoxEggScoutV4'; gui.ResetOnSpawn = false; gui.Parent = guiParent
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(440,380); frame.Position = UDim2.new(.5,-220,.5,-190)
frame.BackgroundColor3 = Color3.fromRGB(22,25,37); frame.Parent = gui
Instance.new('UICorner',frame).CornerRadius = UDim.new(0,12)
local function label(text,y,height)
 local l=Instance.new('TextLabel'); l.Size=UDim2.new(1,-24,0,height or 28)
 l.Position=UDim2.fromOffset(12,y); l.BackgroundTransparency=1
 l.TextColor3=Color3.fromRGB(232,232,246); l.Font=Enum.Font.Gotham
 l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=text; l.Parent=frame
 return l
end
label('FOX EGG SCOUT V4  |  visual-only',12,28)
local status=label('Scan shows nearby egg-like objects. No auto-steal.',44,38)
status.TextWrapped=true
local scroll=Instance.new('ScrollingFrame')
scroll.Size=UDim2.new(1,-24,1,-150); scroll.Position=UDim2.fromOffset(12,91)
scroll.BackgroundColor3=Color3.fromRGB(32,37,54); scroll.BorderSizePixel=0
scroll.ScrollBarThickness=5; scroll.Parent=frame
Instance.new('UICorner',scroll).CornerRadius=UDim.new(0,8)
local layout=Instance.new('UIListLayout',scroll)
layout.Padding=UDim.new(0,5)
local highlights={}
local function clearHighlights()
 for _,h in ipairs(highlights) do if h.Parent then h:Destroy() end end
 table.clear(highlights)
end
local function getPart(inst)
 if inst:IsA('BasePart') then return inst end
 if inst:IsA('Model') then return inst.PrimaryPart or inst:FindFirstChildWhichIsA('BasePart',true) end
 return nil
end
local function scan()
 clearHighlights()
 for _,child in ipairs(scroll:GetChildren()) do if child:IsA('TextLabel') then child:Destroy() end end
 local char=player.Character; local root=char and char:FindFirstChild('HumanoidRootPart')
 local candidates={}
 for _,inst in ipairs(workspace:GetDescendants()) do
  if (inst:IsA('Model') or inst:IsA('BasePart')) and inst.Name:lower():find('egg',1,true) then
   local part=getPart(inst)
   if part and not (char and inst:IsDescendantOf(char)) then
    local dist=root and (part.Position-root.Position).Magnitude or math.huge
    table.insert(candidates,{inst=inst,part=part,dist=dist})
   end
  end
 end
 table.sort(candidates,function(a,b) return a.dist<b.dist end)
 local limit=math.min(#candidates,50)
 for i=1,limit do
  local item=candidates[i]
  local l=Instance.new('TextLabel')
  l.Size=UDim2.new(1,-10,0,34); l.BackgroundColor3=Color3.fromRGB(42,48,70)
  l.TextColor3=Color3.fromRGB(240,240,255); l.Font=Enum.Font.Gotham
  l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left
  l.Text='  '..item.inst.Name..'  |  '..(item.dist<math.huge and math.floor(item.dist)..' studs' or '?')
  l.Parent=scroll
  local h=Instance.new('Highlight'); h.FillTransparency=.8; h.OutlineColor=Color3.fromRGB(205,160,255)
  h.DepthMode=Enum.HighlightDepthMode.Occluded; h.Adornee=item.inst; h.Parent=gui
  table.insert(highlights,h)
 end
 scroll.CanvasSize=UDim2.fromOffset(0,limit*39)
 status.Text='Found '..#candidates..' egg-like objects; showing '..limit..'. Visual hints only.'
end
local function button(title,x,width,callback)
 local b=Instance.new('TextButton'); b.Size=UDim2.fromOffset(width,36)
 b.Position=UDim2.new(0,x,1,-47); b.Text=title
 b.BackgroundColor3=Color3.fromRGB(92,70,154); b.TextColor3=Color3.new(1,1,1)
 b.Font=Enum.Font.GothamBold; b.TextSize=13; b.Parent=frame
 Instance.new('UICorner',b).CornerRadius=UDim.new(0,7)
 b.MouseButton1Click:Connect(callback)
end
button('SCAN',12,128,scan)
button('CLEAR',151,128,function() clearHighlights(); status.Text='Highlights cleared.' end)
button('CLOSE',290,138,function() clearHighlights(); gui:Destroy() end)
local dragging=false; local start,original
frame.InputBegan:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; start=input.Position; original=frame.Position end
end)
UIS.InputEnded:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)
UIS.InputChanged:Connect(function(input)
 if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
  local d=input.Position-start
  frame.Position=UDim2.new(original.X.Scale,original.X.Offset+d.X,original.Y.Scale,original.Y.Offset+d.Y)
 end
end)
scan()
