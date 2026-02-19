-- ui.lua

local appUi = {}

---@type table
local colors = {
    OPAQUE_RED = rgbm(1,0,0,1),
    TRANSLUCENT_GRAY = rgbm(0.5,0.5,0.5,0.5),
}

---@param value any
---@param lineHeight number
---@return vec2
local function toVec2(value, lineHeight)
    if type(value) == "number" then
        return vec2(value, lineHeight)
    end
    if value then
        local okX, x = pcall(function() return value.x end)
        local okY, y = pcall(function() return value.y end)
        if okX and okY and type(x) == "number" and type(y) == "number" then
            return vec2(x, y)
        end
    end
    return vec2(0, lineHeight)
end

---@param text string
---@return vec2
local function getTextSize(text)
    local lineHeight = (ui and ui.getLineHeight and ui.getLineHeight()) or 14

    if ui and ui.calcTextSize then
        return toVec2(ui.calcTextSize(text), lineHeight)
    end
    if ui and ui.measureText then
        return toVec2(ui.measureText(text), lineHeight)
    end
    return vec2(#tostring(text) * 7, lineHeight)
end

---@param pos table
---@param text string
---@param isActive boolean
function appUi.drawApp(pos, text, isActive)
    local hasTitleFont = ui and ui.pushFont and ui.popFont and ui.Font and ui.Font.Title

    ---@type vec2
    local padding = vec2(10, 6)

    local useTitleFont = hasTitleFont
    local textSize
    if useTitleFont then
        ui.pushFont(ui.Font.Title)
        textSize = getTextSize(text)
        ui.popFont()
    else
        textSize = getTextSize(text)
    end

    local size = textSize + padding * 2

    local windowWidth = (ui and ui.windowWidth and ui.windowWidth()) or nil
    local windowHeight = (ui and ui.windowHeight and ui.windowHeight()) or nil

    if windowWidth and windowHeight and useTitleFont then
        local titleFits = (size.x <= windowWidth - 2) and (size.y <= windowHeight - 2)
        if not titleFits then
            useTitleFont = false
            textSize = getTextSize(text)
            size = textSize + padding * 2
        end
    end

    local drawPos = vec2(pos.x - size.x * 0.5, pos.y - size.y * 0.5)

    ---@type rgbm
    local color = isActive and colors.OPAQUE_RED or colors.TRANSLUCENT_GRAY

    if not isActive then
        ui.drawRectFilled(drawPos, drawPos + size, rgbm(0,0,0,0))
    end

    ui.drawRect(drawPos, drawPos + size, color, 0, 2)
    local textOffset = vec2(
        math.max(0, (size.x - textSize.x) * 0.5),
        math.max(0, (size.y - textSize.y) * 0.5)
    )
    ui.setCursor(drawPos + textOffset)

    if useTitleFont then
        ui.pushFont(ui.Font.Title)
    end
    ui.text(text)
    if useTitleFont then
        ui.popFont()
    end
end

return appUi

