local lu = require("luaunit")

local function newVec2(x, y)
    return setmetatable({ x = x, y = y }, {
        __add = function(a, b)
            return newVec2(a.x + b.x, a.y + b.y)
        end,
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

local function reloadUI()
    package.loaded["lib.ui"] = nil
    return require("lib.ui")
end

TestUI = {}

function TestUI:setUp()
    self.calls = {}

    _G.vec2 = newVec2
    _G.rbgm = function(r, g, b, a)
        return { r = r, g = g, b = b, a = a }
    end

    -- ui.drawApp currently reads a global "textSize".
    _G.textSize = newVec2(100, 20)

    self.ui = reloadUI()

    self.ui.calcTextSize = function(text)
        table.insert(self.calls, { fn = "calcTextSize", text = text })
        return newVec2(100, 20)
    end

    self.ui.drawRectFilled = function(from, to, color)
        table.insert(self.calls, { fn = "drawRectFilled", from = from, to = to, color = color })
    end

    self.ui.drawRect = function(from, to, color, rounding, thickness)
        table.insert(self.calls, {
            fn = "drawRect",
            from = from,
            to = to,
            color = color,
            rounding = rounding,
            thickness = thickness,
        })
    end

    self.ui.setCursor = function(pos)
        table.insert(self.calls, { fn = "setCursor", pos = pos })
    end

    self.ui.text = function(text)
        table.insert(self.calls, { fn = "text", text = text })
    end
end

function TestUI:tearDown()
    package.loaded["lib.ui"] = nil
    _G.vec2 = nil
    _G.rbgm = nil
    _G.textSize = nil
end

function TestUI:testDrawAppActivePathRendersBorderAndText()
    local pos = newVec2(5, 7)

    self.ui.drawApp(pos, "Brake", true)

    lu.assertEquals(self.calls[1].fn, "calcTextSize")
    lu.assertEquals(self.calls[2].fn, "drawRect")
    lu.assertEquals(self.calls[3].fn, "setCursor")
    lu.assertEquals(self.calls[4].fn, "text")

    lu.assertEquals(self.calls[2].to.x, 125)
    lu.assertEquals(self.calls[2].to.y, 39)
    lu.assertEquals(self.calls[3].pos.x, 15)
    lu.assertEquals(self.calls[3].pos.y, 13)
end

function TestUI:testDrawAppInactivePathAlsoDrawsBackground()
    local pos = newVec2(0, 0)

    self.ui.drawApp(pos, "Brake", false)

    lu.assertEquals(self.calls[1].fn, "calcTextSize")
    lu.assertEquals(self.calls[2].fn, "drawRectFilled")
    lu.assertEquals(self.calls[3].fn, "drawRect")
    lu.assertEquals(self.calls[4].fn, "setCursor")
    lu.assertEquals(self.calls[5].fn, "text")
end

