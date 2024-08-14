local TL = require('_tealib')
local DS = require('_debug')
local MM = require('_math')
local MV = require('_modvars')
local UD = require('__userdata')
require('_func_helper')

local Func = {}

Func.BuildModData = function()
  print("TeaVehicleTweaks Reading User Data...")
  local VREC_TABLE = TweakDB:GetRecords('gamedataVehicle_Record')
  for _, VREC in ipairs(VREC_TABLE) do
    local VID = ID(VREC)
    MV.Unique.ProfileName = UD.ProfileName
    for k, user_data in pairs(UD.Content) do
      if string.match(VID, k) then
        MV.Unique.Content[VID] = user_data
      end
    end
    for _, k in ipairs(MV.BanFilter) do
      if string.match(VID, k) then
        MV.Banned[VID] = true
      end
    end
  end
  print("TeaVehicleTweaks - Mod Data Initialization Complete")
  -- Crude indication of all user data has being read without major error.
  return 32767
end

Func.PrintRoadSurfaces = function()
  for i, k in ipairs(TweakDB:GetRecords('gamedataVehicleWheelsFrictionPreset_Record')) do
    print(i, ID(k) .. ".frictionPreset")
    print("\t.fristionLatMultiplier", k:FrictionLatMultiplier())
    print("\t.fristionLatMultiplier", k:FrictionLongMultiplier())
  end
end

Func.PrintMemory = function(target, prop)
  print("Printing " .. TL.Inf(tostring(target)) .. TL.Dot(prop))
  if prop==nil then
    for k, v in pairs(target) do
      print(k, v)
    end
  else
    for k, v in pairs(target[prop]) do
      print(k .. " - " .. v)
    end
  end
  print("Print Complete - " .. TL.Inf(tostring(target)) .. TL.Dot(prop))
end

Func.PrintGlobalProfile = function()
  print("Printing " .. MV.Global.ProfileName)
  for k, v in pairs(MV.Global.Content) do
    print(k)
    local sorted = table.sort(v)
    TL.TPrint(sorted)
  end
  print("Print Complete - " .. MV.Global.ProfileName)
end

Func.PrintUniqueProfile = function()
  local count = 0
  print("Printing " .. MV.Unique.ProfileName)
  for k, _ in pairs(MV.Unique.Content) do
    print(k)
    count = count + 1
  end
  print("Print Complete - " .. MV.Global.ProfileName, "Total: " .. count)
end

Func.PrintBannedIDList = function()
  local count = 0
  print("Printing Banned")
  for k, _ in pairs(MV.Banned) do
    print(k)
    count = count + 1
  end
  print("Print Complete - Banned Total: " .. count)
end

Func.PrintRawDump = function()
  local Raw = TweakDB:GetRecord(DS.input)
  if Raw~=nil then print(Dump(Raw, false)) end
end

Func.PlayerInVehicle = function()
  local Player = Game.GetPlayer()
  local WS = Game.GetWorkspotSystem()
  if WS then
    return Player and WS:IsActorInWorkspot(Player)
      and WS:GetExtendedInfo(Player).isActive
      and Func.GetCurrentVehicle()~=nil
  end
end

Func.GetCurrentVehicle = function()
  return Game['GetMountedVehicle;GameObject'](Game.GetPlayer())
end

Func.PrintVehicleDetail = function(original)
  local VREC = TweakDB:GetRecord(DS.input)
  if VREC==nil then print("Invalid Vehicle ID") return end
  local VType = GetType(VREC)
  if VType=='' then print("Invalid Vehicle Type") return end
  local DModel = GetDModel(VREC, VType)
  if DModel==nil then print("Invalid Vehicle DriveModel") return end
  local Engine = GetEngine(VREC)
  if Engine==nil then print("Invalid Vehicle Engine") return end
  if original~=nil then
    DModel = TweakDB:GetRecord(MV.Originals.DModels[ID(DModel)])
    Engine = TweakDB:GetRecord(MV.Originals.Engines[ID(Engine)])
    if DModel==nil then print("Invalid Vehicle DriveModel") end
    if Engine==nil then print("Invalid Vehicle Engine") end
  end
  print(VType, ID(DModel), ID(Engine))
  PrintEngine(GetEngineDetail(Engine, DS.debug))
  PrintDModel(GetDModelDetail(DModel, DS.debug))
  print(GetFinalGear(Engine).id)
  PrintGearTable(GetGearTable(Engine))
end

