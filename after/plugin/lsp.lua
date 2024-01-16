local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
    local function opts(desc)
        return { desc = desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts("Goto Definition"))
    vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts("Goto Reference"))
    vim.keymap.set("n", "<leader>lf", vim.diagnostic.open_float, opts("Open Diagnostic"))
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts("Hover"))
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts("Goto Next Diagnostic"))
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts("Goto Prev Diagnostic"))
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts("Code Action"))
    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts("Rename"))
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts("Signature Help"))
    vim.keymap.set("n", "<leader>fm", function() vim.lsp.buf.format({ async = true }) end, opts("Format Code"))
end
)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { 'tsserver', 'rust_analyzer', 'ocamllsp' },
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end,
    }
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'luasnip', keyword_length = 2 },
        { name = 'buffer',  keyword_length = 3 },
    },
    formatting = lsp_zero.cmp_format(),
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
})
