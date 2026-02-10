---@type table
local lu = require("luaunit")

---@return table
local function reloadDetector()
    package.loaded["lib.detector"] = nil
    return require("lib.detector")
end

---@param content string
---@return string
local function writeTempCSV(content)
    ---@type string
    local path = os.tmpname()
    ---@type file*
    local file = assert(io.open(path, "w"))
    file:write(content)
    file:close()
    return path
end

---@type table
TestDetector = {}

function TestDetector:testLoadTelemetryFromCSVParsesAndCastsFields()
    ---@type table
    local detector = reloadDetector()
    ---@type string
    local csv = table.concat({
        "time,speed,acceleration",
        "0.0,80.5,-3.2",
        "bad,79.1,-2.0",
        "0.2,79.0,-1.4",
    }, "\n")

    ---@type string
    local path = writeTempCSV(csv)
    ---@type table
    local samples = detector.loadTelemetryFromCSV(path)
    os.remove(path)

    lu.assertNotNil(samples)
    lu.assertEquals(#samples, 2)

    lu.assertEquals(samples[1].time, 0.0)
    lu.assertEquals(samples[1].speed, 80.5)
    lu.assertEquals(samples[1].acceleration, -3.2)

    lu.assertEquals(samples[2].time, 0.2)
    lu.assertEquals(samples[2].speed, 79.0)
    lu.assertEquals(samples[2].acceleration, -1.4)
end

function TestDetector:testGetSamplesReturnsInternalCollection()
    ---@type table
    local detector = reloadDetector()
    ---@type string
    local csv = table.concat({
        "time,speed,acceleration",
        "0.0,30.0,-0.2",
        "0.2,29.9,-0.3",
    }, "\n")

    ---@type string
    local path = writeTempCSV(csv)
    detector.loadTelemetryFromCSV(path)
    os.remove(path)

    ---@type table
    local samples = detector.getSamples()

    lu.assertEquals(#samples, 2)
    lu.assertEquals(samples[1].time, 0.0)
end

function TestDetector:testIsHardBrakeReturnsTrueForSustainedStrongDeceleration()
    ---@type table
    local detector = reloadDetector()
    ---@type table[]
    local window = {
        { time = 0.0, speed = 30.0, acceleration = -3.1 },
        { time = 0.2, speed = 28.0, acceleration = -3.2 },
        { time = 0.4, speed = 26.0, acceleration = -3.4 },
        { time = 0.6, speed = 24.0, acceleration = -3.3 },
    }

    lu.assertTrue(detector.isHardBrake(window))
end

function TestDetector:testIsHardBrakeReturnsFalseWhenInsufficientConsecutiveDecel()
    ---@type table
    local detector = reloadDetector()
    ---@type table[]
    local window = {
        { time = 0.0, speed = 30.0, acceleration = -3.1 },
        { time = 0.2, speed = 29.4, acceleration = -2.9 },
        { time = 0.4, speed = 28.7, acceleration = -3.2 },
        { time = 0.6, speed = 28.0, acceleration = -2.8 },
    }

    lu.assertFalse(detector.isHardBrake(window))
end
