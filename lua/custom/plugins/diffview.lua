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

    local function preserve_view(action, fold_cmd)
      return function()
        local win = vim.api.nvim_get_current_win()
        local view = vim.fn.winsaveview()
        local screen_row = vim.fn.winline()
        local open_commands = {
          za = true,
          zA = true,
          zo = true,
          zO = true,
          zr = true,
          zR = true,
        }
        local fold_start = vim.fn.foldclosed '.'
        local fold_end = vim.fn.foldclosedend '.'

        if open_commands[fold_cmd] and fold_start > -1 and fold_end < vim.fn.line '$' then
          view.lnum = fold_end + 1
          screen_row = screen_row + 1
        end

        action()

        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_call(win, function()
            vim.fn.winrestview(view)

            if screen_row > 1 then
              vim.cmd.normal { 'zt', bang = true }

              for _ = 2, screen_row do
                vim.cmd.normal { '\x19', bang = true }
              end
            end
          end)
        end
      end
    end

    opts.keymaps = opts.keymaps or {}
    opts.keymaps.view = opts.keymaps.view or {}

    for _, mapping in ipairs(actions.compat.fold_cmds) do
      table.insert(opts.keymaps.view, {
        mapping[1],
        mapping[2],
        preserve_view(mapping[3], mapping[2]),
        { desc = fold_desc[mapping[2]] or 'Diff fold command' },
      })
    end

    require('diffview').setup(opts)
    require('custom.git.pr_preview').setup()
  end,
}
