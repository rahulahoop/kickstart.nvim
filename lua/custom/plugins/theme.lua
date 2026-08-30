return {
  -- tether: theme
  -- see ~line 317 for setting colorscheme
  'AlexvZyl/nordic.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('nordic').load()
  end,
}
