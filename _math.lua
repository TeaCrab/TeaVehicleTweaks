local Math = {}
-- Rules for modifying MinSpeed of gears
Math.ModSMIN = function(Calc, Mod)
  local Out = {}
  local smin_o = Mod.offset.smin
  local smin_m = Mod.multiplier.smin
  for i, _ in ipairs(Calc.smax) do
    if i-1<=1 then -- Reverse and 1st Gear Starts at 0
      table.insert(Out, 0.0)
    else -- Based on Calculated Max Speed
      table.insert(Out, Calc.smax[i-1] - smin_o[i] * i * 0.175 * smin_m[i])
    end
  end
  return Out
end

-- Rules for modifying MaxSpeed of gears
Math.ModSMAX = function(Orig, Mod)
  local Out = {}
  local smax_o = Mod.offset.smax
  local smax_m = Mod.multiplier.smax
  for i, v in ipairs(Orig.smax) do
    if i-1==0 then
      table.insert(Out, smax_o[i] + v * smax_m[i])
    else -- Simple Offset & Multiplier of Vanilla Gear
      table.insert(Out, smax_o[i] * i + v * smax_m[i])
    end
  end
  return Out
end

-- Rules for modifying MinEngineRPM of gears
Math.ModRMIN = function(Orig, Calc, Mod)
  local Out = {}
  local rmin_o = Mod.offset.rmin
  local rmin_m = Mod.multiplier.rmin
  for i, v in ipairs(Calc.rmax) do
    if i-1<=0 then
      table.insert(Out, Orig.rmin[i])
    else -- Simple Offset & Multiplier of Vanilla Gear
      table.insert(Out, rmin_o[i] * i + v - (v - Orig.rmin[i]) * rmin_m[i])
    end
  end
  return Out
end

-- Rules for modifying MaxEngineRPM of gears
Math.ModRMAX = function(Orig, Mod)
  local Out = {}
  local rmax_o = Mod.offset.rmax
  local rmax_m = Mod.multiplier.rmax
  for i, v in ipairs(Orig.rmax) do
    if i-1==0 then
      table.insert(Out, rmax_o[i] + v * rmax_m[i])
    else -- Simple Offset & Multiplier of Vanilla Gear
      table.insert(Out, rmax_o[i] * i + v * rmax_m[i])
    end
  end
  return Out
end

-- Rules for modifying TorqueMultiplier of gears
Math.ModTMUL = function(Orig, Mod)
  local Out = {}
  local tmul_o = Mod.offset.tmul
  local tmul_m = Mod.multiplier.tmul
  for i, v in ipairs(Orig.tmul) do
    if i-1==0 then
      table.insert(Out, tmul_o[i] + v * tmul_m[i])
    else -- Simple Offset & Multiplier of Vanilla Gear
      table.insert(Out, tmul_o[i] * i + v * tmul_m[i])
    end
  end
  return Out
end

return Math