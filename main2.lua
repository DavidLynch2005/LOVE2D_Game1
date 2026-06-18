-- ========================================
-- GLOBAL PHYSICS CONSTANTS AND VARIABLES
-- ========================================

local GRAVITY = 980           -- Pixels per second squared (downwards)
local DRAG_LIMIT = 300         -- Max distance the bird can be pulled back (pixels)
local SPRING_STRENGTH = 150    -- Multiplier for launch force (higher = harder launch)
local BIRD_RADIUS = 20

-- State variables
local state = "AIMING" -- Possible states: "HOVERING", "AIMING", "FLYING", "RESET"

-- Bird object properties
local bird = {
    x = 150,      -- Initial X position (above the slingshot)
    y = 300,      -- Initial Y position (at the slingshot height)
    radius = BIRD_RADIUS,
    vx = 0,        -- Velocity X
    vy = 0,        -- Velocity Y
    isLaunched = false,
}

-- Slingshot object properties
local sling = {
    x = 50,       -- Anchor point for the slingshot (where bird starts)
    y = 300,      -- Height of the slingshot anchor
    width = 80,   -- Visual width of the slingshot base
}

-- Aiming variables
local dragStartPoint = nil -- Stores the mouse position when dragging started
local currentDragVector = {x = 0, y = 0} -- The vector representing the pull force


----------------------------------------
-- I. LOVE2D CALLBACKS
----------------------------------------

function love.load()
    print("Game Loaded. Click and drag to aim.")
end

function love.update(dt)
    if state == "RESET" then
        -- Simple mechanism to transition out of RESET state after a delay (e.g., 1 second)
        -- In a real game, you'd use a timer, but for simplicity, we just check if the bird is stationary
        if math.abs(bird.vx) < 5 and math.abs(bird.vy) < 5 then
             state = "HOVERING"
             return
        end
    end

    if state == "AIMING" or state == "HOVERING" then
        -- When hovering/aiming, the bird's velocity is zeroed out
        bird.vx = 0
        bird.vy = 0
    elseif state == "FLYING" then
        -- Apply Gravity (Acceleration)
        bird.vy += GRAVITY * dt

        -- Update Velocity
        bird.vx = math.min(math.max(bird.vx, -1000), 1000) -- Clamp velocity just in case
        bird.vy = math.min(math.max(bird.vy, -1000), 1000)

        -- Update Position
        bird.x += bird.vx * dt
        bird.y += bird.vy * dt

        -- Check for Ground Collision (Simple boundary check)
        local groundLevel = 400 -- The bottom of the screen where it "lands"
        if bird.y + BIRD_RADIUS > groundLevel then
            -- Stop movement upon hitting the ground and transition to reset state
            bird.y = groundLevel - BIRD_RADIUS
            bird.vy = 0
            state = "RESET"
        end
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1) -- White for the bird

    -- 1. Draw Slingshot (Static element)
    love.graphics.rectangle("fill", sling.x - sling.width / 2, sling.y, sling.width, 50)
    
    -- Optional: Draw a line showing the anchor point
    love.graphics.circle("line", sling.x + sling.width/2 + 10, sling.y, 5)


    -- 2. Handle Drawing based on State
    if state == "AIMING" or state == "HOVERING" then
        -- Draw the bird at its fixed slingshot position
        love.graphics.circle("fill", bird.x, bird.y, BIRD_RADIUS)

        -- If dragging, visualize the pull vector/ghost mouse location
        if dragStartPoint and love.mouse.isDown(1) then
             local aimX = math.max(sling.x + 50, love.mouse.getX())
             local aimY = love.mouse.getY()

            -- Draw a line showing the aiming direction (from sling anchor to mouse)
            love.graphics.setLineWidth(3)
            love.graphics.line(sling.x + sling.width / 2, slingshot.y, aimX, aimY)
        end

    elseif state == "FLYING" then
        -- Draw the bird at its current physical location
        love.graphics.circle("fill", bird.x, bird.y, BIRD_RADIUS)

    elseif state == "RESET" or state == "HOVERING" then
         -- Draw the bird on the ground if reset/idle
         love.graphics.circle("fill", bird.x, bird.y, BIRD_RADIUS)
    end

    -- Instructions / Debug Info
    love.gui.text("State: " .. state .. " | Drag Limit: " .. DRAG_LIMIT)
    if math.abs(bird.vx) > 1 or math.abs(bird.vy) > 1 then
        love.gui.text("V=(" .. math.floor(math.abs(bird.vx)) / 10) .. ", " .. math.floor(math.abs(bird.vy)) / 10 .. ")")
    end
end


----------------------------------------
-- II. MOUSE INPUT HANDLERS
----------------------------------------

function love.mousepressed(x, y, button)
    if button == 1 then -- Left click
        if state == "AIMING" or state == "HOVERING" then
            dragStartPoint = {x = x, y = y}
            state = "AIMING"
            print("Aiming started.")
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and (state == "AIMING") then
        -- The user released the mouse, time to launch!
        local dragEnd = {x = x, y = y}
        
        -- Calculate the vector from the bird's anchor point (sling right edge) 
        -- to where the mouse was released.
        local slingAnchorX = sling.x + sling.width / 2
        local slingAnchorY = sling.y
        
        -- The displacement vector is (Start - End) because we pull back 
        -- against the direction of movement.
        local dx_pull = slingshot.x - dragEnd.x
        local dy_pull = slingshot.y - dragEnd.y

        -- Calculate the actual pulling force applied, limited by DRAG_LIMIT
        local pullDistance = math.sqrt(dx_pull^2 + dy_pull^2)
        if pullDistance > DRAG_LIMIT then
            dx_pull *= (DRAG_LIMIT / pullDistance)
            dy_pull *= (DRAG_LIMIT / pullDistance)
        end

        -- Apply launch force: Force is proportional to the pull distance, 
        -- and applied in the direction of the pull.
        local forceX = dx_pull * SPRING_STRENGTH
        local forceY = dy_pull * SPRING_STRENGTH

        -- Set initial velocities for flying physics
        bird.vx = forceX
        bird.vy = forceY

        state = "FLYING"
        dragStartPoint = nil -- Clear the aiming state
        print(string.format("Launch! V=(%.2f, %.2f)", bird.vx, bird.vy))
    end
end

function love.mousemoved(x, y, dx, dy, isTouch)
    if state == "AIMING" and love.mouse.isDown(1) then
        -- If the user is actively dragging, we just update the position 
        -- (The calculation for force happens only on release).
        -- We don't need to do anything complex here other than drawing it.
    end
end

----------------------------------------
-- III. UTILITY FUNCTIONS
----------------------------------------

local slingshot = {x = 150, y = 300} -- Global reference for the slingshot center point


function check_state(new_state)
    if state == "HOVERING" and new_state == "AIMING" then
        -- Transition to Aiming only if we are stationary/hovering
        state = new_state
    elseif state == "FLYING" and new_state == "RESET" then
         -- Transition after hitting the ground
        print("Impact! Waiting for reset...")
        -- Set initial position back to the slingshot anchor (visually)
        bird.x = sling.x + BIRD_RADIUS * 2
        bird.y = sling.y - BIRD_RADIUS
        state = "RESET"
    elseif state == "RESET" and new_state == "HOVERING" then
        -- Reset movement parameters
        bird.vx = 0
        bird.vy = 0
        state = "HOVERING"
    end
end

-- Initial Setup: Start the game in a hovering state
check_state("HOVERING")
