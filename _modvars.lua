DummyProfile = {
  auxprops = {
    AirResis = 1.0,
    HandBrak = 1.0,
    BrakeFac = 1.0,
    WhRRatio = 0.0,
  },
  gearmods = {
    offset = {
      -- Gears      R   1st   2nd   3rd   4th   5th   6th   7th
      smin = {    0,    0,    0,    0,    0,    0,    0,    0},
      smax = {    0,    0,    0,    0,    0,    0,    0,    0},
      rmin = {    0,    0,    0,    0,    0,    0,    0,    0},
      rmax = {    0,    0,    0,    0,    0,    0,    0,    0},
      tmul = {    0,    0,    0,    0,    0,    0,    0,    0},
    },
    multiplier = {
      -- Gears      R   1st   2nd   3rd   4th   5th   6th   7th
      smin = {  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0},
      smax = {  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0},
      rmin = {  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0},
      rmax = {  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0},
      tmul = {  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0},
    },
  }
}

local ModVars = {}
ModVars.Profile_GID = ''
ModVars.Profile_UID = ''
ModVars.Unique = {
  ProfileName = '',
  Content = {}, -- Vehicle record ID that matches profile_filter in __userdata will be added here.
}
ModVars.Global = require('__moddata')
ModVars.Banned = {} -- Vehicle record ID that matches BanFilter will be added here
ModVars.BanFilter = {
  "Vehicle%.av_",
  "Vehicle%.s?q%d*.*_av",
  "Vehicle%.s?q%d*.*_crane",
  "Vehicle%.s?q%d*.*_drone",
  "Vehicle%.s?q%d*.*_train",
  "Vehicle%.s?q%d*.*_train_car.*",
  -- These are patterns matching the game's "Fake" vehicle records
  -- they are likely not drivable, and lacks the components for the mod to process them
}

-- During the 1st pass of Processing - Game Records being cloned and swapped,
-- the {new_id, original_id} key, value pairs are added here according to the type
-- this is how the Restoration function works.
ModVars.Originals = {
  Engines = {},
  Gears = {},
  DModels = {},
  RoadFricPreset = {},
  Light = {},
}
-- This is the reverse of Originals, where the key value pairs are:
-- {original_id, new_id}
-- This is used to prevent the same record being cloned/modified multiple times.
ModVars.Processed = {
  Engines = {},
  Gears = {},
  DModels = {},
  RoadFricPreset = {},
  Light = {},
}

return ModVars