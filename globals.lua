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
    NODE_SIZE = 30, -- 15
    MAP_NODE_SIZE = 30,
    SHADOW_SIZE = 300,
    WORLD_SIZE = 20,
    PLAYER_SPEED = 100,
    JUMP_SPEED = 200,
    GRAV_ACC = -200,
    -- 4 * math.pi
    FOV = math.pi / 180 * 74,
    FOV_TRIANGLE_SIZE = 20,
    FOV_SPEED = 100 / 180 * math.pi,
    DISPLAY_MAP = true,
    MAP_NUM_RAYS = 5,

    RENDER_MODE = "sq", -- one of "sq" and "cyl"
    CORRECTION_COEFF = 1
}
