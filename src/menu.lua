local menu = {}

local gamestate = require 'vendor/hump/gamestate'
local game = require 'game'

function menu:enter()
  -- temp, push to game immediately
  gamestate.switch( game )
end

function menu:draw()
end

function menu:update( dt )
end

return menu
