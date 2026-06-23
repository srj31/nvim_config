return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup({})

			local conf = require("telescope.config").values
			local function toggle_telescope(harpoon_files)
				local file_paths = {}
				for _, item in ipairs(harpoon_files.items) do
					table.insert(file_paths, item.value)
				end
				require("telescope.pickers")
					.new({}, {
						prompt_title = "Harpoon",
						finder = require("telescope.finders").new_table({ results = file_paths }),
						previewer = conf.file_previewer({}),
						sorter = conf.generic_sorter({}),
					})
					:find()
			end

			vim.keymap.set("n", "<C-e>", function()
				toggle_telescope(harpoon:list())
			end, { desc = "Harpoon menu" })
			vim.keymap.set("n", "<leader>ha", function()
				harpoon:list():add()
			end, { desc = "Harpoon add" })
			vim.keymap.set("n", "[h", function()
				harpoon:list():prev()
			end, { desc = "Harpoon prev" })
			vim.keymap.set("n", "]h", function()
				harpoon:list():next()
			end, { desc = "Harpoon next" })

			-- Jump straight to harpoon slots 1-4.
			for i = 1, 4 do
				vim.keymap.set("n", "<leader>" .. i, function()
					harpoon:list():select(i)
				end, { desc = "Harpoon slot " .. i })
			end
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{ "<C-n>", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
			{ "<leader>e", "<cmd>Neotree focus reveal<cr>", desc = "Focus file tree" },
		},
		opts = {
			filesystem = {
				follow_current_file = { enabled = true },
				hijack_netrw_behavior = "open_default",
			},
		},
	},
	{
		"mbbill/undotree",
		keys = { { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undotree" } },
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
		},
	},
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
		-- Free up <C-\> for toggleterm; keep h/j/k/l pane navigation.
		init = function()
			vim.g.tmux_navigator_no_mappings = 1
		end,
		config = function()
			local map = vim.keymap.set
			map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Tmux nav left" })
			map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Tmux nav down" })
			map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Tmux nav up" })
			map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Tmux nav right" })
		end,
	},
}
