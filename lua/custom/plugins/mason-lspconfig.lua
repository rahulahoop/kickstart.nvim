return {
  -- Auto-calls vim.lsp.enable() for all mason-installed servers.
  -- nvim-lspconfig provides the lsp/*.lua server definitions it reads.
  'mason-org/mason-lspconfig.nvim',
  opts = {},
  dependencies = {
    'mason-org/mason.nvim',
    'neovim/nvim-lspconfig',
  },
}
