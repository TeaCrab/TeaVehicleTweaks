local TL = require('_tealib')
local MV = require('_modvars')

GetProfile = function(VID, VType, FinalGear)
  if MV.Unique.Content[VID]~=nil then
    if MV.Unique.Content[VID]==true then
      return {
        id = "TeaTweaksDummy",
        gearmods = DummyProfile.gearmods,
        auxprops = DummyProfile.auxprops,
      }
    else
      return {
        id = MV.Unique.ProfileName,
        gearmods = MV.Unique.Content[VID].gearmods,
        auxprops = MV.Unique.Content[VID].auxprops,
      }
    end
  else
    return {
      id = MV.Global.ProfileName,
      gearmods = MV.Global.Content[VType][FinalGear],
      auxprops = MV.Global.Content[VType].auxprops,
      }
  end
end

GetAuxProp = function(Profile, Prop)
  if Profile==nil then
    return DummyProfile.auxprops[Prop]
  else
    if Profile[Prop]==nil then
      return DummyProfile.auxprops[Prop]
    else
      return Profile[Prop]
    end
  end
end

ID = function(record)
  if record~=nil then return TL.Try(record:GetID().value, '') end
  return ''
end

DModel = {
  ['Car']  = function(vrec) return TL.Try(vrec:VehDriveModelData(), nil) end,
  ['Bike'] = function(vrec) return TL.Try(vrec:BikeDriveModelData(), nil) end,
  ['Tank'] = function(vrec) return TL.Try(vrec:TankDriveModelData(), nil) end,
}

DModelPath = {
  ['Car'] = ".vehDriveModelData",
  ['Bike'] = ".bikeDriveModelData",
  ['Tank'] = ".tankDriveModelData",
}

DModelRename = {
    ["_inline%d*.*"] = "_DModelData",
    ["%.%l*DriveModelData.*"] = "_DModelData",
  }

EngineRename = {
    ["_inline%d*.*"] = "_EngineData",
    ["%.vehEngineData%$.*"] = "_EngineData",
  }

GearRename = {
    ["_inline%d*.*"] = "_Gear",
    ["_Gear%d*.*"] = "_Gear",
    ["%.vehEngineData%$.*?%.gears%$.*"] = "_EngineData_Gear",
    -- ["%.gears%$.*"] = "_Gear",
  }

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

GetEngineDetail = function(Engine, level)
  local Out = {
    mtorq = Engine:EngineMaxTorque(),
    rpm_0 = Engine:MinRPM(),
    rpm_1 = Engine:MaxRPM(),
    whres = Engine:WheelsResistanceRatio(),
  }
  if level==nil then return Out end
  if level>0 then
    Out.fgtds = Engine:FinalGearTorqueDecimationScalor()
    Out.gc_cd = Engine:GearChangeCooldown()
    Out.gc_tm = Engine:GearChangeTime()
  end
  if level>1 then
    Out.restq = Engine:ResistanceTorque()
    Out.rdird = Engine:ReverseDirDelay()
    Out.fr1gc = Engine:FastR1GearChange()
  end
  if level>2 then
    Out.fwmoi = Engine:FlyWheelMomentOfInertia()
    Out.frrtm = Engine:ForceReverseRPMToMin()
  end
  return Out
end

GetDModel = function(vrec, vtype)
  vtype = vtype or GetType(vrec)
  if vtype==nil then return nil end
  return DModel[vtype](vrec)
end

GetDModelDetail = function(DModel, level)
  local Out = {
    adrag = DModel:AirResistanceFactor(),
    hbrke = DModel:HandbrakeBrakingTorque(),
    bfact = DModel:BrakingFrictionFactor(),
  }
  if level==nil then return Out end
  if level>0 then
    Out.cmass = DModel:Chassis_mass()
    Out.tmass = DModel:Total_mass()
    Out.bfric = DModel:BodyFriction()
  end
  if level>1 then
    Out.wturn = DModel:MaxWheelTurnDeg()
    Out.comos = DModel:Center_of_mass_offset()
  end
  return Out
end

GetFinalGear = function(Engine)
  local FG = {n=0, id=''}
  for i, Gear in ipairs(Engine:Gears()) do FG.n = i-1 FG.id = ID(Gear) end
  return FG
end

GetGearTable = function(Engine)
  local Out = {smin={}, smax={}, rmin={}, rmax={}, tmul= {}}
  local Gears = Engine:Gears()
  if Gears==nil then return Out end
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

local KEY = {
  -- DModel
  {adrag = 'AirResis: '},
  {hbrke = 'HndBrake: '},
  {bfact = 'BrkFctor: '},
  {bfric = 'BdyFrict: '},
  {cmass = 'ChasMass: '},
  {tmass = 'TotlMass: '},
  {wturn = 'MaxWTurn: '},
  {comos = 'CMoffset: '},
  -- Engine
  {mtorq = 'MaxETorq: '},
  {rpm_0 = 'MinEnPRM: '},
  {rpm_1 = 'MaxEnPRM: '},
  {whres = 'WhlResis: '},
  {fgtds = 'FGDecimS: '},
  {gc_cd = 'GCCoolDn: '},
  {gc_tm = 'GChgTime: '},
  {restq = 'ResisTrq: '},
  {rdird = 'RDirDlay: '},
  {fr1gc = 'FastR1GC: '},
  {fwmoi = 'FlyWhlMI: '},
  {frrtm = 'FRrpm2R0: '},
}

