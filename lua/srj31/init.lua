-- Core (eager, before plugins)
require("srj31.core.options")
require("srj31.core.keymaps")
require("srj31.core.autocmds")
require("srj31.core.dotnet_test")
require("srj31.core.dotnet_newfile")

-- Bootstrap lazy.nvim (prepends lazypath to rtp)
require("srj31.lazy")

require("lazy").setup({
  spec = {
    { import = "srj31.plugins" },
    { import = "srj31.plugins.lang" },
  },
  install = { colorscheme = { "catppuccin-mocha", "habamax" } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})
