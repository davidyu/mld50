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
local Mineral = require 'doodads/mineral'
local ux = require 'ux'
local ai = require 'ai'

-- locals
local cam = nil
local map = nil
local fonts = {}
local game = {}
game.playermineralcount = 50
local minerals = {}
local entities = {}
local pather = nil

-- selection
local selx, sely = 0, 0
local selw, selh = 0, 0
local prevseltime = 0
local seltime = 0
local selection = {}

function game:init()
  fonts = {
    ["HUD"] = love.graphics.newFont( "art/fonts/PressStart2P.ttf", 8 );
  }
end

local function rebuildCollisionCache()
  map.occupied = {}

  for i, entity in ipairs( entities ) do
    if map.occupied[ entity.x + ( entity.y - 1 ) * map.width ] == nil then
      map.occupied[ entity.x + ( entity.y - 1 ) * map.width ] = { entity }
    else
      table.insert( map.occupied[ entity.x + ( entity.y - 1 ) * map.width ], entity )
    end
  end

  for i, mineral in ipairs( minerals ) do
    map.occupied[ mineral.x + ( mineral.y - 1 ) * map.width ] = { mineral }
  end

  pather:setGrid( Grid( utils.buildCollisionMap( map ) ) )
end

function game:enter()
  -- just the same map every time for now
  map = utils.buildMap( "art/maps/standard" )
  table.foreach( map.minerals, function( _, pos )
                                 table.insert( minerals, Mineral:new( pos.x, pos.y, math.random( 500 ) + 500 ) )
                               end )

  cam = Camera( 0, 0 )
  ux.init()

  pather = Pathfinder( Grid( utils.buildCollisionMap( map ) ), 'ASTAR', 0 )
  pather:setMode( 'ORTHOGONAL' )

  math.randomseed( os.time() )

  local basex, basey = 1, 1
  for i = 1, 5 do
    local newx, newy = basex + math.random( 5 ), basey + math.random( 5 )
    while newx > map.width or newy > map.height do
      newx, newy = basex + math.random( 5 ), basey + math.random( 5 )
    end
    table.insert( entities, Scv:new( newx, newy ) )
  end

  basex, basey = 10, 10 -- math.random( map.width - 5 ), math.random( map.height - 5 )
  for i = 1, 20 do
    local newx, newy = basex + math.random( 5 ), basey + math.random( 5 )
    while newx > map.width or newy > map.height do
      newx, newy = basex + math.random( 5 ), basey + math.random( 5 )
    end
    table.insert( entities, Scv:new( newx, newy, 1 ) )
  end
end

function game:mousepressed( x, y, button )
  selx, sely = x, y
  prevseltime = seltime
  seltime = love.timer.getTime()
end

