-- Highlight, edit, and navigate code.
-- nvim-treesitter `main` branch: it only installs/updates parsers + queries (into
-- `stdpath('data')/site`, prepended to runtimepath). Highlighting/indentation are
-- driven by Neovim itself via vim.treesitter.start() + indentexpr, wired below.
local langs = {
  'bash',
  'c',
  'diff',
  'go',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
  'yaml',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  build = ':TSUpdate',
  lazy = false,
  config = function()
    require('nvim-treesitter').setup()

    -- Install any missing parsers (no-op if already present). Runs async.
    local installed = require('nvim-treesitter').get_installed()
    local missing = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, langs)
    if #missing > 0 then
      require('nvim-treesitter').install(missing)
    end

    -- Enable Neovim-provided treesitter highlighting + indentation per buffer.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('custom-treesitter', { clear = true }),
      callback = function(args)
        -- Guard: don't error on filetypes whose parser isn't installed yet.
        if not pcall(vim.treesitter.start, args.buf) then
          return
        end
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
