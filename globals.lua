------------------------------------------------------------------------
-- This is the only place where global variables should be defined
-- Feel free to add anything here that is used often enough
------------------------------------------------------------------------

-- Load third-party libraries
Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"

states = {}
states.game =      require "game"

eps = 0.0001 -- just a small number

CONFIG = {
    NODE_SIZE = 15,
    SHADOW_SIZE = 300,
    WORLD_SIZE = 10,
    PLAYER_SPEED = 100,
    JUMP_SPEED = 200,
    GRAV_ACC = -200,
    -- 4 * math.pi
    FOV = math.pi / 180 * 74,
    FOV_TRIANGLE_SIZE = 40,
    FOV_SPEED = 100 / 180 * math.pi,

    RENDER_MODE = "sq", -- one of "sq" and "cyl"
    CORRECTION_COEFF = 1
}
