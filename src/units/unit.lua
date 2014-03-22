local unit = {}

function unit:new()
  o = {}
  setmetatable( o, self )
  self.__index = self
  self.movetarget = {}
  self.attacktarget = {}
  self.state = 'idle'
  self.x = 0
  self.y = 0
  return o
end

return unit
