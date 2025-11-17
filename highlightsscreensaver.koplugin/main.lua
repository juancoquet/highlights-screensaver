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
local config = require("config")
local ffiUtil = require("ffi/util")  
local T = ffiUtil.template

local HIGHLIGHTS_MODE = "highlights"
G_reader_settings:saveSetting(highlightsWidget.FONT_NAME_QUOTE_SETTING, "NotoSerif-BoldItalic.ttf")
G_reader_settings:saveSetting(highlightsWidget.FONT_NAME_AUTHOR_SETTING, "NotoSerif-Regular.ttf")
G_reader_settings:saveSetting(highlightsWidget.FONT_NAME_NOTE_SETTING, "NotoSerif-Bold.ttf")

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
					{
						text = _("Disable last shown highlight"),
						callback = function()
							local fname = config.getLastShownHighlight()
							if not fname then
								return
							end
							local clipping = clipper.getClipping(fname)
							if not clipping then
								return
							end
							clipping.enabled = false
							clipper.saveClipping(clipping)
							local popup = InfoMessage:new({
								text = _("Disabled highlight: " .. clipping:filename()),
							})
							UIManager:show(popup)
						end,
					},
					{
						text_func = function()
							local theme = config.getTheme()
							local theme_name = theme:sub(1, 1):upper() .. theme:sub(2)
							return T(_("Theme: %1"), _(theme_name))
						end,
						sub_item_table = {
							{
								text = _("Dark"),
								checked_func = function()
									return config.getTheme() == config.Theme.DARK
								end,
								callback = function()
									return config.setTheme(config.Theme.DARK)
								end,
								radio = true,

							},
							{
								text = _("Light"),
								checked_func = function()
									return config.getTheme() == config.Theme.LIGHT
								end,
								callback = function()
									return config.setTheme(config.Theme.LIGHT)
								end,
								radio = true,
							},
						},
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

		local last_scanned = config.getLastScannedDate()
		local t = os.date("*t")
		local today = string.format("%04d-%02d-%02d", t.year, t.month, t.day)
		if not last_scanned or last_scanned < today then
			scan.scanHighlights()
		end

		local clipping = clipper.getRandomClipping()
		config.setLastShownHighlight(clipping:filename())
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
