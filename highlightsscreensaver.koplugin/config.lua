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
local Config = {}
Config.__index = Config

local function getConfigFilePath()
    return utils.getPluginDir() .. "/config.json"
end

---@return Config
function Config.load()
    local file = io.open(getConfigFilePath(), "r")
    local default_config = setmetatable({ theme = M.Theme.DARK, scannable_directories = {} }, Config)
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
    }, Config)
end

M.Config = Config

return M