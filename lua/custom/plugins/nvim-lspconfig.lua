return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp',
  },
  config = function()
    -- Runs every time an LSP attaches to a buffer
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Override defaults with telescope versions
        map('gd', function() require('telescope.builtin').lsp_definitions() vim.cmd('normal! zz') end, '[G]oto [D]efinition')
        map('gr', function() require('telescope.builtin').lsp_references() vim.cmd('normal! zz') end, '[G]oto [R]eferences')
        map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
        map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
        map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

        -- WARN: grD = Declaration (e.g. C header), not Definition
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Highlight references of symbol under cursor on CursorHold
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = {
        source = 'if_many',
        spacing = 2,
      },
    }

    -- Broadcast blink.cmp capabilities to all servers
    vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

    -- Per-server config overrides. See :help lspconfig-all for available servers.
    -- Examples: gopls, rust_analyzer, ts_ls, pyright — add via :Mason then override here if needed.
    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          completion = { callSnippet = 'Replace' },
          -- diagnostics = { disable = { 'missing-fields' } },
        },
      },
    })
  end,
}
