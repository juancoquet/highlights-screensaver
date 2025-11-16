local Blitbuffer = require("ffi/blitbuffer")
local CenterContainer = require("ui/widget/container/centercontainer")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local TextBoxWidget = require("ui/widget/textboxwidget")
local Device = require("device")
local Screen = Device.screen
local ScreenSaverWidget = require("ui/widget/screensaverwidget")
local Size = require("ui/size")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local LineWidget = require("ui/widget/linewidget")

local clipper = require("clipper")

local M = {}

function M.buildHighlightsScreensaverWidget()
	local clipping = clipper.Clipping.new(
		"The chief financial officer at Lucasfilm found Jobs arrogant and prickly, so when it came time to hold a meeting of all the players, he told Catmull, “We have to establish the right pecking order.” The plan was to gather everyone in a room with Jobs, and then the CFO would come in a few minutes late to establish that he was the person running the meeting. “But a funny thing happened,” Catmull recalled. “Steve started the meeting on time without the CFO, and by the time the CFO walked in Steve was already in control of the meeting.”",
		"Pretend to be completely in control, and people will assume that you are.",
		"2025-11-12 00:19:09",
		"Steve Jobs",
		"Walter Isaacson",
		true
	)
	local col_fg, col_bg = Blitbuffer.COLOR_WHITE, Blitbuffer.COLOR_BLACK
	local width = Screen:getWidth() * 0.90

	local highlight_text = TextBoxWidget:new({
		text = clipping.text,
		face = Font:getFace("cfont", 24),
		width = width,
		alignment = "left",
		justified = true,
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

	local source_text = TextBoxWidget:new({
		text = "— " .. clipping.source_title .. ", " .. clipping.source_author,
		face = Font:getFace("infofont", 18),
		width = width,
		fgcolor = col_fg,
		bgcolor = col_bg,
		alignment = "left",
	})

	local content = VerticalGroup:new({
		highlight_group,
		VerticalSpan:new({ width = 20 }),
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
			face = Font:getFace("cfont", 18),
			width = width,
			fgcolor = col_fg,
			bgcolor = col_bg,
			alignment = "left",
			line_height = 0.4,
		})
		table.insert(content, VerticalSpan:new({ width = 40 }))
		table.insert(content, separator)
		table.insert(content, VerticalSpan:new({ width = 20 }))
		table.insert(content, note_text)
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
