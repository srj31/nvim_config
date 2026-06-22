local lsp_zero = require('lsp-zero')
local lspconfig = require 'lspconfig'
local configs = require 'lspconfig.configs'

local on_attach = lsp_zero.on_attach
local capabilities = lsp_zero.capabilities

configs.solidity = {
    default_config = {
        cmd = { 'nomicfoundation-solidity-language-server', '--stdio' },
        filetypes = { 'solidity' },
        root_dir = lspconfig.util.find_git_ancestor,
        single_file_support = true,
    },
}

lspconfig.clangd.setup {
    on_attach = function(client, bufnr)
        client.server_capabilities.signatureHelpProvider = false
        on_attach(client, bufnr)
    end,

    capabilities = capabilities,

}

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'sh',
    callback = function()
        vim.lsp.start({
            name = 'bash-language-server',
            cmd = { 'bash-language-server', 'start' },
        })
    end,
})


lsp_zero.on_attach(function(client, bufnr)
    local function opts(desc)
        return { desc = desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    -- setup compiler config for omnisharp
    if client and client.name == "omnisharp" then
        vim.keymap.set("n", "gd", require('omnisharp_extended').lsp_definition, opts("Goto Definition"))
        vim.keymap.set("n", "gr", require('omnisharp_extended').lsp_references, opts("Goto Reference"))
        vim.keymap.set("n", "gi", require('omnisharp_extended').lsp_implementation,
            opts("Goto Implementation"))
    end


    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts("Goto Definition"))
    vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts("Goto Reference"))
    vim.keymap.set("n", "gi", function() vim.lsp.buf.Implementation() end, opts("Goto Implementation"))
    vim.keymap.set("n", "<leader>ds", vim.diagnostic.open_float, opts("Open Diagnostic"))
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts("Hover"))
    -- all workspace diagnostics
    vim.keymap.set("n", "<leader>aa", vim.diagnostic.setqflist)

    -- all workspace errors
    vim.keymap.set("n", "<leader>ae", function()
        vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
    end)

    -- all workspace warnings
    vim.keymap.set("n", "<leader>aw", function()
        vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.WARN })
    end)

    vim.keymap.set("n", "<leader>ws", function()
        require("metals").hover_worksheet()
    end)
    vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts("Goto Next Diagnostic"))
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts("Goto Prev Diagnostic"))
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts("Code Action"))
    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts("Rename"))
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts("Signature Help"))
    vim.keymap.set("n", "<leader>fm", function() vim.lsp.buf.format({ async = true }) end, opts("Format Code"))
end
)
require('mason').setup({
    ensure_installed = { 'clangd-format', 'codelldb' }
})
require('mason-lspconfig').setup({
    ensure_installed = { 'tsserver', 'rust_analyzer', 'hls', 'ocamllsp', 'pyright', 'omnisharp', 'zls', 'fsautocomplete', 'clangd' },
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end,
        rust_analyzer = function()
            lspconfig.rust_analyzer.setup({
                on_attach = function(client, bufnr)
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            })
        end,
        hls = function()
            lspconfig.hls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    haskell = {
                        formattingProvider = "fourmolu",
                        plugin = {
                            retrie = { globalOn = false },
                            ormolu = { globalOn = false },
                            fourmolu = { globalOn = true },
                        },
                    },
                },
            })
        end

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
