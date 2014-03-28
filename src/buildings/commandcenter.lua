local commandcenter = {}
commandcenter.__index = commandcenter

function commandcenter:new( x, y, owner )
  return setmetatable( {
    x = x or 0,
    y = y or 0,
    owner = owner or 0,
    buildqueue = {},
    buildtimes = {
      ["scv"] = 10
    },
    time = 0
  }, commandcenter )
end

function enqueueunit( unit )
  assert( unit.__type == scv )
  table.insert( buildqueue, unit )
end

function commandcenter:update( entities, dt )
  -- if cooldown time has hit a threshold, then
  -- pop a unit off the queue and construct an scv
  if self.time > 10.0 then
    if table.maxn( buildqueue ) > 0 then
      local newunit = table.remove( buildqueue, 1 )
      table.insert( entities, newunit )
    end
  end
end

return commandcenter
