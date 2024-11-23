-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Null-ls
-- =========================================
require("user.null_ls").config()

-- NvimTree
-- =========================================
require("user.nvim-tree").config()

-- Plugins
-- =========================================
require("user.plugins").config()

-- Nvim Lsp config
-- =========================================
require("user.nvim-lspconfig").config()

-- Keybindings
-- =========================================
require("user.keybindings").config()

-- Bufferline
-- =========================================
require("user.bufferline").config()

-- Which-key
-- =========================================
require("user.which-key").config()

-- Core
-- =========================================
require("user.core").config()
