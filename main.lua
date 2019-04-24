require("globals")

function love.load()
    love.graphics.setFont(love.graphics.newFont("assets/unifont-11.0.01.ttf"))

    love.window.setMode(0, 0, {depth=5,})

    Gamestate.registerEvents()
--    Gamestate.switch(states.menu.main) -- go straight to game regime
    Gamestate.switch(states.game)
end
