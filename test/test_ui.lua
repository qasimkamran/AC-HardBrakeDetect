---@type table
local lu = require("luaunit")

---@param x number
---@param y number
---@return table
local function newVec2(x, y)
    ---@type table
    return setmetatable({ x = x, y = y }, {
        ---@param a table
        ---@param b table
        ---@return table
        __add = function(a, b)
            return newVec2(a.x + b.x, a.y + b.y)
        end,
        ---@param a table|number
        ---@param b table|number
        ---@return table
        __mul = function(a, b)
            if type(a) == "table" and type(b) == "number" then
                return newVec2(a.x * b, a.y * b)
            end
            if type(a) == "number" and type(b) == "table" then
                return newVec2(a * b.x, a * b.y)
            end
            error("Unsupported vec2 multiplication")
        end,
    })
end

---@return table
local function reloadUI()
    package.loaded["lib.ui"] = nil
    return require("lib.ui")
end

---@type table
TestUI = {}

function TestUI:setUp()
    ---@type table[]
    self.calls = {}

    _G.vec2 = newVec2
    ---@param r number
    ---@param g number
    ---@param b number
    ---@param a number
    ---@return table
    _G.rgbm = function(r, g, b, a)
        return { r = r, g = g, b = b, a = a }
    end

    self.currentFont = nil
    self.baseTextSize = newVec2(100, 20)
    self.titleTextSize = newVec2(240, 80)

    _G.ui = {
        calcTextSize = function(text)
            table.insert(self.calls, { fn = "calcTextSize", text = text, font = self.currentFont })
            if self.currentFont == "Title" then
                return self.titleTextSize
            end
            return self.baseTextSize
        end,
        drawRectFilled = function(from, to, color)
            table.insert(self.calls, { fn = "drawRectFilled", from = from, to = to, color = color })
        end,
        drawRect = function(from, to, color, rounding, thickness)
            table.insert(self.calls, {
                fn = "drawRect",
                from = from,
                to = to,
                color = color,
                rounding = rounding,
                thickness = thickness,
            })
        end,
        setCursor = function(pos)
            table.insert(self.calls, { fn = "setCursor", pos = pos })
        end,
        text = function(text)
            table.insert(self.calls, { fn = "text", text = text })
        end,
    }

    ---@type table
    self.appUi = reloadUI()
end

function TestUI:tearDown()
    package.loaded["lib.ui"] = nil
    _G.vec2 = nil
    _G.rgbm = nil
    _G.ui = nil
end

function TestUI:testDrawAppActivePathRendersBorderAndText()
    ---@type table
    local pos = newVec2(100, 50)

    self.appUi.drawApp(pos, "Brake", true)

    lu.assertEquals(self.calls[1].fn, "calcTextSize")
    lu.assertEquals(self.calls[2].fn, "drawRect")
    lu.assertEquals(self.calls[3].fn, "setCursor")
    lu.assertEquals(self.calls[4].fn, "text")
    lu.assertEquals(self.calls[2].color.r, 1)
    lu.assertEquals(self.calls[2].color.g, 0)
    lu.assertEquals(self.calls[2].color.b, 0)
    lu.assertEquals(self.calls[2].color.a, 1)

    lu.assertEquals(self.calls[2].from.x, 40)
    lu.assertEquals(self.calls[2].from.y, 34)
    lu.assertEquals(self.calls[2].to.x, 160)
    lu.assertEquals(self.calls[2].to.y, 66)
    lu.assertEquals(self.calls[3].pos.x, 50)
    lu.assertEquals(self.calls[3].pos.y, 40)
end

function TestUI:testDrawAppInactivePathAlsoDrawsBackground()
    ---@type table
    local pos = newVec2(0, 0)

    self.appUi.drawApp(pos, "Brake", false)

    lu.assertEquals(self.calls[1].fn, "calcTextSize")
    lu.assertEquals(self.calls[2].fn, "drawRectFilled")
    lu.assertEquals(self.calls[3].fn, "drawRect")
    lu.assertEquals(self.calls[4].fn, "setCursor")
    lu.assertEquals(self.calls[5].fn, "text")
    lu.assertEquals(self.calls[2].color.r, 0)
    lu.assertEquals(self.calls[2].color.g, 0)
    lu.assertEquals(self.calls[2].color.b, 0)
    lu.assertEquals(self.calls[2].color.a, 0)
end

function TestUI:testDrawAppFallsBackFromTitleFontWhenWindowTooSmall()
    _G.ui.Font = { Title = "Title" }
    _G.ui.pushFont = function(font)
        self.currentFont = font
        table.insert(self.calls, { fn = "pushFont", font = font })
    end
    _G.ui.popFont = function()
        self.currentFont = nil
        table.insert(self.calls, { fn = "popFont" })
    end
    _G.ui.windowWidth = function()
        return 160
    end
    _G.ui.windowHeight = function()
        return 80
    end

    self.appUi.drawApp(newVec2(80, 40), "Brake", true)

    lu.assertEquals(self.calls[1].fn, "pushFont")
    lu.assertEquals(self.calls[2].fn, "calcTextSize")
    lu.assertEquals(self.calls[2].font, "Title")
    lu.assertEquals(self.calls[3].fn, "popFont")
    lu.assertEquals(self.calls[4].fn, "calcTextSize")
    lu.assertNil(self.calls[4].font)
    lu.assertEquals(self.calls[#self.calls - 1].fn, "setCursor")
    lu.assertEquals(self.calls[#self.calls].fn, "text")
end

function TestUI:testDrawAppUsesTitleFontWhenItFits()
    self.titleTextSize = newVec2(90, 18)
    _G.ui.Font = { Title = "Title" }
    _G.ui.pushFont = function(font)
        self.currentFont = font
        table.insert(self.calls, { fn = "pushFont", font = font })
    end
    _G.ui.popFont = function()
        self.currentFont = nil
        table.insert(self.calls, { fn = "popFont" })
    end
    _G.ui.windowWidth = function()
        return 400
    end
    _G.ui.windowHeight = function()
        return 200
    end

    self.appUi.drawApp(newVec2(100, 50), "Brake", true)

    lu.assertEquals(self.calls[1].fn, "pushFont")
    lu.assertEquals(self.calls[2].fn, "calcTextSize")
    lu.assertEquals(self.calls[3].fn, "popFont")
    lu.assertEquals(self.calls[#self.calls - 2].fn, "pushFont")
    lu.assertEquals(self.calls[#self.calls - 1].fn, "text")
    lu.assertEquals(self.calls[#self.calls].fn, "popFont")
end
