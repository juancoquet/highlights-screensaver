local Blitbuffer = require("ffi/blitbuffer")
local CenterContainer = require("ui/widget/container/centercontainer")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local TextBoxWidget = require("ui/widget/textboxwidget")
local Device = require("device")
local config = require("config")
local Screen = Device.screen
local ScreenSaverWidget = require("ui/widget/screensaverwidget")
local Size = require("ui/size")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local LineWidget = require("ui/widget/linewidget")

local M = {}

function M.buildHighlightsScreensaverWidget(clipping)
	local theme = config.getTheme()
	local fonts = config.getFonts()
	local col_fg, col_bg
	if theme == config.Theme.DARK then
		col_fg = Blitbuffer.COLOR_WHITE
		col_bg = Blitbuffer.COLOR_BLACK
	else
		col_fg = Blitbuffer.COLOR_BLACK
		col_bg = Blitbuffer.COLOR_WHITE
	end
	local width = Screen:getWidth() * 0.90

	local function buildContent(base_font_size)
		local function fontSizeAlt()
			return math.ceil(base_font_size * 0.75)
		end

		local highlight_text = TextBoxWidget:new({
			text = clipping.text,
			face = Font:getFace(fonts.quote, base_font_size),
			width = width,
			alignment = "left",
			justified = false,
			line_height = 0.5,
			fgcolor = col_fg,
			bgcolor = col_bg,
		})
		local left_border = LineWidget:new({
			dimen = Geom:new({
				w = Size.border.thick,
				h = highlight_text:getSize().h,
			}),
			background = col_fg,
		})
		local highlight_group = HorizontalGroup:new({
			left_border,
			HorizontalSpan:new({ width = 20 }),
			highlight_text,
		})

		local author_suffix = ""
		if clipping.source_author and clipping.source_author ~= "" then
			author_suffix = ", " .. clipping.source_author
		end

		local source_text = TextBoxWidget:new({
			text = "— " .. clipping.source_title .. author_suffix,
			face = Font:getFace(fonts.author, fontSizeAlt()),
			width = width,
			fgcolor = col_fg,
			bgcolor = col_bg,
			alignment = "left",
		})

		local content = VerticalGroup:new({
			highlight_group,
			VerticalSpan:new({ width = 24 }),
			source_text,
		})

		if clipping.note and clipping.note ~= "" then
			local separator = LineWidget:new({
				dimen = Geom:new({
					w = width,
					h = Size.line.thin,
				}),
				background = col_fg,
			})
			local note_text = TextBoxWidget:new({
				text = clipping.note,
				face = Font:getFace(fonts.note, fontSizeAlt()),
				width = width,
				fgcolor = col_fg,
				bgcolor = col_bg,
				alignment = "left",
				line_height = 0.4,
			})
			table.insert(content, VerticalSpan:new({ width = 32 }))
			table.insert(content, separator)
			table.insert(content, VerticalSpan:new({ width = 24 }))
			table.insert(content, note_text)
		end

		return content
	end

	local font_size_base = 48
	local content = buildContent(font_size_base)
	while content:getSize().h > Screen:getHeight() * 0.95 and font_size_base > 12 do
		font_size_base = font_size_base - 2
		content = buildContent(font_size_base)
	end

	local container = CenterContainer:new({
		dimen = Screen:getSize(),
		content,
		padding = 0,
		margin = 0,
		bgcolor = col_bg,
	})
	local screensaver_widget = ScreenSaverWidget:new({
		widget = container,
		background = col_bg,
		covers_fullscreen = true,
	})
	return screensaver_widget
end

return M
