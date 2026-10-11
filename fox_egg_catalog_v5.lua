-- FOX EGG V5 | Egg catalog and selection UI (visual-only)
-- Roblox Steal An Egg: place 107778070777162
-- No teleport, automation, simulated inputs, or anti-cheat bypass.
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local player = Players.LocalPlayer
if not player then return end
if _G.FoxEggV5Close then pcall(_G.FoxEggV5Close) end
local data = {
 {'Forest','Chicken,Dog,Bird,Burrowing Owl,Raccoon,Fox,Bear,Brr Brr Patapim'},
 {'Lake','Frog,Duckling,Catfish,Turtle,Trulimero Trulicina,Swan,Axolotl,Leviathan'},
 {'Desert','Jerboa,Fennec,Camel,Tob Tobi Tob Tob,Snake,Sand Spider,Scorpion,Royal Sphinx'},
 {'Jungle','Chimpanzee,Toucan,Crocodile,Gorilla,Orangutini Ananassini,Spider,Tiger,King Snake'},
 {'Snow','Penguin,Walrus,Polar Bear,Sabertooth Tiger,Mammoth,King Mammoth,Yeti,Ice Dragon'},
 {'Volcano','Lava Gecko,Lava Frog,Flaming Bull,Lava Iguana,Chillin Chilli,Cerberus,Phoenix,Lava Dragon'},
 {'Abyss Ocean','Parrotfish,Swordfish,Shark,Orca,Whale Shark,Beluga Whale,Kraken,El Maja'},
 {'Prehistoric','Dodo,Pterodactyl,Ankylosaurus,Triceratops,Bronto,T-Rex,Tralaledon,Mosasaurus'},
 {'Cosmic','Centapede,Cosmic Gecko,Cosmic Gorilla,La Vacca Saturno Saturnita,Cosmic Skeleton Boss,Cosmic Dragon,Eternal Lunar Dragon,Unicorn'},
 {'Cherry Blossom','Crane,Salamander,Red Panda,Snowy Owl,Koi,Stag,Oni Tiger,Kitsune'},
 {'Titan Temple','Crustacia,Bladehide,Mantaris,Mutant Shark,Gorilla King'},
}
local C={bg=Color3.fromRGB(16,19,31),panel=Color3.fromRGB(25,29,46),item=Color3.fromRGB(34,39,59),accent=Color3.fromRGB(151,112,248),fg=Color3.fromRGB(240,240,250),muted=Color3.fromRGB(159,167,191),green=Color3.fromRGB(87,207,155)}
local gui=Instance.new('ScreenGui'); gui.Name='FoxEggCatalogV5'; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
local parent=player:WaitForChild('PlayerGui'); gui.Parent=parent
local conns={}
local function conn(signal,fn) local c=signal:Connect(fn); table.insert(conns,c); return c end
local function frame(parent,size,pos,color,radius)
 local f=Instance.new('Frame'); f.Size=size; f.Position=pos; f.BackgroundColor3=color; f.BorderSizePixel=0; f.Parent=parent
 local r=Instance.new('UICorner'); r.CornerRadius=UDim.new(0,radius or 10); r.Parent=f; return f
end
local function text(parent,value,size,pos,font,color)
 local t=Instance.new('TextLabel'); t.Size=size; t.Position=pos; t.BackgroundTransparency=1; t.Text=value; t.Font=font or Enum.Font.Gotham; t.TextSize=14; t.TextColor3=color or C.fg; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=parent; return t
end
local function button(parent,value,size,pos,fn,background)
 local b=Instance.new('TextButton'); b.Text=value; b.Size=size; b.Position=pos; b.Font=Enum.Font.GothamBold; b.TextSize=13; b.TextColor3=C.fg; b.BackgroundColor3=background or C.item; b.BorderSizePixel=0; b.AutoButtonColor=true; b.Parent=parent
 local corner=Instance.new('UICorner'); corner.CornerRadius=UDim.new(0,9); corner.Parent=b
 conn(b.MouseButton1Click,fn); return b
