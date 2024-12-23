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

return M
