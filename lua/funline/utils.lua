local uv = vim.uv

local M = {}

-- 执行函数
function M.exec_func(fn, timer, default)
  local ok, result = pcall(fn)

  if not ok then
    if timer and not uv.is_closing(timer) then
      uv.close(timer)
    end
    return error("Error occurred: " .. result)
  end

  if result == nil then
    return default
  end

  return result
end

-- 合并配置
M.merge_config = function(opts, defalut)
  local validation = type(opts) == "table"
  assert(validation, "Invalid opts type")

  if opts == nil then
    return defalut
  end
  return vim.tbl_deep_extend("keep", opts, defalut)
end

-- 转义
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

-- 设置高亮色
function M.set_hl(hl, section, reset)
  if reset then
    return string.format("%%#%s#%s%%*", hl, section)
  end
  return string.format("%%#%s#%s", hl, section)
end

return M
