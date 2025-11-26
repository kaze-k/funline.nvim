local M = {}

M.merge_config = function(opts, defalut)
  local validation = type(opts) == "table"
  assert(validation, "Invalid opts type")

  if opts == nil then
    return defalut
  end
  return vim.tbl_deep_extend("keep", opts, defalut)
end

M.escape = function(str, esc)
  local chars = {}

  for i = 1, #str do
    local char = str:sub(i, i)
    if char == esc then
      table.insert(chars, esc)
    end
    table.insert(chars, char)
  end

  local result = table.concat(chars)
  return result
end

function M.set_hl(hl, section, reset)
  if reset then
    return string.format("%%#%s#%s%%*", hl, section)
  end
  return string.format("%%#%s#%s", hl, section)
end

function M.make_set(list)
  local set = {}
  for _, v in ipairs(list) do
    set[v] = true
  end
  return set
end

function M.defer_neovide_redraw(fn)
  if neovide and neovide.disable_redraw then
    neovide.disable_redraw()
  end

  local success, result = pcall(fn)
  pcall(vim.api.nvim__redraw, { cursor = true, flush = true })

  if neovide and neovide.enable_redraw then
    neovide.enable_redraw()
  end

  if not success then
    error(result)
  end
  return result
end

return M
