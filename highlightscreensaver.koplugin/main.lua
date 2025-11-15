--[[--
Show a random highlight on your screensaver.

@module koplugin.HighlightScreensaver
--]]
--
--
local Dispatcher = require("dispatcher") -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Screensaver = require("ui/screensaver")
local _ = require("gettext")
local Device = require("device")
local lfs = require("libs/libkoreader-lfs")

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
	local popup = InfoMessage:new({
		text = _("Highlight Screensaver popup"),
	})
	UIManager:show(popup)
end

local function getDefaultRootDir()
	if Device:isCervantes() or Device:isKobo() then
		return "/mnt"
	elseif Device:isEmulator() then
		return lfs.currentdir()
	else
		return Device.home_dir or lfs.currentdir()
	end
end

local function getPluginDir()
	return getDefaultRootDir() .. "/onboard/highlight-screensaver"
end

local function makeDir(path)
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

function HighlightScreensaver:addToScannableDirectories()
	local path = getPluginDir() .. "/scannable-dirs.json"
	local fileRead = io.open(path, "r")
	local contents = fileRead and fileRead:read("*a") or "[]"
	if fileRead then
		fileRead:close()
	end

	local json = require("json")
	local dirs = json.decode(contents) or {}
	local currDir = lfs.currentdir()
	table.insert(dirs, currDir)

	local uniqueDirs = {}
	local seen = {}
	for _, dir in ipairs(dirs) do
		if not seen[dir] then
			table.insert(uniqueDirs, dir)
			seen[dir] = true
		end
	end

	local dir = getPluginDir()
	local attr = lfs.attributes(dir)
	if not attr then
		local ok, err = makeDir(getPluginDir())
		if not ok then
			error(tostring(err))
		end
	end

	local fileWrite, err = io.open(path, "w")
	if not fileWrite then
		error("Failed to open scannable-dirs file: " .. tostring(err))
	end
	fileWrite:write(json.encode(uniqueDirs))
	fileWrite:close()

	local popup = InfoMessage:new({
		text = _("Added to scannable directories: " .. currDir),
	})
	UIManager:show(popup)
end

return HighlightScreensaver
