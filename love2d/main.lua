require('lib/32linesofgoodness')
require("lib/postshader")
nodeManager = require("node")
require("lib/text_gui")

function love.load()
	nodeManager.init()
  text_gui.load()
end

function love.update(dt)
	nodeManager.update(dt)
end

function love.draw()
	nodeManager.draw()
  text_gui.draw()
end

function love.keypressed(key, scancode, isrepeat)
	nodeManager.keypressed(key)
  if key == "escape" then
    love.event.quit(0)
  end
  -- text box
  -- using the anykey for now, but this could be constrained to certain keys
  if not text_gui.textboxvar then
    -- makes the game go to the next text box
    text_gui.textbox_index = text_gui.textbox_index + 1
  end
  -- choice box
  if key == "up" and text_gui.navigate_choices then
    text_gui.navigate_choices(1)
  end
  if key == "down" and text_gui.navigate_choices then
    text_gui.navigate_choices(-1)
  end
  if key == "return" then
    text_gui.choice_made = true
  end
end

function love.keyreleased(key)

end

function love.textinput(text)
	nodeManager.textinput(text)
end

function love.mousepressed(x, y, button)
	nodeManager.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	nodeManager.mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
	nodeManager.mousemoved(x, y, dx, dy)
end

function love.wheelmoved(x, y)
	nodeManager.wheelmoved(x, y)
end