return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'rcasia/neotest-java',
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-java' {
          ignore_wrapper = false, -- use ./gradlew
        },
      },
    }

    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { desc = 'Test: ' .. desc })
    end

    map('<leader>tn', function() require('neotest').run.run() end, 'Run [N]earest')
    map('<leader>tf', function() require('neotest').run.run(vim.fn.expand '%') end, 'Run [F]ile')
    map('<leader>ts', function() require('neotest').summary.toggle() end, 'Toggle [S]ummary')
    map('<leader>to', function() require('neotest').output.open { enter = true } end, 'Open [O]utput')
    map('<leader>tl', function() require('neotest').run.run_last() end, 'Run [L]ast')
  end,
}
