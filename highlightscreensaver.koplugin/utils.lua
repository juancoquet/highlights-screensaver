local Device = require("device")
local json = require("json")
local lfs = require("libs/libkoreader-lfs")

local M = {}

function M.getDefaultRootDir()
	if Device:isCervantes() or Device:isKobo() then
		return "/mnt"
	elseif Device:isEmulator() then
		return lfs.currentdir()
	else
		return Device.home_dir or lfs.currentdir()
	end
end

function M.getPluginDir()
	return M.getDefaultRootDir() .. "/onboard/highlight-screensaver"
end

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

---@return string
function M.getScannableDirsFilePath()
	return M.getPluginDir() .. "/scannable-dirs.json"
end

---@return string[]
function M.getScannableDirs()
	local file = io.open(M.getScannableDirsFilePath(), "r")
	local contents = file and file:read("*a") or "[]"
	if file then
		file:close()
	end

	local dirs = json.decode(contents) or {}
	local valid_dirs = {}
	for _, dir in ipairs(dirs) do
		if lfs.attributes(dir, "mode") == "directory" then
			table.insert(valid_dirs, dir)
		end
	end
	return valid_dirs
end

---@return string[]
function M.getAllSidecarPaths()
	local scannable_dirs = M.getScannableDirs()
	local sidecars = {}

	local function searchDir(dir)
		for member in lfs.dir(dir) do
			if member == "." or member == ".." then
				goto continue -- skip current and parent dirs
			end

			local path = dir .. "/" .. member
			local attr = lfs.attributes(path)
			if attr and attr.mode == "directory" then
				if member:match("%.sdr$") then
					table.insert(sidecars, path)
				else
					searchDir(path)
				end
			end
			::continue::
		end
	end

	for _, dir in ipairs(scannable_dirs) do
		searchDir(dir)
	end

	return sidecars
end

---@param s string
---@return string
function M.normalise(s)
	s = s:match("^%s*(.-)%s*$") -- trim
	s = s:lower()
	s = s:gsub("%s+", "_") -- replace spaces for underscores
	s = s:gsub("[^%w_%-%.]", "") -- remove unsafe filename chars
	return s
end

return M
