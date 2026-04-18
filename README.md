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
wezterm.plugin.require("https://github.com/abelfubu/wezmuxbar").add_mux_bar(config, {
    tab_bar_position = "bottom",  -- "top" | "bottom"
    tab_max_width = 36,           -- number
    style = "round",              -- "round" | "default"
    date = true,                  -- boolean
    time = true,                  -- boolean
})

return config
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `tab_bar_position` | string | `"bottom"` | Position of the tab bar (`"top"` or `"bottom"`) |
| `tab_max_width` | number | `36` | Maximum width of tabs |
| `style` | string | `"round"` | Tab bar style (`"round"` or `"default"`) |
| `date` | boolean | `true` | Show date widget in right status bar |
| `time` | boolean | `true` | Show time widget in right status bar |

![CATPPUCCIN](https://raw.githubusercontent.com/abelfubu/wezmuxbar/main/images/catppuccin.png)
