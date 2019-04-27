local game = {}

function game:init()
    local Player = require("player")
    game.player = Player(game)
    local Nodes = require("nodes")
    game.nodes = Nodes()
    game.nodes:addNode(0, 0, "stone_brick")
    game.nodes:addNode(1, 0, "stone_brick")
    game.nodes:addNode(2, 0, "stone_brick")
    game.nodes:addNode(3, 0, "stone_brick")
    game.nodes:addNode(4, 0, "stone_brick")
    game.nodes:addNode(5, 0, "stone_brick")
    game.nodes:addNode(0, 5, "stone_brick")
    game.nodes:addNode(1, 5, "stone_brick")
    game.nodes:addNode(2, 5, "stone_brick")
    game.nodes:addNode(3, 5, "stone_brick")
    game.nodes:addNode(4, 5, "stone_brick")
    game.nodes:addNode(5, 5, "stone_brick")
    game.nodes:addNode(0, 1, "stone_brick")
    game.nodes:addNode(0, 2, "stone_brick")
    game.nodes:addNode(0, 3, "stone_brick")
    game.nodes:addNode(0, 4, "stone_brick")
    game.nodes:addNode(5, 1, "stone_brick")
    game.nodes:addNode(5, 2, "stone_brick")
    game.nodes:addNode(5, 3, "stone_brick")
    game.nodes:addNode(5, 4, "stone_brick")

    game.sceneCanvas = love.graphics.newCanvas()
    -- textures
    love.graphics.setDefaultFilter("nearest")
    game.wall = love.graphics.newImage("assets/wall.png")
    game.wall_quad = love.graphics.newQuad(0, 0, 1, 64, 64, 64)

    -- 20x20 world
    -- 0 is floor
    -- 1 is wall
    --[[
    game.world = {
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,
    1,1,1,1,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,1,
    1,2,2,2,2,2,1,0,1,0,0,0,0,0,0,0,0,0,0,1,
    1,2,0,0,0,2,1,1,1,0,0,0,0,0,0,0,0,0,0,1,
    1,2,0,1,0,2,1,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,2,0,0,0,2,1,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,2,0,0,0,2,1,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,2,0,1,0,2,1,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,2,0,0,0,2,1,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,2,2,0,2,2,1,0,0,0,0,0,0,0,1,0,0,0,0,1,
    1,1,1,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,2,2,2,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    }
    --]]
end

function game:update_scene(w,h)
    love.graphics.setCanvas(game.sceneCanvas)
    love.graphics.clear()

    for i=1,w do
        local rot = game.player.rot + (i - w/2) * CONFIG.FOV/w

        local dist, side, points, offset = game:getDistanceToObstacle(rot)
        -- only difference from before is a correction to dist:
        if not CONFIG.FISH_EYE then
            local ang = (i - w/2) * CONFIG.FOV/w
            dist = dist * math.cos(ang)
        end
        local shadow = math.min(dist/CONFIG.SHADOW_SIZE/10,0.5)
        if side == "x" then
            love.graphics.setColor(0.6-shadow,0.6-shadow,0.6-shadow)
        elseif side == "y" then
            love.graphics.setColor(0.55-shadow, 0.55-shadow,0.55-shadow)
        end
        if CONFIG.TEXTURES then
            game.wall_quad:setViewport(64*(offset/CONFIG.NODE_SIZE % 1),0,1,64)
            love.graphics.draw(game.wall, game.wall_quad, i,
                            game.player.z + h/2 - 10000/dist, 0, 1, 310/dist, 0, 0)
        else
            love.graphics.line(i, game.player.z + h/2 - 10000/dist, i, game.player.z + h/2 + 10000/dist)
        end
    end

    love.graphics.setCanvas()
end

function game:update(dt)
    game.player:update(dt)

    if love.keyboard.isDown("-") then
        CONFIG.FOV = CONFIG.FOV - math.pi / 180
    end
    if love.keyboard.isDown("=") then
        CONFIG.FOV = CONFIG.FOV + math.pi / 180
    end
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

function game:render_scene(w,h)
    game:update_scene(w,h)
    
    love.graphics.setColor(1,1,1)
    love.graphics.draw(game.sceneCanvas, 0,0)
end

