return {
  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = { user_default_options = { names = false, css = true, tailwind = true } },
  },
}
