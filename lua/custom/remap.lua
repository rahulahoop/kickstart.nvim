vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
-- primes remaps
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-o>', '<C-o>zz')
vim.keymap.set('n', '<C-o>', '<C-o>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'run format' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'quickfix diagnostic' })
-- html hotkey
--vim.keymap.set("n", "", "ysst", {desc = "create html block in line"})
vim.keymap.set('n', '<leader>m', 'yssT', { desc = 'create html block ending on new line' })
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- dont leave normal mode for new line
vim.keymap.set('n', '<leader>o', 'o<Esc>0"_D', { desc = 'add new line below in normal mode' })
vim.keymap.set('n', '<leader>O', 'O<Esc>0"_D', { desc = 'add new line above in normal mode' })
-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- float-term
vim.keymap.set('t', '<C-w>h', '<C-\\>:FloatermToggle<CR>', { silent = true })
vim.keymap.set('n', '<leader>bt', ':FloatermNew<CR>', { desc = 'Open terminal' })
-- vim.keymap.set("n", "<leader>bh", ":FloatermToggle<CR>", { desc = "switch to floating terminal" })
vim.keymap.set('n', '<F5>', ':FloatermToggle aTerm<CR>', { desc = 'switch to floating terminal' })
vim.keymap.set('t', '<F5>', '<C-\\><C-n>:FloatermToggle aTerm<CR>', { desc = 'toggle floating terminal' })
vim.keymap.set('t', '<F6>', '<C-\\><C-n>:FloatermNext<CR>', { desc = 'cycle floating terminals' })
vim.keymap.set('t', '<C-t>', '<C-\\><C-n>:FloatermNew<CR>', { desc = 'create new terminal' })
-- exit term
vim.keymap.set('t', '<C-x>', '<C-\\><C-n>:FloatermKill', { desc = 'exit terminal mode' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>ZZ', { desc = 'exit terminal mode' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set('n', '<leader>aa', vim.diagnostic.setqflist, { desc = 'all diagnostics' })
-- all workspace errors
vim.keymap.set('n', '<leader>ae', function()
  vim.diagnostic.setqflist { severity = vim.diagnostic.severity.E }
end, { desc = 'all errors' })

-- all workspace warnings
vim.keymap.set('n', '<leader>aw', function()
  vim.diagnostic.setqflist { severity = vim.diagnostic.severity.W }
end, { desc = 'all warnings' })

-- buffer diagnostics only
vim.keymap.set('n', '<leader>d', vim.diagnostic.setloclist, { desc = 'buffer only diagnostics' })

--telescope
vim.keymap.set('n', '<leader>ß', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sb', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- these are from the on-attatch for LSP..
-- TODO: would like to toggle these only when an LSP is actually active
local nmap = function(keys, func, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end

  vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
end
nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

nmap('gd', ":lua require('telescope.builtin').lsp_definitions()<CR>zz", '[G]oto [D]efinition')
nmap('gr', ":lua require('telescope.builtin').lsp_references()<CR>zz", '[G]oto [R]eferences')
nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

-- See `:help K` for why this keymap
nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

-- Lesser used LSP functionality
nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
nmap('<leader>wl', function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, '[W]orkspace [L]ist Folders')
