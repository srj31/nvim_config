# Neovim Configuration

A personal Neovim setup managed with [`lazy.nvim`](https://github.com/folke/lazy.nvim).
Leader key is `<Space>`. Plugin specs live in `lua/srj31/plugins/`, one file per
concern; core options/keymaps live in `lua/srj31/core/`.

## Layout

```
init.lua                      -- entry point
lua/srj31/
├── core/                     -- options, keymaps, base settings
└── plugins/                  -- one file per plugin group
    └── lang/                 -- language-specific setups (rust, haskell, dotnet, markdown)
```

---

## Plugins

### Editing & Coding
| Plugin | What it does |
|--------|--------------|
| `windwp/nvim-autopairs` | Auto-inserts the closing bracket/quote as you type. |
| `numToStr/Comment.nvim` | Toggle comments with `gcc` (line) / `gc` (motion or visual). |
| `kylechui/nvim-surround` | Add/change/delete surrounding pairs — quotes, brackets, tags. |
| `folke/todo-comments.nvim` | Highlights and lets you search `TODO`/`FIXME`/`HACK`/`NOTE` comments. |
| `Exafunction/codeium.vim` | Free AI inline code completion (Copilot alternative). |
| `tpope/vim-sleuth` | Auto-detects indentation (tabs vs spaces, width) per file. |
| `windwp/nvim-ts-autotag` | Auto-closes and renames HTML/JSX tags via Treesitter. |

### Navigation & Search
| Plugin | What it does |
|--------|--------------|
| `ThePrimeagen/harpoon` | Pin a handful of files and jump between them instantly. |
| `nvim-neo-tree/neo-tree.nvim` | File-explorer sidebar (follows the current file). |
| `folke/flash.nvim` | Jump anywhere on screen by typing a few characters (`s` / `S`). |
| `christoomey/vim-tmux-navigator` | Seamless `<C-h/j/k/l>` movement across Neovim splits and tmux panes. |
| `mbbill/undotree` | Visualize and navigate the full undo history. |
| `nvim-telescope/telescope.nvim` | Fuzzy finder for files, grep, buffers, symbols. |
| `…/telescope-live-grep-args` | Live grep that accepts ripgrep flags/args. |
| `…/telescope-fzf-native` | Native FZF sorter for faster Telescope matching. |
| `MagicDuck/grug-far.nvim` | Project-wide find & replace UI. |

### LSP, Completion & Tooling
| Plugin | What it does |
|--------|--------------|
| `neovim/nvim-lspconfig` | Base configurations for language servers. |
| `mason-org/mason.nvim` | Installs LSP servers, formatters, and linters. |
| `mason-org/mason-lspconfig.nvim` | Bridges Mason with lspconfig. |
| `WhoIsSethDaniel/mason-tool-installer.nvim` | Auto-installs the configured tools on startup. |
| `saghen/blink.cmp` | Fast completion engine. |
| `folke/lazydev.nvim` | Lua LSP tuned for editing your Neovim config. |
| `L3MON4D3/LuaSnip` | Snippet engine. |
| `rafamadriz/friendly-snippets` | Community snippet collection. |

### Formatting & Linting
| Plugin | What it does |
|--------|--------------|
| `stevearc/conform.nvim` | Runs formatters (prettier, stylua, shfmt, ruff, …) on demand via `<leader>fm`. |
| `mfussenegger/nvim-lint` | Async linting (e.g. shellcheck) on read/write/insert-leave. |

### Treesitter
| Plugin | What it does |
|--------|--------------|
| `nvim-treesitter/nvim-treesitter` | Syntax-aware highlighting, indentation, parsing. |
| `nvim-treesitter/nvim-treesitter-textobjects` | Treesitter-based text objects (functions, classes, params). |

### Git
| Plugin | What it does |
|--------|--------------|
| `lewis6991/gitsigns.nvim` | Gutter signs, hunk stage/preview/reset, inline blame. |
| `tpope/vim-fugitive` | Full Git wrapper (`:Git …`). |
| `akinsho/git-conflict.nvim` | Highlights and helps resolve merge conflicts. |
| `kdheepak/lazygit.nvim` | Opens the LazyGit TUI inside Neovim. |

### UI
| Plugin | What it does |
|--------|--------------|
| `nvim-lualine/lualine.nvim` | Statusline. |
| `akinsho/bufferline.nvim` | Buffer/tab line along the top. |
| `lukas-reineke/indent-blankline.nvim` | Indentation guide lines. |
| `folke/which-key.nvim` | Popup that shows available keybindings as you type. |
| `folke/trouble.nvim` | Pretty list for diagnostics, quickfix, references. |
| `j-hui/fidget.nvim` | LSP progress notifications. |
| `stevearc/dressing.nvim` | Nicer `vim.ui.select` / `vim.ui.input` menus. |
| `goolord/alpha-nvim` | Start / dashboard screen. |
| `nvim-tree/nvim-web-devicons` | Filetype icons used across the UI. |
| `catgoose/nvim-colorizer.lua` | Highlights color codes (`#rrggbb`) inline. |
| `RRethy/vim-illuminate` | Highlights other occurrences of the word under the cursor. |

### Debugging (DAP)
| Plugin | What it does |
|--------|--------------|
| `mfussenegger/nvim-dap` | Debug Adapter Protocol client. |
| `rcarriga/nvim-dap-ui` | Debugger UI (scopes, stacks, breakpoints, REPL). |
| `nvim-neotest/nvim-nio` | Async I/O library (dap-ui dependency). |
| `theHamsta/nvim-dap-virtual-text` | Shows variable values inline as virtual text. |
| `Cliffback/netcoredbg-macOS-arm64.nvim` | .NET debug adapter for Apple-silicon macOS. |

### Sessions
| Plugin | What it does |
|--------|--------------|
| `folke/persistence.nvim` | Save and restore editing sessions per directory. |

### Language-specific (`lang/`)
| Plugin | What it does |
|--------|--------------|
| `mrcjkb/rustaceanvim` | Rust LSP/tools wrapper around rust-analyzer. |
| `mrcjkb/haskell-tools.nvim` | Haskell LSP and tooling integration. |
| `seblyng/roslyn.nvim` | C#/.NET LSP via Roslyn. |
| `MeanderingProgrammer/render-markdown.nvim` | Renders Markdown (headings, code, tables) in-buffer. |

### Colorschemes
All are theme-only and selectable through the picker (`<leader>tt`, powered by
`zaldih/themery.nvim`):

`catppuccin/nvim` · `folke/tokyonight.nvim` · `rebelot/kanagawa.nvim` ·
`rose-pine/neovim` · `ellisonleao/gruvbox.nvim` · `EdenEast/nightfox.nvim` ·
`sainnhe/everforest` · `gbprod/nord.nvim` · `olimorris/onedarkpro.nvim` ·
`sainnhe/sonokai` · `savq/melange-nvim` · `nyoom-engineering/oxocarbon.nvim`

---

## Key Shortcuts

Leader = `<Space>`.

### Files & Navigation
| Key | Action |
|-----|--------|
| `<C-n>` | Toggle file tree |
| `<leader>e` | Focus tree & reveal current file |
| `<leader>ff` | Find files |
| `<C-f>` | Find git files |
| `<leader>fb` | Find buffers |
| `<leader>fw` | Live grep |
| `<leader>fr` | Project search & replace (grug-far) |
| `s` / `S` | Flash jump / Flash Treesitter |
| `<C-h/j/k/l>` | Move between splits / tmux panes |

### Harpoon
| Key | Action |
|-----|--------|
| `<leader>ha` | Add current file |
| `<C-e>` | Harpoon menu (Telescope) |
| `[h` / `]h` | Previous / next pinned file |
| `<leader>1`–`4` | Jump to slot 1–4 |

### Edit / LSP
| Key | Action |
|-----|--------|
| `<leader>fm` | Format buffer (conform) |
| `<leader>vds` | Document symbols |
| `<leader>vws` | Workspace symbols |
| `<leader>u` | Toggle Undotree |

### Diagnostics (Trouble)
| Key | Action |
|-----|--------|
| `<leader>xx` | Diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xq` | Quickfix |

### Git
| Key | Action |
|-----|--------|
| `<leader>gs` | Git status (fugitive) |
| `<leader>gg` | LazyGit |

### Debugging (DAP)
| Key | Action |
|-----|--------|
| `<leader>dt` | Toggle breakpoint |
| `<leader>dr` | Continue |
| `<leader>dv` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>db` | Step back |
| `<leader>dR` | Restart |
| `<leader>gb` | Run to cursor |
| `<leader>?` | Eval under cursor |

### Sessions / Misc
| Key | Action |
|-----|--------|
| `<leader>qs` | Restore session |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Stop session save |
| `<leader>tt` | Theme picker |
| `<C-\>` | Toggle floating terminal |
