local Component = require("funline.component")
local Timer = require("funline.timer")

local config = require("funline.config")
local utils = require("funline.utils")

local default = config.default

---@type Config
local setup = {
  statusline = default.statusline,
  specialline = default.specialline,
  specialtypes = default.specialtypes,
  highlight = default.highlight,
  refresh = default.refresh,
  handler = default.handler,
}

---@class Funline_status
---@field isUpdate boolean
---@field isClose boolean
local status = {
  isUpdate = true,
  isClose = false,
}

---@class Funline
---@field timer Timer?
---@field autocmd_id number?
---@field status Funline_status
---@field setup Config
local Funline = {
  timer = nil,
  autocmd_id = nil,
  status = status,
  setup = setup,
}

Funline.__index = Funline

---@type Funline | nil
local instance = nil

local events = {
  "WinEnter",
  "BufEnter",
  "CmdlineEnter",
  "CmdlineChanged",
  "CmdlineLeave",
  "BufWritePost",
  "SessionLoadPost",
  "FileChangedShellPost",
  "VimResized",
  "Filetype",
  "TextChanged",
  "TextChangedI",
  "CursorMoved",
  "CursorMovedI",
  "ModeChanged",
  -- "Colorscheme",
  "SearchWrapped",
  "LspAttach",
  "LspDetach",
  "LspNotify",
  "LspProgress",
  "LspRequest",
}

function Funline:new(options)
  local funline = self:getInstance(options)

  local handle_render = function()
    funline:update_handler()
    if funline:get_status() then
      funline:render()
    end
  end

  local fn = function()
    funline:set_status({ isUpdate = true })
    funline:validate(handle_render)
  end

  fn()
  funline:create_autocmd(fn)
  funline.timer:start(fn)
end

function Funline:set_status(opts) self.status = vim.tbl_extend("force", self.status, opts) end

function Funline:get_status() return self.status.isUpdate and not self.status.isClose end

function Funline:destroy()
  self:del_autocmd()
  if self.timer then
    self.timer:stop()
    if not self.timer.uv_timer:is_closing() then
      local callback = function()
        self:set_status({ isClose = true })
        self.timer = nil
        instance = nil
      end
      self.timer:close(callback)
    end
  end
  self:restore_statusline()
end

function Funline:open(options)
  if instance == nil then
    self:new(options)
  end
end

function Funline:close()
  if instance then
    local funline = self:getInstance(self.setup)
    if not funline.status.isClose then
      funline:destroy()
    end
  end
end

function Funline:toggle(options)
  if instance then
    local funline = self:getInstance(self.setup)
    if not funline.status.isClose then
      funline:close()
    end
  else
    self:open(options)
  end
end

function Funline:stop()
  local funline = self:getInstance(self.setup)
  funline.timer:stop()
end

function Funline:start()
  local funline = self:getInstance(self.setup)
  funline:new(self.setup)
end

-- function Funline:restart(options)
--   if instance then
--     local funline = self:getInstance(self.setup)
--     funline:destroy()
--   end
--   self:new(options)
-- end

-- 获取实例
function Funline:getInstance(options)
  if instance == nil then
    instance = setmetatable({}, self)
    instance:init(options)
  end
  instance:set()
  return instance
end

function Funline:validate(fn)
  local ok, err = pcall(fn)

  if not ok then
    self:destroy()
    error(err)
  end
end

function Funline:init(options)
  self.setup = options

  if type(self.setup.refresh) == "table" then
    self.setup.refresh.timeout = options.refresh.timeout
    self.setup.refresh.interval = options.refresh.interval
  elseif type(self.setup.refresh) == "boolean" and self.setup.refresh then
    self.setup.refresh = {}
    self.setup.refresh.timeout = config.default.refresh.timeout
    self.setup.refresh.interval = config.default.refresh.interval
  elseif type(self.setup.refresh) == "boolean" and not self.setup.refresh then
    self.setup.refresh = {}
    self.setup.refresh.timeout = 0
    self.setup.refresh.interval = 0
  elseif type(self.setup.handler) == "function" then
    self.setup.handler = options.handler
  end

  if self.timer == nil then
    self.timer = Timer:new(self.setup.refresh)
  end
end

function Funline:set()
  self:set_highlight()

  self:set_components("statusline_left_components", self.setup.statusline.left)
  self:set_components("statusline_mid_components", self.setup.statusline.mid)
  self:set_components("statusline_right_components", self.setup.statusline.right)

  self:set_components("specialline_left_components", self.setup.specialline.left)
  self:set_components("specialline_mid_components", self.setup.specialline.mid)
  self:set_components("specialline_right_components", self.setup.specialline.right)
end

function Funline:create_autocmd(callback)
  local group = vim.api.nvim_create_augroup("Funline", { clear = true })
  self.autocmd_id = vim.api.nvim_create_autocmd(events, {
    group = group,
    callback = callback,
  })
end

function Funline:del_autocmd()
  if self.autocmd_id then
    vim.api.nvim_del_autocmd(self.autocmd_id)
    self.autocmd_id = nil
  end
end

function Funline:set_highlight()
  local hl_group = "Funline"
  vim.api.nvim_set_hl(0, hl_group, self.setup.highlight)
end

function Funline:get_statusline() return vim.o.statusline end

function Funline:set_statusline(content) vim.o.statusline = content end

function Funline:restore_statusline() vim.o.statusline = "" end

function Funline:update_handler()
  if self.setup.handler then
    self.setup.handler(function(update) self:set_status({ isUpdate = update }) end)
  end
end

function Funline:set_components(name, components)
  local funline_components = {}
  for key, component_props in ipairs(components) do
    local component_name = string.format("%s_%s", name, key)
    local component = Component(component_name, self.timer, component_props)
    local component_loader = component:load()
    table.insert(funline_components, component_loader)
  end
  vim.api.nvim_set_var(name, funline_components)
end

function Funline:section(name)
  local components = {}
  local var = vim.api.nvim_get_var(name)
  for key, _ in ipairs(var) do
    local fn = string.format("%%v:lua.vim.api.nvim_get_var('%s')[%s]()", name, key - 1)
    local result = string.format("%%{%s%%}", fn)
    local is_empty = vim.api.nvim_get_var(name)[key]() == ""
    if not is_empty then
      table.insert(components, result)
    end
  end
  return table.concat(components, " ")
end

function Funline:render_line(left, mid, right)
  local line = ""
  local left_line = self:section(left)
  local mid_line = self:section(mid)
  local right_line = self:section(right)
  line = string.format("%s%%=%s%%=%s", left_line, mid_line, right_line)
  return line
end

--- @class Funline
--- @param self Funline
function Funline:render()
  local statusline =
    self:render_line("statusline_left_components", "statusline_mid_components", "statusline_right_components")
  local specialline =
    self:render_line("specialline_left_components", "specialline_mid_components", "specialline_right_components")

  local content = utils.set_hl("Funline", statusline, true)
  if self:get_statusline() ~= nil then
    self:set_statusline(content)
  end
  for _, specialtype in ipairs(self.setup.specialtypes) do
    if vim.bo.filetype == specialtype or vim.bo.buftype == specialtype then
      local special_content = utils.set_hl("Funline", specialline, true)
      if self:get_statusline() ~= nil then
        self:set_statusline(special_content)
      end
      break
    end
  end
end

return Funline
