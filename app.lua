-- app.lua


---@diagnostic disable: undefined-global

script = script or {}

local app = {}


--> App lifecycle

function script.onShow()
  print('App shown')
end

function script.onHide()
  print('App hidden')
end


--> Update loop

function script.update(dt)
  -- dt = delta time (seconds)
end


--> UI rendering

function script.drawUI()
  ui.text('Hello CSP')
end


return app

