local Blitbuffer = require("ffi/blitbuffer")
local CenterContainer = require("ui/widget/container/centercontainer")
local FrameContainer = require("ui/widget/container/framecontainer")
local Font = require("ui/font")
local TextWidget = require("ui/widget/textwidget")
local TextBoxWidget = require("ui/widget/textboxwidget")
local Device = require("device")
local Screen = Device.screen
local ScreenSaverWidget = require("ui/widget/screensaverwidget")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")

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
	local highlight_text = TextBoxWidget:new({
		text = clipping.text,
		face = Font:getFace("cfont", 24),
		width = Screen:getWidth() * 0.9,
		alignment = "center",
	})
	local source_text = TextWidget:new({
		text = "— " .. clipping.source_title .. ", " .. clipping.source_author,
		face = Font:getFace("infofont", 18),
	})

	local content = VerticalGroup:new({
		highlight_text,
		VerticalSpan:new({ width = 20 }),
		source_text,
	})

	local frame = FrameContainer:new({
		radius = 15,
		bordersize = 2,
		padding = 40,
		background = Blitbuffer.COLOR_WHITE,
		content,
	})

	local container = CenterContainer:new({
		dimen = Screen:getSize(),
		frame,
	})
	local screensaver_widget = ScreenSaverWidget:new({
		widget = container,
		background = Blitbuffer.COLOR_WHITE,
		covers_fullscreen = true,
	})

	return screensaver_widget
end

return M
