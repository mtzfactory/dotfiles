---@type LazySpec
return {
  {
    "stevearc/aerial.nvim",
    tag = "v2.6.0",
    opts = {
      -- Disable tree-sitter backend due to Neovim 0.12.2 compatibility issues
      backends = { "lsp", "markdown", "man" },
    },
  },
}


