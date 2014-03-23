-- vendor libs
require 'vendor/AnAL'
local PrettyPrint = require 'vendor/lua-pretty-print/PrettyPrint'
local gamestate = require 'vendor/hump/gamestate'
local Camera = require 'vendor/hump/camera'
local Grid = require 'vendor/Jumper/jumper.grid'
local Pathfinder = require 'vendor/Jumper/jumper.pathfinder'

-- hack std
function math.clamp(x, min, max)
  if x < min then
    return min
  elseif x > max then
    return max
  else
    return x
  end
end

-- game modules
local utils = require 'utils'
local Scv = require 'units/scv'
local ux = require 'ux'

-- locals
local cam = nil
local map = nil
local game = {}
local entities = {}
local pather = nil

-- selection
local selx, sely = 0, 0
local selw, selh = 0, 0
local selection = {}

function game:init()
end

local function doTestPathfind( pather )
  local sx, sy = 1, 1
  local dx, dy = 1, 3

  local path, length = pather:getPath( sx, sy, dx, dy )
  if path then
    for node, count in path:nodes() do
      print( ('Step: %d - x: %d , y: %d'):format( count, node:getX(), node:getY() ) )
    end
  else
    print( "no path found!" )
  end
end

function game:enter()
  -- just the same map every time for now
  map = utils.buildMap( "art/maps/standard" )
  cam = Camera( 0, 0 )
  pather = Pathfinder( Grid( utils.buildCollisionMap( map ) ), 'ASTAR', 0 )
  pather:setMode( 'ORTHOGONAL' )
  doTestPathfind( pather )

  math.randomseed( os.time() )

  table.insert( entities, Scv:new( math.random( map.width ), math.random( map.height ) ) )
  table.insert( entities, Scv:new( math.random( map.width ), math.random( map.height ) ) )
  table.insert( entities, Scv:new( math.random( map.width ), math.random( map.height ) ) )
  table.insert( entities, Scv:new( math.random( map.width ), math.random( map.height ) ) )
  table.insert( entities, Scv:new( math.random( map.width ), math.random( map.height ) ) )
  table.insert( entities, Scv:new( math.random( map.width ), math.random( map.height ) ) )
end

function game:mousepressed( x, y, button )
  selx, sely = x, y
end

function game:mousereleased( x, y, button )
  selw, selh = x - selx, y - sely

  local min = 5 -- any selection rect smaller than this will be ignored

  if math.abs( selw ) < min or math.abs( selh ) < min then
    return
  end

  -- flip
  if selw < 0 then
    selw = selx - x
    selx = x
  end

  if selh < 0 then
    selh = sely - y
    sely = y
  end

  selx, sely = cam:worldCoords( selx, sely )
  selection = ux.select( selx, sely, selw, selh, entities, map )
  print( table.getn( selection ) )
end

function game:draw()
  cam:attach()
  -- draw map
  for y = 1, map.height do
    for x = 1, map.width do
      love.graphics.draw( map.tileset, map.tiles[ ( y - 1 ) * map.width + x ], ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight )
    end
  end

  -- draw entities
  for i, entity in ipairs( entities ) do
    entity.anim:draw( ( entity.x - 1 ) * map.tilewidth, ( entity.y - 1 ) * map.tileheight )
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
  end

  if love.mouse.getY() - margin <= 0 then
    cam:move( 0, -speed )
  elseif love.mouse.getY() + margin >= 600 then
    cam:move( 0, speed )
  end

  -- clamp camera so it doesn't go off map
  local cx, cy = cam:pos()

  cx = math.clamp( cx, 400, map.tilewidth * map.width - 400 )
  cy = math.clamp( cy, 300, map.tileheight * map.height - 300 )

  cam:lookAt( cx, cy )

  -- update entity anims
  for i, entity in ipairs( entities ) do
    entity.anim:update( dt )
    entity:updateAnim( 0, 0 )
  end
end

return game
