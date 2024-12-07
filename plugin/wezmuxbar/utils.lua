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

return M
