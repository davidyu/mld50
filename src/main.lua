local gamestate = require 'vendor/hump/gamestate'

-- public gamestates
menu = require 'menu'

function love.load()
  love.window.setMode( 800, 600 )
  love.window.setTitle( "Starplane" )
  gamestate.push( menu )
end

function love.keypressed( key, code )
  gamestate.keypressed( key, code )
end

function love.update( dt )
  gamestate.update( dt )
end

function love.draw()
  gamestate.draw()
end

function love.mousepressed( x, y, button )
  gamestate.mousepressed( x, y, button )
end

function love.mousereleased( x, y, button )
  gamestate.mousereleased( x, y, button )
end
