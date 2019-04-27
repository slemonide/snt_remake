local XYMap = Class{
    init = function(self)
        self.storage = {}
        self.size = 0
    end
}

-- Same as add, but won't add anything if the space is already occupied
function XYMap:safeAdd(x, y, data)
    if (not XYMap:contains(x, y)) then
        XYMap:add(x, y, data)
    end
end

function XYMap:add(x, y, data)
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

    return XYMap:forEach(newFunction())
end

function XYMap:clear()
    self.storage = {}
    self.size = 0
end

return XYMap
