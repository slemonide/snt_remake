local game = {}

function game:init()
    -- 10x10 world
    -- 0 is floor
    -- 1 is wall
    game.world = {
    1,1,1,1,1,1,1,1,1,1,
    1,0,0,0,1,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,
    1,0,0,0,0,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,
    1,0,0,0,1,0,0,0,0,1,
    1,1,1,1,1,1,1,1,1,1,
    }

    -- player's state
    -- position, in pixel coordinates
    -- rotation, in radians, 0 is +x
    game.player = {
        x = 2 * CONFIG.NODE_SIZE,
        y = 2 * CONFIG.NODE_SIZE,
        z = 0,
        vz = 0, -- speed in the z direction
        rot = 0
    }
end

function game:update(dt)
    local last_pos = {
        x = game.player.x,
        y = game.player.y
    }

    if love.keyboard.isDown("w") then
        game.player.x = game.player.x + math.cos(game.player.rot) * CONFIG.PLAYER_SPEED * dt
        game.player.y = game.player.y + math.sin(game.player.rot) * CONFIG.PLAYER_SPEED * dt
    end
    if love.keyboard.isDown("e") then
        game.player.x = game.player.x + math.cos(game.player.rot + math.pi/2) * CONFIG.PLAYER_SPEED * dt
        game.player.y = game.player.y + math.sin(game.player.rot + math.pi/2) * CONFIG.PLAYER_SPEED * dt
    end
    if love.keyboard.isDown("s") then
        game.player.x = game.player.x - math.cos(game.player.rot) * CONFIG.PLAYER_SPEED * dt
        game.player.y = game.player.y - math.sin(game.player.rot) * CONFIG.PLAYER_SPEED * dt
    end
    if love.keyboard.isDown("q") then
        game.player.x = game.player.x + math.cos(game.player.rot - math.pi/2) * CONFIG.PLAYER_SPEED * dt
        game.player.y = game.player.y + math.sin(game.player.rot - math.pi/2) * CONFIG.PLAYER_SPEED * dt
    end

    -- collision detection
    if game:isWall(game.player) then
        game.player.x = last_pos.x
        game.player.y = last_pos.y
    end

    if love.keyboard.isDown("a") then
        game.player.rot = game.player.rot - CONFIG.FOV_SPEED * dt
    end
    if love.keyboard.isDown("d") then
        game.player.rot = game.player.rot + CONFIG.FOV_SPEED * dt
    end
    if love.keyboard.isDown("space") then
        if game.player.z == 0 then
            game.player.vz = CONFIG.JUMP_SPEED
            game.player.z = game.player.z + game.player.vz * dt
        end
    end

    -- jump
    if game.player.z <= 0 then
        game.player.vz = 0
        game.player.z = 0
    else
        game.player.z = game.player.z + game.player.vz * dt
        game.player.vz = game.player.vz + CONFIG.GRAV_ACC * dt
    end
end

function game:draw()
    local t1 = os.clock()

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    -- render scene
    for i=1,w do
        local rot = game.player.rot + (i - w/2) * CONFIG.FOV/w

        local dist, side = game:getDistanceToObstacle(rot)
        local shadow = math.min(dist/CONFIG.SHADOW_SIZE,0.5)
        if side == "x" then
            love.graphics.setColor(0.6-shadow,0.6-shadow,0.6-shadow)
        elseif side == "y" then
            love.graphics.setColor(0.55-shadow, 0.55-shadow,0.55-shadow)
        end
        --[[
        if side == "x" then
            love.graphics.setColor(0,0,1-math.min(dist/350,1))
        elseif side == "y" then
            love.graphics.setColor(0, 1-math.min(dist/350,1),0)
        end
        --]]
        love.graphics.line(i, game.player.z + h/2 - 10000/dist, i, game.player.z + h/2 + 10000/dist)
    end

    -- render map
    for i,v in ipairs(game.world) do
        x = ((i - 1) % CONFIG.WORLD_SIZE) * CONFIG.NODE_SIZE
        y = (math.floor((i - 1) / CONFIG.WORLD_SIZE)) * CONFIG.NODE_SIZE
        if v == 1 then
            love.graphics.setColor(0.70, 0.63, 0.05)
            love.graphics.rectangle("fill", x, y, CONFIG.NODE_SIZE, CONFIG.NODE_SIZE)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x, y, CONFIG.NODE_SIZE, CONFIG.NODE_SIZE)
    end

    love.graphics.setColor(1, 0.42, 0.64)
    love.graphics.arc("fill", game.player.x, game.player.y,
        CONFIG.FOV_TRIANGLE_SIZE,
        game.player.rot + CONFIG.FOV/2,
        game.player.rot - CONFIG.FOV/2)
    love.graphics.setColor(0.42, 0.63, 0.05)
    love.graphics.circle("fill", game.player.x, game.player.y, CONFIG.NODE_SIZE/4)

    love.graphics.setColor(0, 1, 0)
    for i=-50,50 do
        local rot = game.player.rot + i * CONFIG.FOV/100

        dist = game:getDistanceToObstacle(rot)
        love.graphics.line(game.player.x, game.player.y,
            game.player.x + math.cos(rot) * dist,
            game.player.y + math.sin(rot) * dist)
    end

    local t2 = os.clock()
    local fps = string.format("FPS: %.0f", 1/(t2 - t1))
    love.graphics.print(fps, w - 100, 10)
