local json = require("json")
local utils = require("utils")

local M = {}

---@alias Theme
---| '"dark"'
---| '"light"'
M.Theme = {
    DARK = "dark",
    LIGHT = "light"
}

---@class Config
---@field theme Theme
---@field scannable_directories string[]
---@field last_scanned_date string|nil
local Config = {}
Config.__index = Config

local function getConfigFilePath()
    return utils.getPluginDir() .. "/config.json"
end

---@return Config
function M.load()
    local default_config = setmetatable({ theme = M.Theme.DARK, scannable_directories = {} }, Config)
    local file = io.open(getConfigFilePath(), "r")
    if not file then
        return default_config
    end

    local content = file:read("*a")
    file:close()
    local data = json.decode(content)
    if not data then
        return default_config
    end

    return setmetatable({
        theme = data.theme or M.Theme.DARK,
        scannable_directories = data.scannable_directories or {},
        last_scanned_date = data.last_scanned_date or nil
    }, Config)
end

function Config:save()
    local copy = {}
    for k, v in pairs(self) do
        copy[k] = v
    end
    setmetatable(copy, nil)
    local content = json.encode(copy, { indent = true })
    utils.makeDir(utils.getPluginDir())
    local file = assert(io.open(getConfigFilePath(), "w"))
    file:write(content)
    file:close()
end

M.Config = Config

return M