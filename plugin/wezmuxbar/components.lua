local wezterm = require("wezterm")

--- @class TabConfig
--- @field fg string Foreground color
--- @field bg string Background color
--- @field text string Tab title
--- @field icon string Icon for leader status
--- @field index number Tab index

local M = {}

--- Create a date widget.
--- @param config TabConfig Leader status configuration
--- @return table[] Formatted leader status widget elements
function M.date(config)
	return {
		{ Foreground = { Color = config.fg } },
		{ Text = wezterm.nerdfonts.ple_left_half_circle_thick },
		{ Background = { Color = config.fg } },
		{ Foreground = { Color = config.bg } },
		{ Text = wezterm.nerdfonts.md_calendar_outline .. " " },
		{ Background = { Color = config.bg } },
		{ Foreground = { Color = config.fg } },
		{ Text = " " .. config.text .. " " },
	}
end

--- Create a leader status widget.
--- @param config TabConfig Leader status configuration
--- @return table[] Formatted leader status widget elements
function M.leader_status(config)
	return {
		{ Foreground = { Color = config.fg } },
		{ Background = { Color = config.bg } },
		{ Text = config.icon },
	}
end

--- Create an inactive tab widget.
--- @param config TabConfig Leader status configuration
--- @return table[] Formatted leader status widget elements
function M.active_tab(config)
	return {
		{ Background = { Color = config.bg } },
		{ Foreground = { Color = config.fg } },
		{ Text = "  " .. config.text .. " " },
		{ Background = { Color = config.fg } },
		{ Foreground = { Color = config.bg } },
		{ Text = " " .. wezterm.nerdfonts.md_tab .. " " },
		{ Foreground = { Color = config.fg } },
		{ Background = { Color = config.bg } },
		{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },
	}
end

--- Create a leader status widget.
--- @param config TabConfig Leader status configuration
--- @return table[] Formatted leader status widget elements
---
function M.inactive_tab(config)
	return {
		{ Foreground = { Color = config.fg } },
		{ Background = { Color = config.bg } },
		{ Text = "  " .. config.text .. " " },
		{ Background = { Color = config.fg } },
		{ Foreground = { Color = config.bg } },
		{ Text = " " .. config.index + 1 },
		{ Foreground = { Color = config.fg } },
		{ Background = { Color = config.bg } },
		{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },
	}
end

return M
