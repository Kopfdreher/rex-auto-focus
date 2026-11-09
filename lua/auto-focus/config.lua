local M = {}

M.defaults = {
  focus = 0.70,
  threshold = 0.005,
}

M.options = {
  focus = M.defaults.focus,
  threshold = M.defaults.threshold,
}

function M.merge(opts)
  opts = opts or {}
  M.options = {
    focus = opts.focus or M.defaults.focus,
    threshold = opts.threshold or M.defaults.threshold,
  }
  return M.options
end

return M
