require 'vendor/AnAL'
local PrettyPrint = require 'vendor/lua-pretty-print/PrettyPrint'

local scv = {}
scv.__index = scv

function scv:new( x, y )
  local animrefs = {}
  local spritesheet = love.graphics.newImage( "art/spritesheets/SCV_Placeholder.png" )
  local animstate = 'md'
  local anim = newAnimation( spritesheet, 64, 64, 0.5, 4 )
  animrefs[ 'mu' ] = { first = 1, last = 1 }
  animrefs[ 'md' ] = { first = 2, last = 2 }
  animrefs[ 'ml' ] = { first = 3, last = 3 }
  animrefs[ 'mr' ] = { first = 4, last = 4 }
  return setmetatable( {
    x = x or 0,
    y = y or 0,
    owner = 0,
    health = 40.0,
    selected = false,
    state = 'idle',
    tx = nil,
    ty = nil,
    pathtable = {},
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

function scv:update()
  if table.maxn( self.pathtable ) > 0 then
    nextnode = table.remove( self.pathtable )
  end

  self:updateAnim( dx, dy )
end

return scv
