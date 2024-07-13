local M = {}

local function set_bufferline_keymaps()
  lvim.keys.normal_mode["<S-x>"] = "<Cmd>lua require('user.bufferline').delete_buffer()<CR>"
  lvim.keys.normal_mode["<S-l>"] = "<Cmd>BufferLineCycleNext<CR>"
  lvim.keys.normal_mode["<S-h>"] = "<Cmd>BufferLineCyclePrev<CR>"
  lvim.keys.normal_mode["]b"] = "<Cmd>BufferLineMoveNext<CR>"
  lvim.keys.normal_mode["[b"] = "<Cmd>BufferLineMovePrev<CR>"
  -- lvim.builtin.which_key.mappings["c"] = {}
  -- lvim.builtin.which_key.mappings.b = {
  --   name = " Buffer",
  --   ["1"] = { "<Cmd>BufferLineGoToBuffer 1<CR>", "goto 1" },
  --   ["2"] = { "<Cmd>BufferLineGoToBuffer 2<CR>", "goto 2" },
  --   ["3"] = { "<Cmd>BufferLineGoToBuffer 3<CR>", "goto 3" },
  --   ["4"] = { "<Cmd>BufferLineGoToBuffer 4<CR>", "goto 4" },
  --   ["5"] = { "<Cmd>BufferLineGoToBuffer 5<CR>", "goto 5" },
  --   ["6"] = { "<Cmd>BufferLineGoToBuffer 6<CR>", "goto 6" },
  --   ["7"] = { "<Cmd>BufferLineGoToBuffer 7<CR>", "goto 7" },
  --   ["8"] = { "<Cmd>BufferLineGoToBuffer 8<CR>", "goto 8" },
  --   ["9"] = { "<Cmd>BufferLineGoToBuffer 9<CR>", "goto 9" },
  --   c = { "<Cmd>BufferLinePickClose<CR>", "delete buffer" },
  --   p = { "<Cmd>BufferLineTogglePin<CR>", "toggle pin" },
  --   s = { "<Cmd>BufferLinePick<CR>", "pick buffer" },
  --   t = { "<Cmd>BufferLineGroupToggle docs<CR>", "toggle groups" },
  --   f = { "<cmd>Telescope buffers<cr>", "Find" },
  --   b = { "<cmd>b#<cr>", "Previous" },
  --   h = { "<cmd>BufferLineCloseLeft<cr>", "Close all to the left" },
  --   l = {
  --     "<cmd>BufferLineCloseRight<cr>",
  --     "Close all to the right",
  --   },
  --   D = {
  --     "<cmd>BufferLineSortByDirectory<cr>",
  --     "Sort by directory",
  --   },
  --   L = {
  --     "<cmd>BufferLineSortByExtension<cr>",
  --     "Sort by language",
  --   },
  -- }
end

M.config = function()
  -- Additional keybindings
  -- =========================================
  lvim.keys.normal_mode["]d"] = "<cmd>lua vim.diagnostic.goto_next()<cr>"
  lvim.keys.normal_mode["[d"] = "<cmd>lua vim.diagnostic.goto_prev()<cr>"

  -- Jump back from go to definition
  lvim.keys.normal_mode["<C-t>"] = ":pop<cr>"

  -- Unsets the 'last search pattern' register by hitting return
  vim.api.nvim_set_keymap("n", "<CR>", ":noh<CR>", { noremap = true, silent = true })

  -- F12 toggles relativenumber
  vim.api.nvim_set_keymap("n", "<F12>", ":set relativenumber!<CR>", { noremap = true, silent = true })

  if lvim.builtin.bufferline.active then
    set_bufferline_keymaps()
  end
end

return M
