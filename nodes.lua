local Nodes = Class{
    init = function(self)
        local newXYMap = require("xy_map")
        self.storage = newXYMap()
        self.names = {}
        self.names["stone_brick"] = {
            name = "stone_brick",
            texture = love.graphics.newImage("assets/stone_brick.png")
        }
        self.names["matrix_wall"] = {
            name = "matrix_wall",
            texture = love.graphics.newImage("assets/matrix_wall.png")
        }
        self.names["arrow"] = {
            name = "arrow",
            texture = love.graphics.newImage("assets/arrow.png")
        }
    end
}

local function try(x, y)
    return not not (self:isWalkable(x,y) or not self:contains(x,y))
end

function Nodes:contains(x, y)
    return self.storage:contains(x, y)
end

function Nodes:addNode(x, y, name)
    if self.names[name] then
        self.storage:add(x, y, self.names[name])
    else
        error("Node " .. name .. " doesn't exist")
    end
end

function Nodes:safeAddNode(x, y, name)
    self.storage:safeAdd(x, y, self.names[name])
end

function Nodes:get(x, y)
    return self.storage:get(x, y)
end

function Nodes:isWalkable(x, y)
    return not not ((self.storage:get(x, y) and self.storage:get(x, y).walkable) or not self.storage:get(x,y))
end

function Nodes:clear()
    self.storage:clear()
end

function Nodes:remove(x, y)
    self.storage:remove(x, y)
end

return Nodes
