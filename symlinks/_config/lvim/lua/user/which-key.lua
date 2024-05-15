local M = {}

M.config = function()
  local kind = require('user.kind')
  local wk = lvim.builtin.which_key

  wk.mappings["l"]["t"] = { ":LvimToggleFormatOnSave<cr>", kind.symbols_outline.File .. " Toggle format-on-save" }
  wk.mappings["l"]["R"] = { ":LspRestart<cr>", kind.icons.exit .. " Restart" }

  wk.mappings["s"]["w"] = {
    "<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.expand('<cword>') })<cr>",
    ' ' .. kind.cmp_kind.EnumMember .. " Search Word Under Cursor"
  }

  wk.mappings['x'] = { ":xa<cr>", "Save All and Quit", }
end

return M
