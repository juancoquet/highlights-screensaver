-- TODO: reimplement dispatcher integration
local json = require("json")
local Dispatcher = require("dispatcher") -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Screensaver = require("ui/screensaver")
local _ = require("gettext")
local lfs = require("libs/libkoreader-lfs")
local utils = require("utils")
local clipper = require("clipper")

local HighlightScreensaver = WidgetContainer:extend({
	name = "Highlight Screensaver",
	is_doc_only = false,
})

function HighlightScreensaver:init()
	self.ui.menu:registerToMainMenu(self)
end

function HighlightScreensaver:addToMainMenu(menu_items)
	menu_items.highlight_screensaver = {
		text = _("Highlight Screensaver"),
		-- in which menu this should be appended
		sorting_hint = "tools",
		sub_item_table = {
			{
				text = _("Scan all book highlights"),
				-- a callback when tapping
				callback = function()
					self:scanHighlights()
				end,
			},
			{
				text = _("Add to scannable directories"),
				callback = function()
					self:addToScannableDirectories()
				end,
			},
		},
	}
end

function HighlightScreensaver:scanHighlights()
	local sidecars = utils.getAllSidecarPaths()
	for _, sidecar in ipairs(sidecars) do
		clipper.extractClippingsFromSidecar(sidecar)
	end
	local sidecar_strings = table.concat(sidecars, ", ")
	local popup = InfoMessage:new({
		text = _(sidecar_strings),
	})
	UIManager:show(popup)
end

function HighlightScreensaver:addToScannableDirectories()
	local scannable_dirs = utils.getScannableDirs()
	local curr_dir = self.ui.file_chooser.path
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

return HighlightScreensaver
