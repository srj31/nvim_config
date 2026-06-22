return {
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Comment line" },
      { "gbc", mode = "n", desc = "Comment block" },
      { "gc", mode = { "n", "o", "x" }, desc = "Comment (linewise)" },
      { "gb", mode = { "n", "o", "x" }, desc = "Comment (blockwise)" },
    },
    opts = {},
  },
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function()
      vim.g.codeium_no_map_tab = 1
      vim.keymap.set("i", "<C-a>", function() return vim.fn["codeium#Accept"]() end, { expr = true })
      vim.keymap.set("i", "<C-;>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true })
      vim.keymap.set("i", "<C-,>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true })
      vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true })
    end,
  },
}
