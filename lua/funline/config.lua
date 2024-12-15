local M = {}

---@class Line
---@field left? table
---@field mid? table
---@field right? table

---@class Refresh
---@field timeout? number
---@field interval? number

---@class Config
---@field statusline? Line
---@field specialline? Line
---@field specialtypes? table
---@field highlight? table
---@field refresh? Refresh
---@field handler? function
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
  handler = nil,
}

return M
