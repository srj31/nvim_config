return {
  {
    "mrcjkb/haskell-tools.nvim",
    version = "^4",
    lazy = false,
    ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
    config = function()
      vim.g.haskell_tools = {
        hls = {
          settings = {
            haskell = {
              formattingProvider = "fourmolu",
              plugin = {
                retrie = { globalOn = false },
                ormolu = { globalOn = false },
                fourmolu = { globalOn = true },
              },
            },
          },
        },
      }
    end,
  },
}
