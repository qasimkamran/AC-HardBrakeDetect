-- detector.lua

local parser = require("lib.parser")
local telemetry = require("lib.telemetry")

local detector = {}

local HardBrakeConfig = {
    MIN_EXPECTED_SAMPLE_RATE_HZ = 5,
    CHANGE_IN_SPEED_THRESHOLD = 1.0,
    PEAK_DECEL_THRESHOLD = -3.0,
    DECEL_MIN_CONSECUTIVE_SAMPLES = 2
}

---@type Sample[]
local samples = {}

---@type number
local lastSpeed = 0

---@type number
local elapsedTime = 0

---@param filepath string
---@return string|nil
local function readFileData(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return nil
    end
    local data = file:read("*a")
    file:close()
    return data
end

---@param filepath string
---@return Sample[]|nil
function detector.loadTelemetryFromCSV(filepath)
    local data = readFileData(filepath)
    if not data then
        return nil
    end

    local rows = parser.parseCSV(data)
    if not rows or #rows == 0 then
        return nil
    end

    if not telemetry.validateHeader(rows[1]) then
        return nil
    end

    samples = {}
    for i = 2, #rows do
        local sample = telemetry.getSampleFromRow(rows[i])
        if not sample then
            goto continue
        end

        ---@type number?
        local time = tonumber(sample.time)
        if not time then
            goto continue
        end
        sample.time = time

        ---@type number?
        local speed = tonumber(sample.speed)
        if not speed then
            goto continue
        end
        sample.speed = speed

        ---@type number?
        local acceleration = tonumber(sample.acceleration)
        if not acceleration then
            goto continue
        end
        sample.acceleration = acceleration

        samples[#samples + 1] = sample
        ::continue::
    end

    return samples
end

---@param dt number|nil
---@param state table
---@return Sample|nil
function detector.loadTelemetryFromCSP(dt, state)
    ---@type Sample|nil
    local sample = telemetry.getSamplCSP(state, dt, lastSpeed, elapsedTime)
    if not sample then
        return nil
    end

    ---@type number|nil
    if not sample.speed then
        return nil
    end
    lastSpeed = sample.speed

    ---@type number|nil
    if not sample.time then
        return nil
    end
    elapsedTime = sample.time

    samples[#samples + 1] = sample
    return sample
end

---@return Sample[]
function detector.getSamples()
    return samples
end

---@param window Sample[]
---@return boolean
function detector.isHardBrake(window)
    if not window or #window < 2 then
        return false
    end

    ---@type number
    local startSpeed = window[1].speed
    ---@type number
    local startTime = window[1].time

    ---@type number
    local endSpeed = window[#window].speed
    ---@type number
    local endTime = window[#window].time

    ---@type number
    local changeInSpeed = startSpeed - endSpeed
    ---@type number
    local changeInTime = endTime - startTime

    if changeInTime <= 0 then
        return false
    end

    -- Minimum expected sampling density while the brake is held.
    local minSamplesForDuration = math.max(2, math.floor((changeInTime * HardBrakeConfig.MIN_EXPECTED_SAMPLE_RATE_HZ) + 0.5))
    if #window < minSamplesForDuration then
        return false
    end

    if changeInSpeed < HardBrakeConfig.CHANGE_IN_SPEED_THRESHOLD then
        return false
    end

    ---@type number
    local peakDecceleration = 0
    local consecutiveBelowThreshold = 0
    local maxConsecutiveBelowThreshold = 0
    for i = 1, #window do
        if window[i].acceleration < peakDecceleration then
            peakDecceleration = window[i].acceleration
        end

        if window[i].acceleration <= HardBrakeConfig.PEAK_DECEL_THRESHOLD then
            consecutiveBelowThreshold = consecutiveBelowThreshold + 1
            if consecutiveBelowThreshold > maxConsecutiveBelowThreshold then
                maxConsecutiveBelowThreshold = consecutiveBelowThreshold
            end
        else
            consecutiveBelowThreshold = 0
        end
    end

    if peakDecceleration > HardBrakeConfig.PEAK_DECEL_THRESHOLD then
        return false
    end
    if maxConsecutiveBelowThreshold < HardBrakeConfig.DECEL_MIN_CONSECUTIVE_SAMPLES then
        return false
    end

    return true
end

return detector

