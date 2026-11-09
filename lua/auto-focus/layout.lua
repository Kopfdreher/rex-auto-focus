local config = require("auto-focus.config")

local M = {}

local function leaves(node, out)
  if node == nil then
    return
  end
  if node.block_id then
    out[#out + 1] = node.block_id
    return
  end
  if node.split then
    leaves(node.split.before, out)
    leaves(node.split.after, out)
  end
end

local function weight_of(node, focus_id, inactive_share)
  local ids = {}
  leaves(node, ids)
  local weight = 0
  for _, id in ipairs(ids) do
    if id == focus_id then
      weight = weight + config.options.focus
    else
      weight = weight + inactive_share
    end
  end
  return weight
end

local function resize_tree(node, focus_id, inactive_share, session_id)
  if node == nil or node.split == nil then
    return
  end
  local split = node.split
  local before_w = weight_of(split.before, focus_id, inactive_share)
  local after_w = weight_of(split.after, focus_id, inactive_share)
  local total = before_w + after_w
  if total > 0 then
    local ratio = before_w / total
    local before_ids, after_ids = {}, {}
    leaves(split.before, before_ids)
    leaves(split.after, after_ids)
    if #before_ids > 0 and #after_ids > 0 and math.abs((split.ratio or 0) - ratio) > config.options.threshold then
      rex.session.resize_pane({
        session_id = session_id,
        direction = split.direction,
        before_block_id = before_ids[1],
        after_block_id = after_ids[1],
        ratio = ratio,
      })
    end
  end
  resize_tree(split.before, focus_id, inactive_share, session_id)
  resize_tree(split.after, focus_id, inactive_share, session_id)
end

local function tiled_layout(window)
  for _, layer in ipairs(window.layers or {}) do
    if layer.kind == "tiled" then
      return layer.layout
    end
  end
end

function M.apply_window(session_id, window)
  if window == nil or window.focused_block_id == nil then
    return false
  end
  local layout = tiled_layout(window)
  if layout == nil then
    return false
  end
  local ids = {}
  leaves(layout, ids)
  if #ids < 2 then
    return false
  end
  local inactive_share = (1 - config.options.focus) / (#ids - 1)
  resize_tree(layout, window.focused_block_id, inactive_share, session_id)
  return true
end

function M.apply_session(session_id)
  local view, err = rex.session.view({ session_id = session_id })
  if err ~= nil or view == nil then
    return nil, err
  end
  for _, window in ipairs(view.windows or {}) do
    if window.window_id == view.active_window_id then
      M.apply_window(session_id, window)
      break
    end
  end
  return true
end

function M.signature(window)
  local count = 0
  local function walk(node)
    if node == nil then
      return
    end
    if node.block_id then
      count = count + 1
    elseif node.split then
      walk(node.split.before)
      walk(node.split.after)
    end
  end
  walk(tiled_layout(window))
  return tostring(window.focused_block_id) .. ":" .. tostring(count)
end

return M
