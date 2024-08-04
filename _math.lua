local Math = {}
-- Rules for modifying MinSpeed of gears
Math.ModSMIN = function(Calc, Mod)
  local Out = {}
  local smin_o = Mod.offset.smin
  local smin_m = Mod.multiplier.smin
  for i, _ in ipairs(Calc.smax) do
    local k = i-1
    if k<=1 then -- Reverse and 1st Gear
      table.insert(Out, 0.0)
    else
      table.insert(Out, Calc.smax[k] - smin_o[i] * i * 0.175 * smin_m[i])
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
    local k = i-1
    if k==0 then -- Reverse Gear
      table.insert(Out, smax_o[i] + v * smax_m[i])
    else
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
    local k = i-1
    if k<=1 then -- Reverse and 1st Gear
      table.insert(Out, Orig.rmin[i])
    else
      table.insert(Out, rmin_o[k] * k + v - (v - Orig.rmin[i]) * rmin_m[i])
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
    local k = i-1
    if k<=1 then -- Reverse and 1st Gear
      table.insert(Out, rmax_o[i] + v * rmax_m[i])
    else
      table.insert(Out, rmax_o[k] * k + v * rmax_m[i])
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
    local k = i-1
    if k<=1 then -- Reverse and 1st Gear
      table.insert(Out, tmul_o[i] + v * tmul_m[i])
    else
      table.insert(Out, tmul_o[i] + v * tmul_m[i])
    end
  end
  return Out
end

Abs = function(t)
  local Out = {}
  for _, v in ipairs(t) do table.insert(Out, math.abs(v)) end
  return Out
end

Norm = function(t)
  local Out = {} local denominator = Max(Abs(t))
  if denominator==0 then return nil end
  for _, v in ipairs(Abs(t)) do table.insert(Out, v/denominator) end
  return Out
end

Min = function(t)
  local Min = t[1]
  for _, v in ipairs(t) do if Min > v then Min = v end end
  return Min
end

Max = function(t)
  local Max = t[1]
  for _, v in ipairs(t) do if v > Max then Max = v end end
  return Max
end

Min0 = function(t)
  local Out = {} local floor = Min(t)
  for _, v in ipairs(t) do table.insert(Out, v - floor) end
  return Out
end

Max0 = function(t)
  local Out = {} local ceil = Max(t)
  for _, v in ipairs(t) do table.insert(Out, v - ceil) end
  return Out
end

Min1 = function(t)
  local Out = {} local floor = Min(t)
  for _, v in ipairs(t) do table.insert(Out, v - floor - 1) end
  return Out
end

Max1 = function(t)
  local Out = {} local ceil = Max(t)
  for _, v in ipairs(t) do table.insert(Out, v - ceil + 1) end
  return Out
end

Unit = function(t) return Norm(Min0(t)) end
Nuit = function(t) return Norm(Max0(t)) end

Fwd = function(i, tlen) return (tlen-i)/tlen end
Bwd = function(i, tlen) return i/tlen end
Lerp = function (i, t)
  local floor = Min(t)
  return floor + (Max(t)-floor) * i
end
Logmap = function(t, base)
  local Out = {}
  for _, v in ipairs(t) do
    table.insert(math.log(v, base))
  end
  table.sort(Out)
  return Out
end

return Math