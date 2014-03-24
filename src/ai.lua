local ai = {}

function ai.update( entities, map )
  for i, entity in ipairs( entities ) do
    if entity.owner ~= 0 then -- not owner
      if table.maxn( entity.pathtable ) == 0 then
        entity.ty, entity.tx = math.random( map.width ), math.random( map.height )
      end
    end
  end
end

return ai
