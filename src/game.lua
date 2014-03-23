-- vendor libs
require 'vendor/AnAL'
local PrettyPrint = require 'vendor/lua-pretty-print/PrettyPrint'
local gamestate = require 'vendor/hump/gamestate'
local Camera = require 'vendor/hump/camera'
local Grid = require 'vendor/Jumper/jumper.grid'
local Pathfinder = require 'vendor/Jumper/jumper.pathfinder'

-- game modules
local utils = require 'utils'
local Scv = require 'units/scv'

-- locals
local cam = nil
local map = nil
local game = {}
local selection = {}
local entities = {}
local pather = nil

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

local function makeSelection( x, y, w, h )
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

  -- update entity anims
  for i, entity in ipairs( entities ) do
    entity.anim:update( dt )
    entity:updateAnim( 0, 0 )
  end
end

return game
