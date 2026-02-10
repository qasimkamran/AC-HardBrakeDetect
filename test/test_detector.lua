local lu = require("luaunit")

local function reloadDetector()
    package.loaded["lib.detector"] = nil
    return require("lib.detector")
end

local function writeTempCSV(content)
    local path = os.tmpname()
    local file = assert(io.open(path, "w"))
    file:write(content)
    file:close()
    return path
end

TestDetector = {}

function TestDetector:testLoadTelemetryFromCSVParsesAndCastsFields()
    local detector = reloadDetector()
    local csv = table.concat({
        "time,speed,acceleration,braking",
        "0.0,80.5,-3.2,true",
        "bad,79.1,-2.0,false",
        "0.2,79.0,-1.4,false",
    }, "\n")

    local path = writeTempCSV(csv)
    local samples = detector.loadTelemetryFromCSV(path)
    os.remove(path)

    lu.assertNotNil(samples)
    lu.assertEquals(#samples, 2)

    lu.assertEquals(samples[1].time, 0.0)
    lu.assertEquals(samples[1].speed, 80.5)
    lu.assertEquals(samples[1].acceleration, -3.2)
    lu.assertTrue(samples[1].braking)

    lu.assertEquals(samples[2].time, 0.2)
    lu.assertEquals(samples[2].speed, 79.0)
    lu.assertEquals(samples[2].acceleration, -1.4)
    lu.assertFalse(samples[2].braking)
end

function TestDetector:testGetSamplesReturnsInternalCollection()
    local detector = reloadDetector()
    local csv = table.concat({
        "time,speed,acceleration,braking",
        "0.0,30.0,-0.2,false",
        "0.2,29.9,-0.3,false",
    }, "\n")

    local path = writeTempCSV(csv)
    detector.loadTelemetryFromCSV(path)
    os.remove(path)

    local samples = detector.getSamples()

    lu.assertEquals(#samples, 2)
    lu.assertEquals(samples[1].time, 0.0)
end

function TestDetector:testIsHardBrakeReturnsTrueForSustainedStrongDeceleration()
    local detector = reloadDetector()
    local window = {
        { time = 0.0, speed = 30.0, acceleration = -3.1, braking = true },
        { time = 0.2, speed = 28.0, acceleration = -3.2, braking = true },
        { time = 0.4, speed = 26.0, acceleration = -3.4, braking = true },
        { time = 0.6, speed = 24.0, acceleration = -3.3, braking = true },
    }

    lu.assertTrue(detector.isHardBrake(window))
end

function TestDetector:testIsHardBrakeReturnsFalseWhenInsufficientConsecutiveDecel()
    local detector = reloadDetector()
    local window = {
        { time = 0.0, speed = 30.0, acceleration = -3.1, braking = true },
        { time = 0.2, speed = 29.4, acceleration = -2.9, braking = true },
        { time = 0.4, speed = 28.7, acceleration = -3.2, braking = true },
        { time = 0.6, speed = 28.0, acceleration = -2.8, braking = true },
    }

    lu.assertFalse(detector.isHardBrake(window))
end

