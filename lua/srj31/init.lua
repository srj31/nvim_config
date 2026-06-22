-- Core (eager, before plugins)
require("srj31.core.options")
require("srj31.core.keymaps")
require("srj31.core.autocmds")

-- Bootstrap lazy.nvim (prepends lazypath to rtp)
require("srj31.lazy")

require("lazy").setup({
  spec = {
    { import = "srj31.plugins" },
  },
  install = { colorscheme = { "catppuccin-mocha", "habamax" } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})
