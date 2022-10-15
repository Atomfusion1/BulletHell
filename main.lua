local anim8 = require("src/anim8/anim8")
local moonshine = require('shader')

math.randomseed(os.time())

local gameState = {
    timer = 0,
    -- Seconds for a single Spawn Start at 1 mob per min 
    mobsPerMin = 1,
    spawnRate = 60,
    -- Time to half the Spawn Rate 
    mobUpgrade = 10,
    mobUpgradeTimer = 0,
    playerUpgrade = 0,

}
gameState.spawnRate = 60/gameState.mobsPerMin
-- Use This for Copying a Fresh Table for Mob Spawn 
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Random Values for Spawned Mobs 
function SpawnMob(tMob)
    --print("Spawn Mob ")
    gameState.timer = love.timer.getTime()
    local windowWidth, windowHeight = love.window.getMode()
    tMob.position.x = math.random(10, windowWidth)
    tMob.position.y = math.random(-20, -220)
    tMob.velocity = math.random(100,500)/100
    tMob.bullet.speed = math.random(40,300)
    if tMob.bullet.speed > 290 then 
            tMob.bullet.speed = math.random(300,550)
        if tMob.bullet.speed > 500 then 
            tMob.bullet.speed = math.random(500,850)
        end
    end
    tMob.bullet.coolDown = math.random (10,800)/1000
    tMob.hitPoints.current = tMob.hitPoints.max
    tMob.bullet.shotNumCoolDown = math.random(20, 500)/100
    tMob.bullet.shotNum = math.random(1, 50)
    tMob.bullet.height = math.random(45, 100)/10
    if tMob.bullet.height > 9 then
        tMob.bullet.height = math.random(10, 50)
    end
    local randomBulletType = math.random(1,20)
    if randomBulletType < 10 then
        tMob.bullet.bulletType = 'single'
        tMob.planeColor = {.5, .8, .4, 1}
    elseif randomBulletType < 16 then
        tMob.bullet.bulletType = 'double'
        tMob.planeColor = {.5, .6, .8, 1}
    else
        tMob.bullet.bulletType = 'spiral'
        tMob.velocity = math.random(50,150)/100
        tMob.bullet.speed = math.random(50,200)
        tMob.bullet.coolDown = math.random (10,100)/1000
        tMob.bullet.shotNumCoolDown = math.random(50, 200)/100
        tMob.bullet.shotNum = math.random(8, 30)
        tMob.bullet.height = math.random(45, 80)/10
        tMob.planeColor = {1, .6, .6, 1}
    end
    
    tMob.bullet.width = tMob.bullet.height
    tMob.bullet.r = math.random(200,1000)/1000
    tMob.bullet.g = math.random(200,1000)/1000
    tMob.bullet.b = math.random(200,1000)/1000
    tMob.bullet.alpha = math.random(500,1000)/1000
    tMob.hitPoints.current = math.random(2, 16)
    tMob.position.scale = 2
    if tMob.hitPoints.current > 14 then
        tMob.hitPoints.current = math.random(20, 50)
        tMob.position.scale = 3
        -- Big Mob Rare 
        if tMob.hitPoints.current > 49 then
            tMob.hitPoints.current = math.random(75, 100)
            tMob.bullet.bulletType = 'double'
            tMob.bullet.speed = math.random(300,550)
            tMob.bullet.shotNum = math.random(15, 50)
            tMob.bullet.height = math.random(35, 100)/10
            tMob.position.scale = 5
            tMob.planeColor = {1, 1, .1, 1}
        end
    end
    tMob.hitPoints.max = tMob.hitPoints.current
end

-- music setup
local music = {
    love.audio.newSource("music/Beyond the Mind.mp3", "stream"),
    love.audio.newSource("music/Electrica.mp3", "stream"),
    love.audio.newSource("music/OutOfTime.mp3", "stream"),
    love.audio.newSource("music/cinematic.mp3", "stream"),
    love.audio.newSource("music/sweetheat.mp3", "stream"),
    love.audio.newSource("music/kobrin.mp3", "stream"),
    songMax = 6
}
music.songNumber = math.random(1,6);
music[1]:setVolume(.05)
music[2]:setVolume(.05)
music[3]:setVolume(.05)
music[4]:setVolume(.05)
music[5]:setVolume(.05)
music[6]:setVolume(.05)

-- Sound Effects 
local effects = {
    love.audio.newSource("efx/pistol.mp3 ", "static"),
    love.audio.newSource("efx/explosion1.wav ", "static"),
    love.audio.newSource("efx/explosion2.wav ", "static")
}

