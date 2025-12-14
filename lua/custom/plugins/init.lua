local plugins = {}

local a = vim.api

local handle = io.popen('ls ' .. vim.fn.stdpath 'config' .. '/lua/custom/plugins')

if handle then
  local result = handle:read '*a'
  handle:close()

  for plugin in string.gmatch(result, '[^%s]+') do
    if string.match(plugin, '.lua$') and not string.match(plugin, 'init.lua') then
      local plugin_name = string.gsub(plugin, '.lua', '')
      local ok, plugin_spec = pcall(require, 'custom.plugins.' .. plugin_name)
      if ok then
        table.insert(plugins, plugin_spec)
      else
        a.nvim_err_writeln(string.format('Error loading plugin: %s\n%s', plugin_name, plugin_spec))
      end
    end
  end
end

return plugins

