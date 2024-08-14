MD = require('__moddata')
MM = require('_math')
local UserData = {
  ProfileName = "TeaTweaksUser",
  Content = {},
}
-- UserData.Content[profile_filter]
-- Any vehicle record ID matches the profile_filter will be prevented from
-- using global profile
UserData.Content["Vehicle.mazda_rx7"] = DummyProfile
UserData.Content["Vehicle.v_arch_v4paladin"] = {
  auxprops = {
    AirResis = 0.41,
    HandBrak = 2.0,
    BrakeFac = 2.0,
    WhRRatio = -3.77,
  },
  gearmods = {
    offset = {
      -- Gears    R   1st   2nd   3rd   4th   5th   6th   7th
      smin = {    0,    0,  4.5,  3.9,  3.3,  2.7,  2.1,  1.5},
      smax = { 1.77,    0,    0,    1,    3,    5,    7,    9},
      rmin = {    0,    0,  300,  300,  300,  325,  350,  375},
      rmax = {    0,    0,    0,    0,    0,    0,    0,    0},
      tmul = {    0, 0.05, 0.06, 0.07, 0.08, 0.09, 0.10, 0.11},
    },
    multiplier = {
      -- Gears    R   1st   2nd   3rd   4th   5th   6th   7th
      smin = {  1.0,  1.0,  2.0,  1.9,  1.8,  1.7,  1.6,  1.5},
      smax = { 0.29, 1.05, 1.27, 1.45, 1.59, 1.69, 1.75, 1.77},
      rmin = {  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0},
      rmax = {  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0},
      tmul = {  0.5, 0.55, 0.55, 0.55,  0.7, 0.77, 0.73,  0.9},
    },
  },
}

return UserData