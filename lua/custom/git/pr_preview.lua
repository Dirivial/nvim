local M = {}

local latest_summary

local function git(args)
  local command = { 'git' }
  vim.list_extend(command, args)

  local output = vim.fn.systemlist(command)
  if vim.v.shell_error ~= 0 then
    local message = table.concat(output, '\n')
    if message == '' then
      message = 'git ' .. table.concat(args, ' ') .. ' failed'
    end

    return nil, message
  end

  return output
end

local function current_branch()
  local branch = git { 'branch', '--show-current' }
  if branch and branch[1] and branch[1] ~= '' then
    return branch[1]
  end

  local sha = git { 'rev-parse', '--short', 'HEAD' }
  return sha and sha[1] or 'HEAD'
end

local function branches()
  local output, err = git {
    'for-each-ref',
    '--format=%(refname:short)%09%(symref:short)',
    'refs/heads',
    'refs/remotes',
  }

  if not output then
    vim.notify(err, vim.log.levels.ERROR)
    return {}
  end

  local current = current_branch()
  local seen = {}
  local result = {}

  for _, line in ipairs(output) do
    local branch, symref = line:match '^([^\t]+)\t?(.*)$'
    if branch and branch ~= '' and not branch:match '/HEAD$' and branch ~= current and not seen[branch] then
      if symref == '' then
        seen[branch] = true
        table.insert(result, branch)
      end
    end
  end

  table.sort(result, function(a, b)
    local rank = {
      main = 1,
      ['origin/main'] = 2,
      master = 3,
      ['origin/master'] = 4,
      develop = 5,
      ['origin/develop'] = 6,
    }

    return (rank[a] or 100) == (rank[b] or 100) and a < b or (rank[a] or 100) < (rank[b] or 100)
  end)

  return result
end

local function parse_shortstat(lines)
  local text = table.concat(lines or {}, ' ')

  return {
    files = tonumber(text:match '(%d+)%s+files? changed') or 0,
    insertions = tonumber(text:match '(%d+)%s+insertions?%(%+%)') or 0,
    deletions = tonumber(text:match '(%d+)%s+deletions?%(%-%)') or 0,
  }
end

local function parse_numstat(lines)
  local files = {}

  for _, line in ipairs(lines or {}) do
    local added, deleted, path = line:match '^([%d%-]+)%s+([%d%-]+)%s+(.+)$'
    if path then
      table.insert(files, {
        path = path,
        added = added,
        deleted = deleted,
      })
    end
  end

  return files
end

local function format_count(value)
  if value == '-' then
    return 'bin'
  end

  return value
end

local function build_summary(target)
  local head = current_branch()
  local range = target .. '...HEAD'

  local shortstat, shortstat_err = git { 'diff', '--shortstat', range }
  if not shortstat then
    return nil, shortstat_err
  end

  local numstat, numstat_err = git { 'diff', '--numstat', range }
  if not numstat then
    return nil, numstat_err
  end

  return {
    head = head,
    target = target,
    range = range,
    totals = parse_shortstat(shortstat),
    files = parse_numstat(numstat),
  }
end

local function summary_lines(summary)
  local totals = summary.totals
  local lines = {
    'PR Preview: ' .. summary.head .. ' -> ' .. summary.target,
    '',
    string.format('%d files changed', totals.files),
    string.format('%d insertions', totals.insertions),
    string.format('%d deletions', totals.deletions),
    '',
  }

  if #summary.files == 0 then
    table.insert(lines, 'No file changes in ' .. summary.range)
    return lines
  end

  table.insert(lines, 'Files')
  table.insert(lines, '')

  for _, file in ipairs(summary.files) do
    table.insert(lines, string.format('%5s %5s  %s', '+' .. format_count(file.added), '-' .. format_count(file.deleted), file.path))
  end

  return lines
end

function M.show_summary()
  if not latest_summary then
    vim.notify('No PR preview summary yet. Run :PrPreview first.', vim.log.levels.WARN)
    return
  end

  local lines = summary_lines(latest_summary)
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end

  width = math.min(math.max(width + 4, 48), math.max(vim.o.columns - 4, 1))
  local height = math.min(#lines, math.max(vim.o.lines - vim.o.cmdheight - 4, 1))
  local row = math.max(0, math.floor((vim.o.lines - vim.o.cmdheight - height) / 2))
  local col = math.max(0, math.floor((vim.o.columns - width) / 2))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'git'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' PR Preview Summary ',
    title_pos = 'center',
  })

  vim.keymap.set('n', 'q', function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, silent = true, desc = 'Close summary' })
end

function M.open(target)
  local summary, err = build_summary(target)
  if not summary then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  latest_summary = summary
  M.show_summary()
  vim.cmd('DiffviewOpen ' .. vim.fn.fnameescape(summary.range))
end

function M.select_target()
  local choices = branches()
  if #choices == 0 then
    vim.notify('No target branches found.', vim.log.levels.WARN)
    return
  end

  vim.ui.select(choices, { prompt = 'Compare current branch against:' }, function(choice)
    if choice then
      M.open(choice)
    end
  end)
end

function M.setup()
  vim.api.nvim_create_user_command('PrPreview', function(opts)
    if opts.args ~= '' then
      M.open(opts.args)
    else
      M.select_target()
    end
  end, {
    nargs = '?',
    complete = function()
      return branches()
    end,
  })

  vim.api.nvim_create_user_command('PrPreviewSummary', M.show_summary, {})
end

return M
