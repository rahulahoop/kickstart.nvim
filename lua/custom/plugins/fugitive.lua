-- Git commands (:Git, :Gdiffsplit) + GitHub integration (:GBrowse, via rhubarb).
-- <leader>gb: browse current line on GitHub; in visual mode the `:` auto-inserts the
-- '<,'> range so it opens the selected lines.
vim.keymap.set({ 'n', 'v' }, '<leader>gb', ':GBrowse<CR>', { desc = '[G]it [B]rowse on GitHub' })

-- Neovim 0.12's netrw#BrowseX signature breaks fugitive's default GBrowse opener
-- (E118: Too many arguments). Fugitive uses a :Browse command if one exists — provide
-- one that opens the URL via the OS handler (macOS `open`).
vim.api.nvim_create_user_command('Browse', function(opts)
  vim.ui.open(opts.args)
end, { nargs = 1 })

return { 'tpope/vim-fugitive', 'tpope/vim-rhubarb' }
