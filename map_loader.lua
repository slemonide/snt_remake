local MapLoader = Class{
    init = function(self, game)
        self.game = game
    end
}

function MapLoader:load_map(filename)
    line_count = 0
    for line in love.filesystem.lines("maps/" .. filename) do
        for i = 1, string.len(line) do
            local char = string.sub(line, i, i)
            if char == "1" then
                local x = i
                local y = line_count
                self.game.nodes:addNode(x, y, "stone_brick")
            end
        end

        line_count = line_count + 1
    end
end

return MapLoader
