local DS = require('_debug')
local TeaLib = {}

TeaLib.Lay = function(t, sep)
  sep = sep or '\t'
  local _t= {}
  for _, v in ipairs(t) do
    if type(v)=='number' then
      _t[#_t+1] = tostring(TeaLib.Fp2(v))
    else
      _t[#_t+1] = tostring(v)
    end
  end
  return table.concat(_t, sep)
end

TeaLib.Dbg = function(debug_level, object)
  if object~=nil and DS.debug>=debug_level then print(object)
  else return DS.debug>=debug_level
  end
end

TeaLib.VecStr = function(vec)
  local Out = {}
  if vec.x then table.insert(Out, 'x ' .. TeaLib.Fp2(vec.x)) end
  if vec.y then table.insert(Out, 'y ' .. TeaLib.Fp2(vec.y)) end
  if vec.z then table.insert(Out, 'z ' .. TeaLib.Fp2(vec.z)) end
  return TeaLib.Lay(Out, ', ')
end

TeaLib.Try = function(object, default)
  if object~=nil then
    return object
  else
    return default
  end
end

TeaLib.Rnd = function(n, decimal)
  local p = 10^(decimal or 0)
  return math.floor(n * p + 0.5) / p
end
TeaLib.Fp1 = function(n) return TeaLib.Rnd(n, 1) end
TeaLib.Fp2 = function(n) return TeaLib.Rnd(n, 2) end
TeaLib.Fp3 = function(n) return TeaLib.Rnd(n, 3) end

TeaLib.SubSub = function(s, patterns)
  local Out = s
  for k, v in pairs(patterns) do
    Out = string.gsub(Out, k, v)
  end
  return Out
end

TeaLib.TPrint = function(t, i)
  local count = 0
  i = i or 0
  for k, v in pairs(t) do
    if type(v)=='number' then
      print(tostring(k) .. ": " .. TeaLib.Fp2(v))
    else
      print(tostring(k) .. ": " .. tostring(v))
    end
    count = count + 1
    if i ~= 0 and count >= i then break end
  end
  if t[count+1] then print('...') end
end

TeaLib.TClear = function(t)
  for k, _ in pairs(t) do
    t[k] = nil
  end
end

TeaLib.Test = function()
  print("__TEST__TEST__TEST__")
end

return TeaLib