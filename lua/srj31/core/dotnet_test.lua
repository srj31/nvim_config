-- Lightweight `dotnet test` runner for F#/.NET.
-- Run the nearest project, the current file's tests, or the test under the
-- cursor; output streams into a bottom split and failures populate the quickfix.
-- Chosen over SageFs because `dotnet test` resolves native deps (e.g. libhegel)
-- from the build output, which SageFs's FSI-based runner cannot.
--
-- Keymaps (F#/C# buffers): <leader>tr project · <leader>tn nearest ·
--                          <leader>tf file · <leader>tl re-run last

local M = {}

local last = nil

-- Nearest .fsproj/.csproj walking up from a directory.
local function nearest_project(dir)
  return vim.fs.find(function(name)
    return name:match("%.[fc]sproj$")
  end, { upward = true, path = dir, type = "file" })[1]
end

-- Parse `dotnet test` output into quickfix entries (Failed <name> + `in FILE:line N`).
local function to_quickfix(lines)
  local items, current = {}, nil
  for _, line in ipairs(lines) do
    local name = line:match("^%s*Failed%s+(.-)%s+%[") or line:match("^%s*Failed%s+(%S.+)$")
    if name then
      current = name
    end
    local file, lnum = line:match("in%s+(.-):line%s+(%d+)")
    if file and lnum and file:match("%.fs[ix]?$") then
      table.insert(items, {
        filename = file,
        lnum = tonumber(lnum),
        text = current and ("FAIL: " .. current) or vim.trim(line),
      })
      current = nil
    end
  end
  vim.fn.setqflist({}, "r", { title = "dotnet test", items = items })
  return #items
end

-- Run a dotnet command in a bottom split, stream output, quickfix on exit.
local function run(cmd, cwd, label)
  last = { cmd = cmd, cwd = cwd, label = label }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.cmd("botright 15split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  local lines = { "$ " .. table.concat(cmd, " "), "" }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local function append(data)
    for _, l in ipairs(data) do
      table.insert(lines, (l:gsub("\r$", "")))
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      if vim.api.nvim_win_is_valid(win) then
        pcall(vim.api.nvim_win_set_cursor, win, { #lines, 0 })
      end
    end
  end

  vim.notify("dotnet test: " .. (label or "running") .. "…")
  vim.fn.jobstart(cmd, {
    cwd = cwd,
    on_stdout = function(_, d)
      if d then vim.schedule(function() append(d) end) end
    end,
    on_stderr = function(_, d)
      if d then vim.schedule(function() append(d) end) end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        local n = to_quickfix(lines)
        if code == 0 then
          vim.notify("dotnet test: ✓ passed", vim.log.levels.INFO)
        else
          vim.notify("dotnet test: ✗ failed (" .. n .. " location(s) → quickfix)", vim.log.levels.WARN)
          if n > 0 then vim.cmd("copen") end
        end
      end)
    end,
  })
end

-- Nearest test name above the cursor (F#: `let ``name`` (` or `let name (`).
local function nearest_test_name()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  for i = row, 1, -1 do
    local l = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1] or ""
    local bt = l:match("^%s*let%s+``(.-)``%s*%(")
    if bt then return bt end
    local plain = l:match("^%s*let%s+([%w_']+)%s*%(")
    if plain then return plain end
  end
  return nil
end

-- `module X.Y.Z` of the current file, for file-scoped runs.
local function file_module()
  for i = 1, math.min(vim.api.nvim_buf_line_count(0), 40) do
    local l = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1] or ""
    local m = l:match("^%s*module%s+([%w_%.']+)")
    if m then return m end
  end
  return nil
end

function M.run_project()
  local proj = nearest_project(vim.fn.expand("%:p:h"))
  if not proj then
    return vim.notify("No .fsproj/.csproj found", vim.log.levels.WARN)
  end
  run({ "dotnet", "test", proj, "--nologo" }, vim.fn.fnamemodify(proj, ":h"), vim.fn.fnamemodify(proj, ":t"))
end

function M.run_nearest()
  local proj = nearest_project(vim.fn.expand("%:p:h"))
  if not proj then
    return vim.notify("No project found", vim.log.levels.WARN)
  end
  local name = nearest_test_name()
  if not name then
    return vim.notify("No test found above the cursor", vim.log.levels.WARN)
  end
  run(
    { "dotnet", "test", proj, "--nologo", "--filter", "FullyQualifiedName~" .. name },
    vim.fn.fnamemodify(proj, ":h"),
    name
  )
end

function M.run_file()
  local proj = nearest_project(vim.fn.expand("%:p:h"))
  if not proj then
    return vim.notify("No project found", vim.log.levels.WARN)
  end
  local mod = file_module()
  local args = { "dotnet", "test", proj, "--nologo" }
  if mod then
    vim.list_extend(args, { "--filter", "FullyQualifiedName~" .. mod })
  end
  run(args, vim.fn.fnamemodify(proj, ":h"), mod or vim.fn.expand("%:t"))
end

function M.run_last()
  if not last then
    return vim.notify("No previous dotnet test run", vim.log.levels.WARN)
  end
  run(last.cmd, last.cwd, last.label)
end

-- Buffer-local keymaps for .NET buffers.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("srj31_dotnet_test", { clear = true }),
  pattern = { "fsharp", "cs" },
  callback = function(ev)
    local function map(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = ev.buf, silent = true, desc = desc })
    end
    map("<leader>tr", M.run_project, "Test: run project")
    map("<leader>tn", M.run_nearest, "Test: run nearest")
    map("<leader>tf", M.run_file, "Test: run file")
    map("<leader>tl", M.run_last, "Test: re-run last")
  end,
})

return M
