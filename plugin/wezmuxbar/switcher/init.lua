local wezterm = require("wezterm")
local switcher_config = require("wezmuxbar.switcher.config")

local M = {}

local is_windows = string.match(wezterm.target_triple, "windows") ~= nil
local sep = is_windows and "\\" or "/"
local tmp_dir = is_windows and (os.getenv("TEMP") or "C:\\Temp") or "/tmp"
local base_dir = tmp_dir .. sep .. "wezmuxbar-switcher"
local result_file = base_dir .. sep .. "result.txt"
local cwd_file = base_dir .. sep .. "cwd.txt"

--- Collects unique workspace names from the mux.
--- @return string[] List of unique workspace names
local function collect_workspaces()
	local workspace_set = {}
	local workspaces = {}

	for _, name in ipairs(wezterm.mux.get_workspace_names()) do
		if not workspace_set[name] then
			workspace_set[name] = true
			table.insert(workspaces, name)
		end
	end

	return workspaces
end

--- Writes workspace list to a temp file for fzf.
--- @param workspaces string[] Workspace names
--- @return string workspaces_file Path to workspaces list file
local function write_temp_data(workspaces)
	os.execute((is_windows and "mkdir " or "mkdir -p ") .. '"' .. base_dir .. '"')

	local ws_file = base_dir .. sep .. "workspaces.txt"
	local f = io.open(ws_file, "w")
	if f then
		f:write("+ Create new workspace\n")
		for _, ws in ipairs(workspaces) do
			f:write(ws .. "\n")
		end
		f:close()
	end

	return ws_file
end

--- Returns the current pane's working directory.
--- @param pane table Wezterm pane object
--- @return string cwd
local function get_current_cwd(pane)
	local ok, url = pcall(function()
		return pane:get_current_working_dir()
	end)
	if ok and url then
		return url.file_path or tostring(url)
	end
	return ""
end

--- Builds the fzf spawn arguments for the current platform.
--- After fzf exits, sends a user-var signal so Lua can process the result.
--- @param ws_file string Path to workspaces list file
--- @return table args for SpawnCommandInNewTab
local function build_fzf_args(ws_file)
	-- MQ== is base64 for "1" — hardcoded to avoid platform-specific base64 commands
	local signal = "\\033]1337;SetUserVar=wezmuxbar_switcher=MQ==\\007"

	local fzf_opts = "--print-query"
		.. " --header='Switch workspace · type new name to create'"
		.. " --prompt='  Workspace: '"
		.. " --pointer='▶'"
		.. " --border=rounded"
		.. " --no-info"

	if is_windows then
		local win_signal = "`e]1337;SetUserVar=wezmuxbar_switcher=MQ==`a"

		local cmd = "$sel = Get-Content '"
			.. ws_file
			.. "' | fzf "
			.. fzf_opts
			.. "; $sel | Set-Content '"
			.. result_file
			.. "';"
			.. " Write-Host -NoNewLine '"
			.. win_signal
			.. "';"
			.. " Start-Sleep -Milliseconds 200"

		return { "powershell", "-NoProfile", "-Command", cmd }
	else
		local cmd = "SEL=$(cat '"
			.. ws_file
			.. "' | fzf "
			.. fzf_opts
			.. ") || true;"
			.. " echo \"$SEL\" > '"
			.. result_file
			.. "';"
			.. " printf '"
			.. signal
			.. "';"
			.. " sleep 0.2"

		return { "bash", "-c", cmd }
	end
end

--- Parses the fzf result file and returns the action and target workspace.
--- @param workspaces string[] Known workspace names
--- @return string|nil action "switch" or "create"
--- @return string|nil target Workspace name
local function parse_result(workspaces)
	local f = io.open(result_file, "r")
	if not f then
		return nil, nil
	end

	local lines = {}
	for line in f:lines() do
		table.insert(lines, line)
	end
	f:close()
	os.remove(result_file)

	local query = lines[1] or ""
	local match = lines[2] or ""

	if match == "+ Create new workspace" then
		if query ~= "" and query ~= "+ Create new workspace" then
			return "create", query
		end
		return nil, nil
	elseif match ~= "" then
		return "switch", match
	elseif query ~= "" then
		local workspace_set = {}
		for _, ws in ipairs(workspaces) do
			workspace_set[ws] = true
		end
		if workspace_set[query] then
			return "switch", query
		else
			return "create", query
		end
	end

	return nil, nil
end

--- Sets up the workspace switcher.
--- Registers keybindings and listens for the user-var signal from fzf.
--- @param config table Wezterm config object
--- @param opts table|nil Optional overrides for default keybinding (key, mods)
function M.setup(config, opts)
	local utils = require("wezmuxbar.utils")
	local merged = utils.deep_merge(switcher_config.defaults, opts or {})

	if not config.keys then
		config.keys = {}
	end

	table.insert(config.keys, {
		key = merged.key,
		mods = merged.mods,
		action = wezterm.action_callback(function(window, pane)
			local workspaces = collect_workspaces()
			local ws_file = write_temp_data(workspaces)
			local cwd = get_current_cwd(pane)
			local fzf_args = build_fzf_args(ws_file)

			-- Store cwd for new workspace creation
			local f = io.open(cwd_file, "w")
			if f then
				f:write(cwd)
				f:close()
			end

			window:perform_action(
				wezterm.action.SpawnCommandInNewTab({
					args = fzf_args,
				}),
				pane
			)
		end),
	})

	-- Listen for the signal from fzf to process the result
	wezterm.on("user-var-changed", function(window, pane, name, value)
		if name ~= "wezmuxbar_switcher" then
			return
		end

		local workspaces = collect_workspaces()
		local action, target = parse_result(workspaces)

		if not action or not target then
			return
		end

		-- Read stored cwd
		local cwd = ""
		local cf = io.open(cwd_file, "r")
		if cf then
			cwd = cf:read("*a") or ""
			cf:close()
			os.remove(cwd_file)
		end

		if action == "create" then
			window:perform_action(
				wezterm.action.SwitchToWorkspace({
					name = target,
					spawn = { cwd = cwd },
				}),
				pane
			)
		else
			window:perform_action(
				wezterm.action.SwitchToWorkspace({ name = target }),
				pane
			)
		end
	end)
end

return M
