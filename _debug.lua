local DebugSettings = {
  road_tweaked = false,
  engine_tweaked = false,
  force_reapply = false,
  status = 0,
  show_profiles = false,
  debug = 0,
  unban = false,
  use_filter = false,
  filter = 'kusanagi',
  last_record = 0,
  last_vehicle_id = '',
  index = 1,
  range = 0,
  count = 0,
  input = 'kusanagi',
  query = 'DModels',
}

function DumpVariable(var, filename)
  filename = filename or '_debug'
  local file = io.open(filename .. '.log', 'w')
  if file then
    file:write(json.encode(var))
    file:close()
  end
end

return DebugSettings