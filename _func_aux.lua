TL = require('_tealib')
DS = require('_debug')
local AuxFunc = {}

FricData_Orig = {}

FricData_Proc = {
  ['Bike'] = {
    lat = 1.37,
    long = 1.77,
  },
  ['Car'] = {
    lat = 1.37,
    long = 1.49
  }
}

Prop = {
  lat = ".frictionLatMultiplier",
  long = ".frictionLongMultiplier",
}

GetFlatProp = function(rid, prop)
  return TweakDB:GetFlat(rid .. Prop[prop])
end

SetFlatProp = function(rid, prop, mult)
  return TweakDB:SetFlat(rid .. Prop[prop], FricData_Orig[rid][prop] * mult[prop])
end

ResetFlatProp = function(rid, prop)
  return TweakDB:SetFlat(rid .. Prop[prop], FricData_Orig[rid][prop])
end

PrintFlatChange = function(rid, prop)
  print(rid, Prop[prop], '=', TL.Fp2(FricData_Orig[rid][prop]), '=>', TL.Fp2(GetFlatProp(rid, prop)))
end

AuxFunc.ModifyDrivingFrictionPreset = function()
  local DFREC= TweakDB:GetRecords('gamedataVehicleWheelsFrictionPreset_Record')
  for _, REC in ipairs(DFREC) do
    local RID = ID(REC)
    if FricData_Orig[RID]==nil then
      FricData_Orig[RID] = {}
      FricData_Orig[RID].lat = GetFlatProp(RID, 'lat')
      FricData_Orig[RID].long = GetFlatProp(RID, 'long')
    end
    local error = false
    if string.match(RID, 'BikeDriv') then
      error = error or not SetFlatProp(RID, 'lat', FricData_Proc['Bike'])
      error = error or not SetFlatProp(RID, 'long', FricData_Proc['Bike'])
    elseif string.match(RID, 'CarDriv') then
      error = error or not SetFlatProp(RID, 'lat', FricData_Proc['Car'])
      error = error or not SetFlatProp(RID, 'long', FricData_Proc['Car'])
    end
    if error then
      print(RID .. " - SetFlat() Failed")
    elseif DS.debug>0 then
      PrintFlatChange(RID, 'lat')
      PrintFlatChange(RID, 'long')
    end
  end
  return 32
end

AuxFunc.RestoreDrivingFrictionPreset = function()
  local DFREC= TweakDB:GetRecords('gamedataVehicleWheelsFrictionPreset_Record')
  for _, REC in ipairs(DFREC) do
    local RID = ID(REC)
    local error = false
    if string.match(RID, 'BikeDriv') then
      error = error or not ResetFlatProp(RID, 'lat')
      error = error or not ResetFlatProp(RID, 'long')
    elseif string.match(RID, 'CarDriv') then
      error = error or not ResetFlatProp(RID, 'lat')
      error = error or not ResetFlatProp(RID, 'long')
    end
    if error then
      print(RID .. " - SetFlat() Failed")
    elseif DS.debug>0 then
        PrintFlatChange(RID, 'lat')
        PrintFlatChange(RID, 'long')
    end
  end
  return -32
end

return AuxFunc