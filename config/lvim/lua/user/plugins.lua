local M = {}

-- Install plugins --> <leader>p i

M.config = function()
  lvim.plugins = {
    {
      "aznhe21/actions-preview.nvim",
      config = function()
        vim.api.nvim_create_user_command("CodeActions", function()
          require("actions-preview").code_actions()
        end, {})
        vim.api.nvim_set_keymap("n", "<Leader>ac", "<cmd>CodeActions<cr>", { silent = true })
      end,
    },
    {
      "catppuccin/nvim",
      name = "catppuccin-mocha",
      priority = 1000,
      config = function()
        lvim.colorscheme = "catppuccin-mocha"
      end
    },
    -- {
    --   "scottmckendry/cyberdream.nvim",
    --   lazy = false,
    --   priority = 1000,
    --   config = function()
    --     require("cyberdream").setup({
    --       transparent = true,
    --       italic_comments = true,
    --       hide_fillchars = true,
    --       borderless_telescope = false,
    --     })
    --     lvim.colorscheme = "cyberdream"
    --   end,
    -- },
    -- {
    --   "wadackel/vim-dogrun",
    --   config = function()
    --     lvim.colorscheme = "dogrun"
    --   end
    -- },
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        local harpoon = require("harpoon")
        harpoon:setup()
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
        vim.keymap.set("n", "hm", function() harpoon.mark:add_file() end)
        vim.keymap.set("n", "hn", function() harpoon.ui:nav_next() end)
        vim.keymap.set("n", "hp", function() harpoon.ui:nav_prev() end)
      end
    },
    {
      'echasnovski/mini.clue',
      version = '*',
      config = function()
        local miniclue = require('mini.clue')
        miniclue.setup({
          triggers = {
            -- Leader triggers
            -- { mode = 'n', keys = '<Leader>' },
            -- { mode = 'x', keys = '<Leader>' },

            -- Built-in completion
            { mode = 'i', keys = '<C-x>' },

            -- `g` key
            { mode = 'n', keys = 'g' },
            { mode = 'x', keys = 'g' },

            -- Marks
            { mode = 'n', keys = "'" },
            { mode = 'n', keys = '`' },
            { mode = 'x', keys = "'" },
            { mode = 'x', keys = '`' },

            -- Registers
            { mode = 'n', keys = '"' },
            { mode = 'x', keys = '"' },
            { mode = 'i', keys = '<C-r>' },
            { mode = 'c', keys = '<C-r>' },

            -- Window commands
            { mode = 'n', keys = '<C-w>' },

            -- `z` key
            { mode = 'n', keys = 'z' },
            { mode = 'x', keys = 'z' },
          },
          clues = {
            -- Enhance this by adding descriptions for <Leader> mapping groups
            miniclue.gen_clues.builtin_completion(),
            miniclue.gen_clues.g(),
            miniclue.gen_clues.marks(),
            miniclue.gen_clues.registers(),
            miniclue.gen_clues.windows(),
            miniclue.gen_clues.z(),
          },
          window = {
            delay = 500,
            config = {
              width = 'auto',
            },
          },
        })
      end
    },
    {
      "windwp/nvim-ts-autotag",
      dependencies = "nvim-treesitter/nvim-treesitter",
      config = function()
        require('nvim-ts-autotag').setup({
          {
            filetypes = {
              "html", "javascript", "javascriptreact", "typescriptreact"
            }
          }
        })
      end,
      event = "VeryLazy",
      lazy = true
    },
    { "tpope/vim-surround" },
    {
      "folke/todo-comments.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("todo-comments").setup()
      end,
      event = "BufRead"
    },
    {
      "nvim-neotest/neotest",
      dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-jest",
      },
      config = function()
        require('neotest').setup({
          adapters = {
            require("neotest-jest")({
              -- jestCommand = require("neotest-jest.jest-util").getJestCommand(vim.fn.expand "%:p:h"),
              jestConfigFile = function(file)
                if string.find(file, "/packages/") then
                  return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
                end

                return vim.fn.getcwd() .. "/jest.config.ts"
              end,
              cwd = function(path)
                if string.find(path, "/packages/") then
                  return string.match(path, "(.-/[^/]+/)src")
                end
                return vim.fn.getcwd()
              end,
            }),
          }
        })
      end
    },
    {
      "antosha417/nvim-lsp-file-operations",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-tree.lua",
      },
      config = function()
        require("lsp-file-operations").setup()
      end,
    },
    {
      "folke/trouble.nvim",
      opts = {},
      cmd = "Trouble",
    },
    -- {
    --   "davidmh/cspell.nvim",
    --   dependencies = { "nvim-telescope/telescope.nvim" },
    -- }
    {
      "catgoose/nvim-colorizer.lua",
      event = "BufReadPre",
      opts = {},
    }
  }
end

return M