Func.Filter = function(i, VID, VType)
  if not DS.unban then
    -- If Debug Level 5, don't skip processing banned vehicle IDs
    if VType~='Bike' and VType~='Car' and VType~='Tank' then return true end
    if MV.Banned[VID]~=nil then return true end
  end
  if TL.Dbg(1) and i~=0 then
    if DS.use_filter then
      DS.count = DS.count + 1
      return not string.match(VID, DS.filter) or DS.count>DS.range
    else return i-DS.range>DS.index or i<DS.index end
  end
  -- Try to skip the processing of unconventional vehicles
  if VType~='Bike' and VType~='Car' and VType~='Tank' then return true end
  if MV.Banned[VID]~=nil then return true end
end

Func.Restore = function()
  print("TeaVehicleTweaks Restoring...")
  DS.count = 0
  local VREC_TABLE = TweakDB:GetRecords('gamedataVehicle_Record')
  for i, VREC in ipairs(VREC_TABLE) do
    DS.last_record = i
    local VID = ID(VREC)
    local VType = GetType(VREC)
    if Func.Filter(0, VID, VType) then
      TL.Dbg(2, TL.Lay({i, TL.Ind("Not Processed"), VID})) goto SKIP
    else
      TL.Dbg(2, TL.Lay({i, VType, VID}))
    end
    -- Restore DriveModel to Original
    local DModel = GetDModel(VREC, VType)
    if DModel==nil then TL.Dbg(0, VID .. " - Vehicle DriveModel not Found!") end
    local DMID = ID(DModel)
    local _DModel
    local _DMID
    if MV.Originals.DModels[DMID]~=nil then -- Original DriveModel found
      _DModel = TweakDB:GetRecord(MV.Originals.DModels[DMID])
      _DMID = ID(_DModel)
      if not TweakDB:SetFlat(VID .. DModelPath[VType], _DModel:GetID()) then
        TL.Dbg(0, VID .. ' => ' .. _DMID .. " - Restore Original Flat Failed")
      end
    else -- Original DriveModel Not Found
      _DModel = DModel
      _DMID = DMID
    end
    -- Restore Engine to Vanilla
    local Engine = GetEngine(VREC)
    if Engine==nil then TL.Dbg(0, VID .. " - Vehicle Engine not Found!") end
    local EID = ID(Engine)
    local _Engine
    local _EID
    if MV.Originals.Engines[EID]~=nil then -- Original Engine Found
      _Engine = TweakDB:GetRecord(MV.Originals.Engines[EID])
      _EID = ID(_Engine)
      if not TweakDB:SetFlat(VID .. '.vehEngineData', _Engine:GetID()) then
        TL.Dbg(0, VID .. ' => ' .. _EID .. " - Restore Original Flat Failed")
      end
    else -- Original Engine Not Found
      _Engine = Engine
      _EID = EID
    end
    TweakDB:Update(VREC)
    TL.Dbg(1, DMID .. ' => ' .. _DMID)
    TL.Dbg(1, EID .. ' => ' .. _EID)
    if TL.Dbg(1) then PrintGearTable(GetGearTable(_Engine)) end
    ::SKIP::
  end
  print("TeaVehicleTweaks - Restoration Complete")
  -- Crude indication of all restoration has finished without major error.
  return -65535
end

