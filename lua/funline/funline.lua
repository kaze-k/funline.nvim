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

-- funline status
---@class Funline.Status
---@field isUpdate boolean
---@field isClose boolean
local status = {
  isUpdate = true,
  isClose = false,
}

-- funline
---@class Funline
---@field timer Timer?
---@field autocmd_id integer?
---@field status Funline.Status
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

local setup_config = nil

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
  "SearchWrapped",
  "LspAttach",
  "LspDetach",
  "LspNotify",
  "LspProgress",
  "LspRequest",
}

local handle_render = function()
  if instance then
    instance:update_handler()
    if instance:get_status() then
      instance:render()
    end
  end
end

local run = function()
  if instance then
    instance:set_status({ isUpdate = true })
    instance:validate(handle_render)
  end
end

function Funline:new(options)
  setup_config = options

  instance = self:get_instance(setup_config)

  -- run()
  instance:create_autocmd(run)
  instance.timer:start(run)
end

function Funline:get_instance(options)
  if instance == nil then
    instance = setmetatable({}, self)
    instance:init(options)
  end
  instance:set_line()
  return instance
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
  end

  if type(self.setup.handler) == "function" then
    self.setup.handler = options.handler
  end

  if self.timer == nil then
    self.timer = Timer:new(self.setup.refresh)
  end
end

function Funline:set_line()
  self:set_highlight()

  self:set_components("statusline_left_components", self.setup.statusline.left)
  self:set_components("statusline_mid_components", self.setup.statusline.mid)
  self:set_components("statusline_right_components", self.setup.statusline.right)

  self:set_components("specialline_left_components", self.setup.specialline.left)
  self:set_components("specialline_mid_components", self.setup.specialline.mid)
  self:set_components("specialline_right_components", self.setup.specialline.right)
end

function Funline:validate(fn)
  local ok, err = pcall(fn)

  if not ok then
    self:destroy()
    error(err)
  end
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

function Funline:set_status(opts) self.status = vim.tbl_extend("force", self.status, opts) end

function Funline:get_status() return self.status.isUpdate and not self.status.isClose end

function Funline:get_statusline() return vim.o.statusline end

function Funline:set_statusline(content)
  local statusline = self:get_statusline()
  if statusline ~= nil then
    vim.o.statusline = content
  end
end

function Funline:restore_statusline() vim.o.statusline = nil end

function Funline:set_highlight()
  local hl_group = "Funline"
  vim.api.nvim_set_hl(0, hl_group, self.setup.highlight)
end

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

function Funline:render()
  local statusline =
    self:render_line("statusline_left_components", "statusline_mid_components", "statusline_right_components")
  local specialline =
    self:render_line("specialline_left_components", "specialline_mid_components", "specialline_right_components")

  local content = utils.set_hl("Funline", statusline, true)
  self:set_statusline(content)

  for _, specialtype in ipairs(self.setup.specialtypes) do
    if vim.bo.filetype == specialtype or vim.bo.buftype == specialtype then
      local special_content = utils.set_hl("Funline", specialline, true)
      self:set_statusline(special_content)
      break
    end
  end
end

function Funline:destroy()
  self:del_autocmd()
  if self.timer then
    self.timer:stop()
    if not self.timer.uv_timer:is_closing() then
      local fn = function()
        self:set_status({ isClose = true })
        self.timer = nil
        instance = nil
      end
      self.timer:close(fn)
    end
  end
  self:restore_statusline()
end

function Funline:open()
  if instance == nil then
    self:new(setup_config)
  end
end

function Funline:close()
  if instance then
    if not instance.status.isClose then
      instance:destroy()
    end
  end
end

function Funline:toggle()
  if instance then
    if not instance.status.isClose then
      instance:close()
    end
  else
    self:open()
  end
end

function Funline:stop()
  if instance then
    instance.timer:stop()
  end
end

function Funline:start()
  if instance then
    instance.timer:start(run)
  end
end

function Funline:reload(options)
  if instance then
    instance:new(options)
  end
  self:new(options)
end

return Funline
