return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    cmd = "Telescope",
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find Files" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Find Buffers" },
      { "<C-f>", function() require("telescope.builtin").git_files() end, desc = "Find Git Files" },
      { "<leader>fw", function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "Live Grep" },
      { "<leader>vws", function() require("telescope.builtin").lsp_workspace_symbols() end, desc = "Workspace Symbols" },
      { "<leader>vds", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Document Symbols" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})
      pcall(telescope.load_extension, "live_grep_args")
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
