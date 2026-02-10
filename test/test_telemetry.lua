local lu = require("luaunit")
local telemetry = require("lib.telemetry")

TestTelemetry = {}

function TestTelemetry:testValidateHeaderAndGetSampleFromRowWithReorderedColumns()
    local header = { "speed", "time", "braking", "acceleration" }
    local isValid = telemetry.validateHeader(header)

    lu.assertTrue(isValid)

    local row = { "88.4", "1.5", "true", "-2.2" }
    local sample = telemetry.getSampleFromRow(row)

    lu.assertEquals(sample.time, "1.5")
    lu.assertEquals(sample.speed, "88.4")
    lu.assertEquals(sample.acceleration, "-2.2")
    lu.assertEquals(sample.braking, "true")
end

function TestTelemetry:testValidateHeaderFailsWhenRequiredFieldMissing()
    local header = { "time", "speed", "acceleration" }

    lu.assertErrorMsgContains("Required header", telemetry.validateHeader, header)
end

function TestTelemetry:testGetSampleFromCSPReturnsNilForInvalidState()
    lu.assertNil(telemetry.getSampleFromCSP(nil, 0.1, 10, 1.0))
    lu.assertNil(telemetry.getSampleFromCSP({ speedKmh = "abc", brake = 1 }, 0.1, 10, 1.0))
end

function TestTelemetry:testGetSampleFromCSPComputesTimeAccelerationAndBraking()
    local sample = telemetry.getSampleFromCSP({ speedKmh = "72", brake = "1" }, 0.5, 54, 2.0)

    lu.assertNotNil(sample)
    lu.assertEquals(sample.time, 2.5)
    lu.assertEquals(sample.speed, 72)
    lu.assertAlmostEquals(sample.acceleration, 10.0, 1e-9)
    lu.assertTrue(sample.braking)
end

