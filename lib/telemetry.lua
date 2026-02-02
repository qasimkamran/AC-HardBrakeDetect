-- telemetry.lua

local telemetry = {}

---@class Sample
---@field time number
---@field speed number
---@field acceleration number
---@field braking boolean

local Fields = {
    "time",
    "speed",
    "acceleration",
    "braking"
}

---@param fields string[]
---@return table[]
local function initHeaderOrder(fields)
    ---@type table[]
    local result = {}
    for k, v in ipairs(fields) do
        result[k] = { v, nil }
    end
    return result
end

---@type table[]
local HeaderOrder = initHeaderOrder(Fields)

---@param field string
---@param position integer
---@return boolean
local function setFieldPositions(field, position)
    -- The parameters have to be validated outside of this fn
    for _, row in ipairs(HeaderOrder) do
        if row[1] == field then
            row[2] = position
            return true
        end
    end
    return false
end

---@param position integer
--~@return string|nil
local function getHeaderByOrderPosition(position)
    for _, v in ipairs(HeaderOrder) do
        if v[2] == position then
            return v[1]
        end
    end
    return nil
end

---@param header string
---@return integer|nil
local function getPositionByOrderHeader(header)
    for _, v in ipairs(HeaderOrder) do
        if v[1] == header then
            return v[2]
        end
    end
    return nil
end

---@param header string[]
---@param onValid fun(field:string, position:integer)|nil
---@return boolean
local function validateHeaderWithCallback(header, onValid)
    HeaderOrder = initHeaderOrder(Fields)
    local present = {}
    for i,v in ipairs(header) do
        ---@type boolean
        local found = false
        for _,field in ipairs(Fields) do
            if v == field then
                found = true
                present[field] = true
                if onValid then
                    onValid(field, i)
                end
                break
            end
        end
        if not found then
            error(("Header '%s' not found in telemetry fields"):format(v))
            return false
        end
    end
    for _, field in ipairs(Fields) do
        if not present[field] then
            error(("Required header '%s' missing from telemetry data"):format(field))
            return false
        end
    end
    return true
end

---@param header string[]
---@return boolean
function telemetry.validateHeader(header)
    return validateHeaderWithCallback(header, setFieldPositions)
end

---@param row string[]
---@return Sample
function telemetry.getSampleFromRow(row)
    --@type Sample
    local sample = {}

    for _, field in ipairs(Fields) do
        local position = getPositionByOrderHeader(field)
        sample[field] = row[position]
    end

    return sample
end

---@param state table
---@param dt number|nil
---@param lastSpeedKmh number|nil
---@param elapsedTime number|nil
---@return Sample|nil
function telemetry.getSampleFromCSP(state, dt, lastSpeedKmh, elapsedTime)
    if not state then
        return nil
    end

    ---@type number?
    local speedKmh = tonumber(state.speedKmh)
    if not speedKmh then
        return nil
    end

    ---@type number
    local time = (elapsedTime or 0) + (dt or 0)

    ---@type number
    local acceleration = 0
    if lastSpeedKmh and dt and dt > 0 then
        local speedMs = speedKmh / 3.6
        local lastSpeedMs = lastSpeedKmh / 3.6
        acceleration = (speedMs - lastSpeedMs) / dt
    end

    ---@type Sample
    local sample = {
        time = time,
        speed = speedKmh,
        acceleration = acceleration,
        braking = (tonumber(state.brake) or 0) > 0
    }

    return sample
end

return telemetry