end
local main=frame(gui,UDim2.fromOffset(680,475),UDim2.new(.5,-340,.5,-237),C.bg,15)
main.Active=true; main.Draggable=true
local header=frame(main,UDim2.new(1,-24,0,65),UDim2.fromOffset(12,12),C.panel,12)
text(header,'FOX EGG',UDim2.fromOffset(190,27),UDim2.fromOffset(17,9),Enum.Font.GothamBold,C.fg).TextSize=21
text(header,'V5  /  EGG CATALOG',UDim2.fromOffset(240,18),UDim2.fromOffset(18,37),nil,C.muted).TextSize=11
local close
close=button(header,'×',UDim2.fromOffset(34,34),UDim2.new(1,-44,0,14),function() if _G.FoxEggV5Close then _G.FoxEggV5Close() end end)
close.TextSize=23
local sidebar=frame(main,UDim2.fromOffset(175,333),UDim2.fromOffset(12,89),C.panel,12)
local biomes=Instance.new('ScrollingFrame'); biomes.BackgroundTransparency=1; biomes.BorderSizePixel=0; biomes.Size=UDim2.new(1,-14,1,-16); biomes.Position=UDim2.fromOffset(7,8); biomes.ScrollBarThickness=3; biomes.ScrollBarImageColor3=C.accent; biomes.Parent=sidebar
local bLayout=Instance.new('UIListLayout'); bLayout.Padding=UDim.new(0,5); bLayout.Parent=biomes
local content=frame(main,UDim2.fromOffset(467,333),UDim2.fromOffset(201,89),C.panel,12)
local heading=text(content,'Forest',UDim2.new(1,-30,0,26),UDim2.fromOffset(14,11),Enum.Font.GothamBold); heading.TextSize=18
local search=Instance.new('TextBox'); search.Size=UDim2.new(1,-28,0,34); search.Position=UDim2.fromOffset(14,46); search.BackgroundColor3=C.item; search.TextColor3=C.fg; search.PlaceholderColor3=C.muted; search.PlaceholderText='Search eggs...'; search.Text=''; search.ClearTextOnFocus=false; search.Font=Enum.Font.Gotham; search.TextSize=13; search.BorderSizePixel=0; search.Parent=content
local searchCorner=Instance.new('UICorner'); searchCorner.CornerRadius=UDim.new(0,8); searchCorner.Parent=search
local results=Instance.new('ScrollingFrame'); results.BackgroundTransparency=1; results.BorderSizePixel=0; results.Position=UDim2.fromOffset(14,89); results.Size=UDim2.new(1,-28,1,-102); results.ScrollBarThickness=4; results.ScrollBarImageColor3=C.accent; results.Parent=content
local rLayout=Instance.new('UIListLayout'); rLayout.Padding=UDim.new(0,6); rLayout.Parent=results
local status=text(main,'Select eggs to build your target list. No auto-steal.',UDim2.new(1,-28,0,29),UDim2.fromOffset(17,432),nil,C.muted); status.TextSize=12
local selected={}; local current=1; local biomeButtons={}
local function count() local n=0 for _,v in pairs(selected) do if v then n=n+1 end end return n end
local function refresh()
 for _,v in ipairs(results:GetChildren()) do if v:IsA('TextButton') then v:Destroy() end end
 local names=string.split(data[current][2],','); local query=string.lower(search.Text)
 for _,name in ipairs(names) do
  name=name:match('^%s*(.-)%s*$'); local key=data[current][1]..'/'..name
  if query=='' or string.find(string.lower(name),query,1,true) then
   local b=Instance.new('TextButton'); b.Size=UDim2.new(1,-8,0,39); b.BackgroundColor3=selected[key] and C.accent or C.item; b.Text=(selected[key] and '✓  ' or '○  ')..name..' Egg'; b.TextXAlignment=Enum.TextXAlignment.Left; b.TextColor3=C.fg; b.TextSize=13; b.Font=Enum.Font.GothamMedium; b.BorderSizePixel=0; b.Parent=results
   local corner=Instance.new('UICorner'); corner.CornerRadius=UDim.new(0,8); corner.Parent=b
   local pad=Instance.new('UIPadding'); pad.PaddingLeft=UDim.new(0,13); pad.Parent=b
   conn(b.MouseButton1Click,function() selected[key]=not selected[key]; status.Text=tostring(count())..' targets selected • visual reference only'; refresh() end)
  end
 end
 results.CanvasSize=UDim2.fromOffset(0,rLayout.AbsoluteContentSize.Y+8)
end
for i,biome in ipairs(data) do
 local index=i
 local b=button(biomes,biome[1],UDim2.new(1,-5,0,32),UDim2.fromOffset(0,0),function()
  current=index; heading.Text=biome[1]; search.Text=''; for j,bb in ipairs(biomeButtons) do bb.BackgroundColor3=j==index and C.accent or C.item end; refresh()
 end,i==1 and C.accent or C.item)
 table.insert(biomeButtons,b)
end
local function sizeCanvas() biomes.CanvasSize=UDim2.fromOffset(0,bLayout.AbsoluteContentSize.Y+10) end
sizeCanvas(); conn(bLayout:GetPropertyChangedSignal('AbsoluteContentSize'),sizeCanvas)
conn(search:GetPropertyChangedSignal('Text'),refresh)
refresh()
local toggleConn
conn(UIS.InputBegan,function(input,processed) if processed then return end if input.KeyCode==Enum.KeyCode.RightShift then main.Visible=not main.Visible end end)
_G.FoxEggV5Close=function() for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end gui:Destroy(); _G.FoxEggV5Close=nil end
