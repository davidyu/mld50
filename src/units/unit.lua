local unit = {}
unit.__index = unit

function unit:new( x, y )
  return setmetatable(
    { x = x or 0,
      y = y or 0,
      state = 'idle',
      movetarget = nil,
      attacktarget = nil }, unit )
end

return unit
