---@type table
local lu = require("luaunit")
---@type table
local logger = require("lib.logger")

---@param fn function
---@param name string
---@return integer, any
local function getUpvalue(fn, name)
    local i = 1
    while true do
        ---@type string, any
        local upName, upValue = debug.getupvalue(fn, i)
        if not upName then
            break
        end
        if upName == name then
            return i, upValue
        end
        i = i + 1
    end
    error(("Upvalue not found: %s"):format(name))
end

---@type table
TestLogger = {}

function TestLogger:setUp()
    ---@type integer, table
    local _, config = getUpvalue(logger.writeWindowToLogFile, "config")
    ---@type table
    self.config = config
    ---@type string
    self.originalLogDir = config.LOG_DIR
    self.config.LOG_DIR = "/tmp/"
end

function TestLogger:tearDown()
    self.config.LOG_DIR = self.originalLogDir
end

function TestLogger:testGetSessionUUIDReturnsUUIDV4Shape()
    ---@type string
    local uuid = logger.getSessionUUID()
    lu.assertStrMatches(uuid, "^[0-9a-f]+%-[0-9a-f]+%-4[0-9a-f]+%-[89ab][0-9a-f]+%-[0-9a-f]+$")
end

function TestLogger:testWriteWindowToLogFileWritesCSV()
    ---@type string
    local uuid = ("logger-test-%d-%d"):format(os.time(), math.random(100000, 999999))
    ---@type string
    local path = "/tmp/" .. uuid .. ".csv"
    ---@type table[]
    local window = {
        { time = 0.1, speed = 12.5, acceleration = -1.2 },
        { time = 0.2, speed = 11.8, acceleration = -1.9 },
    }

    logger.writeWindowToLogFile(uuid, window)

    ---@type file*
    local file = assert(io.open(path, "r"))
    ---@type string
    local data = file:read("*a")
    file:close()
    os.remove(path)

    lu.assertEquals(data, table.concat({
        "time,speed,acceleration",
        "0.1,12.5,-1.2",
        "0.2,11.8,-1.9",
        ""
    }, "\n"))
end

function TestLogger:testWriteWindowToLogFileEscapesCSVFields()
    ---@type string
    local uuid = ("logger-escape-%d-%d"):format(os.time(), math.random(100000, 999999))
    ---@type string
    local path = "/tmp/" .. uuid .. ".csv"
    ---@type table[]
    local window = {
        { time = "1,2", speed = '"3"4"', acceleration = "line\nbreak" },
    }

    logger.writeWindowToLogFile(uuid, window)

    ---@type file*
    local file = assert(io.open(path, "r"))
    ---@type string
    local data = file:read("*a")
    file:close()
    os.remove(path)

    lu.assertEquals(data, table.concat({
        "time,speed,acceleration",
        '"1,2","""3""4""","line',
        'break"',
        ""
    }, "\n"))
end

function TestLogger:testWriteWindowToLogFileErrorsWhenLogDirIsInvalid()
    self.config.LOG_DIR = "/tmp/logger-missing-dir-should-not-exist/"

    lu.assertErrorMsgContains(
        "Unable to open log file for writing in configured LOG_DIR",
        logger.writeWindowToLogFile,
        "logger-error-test",
        {}
    )
end

