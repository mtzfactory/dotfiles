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

  local null_ls = require("null-ls")

  local function safe_notify(message, level)
    vim.schedule(function()
      vim.notify(message, level)
    end)
  end

  local lspconfig_util = require("lspconfig.util")

  local function find_json()
    local root = lspconfig_util.find_git_ancestor(vim.loop.cwd())
    if not root then
      safe_notify("Git root not found. Are you in a Git repository?", vim.log.levels.ERROR)
      return nil
    end

    local json_path = root .. "/cspell.json"
    if vim.loop.fs_stat(json_path) then
      safe_notify("cspell.json found: " .. json_path, vim.log.levels.INFO)
      return json_path
    else
      vim.notify("cspell.json not found in: " .. root, vim.log.levels.WARN)
      return nil
    end
  end

  local config = {
    on_success = function(cspell_config_file, params)
      vim.notify("Formatting cspell.json: " .. cspell_config_file, vim.log.levels.INFO)
      os.execute(
        string.format(
          "cat %s | jq -S '.words |= sort' | tee %s > /dev/null",
          cspell_config_file,
          cspell_config_file
        )
      )
    end
  }

  lvim.lsp.null_ls.setup = {
    sources = {
      null_ls.builtins.diagnostics.cspell.with({
        extra_args = { "--config", find_json() },
        config = config,
      }),
      null_ls.builtins.code_actions.cspell.with({
        extra_args = { "--config", find_json() },
        config = config
      }),
    },
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
