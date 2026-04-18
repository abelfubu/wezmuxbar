-- Test configuration for wezmuxbar plugin
-- This tests different combinations of date/time options

local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"

-- Test case 1: Both date and time visible (default)
local wezmuxbar1 = wezterm.plugin.require("https://github.com/abelfubu/wezmuxbar")
wezmuxbar1.add_mux_bar(config, {
    tab_bar_position = "top",
    -- date = true,  (default)
    -- time = true,  (default)
})
-- Should show: aerospace, cpu, folder, calendar + date, clock + time

-- Uncomment one of the test cases below to test:

-- Test case 2: Only date visible
-- local wezmuxbar2 = wezterm.plugin.require("https://github.com/abelfubu/wezmuxbar")
-- wezmuxbar2.add_mux_bar(config, {
--     tab_bar_position = "top",
--     date = true,
--     time = false,
-- })
-- Should show: aerospace, cpu, folder, calendar + date (NO clock + time)

-- Test case 3: Only time visible
-- local wezmuxbar3 = wezterm.plugin.require("https://github.com/abelfubu/wezmuxbar")
-- wezmuxbar3.add_mux_bar(config, {
--     tab_bar_position = "top",
--     date = false,
--     time = true,
-- })
-- Should show: aerospace, cpu, folder (NO calendar + date), clock + time

-- Test case 4: Both hidden
-- local wezmuxbar4 = wezterm.plugin.require("https://github.com/abelfubu/wezmuxbar")
-- wezmuxbar4.add_mux_bar(config, {
--     tab_bar_position = "top",
--     date = false,
--     time = false,
-- })
-- Should show: aerospace, cpu, folder (NO calendar + date, NO clock + time)

return config
