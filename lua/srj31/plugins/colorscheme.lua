return {
  { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000,
    opts = { flavour = "mocha" } },
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
  { "rose-pine/neovim", name = "rose-pine", lazy = false, priority = 1000 },
  { "ellisonleao/gruvbox.nvim", lazy = false, priority = 1000 },
  { "EdenEast/nightfox.nvim", lazy = false, priority = 1000 },
  {
    "zaldih/themery.nvim",
    lazy = false,
    priority = 999,
    config = function()
      -- Apply a default first; themery overrides it with the persisted pick (if any).
      pcall(vim.cmd.colorscheme, "catppuccin-mocha")

      -- Keep custom line-number highlights across theme switches.
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("srj31_linenr_hl", { clear = true }),
        callback = function()
          vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#919191", bold = true })
          vim.api.nvim_set_hl(0, "LineNr", { fg = "#51B3EC", bold = true })
          vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#919191", bold = true })
        end,
      })

      require("themery").setup({
        themes = {
          { name = "Catppuccin Mocha", colorscheme = "catppuccin-mocha" },
          { name = "Catppuccin Macchiato", colorscheme = "catppuccin-macchiato" },
          { name = "Tokyonight", colorscheme = "tokyonight" },
          { name = "Tokyonight Night", colorscheme = "tokyonight-night" },
          { name = "Kanagawa", colorscheme = "kanagawa" },
          { name = "Rose Pine", colorscheme = "rose-pine" },
          { name = "Gruvbox", colorscheme = "gruvbox" },
          { name = "Nightfox", colorscheme = "nightfox" },
        },
        livePreview = true,
      })

      vim.keymap.set("n", "<leader>tt", "<cmd>Themery<cr>", { desc = "Theme picker" })
    end,
  },
}
