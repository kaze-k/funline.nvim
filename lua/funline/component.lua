local uitls = require("funline.utils")
local config = require("funline.config")
local default_config = config.default

---@class Component_props
---@field condition boolean
---@field icon string
---@field provider string
---@field hl table
---@field interval? number
local DEFAULT_PROPS = {
  condition = true,
  icon = "",
  provider = "",
  hl = default_config.highlight,
  interval = nil,
}

---@class Component
---@field name? string
---@field timer? Timer
---@field props? Component_props
local Component = {
  name = nil,
  timer = nil,
  props = nil,
}

Component.__index = Component

-- 创建组件的函数
Component = setmetatable(Component, {
  __call = function(self, name, timer, props) return self:new(name, timer, props) end,
})

local allowed_props = {
  condition = true,
  icon = true,
  provider = true,
  hl = true,
}

-- 组件的构造函数
function Component:new(name, timer, props)
  local instance = setmetatable({}, self)
  instance:init(name, timer, props)
  return instance
end

-- 设置组件的属性
function Component:init(name, timer, props)
  self.name = name
  self.timer = timer
  self.props = props
end

-- 校验组件的props属性
function Component:validate(props)
  local validateProps = {}

  for key, value in pairs(props or {}) do
    if not allowed_props[key] then
      error(string.format("[%s]Invalid prop: %s", self.name, key))
    end
    validateProps[key] = value
  end

  return validateProps
end

function Component:callback(fn)
  local refresh = function(interval) self.timer:refresh(interval, self.name) end

  local done = function() self.timer:done(self.name) end

  local props = fn(refresh, done)

  return props
end

-- 格式化组件
function Component:format(icon, provider, hl)
  local component
  if #icon > 0 and #provider > 0 then
    component = string.format("%s %s", icon, provider)
  elseif #icon > 0 and #provider == 0 then
    component = icon
  elseif #icon == 0 and #provider > 0 then
    component = provider
  else
    component = ""
  end

  local hl_group = string.format("funline_%s", self.name)
  vim.api.nvim_set_hl(0, hl_group, hl)

  return uitls.set_hl(hl_group, component, true)
end

-- 加载组件
function Component:load()
  local loader = function()
    local props
    if type(self.props) == "table" then
      props = self.props
    end
    if type(self.props) == "function" then
      props = self:callback(self.props)
    end
    local validateProps = self:validate(props)
    local merged_props = vim.tbl_extend("force", DEFAULT_PROPS, validateProps)

    local condition = merged_props.condition
    local icon = uitls.escape(tostring(merged_props.icon), "%")
    local provider = uitls.escape(tostring(merged_props.provider), "%")
    local hl = merged_props.hl

    if not condition then
      return ""
    end

    local component = self:format(icon, provider, hl)

    return component
  end

  return loader
end

return Component