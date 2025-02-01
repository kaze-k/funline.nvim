-- ctx
---@class Ctx
---@field callbacks table
local Ctx = {
  callbacks = {},
}

Ctx.__index = Ctx

---@type Ctx
local instance = setmetatable(Ctx, {
  __call = function(self, callbacks) return self:new(callbacks) end,
})

function Ctx:new(callbacks)
  instance = self:get_instance()

  instance.callbacks = callbacks
  return instance
end

function Ctx:get_instance()
  if instance == nil then
    instance = setmetatable({}, self)
  end

  return instance
end

function Ctx.refresh(interval) instance.callbacks.refresh(interval) end

function Ctx.done() instance.callbacks.done() end

return Ctx
