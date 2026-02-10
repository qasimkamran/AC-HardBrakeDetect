---@type table
local lu = require("luaunit")
---@type table
local telemetry = require("lib.telemetry")

---@type table
TestTelemetry = {}

function TestTelemetry:testValidateHeaderAndGetSampleFromRowWithReorderedColumns()
    ---@type string[]
    local header = { "speed", "time", "acceleration" }
    ---@type boolean
    local isValid = telemetry.validateHeader(header)

    lu.assertTrue(isValid)

    ---@type string[]
    local row = { "88.4", "1.5", "-2.2" }
    ---@type table
    local sample = telemetry.getSampleFromRow(row)

    lu.assertEquals(sample.time, "1.5")
    lu.assertEquals(sample.speed, "88.4")
    lu.assertEquals(sample.acceleration, "-2.2")
end

function TestTelemetry:testValidateHeaderFailsWhenRequiredFieldMissing()
    ---@type string[]
    local header = { "time", "speed" }

    lu.assertErrorMsgContains("Required header", telemetry.validateHeader, header)
end

function TestTelemetry:testGetSampleFromCSPReturnsNilForInvalidState()
    lu.assertNil(telemetry.getSampleFromCSP(nil, 0.1, 10, 1.0))
    lu.assertNil(telemetry.getSampleFromCSP({ speedKmh = "abc" }, 0.1, 10, 1.0))
end

function TestTelemetry:testGetSampleFromCSPComputesTimeAndAcceleration()
    ---@type table
    local sample = telemetry.getSampleFromCSP({ speedKmh = "72" }, 0.5, 54, 2.0)

    lu.assertNotNil(sample)
    lu.assertEquals(sample.time, 2.5)
    lu.assertEquals(sample.speed, 72)
    lu.assertAlmostEquals(sample.acceleration, 10.0, 1e-9)
end
