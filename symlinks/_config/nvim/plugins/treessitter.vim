" Treesitter
" -------
if exists('g:plugs["nvim-treesitter"]')
lua << EOF
  require("nvim-treesitter.configs").setup({
    ensure_installed = { "javascript", "typescript", "lua", "vim", "json", "html", "rust", "tsx" },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true
    }
  })
EOF
endif
