return {
  {
    "Julian/lean.nvim",
    -- Upstream's recommended trigger, rather than `ft = "lean"`: it puts the
    -- plugin's ftplugin/ and indent/ files on the rtp *before* nvim fires
    -- FileType for the buffer that triggered the load.
    event = { "BufReadPre *.lean", "BufNewFile *.lean" },
    dependencies = {
      -- Optional upstream, but lean.init() only registers the
      -- `lean_abbreviations` and `loogle` pickers when telescope is already
      -- loaded (it retries once per new Lean buffer). Telescope is cmd-lazy
      -- here, so depend on it explicitly instead of hoping for the retry.
      "nvim-telescope/telescope.nvim",
    },
    init = function()
      -- Has to be set before the plugin loads: ftplugin/lean/lean.lua reads it
      -- at FileType time. (`require("lean").setup()` is deprecated upstream in
      -- favour of this variable, and nothing else is needed to activate it.)
      vim.g.lean_config = {
        -- Buffer-local <LocalLeader> maps: infoview toggle/pins, restart file,
        -- abbreviation reverse-lookup, accept suggestion, ...
        --
        -- maplocalleader is <Space> here -- the same as mapleader -- so inside
        -- .lean buffers these shadow three global maps outright: <leader>p
        -- (paste from clipboard -> pause infoview pins), <leader>s (substitute
        -- word -> accept suggestion) and <leader>dt (dap toggle breakpoint ->
        -- toggle auto-diff; dap is meaningless in Lean anyway). The which-key
        -- group prefixes it also occupies (<leader>c/v/x/d) keep working for
        -- their longer sequences (<leader>ca, <leader>xx, ...) since none of
        -- lean's maps set `nowait`. Everything outside .lean buffers is
        -- untouched.
        mappings = true,
      }
    end,
    config = function()
      -- lean.nvim maps `K` -> LeanHover from its ftplugin (FileType), but our
      -- shared LspAttach handler in plugins/lsp.lua re-maps `K` to the plain
      -- vim.lsp.buf.hover afterwards and wins. Put the interactive hover back
      -- once the server attaches; vim.schedule defers past every other
      -- LspAttach callback regardless of the order they were registered in.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("srj31_lean_hover", { clear = true }),
        callback = function(event)
          if vim.bo[event.buf].filetype ~= "lean" then
            return
          end
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(event.buf) then
              return
            end
            vim.keymap.set("n", "K", vim.cmd.LeanHover, {
              buffer = event.buf,
              desc = "Lean interactive hover",
              silent = true,
            })
          end)
        end,
      })
    end,
  },
}
