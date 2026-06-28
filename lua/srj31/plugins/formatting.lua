return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>fm",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters = {
        -- dotenv-linter has no stdin mode; fix the buffer's temp file in place.
        dotenv_fix = {
          command = "dotenv-linter",
          args = { "fix", "--no-backup", "$FILENAME" },
          stdin = false,
        },
      },
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        ocaml = { "ocamlformat" },
        haskell = { "fourmolu" },
        sh = { "shfmt" },
        sql = { "sql_formatter" },
        env = { "dotenv_fix" },
        python = { "ruff_format" },
        lua = { "stylua" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = { sh = { "shellcheck" }, env = { "dotenv_linter" } }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("srj31_lint", { clear = true }),
        callback = function()
          -- Skip linters whose binary isn't installed yet (e.g. before mason
          -- finishes), so a missing tool doesn't spam errors on every buffer.
          local runnable = {}
          for _, name in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
            local linter = lint.linters[name]
            if linter and vim.fn.executable(linter.cmd) == 1 then
              table.insert(runnable, name)
            end
          end
          if #runnable > 0 then
            lint.try_lint(runnable)
          end
        end,
      })
    end,
  },
}
