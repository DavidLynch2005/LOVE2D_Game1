local click

-- DEBUG STUFF --
if arg[2] == "debug" then
    require("lldebugger").start()
end
-- END DEBUG STUFF --

-- Track player clicks
local count = 0;

function love.load()
    
end


function love.draw()
    love.graphics.print(count, 400, 300)
     -- Define the x and y coordinates of the vertices
    local vertices = {400, 300, 450, 400, 350, 400}
    
    -- Draw a filled triangle
    love.graphics.polygon("fill", vertices)
    
    -- Or draw an outlined triangle
    -- love.graphics.polygon("line", vertices)
end

function love.update(dt)
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        
    end

    if love.keyboard.isDown("space") then 
        
    end
end

function love.keypressed(key, scancode, isrepeat)
    -- Triggers once when the Escape key is hit
    if key == "space" then
        count = count + 1;
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        count = count + 1;
        createClickEffect()
    elseif button == 2 then
       
    end
end


local function click_effect(x, y)
    local max_radius = 20;
    local start_radius = 5;
    local time = 1; --in seconds

    love.graphics.circle("fill", x, y, start_radius)

end


-- DEBUG STUFF --
local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end
-- END DEBUG STUFF --