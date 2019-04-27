local Player = Class{
    init = function(self, game)
    -- position, in pixel coordinates
    -- rotation, in radians, 0 is +x
        self.x = 2
        self.y = 2
        self.z = 0
        self.vz = 0 -- speed in the z direction
        self.rot = 0
        self.game = game
    end
}

function Player:update(dt)
    local last_pos = {
        x = self.x,
        y = self.y
    }

    if love.keyboard.isDown("w") then
        self.x = self.x + math.cos(self.rot) * CONFIG.PLAYER_SPEED * dt
        self.y = self.y + math.sin(self.rot) * CONFIG.PLAYER_SPEED * dt
    end
    if love.keyboard.isDown("e") then
        self.x = self.x + math.cos(self.rot + math.pi/2) * CONFIG.PLAYER_SPEED * dt
        self.y = self.y + math.sin(self.rot + math.pi/2) * CONFIG.PLAYER_SPEED * dt
    end
    if love.keyboard.isDown("s") then
        self.x = self.x - math.cos(self.rot) * CONFIG.PLAYER_SPEED * dt
        self.y = self.y - math.sin(self.rot) * CONFIG.PLAYER_SPEED * dt
    end
    if love.keyboard.isDown("q") then
        self.x = self.x + math.cos(self.rot - math.pi/2) * CONFIG.PLAYER_SPEED * dt
        self.y = self.y + math.sin(self.rot - math.pi/2) * CONFIG.PLAYER_SPEED * dt
    end

    -- collision detection
    if self.game:isWall(self) then
        self.x = last_pos.x
        self.y = last_pos.y
    end

    if love.keyboard.isDown("a") then
        self.rot = self.rot - CONFIG.FOV_SPEED * dt
    end
    if love.keyboard.isDown("d") then
        self.rot = self.rot + CONFIG.FOV_SPEED * dt
    end
    if love.keyboard.isDown("space") then
        if self.z == 0 then
            self.vz = CONFIG.JUMP_SPEED
            self.z = self.z + self.vz * dt
        end
    end

    -- jump
    if self.z <= 0 then
        self.vz = 0
        self.z = 0
    else
        self.z = self.z + self.vz * dt
        self.vz = self.vz + CONFIG.GRAV_ACC * dt
    end
end

return Player
