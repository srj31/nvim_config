return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        section_separators = "",
        component_separators = "|",
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = { options = { diagnostics = "nvim_lsp" } },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find/format" },
        { "<leader>v", group = "lsp symbols" },
        { "<leader>a", group = "harpoon/diagnostics" },
        { "<leader>d", group = "debug" },
        { "<leader>h", group = "git hunks" },
        { "<leader>x", group = "trouble" },
        { "<leader>t", group = "theme/toggle" },
        { "<leader>g", group = "git" },
        { "<leader>c", group = "code" },
      },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix (Trouble)" },
    },
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    -- FSAC floods $/progress events during analysis; rendering each one bogs
    -- Neovim's UI thread (the "hang"). Ignore fsautocomplete's progress.
    opts = { progress = { ignore = { "fsautocomplete" } } },
  },
  { "stevearc/dressing.nvim", event = "VeryLazy", opts = {} },
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("alpha").setup(require("alpha.themes.startify").config)
    end,
  },
}
