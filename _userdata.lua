local MD = require('_modtable')
local UD = {}
-- Add unique Gear Tweak table here
-- MD.Dummy = mod default/vanilla gearbox tuning
UD["Vehicle.mazda_rx7"] = MD.Dummy
UD['Vehicle.v_arch_v4paladin'] = {
  offset = {
    -- Gears    R   1st   2nd   3rd   4th   5th   6th   7th
    smin = {    0,    0,  4.5,  3.9,  3.3,  2.7,  2.1,  1.5},
    smax = { 1.77,    2,  1.5,  1.0,  0.5,  0.0,-0.25, -0.5},
    rmin = {    0,  350,  200,  125,  100,  100,  100,  100},
    rmax = {    0,    0,    0,    0,    0,    0,    0,    0},
    tmul = {    0,    0, 0.05, 0.03, 0.08, 0.09, 0.07, 0.08},
  },
  multiplier = {
    -- Gears    R   1st   2nd   3rd   4th   5th   6th   7th
    smin = {  1.0,  1.0,  2.0,  1.9,  1.8,  1.7,  1.6,  1.5},
    smax = { 0.25,  0.7,  0.9,  1.0, 1.15, 1.35, 1.65,  2.7},
    rmin = {  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0},
    rmax = {  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0},
    tmul = {  0.5,  0.5,  0.5,  0.5,  0.5,  0.5,  0.5,  0.5},
  },
}

return UD