if vim.fn.executable 'glow' ~= 1 then
  return
end

local function preview_markdown()
  local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local columns = vim.o.columns
  local lines = vim.o.lines - vim.o.cmdheight
  local width = math.max(1, math.floor(columns * 0.9))
  local height = math.max(1, math.floor(lines * 0.85))
  local row = math.max(0, math.floor((lines - height) / 2))
  local col = math.max(0, math.floor((columns - width) / 2))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  local preview_file = vim.fn.tempname() .. '.md'
  vim.fn.writefile(content, preview_file)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Glow Preview ',
    title_pos = 'center',
  })

  local channel
  local cleanup = function()
    if preview_file then
      vim.fn.delete(preview_file)
      preview_file = nil
    end
  end

  local close_preview = function()
    if channel and channel > 0 then
      pcall(vim.fn.jobstop, channel)
      channel = nil
    end

    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end

    cleanup()
  end

  vim.keymap.set('n', 'q', close_preview, { buffer = buf, silent = true, desc = 'Close preview' })
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { buffer = buf, silent = true, desc = 'Exit terminal mode' })
  vim.keymap.set('t', 'q', close_preview, { buffer = buf, silent = true, desc = 'Close preview' })

  channel = vim.fn.termopen({ 'glow', '--pager', '--width', tostring(math.max(20, width - 4)), preview_file }, {
    on_exit = vim.schedule_wrap(cleanup),
  })

  if channel <= 0 then
    vim.notify('Failed to start glow', vim.log.levels.ERROR)
    close_preview()
    return
  end

  vim.cmd.startinsert()
end

vim.keymap.set('n', '<leader>mp', preview_markdown, { buffer = true, desc = '[M]arkdown [P]review' })
