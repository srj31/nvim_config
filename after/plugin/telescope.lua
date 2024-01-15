local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find in all files" })
vim.keymap.set('n', '<C-f>', builtin.git_files, { desc = "Find in Git files" })
vim.keymap.set("n", "<leader>fw", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
    { desc = "Live grep" })
