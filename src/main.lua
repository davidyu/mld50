local gamestate = require 'vendor/hump/gamestate'

-- public gamestates
menu = require 'menu'
game = require 'game'

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
