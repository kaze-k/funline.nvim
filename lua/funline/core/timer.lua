local uv = vim.uv

-- timer status
---@class Timer.Status
---@field isStop boolean
local status = {
  isStop = true,
}

-- timer
---@class Timer
---@field uv_timer? uv_timer_t
---@field timeout integer
---@field interval integer
---@field status Timer.Status
---@field component_intervals table
---@field fastest integer | nil
---@field finded_fastest boolean
local Timer = {
  uv_timer = nil,
  timeout = 0,
  interval = 0,
  status = status,
  component_intervals = {},
  fastest = nil,
  finded_fastest = false,
}

Timer.__index = Timer

---@type Timer | nil
local instance = nil

function Timer:new(options)
  local timer = self:get_instance()
  timer:init(options)
  return timer
end

function Timer:get_instance()
  if instance == nil then
    instance = setmetatable({}, self)
  end
  return instance
end

function Timer:init(options)
  self.uv_timer = uv.new_timer()

  if type(options) == "table" then
    if options.timeout and options.timeout > 0 then
      self.timeout = options.timeout
    end
    if options.interval and options.interval > 0 then
      self.interval = options.interval
    end
  end

  if type(options) == "number" then
    self.interval = options
  end
end

function Timer:get_fastest_interval()
  for _, interval in pairs(self.component_intervals) do
    if self.fastest == nil or interval < self.fastest then
      self.fastest = interval
    end
  end

  self.finded_fastest = true
end

function Timer:reset()
  if self.fastest == nil or not self.finded_fastest then
    self:get_fastest_interval()
  end

  local current_interval = self.uv_timer:get_repeat()

  if self.fastest == nil then
    if current_interval ~= self.interval then
      self.uv_timer:set_repeat(self.interval)
    end
  elseif self.fastest < self.interval and self.fastest ~= current_interval then
    self.uv_timer:set_repeat(self.fastest)
  else
    self.uv_timer:set_repeat(self.interval)
  end

  self.uv_timer:again()
end

function Timer:refresh(interval, name)
  if self.status.isStop then
    return
  end

  if not self.component_intervals[name] or self.component_intervals[name] ~= interval then
    self.component_intervals[name] = interval
    if self.fastest == nil or interval < self.fastest then
      self.finded_fastest = false
    end
    self:reset()
  end
end

function Timer:done(name)
  if self.status.isStop then
    return
  end

  if self.component_intervals[name] then
    self.component_intervals[name] = nil
    self.finded_fastest = false
    self:reset()
  end
end

function Timer:start(fn)
  if self.uv_timer == nil then
    self.uv_timer = uv.new_timer()
  end
  self.status.isStop = false
  local callback = vim.schedule_wrap(fn)
  self.uv_timer:start(self.timeout, self.interval, callback)
end

function Timer:stop()
  if self.uv_timer then
    self.uv_timer:stop()
    self.status.isStop = true
  end
end

function Timer:close(callback)
  if self.uv_timer then
    self.uv_timer:close(callback)
  end
end

return Timer
