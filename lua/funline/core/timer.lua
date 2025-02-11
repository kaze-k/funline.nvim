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
local Timer = {
  uv_timer = nil,
  timeout = 0,
  interval = 0,
  status = status,
}

Timer.__index = Timer

---@type Timer | nil
local instance = nil

-- component interval queue
local component_intervals = {}

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
  local fastest = nil
  for _, interval in pairs(component_intervals) do
    if fastest == nil or interval < fastest then
      fastest = interval
    end
  end
  return fastest
end

function Timer:reset()
  local fastest = self:get_fastest_interval()
  local current_interval = self.uv_timer:get_repeat()

  if fastest == nil then
    if current_interval ~= self.interval then
      self.uv_timer:set_repeat(self.interval)
    end
    return
  end

  if fastest < self.interval and fastest ~= current_interval then
    self.uv_timer:set_repeat(fastest)
  else
    self.uv_timer:set_repeat(self.interval)
  end
  self.uv_timer:again()
end

function Timer:refresh(interval, name)
  if self.status.isStop then
    return
  end

  if not component_intervals[name] or component_intervals[name] ~= interval then
    component_intervals[name] = interval
    self:reset()
  end
end

function Timer:done(name)
  if self.status.isStop then
    return
  end

  if component_intervals[name] then
    component_intervals[name] = nil
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
