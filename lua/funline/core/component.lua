local utils = require("funline.utils")

local Ctx = require("funline.core.ctx")

-- default props
---@class Component.Props
---@field condition boolean
---@field icon string
---@field provider string
---@field padding { left: string, right: string }
---@field hl vim.api.keyset.highlight
local DEFAULT_PROPS = {
  condition = true,
  icon = "",
  provider = "",
  padding = { left = "", right = "" },
  hl = {},
}

-- component
---@class Component
---@field name? string
---@field timer? Timer
---@field props? Component.Props
---@field ctx? Ctx
local Component = {
  name = nil,
  timer = nil,
  props = nil,
  ctx = nil,
}

Component.__index = Component

Component = setmetatable(Component, {
  __call = function(self, name, timer, props) return self:new(name, timer, props) end,
})

function Component:new(name, timer, props)
  local instance = setmetatable({}, self)
  instance:init(name, timer, props)
  return instance
end

function Component:get_callbacks()
  local refresh = function(interval) self.timer:refresh(interval, self.name) end
  local done = function() self.timer:done(self.name) end

  local callbacks = {
    refresh = refresh,
    done = done,
  }

  return callbacks
end

function Component:init(name, timer, props)
  local callbacks = self:get_callbacks()

  self.name = name
  self.timer = timer
  self.props = props
  self.ctx = Ctx(callbacks)
end

function Component:validate(props)
  local validateProps = {}

  for key, value in pairs(props or {}) do
    if not DEFAULT_PROPS[key] then
      error(string.format("[%s]Invalid prop: %s", self.name, key))
    end
    validateProps[key] = value
  end

  return validateProps
end

function Component:callback(fn)
  local props = fn(self.ctx)

  return props
end

function Component:format(icon, provider, padding, hl)
  local component
  local space = " "

  if #icon > 0 and #provider > 0 then
    component = string.format("%s%s%s", icon, space, provider)
  elseif #icon > 0 and #provider == 0 then
    component = icon
  elseif #icon == 0 and #provider > 0 then
    component = provider
  else
    component = ""
  end

  if component ~= "" then
    padding.left = padding.left or DEFAULT_PROPS.padding.left
    padding.right = padding.right or DEFAULT_PROPS.padding.right

    component = string.format(
      "%s%s%s",
      utils.escape(tostring(padding.left), "%"),
      component,
      utils.escape(tostring(padding.right), "%")
    )
  end

  local hl_group = string.format("funline_%s", self.name)
  vim.api.nvim_set_hl(0, hl_group, hl)

  return utils.set_hl(hl_group, component, true)
end

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
    local icon = utils.escape(tostring(merged_props.icon), "%")
    local provider = utils.escape(tostring(merged_props.provider), "%")
    local padding = merged_props.padding
    local hl = merged_props.hl

    if not condition then
      return ""
    end

    local component = self:format(icon, provider, padding, hl)

    return component
  end

  return loader
end

return Component
