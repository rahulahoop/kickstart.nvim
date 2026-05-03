return {
  'scalameta/nvim-metals',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  ft = { 'scala', 'sbt' },
  opts = function()
    local metals_config = require('metals').bare_config()

    -- Example of settings
    metals_config.settings = {
      showImplicitArguments = true,
      excludedPackages = { 'akka.actor.typed.javadsl', 'com.github.swagger.akka.javadsl' },
    }

    -- *READ THIS*
    -- I *highly* recommend setting statusBarProvider to either "off" or "on"
    --
    -- "off" will enable LSP progress notifications by Metals and you'll need
    -- to ensure you have a plugin like fidget.nvim installed to handle them.
    --
    -- "on" will enable the custom Metals status extension and you *have* to have
    -- a have settings to capture this in your statusline or else you'll not see
    -- any messages from metals. There is more info in the help docs about this
    metals_config.init_options.statusBarProvider = 'off'

    -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
    metals_config.capabilities = require('blink.cmp').get_lsp_capabilities()

    metals_config.on_attach = function(_, bufnr)
      local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
      end
      -- LSP mappings
      map('gd', ":lua require('telescope.builtin').lsp_definitions()<CR>zz", '[G]oto [D]efinition')
      map('gr', ":lua require('telescope.builtin').lsp_references()<CR>zz", '[G]oto [R]eferences')
      map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
      map('<leader>oi', ':MetalsOrganizeImports<CR>', '[O]rganize [I]mports')

      map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
      map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
      map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
      -- See `:help K` for why this keymap
      map('K', vim.lsp.buf.hover, 'Hover Documentation')
      map('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
      map('<leader>sh', vim.lsp.buf.signature_help, '[S]ignature [H]elp')
    end

    return metals_config
  end,
  config = function(self, metals_config)
    local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      pattern = self.ft,
      callback = function()
        require('metals').initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  end,
}