function game:render_map()
    love.graphics.push()
    love.graphics.scale(CONFIG.MAP_NODE_SIZE,
                        CONFIG.MAP_NODE_SIZE)

    for x=0,10 do
        for y=0,10 do
            local v = 0
            if game.nodes:contains(x,y) then
                v = 1
            end
            if v == 1 then
                love.graphics.setColor(0.70, 0.63, 0.05)
                love.graphics.rectangle("fill", x, y, CONFIG.NODE_SIZE, CONFIG.NODE_SIZE)
            elseif v == 2 then
                love.graphics.setColor(0.06, 0.63, 0.70)
                love.graphics.rectangle("fill", x, y, CONFIG.NODE_SIZE, CONFIG.NODE_SIZE)
            end
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", x, y, CONFIG.NODE_SIZE, CONFIG.NODE_SIZE)
        end
    end
    
    love.graphics.setColor(1, 0.42, 0.64)
    love.graphics.arc("fill", game.player.x, game.player.y,
        CONFIG.FOV_TRIANGLE_SIZE,
        game.player.rot + CONFIG.FOV/2,
        game.player.rot - CONFIG.FOV/2)
    love.graphics.setColor(0.42, 0.63, 0.05)
    love.graphics.circle("fill", game.player.x, game.player.y, CONFIG.NODE_SIZE/4)

    if CONFIG.MAP_NUM_RAYS ~= 0 then
        for i=-CONFIG.MAP_NUM_RAYS,CONFIG.MAP_NUM_RAYS do
            local rot = game.player.rot + i * CONFIG.FOV/(2*CONFIG.MAP_NUM_RAYS)

            dist, side, points = game:getDistanceToObstacle(rot)

            line_points = {}
            
            table.insert(line_points, game.player.x)
            table.insert(line_points, game.player.y)

            for _, point in ipairs(points) do
                table.insert(line_points, point.x)
                table.insert(line_points, point.y)
            end


            love.graphics.setColor(0, 1, 0)
            love.graphics.line(line_points)

            for _, point in ipairs(points) do
                love.graphics.setColor(1,0,0)
                love.graphics.circle("fill", point.x, point.y, 3)
            end
        end
    end
    love.graphics.pop()
end

function game:draw()
    local t1 = os.clock()
    
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    game:render_scene(w,h)

    if CONFIG.DISPLAY_MAP then
        game:render_map()
    end

    -- compute FPS
    local t2 = os.clock()
    local fps = string.format("FPS: %.0f", 1/(t2 - t1))
    
    local disp_cnt = 0
    local function disp(text)
        love.graphics.print(text, w - 140, 10 + 15*disp_cnt)
        disp_cnt = disp_cnt + 1
    end

    love.graphics.setColor(1,0,0)
    disp(fps)
    disp("Fisheye: " .. (CONFIG.FISH_EYE and "on" or "off"))
    disp("Textures: " .. (CONFIG.TEXTURES and "on" or "off"))
    disp(string.format("FOV: %.0f degrees", CONFIG.FOV/math.pi*180))
    disp("Map num rays: " .. CONFIG.MAP_NUM_RAYS)
    disp(string.format("Position: %.0f, %.0f", game.player.x, game.player.y))
    disp(string.format("Angle: %.0f degrees", (game.player.rot/math.pi*180) % 360))

end