end

function game:getDistanceToObstacle(angle)
    local distance_so_far = 0

    local current_pos = {
        x = game.player.x,
        y = game.player.y
    }

    local step = 0.5
    local dp = {
        x = step * math.cos(angle),
        y = step * math.sin(angle)
    }

    for i=1,1000 do
            local isWall, ind = game:isWall(current_pos)
        if isWall then
            local wallY = math.floor(ind / CONFIG.WORLD_SIZE) * CONFIG.NODE_SIZE
            local wallX = (ind % CONFIG.WORLD_SIZE) * CONFIG.NODE_SIZE
            local dx = current_pos.x - wallX + CONFIG.NODE_SIZE/2
            local dy = current_pos.y - wallY - CONFIG.NODE_SIZE/2

            local angle_in = math.atan(dy/dx) + math.pi/4

            if CONFIG.FISH_EYE_CORRECTION then
                if math.tan(angle_in) > 0 then
                    return distance_so_far * math.cos((angle - game.player.rot) * CONFIG.FISH_EYE_FACTOR), "x"
                else
                    return distance_so_far * math.cos((angle - game.player.rot) * CONFIG.FISH_EYE_FACTOR), "y"
                end
            else
                if math.tan(angle_in) > 0 then
                    return distance_so_far, "x"
                else
                    return distance_so_far, "y"
                end
            end
        else
            current_pos.x = current_pos.x + dp.x
            current_pos.y = current_pos.y + dp.y
            distance_so_far = distance_so_far + step
        end
    end

    return distance_so_far, "x"
end

--[[
-- CONSTANT STEP VERSION
function game:getDistanceToObstacle(angle)
    local distance_so_far = 0
    local current_pos = {
        x = game.player.x,
        y = game.player.y
    }
    local step = 0.5
    local dp = {
        x = step * math.cos(angle),
        y = step * math.sin(angle)
    }
    for i=1,10000 do
            local isWall, ind = game:isWall(current_pos)
        if isWall then
            local wallY = math.floor(ind / CONFIG.WORLD_SIZE) * CONFIG.NODE_SIZE
            local wallX = (ind % CONFIG.WORLD_SIZE) * CONFIG.NODE_SIZE
            local dx = current_pos.x - wallX + CONFIG.NODE_SIZE/2
            local dy = current_pos.y - wallY - CONFIG.NODE_SIZE/2
           
            local angle_in = math.atan(dy/dx) + math.pi/4
 
            if CONFIG.FISH_EYE_CORRECTION then
                if math.tan(angle_in) > 0 then
                    return distance_so_far * math.cos((angle - game.player.rot) * CONFIG.FISH_EYE_FACTOR), "x"
                else
                    return distance_so_far * math.cos((angle - game.player.rot) * CONFIG.FISH_EYE_FACTOR), "y"
                end
            else
                if math.tan(angle_in) > 0 then
                    return distance_so_far, "x"
                else
                    return distance_so_far, "y"
                end
            end
        else
            current_pos.x = current_pos.x + dp.x
            current_pos.y = current_pos.y + dp.y
            distance_so_far = distance_so_far + step
        end
    end
    return distance_so_far, "x"
end
--]]

function game:isWall(pos)
    i = math.ceil(pos.x / CONFIG.NODE_SIZE) +
        math.floor((pos.y / CONFIG.NODE_SIZE)) * CONFIG.WORLD_SIZE
    if game.world[i] == 1 then
        return true, i
    else
        return false, i
    end
end

function game:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return game
