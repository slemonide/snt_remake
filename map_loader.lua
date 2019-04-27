local MapLoader = Class{
    init = function(self, game)
        self.game = game
    end
}

function MapLoader:load_map(filename)
    if filename then

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
    else
        self.game.nodes:addNode(0, 0, "stone_brick")
        self.game.nodes:addNode(1, 0, "stone_brick")
        self.game.nodes:addNode(2, 0, "stone_brick")
        self.game.nodes:addNode(3, 0, "stone_brick")
        self.game.nodes:addNode(4, 0, "stone_brick")
        self.game.nodes:addNode(5, 0, "stone_brick")
        self.game.nodes:addNode(0, 5, "stone_brick")
        self.game.nodes:addNode(1, 5, "stone_brick")
        self.game.nodes:addNode(2, 5, "stone_brick")
        self.game.nodes:addNode(3, 5, "stone_brick")
        self.game.nodes:addNode(4, 5, "stone_brick")
        self.game.nodes:addNode(5, 5, "stone_brick")
        self.game.nodes:addNode(0, 1, "stone_brick")
        self.game.nodes:addNode(0, 2, "stone_brick")
        self.game.nodes:addNode(0, 3, "stone_brick")
        self.game.nodes:addNode(0, 4, "stone_brick")
        self.game.nodes:addNode(5, 1, "stone_brick")
        self.game.nodes:addNode(5, 2, "stone_brick")
        self.game.nodes:addNode(5, 3, "stone_brick")
        self.game.nodes:addNode(5, 4, "stone_brick")
    end
end

return MapLoader
