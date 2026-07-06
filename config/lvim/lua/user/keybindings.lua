local M = {}

M.config = function()
  local kind = require('user.kind')
  local wk = lvim.builtin.which_key

  wk.mappings["c"] = {
    name = "Diagnostics",
    d = { "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Document" },
    l = { "<cmd>Trouble loclist toggle<cr>", "Location list" },
    q = { "<cmd>Trouble qflist toggle<cr>", "Quickfix list" },
    r = { "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "References" },
    s = { "<cmd>Trouble symbols toggle focus=false<cr>", "Symbols" },
    t = { "<cmd>Trouble diagnostics toggle<cr>", "Trouble" },
  }

  wk.mappings["l"]["t"] = { ":LvimToggleFormatOnSave<cr>", kind.symbols_outline.File .. " Toggle format-on-save" }
  wk.mappings["l"]["R"] = { ":LspRestart<cr>", kind.icons.exit .. " Restart" }

  wk.mappings["s"]["w"] = {
    "<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.expand('<cword>') })<cr>",
    kind.cmp_kind.EnumMember .. " Search Word Under Cursor"
  }

  wk.mappings["t"] = {
    name = "Test",
    f = { "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", "File" },
    n = { "<cmd>lua require('neotest').run.run()<cr>", "Nearest" },
    o = { "<cmd>lua require('neotest').output_panel.open({enter=true})<cr>", "Output" },
    s = { "<cmd>lua require('neotest').summary.open()<cr>", "Summary" },
    w = { "<cmd>lua require('neotest').watch.open(vim.fn.expand('%'))<cr>", "Watch" }
    -- w = { "<cmd>lua require('neotest').run.run({ jestCommand = 'jest --watch ' })<cr>", "Watch" }
  }

  wk.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without Formatting" }

  wk.mappings['x'] = { ":xa<cr>", "Save All and Quit" }

  -- Navigate next or previous diagnostic
  lvim.keys.normal_mode["]d"] = "<cmd>lua vim.diagnostic.goto_next()<cr>"
  lvim.keys.normal_mode["[d"] = "<cmd>lua vim.diagnostic.goto_prev()<cr>"

  -- Navigate next or previous change
  lvim.keys.normal_mode["]c"] = "<cmd>Gitsigns next_hunk<cr>"
  lvim.keys.normal_mode["[c"] = "<cmd>Gitsigns prev_hunk<cr>"

  -- Jump back from go to definition
  lvim.keys.normal_mode["<C-t>"] = ":pop<cr>"

  -- F12 toggles relativenumber
  lvim.keys.normal_mode["<F12>"] = ":set relativenumber!<cr>"

  -- Open recent files
  lvim.keys.normal_mode["<C-o>"] = "<cmd>Telescope oldfiles<cr>"

  -- Show diagnostics on hover
  vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
end

return M
