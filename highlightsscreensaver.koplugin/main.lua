local json = require("json")
-- TODO: reimplement dispatcher integration
local Dispatcher = require("dispatcher") -- luacheck:ignore
local FileManager = require("apps/filemanager/filemanager")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Screensaver = require("ui/screensaver")
local Device = require("device")
local Screen = Device.screen
local _ = require("gettext")
local lfs = require("libs/libkoreader-lfs")
local utils = require("utils")
local clipper = require("clipper")

local HIGHLIGHTS_MODE = "highlights"

local function scanHighlights()
	local sidecars = utils.getAllSidecarPaths()
	local total_saved = 0
	for _, sidecar in ipairs(sidecars) do
		local clippings = clipper.extractClippingsFromSidecar(sidecar)
		for _, clipping in ipairs(clippings) do
			clipper.saveClipping(clipping)
			total_saved = total_saved + 1
		end
	end

	local popup = InfoMessage:new({
		text = _("Saved " .. total_saved .. "highlights"),
	})
	UIManager:show(popup)
end

local function addToScannableDirectories()
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

-- patch `dofile` to add a highlights mode
local orig_dofile = dofile
_G.dofile = function(filepath)
	local result = orig_dofile(filepath)

	if filepath and filepath:match("screensaver_menu%.lua$") then
		if result and result[1] and result[1].sub_item_table then
			local wallpaper_submenu = result[1].sub_item_table

			table.insert(result, 3, {
				text = _("Highlights screensaver"),
				sub_item_table = {
					{
						text = _("Scan all book highlights"),
						callback = function()
							scanHighlights()
						end,
					},
					{
						text = _("Add to scannable directories"),
						callback = function()
							addToScannableDirectories()
						end,
					},
				},
			})

			table.insert(wallpaper_submenu, 6, {
				text = _("Show highlights screensaver"),
				checked_func = function()
					return G_reader_settings:readSetting("screensaver_type") == HIGHLIGHTS_MODE
				end,
				callback = function()
					G_reader_settings:saveSetting("screensaver_type", HIGHLIGHTS_MODE)
				end,
				radio = true,
			})
		end
	end

	return result
end

-- patch the screensaver's `show` function to handle the new highlights mode
local og_screensaver_show = Screensaver.show
Screensaver.show = function(self)
	if self.screensaver_type == HIGHLIGHTS_MODE then
		if self.screensaver_widget then
			UIManager:close(self.screensaver_widget)
			self.screensaver_widget = nil
		end

		Device.screen_saver_mode = true

		local rotation_mode = Screen:getRotationMode()
		Device.orig_rotation_mode = rotation_mode
		if bit.band(rotation_mode, 1) == 1 then
			Screen:setRotationMode(Screen.DEVICE_ROTATED_UPRIGHT)
		else
			Device.orig_rotation_mode = nil
		end

		-- TODO: create custom widget

		return
	end

	og_screensaver_show(self)
end

local HighlightsScreensaver = WidgetContainer:extend({
	name = "Highlights Screensaver",
	is_doc_only = false,
})

function HighlightsScreensaver:init() end

return HighlightsScreensaver
