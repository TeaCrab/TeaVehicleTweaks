local DS = require('_debug')
local MM = require('_math')
local MD = require('_moddata')
local TL = require('_tealib')

ID = function(record)
  if record~=nil then
    return TL.Try(record:GetID().value, '')
  else
    return ''
  end
end

GetType = function(vrec)
  if vrec:Type()~=nil then
    ---@type string
    return vrec:Type():EnumName()
  else
    return ''
  end
end

GetEngine = function(vrec)
  return TL.Try(vrec:VehEngineData(), nil)
end

GetDModel = function(vrec, vtype)
  vtype = vtype or GetType(vrec)
  if vtype==nil then return nil end
  return MD.DriveModel[vtype](vrec)
end

CloneEngine = function(vrec)
  -- Clone a new Engine based on Vehicle Record
  local Engine = GetEngine(vrec)
  local EID = ID(Engine)
  local _EID = TL.SubSub(EID, MD.EngineRename)
  -- Cloning Errors
  if not TweakDB:CloneRecord(_EID, Engine:GetID()) and DS.debug>1 then
    print("Wrn.NewEngine() - TweakDB:CloneRecord()")
  end
  MD.Processed.Engines[EID] = _EID
  MD.Originals.Engines[_EID] = EID
  if DS.debug>0 then print(EID .. ' => ' .. _EID) end
  return TweakDB:GetRecord(_EID)
end

SetEngine = function(vrec, NewEngine)
  -- Set Vehicle Record to use a specific Engine
  local VID = ID(vrec)
  local _EID = ID(NewEngine)
  local Path = VID .. ".vehEngineData"
  if DS.debug>2 then print(Path .. ' = ' .. _EID) end
  return TweakDB:SetFlat(Path, NewEngine:GetID())
end

CloneGearsFlat = function(Engine)
  local Out = {}
  local Error = false
  -- Process Each Gears for the Engine Record
  for i, Gear in ipairs(Engine:Gears()) do
    local GID = ID(Gear)
    local _GID = TL.SubSub(GID, MD.GearRename) .. i-1
    Error = not TweakDB:CloneRecord(_GID, Gear:GetID()) or Error
    MD.Processed.Gears[GID] =_GID
    MD.Originals.Gears[_GID] = GID
    if DS.debug>3 then print(GID .. ' => ' .. _GID) end
    table.insert(Out, _GID)
  end
  -- Cloning Errors
  if Error and DS.debug>1 then
    print("Wrn.NewGearsFlat() - TweakDB:CloneRecord()")
  end
  return Out
end

SetGearsFlat = function(Engine, GearTable)
  local EID = ID(Engine)
  local FGID = ''
  local Path = EID .. '.gears'
  for _, v in ipairs(GearTable) do FGID = v end
  if DS.debug>0 then print(Path .. ' = ...' .. FGID) end
  return TweakDB:SetFlat(Path, GearTable)
end

SetGearsProp = function(Engine, CalcGears)
  local GID
  local Err = ''
  for i, Gear in ipairs(Engine:Gears()) do
    GID = ID(Gear)
    if CalcGears.smin then Err='smin' if not TweakDB:SetFlat(
      GID .. '.minSpeed', CalcGears.smin[i]) then goto ERRORS end
    end
    if CalcGears.smax then Err='smax' if not TweakDB:SetFlat(
      GID .. '.maxSpeed', CalcGears.smax[i]) then goto ERRORS end
    end
    if CalcGears.rmin then Err='rmin' if not TweakDB:SetFlat(
      GID .. '.minEngineRPM', CalcGears.rmin[i]) then goto ERRORS end
    end
    if CalcGears.rmax then Err='rmax' if not TweakDB:SetFlat(
      GID .. '.maxEngineRPM', CalcGears.rmax[i]) then goto ERRORS end
    end
    if CalcGears.tmul then Err='tmul' if not TweakDB:SetFlat(
      GID .. '.torqueMultiplier', CalcGears.tmul[i]) then goto ERRORS end
    end
  end
  if DS.debug>0 then print("Gears Modifications Applied") end
  goto SKIPERROR
  ::ERRORS::
  print("Err.SetGearsProp()." .. Err .. " - " .. GID .. " - Failed")
  ::SKIPERROR::
end

GetFinalGear = function(Engine)
  FG = 0 for i, _ in ipairs(Engine:Gears()) do FG = i-1 end return FG
end

GetGearTable = function(Engine)
  local Out = {smin={}, smax={}, rmin={}, rmax={}, tmul= {}}
  local Gears = Engine:Gears()
  if Gears==nil then return nil end
  for _, Gear in ipairs(Gears) do
    table.insert(Out.smin, Gear:MinSpeed())
    table.insert(Out.smax, Gear:MaxSpeed())
    table.insert(Out.rmin, Gear:MinEngineRPM())
    table.insert(Out.rmax, Gear:MaxEngineRPM())
    table.insert(Out.tmul, Gear:TorqueMultiplier())
  end
  ::SKIP::
  return Out
end

