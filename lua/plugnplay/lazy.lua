local fs = require("plugnplay.fs")
local json = require("plugnplay.json")
local lockfile_contents = fs.read_or_create(_G.pnp_state.config.plugnplay.lockfile, "{}")
local plugins = json.decode(lockfile_contents)
local log = require("plugnplay.external.log")

-- TODO: implement `wants`?
-- TODO: implement `after`

---@class lazy
local lazy = {}

--- Load given plugin
---@param plugin string Plugin name
lazy.load = function(plugin)
    local plug_conf = plugins[plugin]
    vim.cmd("packadd " .. plugin)
    if plug_conf.configuration == vim.NIL then
        return
    end
    if plug_conf.configuration.mod then
        require(plug_conf.configuration.mod)
    end
    if plug_conf.configuration.chunk then
        local success, err = pcall(loadstring, plug_conf.configuration.chunk)
        if not success then
            log.error("Error running config for " .. plugin .. ": " .. err)
        end
    end
end

lazy.event = function(plugin, event)
    vim.validate({ event = { event, "string" } })
    vim.api.nvim_create_autocmd(event, {
        pattern = "*",
        callback = function()
            lazy.load(plugin)
        end,
        once = true,
    })
end

local function lazy_load(plugin, config)
    if config.lazy_load == vim.NIL then
        return
    end
    local lazy_loading = config.lazy_load
    if lazy_loading.event ~= vim.NIL then
        lazy.event(plugin, lazy_loading.event)
    end
end

for plugin, config in pairs(plugins) do
    lazy_load(plugin, config)
end