-- Brackground Images 
local background = {
    graphics = {
        --[1] = love.graphics.newImage('images/background/starfield1.jpg'),
        --[2] = love.graphics.newImage('images/background/starfield2.jpg'),
        --[3] = love.graphics.newImage('images/background/starfield3.jpg'),
        [4] = love.graphics.newImage('images/background/starfield4.jpg'),
        [5] = love.graphics.newImage('images/background/starfield5.jpg'),
        --[6] = love.graphics.newImage('images/background/starfield6.jpg')
    }
}

-- Player Table 
local player = {
    state = 'idle',
    graphics = {
        love.graphics.newImage('images/mobs/1945.png'),
        love.graphics.newImage('images/player/XWing.png'),
    },
    draw = "rectangle",
    position = {
        x = love.graphics.getWidth( )/2,
        y = love.graphics.getHeight( ) - love.graphics.getHeight( )/8,
        draw = "rectangle",
        h = 32,
        w = 32,
        rot = -1.6,
        scale = .5,
    },
    hitPoints = {
        current = 10,
        max = 10
    },
    bullet = {
        speed = 350,
        width = 5,
        height = 5,
        coolDown = .050,
        timer = 0,
        shotNumCoolDown = .100,
        shotNum = 20,
        shotTracker = 0,
        shotTimer = 0,
        bulletType = "single",
        bulletOdd = false,
        angle = math.random(1, 180),
        r = .7, 
        g = 0, 
        b = 0, 
        alpha = .6
    },
    bulletTable = {
    },
    velocity = 4,
    animations = {},
    efx = true,
    score = 0,
    highScore = 180, 
    planeColor = {1,1,1,1}
}
-- Player Setup
player.graphics.grid = anim8.newGrid(102,80, player.graphics[2]:getWidth(), player.graphics[2]:getHeight(),3,3,1)
player.animations.down = anim8.newAnimation(player.graphics.grid(1,1), .1)

-- Mob Tables 
local mobs = {
    state = "idle",
    graphics = {
        love.graphics.newImage('images/mobs/1945.png')
    },
    position = {
        x = 400,
        y = 200,
        draw = "rectangle",
        h = 25,
        w = 25,
        rot = 0,
        scale = 8,
    },
    hitPoints = {
        current = 50,
        max = 50
    },
    bullet = {
        speed = 250,
        width = 6,
        height = 6,
        coolDown = .550,
        timer = 0,
        shotNumCoolDown = 5,
        shotNum = 10,
        shotTracker = 0,
        shotTimer = 0,
        bulletType ='double',
        bulletOdd = false,
        angle = math.random(1, 180),
        r = 1,
        g = 1,
        b = 1,
        alpha = 1,
    },
    bulletTable = {
    },
    velocity = 1,
    animations = {},
    efx = false,
    score = 0,
    planeColor = {1,.6 ,.9,1}
}
-- colors 1,.6,.6,1 red
-- .5 .6 .8 1 blue 
--  .5 .8 .4 1 green 
-- .9 1 .1 1yellow 
-- 1 .6 .9 1 pink
-- initial mob Setup 
mobs.position.x = math.random(10, 200)
mobs.position.y = math.random(-32, -400)
mobs.graphics.grid = anim8.newGrid(32,32, mobs.graphics[1]:getWidth(), mobs.graphics[1]:getHeight(),3,3,1)
mobs.animations.down = anim8.newAnimation(mobs.graphics.grid('4-6',15, 5,15), .1)
local explosionAnim8 = {}
explosionAnim8.anim8 = false
explosionAnim8.grid = anim8.newGrid(32,32, mobs.graphics[1]:getWidth(), mobs.graphics[1]:getHeight(),3,3,1)
explosionAnim8.anim8 = anim8.newAnimation(mobs.graphics.grid('3-8', 6), .8)

-- Setup Spawn Mobs 
local screenMobs = {}
screenMobs[1] = deepcopy(mobs)
SpawnMob(screenMobs[1])

local bulletTableMob = {}
local bulletTablePlayer = {}
local mobSpawnTable = {}
local playerSpawnTable = {}

local showCollisionBox = false

function InsertBulletIntoTable(tBullet, tVector, tChar)
    tChar.bullet.shotTracker = tChar.bullet.shotTracker + 1
    table.insert(tBullet, {x = tVector.x, y = tVector.y, dx = tVector.dx, dy = tVector.dy, h = tChar.bullet.height, w = tChar.bullet.width,r = tChar.bullet.r, g = tChar.bullet.g, b = tChar.bullet.b, alpha = tChar.bullet.alpha, })
