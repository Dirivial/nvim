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
  },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = 'Open git diff view' },
    { '<leader>gD', '<cmd>DiffviewFileHistory<CR>', desc = 'Open git file history' },
    { '<leader>gq', '<cmd>DiffviewClose<CR>', desc = 'Close git diff view' },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  opts = {},
}
