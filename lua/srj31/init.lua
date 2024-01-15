require("srj31.remap")
require("srj31.set")
require("srj31.lazy")

require("lazy").setup({
    "folke/which-key.nvim",
    {
        "folke/neoconf.nvim", cmd = "Neoconf"
    },
    "folke/neodev.nvim",
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },

    {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
    {"mbbill/undotree"},
    {"tpop/vim-fugitive"},
    {'williamboman/mason.nvim'},
    {'williamboman/mason-lspconfig.nvim'},

    {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/nvim-cmp'},
    {'L3MON4D3/LuaSnip'},
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup {}
        end,
    }
})
