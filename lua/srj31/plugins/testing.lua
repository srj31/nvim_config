return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- .NET adapter: discovers [<Fact>]/[<Theory>] (xUnit), NUnit, MSTest in C#/F#
      "Issafalcon/neotest-dotnet",
    },
    -- Load on a .NET buffer (so gutter signs appear) or the first test keymap.
    ft = { "cs", "fsharp" },
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Test: run nearest" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: run file" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Test: run last" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test: debug nearest" },
      { "<leader>tx", function() require("neotest").run.stop() end, desc = "Test: stop" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test: summary tree" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Test: output (float)" },
      { "<leader>tp", function() require("neotest").output_panel.toggle() end, desc = "Test: output panel" },
      { "]t", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next failed test" },
      { "[t", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Prev failed test" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-dotnet")({
            -- Debug a test with <leader>td via the netcoredbg adapter you already have.
            dap = { adapter_name = "netcoredbg" },
          }),
        },
      })
    end,
  },
}
