-- shells.lua
-- Common NoLeg shells / IPLs. Add or edit entries as needed.
-- Each key: unique id. Value: { label, ipl, interior (optional), spawn = {x,y,z,h}, cam = {x,y,z,rx,ry,rz}, meta }

local Shells = {
  ["2floor_house"] = {
    label = "2 Floor House",
    ipl = nil,
    interior = "shell_2floor",
    spawn = { x = 295.0, y = -1000.0, z = -99.0, h = 90.0 },
    cam = { x = 298.0, y = -1003.0, z = -98.0 },
    meta = { type = "house", beds = 2 }
  },

  ["modern_apartment"] = {
    label = "Modern Apartment (Vinewood)",
    ipl = nil,
    interior = "shell_modern_apt",
    spawn = { x = -589.0, y = -927.0, z = 23.8, h = 90.0 },
    cam = { x = -586.0, y = -924.0, z = 24.8 },
    meta = { type = "apartment", tier = "mid" }
  },

  ["penthouse_suite_2"] = {
    label = "Penthouse 2 (Eclipse Towers)",
    ipl = "apa_v_ilev_apart2",
    interior = "penthouse_suite_2",
    spawn = { x = -774.0, y = 341.0, z = 145.7, h = 180.0 },
    cam = { x = -771.0, y = 338.0, z = 146.7 },
    meta = { type = "penthouse", tier = "high" }
  },

  ["motel_room_1"] = {
    label = "Motel Room (Chain)",
    ipl = nil,
    interior = "shell_motel01",
    spawn = { x = 317.0, y = -213.0, z = 54.0, h = 180.0 },
    cam = { x = 320.0, y = -210.0, z = 55.0 },
    meta = { type = "motel", beds = 1 }
  },

  ["small_apartment_low"] = {
    label = "Small Low-end Apartment",
    ipl = nil,
    interior = "shell_small_low",
    spawn = { x = -18.0, y = -583.0, z = 36.0, h = 270.0 },
    cam = { x = -15.0, y = -580.0, z = 37.0 },
    meta = { type = "apartment", tier = "low" }
  },

  ["luxury_apartment_1"] = {
    label = "Luxury Apartment (Rich)",
    ipl = "apa_v_ipl_luxury_a",
    interior = "shell_luxury_1",
    spawn = { x = -1459.0, y = -539.0, z = 33.9, h = 4.0 },
    cam = { x = -1456.0, y = -536.0, z = 34.9 },
    meta = { type = "apartment", tier = "luxury" }
  },

  ["office_small"] = {
    label = "Small Office",
    ipl = nil,
    interior = "shell_office_small",
    spawn = { x = -104.0, y = -608.0, z = 35.3, h = 90.0 },
    cam = { x = -101.0, y = -605.0, z = 36.3 },
    meta = { type = "business", category = "office" }
  },

  ["benny_workshop"] = {
    label = "Benny's Workshop (Garage)",
    ipl = "v_int_38_milo", -- example IPL (some servers may differ)
    interior = "shell_benny",
    spawn = { x = -211.0, y = -1323.0, z = 30.9, h = 200.0 },
    cam = { x = -208.0, y = -1319.0, z = 31.5 },
    meta = { type = "garage", capacity = 4 }
  },

  ["maze_bank_office"] = {
    label = "Maze Bank Office",
    ipl = "ex_exec_warehouse_placement",
    interior = "shell_maze_office",
    spawn = { x = -80.0, y = -829.0, z = 243.4, h = 90.0 },
    cam = { x = -77.0, y = -826.0, z = 244.4 },
    meta = { type = "office", tier = "corporate" }
  },

  ["warehouse_small"] = {
    label = "Small Warehouse",
    ipl = nil,
    interior = "shell_wh_small",
    spawn = { x = 107.0, y = -3102.0, z = 6.0, h = 180.0 },
    cam = { x = 110.0, y = -3099.0, z = 7.0 },
    meta = { type = "warehouse", capacity = 6 }
  },

  -- Add more shells from original NoLeg repo here as needed.
}

return Shells
