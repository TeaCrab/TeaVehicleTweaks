local TL = require('_tealib')
local MT = require('_modtable')

local ModData = {
  ModName = "TeaTweaks"
}

ModData.EngineRename = {
  ["Vehicle%."] = ModData.ModName .. '.',
  ["_inline%d*.*"] = "_EngineData",
  ["%.vehEngineData.*"] = "_EngineData",
}

ModData.GearRename = {
  ["Vehicle%p"] = ModData.ModName .. '.',
  ["_inline%d*.*"] = "_Gear",
  ["_Gear%d*.*"] = "_Gear",
}

ModData.Originals = {
  Engines = {},
  Gears = {},
  DModels = {},
}

ModData.Processed = {
  Engines = {},
  Gears = {},
  DModels = {},
}

ModData.ModTable = {
  ['Bike'] = {
    [5] = MT.BikeGear5,
    [6] = MT.BikeGear6,
    [7] = MT.BikeGear7,
  },
  ['Car'] = {
    [5] = MT.CarGear5,
    [6] = MT.CarGear6,
    [7] = MT.CarGear7,
  }
}

ModData.DriveModel = {
  ['Car']  = function(vrec) return TL.Try(vrec:VehDriveModelData(), nil) end,
  ['Bike'] = function(vrec) return TL.Try(vrec:BikeDriveModelData(), nil) end,
  ['Tank'] = function(vrec) return TL.Try(vrec:TankDriveModelData(), nil) end,
}

return ModData