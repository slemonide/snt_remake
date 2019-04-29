local MiniMap = Class{
    init = function(self, game)
        self.game = game
        self.selected_node = false -- false or position in the form {x=number, y=number}
        self.map_h = CONFIG.MAP_SIZE -- actually, half of them
        self.map_w = CONFIG.MAP_SIZE
        self.node_size = CONFIG.MAP_NODE_SIZE
        self:init_canvas()
    end
}

function MiniMap:init_canvas()
    local sizex = self.map_w * self.node_size * 2
    local sizey = self.map_h * self.node_size * 2

    self.canvas = love.graphics.newCanvas(sizex, sizey)
    self.quad = love.graphics.newQuad(self.node_size,
                                      self.node_size,
                                      sizex - self.node_size,
                                      sizey - self.node_size,
                                      sizex, sizey)

end

function MiniMap:switch_editor()
    if CONFIG.EDITOR then
        self.node_size = CONFIG.EDITOR_NODE_SIZE

        local width, height = love.graphics.getDimensions()

        self.map_h = math.floor(height/self.node_size/2)
        self.map_w = math.floor(width/self.node_size/2)
    else
        self.node_size = CONFIG.MAP_NODE_SIZE
        self.map_h = CONFIG.MAP_SIZE
        self.map_w = CONFIG.MAP_SIZE
    end
    self:init_canvas()
end

function MiniMap:update(dt)
    -- active node
    local x, y = love.mouse.getPosition()

    local x_i = math.floor(x / self.node_size + self.game.player.x % 1) - 1
    local y_i = math.floor(y / self.node_size + self.game.player.y % 1) - 1

    if x_i <= self.map_w * 2 and y_i <= self.map_h * 2 then
        self.selected_node = {x = x_i, y = y_i}

        local x_p = math.floor(self.game.player.x)
        local y_p = math.floor(self.game.player.y)

        local x_w = x_p - self.map_w + x_i
        local y_w = y_p - self.map_h + y_i

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

function MiniMap:update_canvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    love.graphics.push()
    love.graphics.scale(self.node_size,
                        self.node_size)
    love.graphics.setLineWidth(1/self.node_size)
    love.graphics.translate(1+self.map_w-self.game.player.x, 1+self.map_h-self.game.player.y)

    x_i = math.floor(self.game.player.x)
    y_i = math.floor(self.game.player.y)

    for xj=0,self.map_w*2 do
        for yj=0,self.map_h*2 do
            x = x_i - self.map_w + xj
            y = y_i - self.map_h + yj
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

            if dist then
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
    end
    love.graphics.pop()
    love.graphics.setCanvas()
end

function MiniMap:render()
    self:update_canvas()

    love.graphics.setColor(1,1,1)
    love.graphics.draw(self.canvas, self.quad, self.node_size, self.node_size)
end

return MiniMap
