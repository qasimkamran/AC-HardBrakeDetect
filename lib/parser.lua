-- parser.lua

local parser = {}

---@class FileType
---@type FileType
local FileType = {
    CSV = 0
}

---@class Options
---@field delimiter string|nil
---@field headers boolean

---@type Options
local Options = {
    delimiter = nil,
    headers = false
}

---@param type integer
local function setOptions(type)
    if type == FileType.CSV then
        Options.delimiter = ","
        Options.headers = true
    end
end

---@param filepath string
---@return string|nil
local function getFileData(filepath)
    local file = io.open(filepath, "r")

    if not file then
        return nil
    end

    local data = file:read("*a")

    file:close()

    return data
end

---@param row string[]
---@param field string[]
local function pushField(row, field)
    row[#row + 1] = table.concat(field)
end

---@param rows string[][]
---@param row string[]
local function pushRow(rows, row)
    if #row > 0 or #rows == 0 then
      rows[#rows + 1] = row
    end
end

---@param data string
---@return string[][]|nil
function parser.parseCSV(data)
    setOptions(FileType.CSV)

    if not data then
        return nil
    end

    if not Options.delimiter then
        return nil
    end

    ---@type string[][]
    local rows = {}

    ---@type string[]
    local row = {}
    local field = {}

    ---@type boolean
    local inQuotes = false

    ---@type string
    local quote = '"'

    ---@type integer
    local i, n = 1, #data
    while i <= n do
        ---@type string
        local c = data:sub(i, i)

        if c == quote then
            if inQuotes and data.sub(i + 1, i + 1) == quote then
                field[#field + 1] = quote
                i = i + 1
            else
                inQuotes = not inQuotes
            end

        elseif
            c == Options.delimiter and not inQuotes then
            pushField(row, field)
            field = {}

        elseif (c == '\n' or c == '\r') and not inQuotes then
            if c == '\r' and data:sub(i + 1, i + 1) == '\n' then
                i = i + 1
            end
            pushField(row, field)
            pushRow(rows, row)
            field = {}
            row = {}

        else
            field[#field + 1] = c
        end

        i = i +1
    end

    if inQuotes then
        error("Unclosed quote encountered")
    end

    if #field > 0 or #row > 0 then
        pushField(row, field)
        pushRow(rows, row)
    end

    return rows
end

return parser
