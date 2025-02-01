local M = {}

-- line config
---@class Line
---@field left? table
---@field mid? table
---@field right? table

---line highlights
---@class Highlights
---@field left? vim.api.keyset.highlight
---@field mid? vim.api.keyset.highlight
---@field right? vim.api.keyset.highlight

-- refresh config
---@class Refresh
---@field timeout? number
---@field interval? number

-- config
---@class Config
---@field statusline? Line
---@field specialline? Line
---@field highlights? Highlights
---@field specialtypes? table
---@field refresh? Refresh
---@field handle_update? function
M.default = {
  statusline = {
    left = {},
    mid = {},
    right = {},
  },
  specialline = {
    left = {},
    mid = {},
    right = {},
  },
  highlights = {
    left = {},
    mid = {},
    right = {},
  },
  specialtypes = {},
  refresh = {
    timeout = 0,
    interval = 1000,
  },
  handle_update = nil,
}

return M
