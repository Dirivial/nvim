---@module 'lazy'
---@type LazySpec
return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  keys = {
    { '<leader>gg', '<cmd>LazyGit<CR>', desc = 'Open LazyGit' },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
}
