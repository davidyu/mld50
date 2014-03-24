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
local ai = require 'ai'

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

local function rebuildCollisionCache()
  map.occupied = {}

  for i, entity in ipairs( entities ) do
    if map.occupied[ entity.x + ( entity.y - 1 ) * map.width ] == nil then
      map.occupied[ entity.x + ( entity.y - 1 ) * map.width ] = 1
    else
      map.occupied[ entity.x + ( entity.y - 1 ) * map.width ] = map.occupied[ entity.x + ( entity.y - 1 ) * map.width ] + 1
    end
  end

  pather:setGrid( Grid( utils.buildCollisionMap( map ) ) )
end

function game:enter()
  -- just the same map every time for now
  map = utils.buildMap( "art/maps/standard" )
  cam = Camera( 0, 0 )
  ux.init()

  pather = Pathfinder( Grid( utils.buildCollisionMap( map ) ), 'ASTAR', 0 )
  pather:setMode( 'ORTHOGONAL' )

  math.randomseed( os.time() )

  for i = 1, 20 do
    table.insert( entities, Scv:new( math.random( map.width ), math.random( map.height ) ) )
  end

  for i = 1, 50 do
    table.insert( entities, Scv:new( math.random( map.width ), math.random( map.height ), 1 ) )
  end
end

function game:mousepressed( x, y, button )
  selx, sely = x, y
end

function game:mousereleased( x, y, button )
  if button == 'r' then
    -- set target
    local wx, wy = cam:worldCoords( x, y )
    local tx = math.floor( wx / map.tilewidth ) + 1
    local ty = math.floor( wy / map.tileheight ) + 1
    table.foreach( selection, function( _, entity )
                                entity.tx = tx
                                entity.ty = ty
                              end )
    return
  end

  -- left-click
  selw, selh = x - selx, y - sely

  local min = 5 -- any selection rect smaller than this will be (sort of) ignored

  if math.abs( selw ) < min or math.abs( selh ) < min then
    -- we'll see if there's a unit under the mouse cursor
    local x, y = cam:worldCoords( selx, sely )
    table.foreach( selection, function( _, entity ) entity.selected = false end )
    for i, entity in ipairs( entities ) do
      if ( entity.x - 1 ) * map.tilewidth <= x and ( entity.y - 1 ) * map.tileheight <= y and ( entity.x ) * map.tilewidth >= x and ( entity.y ) * map.tileheight >= y then
        selection = {}
        table.insert( selection, entity )
        break
      end
    end
    table.foreach( selection, function( _, entity ) entity.selected = true end )
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
  table.foreach( selection, function( _, entity ) entity.selected = false end )
  selection = ux.accselect( selx, sely, selw, selh, entities, map )
  table.foreach( selection, function( _, entity ) entity.selected = true end )
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
    if entity.selected then
      ux.drawSelection( ( entity.x - 1 ) * map.tilewidth, ( entity.y - 1 ) * map.tileheight )
    end
    local r,g,b,a = love.graphics.getColor()
    if entity.owner ~= 0 then
      love.graphics.setColor( 159, 189, 77 )
    else
      love.graphics.setColor( 82, 211, 190 )
    end
    love.graphics.rectangle( 'fill', ( entity.x - 1 ) * map.tilewidth + 16, ( entity.y - 1 ) * map.tileheight, 32, 32 )
    love.graphics.setColor( r,g,b,a )
    entity.anim:draw( ( entity.x - 1 ) * map.tilewidth, ( entity.y - 1 ) * map.tileheight )
  end
  cam:detach()
end

function game:update( dt )
  -- backend
  ai.update( entities, map )

  -- user facing
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

  -- update entities
  for i, entity in ipairs( entities ) do
    entity:update( pather, map, dt )
    -- update anim module
    entity.anim:update( dt )
  end

  -- update map occupied cache
  rebuildCollisionCache()

  -- resolve same-tile collisions
  for i, entity in ipairs( entities ) do
    -- update anim module
    entity:postupdate( pather, map )
  end

  -- update map occupied cache after collision resolve
  rebuildCollisionCache()

end

return game
