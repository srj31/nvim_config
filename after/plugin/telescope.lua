local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find Files" })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Find Buffers" })
vim.keymap.set('n', '<C-f>', builtin.git_files, { desc = "Find Git files" })
vim.keymap.set("n", "<leader>fw", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
    { desc = "Live grep" })
vim.keymap.set("n", "<leader>vws", builtin.lsp_workspace_symbols, { desc = "Find Workspace Symbol" })
vim.keymap.set("n", "<leader>vds", builtin.lsp_document_symbols, { desc = "Find Workspace Symbol" })
