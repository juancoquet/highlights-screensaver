local utils = require("utils")

---@class Clipping
---@field text string
---@field note string|nil
---@field created_at string
---@field source_title string
---@field source_author string|nil
local Clipping = {}
Clipping.__index = Clipping

---@param text string
---@param note string|nil
---@param created_at string
---@param source_title string
---@param source_author string|nil
---@return Clipping
function Clipping.new(text, note, created_at, source_title, source_author)
	local self = setmetatable({}, Clipping)
	self.text = text
	self.note = note
	self.created_at = created_at
	self.source_title = source_title
	self.source_author = source_author
	return self
end

---@param self Clipping
---@return string
function Clipping:filename()
	return utils.normalise(self.source_title .. " " .. self.created_at)
end

local M = {}

---@param path string
---@return Clipping[]
function M.extractClippingsFromSidecar(path)
	local metadata = dofile(path .. "/metadata.epub.lua")
	local authors = metadata.stats.authors
	local title = metadata.stats.title
	local clippings = {}

	for _, annotation in ipairs(metadata.annotations) do
		local clipping = Clipping.new(annotation.text, annotation.note or nil, annotation.datetime, title, authors)
		table.insert(clippings, clipping)
	end

	return clippings
end

return M
