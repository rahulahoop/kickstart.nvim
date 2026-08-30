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
    local ts = require 'nvim-treesitter'
    ts.setup()

    -- Warm the cache: install the baseline set up front (async, non-blocking).
    local missing = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(ts.get_installed(), lang)
    end, langs)
    if #missing > 0 then
      ts.install(missing)
    end

    -- Start Neovim's treesitter highlighting + indentation for a buffer, guarding
    -- against parser/query issues.
    local function ts_start(buf)
      if vim.api.nvim_buf_is_valid(buf) and pcall(vim.treesitter.start, buf) then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    -- Attach to a buffer, auto-installing the parser on first use if needed.
    -- (The `main` branch has no built-in auto_install, so we replicate it here.)
    local function try_attach(buf)
      local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
      if not lang then
        return
      end
      if vim.tbl_contains(ts.get_installed(), lang) then
        ts_start(buf)
      elseif vim.tbl_contains(ts.get_available(), lang) then
        ts.install(lang):await(vim.schedule_wrap(function()
          ts_start(buf)
        end))
      end
    end

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('custom-treesitter', { clear = true }),
      callback = function(args)
        try_attach(args.buf)
      end,
    })

    -- Cover buffers already open before this config ran (e.g. the file nvim launched with).
    vim.schedule(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= '' then
          try_attach(buf)
        end
      end
    end)
  end,
}