function game:getDistanceToObstacle(angle)
    local points = {}

    local current_pos = {
        x = game.player.x,
        y = game.player.y
    }

    local prev_pos = {}

    local distance = 0

    angle = angle % (2*math.pi)

    for i=1,1000 do
        prev_pos.x = current_pos.x
        prev_pos.y = current_pos.y

        current_pos.x = current_pos.x + eps * math.cos(angle)
        current_pos.y = current_pos.y + eps * math.sin(angle)

        local x_i = math.floor(current_pos.x / CONFIG.NODE_SIZE)
        local y_i = math.floor(current_pos.y / CONFIG.NODE_SIZE)

        if (angle >= 0 and angle < math.pi/2) then
            local x_a = (x_i + 1) * CONFIG.NODE_SIZE
            local y_a = (y_i + 1) * CONFIG.NODE_SIZE

            local dx = x_a - current_pos.x
            local dy = y_a - current_pos.y

            local a_angle = math.atan(dy/dx)

            if (angle < a_angle) then
                current_pos.x = x_a
                current_pos.y = current_pos.y + dx * math.tan(angle)
            else
                current_pos.x = current_pos.x + dy * math.tan(math.pi/2 - angle)
                current_pos.y = y_a
            end

        elseif (angle >= math.pi/2 and angle < math.pi) then
            local x_a = (x_i) * CONFIG.NODE_SIZE
            local y_a = (y_i + 1) * CONFIG.NODE_SIZE

            local dx = current_pos.x - x_a
            local dy = y_a - current_pos.y

            local a_angle = math.atan(dx/dy)

            local langle = angle - math.pi/2

            if (langle < a_angle) then
                current_pos.x = current_pos.x - dy * math.tan(langle)
                current_pos.y = y_a
            else
                current_pos.x = x_a
                current_pos.y = current_pos.y + dx * math.tan(math.pi/2 - langle)
            end

        elseif (angle >= math.pi and angle < math.pi * 3/2) then
            local x_a = (x_i) * CONFIG.NODE_SIZE
            local y_a = (y_i) * CONFIG.NODE_SIZE

            local dx = current_pos.x - x_a
            local dy = current_pos.y - y_a

            local a_angle = math.atan(dy/dx)

            local langle = angle - math.pi

            if (langle < a_angle) then
                current_pos.x = x_a
                current_pos.y = current_pos.y - dx * math.tan(langle)
            else
                current_pos.x = current_pos.x - dy * math.tan(math.pi/2 - langle)
                current_pos.y = y_a
            end
        elseif (angle >= math.pi * 3/2 and angle < math.pi * 2) then
            local x_a = (x_i + 1) * CONFIG.NODE_SIZE
            local y_a = (y_i) * CONFIG.NODE_SIZE

            local dx = x_a - current_pos.x
            local dy = current_pos.y - y_a

            local a_angle = math.atan(dx/dy)

            local langle = angle - math.pi * 3/2

            if (langle < a_angle) then
                current_pos.x = current_pos.x + dy * math.tan(langle)
                current_pos.y = y_a
            else
                current_pos.x = x_a
                current_pos.y = current_pos.y - dx * math.tan(math.pi/2 - langle)
            end
        else
            print("Incorrect angle " .. angle)
        end

        distance = distance + math.sqrt((current_pos.x - prev_pos.x)^2 + (current_pos.y - prev_pos.y)^2)

        table.insert(points, {x=current_pos.x, y=current_pos.y})

        local eps = 0.001
        local isWall = game:isWall({x = current_pos.x + eps * math.cos(angle),
                                    y = current_pos.y + eps * math.sin(angle)})

        local isMirror = game:isMirror({x = current_pos.x + eps * math.cos(angle),
                                        y = current_pos.y + eps * math.sin(angle)})
        if isMirror then
            local wallX = math.floor(current_pos.x / CONFIG.WORLD_SIZE) * CONFIG.NODE_SIZE
            local wallY = math.floor(current_pos.y / CONFIG.WORLD_SIZE) * CONFIG.NODE_SIZE
            local dx = current_pos.x - wallX + CONFIG.NODE_SIZE/2
            local dy = current_pos.y - wallY - CONFIG.NODE_SIZE/2

            local angle_in = math.atan(dy/dx) + math.pi/4

            local side = ""

            if math.tan(angle_in) > 0 then
                side = "x"
            else
                side = "y"
            end
            -- REFACTOR: put above code into a separate function, unite with the one from below

            if (side == "y") then
                angle = math.pi * 2 - angle
            elseif (side == "x") then
                angle = math.pi - angle
            end
            
            angle = angle % (math.pi * 2)
        elseif isWall then
            local wallX = math.floor(current_pos.x / CONFIG.WORLD_SIZE) * CONFIG.NODE_SIZE
            local wallY = math.floor(current_pos.y / CONFIG.WORLD_SIZE) * CONFIG.NODE_SIZE
            local dx = current_pos.x - wallX + CONFIG.NODE_SIZE/2
            local dy = current_pos.y - wallY - CONFIG.NODE_SIZE/2

            local angle_in = math.atan(dy/dx) + math.pi/4

            angle_in = angle_in % (2*math.pi)


            local x_i = math.floor(current_pos.x / CONFIG.NODE_SIZE)
            local y_i = math.floor(current_pos.y / CONFIG.NODE_SIZE)

            local offset = 0

            if (angle_in >= 0 and angle_in < math.pi/2) then
                offset = math.sqrt((x_i * CONFIG.NODE_SIZE - current_pos.x)^2
                                 + (y_i * CONFIG.NODE_SIZE - current_pos.y)^2)
            elseif (angle_in >= math.pi/2 and angle_in < math.pi) then
                offset = math.sqrt(((x_i+1) * CONFIG.NODE_SIZE - current_pos.x)^2
                                 + ((y_i) * CONFIG.NODE_SIZE - current_pos.y)^2)
            elseif (angle_in >= math.pi * 3/2 and angle_in < math.pi * 2) then
                offset = math.sqrt(((x_i+1) * CONFIG.NODE_SIZE - current_pos.x)^2
                                 + ((y_i) * CONFIG.NODE_SIZE - current_pos.y)^2)
            else
                print("Unknown angle: " .. angle_in)
            end

            if math.tan(angle_in) > 0 then
                return distance, "x", points, offset
            else
                return distance, "y", points, offset
            end
        end
    end

    return distance, "x", points, 0
end

function game:isWall(pos)
    --[[
    i = math.ceil(pos.x / CONFIG.NODE_SIZE) +
        math.floor((pos.y / CONFIG.NODE_SIZE)) * CONFIG.WORLD_SIZE
    if game.world[i] ~= 0 then
        return true, i
    else
        return false, i
    end
    --]]
    return game.nodes:contains(math.floor(pos.x/CONFIG.NODE_SIZE), math.floor(pos.y/CONFIG.NODE_SIZE))
end

function game:isMirror(pos)
    --[[
    i = math.ceil(pos.x / CONFIG.NODE_SIZE) +
        math.floor((pos.y / CONFIG.NODE_SIZE)) * CONFIG.WORLD_SIZE
    if game.world[i] == 2 then
        return true, i
    else
        return false, i
    end
    --]]

    return false
end

function game:keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f" then
        CONFIG.FISH_EYE = not CONFIG.FISH_EYE
    elseif key == "tab" then
        CONFIG.DISPLAY_MAP = not CONFIG.DISPLAY_MAP
    elseif key == "t" then
        CONFIG.TEXTURES = not CONFIG.TEXTURES
    end
end

return game
