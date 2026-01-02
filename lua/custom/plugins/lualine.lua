return {
  -- Set lualine as statusline
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup {
      sections = {
        lualine_z = {
          {
            'datetime',
            -- options: 'default', 'us', 'uk', 'iso', or your own format string
            -- using 'os.date' format specifiers
            style = '%H:%M:%S', -- Displays 24-hour time (e.g. 14:30)
          },
        },
      },
      options = {
        icons_enabled = false,
        theme = 'seoul256',
        component_separators = '|',
        section_separators = '',
      },
    }
  end,
}
