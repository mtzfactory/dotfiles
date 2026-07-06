-- obsidian.nvim - Neovim integration for Obsidian vaults
-- https://github.com/obsidian-nvim/obsidian.nvim
---@type LazySpec
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  event = {
    "BufReadPre /Users/ricardo.martinez/development/personal/notes/obsidian/**.md",
    "BufNewFile /Users/ricardo.martinez/development/personal/notes/obsidian/**.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "/Users/ricardo.martinez/development/personal/notes/obsidian",
      },
      -- Puedes agregar más vaults:
      -- {
      --   name = "work",
      --   path = "~/work/notes",
      -- },
    },

    -- Directorio para notas nuevas (relativo al vault)
    notes_subdir = "inbox",

    -- Template para notas nuevas
    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.date "%Y%m%d") .. "-" .. suffix
    end,

    -- Completado de [[wikilinks]] con nvim-cmp / blink.cmp
    completion = {
      nvim_cmp = true,   -- si usas nvim-cmp
      -- blink = true,   -- si usas blink.cmp
      min_chars = 2,
    },

    -- Mappings dentro de archivos markdown
    mappings = {
      -- Seguir link bajo cursor (normal + visual)
      ["gf"] = {
        action = function() return require("obsidian").util.gf_passthrough() end,
        opts = { noremap = false, expr = true, buffer = true, desc = "Obsidian: follow link" },
      },
      -- Toggle checkbox
      ["<Leader>ch"] = {
        action = function() return require("obsidian").util.toggle_checkbox() end,
        opts = { buffer = true, desc = "Obsidian: toggle checkbox" },
      },
      -- Smart action (enter en link / crear nota)
      ["<CR>"] = {
        action = function() return require("obsidian").util.smart_action() end,
        opts = { buffer = true, expr = true, desc = "Obsidian: smart action" },
      },
    },

    -- Estilo visual de los wikilinks, etiquetas, etc.
    ui = {
      enable = true,
      update_debounce = 200,
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
        [">"] = { char = "", hl_group = "ObsidianRightArrow" },
        ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        ["!"] = { char = "", hl_group = "ObsidianImportant" },
      },
    },

    -- Picker (usa telescope si está disponible, si no fzf-lua)
    picker = {
      name = "telescope.nvim",
      -- name = "fzf-lua",
      -- name = "mini.pick",
    },
  },

  -- Keymaps globales con <Leader>O
  config = function(_, opts)
    require("obsidian").setup(opts)

    local map = vim.keymap.set
    map("n", "<Leader>On", "<Cmd>ObsidianNew<CR>",          { desc = "Obsidian: new note" })
    map("n", "<Leader>Oo", "<Cmd>ObsidianOpen<CR>",         { desc = "Obsidian: open in app" })
    map("n", "<Leader>Of", "<Cmd>ObsidianQuickSwitch<CR>",  { desc = "Obsidian: find note" })
    map("n", "<Leader>Os", "<Cmd>ObsidianSearch<CR>",       { desc = "Obsidian: search" })
    map("n", "<Leader>Ob", "<Cmd>ObsidianBacklinks<CR>",    { desc = "Obsidian: backlinks" })
    map("n", "<Leader>Ot", "<Cmd>ObsidianTags<CR>",         { desc = "Obsidian: tags" })
    map("n", "<Leader>Od", "<Cmd>ObsidianToday<CR>",        { desc = "Obsidian: daily note" })
    map("n", "<Leader>Oy", "<Cmd>ObsidianYesterday<CR>",    { desc = "Obsidian: yesterday" })
    map("n", "<Leader>Ol", "<Cmd>ObsidianLinks<CR>",        { desc = "Obsidian: links in note" })
    map("n", "<Leader>OL", "<Cmd>ObsidianLinkNew<CR>",      { desc = "Obsidian: link new note" })
    map("v", "<Leader>OL", "<Cmd>ObsidianLinkNew<CR>",      { desc = "Obsidian: link new note" })
    map("n", "<Leader>Op", "<Cmd>ObsidianPasteImg<CR>",     { desc = "Obsidian: paste image" })
    map("n", "<Leader>OT", "<Cmd>ObsidianTemplate<CR>",     { desc = "Obsidian: insert template" })
    map("n", "<Leader>Ow", "<Cmd>ObsidianWorkspace<CR>",    { desc = "Obsidian: switch workspace" })
  end,
}
