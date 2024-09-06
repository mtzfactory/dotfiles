local M = {}

M.config = function()
  lvim.format_on_save.enabled = true

  lvim.builtin.nvimtree.setup.update_focused_file = {
    enable = true,
    update_cwd = true,
  }
end


return M
