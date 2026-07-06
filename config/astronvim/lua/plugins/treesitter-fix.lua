---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Disable markdown tree-sitter highlighting due to Neovim 0.12.2 compatibility issues
      if opts.highlight then
        opts.highlight.disable = opts.highlight.disable or {}
        if type(opts.highlight.disable) == "table" then
          table.insert(opts.highlight.disable, "markdown")
          table.insert(opts.highlight.disable, "markdown_inline")
        end
      end
      return opts
    end,
  },
}
