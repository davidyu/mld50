require 'vendor/AnAL'
local PrettyPrint = require 'vendor/lua-pretty-print/PrettyPrint'

local scv = {}
scv.__index = scv

function scv:new( x, y )
  print( ("%d %d"):format( x, y ) )
  local animrefs = {}
  local spritesheet = love.graphics.newImage( "art/spritesheets/scv.png" )
  local animstate = 'md'
  local anim = newAnimation( spritesheet, 32, 32, 0.5, 4 )
  animrefs[ 'mu' ] = { first = 1, last = 1 }
  animrefs[ 'md' ] = { first = 2, last = 2 }
  animrefs[ 'ml' ] = { first = 3, last = 3 }
  animrefs[ 'mr' ] = { first = 4, last = 4 }
  return setmetatable( {
    x = x or 0,
    y = y or 0,
    state = 'idle',
    movetarget = nil,
    attacktarget = nil,
    animrefs = animrefs,
    animstate = animstate,
    anim = anim
  }, scv )
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
