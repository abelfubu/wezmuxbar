local wezterm = require("wezterm")
local switcher_config = require("wezmuxbar.switcher.config")

local M = {}

--- Resolves the absolute path to the switcher shell script.
--- @return string path to switcher.sh
local function get_script_path()
	local is_windows = string.match(wezterm.target_triple, "windows") ~= nil
	local sep = is_windows and "\\" or "/"
	local plugin_dir = wezterm.plugin.list()[1].plugin_dir:gsub(sep .. "[^" .. sep .. "]*$", "")

	local function directory_exists(path)
		local success, _ = pcall(wezterm.read_dir, plugin_dir .. path)
		return success
	end

	local path1 = "httpssCssZssZsgithubsDscomsZsabelfubusZswezmuxbar"
	local path2 = "httpssCssZssZsgithubsDscomsZsabelfubusZswezmuxbarZs"
	local require_path = directory_exists(path2) and path2 or path1

	return plugin_dir
		.. sep
		.. require_path
		.. sep
		.. "plugin"
		.. sep
		.. "wezmuxbar"
		.. sep
		.. "switcher"
		.. sep
		.. "switcher.sh"
end

--- Sets up the workspace switcher.
--- Registers keybindings and the user-var-changed event handler.
--- @param config table Wezterm config object
--- @param opts table|nil Optional overrides for default keybinding (key, mods)
function M.setup(config, opts)
	local utils = require("wezmuxbar.utils")
	local merged = utils.deep_merge(switcher_config.defaults, opts or {})
	local script_path = get_script_path()

	-- Register keybinding
	if not config.keys then
		config.keys = {}
	end

	table.insert(config.keys, {
		key = merged.key,
		mods = merged.mods,
		action = wezterm.action.SpawnCommandInNewTab({
			args = { "bash", script_path },
		}),
	})

	-- Listen for the switcher's user-var signal to perform workspace switch
	wezterm.on("user-var-changed", function(window, pane, name, value)
		if name ~= "wezmuxbar_switcher" then
			return
		end

		-- value is already base64-decoded by wezterm
		-- Format: "action|workspace_name|cwd"
		local parts = {}
		for part in value:gmatch("[^|]+") do
			table.insert(parts, part)
		end

		local action = parts[1]
		local workspace = parts[2]
		local cwd = parts[3] or ""

		if action == "create" then
			window:perform_action(
				wezterm.action.SwitchToWorkspace({
					name = workspace,
					spawn = { cwd = cwd },
				}),
				pane
			)
		else
			window:perform_action(
				wezterm.action.SwitchToWorkspace({ name = workspace }),
				pane
			)
		end
	end)
end

return M
