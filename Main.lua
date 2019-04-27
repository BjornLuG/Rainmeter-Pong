-- Main Pong game engine

function Initialize()
    -- Get Variables
    -- + 0 to make string to number
    gameWidth = SKIN:GetVariable('GameWidth') + 0
    gameHeight = SKIN:GetVariable('GameHeight') + 0
    gamePadding = SKIN:GetVariable('GamePadding') + 0
    playerWidth = SKIN:GetVariable('PlayerWidth') + 0
    playerHeight = SKIN:GetVariable('PlayerHeight') + 0
    playerMoveSpeed = SKIN:GetVariable('PlayerMoveSpeed') + 0
    ballMoveSpeed = SKIN:GetVariable('BallMoveSpeed') + 0
    ballDiameter = SKIN:GetVariable('BallRadius') * 2

    -- Computed
    playerPosYMax = gameHeight - playerHeight
    player1MinX = gamePadding
    player1MaxX = gamePadding + playerWidth
    player2MinX = gameWidth - gamePadding - playerWidth - ballDiameter
    player2MaxX = gameWidth - gamePadding - ballDiameter

    -- Runtime
    playerPosY1 = 0
    playerPosY2 = 0
    score1 = 0
    score2 = 0
 
    ballPosX = 0
    ballPosY = 0

    -- Key movement
    inputUp1 = false
    inputDown1 = false
    inputUp2 = false
    inputDown2 = false

    playerMoveY1 = 0
    playerMoveY2 = 0

    ballMoveX, ballMoveY = 0, 0

    -- Delta time (in secs)
    dt = 0
    prevTime = os.clock()

    -- Wait time before game starts
    gameWait = 3

    -- Start game, by restarting it
    RestartGame()
end

function Update()
    UpdateDt()

    if gameWait > 0 then
        gameWait = gameWait - dt
        return
    end

    if inputUp1 ~= inputDown1 then
        if inputUp1 then
            playerPosY1 = clamp(playerPosY1 - playerMoveSpeed * dt, 0, playerPosYMax)
        elseif inputDown1 then
            playerPosY1 = clamp(playerPosY1 + playerMoveSpeed * dt, 0, playerPosYMax)
        end
    end

    if inputUp2 ~= inputDown2 then
        if inputUp2 then
            playerPosY2 = clamp(playerPosY2 - playerMoveSpeed * dt, 0, playerPosYMax)
        elseif inputDown2 then
            playerPosY2 = clamp(playerPosY2 + playerMoveSpeed * dt, 0, playerPosYMax)
        end
    end

    -- Update Ball Pos
    ballPosX = ballPosX + ballMoveX * ballMoveSpeed * dt
    ballPosY = ballPosY + ballMoveY * ballMoveSpeed * dt

    CheckBall()

    UpdateRMView()
end

function Player1Up(val)
    inputUp1 = val
end

function Player1Down(val)
    inputDown1 = val
end

function Player2Up(val)
    inputUp2 = val
end

function Player2Down(val)
    inputDown2 = val
end

function UpdateDt()
    dt = os.clock() - prevTime
    prevTime = os.clock()
end

function RestartGame()
    playerPosY1 = (gameHeight - playerHeight) / 2
    playerPosY2 = (gameHeight - playerHeight) / 2

    ballPosX = (gameWidth - ballDiameter) / 2
    ballPosY = (gameHeight - ballDiameter) / 2

    ballMoveX, ballMoveY = GetRandomNormVector()

    gameWait = 3

    UpdateRMView()
end

function UpdateRMView()
    -- Set Variables
    SKIN:Bang('!SetVariable', 'PlayerPosY1', playerPosY1)
    SKIN:Bang('!SetVariable', 'PlayerPosY2', playerPosY2)

    SKIN:Bang('!SetVariable', 'BallPosX', ballPosX)
    SKIN:Bang('!SetVariable', 'BallPosY', ballPosY)

    -- Update and Redraw
    SKIN:Bang('!UpdateMeterGroup', 'Game')
    SKIN:Bang('!Redraw')
end

function UpdateScore()
    -- Set Variables
    SKIN:Bang('!SetVariable', 'Score1', score1)
    SKIN:Bang('!SetVariable', 'Score2', score2)

    -- Update and Redraw
    SKIN:Bang('!UpdateMeterGroup', 'Score')
    SKIN:Bang('!Redraw')
end

function CheckBall()
    if ballPosX > player1MaxX and ballPosX < player2MinX and ballPosY > 0 and ballPosY + ballDiameter < gameHeight then
        -- Is in free area, not collisions
        return
    elseif ballPosX + ballDiameter < 0 then
        -- Player 1 loses, Player 2 wins
        score2 = score2 + 1
        UpdateScore()
        RestartGame()
    elseif ballPosX > gameWidth + ballDiameter then
        -- Player 2 loses, Player 1 wins
        score1 = score1 + 1
        UpdateScore()
        RestartGame()
    elseif (ballPosY <= 0 and ballMoveY < 0) or (ballPosY + ballDiameter >= gameHeight and ballMoveY > 0) then
        -- Hit top or bottom border
        ballMoveY = -ballMoveY
    elseif (ballPosX >= player1MinX and 
            ballPosX <= player1MaxX and 
            ballPosY >= playerPosY1 and 
            ballPosY <= playerPosY1 + playerHeight and
            ballMoveX < 0) or
           (ballPosX >= player2MinX and
            ballPosX <= player2MaxX and
            ballPosY >= playerPosY2 and 
            ballPosY <= playerPosY2 + playerHeight and
            ballMoveX > 0) then
        -- If hit on player1's paddle or player2's paddle
        ballMoveX = -ballMoveX
        -- Hehehe... You found an easter egg
        -- Speed will gradually increase hor every paddle hit
        ballMoveSpeed = ballMoveSpeed + 2
    end
end

function clamp(val, min, max)
    if val < min then 
        return min
    elseif val > max then
        return max
    else
        return val
    end
end

function GetRandomNormVector()

    local y = RandomFloat(0.4, 0.6)
    local x = math.sqrt(1 - y * y)

    if math.random() > 0.5 then y = -y end
    if math.random() > 0.5 then x = -x end

    return x, y
end

function RandomFloat(min, max)
    return min + math.random() * (max - min)
end