end

--Lets Check if we are Past cooldown and create a bullet 
function FireBullet(tCharacter, tBulletTable, dirX, dirY, dt)
    if (tCharacter.state ~= 'idle') then return end
    if tCharacter.bullet.bulletType == 'double' or tCharacter.bullet.bulletType == 'spiral' then
        if tCharacter.bullet.timer < tCharacter.bullet.coolDown then
            tCharacter.bullet.timer = tCharacter.bullet.timer + dt
            return
        end
    else
        if tCharacter.bullet.timer < tCharacter.bullet.coolDown*2 then
            tCharacter.bullet.timer = tCharacter.bullet.timer + dt
            return
        end
    end
    --print(player.bullet.shotTracker , player.bullet.shotNum , player.bullet.shotTimer , player.bullet.shotNumCoolDown)
    if tCharacter.bullet.shotTracker > tCharacter.bullet.shotNum then
        if tCharacter.bullet.shotTimer < tCharacter.bullet.shotNumCoolDown then
            tCharacter.bullet.shotTimer = tCharacter.bullet.shotTimer + dt
            return
        else
            tCharacter.bullet.shotTracker = 0
        end
    end

    if tCharacter.efx then
        effects[1]:stop()
        effects[1]:setVolume(.02)
        effects[1]:setPitch(10)
        effects[1]:play()
    end
    tCharacter.bullet.shotTimer = 0
    tCharacter.bullet.timer = 0
    local angle = math.atan2((dirY - tCharacter.position.y), (dirX - tCharacter.position.x))
    local mathCos = math.cos(angle)
    local mathSin = math.sin(angle)
    tCharacter.position.rot = angle
    local startXa, startYa

    if tCharacter.bullet.bulletType == 'double' then
        if tCharacter.bullet.bulletOdd then
            tCharacter.bullet.bulletOdd = false
            startXa = tCharacter.position.x + 10*mathCos + 20*mathSin
            startYa = tCharacter.position.y + 10*mathSin - 20*mathCos
        else
            tCharacter.bullet.bulletOdd = true
            startXa = tCharacter.position.x + 10*mathCos - 20*mathSin
            startYa = tCharacter.position.y + 10*mathSin + 20*mathCos
        end
        angle = angle + love.math.random(-50, 50)/2000
    elseif tCharacter.bullet.bulletType == 'single' then
        tCharacter.bullet.bulletOdd = true
        startXa = tCharacter.position.x  + 10*mathCos
        startYa = tCharacter.position.y  + 10*mathSin
        angle = angle + love.math.random(-50, 50)/2000
    elseif tCharacter.bullet.bulletType == 'spiral' then 
        --print("Spiral Bullet")
        startXa = tCharacter.position.x  + math.cos(tCharacter.bullet.angle)
        startYa = tCharacter.position.y  + math.sin(tCharacter.bullet.angle)
        angle = tCharacter.bullet.angle + love.math.random(-50, 50)/2000
        local bulletSpeed = tCharacter.bullet.speed
        local bulletDx = bulletSpeed * math.cos(angle)
        local bulletDy = bulletSpeed * math.sin(angle)
        local tVector = {x = startXa, y = startYa, dx = bulletDx, dy = bulletDy}
        InsertBulletIntoTable(tBulletTable, tVector, tCharacter)
        tCharacter.bullet.angle = tCharacter.bullet.angle + 3.4
        angle = tCharacter.bullet.angle + love.math.random(-50, 50)/2000
    else
        tCharacter.bullet.bulletOdd = true
        startXa = tCharacter.position.x  + 10*mathCos
        startYa = tCharacter.position.y  + 10*mathSin
        angle = angle + love.math.random(-50, 50)/2000
    end

    tCharacter.bullet.angle = tCharacter.bullet.angle + 3.4
    
    local bulletSpeed = tCharacter.bullet.speed
    local bulletDx = bulletSpeed * math.cos(angle)
    local bulletDy = bulletSpeed * math.sin(angle)
    local tVector = {x = startXa, y = startYa, dx = bulletDx, dy = bulletDy}
    InsertBulletIntoTable(tBulletTable, tVector, tCharacter)
end

