-- logger.lua

local telemetry = require("lib.telemetry")

local logger = {}

local config = {
    LOG_DIR = "../log/"
}

math.randomseed(os.time() + tonumber(tostring({}):match("0x(.*)"), 16))

---@param c string
---@return string
local function uuidReplace(c)
    local v = (c == "x") and math.random(0, 15)
                          or math.random(8, 11)
    return string.format("%x", v)
end

---@return string
function logger.getSessionUUID()
    ---@type string
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    ---@Type string
    local uuid = string.gsub(template, "[xy]", uuidReplace)
    return uuid
end

---@param value any
---@return string
local function csvEscape(value)
    ---@type string
    local text = tostring(value or "")
    if text:find('[,"\n\r]') then
        text = '"' .. text:gsub('"', '""') .. '"'
    end
    return text
end


---@param uuid string
--@param window Sample[]
--@return void
function logger.writeWindowToLogFile(uuid, window)
    ---@type string
    local logDir = config.LOG_DIR

    if logDir:sub(-1) ~= "/" and logDir:sub(-1) ~= "\\" then
        logDir = logDir .. "/"
    end

    ---@type string
    local filePath = logDir .. uuid .. ".csv"
    ---@type file*?
    local file = io.open(filePath, "w")
    if not file then
        error(("Unable to open log file for writing in configured LOG_DIR '%s': %s"):format(logDir, filePath))
        return
    end

    file:write("time,speed,acceleration\n")
    for i = 1, #window do
        ---@type Sample
        local sample = window[i]
        file:write(
            csvEscape(sample.time), ",",
            csvEscape(sample.speed), ",",
            csvEscape(sample.acceleration), "\n"
        )
    end

    file:close()
end

return logger

