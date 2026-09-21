return {
  "coder/claudecode.nvim",
  -- Serves a WebSocket on a random port and writes ~/.claude/ide/<port>.lock.
  -- The `claude` CLI reads that lock file and auto-connects when launched from
  -- this nvim instance, giving it selection context and native diff buffers.
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSelectModel",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeStatus",
    "ClaudeCodeStart",
    "ClaudeCodeStop",
    "ClaudeCodeOpen",
    "ClaudeCodeClose",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeCloseAllDiffs",
  },
  opts = {
    terminal = {
      -- "auto" prefers snacks.nvim; we don't have it, so be explicit.
      provider = "native",
      split_side = "right",
      split_width_percentage = 0.35,
    },
    diff_opts = {
      layout = "vertical",
    },
  },
  -- <leader>a is taken (harpoon/diagnostics, rust codeAction) and <leader>C meant
  -- reaching for shift on every invocation, so: <leader>k (free, home row).
  keys = {
    { "<leader>k", nil, desc = "Claude Code" },
    { "<leader>kc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>kf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>kr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume session" },
    { "<leader>kn", "<cmd>ClaudeCode --continue<cr>", desc = "Continue last session" },
    { "<leader>km", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
    { "<leader>kb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to context" },
    { "<leader>ks", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
    { "<leader>ks", "<cmd>ClaudeCodeTreeAdd<cr>", ft = "neo-tree", desc = "Add file from tree" },
    { "<leader>ka", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>kd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    { "<leader>kx", "<cmd>ClaudeCodeStatus<cr>", desc = "Connection status" },
  },
}
