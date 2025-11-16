-- TODO: reimplement dispatcher integration
local Dispatcher = require("dispatcher") -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Screensaver = require("ui/screensaver")
local Device = require("device")
local Screen = Device.screen
local _ = require("gettext")
local highlightsWidget = require("highlights_widget")
local scan = require("scan")
local clipper = require("clipper")
local utils = require("utils")

local HIGHLIGHTS_MODE = "highlights"

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
						text = _("Scan book highlights"),
						callback = function()
							scan.scanHighlights()
							local popup = InfoMessage:new({
								text = _("Finished scanning highlights"),
							})
							UIManager:show(popup)
						end,
					},
					{
						text = _("Add current directory to scannable directories"),
						callback = function()
							scan.addToScannableDirectories()
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

		local last_scanned = utils.getLastScannedDate()
		local t = os.date("*t")
		local today = string.format("%04d-%02d-%02d", t.year, t.month, t.day)
		if not last_scanned or last_scanned < today then
			scan.scanHighlights()
		end

		-- TODO: disable last highlight
		---- note that highlight logic has to take into account already disabled highlights.
		---- that means reading in the existing clipping before overwriting it, using the clipping's enabled
		---- state during the overwrite
		local clipping = clipper.getRandomClipping()
		self.screensaver_widget = highlightsWidget.buildHighlightsScreensaverWidget(clipping)
		self.screensaver_widget.modal = true
		self.screensaver_widget.dithered = true
		UIManager:show(self.screensaver_widget, "full")

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
