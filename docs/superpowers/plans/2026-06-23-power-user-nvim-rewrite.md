# Power-User Neovim Rewrite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the existing ThePrimeagen-style Neovim config into a clean modular lazy.nvim setup with power-user polish, modern plugins, and a live theme switcher — preserving the user's keymaps.

**Architecture:** Eager core modules (`lua/srj31/core/{options,keymaps,autocmds}.lua`) load first; then lazy.nvim imports plugin spec modules from `lua/srj31/plugins/` (and `lua/srj31/plugins/lang/`). Each plugin module returns a lazy spec table and owns its own config + keymaps. LSP uses the Neovim 0.12 `vim.lsp.config()`/`vim.lsp.enable()` API with a shared `LspAttach` autocmd for keymaps.

**Tech Stack:** Neovim 0.12, lazy.nvim, blink.cmp, LuaSnip, mason + mason-lspconfig + mason-tool-installer, nvim-lspconfig, conform.nvim, nvim-lint, rustaceanvim, roslyn.nvim, haskell-tools.nvim, neo-tree, telescope, treesitter, nvim-dap, lualine, gitsigns, themery.nvim.

## Global Constraints

- **Neovim version floor: 0.12.0** (required by roslyn.nvim; enables `vim.lsp.config`/`vim.lsp.enable`). Upgrade in Task 1.
- **Plugin namespace:** all Lua under `lua/srj31/`. Root `init.lua` stays `require("srj31")`.
- **Mapleader:** `" "` (space), set in `core/options.lua` before any keymap or plugin loads.
- **Every task ends loadable.** Standard load check (run after every file change, referenced as **[LOAD CHECK]** below):
  ```bash
  cd /Users/srj31/.config/nvim
  nvim --headless "+Lazy! sync" +qa 2>&1 | tail -n 30          # installs/updates; spec errors surface here
  nvim --headless "+lua print('STARTUP_OK')" +qa 2>&1 | tail -n 30  # must print STARTUP_OK, no Error/stack traces
  ```
  Expected: ends with `STARTUP_OK`, no lines containing `Error`, `E5108`, or `stack traceback`.
- **Keymaps to preserve exactly** (see spec): `jk`→Esc; visual `J`/`K`; `<leader>p/y/Y/d/{/s`; telescope `<leader>ff/fb/fw/vws/vds`, `<C-f>`; harpoon `<C-e>/<leader>a/<C-S-P>/<C-S-N>`; LSP `gd/gr/gi/K/<leader>ds/ca/rn/cl/aa/ae/aw`, insert `<C-h>`; neo-tree `<C-n>/<leader>e`; toggleterm `<C-\>`; DAP `<leader>dt/dr/di/dv/do/db`, `<leader>gb`, `<leader>?`; undotree `<leader>u`; fugitive `<leader>gs`; codeium insert `<C-a>/<C-;>/<C-,>/<C-x>`.
- **Fixes:** drop manual `<C-hjkl>` window-nav (tmux-navigator owns them); `]d`/`[d` conventional; broken `<Leaders>drt`→`<leader>dR`; `<leader>fm` formats via conform.

---

### Task 1: Upgrade Neovim + scaffold core + cutover loader + colorscheme

Atomic cutover: upgrade nvim, build the new core + loader, remove the old `after/plugin/` config and monolithic spec, and land the first plugin module (themes). After this task the config loads with core + colorscheme only.

**Files:**
- Upgrade: Neovim 0.11.3 → 0.12.x (Homebrew)
- Create: `lua/srj31/core/options.lua`, `lua/srj31/core/keymaps.lua`, `lua/srj31/core/autocmds.lua`
- Modify: `lua/srj31/init.lua` (rewrite to new loader)
- Create: `lua/srj31/plugins/colorscheme.lua`
- Delete: `lua/srj31/set.lua`, `lua/srj31/remap.lua`, all of `after/plugin/*.lua`

**Interfaces:**
- Produces: eager core modules; `require("lazy").setup` importing `srj31.plugins`; default colorscheme `catppuccin-mocha`; keymap `<leader>tt` → `:Themery`.

- [ ] **Step 1: Upgrade Neovim via Homebrew**

```bash
brew upgrade neovim
nvim --version | head -1   # expect: NVIM v0.12.x
```
Expected: version line shows `v0.12.0` or higher.

