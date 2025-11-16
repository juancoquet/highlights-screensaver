local FileManager = require("apps/filemanager/filemanager")
local InfoMessage = require("ui/widget/infomessage")
local json = require("json")
local lfs = require("libs/libkoreader-lfs")
local UIManager = require("ui/uimanager")

local utils = require("utils")
local clipper = require("clipper")

local M = {}

function M.scanHighlights()
	local sidecars = utils.getAllSidecarPaths()
	for _, sidecar in ipairs(sidecars) do
		local clippings = clipper.extractClippingsFromSidecar(sidecar)
		for _, clipping in ipairs(clippings) do
			clipper.saveClipping(clipping)
		end
	end

	local file = assert(io.open(utils.getLastScannedDateFilePath(), "w"))
	local t = os.date("*t")
	local today = string.format("%04d-%02d-%02d", t.year, t.month, t.day)
	file:write(today)
	file:close()
end

function M.addToScannableDirectories()
	local scannable_dirs = utils.getScannableDirs()
	local curr_dir = FileManager.instance.file_chooser.path
	-- local curr_dir = self.ui.file_chooser.path
	table.insert(scannable_dirs, curr_dir)

	local unique_dirs = {}
	local seen = {}
	for _, dir in ipairs(scannable_dirs) do
		if not seen[dir] then
			table.insert(unique_dirs, dir)
			seen[dir] = true
		end
	end

	local dir = utils.getPluginDir()
	local attr = lfs.attributes(dir)
	if not attr then
		local ok, err = utils.makeDir(utils.getPluginDir())
		if not ok then
			error(tostring(err))
		end
	end

	local file, err = io.open(utils.getScannableDirsFilePath(), "w")
	if not file then
		error("Failed to open scannable-dirs file: " .. tostring(err))
	end
	file:write(json.encode(unique_dirs))
	file:close()

	local popup = InfoMessage:new({
		text = _("Added to scannable directories: " .. curr_dir),
	})
	UIManager:show(popup)
end

return M
