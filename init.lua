local cetopen = false
local windowstate = {
  Current = {
    mywindowhidden = false,
  },
  Default = {
    mywindowhidden = false,
  }
}

local MS = require('_modsetting')
local UL = require('_utility')
local DS = require('_debug')
local FN = require('_func')
-- local AF = require('_func_aux')
local MV = require('_modvars')

local function SaveModSettings()
  local file = io.open('config.json', 'w+')
  if file then
    file:write(json.encode(MS.Current))
    file:close()
  end
end

local function LoadModSettings()
  local file = io.open('config.json', 'r')
  if file then
    local content = file:read('*all')
    file:close()
    MS.Current = json.decode(content)
  else
    MS.Current = MS.Default
  end
  return 512
end

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
  LoadModSettings()
  ImGui.SetNextWindowSize(512, 720, ImGuiCond.FirstUseEver)
  UL.ImGui_Init()
  if ImGui.Begin('TeaTweaks', true) then

    if ImGui.Button('Load Settings') then
      LoadModSettings()
    end
    ImGui.SameLine()
    if ImGui.Button('Save Settings') then
      SaveModSettings()
    end
    ImGui.SameLine()
    MS.Current.apply_on_init = ImGui.Checkbox('Apply on Game Start', MS.Current.apply_on_init)

    if ImGui.Button('Rebuild Mod Data') then FN.BuildModData() end
    if DS.debug>0 then
      ImGui.SameLine()
      DS.unban = ImGui.Checkbox('Allow Banned Vehicle IDs', DS.unban)
    end
    if not DS.engine_tweaked then
      if ImGui.Button('Process Vehicle Records') then
        DS.status = FN.Process()
        if DS.status~=65535 then DS.index = DS.last_record
        else DS.engine_tweaked = true end
      end
    else
      if ImGui.Button('Restore Vanilla Records') then
        DS.status = FN.Restore()
        if DS.status~=-65535 then DS.index = DS.last_record
        else DS.engine_tweaked = false end
      end
    end
    -- ImGui.SameLine()
    -- if not DS.road_tweaked then
    --   if ImGui.Button('Process Road Friction') then
    --     DS.status = AF.ModifyDrivingFrictionPreset()
    --     if DS.status==32 then DS.road_tweaked = true end
    --   end
    -- else
    --   if ImGui.Button('Restore Road Friction') then
    --     DS.status = AF.RestoreDrivingFrictionPreset()
    --     if DS.status==-32 then DS.road_tweaked = false end
    --   end
    -- end

    DS.debug = ImGui.SliderInt('Debug Level', DS.debug, 0, 5)
    if DS.debug>0 then
      DS.use_filter = ImGui.Checkbox('Filter', DS.use_filter)
      ImGui.SameLine()
      ImGui.Text('Status: ' .. tostring(DS.status))
      ImGui.SameLine()
      ImGui.Text("Last Processed Index: " .. tostring(DS.last_record))
      if DS.use_filter then
        DS.filter = ImGui.InputText("", DS.filter, 256)
      end
      DS.index = ImGui.SliderInt('Index', DS.index, 1, 3000)
      DS.range = ImGui.SliderInt('Range', DS.range, 0, 3000)
      if ImGui.Button('Print Global Profile') then FN.PrintGlobalProfile() end
      ImGui.SameLine()
      if ImGui.Button('Print Unique Profile') then FN.PrintUniqueProfile() end
      ImGui.SameLine()
      if ImGui.Button('Print Banned ID List') then FN.PrintBannedIDList() end
    end

    if FN.PlayerInVehicle() then
      if ImGui.Button('Get Current Vehicle ID') then
        local idvalue = FN.GetCurrentVehicle():GetRecord():GetID().value
        if idvalue~=DS.last_vehicle_id and idvalue~=DS.input then
          DS.last_vehicle_id = DS.input
          DS.input = idvalue
        end
      end
    end

    DS.input = ImGui.InputText('Target ID', DS.input, 256)
    if ImGui.Button('Print Vehicle Detail - Current') then FN.PrintVehicleDetail() end
    if ImGui.Button('Print Vehicle Detail - Vanilla') then FN.PrintVehicleDetail(true) end
    if DS.debug>0 then
      if ImGui.Button('Print Dump TargetID') then FN.PrintRawDump() end
      if ImGui.Button('Print Road Surfaces') then FN.PrintRoadSurfaces() end
      DS.query = ImGui.InputText('Record Type', DS.query, 256)
      if ImGui.Button('Print Originals') then FN.PrintMemory(MV.Originals, DS.query) end
      if ImGui.Button('Print Processed') then FN.PrintMemory(MV.Processed, DS.query) end
    end
  end
  ImGui.End()
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
  DS.status = LoadModSettings()
  DS.status = FN.BuildModData()
  if DS.status~=32767 then print("[TeaTweaks] Mod Data Intialization Failed") end
  DS.status = FN.Process()
  if DS.status~=65535 then print("[TeaTweaks] Processing Failed") end
  DS.engine_tweaked=DS.status==65535
  -- DS.status = AF.ModifyDrivingFrictionPreset()
  -- if DS.status~=32 then print("[TeaTweaks] Road Surface Tweaks Failed") end
  -- DS.road_tweaked=DS.status==32
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