return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  event = { 'BufReadPost', 'BufNewFile' },
  keys = {
    { '<leader>tt', '<cmd>TSContext toggle<CR>', desc = 'Toggle treesitter context' },
  },
}
