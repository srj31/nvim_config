vim.opt.termguicolors = true
local bufferline = require('bufferline')

bufferline.setup {
    options = {
        diagnostics = "nvim_lsp",
    }
}
