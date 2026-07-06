local M = {}

M.config = function()
  if lvim.builtin.bufferline.active then
    lvim.keys.normal_mode["<S-x>"] = "<Cmd>lua require('user.bufferline').delete_buffer()<CR>"
    lvim.keys.normal_mode["<S-l>"] = "<Cmd>BufferLineCycleNext<CR>"
    lvim.keys.normal_mode["<S-h>"] = "<Cmd>BufferLineCyclePrev<CR>"
    lvim.keys.normal_mode["]b"] = "<Cmd>BufferLineMoveNext<CR>"
    lvim.keys.normal_mode["[b"] = "<Cmd>BufferLineMovePrev<CR>"

    lvim.builtin.which_key.mappings[" "] = { "<cmd>Telescope buffers<cr>", "Buffers" }

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
end

M.delete_buffer = function()
  local fn = vim.fn
  local cmd = vim.cmd
  local buflisted = fn.getbufinfo { buflisted = 1 }
  local cur_winnr, cur_bufnr = fn.winnr(), fn.bufnr()
  if #buflisted < 2 then
    cmd "confirm qall"
    return
  end
  for _, winid in ipairs(fn.getbufinfo(cur_bufnr)[1].windows) do
    cmd(string.format("%d wincmd w", fn.win_id2win(winid)))
    cmd(cur_bufnr == buflisted[#buflisted].bufnr and "bp" or "bn")
  end
  cmd(string.format("%d wincmd w", cur_winnr))
  local is_terminal = fn.getbufvar(cur_bufnr, "&buftype") == "terminal"
  cmd(is_terminal and "bd! #" or "silent! confirm bd #")
end

return M
