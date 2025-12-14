return {
  -- Set lualine as statusline
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = false,
        theme = 'seoul256',
        component_separators = '|',
        section_separators = '',
      },
    }
  end,
}
