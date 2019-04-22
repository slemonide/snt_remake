------------------------------------------------------------------------
-- This is the only place where global variables should be defined
-- Feel free to add anything here that is used often enough
------------------------------------------------------------------------

-- Load third-party libraries
Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"

states = {}
states.game =      require "game"

CONFIG = {
    NODE_SIZE = 20,
    SHADOW_SIZE = 300,
    WORLD_SIZE = 10,
    PLAYER_SPEED = 100,
    JUMP_SPEED = 200,
    GRAV_ACC = -200,
    -- 4 * math.pi
    FOV = math.pi/2,
    FOV_TRIANGLE_SIZE = 40,
    FOV_SPEED = 100 / 180 * math.pi,
    FISH_EYE_CORRECTION = false,
    FISH_EYE_FACTOR = 0.88
}
