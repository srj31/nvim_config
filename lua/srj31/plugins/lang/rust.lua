return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            vim.keymap.set("n", "<C-space>", function() vim.cmd.RustLsp({ "hover", "actions" }) end,
              { buffer = bufnr, desc = "Rust hover actions" })
            vim.keymap.set("n", "<leader>a", function() vim.cmd.RustLsp("codeAction") end,
              { buffer = bufnr, desc = "Rust code action" })
          end,
          default_settings = { ["rust-analyzer"] = {} },
        },
      }
    end,
  },
}
