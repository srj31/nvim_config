-- NOTE: <C-h/j/k/l> are intentionally NOT mapped here; vim-tmux-navigator
-- provides them (navigates vim splits AND tmux panes).

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })
vim.keymap.set("n", "<leader>p", [["+P]], { desc = "Paste from system clipboard" })

vim.keymap.set("n", "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("v", "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

vim.keymap.set("n", "<leader>d", [["_d]], { desc = "Delete to black hole" })
vim.keymap.set("v", "<leader>d", [["_d]], { desc = "Delete to black hole" })

vim.keymap.set("n", "<leader>{", "^dt{d%", { desc = "Delete to/incl brace block" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Substitute word under cursor" })
