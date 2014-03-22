-- modules
local utils = require 'utils'
local gamestate = require 'vendor/hump/gamestate'
local Camera = require 'vendor/hump/camera'

local cam = nil
local map = nil
local game = {}
local selection = {}

function game:init()
end

function game:enter()
  -- just the same map every time for now
  map = utils.buildMap( "art/maps/standard" )
  cam = Camera( 0, 0 )
end

function game:draw()
  cam:attach()
  -- draw map
  for y = 1, map.height do
    for x = 1, map.width do
      love.graphics.draw( map.tileset, map.tiles[ ( y - 1 ) * map.width + x ], ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight )
    end
  end
  cam:detach()
end

function game:update( dt )
  -- update camera
  local margin = 30
  local speed = 10
  if love.mouse.getX() - margin <= 0 then
    cam:move( -speed, 0 )
  elseif love.mouse.getX() + margin >= 800 then
    cam:move( speed, 0 )
  elseif love.mouse.getY() - margin <= 0 then
    cam:move( 0, -speed )
  elseif love.mouse.getY() + margin >= 600 then
    cam:move( 0, speed )
  end

  local cx, cy = cam:pos()
  if cx < 0 then
    cam:lookAt( 0, cy )
  end

  if cy < 0 then
    cam:lookAt( cx, 0 )
  end

  if cx > map.tilewidth * map.width then
    cam:lookAt( map.tilewidth * map.width, cy )
  end

  if cy > map.tileheight * map.height then
    cam:lookAt( cx, map.tileheight * map.height )
  end
end

return game
