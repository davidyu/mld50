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

function ux.drawHealth( health, maxhealth, x, y )
  local r, g, b, a = love.graphics.getColor()
  local normalizedhealth = health / maxhealth

  if normalizedhealth < 0.66 then
    love.graphics.setColor( 214, 0, 96 )
  elseif normalizedhealth < 0.33 then
    love.graphics.setColor( 242, 165, 55 )
  else -- full health
    love.graphics.setColor( 12, 192, 57 )
  end

  love.graphics.rectangle( 'fill', x + 16, y - 8, 32 * normalizedhealth, 5 )
  love.graphics.setColor( 0, 0, 0 )
  love.graphics.rectangle( 'line', x + 16, y - 8, 32, 5 )

  love.graphics.setColor( r, g, b, a )
end

return ux
