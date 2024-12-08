local wezterm = require("wezterm")

local M = {}

--- Checks if the user is on windows
local is_windows = string.match(wezterm.target_triple, "windows") ~= nil
local separator = is_windows and "\\" or "/"

local plugin_dir = wezterm.plugin.list()[1].plugin_dir:gsub(separator .. "[^" .. separator .. "]*$", "")

--- Checks if the plugin directory exists
local function directory_exists(path)
	local success, result = pcall(wezterm.read_dir, plugin_dir .. path)
	return success and result
end

--- Returns the name of the package, used when requiring modules
local function get_require_path()
	local path1 = "httpssCssZssZsgithubsDscomsZsabelfubusZswezmuxbar"
	local path2 = "httpssCssZssZsgithubsDscomsZsabelfubusZswezmuxbarZs"
	return directory_exists(path2) and path2 or path1
end

package.path = package.path
	.. ";"
	.. plugin_dir
	.. separator
	.. get_require_path()
	.. separator
	.. "plugin"
	.. separator
	.. "?.lua"

local default_options = {
	tab_bar_position = "bottom", -- "top" | "bottom"
	tab_max_width = 36, -- number,
	style = "round", -- "round" | "default"
}

function M.add_mux_bar(config, options)
	local utils = require("wezmuxbar.utils")
	local components = require("wezmuxbar.components")
	local cpu = require("wezmuxbar.cpu")

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

	local merged_options = utils.deep_merge(default_options, options or {})

	config.tab_bar_at_bottom = merged_options.tab_bar_position == "bottom"
	config.hide_tab_bar_if_only_one_tab = false
	config.use_fancy_tab_bar = false
	config.tab_and_split_indices_are_zero_based = false
	config.tab_max_width = merged_options.tab_max_width
	config.show_tab_index_in_tab_bar = false
	config.show_new_tab_button_in_tab_bar = false

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

		local right_elements = {}

		for _, value in
			ipairs(components.right_widget({
				text = wezterm.strftime("%Y-%m-%d"),
				fg = colors.brights[4],
				bg = colors.background,
				icon = wezterm.nerdfonts.md_calendar_outline,
			}))
		do
			table.insert(right_elements, value)
		end

		for _, value in
			ipairs(components.right_widget({
				text = cpu.update(window, { throttle = 3 }),
				fg = colors.brights[5],
				bg = colors.background,
				icon = cpu.default_opts.icon,
			}))
		do
			table.insert(right_elements, value)
		end

		window:set_right_status(wezterm.format(right_elements))
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
