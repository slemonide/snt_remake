local game = {}

function game:init()
    local Player = require("player")
    local Nodes = require("nodes")
    local MapLoader = require("map_loader")
    local MiniMap = require("minimap")

    game.player = Player(game)
    game.nodes = Nodes()
    game.map_loader = MapLoader(game)
    game.map_loader:load_map("level1.map")
    game.minimap = MiniMap(game)

    game.sceneCanvas = love.graphics.newCanvas()
    -- textures
    game.wall_quad = love.graphics.newQuad(0, 0, 1, 64, 64, 64)
end

function game:update_scene(w,h)
    love.graphics.setCanvas(game.sceneCanvas)
    love.graphics.clear()

    for i=1,w do
        local rot = game.player.rot + (i - w/2) * CONFIG.FOV/w

        local dist, side, points, offset, node = game:getDistanceToObstacle(rot)
        if dist then
            -- only difference from before is a correction to dist:
            if not CONFIG.FISH_EYE then
                local ang = (i - w/2) * CONFIG.FOV/w
                dist = dist * math.cos(ang)
            end
            local shadow = math.min(dist/CONFIG.SHADOW_SIZE/10,0.5)
            if side == "px" or side == "nx" then
                love.graphics.setColor(0.6-shadow,0.6-shadow,0.6-shadow)
            elseif side == "py" or side == "ny" then
                love.graphics.setColor(0.54-shadow, 0.54-shadow,0.54-shadow)
            end
            if CONFIG.TEXTURES then
                game.wall_quad:setViewport(64*(offset % 1),0,1,64)
                love.graphics.draw(node.texture, game.wall_quad, i,
                                   game.player.z + h/2 - 10000/dist/30, 0, 1, 310/dist/30, 0, 0)
            else
                love.graphics.line(i, game.player.z + h/2 - 10000/dist/30, i, game.player.z + h/2 + 10000/dist/30)
            end
            -- draw floor
            love.graphics.setColor(0.2,0.8,0.3)
            love.graphics.line(i, game.player.z + h/2 + 10000/dist/30, i, h)
            -- draw ceiling
            love.graphics.setColor(0.9,0.8,0.9)
            love.graphics.line(i, game.player.z + h/2 - 10000/dist/30, i, 0)

            -- draw node borders
            love.graphics.setColor(1,0,0)
            for _, point in ipairs(points) do
                local point_dist = math.sqrt((game.player.x - point.x)^2 +
                                             (game.player.y - point.y)^2)
                -- TODO:finish
                --local screen_y = point_dist / dist * (game.player.z + h/2 - 10000/dist/30)
                --local screen_y = math.atan(point_dist / dist) * (game.player.z + h/2 - 10000/dist/30)
                --love.graphics.points(i, screen_y)
            end
        else
            -- draw floor
            love.graphics.setColor(0.2,0.8,0.3)
            love.graphics.line(i, game.player.z + h/2, i, h)
            -- draw ceiling
            love.graphics.setColor(0.9,0.8,0.9)
            love.graphics.line(i, game.player.z + h/2, i, 0)
        end
    end

    love.graphics.setCanvas()
end

function game:update(dt)
    game.player:update(dt)
    game.minimap:update(dt)

    if not love.keyboard.isDown("lshift") then
        if love.keyboard.isDown("-") then
            CONFIG.FOV = CONFIG.FOV - math.pi / 180
        end
        if love.keyboard.isDown("=") then
            CONFIG.FOV = CONFIG.FOV + math.pi / 180
        end
    else
        if love.keyboard.isDown("-") then
            CONFIG.MAP_SIZE = math.max(CONFIG.MAP_SIZE - 1, 0)
        end
        if love.keyboard.isDown("=") then
            CONFIG.MAP_SIZE = CONFIG.MAP_SIZE + 1
        end
    end
end

function game:render_scene(w,h)
    game:update_scene(w,h)
    
    love.graphics.setColor(1,1,1)
    love.graphics.draw(game.sceneCanvas, 0,0,0,1,1)
end

function game:draw()
    local t1 = os.clock()
    
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    game:render_scene(w,h)

    if CONFIG.DISPLAY_MAP then
        game.minimap:render()
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

    for i=1,100 do
        prev_pos.x = current_pos.x
        prev_pos.y = current_pos.y

        current_pos.x = current_pos.x + eps * math.cos(angle)
        current_pos.y = current_pos.y + eps * math.sin(angle)

        local x_i = math.floor(current_pos.x)
        local y_i = math.floor(current_pos.y)

        if not (game.nodes.storage.min_pos.x <= x_i and
                game.nodes.storage.min_pos.y <= y_i and
                x_i <= game.nodes.storage.max_pos.x and
                y_i <= game.nodes.storage.max_pos.y) then
            return false
        end

        if (angle >= 0 and angle < math.pi/2) then
            local x_a = (x_i + 1)
            local y_a = (y_i + 1)

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
            local x_a = (x_i)
            local y_a = (y_i + 1)

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
            local x_a = (x_i)
            local y_a = (y_i)

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
            local x_a = (x_i + 1)
            local y_a = (y_i)

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

        local eps = 1e-10

        local pos = {x = current_pos.x + eps * math.cos(angle),
                     y = current_pos.y + eps * math.sin(angle)}

        local isWall = game:isWall(pos)
        local isMirror = game:isMirror(pos)

        if isMirror then
            local wallX = math.floor(current_pos.x)
            local wallY = math.floor(current_pos.y)
            local dx = current_pos.x - wallX + 1/2
            local dy = current_pos.y - wallY - 1/2

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
            local side = "px" -- default side

            -- compute side
            local x_l = current_pos.x % 1
            local y_l = current_pos.y % 1

            --[[
                Node and its sides:
                     ny
                    -----
                    |\ /|
                 nx | x | px
                    |/ \|
                    -----
                     py
                Top left side is the origin, coordiante system is (x_l, y_l)
            --]]

            if     (y_l > 1 - x_l and y_l > x_l) then
                side = "py"
            elseif (y_l < 1 - x_l and y_l < x_l) then
                side = "ny"
            elseif (y_l > 1 - x_l and y_l < x_l) then
                side = "px"
            elseif (y_l < 1 - x_l and y_l > x_l) then
                side = "nx"
            end

            local offset = math.sqrt(y_l^2 + x_l^2)

            return distance, side, points, offset, game.nodes:get(pos.x,pos.y), pos
        end
    end

    return false -- didn't find anything :(
end

function game:isWall(pos)
    return game.nodes:contains(pos)
end

function game:isMirror(pos)
    return false -- stub
end

function game:keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f" then
        CONFIG.FISH_EYE = not CONFIG.FISH_EYE
    elseif key == "tab" then
        if love.keyboard.isDown("lshift") then
            CONFIG.EDITOR = not CONFIG.EDITOR
            game.minimap:switch_editor()
        else
            CONFIG.DISPLAY_MAP = not CONFIG.DISPLAY_MAP
        end
    elseif key == "t" then
        CONFIG.TEXTURES = not CONFIG.TEXTURES
    end
end

return game
