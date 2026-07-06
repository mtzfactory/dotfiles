---@type LazySpec
return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Disable both scope and indent due to Neovim 0.12.2 tree-sitter compatibility issues
      opts.scope = vim.tbl_extend("force", opts.scope or {}, {
        enabled = false,
      })
      opts.indent = vim.tbl_extend("force", opts.indent or {}, {
        enabled = false,
      })
      return opts
    end,
  },
}

