local config = require("funline.config")
local utils = require("funline.utils")

local Component = require("funline.core.component")
local Timer = require("funline.core.timer")

local default = config.default

---@type Config
local setup = {
  statusline = default.statusline,
  specialline = default.specialline,
  specialtypes = default.specialtypes,
  highlights = default.highlights,
  refresh = default.refresh,
  handle_update = default.handle_update,
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

local statusline_components_names = {
  left = "statusline_left_components",
  mid = "statusline_mid_components",
  right = "statusline_right_components",
}

local specialline_components_names = {
  left = "specialline_left_components",
  mid = "specialline_mid_components",
  right = "specialline_right_components",
}

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

local hl_groups = {
  left = "funline_left_line",
  mid = "funline_mid_line",
  right = "funline_right_line",
}

local isCalled = false

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

local timer_callback = function()
  run()
  isCalled = true
end

local autocmd_callback = function()
  if not isCalled then
    run()
  end
  isCalled = false
end

function Funline:new(options)
  setup_config = options

  instance = self:get_instance(setup_config)

  instance:create_autocmd(autocmd_callback)
  instance.timer:start(timer_callback)
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

  if type(self.setup.handle_update) == "function" then
    self.setup.handle_update = options.handle_update
  end

  if self.timer == nil then
    self.timer = Timer:new(self.setup.refresh)
  end
end

function Funline:set_line()
  self:set_highlights()

  self:set_components(statusline_components_names.left, self.setup.statusline.left)
  self:set_components(statusline_components_names.mid, self.setup.statusline.mid)
  self:set_components(statusline_components_names.right, self.setup.statusline.right)

  self:set_components(specialline_components_names.left, self.setup.specialline.left)
  self:set_components(specialline_components_names.mid, self.setup.specialline.mid)
  self:set_components(specialline_components_names.right, self.setup.specialline.right)
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

function Funline:set_highlights()
  vim.api.nvim_set_hl(0, hl_groups.left, self.setup.highlights.left)
  vim.api.nvim_set_hl(0, hl_groups.mid, self.setup.highlights.mid)
  vim.api.nvim_set_hl(0, hl_groups.right, self.setup.highlights.right)
end

function Funline:update_handler()
  if self.setup.handle_update then
    self.setup.handle_update(function(update) self:set_status({ isUpdate = update }) end)
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
  return table.concat(components, "")
end

function Funline:render_line(left, mid, right)
  local line = ""
  local left_line = self:section(left)
  local mid_line = self:section(mid)
  local right_line = self:section(right)

  local mid_symbol = utils.set_hl(hl_groups.mid, "%=", true)

  left_line = utils.set_hl(hl_groups.left, left_line, true)
  mid_line = utils.set_hl(hl_groups.mid, mid_line, true)
  right_line = utils.set_hl(hl_groups.right, right_line, true)

  if mid_line == "" then
    line = string.format("%s%s%s", left_line, mid_symbol, right_line)
  else
    line = string.format("%s%s%s%s%s", left_line, mid_symbol, mid_line, mid_symbol, right_line)
  end
  return line
end

function Funline:render()
  local statusline = self:render_line(
    statusline_components_names.left,
    statusline_components_names.mid,
    statusline_components_names.right
  )
  local specialline = self:render_line(
    specialline_components_names.left,
    specialline_components_names.mid,
    specialline_components_names.right
  )

  self:set_statusline(statusline)

  for _, specialtype in ipairs(self.setup.specialtypes) do
    if vim.bo.filetype == specialtype or vim.bo.buftype == specialtype then
      self:set_statusline(specialline)
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

Funline.open = function()
  if instance == nil then
    Funline:new(setup_config)
  end
end

Funline.close = function()
  if instance then
    if not instance.status.isClose then
      instance:destroy()
    end
  end
end

Funline.toggle = function()
  if instance then
    if not instance.status.isClose then
      instance:close()
    end
  else
    Funline:open()
  end
end

Funline.stop = function()
  if instance then
    instance.timer:stop()
  end
end

Funline.start = function()
  if instance then
    instance.timer:start(run)
  end
end

Funline.reload = function()
  if instance then
    instance:new(setup_config)
  end
  Funline:new(setup_config)
end

return Funline
