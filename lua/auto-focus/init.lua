local config = require("auto-focus.config")
local layout = require("auto-focus.layout")

local M = {}
local seen = {}

local function on_view(session_id)
  local view, err = rex.session.view({ session_id = session_id })
  if err ~= nil or view == nil then
    return
  end
  for _, window in ipairs(view.windows or {}) do
    local key = session_id .. ":" .. window.window_id
    local signature = layout.signature(window)
    if seen[key] ~= signature then
      seen[key] = signature
      layout.apply_window(session_id, window)
    end
  end
end

function M.setup(opts)
  config.merge(opts)
  if rex.action == nil then
    return M
  end
  rex.action({
    name = "auto_focus",
    title = "Resize for focused pane",
    description = "Give the focused pane most of the tab and split the rest among the others.",
    category = "Layout",
    run = function(ctx, _args)
      local _, err = layout.apply_session(ctx.session_id)
      if err ~= nil then
        error(err, 0)
      end
    end,
  })
  return M
end

function M.watch()
  rex.on("session_view_changed", function(ctx, _ev)
    on_view(ctx.session_id)
  end)
  rex.on("active_window_changed", function(ctx, _ev)
    on_view(ctx.session_id)
  end)

  local sessions, err = rex.call("session.list")
  if err ~= nil or sessions == nil then
    return
  end
  for _, session in ipairs(sessions.sessions or sessions) do
    local id = session.session_id or session
    if type(id) == "string" then
      on_view(id)
    end
  end
end

M.apply_window = layout.apply_window
M.apply_session = layout.apply_session

return M
