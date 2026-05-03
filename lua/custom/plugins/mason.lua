return {
  {
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    -- Ensures tools are always installed. Manage others ad-hoc via :Mason (g? for help).
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = {
      ensure_installed = {
        'lua-language-server',
        'jdtls',
        'stylua',
      },
    },
  },
}
