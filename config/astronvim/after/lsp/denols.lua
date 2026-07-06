---@type vim.lsp.Config
return {
  -- root_markers: used by native vim.lsp.config API (nvim 0.10+)
  root_markers = { "deno.json", "deno.jsonc" },
  -- root_dir: used by deno-nvim → lspconfig.denols.setup(), which ignores root_markers.
  -- Without this, lspconfig falls back to its default which includes '.git',
  -- causing denols to start in every git project.
  root_dir = function(fname)
    return require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")(fname)
  end,
}
