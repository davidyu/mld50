local commandcenter = {}
commandcenter.__index = commandcenter

function commandcenter:new( x, y, owner )
  local spritesheet = love.graphics.newImage( "art/spritesheets/CommandCenter_Placeholder.png" )
  local anim = newAnimation( spritesheet, 128, 128, 0.5, 1 )
  return setmetatable( {
    x = x or 0,
    y = y or 0,
    anim = anim,
    owner = owner or 0,
    buildqueue = {},
    buildtimes = {
      ["scv"] = 10
    },
    time = 0
  }, commandcenter )
end

function commandcenter:enqueueunit( unit )
  assert( unit.__type == scv )
  if table.maxn( self.buildqueue ) <= 9 then -- only allow up to 10 units to be placed in the queue
    table.insert( self.buildqueue, unit )
  end
end

function commandcenter:update( entities, dt )
  -- if cooldown time has hit a threshold, then
  -- pop a unit off the queue and construct an scv
  self.time = self.time + dt
  if self.time > 10.0 then
    if table.maxn( self.buildqueue ) > 0 then
      local newunit = table.remove( self.buildqueue, 1 )
      table.insert( entities, newunit )
    end
    self.time = 0.0
  end
end

return commandcenter
