local source = debug.getinfo(1, "S").source
local root = source:match("^@?(.+)/plugin/auto%-focus%.lua$")
if root == nil then
  error("auto-focus: could not locate the plugin directory from " .. source, 0)
end
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path
require("auto-focus").watch()
