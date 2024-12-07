# Wezterm Mux Bar

A simple mux bar for Wezterm that integrates with the set of default wezterm color schemes.

## Usage

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- build your config according to
-- https://wezfurlong.org/wezterm/config/lua/wezterm/config_builder.html

-- Set your favorite color scheme
c.color_scheme = "Catppuccin Mocha"

-- then finally apply the plugin
-- these are currently the defaults:
wezterm.plugin.require("https://github.com/abelfubu/wezmuxbar").add_mux_bar(config)

return config
```

## Customization

WIP
