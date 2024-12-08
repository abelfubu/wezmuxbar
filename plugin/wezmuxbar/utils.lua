local M = {}

function M.deep_merge(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" and type(t1[k]) == "table" then
			deep_merge(t1[k], v)
		else
			t1[k] = v
		end
	end
	return t1
end

function M.includes(values, key)
	for _, value in pairs(values) do
		if value == key then
			return true
		end
	end

	return false
end

function M.parse_tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end

	return tab_info.active_pane.title
end

function M.get_current_dir(pane)
	local valid, url = pcall(function()
		return pane:get_current_working_dir()
	end)

	if not valid or url.scheme ~= "file" then
		return ""
	end

	local clean_path = url.file_path:gsub("^/", ""):gsub("[/\\]+$", "")
	local last_portion = string.match(clean_path, "[^/\\]+$") or "Unknown"
	return last_portion
end

return M
