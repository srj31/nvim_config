return {
  { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000,
    opts = { flavour = "mocha" } },
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
  { "rose-pine/neovim", name = "rose-pine", lazy = false, priority = 1000 },
  { "ellisonleao/gruvbox.nvim", lazy = false, priority = 1000 },
  { "EdenEast/nightfox.nvim", lazy = false, priority = 1000 },
  { "sainnhe/everforest", lazy = false, priority = 1000 },
  { "gbprod/nord.nvim", lazy = false, priority = 1000 },
  { "olimorris/onedarkpro.nvim", lazy = false, priority = 1000 },
  { "sainnhe/sonokai", lazy = false, priority = 1000 },
  { "savq/melange-nvim", name = "melange", lazy = false, priority = 1000 },
  { "nyoom-engineering/oxocarbon.nvim", lazy = false, priority = 1000 },
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
          -- Catppuccin
          { name = "Catppuccin Mocha", colorscheme = "catppuccin-mocha" },
          { name = "Catppuccin Macchiato", colorscheme = "catppuccin-macchiato" },
          { name = "Catppuccin Frappe", colorscheme = "catppuccin-frappe" },
          { name = "Catppuccin Latte", colorscheme = "catppuccin-latte" },
          -- Tokyonight
          { name = "Tokyonight", colorscheme = "tokyonight" },
          { name = "Tokyonight Night", colorscheme = "tokyonight-night" },
          { name = "Tokyonight Storm", colorscheme = "tokyonight-storm" },
          { name = "Tokyonight Moon", colorscheme = "tokyonight-moon" },
          { name = "Tokyonight Day", colorscheme = "tokyonight-day" },
          -- Kanagawa
          { name = "Kanagawa Wave", colorscheme = "kanagawa-wave" },
          { name = "Kanagawa Dragon", colorscheme = "kanagawa-dragon" },
          { name = "Kanagawa Lotus", colorscheme = "kanagawa-lotus" },
          -- Rose Pine
          { name = "Rose Pine", colorscheme = "rose-pine" },
          { name = "Rose Pine Moon", colorscheme = "rose-pine-moon" },
          { name = "Rose Pine Dawn", colorscheme = "rose-pine-dawn" },
          -- Gruvbox (shares one colorscheme name; flip background per variant)
          { name = "Gruvbox Dark", colorscheme = "gruvbox", before = [[vim.o.background = "dark"]] },
          { name = "Gruvbox Light", colorscheme = "gruvbox", before = [[vim.o.background = "light"]] },
          -- Nightfox family
          { name = "Nightfox", colorscheme = "nightfox" },
          { name = "Duskfox", colorscheme = "duskfox" },
          { name = "Nordfox", colorscheme = "nordfox" },
          { name = "Terafox", colorscheme = "terafox" },
          { name = "Carbonfox", colorscheme = "carbonfox" },
          { name = "Dayfox", colorscheme = "dayfox" },
          -- Everforest (background + hardness set before load)
          { name = "Everforest Dark", colorscheme = "everforest", before = [[
            vim.o.background = "dark"
            vim.g.everforest_background = "hard"
          ]] },
          { name = "Everforest Light", colorscheme = "everforest", before = [[
            vim.o.background = "light"
            vim.g.everforest_background = "medium"
          ]] },
          -- Nord
          { name = "Nord", colorscheme = "nord" },
          -- OneDark Pro
          { name = "Onedark", colorscheme = "onedark" },
          { name = "Onedark Vivid", colorscheme = "onedark_vivid" },
          { name = "Onelight", colorscheme = "onelight" },
          -- Sonokai (style set before load)
          { name = "Sonokai", colorscheme = "sonokai", before = [[vim.g.sonokai_style = "default"]] },
          { name = "Sonokai Andromeda", colorscheme = "sonokai", before = [[vim.g.sonokai_style = "andromeda"]] },
          { name = "Sonokai Espresso", colorscheme = "sonokai", before = [[vim.g.sonokai_style = "espresso"]] },
          -- Melange & Oxocarbon (background set for safety)
          { name = "Melange", colorscheme = "melange", before = [[vim.o.background = "dark"]] },
          { name = "Oxocarbon", colorscheme = "oxocarbon", before = [[vim.o.background = "dark"]] },
        },
        livePreview = true,
      })

      vim.keymap.set("n", "<leader>tt", "<cmd>Themery<cr>", { desc = "Theme picker" })
    end,
  },
}
