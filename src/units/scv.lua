require 'vendor/AnAL'
local utils = require 'utils'

local PrettyPrint = require 'vendor/lua-pretty-print/PrettyPrint'

local scv = {}
scv.__index = scv

function scv:new( x, y, owner )
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
    owner = owner or 0,
    health = 40.0,
    maxhealth = 40.0,
    selected = false,
    weapon = 5,
    repair = 5,
    friendlytargets = utils.Set { scv },
    targetcommand = 'repair',
    cooldown = 0.8,
    atktimer = 0,
    range = 1,
    sight = 2,
    state = 'idle',
    tx = -1,
    ty = -1,
    pathtable = {},
    target = nil,
    forcetarget = nil,
    animrefs = animrefs,
    animstate = animstate,
    anim = anim,
    time = 0,
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

local function withinrange( me, target )
  return math.abs( me.x - target.x ) + math.abs( me.y - target.y ) <= me.range
end

function scv:takedamage( damage )
  self.health = self.health - damage
  if self.health <= 0 then
    self.health = 0
    -- death handled by god
  end
end

function scv:update( pather, map, dt )
  self.time = self.time + dt
  self.atktimer = self.atktimer + dt

  local newx, newy = self.x, self.y

  if self.time > 0.4 then
    -- do action, timer is reset on postupdate

    -- clear stale attack targets
    if self.target ~= nil and self.target.health == 0 then
      self.target = nil
    end

    -- stop repairing if HP full
    if self.target ~= nil and self.targetcommand == 'repair' and self.target.health / self.target.maxhealth >= 1 then
      self.target = nil
    end

    -- within range, so attack!!!!
    if self.target ~= nil and withinrange( self, self.target ) and self.atktimer > self.cooldown then
      if self.targetcommand == 'repair' then
        self.target:takedamage( -self.repair )
        self.atktimer = 0
      else
        self.target:takedamage( self.weapon )
        self.atktimer = 0
      end
    end

    -- seek to target
    if self.target ~= nil and self.tx ~= self.target.x and self.ty ~= self.target.y and not withinrange( self, self.target ) then
      -- acquire empty spot within range
      local candidatex, candidatey = self.target.x, self.target.y
      for i = 0, self.range do
        for j = 0, self.range - i do
          if map.occupied[ self.target.x + i + ( self.target.y - 1 - j ) * map.width ] == nil then
            candidatex = self.target.x + i
            candidatey = self.target.y - j
          end
          if map.occupied[ self.target.x - i + ( self.target.y - 1 + j ) * map.width ] == nil then
            candidatex = self.target.x - i
            candidatey = self.target.y + j
          end
          if map.occupied[ self.target.x + i + ( self.target.y - 1 + j ) * map.width ] == nil then
            candidatex = self.target.x + i
            candidatey = self.target.y + j
          end
          if map.occupied[ self.target.x - i + ( self.target.y - 1 - j ) * map.width ] == nil then
            candidatex = self.target.x - i
            candidatey = self.target.y - j
          end
        end
      end

      if candidatex ~= self.target.x or candidatey ~= self.target.y then
        self.tx = candidatex
        self.ty = candidatey
      end
    end

    if self.tx > 0 and self.ty > 0 then
      local path, length = pather:getPath( self.x, self.y, self.tx, self.ty )
      if path then
        self.pathtable = {}
        for node, count in path:nodes() do
          table.insert( self.pathtable, node )
        end
        table.remove( self.pathtable, 1 ) -- remove first node in path, which is your current position
      end
      -- reset
      self.tx, self.ty = -1, -1
    end

    if table.maxn( self.pathtable ) > 0 then
      local nextnode = table.remove( self.pathtable, 1 )
      newx, newy = nextnode:getX(), nextnode:getY()
      -- collision check
      if map.occupied[ newx + ( newy - 1 ) * map.width ] ~= nil then
        -- repath
        if table.maxn( self.pathtable ) > 0 then -- only if destination not occupied
          local target = table.remove( self.pathtable )
          self.tx, self.ty = target:getX(), target:getY() -- try again next turn
          newx, newy = self.x, self.y
        end
        newx, newy = self.x, self.y
      end
    end
  end

  dx, dy = newx - self.x, newy - self.y
  self:updateAnim( dx, dy )
  self.x, self.y = newx, newy

end

function scv:postupdate( pather, map )
  local newx, newy = self.x, self.y

  if self.time > 0.4 then
    self.time = 0

    -- move to nearest square with no collision
    local nx, ny = newx, newy
    while nx < map.width and ny < map.height and map.occupied[ nx + ( ny - 1 ) * map.width ] ~= nil and table.maxn( map.occupied[ nx + ( ny - 1 ) * map.width ] ) > 1 do
      -- guess-verify
      nx, ny = newx + math.random( 2 ) - 1, newy + math.random( 2 ) - 1
    end
    newx, newy = nx, ny

    -- repath if necessary
    if table.maxn( self.pathtable ) > 0 then
      local target = table.remove( self.pathtable )
      self.tx, self.ty = target:getX(), target:getY()
    end
  end

  self.x, self.y = newx, newy

end

return scv