function game:mousereleased( x, y, button )
  -- right click
  if button == 'r' then
    -- set target
    local wx, wy = cam:worldCoords( x, y )
    local tx = math.floor( wx / map.tilewidth ) + 1
    local ty = math.floor( wy / map.tileheight ) + 1
    if map.occupied[ tx + ( ty - 1 ) * map.width ] ~= nil then
      local target = map.occupied[ tx + ( ty - 1 ) * map.width ][1]
      if target.owner ~= nil and target.owner ~= 0 then
        table.foreach( selection, function( _, entity )
                                    entity.target = target
                                    entity.targetcommand = 'attack'
                                  end )
      else
        local targettype = target.__index
        table.foreach( selection, function( _, entity )
                                    if entity.friendlytargets[ targettype ] then
                                      entity.target = target
                                      entity.targetcommand = 'repair'
                                    elseif targettype == Mineral then
                                      entity.target = target
                                      entity.targetcommand = 'mine'
                                    end
                                  end )
      end
    else
      -- clear target
      table.foreach( selection, function( _, entity ) entity.target = nil end )
      -- set move target
      table.foreach( selection, function( _, entity )
                                  entity.tx = tx
                                  entity.ty = ty
                                end )
    end
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
    if seltime - prevseltime < 0.5 then
      -- double click, select all units of type
      if table.maxn( selection ) > 0 then
        local type = selection[1].__index
        local originalentity = selection[1]
        for i, entity in ipairs( entities ) do
          if entity.__index == type and entity.owner == 0 and entity ~= originalentity then
            table.insert( selection, entity )
          end
        end
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

  -- draw minerals
  for _, mineral in ipairs( minerals ) do
    love.graphics.draw( Mineral.sheet, Mineral.quad, ( mineral.x - 1 ) * map.tilewidth, ( mineral.y - 1 ) * map.tileheight )
  end

  -- draw entities and entity-attached UI
  for i, entity in ipairs( entities ) do
    if entity.selected then
      ux.drawSelection( ( entity.x - 1 ) * map.tilewidth, ( entity.y - 1 ) * map.tileheight )
      ux.drawHealth( entity.health, entity.maxhealth, ( entity.x - 1 ) * map.tilewidth, ( entity.y - 1 ) * map.tileheight )
    end
    local r,g,b,a = love.graphics.getColor()
    if entity.owner ~= 0 then
      love.graphics.setColor( 0, 95, 146 )
    else
      love.graphics.setColor( 244, 35, 74 )
    end
    love.graphics.rectangle( 'fill', ( entity.x - 1 ) * map.tilewidth + 16, ( entity.y - 1 ) * map.tileheight, 32, 32 )
    love.graphics.setColor( r,g,b,a )
    entity.anim:draw( ( entity.x - 1 ) * map.tilewidth, ( entity.y - 1 ) * map.tileheight )
  end

  -- draw FOW
  local r,g,b,a = love.graphics.getColor()
  for y = 1, map.height do
    for x = 1, map.width do
      if map.fow[ ( y - 1 ) * map.width + x ] == nil then
        love.graphics.setColor( 0, 0, 0, 255 )
        love.graphics.rectangle( 'fill', ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight, 64, 64 )
      elseif map.fow[ ( y - 1 ) * map.width + x ] == true then
        love.graphics.setColor( 0, 0, 0, 144 )
        love.graphics.rectangle( 'fill', ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight, 64, 64 )
      end
    end
  end
  love.graphics.setColor( r,g,b,a )

  cam:detach()

  -- draw HUD UI
  if love.mouse.isDown( 'l' ) then
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor( 12, 192, 57 )

    love.graphics.rectangle( 'line', selx, sely, love.mouse.getX() - selx, love.mouse.getY() - sely )
    love.graphics.setColor( r,g,b,a )
  end

  -- resource overlay
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor( 0, 0, 0, 128 )
  love.graphics.rectangle( "fill", 545, 5, 80, 28 )
  love.graphics.setColor( 255, 255, 255, 255 )
  love.graphics.setFont( fonts["HUD"] )
  love.graphics.print( "MINERALS: " .. game.playermineralcount, 650, 10 )
  love.graphics.setColor( r, g, b, a )
end

function game:update( dt )
  -- backend
  ai.update( entities, map )

  -- reset FOW
  for k, v in pairs( map.fow ) do
    if v == false then
      map.fow[ k ] = true
    end
  end

  -- clear FOW
  for i, entity in ipairs( entities ) do
    -- clear FOW within the viewing range of all friendly units
    if entity.owner == 0 then
      for i = 0, entity.sight do
        for j = 0, entity.sight - i do
          map.fow[ entity.x + i + ( entity.y - 1 - j ) * map.width ] = false
          map.fow[ entity.x - i + ( entity.y - 1 + j ) * map.width ] = false
          map.fow[ entity.x + i + ( entity.y - 1 + j ) * map.width ] = false
          map.fow[ entity.x - i + ( entity.y - 1 - j ) * map.width ] = false
        end
      end
    end
  end

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
    entity:update( game, pather, map, dt )
    -- update anim module
    entity.anim:update( dt )
  end

  for i, entity in ipairs( entities ) do
    if entity.health == 0 then table.remove( entities, i ) end
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
