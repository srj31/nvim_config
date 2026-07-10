-- Keep new .NET source files wired into their project from Neovim.
--   F# (.fs): F# compiles top-down, so a file must appear in the .fsproj's
--     <Compile> list, in order. Two ways in:
--       * AUTOMATIC: saving a new .fs under a project appends it to the end of
--         the <Compile> list (opt out with `vim.g.dotnet_autoadd = false`).
--       * :DotnetNewFile <name> / :DotnetNewFileAbove <name> — create + insert
--         relative to the current file (positional).
--   C# (.cs): SDK-style .csproj auto-globs **/*.cs, so :DotnetNewFile just
--     creates the file with a skeleton -- no project edit needed.
-- FSAC reloads the .fsproj via its file watcher; use <leader>lr if it doesn't.

local function nearest(dir, pat)
  return vim.fs.find(function(n)
    return n:match(pat)
  end, { upward = true, path = dir, type = "file" })[1]
end

-- path of `abs` relative to directory `base` (nil if outside), forward slashes.
local function relpath(abs, base)
  if abs:sub(1, #base + 1) == base .. "/" then
    return abs:sub(#base + 2)
  end
  return nil
end

-- For a real .fs file: return fsproj, projdir, lines, rel (or nil if N/A).
local function project_context(abs)
  if not abs:match("%.fs$") or abs:match("/obj/") or abs:match("/bin/") then
    return
  end
  local fsproj = nearest(vim.fn.fnamemodify(abs, ":h"), "%.fsproj$")
  if not fsproj then
    return
  end
  local projdir = vim.fn.fnamemodify(fsproj, ":h")
  local rel = relpath(abs, projdir)
  if not rel then
    return
  end
  return fsproj, projdir, vim.fn.readfile(fsproj), rel
end

-- Already compiled, explicitly or via a glob include?
local function already_compiled(lines, rel)
  for _, l in ipairs(lines) do
    local inc = l:match('<Compile%s+Include="([^"]+)"')
    if inc then
      if inc:find("%*") then
        return true
      end -- glob include covers it
      if inc:gsub("\\", "/") == rel then
        return true
      end -- explicit entry
    end
  end
  return false
end

local function root_namespace(fsproj)
  local ns
  for _, l in ipairs(vim.fn.readfile(fsproj)) do
    ns = ns or l:match("<RootNamespace>(.-)</RootNamespace>")
  end
  return ns or vim.fn.fnamemodify(fsproj, ":t:r")
end

-- AUTOMATIC: append an existing-on-disk .fs to its fsproj if not already listed.
local function ensure_in_fsproj(abs)
  local fsproj, _, lines, rel = project_context(abs)
  if not fsproj or already_compiled(lines, rel) then
    return
  end
  local last, indent
  for i, l in ipairs(lines) do
    if l:match("<Compile%s+Include=") then
      last, indent = i, l:match("^(%s*)")
    end
  end
  if not last then
    return
  end -- no <Compile> group to extend; leave the project alone
  table.insert(lines, last + 1, (indent) .. string.format('<Compile Include="%s" />', rel))
  vim.fn.writefile(lines, fsproj)
  vim.notify(("Added %s to %s (end of compile order)"):format(rel, vim.fn.fnamemodify(fsproj, ":t")))
end

-- MANUAL: create <name>.fs next to the current file, insert positionally.
local function add_fsharp(name, where)
  local cur = vim.api.nvim_buf_get_name(0)
  local fsproj = nearest(vim.fn.fnamemodify(cur, ":h"), "%.fsproj$")
  if not fsproj then
    return vim.notify("No .fsproj found for this buffer", vim.log.levels.WARN)
  end
  local projdir = vim.fn.fnamemodify(fsproj, ":h")
  if not name:match("%.fs$") then
    name = name .. ".fs"
  end
  local newabs = vim.fn.fnamemodify(vim.fn.fnamemodify(cur, ":h") .. "/" .. name, ":p"):gsub("/$", "")
  local new_rel = relpath(newabs, projdir)
  if not new_rel then
    return vim.notify("New file must live inside the project directory", vim.log.levels.WARN)
  end
  if vim.fn.filereadable(newabs) == 1 then
    return vim.notify("File already exists: " .. newabs, vim.log.levels.WARN)
  end

  local lines = vim.fn.readfile(fsproj)
  local anchor_rel = relpath(cur, projdir)
  local idx, indent, last_idx, last_indent
  for i, l in ipairs(lines) do
    local inc = l:match('<Compile%s+Include="([^"]+)"')
    if inc then
      last_idx, last_indent = i, l:match("^(%s*)")
      if anchor_rel and inc:gsub("\\", "/") == anchor_rel then
        idx, indent = i, l:match("^(%s*)")
      end
    end
  end
  if not idx then
    idx, indent, where = last_idx, last_indent, "below"
  end
  if not idx then
    return vim.notify("No <Compile Include> items found; add the entry manually", vim.log.levels.WARN)
  end

  table.insert(lines, where == "above" and idx or idx + 1, (indent) .. string.format('<Compile Include="%s" />', new_rel))
  vim.fn.mkdir(vim.fn.fnamemodify(newabs, ":h"), "p")
  vim.fn.writefile({ "module " .. root_namespace(fsproj) .. "." .. new_rel:gsub("%.fs$", ""):gsub("/", "."), "" }, newabs)
  vim.fn.writefile(lines, fsproj)
  vim.cmd.edit(vim.fn.fnameescape(newabs))
  vim.notify(("Added %s %s %s"):format(new_rel, where, anchor_rel or "(end)"))
end

local function add_csharp(name)
  local cur = vim.api.nvim_buf_get_name(0)
  if not name:match("%.cs$") then
    name = name .. ".cs"
  end
  local newabs = vim.fn.fnamemodify(vim.fn.fnamemodify(cur, ":h") .. "/" .. name, ":p"):gsub("/$", "")
  if vim.fn.filereadable(newabs) == 1 then
    return vim.notify("File already exists: " .. newabs, vim.log.levels.WARN)
  end
  local csproj = nearest(vim.fn.fnamemodify(cur, ":h"), "%.csproj$")
  local ns = csproj and vim.fn.fnamemodify(csproj, ":t:r") or "App"
  vim.fn.mkdir(vim.fn.fnamemodify(newabs, ":h"), "p")
  vim.fn.writefile({ "namespace " .. ns .. ";", "", "class " .. vim.fn.fnamemodify(newabs, ":t:r"), "{", "}" }, newabs)
  vim.cmd.edit(vim.fn.fnameescape(newabs))
  vim.notify(name .. " created (SDK-style .csproj includes it automatically)")
end

local function dispatch(name, where)
  if name == "" then
    return vim.notify("Usage: :DotnetNewFile <name>", vim.log.levels.WARN)
  end
  local ft = vim.bo.filetype
  if ft == "fsharp" then
    add_fsharp(name, where)
  elseif ft == "cs" then
    add_csharp(name)
  else
    vim.notify("Run this from an F# (.fs) or C# (.cs) buffer", vim.log.levels.WARN)
  end
end

vim.api.nvim_create_user_command("DotnetNewFile", function(o)
  dispatch(o.args, "below")
end, { nargs = 1, complete = "file", desc = ".NET: new file (F#: below current in .fsproj; C#: create)" })

vim.api.nvim_create_user_command("DotnetNewFileAbove", function(o)
  dispatch(o.args, "above")
end, { nargs = 1, complete = "file", desc = "F#: new file above current in .fsproj" })

-- Auto-add any new .fs file to its .fsproj on first save.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("srj31_fsproj_autoadd", { clear = true }),
  pattern = "*.fs",
  callback = function(ev)
    if vim.g.dotnet_autoadd ~= false then
      ensure_in_fsproj(vim.api.nvim_buf_get_name(ev.buf))
    end
  end,
})
