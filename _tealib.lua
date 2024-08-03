local TeaLib = {}

TeaLib.Lay = function(t, sep)
  sep = sep or '\t'
  local _t= {}
  for _, value in ipairs(t) do
    if type(value)=='number' then
      _t[#_t+1] = tostring(TeaLib.Fp2(value))
    else
      _t[#_t+1] = tostring(value)
    end
  end
  return table.concat(_t, sep)
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
  local out = s
  for k, v in pairs(patterns) do
    out = string.gsub(out, k, v)
  end
  return out
end

TeaLib.Test = function()
  print("__TEST__TEST__TEST__")
end

TeaLib.TPrint = function(t, i)
  local count = 0
  i = i or 0
  for k, v in pairs(t) do
    print(tostring(k) .. ": " .. tostring(v))
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

return TeaLib