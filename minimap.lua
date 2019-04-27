local MiniMap = Class{
    init = function(self, game)
        self.game = game
    end
}

function MiniMap:render()
    love.graphics.push()
    love.graphics.scale(CONFIG.MAP_NODE_SIZE,
                        CONFIG.MAP_NODE_SIZE)
    love.graphics.setLineWidth(1/CONFIG.MAP_NODE_SIZE)
    love.graphics.translate(6-self.game.player.x, 6-self.game.player.y)

    x_i = math.floor(self.game.player.x)
    y_i = math.floor(self.game.player.y)

    for xj=0,10 do
        for yj=0,10 do
            x = x_i - 5 + xj
            y = y_i - 5 + yj
            local v = 0
            if self.game.nodes:contains(x,y) then
                v = 1
            end
            if v == 1 then
                love.graphics.setColor(0.70, 0.63, 0.05)
                love.graphics.rectangle("fill", x, y, 1, 1)
            elseif v == 2 then
                love.graphics.setColor(0.06, 0.63, 0.70)
                love.graphics.rectangle("fill", x, y, 1, 1)
            end
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", x, y, 1, 1)
        end
    end

    love.graphics.setColor(1, 0.42, 0.64)
    love.graphics.arc("fill", self.game.player.x, self.game.player.y, 0.1,
        self.game.player.rot + CONFIG.FOV/2,
        self.game.player.rot - CONFIG.FOV/2)
    love.graphics.setColor(0.42, 0.63, 0.05)
    love.graphics.circle("fill", self.game.player.x, self.game.player.y, 1/4)

    if CONFIG.MAP_NUM_RAYS ~= 0 then
        for i=-CONFIG.MAP_NUM_RAYS,CONFIG.MAP_NUM_RAYS do
            local rot = self.game.player.rot + i * CONFIG.FOV/(2*CONFIG.MAP_NUM_RAYS)

            dist, side, points = self.game:getDistanceToObstacle(rot)

            line_points = {}
            
            table.insert(line_points, self.game.player.x)
            table.insert(line_points, self.game.player.y)

            for _, point in ipairs(points) do
                table.insert(line_points, point.x)
                table.insert(line_points, point.y)
            end


            love.graphics.setColor(0, 1, 0)
            love.graphics.line(line_points)

            for _, point in ipairs(points) do
                love.graphics.setColor(1,0,0)
                love.graphics.circle("fill", point.x, point.y, 0.1)
            end
        end
    end
    love.graphics.pop()
end

return MiniMap
