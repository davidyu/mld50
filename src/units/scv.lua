require 'vendor/AnAL'

local Unit = require 'units/unit'
local scv = Unit:new()

function scv:new()
  o = Unit:new()
  setmetatable( o, self )
  self.__index = self
  self.animrefs = {}
  local spritesheet = love.graphics.newImage( "art/spritesheets/scv.png" )
  self.anim = newAnimation( spritesheet, 32, 32, 0.5, 4 )
  self.animrefs[ 'mu' ] = { first = 1, last = 1 }
  self.animrefs[ 'md' ] = { first = 2, last = 2 }
  self.animrefs[ 'ml' ] = { first = 3, last = 3 }
  self.animrefs[ 'mr' ] = { first = 4, last = 4 }
  self.animstate = 'md'
  return o
end

function scv:updateAnim( dx, dy )
  if     dx > 0 then self.animstate = 'mr'
  elseif dx < 0 then self.animstate = 'ml' end

  if     dy > 0 then self.animstate = 'mu'
  elseif dy < 0 then self.animstate = 'md' end

  if self.anim:getCurrentFrame() == self.animrefs[ self.animstate ].last then
    self.anim:seek( self.animrefs[ self.animstate ].first )
  end
end

return scv
