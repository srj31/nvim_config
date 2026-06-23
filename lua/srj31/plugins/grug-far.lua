return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {},
    keys = {
      { "<leader>fr", function() require("grug-far").open() end, desc = "Search & Replace (project)" },
    },
  },
}
