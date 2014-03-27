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
end

function commandcenter:update( dt )

end

return commandcenter
