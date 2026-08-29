-- Fast worktree jumping + changed-files review, for the Claude Code agent workflow.
-- Agents work in git worktrees under <repo>/.claude/worktrees/<name>; these keymaps let
-- you jump into one from inside nvim and review what changed vs the parent branch.
--
-- This module defines keymaps at import time and requires telescope lazily inside the
-- callbacks (telescope loads on VimEnter), so it doesn't force any plugin to load early.
-- Returns {} — no plugin spec of its own (same pattern as empty.lua).

-- Parse `git worktree list --porcelain` into { path, branch } entries.
local function list_worktrees()
  local out = vim.fn.systemlist { 'git', 'worktree', 'list', '--porcelain' }
  if vim.v.shell_error ~= 0 then
    return {}
  end
  local trees = {}
  local cur
  for _, line in ipairs(out) do
    local path = line:match '^worktree (.+)$'
    if path then
      cur = { path = path }
      table.insert(trees, cur)
    elseif cur then
      local branch = line:match '^branch refs/heads/(.+)$'
      if branch then
        cur.branch = branch
      elseif line == 'detached' then
        cur.branch = 'detached'
      end
    end
  end
  return trees
end

-- Branch of the primary (first) worktree — where Claude Code is launched, so agent
-- worktrees almost always fork from it. Falls back to origin/HEAD, then main/master.
local function base_branch()
  local primary = list_worktrees()[1]
  if primary and primary.branch and primary.branch ~= 'detached' then
    return primary.branch
  end
  local head = vim.fn.systemlist { 'git', 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD' }
  if vim.v.shell_error == 0 and head[1] then
    return (head[1]:gsub('^origin/', ''))
  end
  for _, b in ipairs { 'main', 'master' } do
    vim.fn.system { 'git', 'rev-parse', '--verify', b }
    if vim.v.shell_error == 0 then
      return b
    end
  end
  return nil
end

-- Merge-base of the current HEAD and the base branch: the point this worktree forked
-- off. Diffing against it captures both committed and uncommitted agent work.
local function fork_point(base)
  if not base then
    return nil
  end
  local mb = vim.fn.systemlist { 'git', 'merge-base', base, 'HEAD' }
  if vim.v.shell_error ~= 0 or not mb[1] or mb[1] == '' then
    return nil
  end
  return mb[1]
end

-- <leader>gw — pick a worktree, open it in a new tab (tab-local cwd) and find_files there.
local function pick_worktree()
  local trees = list_worktrees()
  if vim.tbl_isempty(trees) then
    vim.notify('No git worktrees found', vim.log.levels.WARN)
    return
  end
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  pickers
    .new({}, {
      prompt_title = 'Git Worktrees',
      finder = finders.new_table {
        results = trees,
        entry_maker = function(t)
          return {
            value = t,
            display = string.format('%-50s [%s]', vim.fn.fnamemodify(t.path, ':~'), t.branch or '?'),
            ordinal = t.path .. ' ' .. (t.branch or ''),
          }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(bufnr)
          if not entry then
            return
          end
          vim.cmd 'tabnew'
          vim.cmd('tcd ' .. vim.fn.fnameescape(entry.value.path))
          require('telescope.builtin').find_files()
        end)
        return true
      end,
    })
    :find()
end

-- <leader>gc — telescope picker of files changed vs the parent branch (in the tab's cwd).
local function pick_changed_files()
  local base = base_branch()
  local fp = fork_point(base)
  if not fp then
    vim.notify('Could not determine base branch to diff against', vim.log.levels.WARN)
    return
  end
  local files = vim.fn.systemlist { 'git', 'diff', '--name-only', fp }
  if vim.v.shell_error ~= 0 or vim.tbl_isempty(files) then
    vim.notify('No changes vs ' .. base, vim.log.levels.INFO)
    return
  end
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values

  pickers
    .new({}, {
      prompt_title = 'Changed vs ' .. base,
      finder = finders.new_table {
        results = files,
        entry_maker = function(f)
          return { value = f, display = f, ordinal = f, path = f }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = conf.file_previewer {},
    })
    :find()
end

-- <leader>gd — open a full diff-review panel of everything changed vs the parent branch.
local function diff_vs_base()
  local base = base_branch()
  local fp = fork_point(base)
  if not fp then
    vim.notify('Could not determine base branch to diff against', vim.log.levels.WARN)
    return
  end
  vim.cmd('DiffviewOpen ' .. fp)
  vim.notify('Diff vs ' .. base, vim.log.levels.INFO)
end

vim.keymap.set('n', '<leader>gw', pick_worktree, { desc = '[G]it [W]orktree switch' })
vim.keymap.set('n', '<leader>gc', pick_changed_files, { desc = '[G]it [C]hanged files vs base' })
vim.keymap.set('n', '<leader>gd', diff_vs_base, { desc = '[G]it [D]iff vs base branch' })

return {}
