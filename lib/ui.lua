-- ui.lua

local ui = {}

---@type table
local colors = {
    OPAQUE_RED = rbgm(1,0,0,1),
    TRSNALUCENT_GRAY = rbgm(0.5,0.5,0.5,0.5),
}

---@param pos table
---@param text string
---@param isActive boolean
function ui.drawApp(pos, text, isActive)
    ---@type vec2
    local padding = vec2(10, 6)

    ---@type vec2
    local testSize = ui.calcTextSize(text)

    ---@type vec2
    local size = textSize + padding * 2

    ---@type rgbm
    local color = isActive and colors.OPAQUE_RED or colors.TRANSLUCENT_GRAY

    if not isActive then
        ui.drawRectFilled(pos, pos + size, rbgm(0,0,0,0))
    end

    ui.drawRect(pos, pos + size, color, 0, 2)
    ui.setCursor(pos + padding)
    ui.text(text)
end

return ui

