# Power-User Neovim Rewrite — Design

Date: 2026-06-23
Branch: `feat/power-user-rewrite`
Backup: tag `pre-rewrite-backup` on `main` + folder copy `~/.config/nvim.backup-2026-06-23`

## Goal

Restructure the existing ThePrimeagen-style config (`after/plugin/` layout, lsp-zero,
nvim-cmp, null-ls, rust-tools) into a clean **modular lazy.nvim** config with the polish
that power-user setups have — while keeping it *the user's* config and preserving all
existing muscle-memory keymaps. Also add a live theme switcher with several themes.

Neovim version: 0.11.3 (modern `vim.lsp` / `vim.diagnostic` APIs available).

## Approach (decided in brainstorming)

- **Custom modular rewrite** (not a distribution like LazyVim, not incremental).
- **Theme switcher** with 6 themes (themery.nvim), default catppuccin-mocha.
- **Languages kept**: Rust, C#/.NET, OCaml, Haskell, Markdown, SQL, TypeScript/JavaScript,
  Python (plus Lua for editing the config, C/C++ via clangd, Bash — already present).
- **Languages dropped**: Scala/metals, Dart/Flutter, Solidity, Zig, F#.
- **Completion**: blink.cmp + LuaSnip + friendly-snippets; keep Codeium inline AI.

## Target structure

```
init.lua                    -> require("srj31")
lua/srj31/
├── init.lua                bootstrap lazy + import "srj31.plugins"
├── lazy.lua                lazy.nvim bootstrap (existing, keep)
├── core/
│   ├── options.lua         (was set.lua)
│   ├── keymaps.lua         (was remap.lua, deduped)
│   └── autocmds.lua        (new: highlight-on-yank, etc.)
└── plugins/
    ├── colorscheme.lua     6 themes + themery switcher (default catppuccin-mocha)
    ├── telescope.lua
    ├── treesitter.lua
    ├── lsp.lua             mason + mason-lspconfig + lspconfig + LspAttach keymaps
    ├── completion.lua      blink.cmp + LuaSnip + friendly-snippets
    ├── coding.lua          autopairs, Comment, surround, todo-comments, codeium
    ├── formatting.lua      conform.nvim + nvim-lint
    ├── git.lua             gitsigns, fugitive, git-conflict
    ├── ui.lua              lualine, bufferline, indent-blankline, which-key,
    │                       trouble, fidget, dressing, alpha (dashboard), web-devicons
    ├── navigation.lua      harpoon, nvim-tree, flash, tmux-navigator, undotree
    ├── terminal.lua        toggleterm
    ├── debugging.lua       nvim-dap, dap-ui, nvim-nio, mason-nvim-dap, netcoredbg
    └── lang/
        ├── rust.lua        rustaceanvim
        ├── dotnet.lua      omnisharp-extended-lsp + netcoredbg config
        ├── haskell.lua     haskell-tools.nvim (hls, fourmolu)
        └── markdown.lua    render-markdown.nvim (+ marksman via lsp.lua)
```

Server-only languages (OCaml, Python, TS/JS, SQL, C/C++, Bash, Lua) are configured as
entries inside `lsp.lua` — no separate 3-line files.

## Power-user additions

lualine, gitsigns (gutter + hunk stage/reset/blame), nvim-autopairs, indent-blankline,
todo-comments, trouble.nvim, flash.nvim, which-key (configured), fidget (LSP progress),
alpha (dashboard), dressing (UI select/input).

## Modernizations (replace deprecated pieces)

| Old | New | Why |
|-----|-----|-----|
| lsp-zero v3 | native mason + mason-lspconfig + lspconfig | lsp-zero winding down; 0.11 standard |
| nvim-cmp + cmp-* | blink.cmp + LuaSnip + friendly-snippets | user choice; modern/fast |
| null-ls / none-ls | conform.nvim (format) + nvim-lint (lint) | none-ls deprecated |
| rust-tools.nvim | rustaceanvim | rust-tools archived |

Formatters via conform: prettier (web/json/md/yaml), ocamlformat, shfmt (sh),
fourmolu (haskell), ruff (python). Linters via nvim-lint: shellcheck (sh).

## Themes

catppuccin (**default mocha**), tokyonight, kanagawa, rose-pine, gruvbox, nightfox.
Switcher: themery.nvim, bound to `<leader>tt`, selection persists across restarts.
Carry over the custom LineNr highlights from the old `colors.lua`.

## LSP servers (ensure_installed)

lua_ls, rust_analyzer (via rustaceanvim, not the mason-lspconfig handler), omnisharp,
ocamllsp, hls (via haskell-tools), ts_ls, pyright, ruff, sqls, marksman, bashls, clangd.

## Keymap preservation (must keep, exact)

Core: `jk`->Esc; visual `J`/`K` move; `<leader>p`/`y`/`Y`/`d` register ops; `<leader>{`;
`<leader>s` substitute word under cursor.
Telescope: `<leader>ff`, `<leader>fb`, `<C-f>` git files, `<leader>fw` live-grep-args,
`<leader>vws`, `<leader>vds`.
Harpoon: `<C-e>` (telescope UI), `<leader>a` add, `<C-S-P>`/`<C-S-N>` prev/next.
LSP: `gd`, `gr`, `gi`, `K` hover, `<leader>ds`, `<leader>aa`/`ae`/`aw` qflist,
`<leader>cl` codelens, `<leader>ca`, `<leader>rn`, `<C-h>` (insert) signature,
`<leader>fm` format. omnisharp uses omnisharp_extended for `gd`/`gr`/`gi`.
nvim-tree: `<C-n>` toggle, `<leader>e` focus.
toggleterm: `<C-\>`.
DAP: `<leader>dt` breakpoint, `<leader>dr` continue, `<leader>di`/`dv`/`do`/`db`
step into/over/out/back, `<space>gb` run-to-cursor, `<space>?` eval.
undotree: `<leader>u`. fugitive: `<leader>gs`.
rust (buffer-local): `<C-space>` hover actions, `<leader>a` code-action group, diagnostic float.
Codeium (insert): `<C-a>` accept, `<C-;>`/`<C-,>` cycle, `<C-x>` clear.

## Fixes (surfaced and approved)

- `<C-h/j/k/l>`: drop the manual window-nav maps; keep vim-tmux-navigator's (navigates
  vim splits AND tmux panes).
- `]d`/`[d`: were swapped; make conventional (`]d` next, `[d` prev).
- `<Leaders>drt` typo (broken) -> `<leader>dR` dap restart.
- Drop metals worksheet keymap (Scala removed).

## New keymaps added (documented in which-key)

`<leader>tt` theme picker; gitsigns hunk maps under `<leader>h` (stage/reset/blame/preview);
trouble under `<leader>x`; flash via `s`/`S`. All grouped/labeled in which-key.

## Safety / rollback

- `main` is untouched (old config) + tag `pre-rewrite-backup`.
- Folder copy `~/.config/nvim.backup-2026-06-23` (full, includes `.git`).
- Rollback: `git checkout main` OR restore the folder copy.
- New config developed on `feat/power-user-rewrite`, pushed to `origin` at the end.

## Verification

Headless load check (`nvim --headless "+Lazy! sync" +qa` then `nvim --headless +qa`) must
produce no errors; lazy installs all plugins; `:checkhealth` clean enough; manual smoke
test of theme switch, completion, LSP attach, format, and harpoon.