Func.Process = function()
  DS.count = 0
  local VREC_TABLE = TweakDB:GetRecords('gamedataVehicle_Record')
  print("TeaVehicleTweaks Processing...")
  for i, VREC in ipairs(VREC_TABLE) do
    DS.last_record = i
    local VID = ID(VREC)
    local VType = GetType(VREC)
    if Func.Filter(i, VID, VType) then
      TL.Dbg(2, TL.Lay({i, TL.Ind("Ignored" .. VType), VID})) goto SKIP
    else
      TL.Dbg(1, '\t' .. TL.Lay({i, TL.Ind("Valid:" .. VType), VID}))
    end
    local DModel = GetDModel(VREC, VType)
    if DModel==nil then TL.Dbg(1, VID .. " - Vehicle DriveModel not Found!") goto SKIP end
    local DMID = ID(DModel)
    local Engine = GetEngine(VREC)
    if Engine==nil then TL.Dbg(1, VID .. " - Vehicle Engine not Found!") goto SKIP end
    local EID = ID(Engine)
    local OrigGears = GetGearTable(Engine)
    if OrigGears==nil then TL.Dbg(1, VID .. " - Engine Gears not Found!") goto SKIP end
    local Profile = GetProfile(VID, VType, GetFinalGear(Engine).n)
    -- Drive Model
    local _DModel
    local _DMID
    if MV.Processed.DModels[DMID]==nil and MV.Originals.DModels[DMID]==nil then -- DriveModel not found in Mod's Memory => Not processed
      _DModel = CloneDModel(VREC, VType, Profile.id)
      _DMID = ID(_DModel)
      if not SetDModel(VREC, VType, _DModel) then
        print("Error.SetDModel() - " .. _DMID .. " Failed") goto SKIP
      end
      if not TweakDB:SetFlat(_DMID .. '.airResistanceFactor', DModel:AirResistanceFactor() * GetAuxProp(Profile.auxprops, 'AirResis')) then
        print("Wrn.SetFlat() - AirResistanceFactor Failed")
      end
      if not TweakDB:SetFlat(_DMID .. '.handbrakeBrakingTorque', DModel:HandbrakeBrakingTorque() * GetAuxProp(Profile.auxprops, 'HandBrak')) then
        print("Wrn.SetFlat() - HandbrakeBrakingTorque Failed")
      end
      if not TweakDB:SetFlat(_DMID .. '.brakingFrictionFactor', DModel:BrakingFrictionFactor() * GetAuxProp(Profile.auxprops, 'BrakeFac')) then
        print("Wrn.SetFlat() - BrakingFrictionFactor Failed")
      end
    elseif string.match(DMID, Profile.id .. '.') then -- Already using modified Engines
      _DModel = DModel
      _DMID = DMID
    else -- DriveModel found in Mod's Memory => Already Processed, just need to set the vehicle to use it
      _DModel = TweakDB:GetRecord(MV.Processed.DModels[DMID])
      _DMID = ID(_DModel)
      TL.Dbg(1, DMID .. ' => ' .. _DMID)
      SetDModel(VREC, VType, _DModel)
    end
    -- Engine
    local _Engine
    local _EID
    if MV.Processed.Engines[EID]==nil and MV.Originals.Engines[EID]==nil then -- Neither Original nor Modified found in Memory => Not processed
      _Engine = CloneEngine(VREC, Profile.id)
      _EID = ID(_Engine)
      if not SetEngine(VREC, _Engine) then
        print("Error.SetEngine() - " .. _EID .. " Failed") goto SKIP
      end
      if not SetGearsFlat(_Engine, CloneGearsFlat(Engine, Profile.id)) then
        print("Error.SetGearsFlat() - " .. _EID .. " Failed") goto SKIP
      end
      local CalcGears = {}
      CalcGears.smax = MM.ModSMAX(OrigGears, Profile.gearmods)
      CalcGears.smin = MM.ModSMIN(CalcGears, Profile.gearmods)
      CalcGears.rmax = MM.ModRMAX(OrigGears, Profile.gearmods)
      CalcGears.rmin = MM.ModRMIN(OrigGears, CalcGears, Profile.gearmods)
      CalcGears.tmul = MM.ModTMUL(OrigGears, Profile.gearmods)
      -- Wheel Resistance
      if not TweakDB:SetFlat(_EID .. '.wheelsResistanceRatio', Engine:WheelsResistanceRatio() + GetAuxProp(Profile.auxprops, 'WhRRatio')) then
        print("Wrn.SetFlat() - BrakingFrictionFactor Failed")
      end
      -- PrintGearTable(CalcGears)
      SetGearsProp(_Engine, CalcGears)
    elseif string.match(EID, Profile.id .. '.') then -- Already using modified Engines
      _Engine = Engine
      _EID = EID
    else -- Engine found in Mod's Memory => Already Processed, just need to set the vehicle to use it
      _Engine = TweakDB:GetRecord(MV.Processed.Engines[EID])
      _EID = ID(_Engine)
      if not SetEngine(VREC, _Engine) then
        print("Error.SetEngine() - " .. _EID .. " Failed") goto SKIP
      end
    end
    TL.Dbg(1, DMID .. ' => ' .. _DMID)
    TL.Dbg(1, EID .. ' => ' .. _EID)
    TL.Dbg(2, _EID .. ".gears" .. ' = ...' .. GetFinalGear(_Engine).id)
    TweakDB:Update(VREC)
    if TL.Dbg(1) then PrintGearTable(GetGearTable(_Engine)) end
    ::SKIP::
  end
  -- Crude indication of all processing has finished without major error.
  print("TeaVehicleTweaks - Processing Complete")
  return 65535
end

return Func