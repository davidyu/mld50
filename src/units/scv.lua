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
    tx = -1,
    ty = -1,
    pathtable = {},
    attacktarget = nil,
    animrefs = animrefs,
    animstate = animstate,
    anim = anim,
    time = 0
  }, scv )
end

function scv:updateAnim( dx, dy )
  if     dx > 0 then self.animstate = 'mr'
  elseif dx < 0 then self.animstate = 'ml' end

  if     dy < 0 then self.animstate = 'mu'
  elseif dy > 0 then self.animstate = 'md' end

  if self.anim:getCurrentFrame() >= self.animrefs[ self.animstate ].last or self.anim:getCurrentFrame() <= self.animrefs[ self.animstate ].first then
    self.anim:seek( self.animrefs[ self.animstate ].first )
  end
end

function scv:update( pather, dt )
  self.time = self.time + dt

  local newx, newy = self.x, self.y

  if self.time > 0.2 then
    self.time = 0

    if self.tx > 0 and self.ty > 0 then
      local path, length = pather:getPath( self.x, self.y, self.tx, self.ty )
      if path then
        self.pathtable = {}
        for node, count in path:nodes() do
          table.insert( self.pathtable, node )
        end
        table.remove( self.pathtable, 1 ) -- remove first thing
      end
      -- reset
      self.tx, self.ty = -1, -1
    end

    if table.maxn( self.pathtable ) > 0 then
      local nextnode = table.remove( self.pathtable, 1 )
      newx, newy = nextnode:getX(), nextnode:getY()
    end
  end

  dx, dy = newx - self.x, newy - self.y
  self:updateAnim( dx, dy )
  self.x, self.y = newx, newy

end

return scv