-- Update Mob Position 
function MobUpdates(tMobs)
    local windowWidth, windowHeight = love.window.getMode()
    if tMobs.hitPoints.current <= 0 and tMobs.state == 'spawn' then
        SpawnMob(tMobs)
        tMobs.state = 'idle'
    end
    if not (tMobs.hitPoints.current <= 0) then
        tMobs.position.y = tMobs.position.y + tMobs.velocity
    end
    if tMobs.position.y > windowHeight then tMobs.position.y = -32 end

end

-- Check Collision 
function CheckCollision(tCharacter, tMobs)
    local x1 = tCharacter.x - tCharacter.w/2
    local y1 = tCharacter.y - tCharacter.h/2
    local w1 = tCharacter.w
    local h1 = tCharacter.h

    local x2 = tMobs.x
    local y2 = tMobs.y
    local w2 = tMobs.w
    local h2 = tMobs.h
    return x1 < x2+w2 and
        x2 < x1+w1 and
        y1 < y2+h2 and
        y2 < y1+h1
end

-- Move Bullets every frame 
function UpdateBulletLocation(tCharacter, dt)
    local windowWidth, windowHeight = love.window.getMode()
    for i,v in ipairs(tCharacter) do
		v.x = v.x + (v.dx * dt)
		v.y = v.y + (v.dy * dt)
        if v.x > windowWidth or v.y > windowHeight or v.x < 0 or v.y < 0 then
            table.remove(tCharacter, i)
        end
    end
end

-- Load Mobs and Bullets into Collision Box then Check Collision
function CheckForCollisions(tBullets, tMobs)
    -- collisions player bullets 
    -- reset collision box 
    tBullets.collisionBox = {}
    local width = tMobs.position.w*tMobs.position.scale
    local height = tMobs.position.h*tMobs.position.scale
    table.insert(tBullets.collisionBox, { draw = tMobs.position.draw, x = tMobs.position.x - width/2, y = tMobs.position.y - height/2, h = height, w = width})
    for i,v in ipairs(tBullets) do
        table.insert(tBullets.collisionBox, { draw = "rectangle", x = v.x-v.w/2, y = v.y-v.h/2, h = v.h, w = v.w})
        if CheckCollision(v, tBullets.collisionBox[1]) then
            tMobs.hitPoints.current = tMobs.hitPoints.current - 1
            table.remove(tBullets, i)
        end
	end

end

-- Check Keyboard
function CheckKeyboard(dt)
    -- Keyboard Controls
    if love.mouse.isDown(1) then
        -- PLAYER SHOOT 
        --player.bullet.timer, angle = FireBullet(player.position.x, player.position.y, love.mouse.getX(), love.mouse.getY(), bullets, player.bullet, dt, true, player.state)
        FireBullet(player, bulletTablePlayer, love.mouse.getX(), love.mouse.getY(), dt)
    end
    if love.mouse.isDown(2) then
        -- PLAYER SHOOT 
        --player.bullet.timer, angle = FireBullet(player.position.x, player.position.y, love.mouse.getX(), love.mouse.getY(), bullets, player.bullet, dt, true, player.state)
        player.velocity = 8
    else 
        player.velocity = 4
    end
    if love.keyboard.isDown('w') then
        if player.position.y > 0 then player.position.y = player.position.y - player.velocity end
    end
    local windowWidth, windowHeight = love.window.getMode()
    if love.keyboard.isDown('s') then
        if player.position.y < windowHeight then player.position.y = player.position.y + player.velocity end
    end
    if love.keyboard.isDown('a') then
        if player.position.x > 0 then player.position.x = player.position.x - player.velocity end
    end
    if love.keyboard.isDown('d') then
        if player.position.x < windowWidth then player.position.x = player.position.x + player.velocity end
    end
    if love.keyboard.isDown('space') then
        player.hitPoints.current = player.hitPoints.max
        screenMobs = {}
        bulletTableMob = {}
        screenMobs[1] = deepcopy(mobs)
        SpawnMob(screenMobs[1])
        gameState.spawnRate = 60
        gameState.mobsPerMin = 1
        if (player.highScore < player.score) then
            player.highScore = player.score
        end
        player.score = 0
        player.died = false
    end
end

-- Check Audio 
function IsAudioPlaying()
    -- cycle music 
    if not music[music.songNumber]:isPlaying() then
        music.songNumber = music.songNumber + 1
        if music.songNumber >= music.songMax then
            music.songNumber = 1
        end
        print("Playing Song ".. music.songNumber)        
        music[music.songNumber]:play()
    end
end

