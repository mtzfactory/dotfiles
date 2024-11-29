local M = {}

M.config = function()
  lvim.format_on_save.enabled = true

  lvim.builtin.nvimtree.setup.update_focused_file = {
    enable = true,
    update_cwd = true,
  }

  lvim.builtin.telescope.defaults.layout_config = {
    height = 0.65,
    width = 0.65,
  }

  -- folding powered by treesitter
  -- https://github.com/nvim-treesitter/nvim-treesitter#folding
  -- look for foldenable: https://github.com/neovim/neovim/blob/master/src/nvim/options.lua
  -- Vim cheatsheet, look for folds keys: https://devhints.io/vim
  vim.opt.foldmethod = "expr"                     -- default is "normal"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- default is ""
  vim.opt.foldenable = false                      -- if this option is true and fold method option is other than normal, every time a document is opened everything will be folded.
end


return M
