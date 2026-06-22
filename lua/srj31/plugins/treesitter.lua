return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "c", "cpp", "lua", "vim", "vimdoc", "query", "bash",
        "javascript", "typescript", "tsx", "rust", "ocaml", "ocaml_interface",
        "haskell", "python", "sql", "markdown", "markdown_inline",
        "c_sharp", "json", "yaml", "toml",
      },
      sync_install = false,
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
    },
  },
}
