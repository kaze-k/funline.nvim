local M = {}

-- line config
---@class Line
---@field left? table
---@field mid? table
---@field right? table

---line highlights
---@class Highlights
---@field left? vim.api.keyset.highlight | function
---@field mid? vim.api.keyset.highlight | function
---@field right? vim.api.keyset.highlight | function

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
---@field refresh? Refresh | boolean
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
  refresh = false,
  handle_update = nil,
}

return M
