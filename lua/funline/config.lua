local M = {}

-- line config
---@class Line
---@field left? table
---@field mid? table
---@field right? table

-- refresh config
---@class Refresh
---@field timeout? number
---@field interval? number

-- config
---@class Config
---@field statusline? Line
---@field specialline? Line
---@field specialtypes? table
---@field highlight? vim.api.keyset.highlight
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
  specialtypes = {},
  highlight = { link = "StatusLine" },
  refresh = {
    timeout = 0,
    interval = 1000,
  },
  handle_update = nil,
}

return M
