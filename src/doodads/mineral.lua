local mineral = {}
mineral.__index = mineral

-- same static image; no need to keep it in instance table
mineral.sheet = love.graphics.newImage( "art/doodads/doodads_ref_tilesheet.png" )
mineral.quad = love.graphics.newQuad( 128, 0, 64, 64, mineral.sheet:getWidth(), mineral.sheet:getHeight() )

function mineral:new( x, y, amount )
  return setmetatable( {
    x = x or 0,
    y = y or 0,
    amount = amount or 1000
  }, mineral )
end

return mineral
