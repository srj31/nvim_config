return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      local ensure_installed = {
        "c", "cpp", "lua", "vim", "vimdoc", "query", "bash",
        "javascript", "typescript", "tsx", "rust", "ocaml", "ocaml_interface",
        "haskell", "python", "sql", "markdown", "markdown_inline",
        "c_sharp", "json", "yaml", "toml",
      }
      -- The main branch compiles parsers with the `tree-sitter` CLI, which must be
      -- on the system PATH (install it with `brew install tree-sitter`). Skip the
      -- install when it's missing so startup never errors; any already-compiled
      -- parsers keep highlighting working in the meantime.
      if vim.fn.executable("tree-sitter") == 1 then
        require("nvim-treesitter").install(ensure_installed)
      end

      -- env/.zshrc have no dedicated parser; highlight them with the bash parser.
      vim.treesitter.language.register("bash", { "env", "zsh" })

      -- The main branch has no `highlight` module: start treesitter per buffer.
      -- pcall no-ops for filetypes without an installed parser.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("srj31_ts_highlight", { clear = true }),
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            -- experimental main-branch indent (replaces the old `indent` module)
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      local function map_select(lhs, capture)
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(capture, "textobjects")
        end, { silent = true, desc = "Select " .. capture })
      end

      map_select("af", "@function.outer")
      map_select("if", "@function.inner")
      map_select("ac", "@class.outer")
      map_select("ic", "@class.inner")
      map_select("aa", "@parameter.outer")
      map_select("ia", "@parameter.inner")

      local function map_move(lhs, fn, capture)
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          fn(capture, "textobjects")
        end, { silent = true, desc = "Move " .. capture })
      end

      map_move("]f", move.goto_next_start, "@function.outer")
      map_move("]a", move.goto_next_start, "@parameter.inner")
      map_move("[f", move.goto_previous_start, "@function.outer")
      map_move("[a", move.goto_previous_start, "@parameter.inner")
    end,
  },
}
