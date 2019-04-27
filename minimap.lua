local MiniMap = Class{
    init = function(self, game)
        self.game = game
        self.selected_node = false -- false or position in the form {x=number, y=number}
    end
}

function MiniMap:update(dt)
    -- active node
    local x, y = love.mouse.getPosition()

    local x_i = math.floor(x / CONFIG.MAP_NODE_SIZE + self.game.player.x % 1) - 1
    local y_i = math.floor(y / CONFIG.MAP_NODE_SIZE + self.game.player.y % 1)

    if x_i <= CONFIG.MAP_SIZE * 2 and y_i <= CONFIG.MAP_SIZE * 2 then
        self.selected_node = {x = x_i, y = y_i}

        local x_p = math.floor(self.game.player.x)
        local y_p = math.floor(self.game.player.y)

        local x_w = x_p - CONFIG.MAP_SIZE + x_i
        local y_w = y_p - CONFIG.MAP_SIZE + y_i

        if love.mouse.isDown(1) then -- primary button (usually left)
            self.game.nodes:addNode(x_w,y_w, "stone_brick")
        elseif love.mouse.isDown(2) then -- secondary button (usually right)
            self.game.nodes:remove(x_w,y_w)
        end

    else
        self.selected_node = false
    end

    -- number of rays

    if love.keyboard.isDown("[") then
        CONFIG.MAP_NUM_RAYS = CONFIG.MAP_NUM_RAYS - 1
        if CONFIG.MAP_NUM_RAYS < 0 then
            CONFIG.MAP_NUM_RAYS = 0
        end
    end
    if love.keyboard.isDown("]") then
        CONFIG.MAP_NUM_RAYS = CONFIG.MAP_NUM_RAYS + 1
    end

end

function MiniMap:render()
    love.graphics.push()
    love.graphics.scale(CONFIG.MAP_NODE_SIZE,
                        CONFIG.MAP_NODE_SIZE)
    love.graphics.setLineWidth(1/CONFIG.MAP_NODE_SIZE)
    love.graphics.translate(1+CONFIG.MAP_SIZE-self.game.player.x, CONFIG.MAP_SIZE-self.game.player.y)

    x_i = math.floor(self.game.player.x)
    y_i = math.floor(self.game.player.y)

    for xj=0,CONFIG.MAP_SIZE*2 do
        for yj=0,CONFIG.MAP_SIZE*2 do
            x = x_i - CONFIG.MAP_SIZE + xj
            y = y_i - CONFIG.MAP_SIZE + yj
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
            if self.selected_node and self.selected_node.x == xj and
                                      self.selected_node.y == yj then

                love.graphics.setColor(0, 1, 0, 0.5)
                love.graphics.rectangle("fill", x, y, 1, 1)
            else
                love.graphics.setColor(1, 1, 1)
            end
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