- [ ] **Step 2: Create `lua/srj31/core/options.lua`**

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
```

- [ ] **Step 3: Create `lua/srj31/core/keymaps.lua`** (old `remap.lua` minus the window-nav maps that tmux-navigator owns)

```lua
-- NOTE: <C-h/j/k/l> are intentionally NOT mapped here; vim-tmux-navigator
-- provides them (navigates vim splits AND tmux panes).

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })
vim.keymap.set("n", "<leader>p", [["+P]], { desc = "Paste from system clipboard" })

vim.keymap.set("n", "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("v", "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

vim.keymap.set("n", "<leader>d", [["_d]], { desc = "Delete to black hole" })
vim.keymap.set("v", "<leader>d", [["_d]], { desc = "Delete to black hole" })

vim.keymap.set("n", "<leader>{", "^dt{d%", { desc = "Delete to/incl brace block" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Substitute word under cursor" })
```

- [ ] **Step 4: Create `lua/srj31/core/autocmds.lua`**

```lua
-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("srj31_highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- OCaml-related filetypes (from old after/plugin/ocaml.lua)
vim.filetype.add({
  extension = {
    mli = "ocaml.interface",
    mly = "ocaml.menhir",
    mll = "ocaml.lexer",
  },
})
```

- [ ] **Step 5: Rewrite `lua/srj31/init.lua`** (new loader)

```lua
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
```
(Leave `lua/srj31/lazy.lua` unchanged — it still bootstraps `lazypath`.)

- [ ] **Step 6: Create `lua/srj31/plugins/colorscheme.lua`**

```lua
return {
  { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000,
    opts = { flavour = "mocha" } },
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
  { "rose-pine/neovim", name = "rose-pine", lazy = false, priority = 1000 },
  { "ellisonleao/gruvbox.nvim", lazy = false, priority = 1000 },
  { "EdenEast/nightfox.nvim", lazy = false, priority = 1000 },
  {
    "zaldih/themery.nvim",
    lazy = false,
    priority = 999,
    config = function()
      -- Apply a default first; themery overrides it with the persisted pick (if any).
      pcall(vim.cmd.colorscheme, "catppuccin-mocha")

      -- Keep custom line-number highlights across theme switches.
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("srj31_linenr_hl", { clear = true }),
        callback = function()
          vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#919191", bold = true })
          vim.api.nvim_set_hl(0, "LineNr", { fg = "#51B3EC", bold = true })
          vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#919191", bold = true })
        end,
      })

      require("themery").setup({
        themes = {
          { name = "Catppuccin Mocha", colorscheme = "catppuccin-mocha" },
          { name = "Catppuccin Macchiato", colorscheme = "catppuccin-macchiato" },
          { name = "Tokyonight", colorscheme = "tokyonight" },
          { name = "Tokyonight Night", colorscheme = "tokyonight-night" },
          { name = "Kanagawa", colorscheme = "kanagawa" },
          { name = "Rose Pine", colorscheme = "rose-pine" },
          { name = "Gruvbox", colorscheme = "gruvbox" },
          { name = "Nightfox", colorscheme = "nightfox" },
        },
        livePreview = true,
      })

      vim.keymap.set("n", "<leader>tt", "<cmd>Themery<cr>", { desc = "Theme picker" })
    end,
  },
}
```

- [ ] **Step 7: Delete the old config files**

```bash
cd /Users/srj31/.config/nvim
git rm lua/srj31/set.lua lua/srj31/remap.lua
git rm after/plugin/*.lua
```

- [ ] **Step 8: [LOAD CHECK]** — run the standard load check. Also confirm a theme is active:

```bash
nvim --headless "+lua print(vim.g.colors_name or 'NONE')" +qa 2>&1 | tail -n 5
```
Expected: prints a colorscheme name (e.g. `catppuccin` / `catppuccin-mocha`), not `NONE`; load check clean.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "refactor: cutover to modular lazy config + themes (nvim 0.12)"
```

---

### Task 2: Completion (blink.cmp + LuaSnip)

blink.cmp must exist before LSP (Task 3) so LSP can pull its capabilities.

**Files:**
- Create: `lua/srj31/plugins/completion.lua`

**Interfaces:**
- Produces: `blink.cmp` plugin; `require("blink.cmp").get_lsp_capabilities()` consumed by Task 3.

- [ ] **Step 1: Create `lua/srj31/plugins/completion.lua`**

```lua
return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    opts = {
      snippets = { preset = "luasnip" },
      keymap = {
        preset = "none",
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-y>"] = { "select_and_accept" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      completion = { documentation = { auto_show = true, auto_show_delay_ms = 200 } },
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
}
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check (blink builds its fuzzy lib on first sync; allow it to finish). Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/completion.lua
git commit -m "feat: blink.cmp completion + LuaSnip"
```

---

### Task 3: LSP (mason + mason-lspconfig + tool-installer + LspAttach)

**Files:**
- Create: `lua/srj31/plugins/lsp.lua`

**Interfaces:**
- Consumes: `require("blink.cmp").get_lsp_capabilities()` (Task 2).
- Produces: shared `LspAttach` keymaps (`gd/gr/gi/K/<leader>ds/ca/rn/cl/aa/ae/aw`, insert `<C-h>`, `]d`/`[d`); mason-installed servers + tools (roslyn, formatters, linters, debuggers). NOTE: `<leader>fm` is intentionally NOT defined here — Task 5 (conform) owns it.

- [ ] **Step 1: Create `lua/srj31/plugins/lsp.lua`**

```lua
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
    },
    config = function()
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded", source = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.INFO] = "I",
            [vim.diagnostic.severity.HINT] = "H",
          },
        },
      })

      -- Shared keymaps for every LSP server (incl. rustaceanvim, roslyn, haskell-tools)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("srj31_lsp_attach", { clear = true }),
        callback = function(event)
          local function opts(desc)
            return { buffer = event.buf, desc = desc, silent = true, noremap = true }
          end
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Goto Definition"))
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Goto References"))
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Goto Implementation"))
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover"))
          vim.keymap.set("n", "<leader>ds", vim.diagnostic.open_float, opts("Line Diagnostics"))
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code Action"))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename"))
          vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts("Run CodeLens"))
          vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts("Signature Help"))
          vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,
            opts("Next Diagnostic"))
          vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end,
            opts("Prev Diagnostic"))
          vim.keymap.set("n", "<leader>aa", vim.diagnostic.setqflist, opts("All Diagnostics -> qflist"))
          vim.keymap.set("n", "<leader>ae",
            function() vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR }) end,
            opts("All Errors -> qflist"))
          vim.keymap.set("n", "<leader>aw",
            function() vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.WARN }) end,
            opts("All Warnings -> qflist"))
        end,
      })

      -- Global capabilities (blink) for all servers
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

      -- Per-server overrides
      vim.lsp.config("lua_ls", {
        settings = { Lua = { completion = { callSnippet = "Replace" } } },
      })
      vim.lsp.config("clangd", {
        on_attach = function(client)
          client.server_capabilities.signatureHelpProvider = false
        end,
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "ocamllsp", "ts_ls", "pyright", "ruff",
          "sqls", "marksman", "bashls", "clangd",
        },
        automatic_enable = true,
      })

      require("mason-tool-installer").setup({
        ensure_installed = {
          "roslyn",                        -- C# server (used by roslyn.nvim)
          "haskell-language-server",       -- hls (used by haskell-tools.nvim)
          "prettier", "shfmt", "ocamlformat", "fourmolu", "stylua", -- formatters
          "shellcheck",                    -- linter
          "netcoredbg", "codelldb", "debugpy", -- debuggers
        },
      })
    end,
  },
}
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check (mason will download servers/tools; this can take a few minutes on first run). Expected clean.

- [ ] **Step 3: Verify mason installed roslyn**

```bash
ls "$(nvim --headless '+lua io.write(vim.fn.stdpath("data"))' +qa 2>/dev/null)/mason/packages" | grep -i roslyn
```
Expected: lists `roslyn` (may need a moment after sync; rerun if empty).

- [ ] **Step 4: Commit**

```bash
git add lua/srj31/plugins/lsp.lua
git commit -m "feat: native LSP (mason + lsp.config) with shared LspAttach keymaps"
```

---

### Task 4: Telescope

**Files:**
- Create: `lua/srj31/plugins/telescope.lua`

**Interfaces:**
- Produces: `require("telescope.builtin")`, `require("telescope.config")`, pickers/finders — consumed by harpoon (Task 9); keymaps `<leader>ff/fb/fw/vws/vds`, `<C-f>`.

- [ ] **Step 1: Create `lua/srj31/plugins/telescope.lua`**

```lua
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
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check. Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/telescope.lua
git commit -m "feat: telescope with live-grep-args + fzf-native"
```

---

### Task 5: Formatting + linting (conform + nvim-lint)

**Files:**
- Create: `lua/srj31/plugins/formatting.lua`

**Interfaces:**
- Consumes: mason-installed formatters/linters (Task 3).
- Produces: keymap `<leader>fm` (conform format, with LSP fallback); format-on-save; shellcheck linting.

- [ ] **Step 1: Create `lua/srj31/plugins/formatting.lua`**

```lua
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>fm",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        ocaml = { "ocamlformat" },
        haskell = { "fourmolu" },
        sh = { "shfmt" },
        python = { "ruff_format" },
        lua = { "stylua" },
      },
      format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
    },
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = { sh = { "shellcheck" } }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("srj31_lint", { clear = true }),
        callback = function() lint.try_lint() end,
      })
    end,
  },
}
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check. Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/formatting.lua
git commit -m "feat: conform.nvim formatting + nvim-lint (replaces null-ls)"
```

---

### Task 6: Git (gitsigns + fugitive + git-conflict)

**Files:**
- Create: `lua/srj31/plugins/git.lua`

**Interfaces:**
- Produces: keymaps `<leader>gs` (fugitive), `<leader>h{s,r,p,b,d}` + `]c`/`[c` (gitsigns).

- [ ] **Step 1: Create `lua/srj31/plugins/git.lua`**

```lua
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
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check. Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/git.lua
git commit -m "feat: gitsigns + fugitive + git-conflict"
```

---

### Task 7: UI (lualine, bufferline, indent guides, which-key, trouble, fidget, dressing, dashboard)

**Files:**
- Create: `lua/srj31/plugins/ui.lua`

**Interfaces:**
- Produces: statusline, bufferline, indent guides, which-key groups, trouble keymaps `<leader>x{x,X,q}`, LSP progress, better selects, dashboard.

- [ ] **Step 1: Create `lua/srj31/plugins/ui.lua`**

```lua
return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        section_separators = "",
        component_separators = "|",
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = { options = { diagnostics = "nvim_lsp" } },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find/format" },
        { "<leader>v", group = "lsp symbols" },
        { "<leader>a", group = "harpoon/diagnostics" },
        { "<leader>d", group = "debug" },
        { "<leader>h", group = "git hunks" },
        { "<leader>x", group = "trouble" },
        { "<leader>t", group = "theme/toggle" },
        { "<leader>g", group = "git" },
        { "<leader>c", group = "code" },
      },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix (Trouble)" },
    },
  },
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
  { "stevearc/dressing.nvim", event = "VeryLazy", opts = {} },
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("alpha").setup(require("alpha.themes.startify").config)
    end,
  },
}
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check. Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/ui.lua
git commit -m "feat: UI suite (lualine, bufferline, which-key, trouble, dashboard)"
```

---

### Task 8: Navigation (harpoon, neo-tree, undotree, flash, tmux-navigator)

**Files:**
- Create: `lua/srj31/plugins/navigation.lua`

**Interfaces:**
- Consumes: telescope pickers/config (Task 4).
- Produces: keymaps `<C-e>/<leader>a/<C-S-P>/<C-S-N>` (harpoon), `<C-n>/<leader>e` (neo-tree), `<leader>u` (undotree), `s`/`S` (flash), `<C-h/j/k/l>` (tmux-navigator).

- [ ] **Step 1: Create `lua/srj31/plugins/navigation.lua`**

```lua
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
        require("telescope.pickers").new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({ results = file_paths }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        }):find()
      end

      vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end, { desc = "Harpoon menu" })
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add" })
      vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = "Harpoon prev" })
      vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, { desc = "Harpoon next" })
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
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },
  { "christoomey/vim-tmux-navigator", lazy = false },
}
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check. Expected clean.

- [ ] **Step 3: Verify neo-tree toggles headlessly**

```bash
nvim --headless "+Neotree toggle" "+lua print('NEOTREE_OK')" +qa 2>&1 | tail -n 5
```
Expected: prints `NEOTREE_OK`, no errors.

- [ ] **Step 4: Commit**

```bash
git add lua/srj31/plugins/navigation.lua
git commit -m "feat: harpoon, neo-tree, undotree, flash, tmux-navigator"
```

---

### Task 9: Coding helpers (autopairs, Comment, surround, todo-comments, codeium)

**Files:**
- Create: `lua/srj31/plugins/coding.lua`

**Interfaces:**
- Produces: autopairs; `gcc`/`gc`/`gbc`/`gb` comments; surround; todo-comments; codeium insert keymaps `<C-a>/<C-;>/<C-,>/<C-x>`.

- [ ] **Step 1: Create `lua/srj31/plugins/coding.lua`**

```lua
return {
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Comment line" },
      { "gbc", mode = "n", desc = "Comment block" },
      { "gc", mode = { "n", "o", "x" }, desc = "Comment (linewise)" },
      { "gb", mode = { "n", "o", "x" }, desc = "Comment (blockwise)" },
    },
    opts = {},
  },
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function()
      vim.g.codeium_no_map_tab = 1
      vim.keymap.set("i", "<C-a>", function() return vim.fn["codeium#Accept"]() end, { expr = true })
      vim.keymap.set("i", "<C-;>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true })
      vim.keymap.set("i", "<C-,>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true })
      vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true })
    end,
  },
}
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check. Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/coding.lua
git commit -m "feat: autopairs, Comment, surround, todo-comments, codeium"
```

---

### Task 10: Treesitter

**Files:**
- Create: `lua/srj31/plugins/treesitter.lua`

**Interfaces:**
- Produces: syntax highlighting + indent for all target languages.

- [ ] **Step 1: Create `lua/srj31/plugins/treesitter.lua`**

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "c", "cpp", "lua", "vim", "vimdoc", "query", "bash",
        "javascript", "typescript", "tsx", "rust", "ocaml", "ocaml_interface",
        "haskell", "python", "sql", "markdown", "markdown_inline",
        "c_sharp", "json", "yaml", "toml",
      },
      sync_install = false,
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
    },
  },
}
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check (parsers compile on first sync; allow time). Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/treesitter.lua
git commit -m "feat: treesitter with full language parser set"
```

---

### Task 11: Terminal (toggleterm)

**Files:**
- Create: `lua/srj31/plugins/terminal.lua`

**Interfaces:**
- Produces: `<C-\>` floating terminal.

- [ ] **Step 1: Create `lua/srj31/plugins/terminal.lua`**

```lua
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
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check. Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/terminal.lua
git commit -m "feat: toggleterm floating terminal"
```

---

### Task 12: Debugging (nvim-dap + dap-ui + netcoredbg)

**Files:**
- Create: `lua/srj31/plugins/debugging.lua`

**Interfaces:**
- Consumes: mason-installed `netcoredbg`, `codelldb`, `debugpy` (Task 3).
- Produces: DAP keymaps `<leader>dt/dr/di/dv/do/db/dR`, `<leader>gb`, `<leader>?`; auto-open/close dap-ui.

- [ ] **Step 1: Create `lua/srj31/plugins/debugging.lua`**

```lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
      "Cliffback/netcoredbg-macOS-arm64.nvim",
    },
    keys = {
      { "<leader>dt", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dr", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dv", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>db", function() require("dap").step_back() end, desc = "Step Back" },
      { "<leader>dR", function() require("dap").restart() end, desc = "Restart" },
      { "<leader>gb", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>?", function() require("dapui").eval(nil, { enter = true }) end, desc = "Eval Under Cursor" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      require("nvim-dap-virtual-text").setup()
      require("netcoredbg-macOS-arm64").setup(dap)

      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end,
  },
}
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check. Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/debugging.lua
git commit -m "feat: nvim-dap + dap-ui + virtual text + netcoredbg"
```

---

### Task 13: Language — Rust (rustaceanvim) + enable lang import

**Files:**
- Modify: `lua/srj31/init.lua` (add lang import)
- Create: `lua/srj31/plugins/lang/rust.lua`

**Interfaces:**
- Consumes: shared `LspAttach` keymaps (Task 3); mason `codelldb` (Task 3).
- Produces: rust LSP via rustaceanvim; buffer-local `<C-space>` (hover actions), `<leader>a` (code action) in rust buffers.

- [ ] **Step 1: Add the lang import to `lua/srj31/init.lua`** — change the `spec` block to:

```lua
  spec = {
    { import = "srj31.plugins" },
    { import = "srj31.plugins.lang" },
  },
```

- [ ] **Step 2: Create `lua/srj31/plugins/lang/rust.lua`**

```lua
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            vim.keymap.set("n", "<C-space>", function() vim.cmd.RustLsp({ "hover", "actions" }) end,
              { buffer = bufnr, desc = "Rust hover actions" })
            vim.keymap.set("n", "<leader>a", function() vim.cmd.RustLsp("codeAction") end,
              { buffer = bufnr, desc = "Rust code action" })
          end,
          default_settings = { ["rust-analyzer"] = {} },
        },
      }
    end,
  },
}
```

- [ ] **Step 3: [LOAD CHECK]** — standard load check. Expected clean (and lang import resolves).

- [ ] **Step 4: Commit**

```bash
git add lua/srj31/init.lua lua/srj31/plugins/lang/rust.lua
git commit -m "feat(lang): rust via rustaceanvim + enable lang import"
```

---

### Task 14: Language — C#/.NET (roslyn.nvim)

**Files:**
- Create: `lua/srj31/plugins/lang/dotnet.lua`

**Interfaces:**
- Consumes: mason-installed `roslyn` (Task 3); shared `LspAttach` keymaps (Task 3); netcoredbg (Task 12).
- Produces: C# LSP via roslyn.nvim (native `gd/gr/gi`).

- [ ] **Step 1: Create `lua/srj31/plugins/lang/dotnet.lua`**

```lua
return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    opts = {
      -- Uses the mason-installed roslyn server automatically on nvim 0.12.
    },
  },
}
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check. Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/lang/dotnet.lua
git commit -m "feat(lang): C# via roslyn.nvim (replaces omnisharp)"
```

---

### Task 15: Language — Haskell (haskell-tools.nvim)

**Files:**
- Create: `lua/srj31/plugins/lang/haskell.lua`

**Interfaces:**
- Consumes: mason `haskell-language-server` (Task 3); shared `LspAttach` keymaps (Task 3).
- Produces: Haskell LSP via haskell-tools (fourmolu formatting).

- [ ] **Step 1: Create `lua/srj31/plugins/lang/haskell.lua`**

```lua
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
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check. Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/lang/haskell.lua
git commit -m "feat(lang): haskell via haskell-tools.nvim"
```

---

### Task 16: Language — Markdown (render-markdown.nvim)

**Files:**
- Create: `lua/srj31/plugins/lang/markdown.lua`

**Interfaces:**
- Consumes: treesitter (Task 10); marksman LSP (Task 3).
- Produces: in-editor markdown rendering.

- [ ] **Step 1: Create `lua/srj31/plugins/lang/markdown.lua`**

```lua
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
}
```

- [ ] **Step 2: [LOAD CHECK]** — standard load check. Expected clean.

- [ ] **Step 3: Commit**

```bash
git add lua/srj31/plugins/lang/markdown.lua
git commit -m "feat(lang): markdown rendering via render-markdown.nvim"
```

---

### Task 17: Final verification, lazy-lock, and push

**Files:**
- Modify: `lazy-lock.json` (regenerated by lazy)

- [ ] **Step 1: Clean sync (removes any leftover old plugins, locks versions)**

```bash
cd /Users/srj31/.config/nvim
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -n 40
nvim --headless "+Lazy! clean" +qa 2>&1 | tail -n 20
```
Expected: no errors; clean reports removal of any orphaned plugins.

- [ ] **Step 2: Full health + startup check**

```bash
nvim --headless "+lua print('STARTUP_OK')" +qa 2>&1 | tail -n 20
nvim --headless "+checkhealth lazy" "+w! /tmp/health.txt" +qa 2>&1 | tail -n 5
grep -iE "error|fail" /tmp/health.txt || echo "no health errors"
```
Expected: `STARTUP_OK`; no critical `ERROR` in lazy health.

- [ ] **Step 3: Interactive smoke test (manual — user runs `nvim`)**

Confirm each: theme picker (`<leader>tt`), file tree (`<C-n>`), find files (`<leader>ff`), open a `.rs`/`.cs`/`.py` file → LSP attaches (`:LspInfo`/`:checkhealth`), completion popup (insert mode), `<leader>fm` formats, `<leader>gs` opens fugitive, statusline + bufferline visible.

- [ ] **Step 4: Commit the regenerated lock file**

```bash
git add lazy-lock.json
git commit -m "chore: lock plugin versions (lazy-lock.json)"
```

- [ ] **Step 5: Push the branch**

```bash
git push -u origin feat/power-user-rewrite
```
Expected: branch pushed to `origin` (github.com/srj31/nvim_config); print the PR-create URL.

---

## Rollback (if needed)

- `git checkout main` (old config preserved on `main`, also tagged `pre-rewrite-backup`), or
- restore the folder copy: `rm -rf ~/.config/nvim && mv ~/.config/nvim.backup-2026-06-23 ~/.config/nvim`
- If staying on rewrite but nvim 0.12 caused an unrelated issue: `brew` keeps the prior bottle; `brew switch neovim 0.11.3` (or reinstall) reverts the editor.
