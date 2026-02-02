-- detector.lua

local parser = require("lib.parser")
local telemetry = require("lib.telemetry")

local detector = {}

---@type Sample[]
local samples = {}

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

        ---@type boolean
        local braking = (tostring(sample.braking):lower() == "true") and true or false
        if not braking then
            goto continue
        end
        sample.braking = braking

        samples[#samples + 1] = sample
        ::continue::
    end

    return samples
end

---@return Sample[]
function detector.getSamples()
    return samples
end

return detector
