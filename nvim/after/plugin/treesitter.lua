require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "help", "query", "rust", "go", "javascript", "typescript", "python", "haskell"},
  sync_install = false,
  auto_install = true,
  ignore_install = { "javascript", "help" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
