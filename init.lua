local cetopen = false
local windowstate = {
  Current = {
    mywindowhidden = false,
  },
  Default = {
    mywindowhidden = false,
  }
}

local UL = require('_utility')
local FN = require('_func')
local DS = require('_debug')

local function SaveWindowState()
  local file = io.open('windowstate.json', 'w')
  if file then
    file:write(json.encode(windowstate.Current))
    file:close()
  end
end

local function LoadWindowState()
  local file = io.open('windowstate.json', 'r')
  if file then
    local content = file:read('*all')
    file:close()
    windowstate.Current = json.decode(content)
  elseif not file then
    return
  end
end

local function DrawWindowHider()
  if not cetopen then
    return
  end
  if ImGui.Begin("Window Hider Tool") then
    if ImGui.BeginMenu("ImGui Builder Mods") then
      if ImGui.Button("Toggle TeaTweaks Mod") then
        if windowstate.Current.mywindowhidden == true then
          windowstate.Current.mywindowhidden = false
          SaveWindowState()
        elseif windowstate.Current.mywindowhidden == false then
          windowstate.Current.mywindowhidden = true
          SaveWindowState()
        end
      end
      ImGui.EndMenu()
    end
    ImGui.End()
  end
end

local function DrawButtons()
  if not cetopen or windowstate.Current.mywindowhidden == true then
    return
  end
  ImGui.SetNextWindowSize(640, 216, ImGuiCond.FirstUseEver)
  UL.ImGui_Init()
  if ImGui.Begin('TeaTweaks', true) then

    DS.debug = ImGui.SliderInt('Debug', DS.debug, 0, 5)
    DS.apply_on_init = ImGui.Checkbox('Apply on Game Start', DS.apply_on_init)
    DS.use_filter = ImGui.Checkbox('Filter', DS.use_filter)
    if DS.use_filter then
      DS.filter = ImGui.InputText("", DS.filter, 256)
    end
    DS.index = ImGui.SliderInt('Index', DS.index, 1, 3000)
    DS.range = ImGui.SliderInt('Range', DS.range, 0, 3000)
    if not DS.applied then
      if ImGui.Button('Process Vehicle Records') then
        DS.status = FN.Process()==65535
        DS.applied = DS.status
        DS.status = false
      end
    else
      if ImGui.Button('Restore Vanilla Records') then
        DS.status = FN.Restore()==-65535
        DS.applied = not DS.status
        DS.status = false
      end
    end

    DS.input = ImGui.InputText("Input", DS.input, 512)
    if ImGui.Button('Print Vehicle Type') then FN.PrintVType() end
    if ImGui.Button('Print Engine') then FN.PrintEngine() end
    if ImGui.Button('Print Gears') then FN.PrintGears() end
    ImGui.Text(DS.last_record)

    ImGui.End()
  end
end

registerForEvent('onDraw', function()
  DrawButtons()
  local WindowHiderTool = GetMod("WindowHiderTool")
  if WindowHiderTool and cetopen then
    DrawWindowHider()
  elseif not WindowHiderTool then
    windowstate.Current.mywindowhidden = false
    SaveWindowState()
  end
end)

registerForEvent("onInit", function()
  LoadWindowState()
  if DS.apply_on_init then
    DS.status = FN.Process()==65535
    DS.applied = DS.status
    DS.status = false
  end
end)

registerForEvent('onOverlayOpen', function()
  LoadWindowState()
  cetopen = true
end)

registerForEvent('onOverlayClose', function()
  cetopen = false
  SaveWindowState()
end)
--Original script generated using CET Overlay Window Builder Tool