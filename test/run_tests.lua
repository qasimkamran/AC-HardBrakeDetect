---@type table
local luaunit = require("luaunit")

require("test.test_parser")
require("test.test_telemetry")
require("test.test_detector")
require("test.test_ui")

os.exit(luaunit.LuaUnit.run())
