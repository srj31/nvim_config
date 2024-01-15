local api = require "nvim-tree.api";
vim.keymap.set('n', '<C-n>', api.tree.toggle, {desc= "Toggle Nvim Tree"})
vim.keymap.set('n', '<leader>e', api.tree.focus, {desc= "Toggle Nvim Tree"})
