local uv = vim.uv

---@class TimerStatus
---@field isStop boolean
local status = {
  isStop = true,
}

---@class Timer
---@field uv_timer? uv_timer_t
---@field timeout number
---@field interval number
---@field status TimerStatus
local Timer = {
  uv_timer = nil,
  timeout = 0,
  interval = 0,
  status = status,
}

Timer.__index = Timer

---@type Timer | nil
local instance = nil

local DEFAULT_INTERVAL = nil

function Timer:new(options)
  local timer = self:getInstance()
  timer:init(options)
  return timer
end

function Timer:getInstance()
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
      DEFAULT_INTERVAL = options.interval
    end
  end

  if type(options) == "number" then
    self.interval = options
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

function Timer:reset(interval)
  if self.uv_timer and not self.status.isStop then
    if interval == 0 then
      if DEFAULT_INTERVAL then
        self.interval = DEFAULT_INTERVAL
        self.uv_timer:set_repeat(self.interval)
      end
      return
    end

    if interval > 0 and interval < self.interval then
      self.interval = interval
      self.uv_timer:set_repeat(self.interval)
    elseif interval >= self.interval then
      self.uv_timer:set_repeat(self.interval)
    end

    self.uv_timer:again()
  end
end

function Timer:stop()
  if self.uv_timer then
    self.uv_timer:stop()
    self.status.isStop = true
  end
end

function Timer:close(callback)
  if self.uv_timer then
    self.uv_timer:close(callback())
  end
end

return Timer
