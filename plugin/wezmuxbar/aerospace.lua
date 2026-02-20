local wezterm = require("wezterm")

local M = {}

M.default_opts = {
	icon = wezterm.nerdfonts.md_monitor_multiple,
}

--- Get aerospace workspaces and active workspace
--- @return string Formatted workspace string
function M.get_workspaces()
	local success, stdout, stderr = wezterm.run_child_process({
		"aerospace",
		"list-workspaces",
		"--all",
	})

	if not success then
		return ""
	end

	local workspaces = {}
	for workspace in stdout:gmatch("[^\r\n]+") do
		table.insert(workspaces, workspace)
	end

	local active_success, active_stdout = wezterm.run_child_process({
		"aerospace",
		"list-workspaces",
		"--focused",
	})

	local active_workspace = active_success and active_stdout:match("^%s*(.-)%s*$") or ""

	local result = {}
	for _, ws in ipairs(workspaces) do
		if ws == active_workspace then
			table.insert(result, "[" .. ws .. "]")
		else
			table.insert(result, ws)
		end
	end

	return table.concat(result, " ")
end

return M
