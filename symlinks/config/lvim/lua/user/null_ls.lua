local M = {}

-- Install plugins using Mason --> <leader>l I

M.config = function()
  local linters = require "lvim.lsp.null-ls.linters"
  linters.setup {
    {
      command = "eslint_d",
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx"
      }
    }
  }

  local formatters = require "lvim.lsp.null-ls.formatters"
  formatters.setup {
    {
      command = "eslint_d",
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx"
      },
    },
    {
      command = "prettierd",
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx"
      },
    },
  }

  local code_actions = require "lvim.lsp.null-ls.code_actions"
  code_actions.setup {
    {
      command = "eslint_d",
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx"
      },
    }
  }

  -- linter and formatter for ruby
  vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "solargraph" })
  require("lspconfig").solargraph.setup({})
  local null_ls = require("null-ls")
  local sources = { null_ls.builtins.diagnostics.rubocop }
  null_ls.register({ sources = sources })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    pattern = {
      'Appfile',
      "Deliverfile",
      'Fastfile',
      "Gymfile",
      'Matchfile',
      "Snapfile",
      "Scanfile",
      'Pluginfile',
    },
    command = "set filetype=ruby",
  })
end

return M
