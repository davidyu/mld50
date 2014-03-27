local ai = {}

function ai.update( entities, map )
  for i, entity in ipairs( entities ) do
    -- dumb "wait" action
    if math.random( 10 ) > 6 then
      -- don't do anything
    else
      -- smart logic
      if entity.owner ~= 0 then -- not owner
        target = nil
        for ii, ee in ipairs( entities ) do
          if ee.owner == 0 and math.abs( ee.x - entity.x ) + math.abs( ee.y - entity.y ) < 10 then
            -- seek and destroy!
            target = ee
          end
        end

        if target ~= nil and entity.health / entity.maxhealth > 0.4 then
          entity.target = target
          entity.targetcommand = 'attack'
        else -- run!!!
          if table.maxn( entity.pathtable ) == 0 then
            entity.ty, entity.tx = math.random( map.width ), math.random( map.height )
          end
        end
      end
    end
  end
end

return ai
