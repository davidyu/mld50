local utils = require 'utils'
local gamestate = require 'vendor/hump/gamestate'

local map = nil
local game = {}

function game:init()
end

function game:enter()
  map = utils.buildMap( "art/maps/standard" )
  print( map.height )
end

function game:draw()
  print( "draw" )
  -- draw map
  for y = 1, map.height do
    for x = 1, map.width do
      love.graphics.draw( map.tileset, map.tiles[ ( y - 1 ) * map.width + x ], ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight )
    end
  end
end

function game:update( dt )
  print( "update" )
end

return game
