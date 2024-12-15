local utils = require("funline.utils")

local config = require("funline.config")

local default = config.default

--- 组件的默认配置
---@class Component_props
---@field condition boolean
---@field icon string
---@field provider string
---@field hl table
---@field interval number
local DEFAULT = {
  condition = true,
  icon = "",
  provider = "",
  hl = default.highlight,
  interval = 0,
}

-- 组件类
---@class Component
---@field name? string
---@field timer? Timer
---@field condition boolean
---@field icon string
---@field provider string
---@field hl? table
---@field interval number
local Component = {
  name = nil,
  timer = nil,
  condition = DEFAULT.condition,
  icon = DEFAULT.icon,
  provider = DEFAULT.provider,
  hl = DEFAULT.hl,
  interval = DEFAULT.interval,
}

Component.__index = Component

-- 创建组件的函数
Component = setmetatable(Component, {
  __call = function(self, name, timer, options) return self:new(name, timer, options) end,
})

-- 组件的构造函数
function Component:new(name, timer, options)
  local instance = setmetatable({}, self)
  instance:init(name, timer, options)
  instance:check()
  return instance
end

-- 设置组件的属性
function Component:init(name, timer, options)
  self.name = name
  self.timer = timer
  self.icon = options.icon
  self.provider = options.provider
  self.condition = options.condition
  self.hl = options.hl
  self.interval = options.interval
end

-- 检查组件的icon属性类型
function Component:check_icon()
  local icon = self.icon
  local validation = type(icon) == "string" or type(icon) == "function"
  assert(validation, "Invalid icon type")
  return icon
end

-- 检查组件的provider属性类型
function Component:check_provider()
  local provider = self.provider
  local validation = type(provider) == "string" or type(provider) == "function"
  assert(validation, "Invalid provider type")
  return provider
end

-- 检查组件的condition属性类型
function Component:check_condition()
  local condition = self.condition
  local validation = type(condition) == "boolean" or type(condition) == "function"
  assert(validation, "Invalid condition type")
  return condition
end

-- 检查组件的hl属性类型
function Component:check_hl()
  local hl = self.hl
  local validation = type(hl) == "table" or type(hl) == "function"
  assert(validation, "Invalid hl type")
  return hl
end

-- 检查组件的interval属性类型
function Component:check_interval()
  local interval = self.interval
  local validation = type(interval) == "number" or type(interval) == "function"
  assert(validation, "Invalid interval type")
  return interval
end

-- 获取组件结构
function Component:check()
  self:check_icon()
  self:check_provider()
  self:check_condition()
  self:check_hl()
  self:check_interval()
end

-- 加载icon
function Component:load_icon()
  if type(self.icon) == "string" then
    return self.icon
  end

  if type(self.icon) == "function" then
    return tostring(utils.exec_func(self.icon, self.timer.uv_timer, DEFAULT.icon))
  end
end

-- 加载provider
function Component:load_provider()
  if type(self.provider) == "string" then
    return self.provider
  end

  if type(self.provider) == "function" then
    return tostring(utils.exec_func(self.provider, self.timer.uv_timer, DEFAULT.provider))
  end
end

-- 加载condition
function Component:load_condition()
  if type(self.condition) == "boolean" then
    return self.condition
  end

  if type(self.condition) == "function" then
    return utils.exec_func(self.condition, self.timer.uv_timer, DEFAULT.condition)
  end
end

-- 加载highlight
function Component:load_hl()
  local hl_group = string.format("funline_%s", self.name)

  if type(self.hl) == "table" then
    vim.api.nvim_set_hl(0, hl_group, self.hl)
    return hl_group
  end

  if type(self.hl) == "function" then
    self.hl = utils.exec_func(self.hl, self.timer.uv_timer, DEFAULT.hl)
    vim.api.nvim_set_hl(0, hl_group, self.hl)
    return hl_group
  end
end

function Component:load_interval()
  if type(self.interval) == "number" then
    return self.interval
  end

  if type(self.interval) == "function" then
    return tonumber(utils.exec_func(self.interval, self.timer.uv_timer, DEFAULT.interval))
  end
end

-- 格式化组件
function Component:format(component, icon, provider, hl_group)
  if #icon > 0 and #provider > 0 then
    component = string.format("%s %s", icon, provider)
  elseif #icon > 0 and #provider == 0 then
    component = icon
  elseif #icon == 0 and #provider > 0 then
    component = provider
  else
    component = ""
  end

  component = utils.set_hl(hl_group, component, true)

  return component
end

-- 加载组件
function Component:load()
  local loader = function()
    local condition = self:load_condition()
    local component = ""

    if condition then
      local icon = self:load_icon()
      local provider = self:load_provider()
      local hl_group = self:load_hl()
      local interval = self:load_interval()

      self.timer:reset(interval)

      icon = utils.escape(icon, "%")
      provider = utils.escape(provider, "%")

      component = Component:format(component, icon, provider, hl_group)
    end

    return component
  end

  return loader
end

return Component
