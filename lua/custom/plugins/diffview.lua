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
    local actions = require 'diffview.actions'

    local fold_desc = {
      za = 'Toggle fold',
      zA = 'Toggle fold recursively',
      ze = 'Scroll cursor to right edge',
      zE = 'Eliminate all folds',
      zo = 'Open fold',
      zc = 'Close fold',
      zO = 'Open fold recursively',
      zC = 'Close fold recursively',
      zr = 'Reduce folding',
      zm = 'Increase folding',
      zR = 'Open all folds',
      zM = 'Close all folds',
      zv = 'Open folds under cursor',
      zx = 'Update folds',
      zX = 'Update folds and close',
      zn = 'Disable folding',
      zN = 'Enable folding',
      zi = 'Toggle folding',
    }

    opts.keymaps = opts.keymaps or {}
    opts.keymaps.view = opts.keymaps.view or {}

    for _, mapping in ipairs(actions.compat.fold_cmds) do
      table.insert(opts.keymaps.view, {
        mapping[1],
        mapping[2],
        mapping[3],
        { desc = fold_desc[mapping[2]] or 'Diff fold command' },
      })
    end

    require('diffview').setup(opts)
    require('custom.git.pr_preview').setup()
  end,
}
