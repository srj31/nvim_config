return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { [[<C-\>]] },
    cmd = "ToggleTerm",
    opts = {
      open_mapping = [[<c-\>]],
      direction = "float",
      float_opts = { border = "curved" },
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
    },
  },
}
