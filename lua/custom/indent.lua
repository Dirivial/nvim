local M = {}

---Set buffer-local indentation options for a filetype.
---@param opts { tabstop?: integer, shiftwidth?: integer, softtabstop?: integer, expandtab?: boolean }
function M.set(opts)
  vim.bo.tabstop = opts.tabstop or opts.shiftwidth or vim.bo.tabstop
  vim.bo.shiftwidth = opts.shiftwidth or opts.tabstop or vim.bo.shiftwidth
  vim.bo.softtabstop = opts.softtabstop or opts.shiftwidth or opts.tabstop or vim.bo.softtabstop

  if opts.expandtab ~= nil then
    vim.bo.expandtab = opts.expandtab
  end
end

return M
