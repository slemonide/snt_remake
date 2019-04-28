local XYMap = Class{
    init = function(self)
        self.storage = {}
        self.size = 0
        self.min_pos = {x=0,y=0} -- roughly tells the bounding box of the world
        self.max_pos = {x=0,y=0} -- it can only grow, i.e. it is not shrinked
                                 -- when things are removed
    end
}

-- Same as add, but won't add anything if the space is already occupied
function XYMap:safeAdd(x, y, data)
    if (not self:contains(x, y)) then
        self:add(x, y, data)
    end
end

function XYMap:add(x, y, data)
    self.min_pos.x = math.min(self.min_pos.x, x)
    self.min_pos.y = math.min(self.min_pos.y, y)
    self.max_pos.x = math.max(self.max_pos.x, x)
    self.max_pos.y = math.max(self.max_pos.y, y)

    data = data or true

    if (not self.storage[x]) then
        self.storage[x] = {}
    end
    self.storage[x][y] = data

    self.size = self.size + 1
end

function XYMap:forEach(fun)
    local index = 1
    for x, yArray in pairs(self.storage) do
        for y, thing in pairs(yArray) do
            assert (thing)
            local result = fun(x, y, thing, index)
            if (result) then
                return result
            end
            index = index + 1
        end
    end
end

function XYMap:contains(x, y)
    if not y then
        local pos = x
        y = pos.y
        x = pos.x
    end

    x = math.floor(x)
    y = math.floor(y)

    return (self.storage[x] or {})[y]
end

function XYMap:get(x, y)
    return (self.storage[x] and self.storage[x][y] or false)
end

function XYMap:remove(x, y)
    if (self.storage[x] or {})[y] then
        self.storage[x][y] = nil
        self.size = self.size - 1
        assert(self.size >= 0)

        -- clean up if XYMap[x] is empty
        if (not self.storage[x]) then
            self.storage[x] = nil
        end
    end
end

function XYMap:randomPosition()
    local function newFunction()
        local randomChoice = math.random(self.size)
        return function(x, y, _, index)
            if (index == randomChoice) then
                return {x = x, y = y}
            end
        end
    end

    return self:forEach(newFunction())
end

function XYMap:clear()
    self.storage = {}
    self.size = 0
end

return XYMap
