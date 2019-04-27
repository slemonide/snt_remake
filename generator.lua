-------------------------------------------------------------------------------
-- World generator
-------------------------------------------------------------------------------

local Generator = Class{
    init = function(self, game)
        self.game = game
        local newXYMap = require("xy_map")
        self.storage = newXYMap()
        self.toDoLater = {}
    end
}

local GENERATOR_DISTANCE = 50
local STONE_FILL_DISTANCE = 20

function Generator:add(x, y, data)
    table.insert(self.toDoLater, function() self.storage:safeAdd(x, y, data) end)
end

function Generator:remove(x, y)
    table.insert(self.toDoLater, function() self.storage:remove(x, y) end)
end

function Generator:generate()
    self.storage:forEach(function(x,y,node)
        if (node.ignore_player or
            math.abs(x - self.game.player.x) < GENERATOR_DISTANCE and
            math.abs(y - self.game.player.y) < GENERATOR_DISTANCE) then

            node.action(x,y,node)
        end
    end)

    for _, func in ipairs(self.toDoLater) do
        func()
    end
    self.toDoLater = {}
end

function Generator:placeWall(x, y)
    self.game.nodes:safeAddNode(x, y, "stone_brick")
end

local function numOpenNeighbours(x, y)
    local count = 0

    for dx = -1, 1 do
        for dy = -1, 1 do
            if (self.game.nodes:isWalkable(x + dx, y + dy)) then
                count = count + 1
            end
        end
    end

    return count
end

function Generator:placeFloor(x, y)
    -- TODO: implement floors
end

-- Begin generating a maze at (x, y)
function Generator:addMaze(x, y)
    self:add(x, y, {
        action = function()
            self:remove(x, y)

            self:placeWall(x+1,y+1)
            self:placeWall(x+1,y-1)
            self:placeWall(x-1,y+1)
            self:placeWall(x-1,y-1)

            local function generateNextNode(generate, dx, dy)
                local function generateBorders(wall)
                    local func = function(x,y)
                        if (wall) then
                            self:placeWall(x,y)
                        end
                    end

                    if (math.random() > 0.4) then
                        if (dx == 0) then
                            func(x, y + dy * 2)
                            func(x - 1, y + dy * 2)
                            func(x + 1, y + dy * 2)
                        else
                            func(x + dx * 2, y)
                            func(x + dx * 2, y - 1)
                            func(x + dx * 2, y + 1)
                        end
                    else
                        if (dx == 0) then
                            func(x, y + dy * 2)
                            self:placeWall(x - 1, y + dy * 2)
                            self:placeWall(x + 1, y + dy * 2)
                        else
                            func(x + dx * 2, y)
                            self:placeWall(x + dx * 2, y - 1)
                            self:placeWall(x + dx * 2, y + 1)
                        end
                    end
                end

                if (generate and not self.game.nodes:contains(x + dx, y + dy)) then
                    generateBorders(false)
                    self:addMaze(x + dx, y + dy)
                else
                    generateBorders(true)
                end

                return generate
            end

            local generated_nodes = 1
            local function generateNextNodeProbabilityDone(dx, dy)
                local generate
                if (self.storage.size < 20) then
                    generate = math.random() < 1 / generated_nodes
                elseif (self.storage.size < 10) then
                    generate = true
                else
                    generate = math.random() < 0.6 / generated_nodes
                end
                if (generate) then
                    if (self.storage.size < 20) then
                        generated_nodes = generated_nodes + 1
                    else
                        generated_nodes = generated_nodes * 3
                    end
                end

                return generateNextNode(
                    generate,
                    2 * dx,
                    2 * dy
                )
            end

            local generationQueue = {
                function() generateNextNodeProbabilityDone(1, 0) end,
                function() generateNextNodeProbabilityDone(-1,0) end,
                function() generateNextNodeProbabilityDone(0, 1) end,
                function() generateNextNodeProbabilityDone(0,-1) end
            }

            while (#generationQueue ~= 0) do
                local index = math.random(#generationQueue)
                generationQueue[index]()
                table.remove(generationQueue, index)
            end
        end
    })
end

function Generator:addCave(x, y, points)
    self:add(x, y, {
        ignore_player = false,
        points = points or math.pow(2, 50),
        action = function(x, y, node)
            if (self.game.nodes:get(x,y)) then
                self:remove(x, y)
            end

            local points = node.points

            if (points == 1) then
                self:remove(x, y)
                if (x % 4 == 0 and y % 4 == 0) then
                    self:addMaze(x,y)
                elseif (math.random() < 1 * math.exp(-self.size/20)) then
                    self:addCave(x, y, math.pow(2, math.random(60) + 10))
                end
            else
                node.points = points * 2

                local generatorOptions = {
                    function() self:addCave(x+1, y, points * 2) end,
                    function() self:addCave(x-1, y, points * 2) end,
                    function() self:addCave(x, y+1, points * 2) end,
                    function() self:addCave(x, y-1, points * 2) end
                }

                generatorOptions[math.random(#generatorOptions)]()
            end
        end
    })
end

return Generator
