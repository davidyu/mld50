local ux = {}

function ux.init()
  ux.selectsprite = love.graphics.newImage( "art/ui/selection.png" )
end

function ux.accselect( x, y , w, h, entities, map )
  -- print( ( "%d %d %d %d"):format( x, y, w, h ) )
  local selections = {}
  for i, entity in ipairs( entities ) do
    -- print( ( "%d %d"):format( ( entity.x - 1 ) * map.tilewidth, ( entity.y - 1 ) * map.tileheight ) )
    if ( entity.x - 1 ) * map.tilewidth >= x and ( entity.y - 1 ) * map.tileheight >= y and ( entity.x - 1 ) * map.tilewidth <= x + w and ( entity.y - 1 ) * map.tileheight <= y + h then
      table.insert( selections, entity )
    end
  end
  return selections
end

function ux.drawSelection( x, y, size )
  love.graphics.draw( ux.selectsprite, x + 16, y + 20 )
end

return ux