-- Check for Mob Death and cause explosion *Bug- No explosion*
function CheckForDeath(tCharacter)
    if tCharacter.state == 'sound' then
        effects[2]:stop()
        effects[2]:setVolume(1)
        effects[2]:setPitch(2)
        effects[2]:play()
        if (player.hitPoints.current > 0) then   player.score = player.score + 1 end
        tCharacter.state = 'exploding'
    end
end

-- TODO split into multiple test scripts
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    effect = moonshine(moonshine.effects.glow)
end

-- Change Mob Spawn Rate
function UpgradeMobs()
    if not (love.timer.getTime() - gameState.mobUpgradeTimer > gameState.mobUpgrade) then
        return
    end
    gameState.mobUpgradeTimer = love.timer.getTime()
    gameState.mobsPerMin = gameState.mobsPerMin + 1
    gameState.spawnRate = 60/gameState.mobsPerMin
    print(gameState.spawnRate)
    if gameState.spawnRate < .5 then gameState.spawnRate = .5 end
end
-- Update Player per mob death 
function UpgradePlayer()
    if player.score == 7 and gameState.playerUpgrade == 0 then
        gameState.playerUpgrade = player.score
        player.bullet.speed = player.bullet.speed +50
        player.bullet.coolDown = player.bullet.coolDown - player.bullet.coolDown/8        
    elseif player.score == 15 and gameState.playerUpgrade == 7 then
        gameState.playerUpgrade = player.score
        player.bullet.bulletType = "double"
        player.bullet.speed = player.bullet.speed +50
        player.bullet.coolDown = player.bullet.coolDown - player.bullet.coolDown/4
    elseif player.score == 30 and gameState.playerUpgrade == 15 then
        gameState.playerUpgrade = player.score
        player.bullet.bulletType = "double"
        player.bullet.speed = player.bullet.speed + 100
        player.bullet.coolDown = player.bullet.coolDown - player.bullet.coolDown/4
    elseif player.score == 50 and gameState.playerUpgrade == 30 then
        gameState.playerUpgrade = player.score
        player.bullet.bulletType = "double"
        player.bullet.speed = player.bullet.speed + 100
        player.bullet.coolDown = player.bullet.coolDown - player.bullet.coolDown/4
    elseif player.score == 100 and gameState.playerUpgrade == 50 then
        gameState.playerUpgrade = player.score
        player.bullet.bulletType = "double"
        player.bullet.speed = player.bullet.speed + 150
        player.bullet.coolDown = player.bullet.coolDown - player.bullet.coolDown/2
    end
end

