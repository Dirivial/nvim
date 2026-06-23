---@module 'lazy'
---@type LazySpec
return {
  'sindrets/diffview.nvim',
  cmd = {
    'DiffviewClose',
    'DiffviewFileHistory',
    'DiffviewFocusFiles',
    'DiffviewLog',
    'DiffviewOpen',
    'DiffviewRefresh',
    'DiffviewToggleFiles',
    'PrPreview',
    'PrPreviewSummary',
  },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = 'Open git diff view' },
    { '<leader>gD', '<cmd>DiffviewFileHistory<CR>', desc = 'Open git file history' },
    { '<leader>gp', function() require('custom.git.pr_preview').select_target() end, desc = 'Open PR preview' },
    { '<leader>gP', function() require('custom.git.pr_preview').show_summary() end, desc = 'Show PR preview summary' },
    { '<leader>gq', '<cmd>DiffviewClose<CR>', desc = 'Close git diff view' },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  opts = {},
  config = function(_, opts)
    require('diffview').setup(opts)
    require('custom.git.pr_preview').setup()
  end,
}
