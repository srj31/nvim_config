return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(l, r, desc)
          vim.keymap.set("n", l, r, { buffer = bufnr, desc = desc })
        end
        map("]c", function() gs.nav_hunk("next") end, "Next Hunk")
        map("[c", function() gs.nav_hunk("prev") end, "Prev Hunk")
        map("<leader>hs", gs.stage_hunk, "Stage Hunk")
        map("<leader>hr", gs.reset_hunk, "Reset Hunk")
        map("<leader>hp", gs.preview_hunk, "Preview Hunk")
        map("<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("<leader>hd", gs.diffthis, "Diff This")
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = { { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" } },
  },
  { "akinsho/git-conflict.nvim", version = "*", event = "BufReadPre", config = true },
}
