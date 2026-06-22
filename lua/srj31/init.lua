require("srj31.remap")
require("srj31.set")
require("srj31.lazy")

local map = vim.keymap.set

require("lazy").setup({
    "folke/which-key.nvim",
    {
        "folke/neoconf.nvim", cmd = "Neoconf"
    },
    "folke/neodev.nvim",
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = {
            'nvim-lua/plenary.nvim',
            "nvim-telescope/telescope-live-grep-args.nvim",
            -- This will not install any breaking changes.
            -- For major updates, this must be adjusted manually.
            version = "^1.0.0",
        },
        config = function()
            require("telescope").load_extension("live_grep_args")
        end
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },

    { "nvim-treesitter/nvim-treesitter",  build = ":TSUpdate" },
    { "mbbill/undotree" },
    { "tpope/vim-fugitive" },
    { 'williamboman/mason.nvim' },
    { 'jay-babu/mason-null-ls.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },

    { 'VonHeikemen/lsp-zero.nvim',        branch = 'v3.x' },
    {
        'neovim/nvim-lspconfig',
        dependencies =
        "nvimtools/none-ls.nvim",

    },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/nvim-cmp' },
    { 'L3MON4D3/LuaSnip' },
    { 'akinsho/bufferline.nvim',   version = "*", dependencies = 'nvim-tree/nvim-web-devicons' },
    { 'akinsho/git-conflict.nvim', version = "*", config = true },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
    },

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
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup {
                -- Configuration here, or leave empty to use defaults
            }
        end,
    },
    {
        "Exafunction/codeium.vim",
        event = "BufEnter",
        config = function()
            vim.g.codeium_no_map_tab = 1
            -- Change '<C-g>' here to any keycode you like.
            vim.keymap.set("i", "<C-a>", function()
                return vim.fn["codeium#Accept"]()
            end, { expr = true })
            vim.keymap.set("i", "<C-;>", function()
                return vim.fn["codeium#CycleCompletions"](1)
            end, { expr = true })
            vim.keymap.set("i", "<C-,>", function()
                return vim.fn["codeium#CycleCompletions"](-1)
            end, { expr = true })
            vim.keymap.set("i", "<C-x>", function()
                return vim.fn["codeium#Clear"]()
            end, { expr = true })
        end,
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    {
        "numToStr/Comment.nvim",
        keys = {
            { "gcc", mode = "n",          desc = "Comment toggle current line" },
            { "gc",  mode = { "n", "o" }, desc = "Comment toggle linewise" },
            { "gc",  mode = "x",          desc = "Comment toggle linewise (visual)" },
            { "gbc", mode = "n",          desc = "Comment toggle current block" },
            { "gb",  mode = { "n", "o" }, desc = "Comment toggle blockwise" },
            { "gb",  mode = "x",          desc = "Comment toggle blockwise (visual)" },
        },
        config = function(_, opts)
            require("Comment").setup(opts)
        end,
    },
    {
        "dart-lang/dart-vim-plugin",
    },
    { "OmniSharp/omnisharp-vim" },
    { "Hoffs/omnisharp-extended-lsp.nvim" },
    { "thosakwe/vim-flutter" },
    {
        "akinsho/flutter-tools.nvim",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim", -- optional for vim.ui.select
        },
        ft = { "dart" },
        config = true,
    },

    {
        "simrat39/rust-tools.nvim",
        ft = "rust",
        dependencies = "neovim/nvim-lspconfig",
    },
    { 'akinsho/bufferline.nvim',        version = "*", dependencies = 'nvim-tree/nvim-web-devicons' },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        event = "VeryLazy",
    },
    {
        "Cliffback/netcoredbg-macOS-arm64.nvim",
        dependencies = { "mfussenegger/nvim-dap" }
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        event = "VeryLazy",
        dependencies = { "mfussenegger/nvim-dap", "williamboman/mason.nvim" },
        opts = {
            handlers = {
                -- Add any custom handlers
            },
        }
    },
    { "christoomey/vim-tmux-navigator", lazy = false },
    {
        "scalameta/nvim-metals",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "j-hui/fidget.nvim",
                opts = {},
            },
            {
                "mfussenegger/nvim-dap",
                config = function(self, opts)
                    -- Debug settings if you're using nvim-dap
                    local dap = require("dap")

                    dap.configurations.scala = {
                        {
                            type = "scala",
                            request = "launch",
                            name = "RunOrTest",
                            metals = {
                                runType = "runOrTestFile",
                                --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
                            },
                        },
                        {
                            type = "scala",
                            request = "launch",
                            name = "Test Target",
                            metals = {
                                runType = "testTarget",
                            },
                        },
                    }
                end
            },
        },
        ft = { "scala", "sbt", "java" },
        opts = function()
            local metals_config = require("metals").bare_config()
            -- Example of settings
            metals_config.settings = {
                showImplicitArguments = true,
                excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
            }

            -- *READ THIS*
            -- I *highly* recommend setting statusBarProvider to either "off" or "on"
            --
            -- "off" will enable LSP progress notifications by Metals and you'll need
            -- to ensure you have a plugin like fidget.nvim installed to handle them.
            --
            -- "on" will enable the custom Metals status extension and you *have* to have
            -- a have settings to capture this in your statusline or else you'll not see
            -- any messages from metals. There is more info in the help docs about this
            metals_config.init_options.statusBarProvider = "off"

            -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
            metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
            metals_config.on_attach = function(client, bufnr)
                require("metals").setup_dap() -- your on_attach function
                -- Example mappings for usage with nvim-dap. If you don't use that, you can
                -- skip these
                map("n", "<leader>dc", function()
                    require("dap").continue()
                end)

                map("n", "<leader>dr", function()
                    require("dap").repl.toggle()
                end)

                map("n", "<leader>dK", function()
                    require("dap.ui.widgets").hover()
                end)

                map("n", "<leader>dt", function()
                    require("dap").toggle_breakpoint()
                end)

                map("n", "<leader>dso", function()
                    require("dap").step_over()
                end)

                map("n", "<leader>dsi", function()
                    require("dap").step_into()
                end)

                map("n", "<leader>dl", function()
                    require("dap").run_last()
                end)
            end
            return metals_config
        end,
        config = function(self, metals_config)
            local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                pattern = self.ft,
                callback = function()
                    require("metals").initialize_or_attach(metals_config)
                end,
                group = nvim_metals_group,
            })
        end
    }
})
