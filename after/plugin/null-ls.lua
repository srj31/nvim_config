local null_ls = require("null-ls")

local formatting = null_ls.builtins.formatting
local lint = null_ls.builtins.diagnostics

require("mason-null-ls").setup({
    ensure_installed = { "ruff" }
})


local sources = {
    formatting.prettier,
    formatting.ocamlformat,
    formatting.shfmt,
    formatting.fourmolu,
    lint.shellcheck
}

null_ls.setup({
    debug = true,
    sources = sources,
})