Format = function(t, key)
  if t[key]~=nil then return KEY[key] .. TL.Fp2(t[key]) end
  return nil
end

BuildTable = function(t, every)
  every = every or 4
  local Out = {}
  local layer=1
  local index=1
  for _, label in ipairs(KEY) do
    for k, v in pairs(label) do
      if t[k]==nil then goto SKIP end
      if index > layer * every then layer=layer+1 end
      if Out[layer]==nil then Out[layer]={} end
      if type(t[k])=='number' then
        table.insert(Out[layer], v .. TL.Fp2(t[k]))
        index = index + 1
      elseif type(t[k])=='boolean' then
        table.insert(Out[layer], v .. tostring(t[k]))
        index = index + 1
      elseif type(t[k])=='userdata' and t[k].x~=nil then
        table.insert(Out[layer], v .. TL.VecStr(t[k]))
        index = index + (every - index % every)
      end
      ::SKIP::
    end
  end
  return Out
end

PrintEngine= function(EngineTable)
  for _, t in ipairs(BuildTable(EngineTable)) do
    print(TL.Lay(t))
  end
end

PrintDModel = function(DModelTable)
  for _, t in ipairs(BuildTable(DModelTable)) do
    print(TL.Lay(t))
  end
end

PrintGearTable = function(GearTable)
  if GearTable.smin then print("SpdMin: " .. TL.Lay(GearTable.smin)) end
  if GearTable.smax then print("SpdMax: " .. TL.Lay(GearTable.smax)) end
  if GearTable.rmin then print("RpmMin: " .. TL.Lay(GearTable.rmin)) end
  if GearTable.rmax then print("RpmMax: " .. TL.Lay(GearTable.rmax)) end
  if GearTable.tmul then print("TrqMul: " .. TL.Lay(GearTable.tmul)) end
end

CloneDModel = function(vrec, VType, ProfileName)
  -- Clone a new Drive Model based on Vehicle Record
  local DModel = GetDModel(vrec, VType)
  local DMID = ID(DModel)
  DModelRename['Vehicle%.'] = ProfileName .. '.'
  local _DMID = TL.SubSub(DMID, DModelRename)
  -- Cloning Errors
  if not TweakDB:CloneRecord(_DMID, DModel:GetID()) then
    TL.Dbg(3, "Wrn.CloneDModel() - TweakDB:CloneRecord() Failed")
  end
  MV.Processed.DModels[DMID] = _DMID
  if MV.Originals.DModels[_DMID]==nil then
    MV.Originals.DModels[_DMID] = DMID
  end
  return TweakDB:GetRecord(_DMID)
end

SetDModel = function(vrec, VType, NewDModel)
  -- Set Vehicle Record to use a specific Engine
  local VID = ID(vrec)
  local _EID = ID(NewDModel)
  local Path = VID .. DModelPath[VType]
  TL.Dbg(4, Path .. ' = ' .. _EID)
  return TweakDB:SetFlat(Path, NewDModel:GetID())
end

CloneEngine = function(vrec, ProfileName)
  -- Clone a new Engine based on Vehicle Record
  local Engine = GetEngine(vrec)
  local EID = ID(Engine)
  EngineRename['Vehicle%.'] = ProfileName .. '.'
  local _EID = TL.SubSub(EID, EngineRename)
  -- Cloning Errors
  if not TweakDB:CloneRecord(_EID, Engine:GetID()) then
    TL.Dbg(3, "Wrn.CloneEngine() - TweakDB:CloneRecord() Failed")
  end
  MV.Processed.Engines[EID] = _EID
  if MV.Originals.Engines[_EID]==nil then
    MV.Originals.Engines[_EID] = EID
  end
  return TweakDB:GetRecord(_EID)
end

SetEngine = function(vrec, NewEngine)
  -- Set Vehicle Record to use a specific Engine
  local VID = ID(vrec)
  local _EID = ID(NewEngine)
  local Path = VID .. ".vehEngineData"
  TL.Dbg(4, Path .. ' = ' .. _EID)
  return TweakDB:SetFlat(Path, NewEngine:GetID())
end

CloneGearsFlat = function(Engine, ProfileName)
  local Out = {}
  local Error = false
  -- Process Each Gears for the Engine Record
  GearRename['Vehicle%.'] = ProfileName .. '.'
  for i, Gear in ipairs(Engine:Gears()) do
    local GID = ID(Gear)
    local _GID = TL.SubSub(GID, GearRename) .. i-1
    Error = not TweakDB:CloneRecord(_GID, Gear:GetID()) or Error
    MV.Processed.Gears[GID] =_GID
    if MV.Originals.Gears[_GID]==nil then
      MV.Originals.Gears[_GID] = GID
    end
    TL.Dbg(5, GID .. ' => ' .. _GID)
    table.insert(Out, _GID)
  end
  -- Cloning Errors
  if Error and TL.Dbg(4) then
    print("Wrn.CloneGearsFlat() - TweakDB:CloneRecord() Failed")
  end
  return Out
end

SetGearsFlat = function(Engine, GearTable)
  local EID = ID(Engine)
  return TweakDB:SetFlat(EID .. '.gears', GearTable)
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
  TL.Dbg(5, "Gears Modifications Applied")
  goto SKIPERROR
  ::ERRORS::
  print("Err.SetGearsProp()." .. Err .. " - " .. GID .. " - Failed")
  ::SKIPERROR::
end