return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
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
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]a"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[a"] = "@parameter.inner" },
        },
      },
    },
  },
}
