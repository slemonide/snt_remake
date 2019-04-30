-- source: https://stackoverflow.com/questions/32465881/bfs-algorithm-using-lua-that-finds-the-shortest-path-between-2-nodes

local queue = {}

function queue:init()
    local q = {}

    q.stack = {}

    function q:push(e)
        if e then
            table.insert(self.stack, e)
        end
    end

    function q:pull()
        local e = self.stack[1]

        table.remove(self.stack, 1)

        return e
    end

    function q:count()
        return #self.stack
    end

    return q
end

return queue
