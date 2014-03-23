local unit = {}
unit.__index = unit

function unit:new( x, y )
  return setmetatable(
    { x = x or 0,
      y = y or 0,
      owner = 0,
      selected = false,
      state = 'idle',
      movetarget = nil,
      attacktarget = nil }, unit )
end

return unit
