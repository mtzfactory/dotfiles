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
end

return M
