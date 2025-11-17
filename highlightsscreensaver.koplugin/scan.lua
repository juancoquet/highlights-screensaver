local _ = require("gettext")
local FileManager = require("apps/filemanager/filemanager")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local lfs = require("libs/libkoreader-lfs")

local clipper = require("clipper")
local config = require("config")
local utils = require("utils")

local M = {}

---@param scannable_dirs string[]
---@return string[]
local function getAllSidecarPaths(scannable_dirs)
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

function M.scanHighlights()
	utils.makeDir(utils.getPluginDir())
	local scannable_directories = config.getScannableDirectories()

	local sidecars = getAllSidecarPaths(scannable_directories)
	for _, sidecar in ipairs(sidecars) do
		local clippings = clipper.extractClippingsFromSidecar(sidecar)
		for _, clipping in ipairs(clippings) do
			local existingClipping = clipper.getClipping(clipping:filename())
			if existingClipping then
				clipping.enabled = existingClipping.enabled
			end
			clipper.saveClipping(clipping)
		end
	end

	local t = os.date("*t")
	local today = string.format("%04d-%02d-%02d", t.year, t.month, t.day)
	config.setLastScannedDate(today)
end

function M.addToScannableDirectories()
	local curr_dir = FileManager.instance.file_chooser.path
	local scannable_directories = config.getScannableDirectories()
	table.insert(scannable_directories, curr_dir)

	local unique_dirs = {}
	local seen = {}
	for _, dir in ipairs(scannable_directories) do
		if not seen[dir] then
			table.insert(unique_dirs, dir)
			seen[dir] = true
		end
	end

	config.setScannableDirectories(unique_dirs)
	local popup = InfoMessage:new({
		text = _("Added to scannable directories: " .. curr_dir),
	})
	UIManager:show(popup)
end

return M
