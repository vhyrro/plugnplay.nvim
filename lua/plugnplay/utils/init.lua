local utils = {}

---Gets the install method and the url to install based on the plugin url
--- At the moment types are `local` and `git_clone`
---@param url string The url of the plugin
---@return table #Table with `action` and `url` fields
function utils.get_install_action(url)
    local ret = {}
    if url:sub(1, 1) == "~" then
        url = vim.fn.expand("~") .. url:sub(2, -1)
    end
    if vim.fn.isdirectory(url) == 1 then
        ret.action = "local"
        ret.url = url
    elseif url:sub(1, 4) == "http" then
        ret.action = "git_clone"
        ret.url = url
    elseif url:match("^[%w-_.]+%/[%w-_.]+$") then
        ret.action = "git_clone"
        ret.url = "https://github.com/" .. url
    end
    return ret
end

return utils
