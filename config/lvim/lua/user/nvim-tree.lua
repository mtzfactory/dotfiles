local M = {}

M.config = function()
  local nvimtree = lvim.builtin.nvimtree

  nvimtree.setup.view.adaptive_size = true
  nvimtree.setup.view.side = "right"
end


return M
