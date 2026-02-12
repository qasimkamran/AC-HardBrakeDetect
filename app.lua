-- app.lua


---@diagnostic disable: undefined-global

script = script or {}

---@type table
local detector = require("lib.detector")
---@type table
local telemetry = require("lib.telemetry")
---@type table
local logger = require("lib.logger")
---@type table
local myUi = require("lib.ui")

---@type integer
local WINDOW_SAMPLE_COUNT = 4

local app = {}

---@type Sample[]
local brakeWindow = {}
---@type number|nil
local lastSpeedKmh = nil
---@type number
local elapsedTime = 0

---@type boolean
local hardBrakeDetected = false
---@type string
local statusText = "Monitoring"
---@type boolean
local debug = false
---@type string|nil
local sessionUUID = nil

---@param state table|nil
---@return boolean
local function isBrakeEngaged(state)
  if not state then
    return false
  end
  return (tonumber(state.brake) or 0) > 0
end

---@param window Sample[]
---@param maxCount integer
local function trimWindow(window, maxCount)
  while #window > maxCount do
    table.remove(window, 1)
  end
end

local function resetBrakeWindow()
  brakeWindow = {}
  hardBrakeDetected = false
  statusText = "Monitoring"
end

---@param dt number|nil
---@param state table|nil
---@return Sample|nil
local function buildSample(dt, state)
  ---@type Sample|nil
  local sample = telemetry.getSampleFromCSP(state, dt, lastSpeedKmh, elapsedTime)
  if not sample then
    return nil
  end

  lastSpeedKmh = sample.speed
  elapsedTime = sample.time
  return sample
end

---@return boolean
local function hasEnoughSamples()
  return #brakeWindow >= WINDOW_SAMPLE_COUNT
end

---@return boolean
local function runDetectionForWindow()
  if not hasEnoughSamples() then
    return false
  end
  return detector.isHardBrake(brakeWindow)
end

---@param dt number|nil
---@param state table|nil
---@return boolean
local function processBrakeTelemetry(dt, state)
  if not isBrakeEngaged(state) then
    resetBrakeWindow()
    return false
  end

  ---@type Sample|nil
  local sample = buildSample(dt, state)
  if not sample then
    return false
  end

  brakeWindow[#brakeWindow + 1] = sample
  trimWindow(brakeWindow, WINDOW_SAMPLE_COUNT)

  if debug then
    sessionUUID = sessionUUID or logger.getSessionUUID()
    logger.writeWindowToLogFile(sessionUUID, brakeWindow)
  end

  hardBrakeDetected = runDetectionForWindow()
  statusText = hardBrakeDetected and "Hard Brake Detected" or "Monitoring"
  return hardBrakeDetected
end

---@return table|nil
local function getTelemetryState()
  if ac and ac.getCar then
    return ac.getCar(0)
  end
  return nil
end


--> App lifecycle

function script.onShow()
  sessionUUID = logger.getSessionUUID()
  resetBrakeWindow()
  print("App shown")
end

function script.onHide()
  sessionUUID = nil
  print("App hidden")
end


--> Update loop

function script.update(dt)
  ---@type table|nil
  local state = getTelemetryState()

  debug = ui.checkbox("Enable Debug Logging", debug)

  processBrakeTelemetry(dt, state)

  --> UI rendering
  myUi.drawApp(vec2(100, 100), statusText, hardBrakeDetected)
end


return app
