local lu = require("luaunit")
local parser = require("lib.parser")

TestParser = {}

function TestParser:testParseCSVReturnsNilForNilInput()
    lu.assertNil(parser.parseCSV(nil))
end

function TestParser:testParseCSVParsesRowsAndColumns()
    local csv = "time,speed,acceleration\n0.1,12.5,-1.2\n0.2,11.8,-1.9"

    local rows = parser.parseCSV(csv)

    lu.assertEquals(#rows, 3)
    lu.assertEquals(rows[1], { "time", "speed", "acceleration" })
    lu.assertEquals(rows[2], { "0.1", "12.5", "-1.2" })
    lu.assertEquals(rows[3], { "0.2", "11.8", "-1.9" })
end

function TestParser:testParseCSVSupportsQuotedCommasAndCRLF()
    local csv = 'time,speed,acceleration\r\n0.1,"12,5",-1.2\r\n'

    local rows = parser.parseCSV(csv)

    lu.assertEquals(#rows, 2)
    lu.assertEquals(rows[2], { "0.1", "12,5", "-1.2" })
end

function TestParser:testParseCSVErrorsForUnclosedQuote()
    local csv = 'time,speed\n"0.1,12.5\n'

    lu.assertErrorMsgContains("Unclosed quote", parser.parseCSV, csv)
end
