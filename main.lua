require("globals")

function love.load()
    love.graphics.setFont(love.graphics.newFont("assets/unifont-11.0.01.ttf"))
    love.graphics.setDefaultFilter("nearest")

    Gamestate.registerEvents()
--    Gamestate.switch(states.menu.main) -- go straight to game regime
    Gamestate.switch(states.game)
end
