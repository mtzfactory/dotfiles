local M = {}

-- Install plugins using Mason --> <leader>l I

M.config = function()
  lvim.lsp.null_ls.setup.debug = true

  local condition_eslintd = function(utils)
    return utils.root_has_file({
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      ".eslintrc.json",
      "eslint.config.js",
      "eslint.config.mjs",
      "eslint.config.json"
    })
  end

  local condition_prettierd = function(utils)
    return utils.root_has_file({
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.yml",
      ".prettierrc.yaml",
      ".prettierrc.json5",
      ".prettierrc.js",
      ".prettierrc.cjs",
      ".prettierrc.toml",
      "prettier.config.js",
      "prettier.config.cjs"
    })
  end

  local linters = require "lvim.lsp.null-ls.linters"
  linters.setup {
    {
      command = "eslint_d",
      condition = condition_eslintd
    }
  }

  local formatters = require "lvim.lsp.null-ls.formatters"
  formatters.setup {
    {
      command = "eslint_d",
      condition = condition_eslintd,
    },
    {
      command = "prettierd",
      condition = condition_prettierd
    }
  }

  local code_actions = require "lvim.lsp.null-ls.code_actions"
  code_actions.setup { { command = "eslint_d" } }

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
