local utils = {}
local PrettyPrint = require 'vendor/lua-pretty-print/PrettyPrint'

function utils.buildCollisionMap( map )
  local colMap = {}
  local x, y = 1, 1
  table.insert( colMap, {} )
  for i, impass in ipairs( map.impassable ) do
    local col = 0
    if impass then col = 1 end
    if map.occupied[i] ~= nil then col = 1 end
    table.insert( colMap[y], col )

    x = x + 1
    if i % map.width == 0 and ( i / map.width ) < map.height then
      y = y + 1
      table.insert( colMap, {} )
      x = 1
    end
  end
  return colMap
end

function utils.buildMap( path )
  assert( love.filesystem.exists( path .. ".lua" ),
          "the level " .. path .. "does not exist!" )
  local mapdata = love.filesystem.load( path .. ".lua" )() -- executable output from tmx2lua
  local map = {}
  map.name = path
  map.width = mapdata.width
  map.height = mapdata.height
  map.tilewidth = mapdata.tilewidth
  map.tileheight = mapdata.tileheight
  map.occupied = {}
  map.fow = {}

  map.tileset = love.graphics.newImage( mapdata.tilesets[1].image.source )
  for i, tilelayer in ipairs( mapdata.tilelayers ) do
    if tilelayer.name == 'base' then
      map.tiles = {}
      map.impassable = {}
      local tilesetwidth = mapdata.tilesets[1].image.width / mapdata.tilesets[1].tilewidth
      for j, tile in ipairs( tilelayer.tiles ) do
        local tx = ( tilelayer.tiles[j].id % tilesetwidth ) * map.tilewidth
        local ty = math.floor( tilelayer.tiles[j].id / tilesetwidth ) * map.tileheight
        map.tiles[j] = love.graphics.newQuad( tx, ty, mapdata.tilewidth, mapdata.tileheight, mapdata.tilesets[1].image.width, mapdata.tilesets[1].image.height )
        map.impassable[j] = tilelayer.tiles[j].id == 1 -- LOL
      end
    elseif tilelayer.name == 'doodads' then
      map.spawn = {}
      map.indicators = {}
      for j, tile in ipairs( tilelayer.tiles ) do
        if tile then
          local x = ( j - 1 ) % mapdata.width + 1
          local y = math.floor( ( j -  1 ) / mapdata.width ) + 1
          if tile.id == 0 then -- spawn
            table.insert( map.spawn, { x = x, y = y } )
          end
        end
      end
    end
  end
  return map
end

return utils
