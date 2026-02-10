local lu = require("luaunit")
local parser = require("lib.parser")

TestParser = {}

function TestParser:testParseCSVReturnsNilForNilInput()
    lu.assertNil(parser.parseCSV(nil))
end

function TestParser:testParseCSVParsesRowsAndColumns()
    local csv = "time,speed,acceleration,braking\n0.1,12.5,-1.2,false\n0.2,11.8,-1.9,true"

    local rows = parser.parseCSV(csv)

    lu.assertEquals(#rows, 3)
    lu.assertEquals(rows[1], { "time", "speed", "acceleration", "braking" })
    lu.assertEquals(rows[2], { "0.1", "12.5", "-1.2", "false" })
    lu.assertEquals(rows[3], { "0.2", "11.8", "-1.9", "true" })
end

function TestParser:testParseCSVSupportsQuotedCommasAndCRLF()
    local csv = 'time,speed,acceleration,braking\r\n0.1,"12,5",-1.2,false\r\n'

    local rows = parser.parseCSV(csv)

    lu.assertEquals(#rows, 2)
    lu.assertEquals(rows[2], { "0.1", "12,5", "-1.2", "false" })
end

function TestParser:testParseCSVErrorsForUnclosedQuote()
    local csv = 'time,speed\n"0.1,12.5\n'

    lu.assertErrorMsgContains("Unclosed quote", parser.parseCSV, csv)
end

