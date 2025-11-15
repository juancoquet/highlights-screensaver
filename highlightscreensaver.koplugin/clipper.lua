local utils = require("utils")

---@class Clipping
---@field text string
---@field note string|nil
---@field created_at string
---@field source_title string
---@field source_author string|nil
local Clipping = {}
Clipping.__index = Clipping

---@param self Clipping
---@return string
function Clipping:filename()
	return utils.normalise(self.source_title .. " " .. self.created_at)
end

local M = {}

---@param path string
---@return Clipping
function M.extractClipping(path)
end

return M
