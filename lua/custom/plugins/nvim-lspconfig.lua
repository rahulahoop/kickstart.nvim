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

    -- gopls: enable extra analyses/completion/hints. Formatting is left as gofmt
    -- (no gofumpt) so save-formatting behavior is unchanged. Inlay hints only render
    -- when toggled on via <leader>th.
    vim.lsp.config('gopls', {
      settings = {
        gopls = {
          staticcheck = true,
          usePlaceholders = true,
          completeUnimported = true,
          -- Skip irrelevant huge trees to cut indexing time in big repos.
          directoryFilters = { '-**/node_modules' },
          analyses = {
            unusedparams = true,
            unusedwrite = true,
            nilness = true,
            useany = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
        },
      },
    })

    -- Organize imports (add missing / remove unused) via the LSP source action.
    -- Synchronous so the edit lands before a write. Works for any client that
    -- supports it (gopls, ts_ls, …); a no-op otherwise.
    local function organize_imports(buf)
      buf = buf or vim.api.nvim_get_current_buf()
      local client = vim.lsp.get_clients({ bufnr = buf })[1]
      if not client then
        return
      end
      local enc = client.offset_encoding or 'utf-16'
      local params = vim.lsp.util.make_range_params(0, enc)
      params.context = { only = { 'source.organizeImports' } }
      local res = vim.lsp.buf_request_sync(buf, 'textDocument/codeAction', params, 1000)
      for _, r in pairs(res or {}) do
        for _, action in pairs(r.result or {}) do
          if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, enc)
          end
        end
      end
    end

    -- On save for Go, before conform's gofmt runs.
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = vim.api.nvim_create_augroup('gopls-organize-imports', { clear = true }),
      pattern = '*.go',
      callback = function(args)
        organize_imports(args.buf)
      end,
    })

    -- Manual trigger.
    vim.keymap.set('n', '<leader>ci', function()
      organize_imports()
    end, { desc = '[C]ode: organize [I]mports' })

    -- vtsls must attach to .vue files so vue_ls (Volar) can find it for TS handling.
    -- See lsp/vtsls.lua docs for full explanation of Vue hybrid mode setup.
    vim.lsp.config('vtsls', {
      filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
      settings = {
        vtsls = {
          tsserver = {
            globalPlugins = {
              {
                name = '@vue/typescript-plugin',
                location = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node_modules/@vue/language-server',
                languages = { 'vue' },
                configNamespace = 'typescript',
              },
            },
          },
        },
      },
    })
  end,
}
