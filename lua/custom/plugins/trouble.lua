---@module 'lazy'
---@type LazySpec
return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  keys = {
    { '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', desc = 'Diagnostics' },
    { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', desc = 'Buffer diagnostics' },
    { '<leader>xQ', '<cmd>Trouble qflist toggle<CR>', desc = 'Quickfix list' },
    { '<leader>xL', '<cmd>Trouble loclist toggle<CR>', desc = 'Location list' },
    { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<CR>', desc = 'Document symbols' },
    { '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<CR>', desc = 'LSP locations' },
  },
  dependencies = {
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  opts = {},
}
