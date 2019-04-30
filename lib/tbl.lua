-- source: https://stackoverflow.com/questions/32465881/bfs-algorithm-using-lua-that-finds-the-shortest-path-between-2-nodes

function table.contains(tbl, e)
    for _, v in pairs(tbl) do
        if v == e then
            return true
        end
    end

    return false
end

function table.copy(tbl)
    local t = {}

    for _, v in pairs(tbl) do
        table.insert(t, v)
    end

    return t
end
