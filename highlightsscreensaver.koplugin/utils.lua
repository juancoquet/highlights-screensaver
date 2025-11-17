local Device = require("device")
local lfs = require("libs/libkoreader-lfs")

local M = {}

---@return string
function M.getDefaultRootDir()
	if Device:isCervantes() or Device:isKobo() then
		return "/mnt"
	elseif Device:isEmulator() then
		return lfs.currentdir()
	else
		return Device.home_dir or lfs.currentdir()
	end
end

---@return string
function M.getPluginDir()
	return M.getDefaultRootDir() .. "/onboard/highlight-screensaver"
end

---@return string
function M.getClippingsDir()
	return M.getPluginDir() .. "/clippings"
end

---@param path string
function M.makeDir(path)
	local current = ""
	for dir in path:gmatch("[^/]+") do
		current = current .. "/" .. dir
		local attr = lfs.attributes(current, "mode")
		if not attr then
			local ok, err = lfs.mkdir(current)
			if not ok then
				return nil, "Failed to create directory '" .. current .. "': " .. err
			end
		end
	end
	return true
end

---@param s string
---@return string
function M.normalise(s)
	s = s:match("^%s*(.-)%s*$") -- trim
	s = s:lower()
	s = s:gsub("%s+", "_")    -- replace spaces for underscores
	s = s:gsub("[^%w_%-%.]", "") -- remove unsafe filename chars
	return s
end

return M