-- UPDATE ***********
function love.update(dt)
    -- house keeping
    for i,mobs1 in ipairs(screenMobs) do
        mobs1.animations.down:update(dt)
    end
    explosionAnim8.anim8:update(dt)
    
    IsAudioPlaying()
    -- upgrades 
    UpgradeMobs()
    UpgradePlayer()
    -- spawn mobs 
    if love.timer.getTime() - gameState.timer >  gameState.spawnRate then
        table.insert(screenMobs, deepcopy(mobs))
        SpawnMob(screenMobs[#screenMobs])
    end

    -- Main Updates and Collision Checks 
    UpdateBulletLocation(bulletTablePlayer, dt)
    UpdateBulletLocation(bulletTableMob, dt)
    CheckForCollisions(bulletTableMob, player) 
    for i,mobs1 in ipairs(screenMobs) do
        if (mobs1.state == 'spawn' and i > 1) then
            table.remove(screenMobs, i)
            print("dead")
        end
        MobUpdates(mobs1)
        FireBullet(mobs1, bulletTableMob, player.position.x, player.position.y, dt)
        CheckForCollisions(bulletTablePlayer, mobs1) 
        CheckForDeath(mobs1)
    end
    CheckForDeath(player)
    -- Check for Player Input 
    CheckKeyboard(dt)
end

local function displayUI()
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle('fill', 0, 0, 230, 50)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle('line', 0, 0, 230, 50)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("FPS:", 10, 10)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(love.timer.getFPS(), 45, 10)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("MPM:", 10, 30)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(gameState.mobsPerMin, 45, 30)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Health:", 65, 10)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(player.hitPoints.current, 110, 10)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Score:", 140, 10)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(player.score, 190, 10)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("High Score:", 110, 30)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(player.highScore, 190, 30)
    if (player.hitPoints.current < 1 ) then 
        love.graphics.setColor(1,0,0,1)
        love.graphics.print("DEAD Press SPACE BAR", 100, 170, nil, 2)
    end

end


-- DRAW *********
function love.draw()
    love.graphics.setColor(1, 1, 1, .5)
    love.graphics.draw(background.graphics[5], 0, 0,0, .2,.2)
    love.graphics.setColor(1, 1, 1, .6)
    love.graphics.draw(background.graphics[4], (player.position.x/20-50), (player.position.y/20-50), 0, 2, 2)
    if player.hitPoints.current > 0 then
        love.graphics.setColor(player.planeColor)
        player.animations.down:draw(player.graphics[2], player.position.x, player.position.y, player.position.rot-1.57, .5, .5, 45, 16)
    elseif player.died == false then
        love.graphics.setColor(1, 1, 1, 1)
        if not player.state == 'sound' then explosionAnim8.anim8:gotoFrame(1) end
        player.state = 'sound'
        explosionAnim8.anim8:draw(player.graphics[1], player.position.x, player.position.y, player.position.rot-1.57, .8, .8, 45, 16)
        if explosionAnim8.anim8.position == 6 then
            player.died = true
        end
    end
    for i,mobs1 in ipairs(screenMobs) do
        if mobs1.hitPoints.current > 0 then
            mobs1.state = "idle"
            love.graphics.setColor(mobs1.planeColor)
            mobs1.animations.down:draw(player.graphics[1],mobs1.position.x, mobs1.position.y, 0, mobs1.position.scale, mobs1.position.scale, 16, 16)
        elseif mobs1.state == "idle" then
            mobs1.state = "sound"
            explosionAnim8.audio = true
            love.graphics.setColor(1, 1, 1, 1)
            explosionAnim8.anim8:gotoFrame(1)
            explosionAnim8.anim8:draw(player.graphics[1],mobs1.position.x, mobs1.position.y, 0, mobs1.position.scale, mobs1.position.scale, 16, 16)
        elseif mobs1.state =="exploding" then
            if explosionAnim8.anim8.position == 6 then
                mobs1.died = true
                mobs1.state = "spawn"
            end
        end
    end
    -- Draw Bullets 
	for i,v in ipairs(bulletTablePlayer) do
            love.graphics.setColor(v.r, v.g, v.b, v.alpha)
            love.graphics.circle("fill", v.x, v.y, v.h, v.h)
            love.graphics.setColor(v.r+2, v.g+.2, v.b+.2, .7)
            love.graphics.circle("fill", v.x, v.y, v.h/(math.random(10,30)/10))
	end
    -- Mob Bullets
    for i,v in ipairs(bulletTableMob) do
        love.graphics.setColor(v.r, v.g, v.b, v.alpha)
        love.graphics.circle("fill", v.x, v.y, v.h)
        love.graphics.setColor(v.r+.05, v.g+.05, v.b+.05, v.alpha+.2)
        love.graphics.circle("fill", v.x, v.y, v.h/(math.random(10,40)/10), 5)
        love.graphics.setColor(1-v.r, .5-v.g, 1-v.b, .5)
        love.graphics.circle("line", v.x, v.y, v.h, v.h, v.w)
    end
    -- Press Tab to activate Collision Box View 
    if showCollisionBox then
        for i,v in ipairs(bulletTablePlayer.collisionBox) do
            --print(v.draw, v.x, v.y, v.h, v.w)
            if v.draw == "circle" then
                love.graphics.setColor(0, 1, 0,1)
                love.graphics.circle("line", v.x, v.y, v.h)
            elseif v.draw == "rectangle" then
                love.graphics.setColor(0, 0, 1,1)
                love.graphics.rectangle("line", v.x, v.y, v.h, v.w)
            else print("undefined collision")
                table.remove(player.collisionBox, i)
            end
        end
        for i,v in ipairs(bulletTableMob.collisionBox) do
            --print(v.draw, v.x, v.y, v.h, v.w)
            if v.draw == "circle" then
                love.graphics.setColor(0, 1, 0,1)
                love.graphics.circle("line", v.x, v.y, v.h)
            elseif v.draw == "rectangle" then
                love.graphics.setColor(0, 0, 1,1)
                love.graphics.rectangle("line", v.x, v.y, v.h, v.w)
            else print("undefined collision")
                table.remove(player.collisionBox, i)
            end
        end
    end
    -- Display Score 
    displayUI()
end


-- Keyboard and Mouse 
function love.keypressed(key)
    if key == 'tab' then showCollisionBox = not showCollisionBox end
end

function love.keyreleased(key)
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end