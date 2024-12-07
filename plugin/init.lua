local wezterm = require("wezterm")
local utils = require("wezmuxbar.utils")
local components = require("wezmuxbar.components")

local M = {}

local default_options = {
	tab_bar_position = "bottom", -- "top" | "bottom"
	tab_max_width = 36, -- number,
	style = "round", -- "round" | "default"
}

function M.add_mux_bar(config, options)
	local colors = wezterm.color.get_builtin_schemes()["catppuccin-mocha"]

	for key, value in pairs(wezterm.color.get_builtin_schemes()) do
		local valid_keys = {
			config.color_scheme:gsub(" ", "_"),
			config.color_scheme:gsub(" ", "-"),
			config.color_scheme,
		}

		if utils.includes(valid_keys, key:lower()) then
			colors = value
			break
		end
	end

	local merged_options = utils.deep_merge(default_options, options)

	config.tab_bar_at_bottom = merged_options.tab_bar_position == "bottom"
	config.hide_tab_bar_if_only_one_tab = false
	config.use_fancy_tab_bar = false
	config.tab_and_split_indices_are_zero_based = false
	config.tab_max_width = merged_options.tab_max_width
	config.show_tab_index_in_tab_bar = false
	config.show_new_tab_button_in_tab_bar = false
	config.show_close_tab_button_in_tabs = false

	config.colors = {
		tab_bar = {
			background = colors.background,
		},
	}

	wezterm.on("update-right-status", function(window)
		local leader_active = window:leader_is_active()

		window:set_left_status(wezterm.format(components.leader_status({
			fg = colors.brights[3],
			bg = colors.background,
			icon = leader_active and "   " or "   ",
		})))

		window:set_right_status(wezterm.format(components.date({
			text = wezterm.strftime("%Y-%m-%d"),
			fg = colors.brights[4],
			bg = colors.background,
		})))
	end)

	wezterm.on("format-tab-title", function(tab)
		local title = utils.parse_tab_title(tab)

		if tab.is_active then
			return components.active_tab({ text = title, fg = colors.brights[6], bg = colors.background })
		end

		return components.inactive_tab({
			text = title,
			index = tab.tab_index,
			fg = colors.brights[4],
			bg = colors.background,
		})
	end)
end

return M
