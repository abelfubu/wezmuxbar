local wezterm = require("wezterm")

local M = {}

local tab_title = function(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end

	return tab_info.active_pane.title
end

local includes = function(values, key)
	for _, value in pairs(values) do
		if value == key then
			return true
		end
	end
	return false
end

function M.add_mux_bar(config)
	local colors = wezterm.color.get_builtin_schemes()["catppuccin-mocha"]

	for key, value in pairs(wezterm.color.get_builtin_schemes()) do
		local valid_keys = {
			config.color_scheme:gsub(" ", "_"),
			config.color_scheme:gsub(" ", "-"),
			config.color_scheme,
		}

		if includes(valid_keys, key:lower()) then
			colors = value
			break
		end
	end

	config.colors = {
		tab_bar = {
			background = colors.background,
		},
	}

	wezterm.on("update-right-status", function(window, _)
		local leader_active = window:leader_is_active()

		local switch = leader_active and " " or " "

		window:set_left_status(wezterm.format({
			{ Foreground = { Color = leader_active and colors.brights[3] or colors.brights[2] } },
			{ Background = { Color = colors.background } },
			{ Text = " " .. switch .. "" },
		}))

		local date = wezterm.strftime("%Y-%m-%d")

		window:set_right_status(wezterm.format({
			{ Foreground = { Color = colors.brights[4] } },
			{ Text = wezterm.nerdfonts.ple_left_half_circle_thick },
			{ Background = { Color = colors.brights[4] } },
			{ Foreground = { Color = colors.background } },
			{ Text = wezterm.nerdfonts.md_calendar_outline .. " " },
			{ Background = { Color = colors.background } },
			{ Foreground = { Color = colors.brights[4] } },
			{ Text = " " .. date .. " " },
		}))
	end)

	wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
		local title = tab_title(tab)

		if tab.is_active then
			return {
				{ Background = { Color = conf.resolved_palette.background } },
				{ Foreground = { Color = colors.brights[6] } },
				{ Text = "  " .. title .. " " },
				{ Background = { Color = colors.brights[6] } },
				{ Foreground = { Color = colors.background } },
				{ Text = " " .. wezterm.nerdfonts.md_tab .. " " },
				{ Foreground = { Color = colors.brights[6] } },
				{ Background = { Color = colors.background } },
				{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },
			}
		end

		return {
			{ Foreground = { Color = colors.brights[1] } },
			{ Background = { Color = colors.background } },
			{ Text = "  " .. title .. " " },
			{ Background = { Color = colors.brights[1] } },
			{ Foreground = { Color = colors.background } },
			{ Text = " " .. tab.tab_index + 1 },
			{ Foreground = { Color = colors.brights[1] } },
			{ Background = { Color = colors.background } },
			{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },
		}
	end)
end

return M