PrintGearTable = function(GearTable)
  if GearTable.smin then print("SpdMin: " .. TL.Lay(GearTable.smin)) end
  if GearTable.smax then print("SpdMax: " .. TL.Lay(GearTable.smax)) end
  if GearTable.rmin then print("RpmMin: " .. TL.Lay(GearTable.rmin)) end
  if GearTable.rmax then print("RpmMax: " .. TL.Lay(GearTable.rmax)) end
  if GearTable.tmul then print("TrqMul: " .. TL.Lay(GearTable.tmul)) end
end

local Func = {
}

Func.Filter = function(i, VID, VType)
  if DS.debug>0 then
    if DS.use_filter then
      DS.count = DS.count + 1
      return not string.match(VID, DS.filter) or DS.count>DS.range
    else return i-DS.range>DS.index or i<DS.index end
  end
  -- Try to skip the processing of unconventional vehicles
  if VType=='Bike' or VType=='Car' or VType=='Tank' then
    return string.match(VID, "Vehicle%.av_")
      or string.match(VID, "Vehicle%.s?q%d*.*_av")
      or string.match(VID, "Vehicle%.s?q%d*.*_crane")
      or string.match(VID, "Vehicle%.s?q%d*.*_drone")
  else return true end
end

Func.PrintVType = function()
  local VREC = TweakDB:GetRecord(DS.input)
  print(GetType(VREC))
end

Func.PrintEngine = function()
  local VREC = TweakDB:GetRecord(DS.input)
  print(ID(GetEngine(VREC)))
end

Func.PrintGears = function()
  local VREC = TweakDB:GetRecord(DS.input)
  PrintGearTable(GetGearTable(GetEngine(VREC)))
end

Func.Restore = function()
  DS.count = 0
  local VREC_TABLE = TweakDB:GetRecords('gamedataVehicle_Record')
  for i, VREC in ipairs(VREC_TABLE) do
    DS.last_record = i
    local VID = ID(VREC)
    local VType = GetType(VREC)
    if Func.Filter(i, VID, VType) then goto SKIP
    else print('\t' .. TL.Lay({i, VID .. ': ' .. VType}))
    end
    local Engine = GetEngine(VREC)
    if Engine==nil then print(VID .. " - Vehicle Engine not Found!") goto SKIP end
    local EID = ID(Engine)
    local _Engine
    Path = EID .. '.vehEngineData'
    if MD.Originals.Engines[EID] then
      local Original = TweakDB:GetRecord(MD.Originals.Engines[EID]):GetID()
      if not TweakDB:SetFlat(VID .. '.vehEngineData', Original) then
        print(VID .. ': ' .. Original.value .. " - Restore Original Flat Failed")
      end
    end
    _Engine = GetEngine(VREC)
    if DS.debug>0 then PrintGearTable(GetGearTable(_Engine)) end
    ::SKIP::
  end
  -- Crude indication of all restoration has finished without major error.
  return -65535
end

Func.Process = function()
  DS.count = 0
  local VREC_TABLE = TweakDB:GetRecords('gamedataVehicle_Record')
  print("TeaTweaks...")
  for i, VREC in ipairs(VREC_TABLE) do
    DS.last_record = i
    local VID = ID(VREC)
    local VType = GetType(VREC)
    if Func.Filter(i, VID, VType) then goto SKIP
    else print('\t' .. TL.Lay({i, VID .. ': ' .. VType}))
    end
    local Engine = GetEngine(VREC)
    local _Engine
    if Engine==nil then print(VID .. " - Vehicle Engine not Found!") goto SKIP end
    local OrigGears = GetGearTable(Engine)
    if OrigGears==nil then print(VID .. " - Engine Gears not Found!") goto SKIP end
    local EID = ID(Engine)
    if MD.Processed.Engines[EID]==nil then
      _Engine = CloneEngine(VREC)
      if not SetEngine(VREC, _Engine) then
        print("Error.SetEngine() - " .. ID(_Engine) .. " Failed") goto SKIP
      end
      if not SetGearsFlat(_Engine, CloneGearsFlat(Engine)) then
        print("Error.SetGearsFlat() - " .. ID(_Engine) .. " Failed") goto SKIP
      end
      local CalcGears = {}
      ModTable = MD.ModTable[VType][GetFinalGear(Engine)]
      CalcGears.smax = MM.ModSMAX(OrigGears, ModTable)
      CalcGears.smin = MM.ModSMIN(CalcGears, ModTable)
      CalcGears.rmax = MM.ModRMAX(OrigGears, ModTable)
      CalcGears.rmin = MM.ModRMIN(OrigGears, CalcGears, ModTable)
      CalcGears.tmul = MM.ModTMUL(OrigGears, ModTable)
      -- PrintGearTable(CalcGears)
      SetGearsProp(_Engine, CalcGears)
    else
      _Engine = TweakDB:GetRecord(MD.Processed.Engines[EID])
      if DS.debug>0 then print(EID .. ': ' .. ID(_Engine)) end
      SetEngine(VREC, _Engine)
    end
    TweakDB:Update(VREC)
    if DS.debug>0 then PrintGearTable(GetGearTable(_Engine)) end
    ::SKIP::
  end
  -- Crude indication of all processing has finished without major error.
  return 65535
end

return Func