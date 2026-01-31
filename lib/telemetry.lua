-- telemetry.lua

local telemetry = {}

---@class Sample
---@field time number
---@field speed number
---@field acceleration number

local Fields = {
    "time",
    "speed",
    "acceleration"
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

---@param header string[]
---@param onValid fun(field:string, position:integer)|nil
---@return boolean
function telemetry.validateHeader(header, onValid)
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

return telemetry

