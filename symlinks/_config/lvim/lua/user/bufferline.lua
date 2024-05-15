local M = {}

M.config = function()
  if lvim.builtin.bufferline.active then
    lvim.keys.normal_mode["<S-x>"] = "<Cmd>lua require('user.bufferline').delete_buffer()<CR>"
    lvim.keys.normal_mode["<S-l>"] = "<Cmd>BufferLineCycleNext<CR>"
    lvim.keys.normal_mode["<S-h>"] = "<Cmd>BufferLineCyclePrev<CR>"
    lvim.keys.normal_mode["[b"] = "<Cmd>BufferLineMoveNext<CR>"
    lvim.keys.normal_mode["]b"] = "<Cmd>BufferLineMovePrev<CR>"
  end
end

return M
