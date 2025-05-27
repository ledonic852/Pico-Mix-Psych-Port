local shootPlayerFrames = {}
local shootOpponentFrames = {}
for i = 0, 300 do
    shootPlayerFrames[i] = i + 878
    shootOpponentFrames[i] = i
end

local explodePlayerFrames = {}
local explodeOpponentFrames = {}
for i = 301, 576 do
    explodePlayerFrames[(i - 300)] = i + 878
    explodeOpponentFrames[(i - 300)] = i
end

local explodePlayerLoopFrames = {}
local explodeOpponentLoopFrames = {}
for i = 0, 7 do
    explodePlayerLoopFrames[(i + 1)] = explodePlayerFrames[(#explodePlayerFrames - (7 - i))]
    explodeOpponentLoopFrames[(i + 1)] = explodeOpponentFrames[(#explodeOpponentFrames - (7 - i))]
end

local cigarettePlayerFrames = {}
local cigaretteOpponentFrames = {}
for i = 577, 877 do
    cigarettePlayerFrames[(i - 576)] = i + 878
    cigaretteOpponentFrames[(i - 576)] = i
end

function onCreate()
    initSaveData('Pico_Mix_Variables')
    
    makeFlxAnimateSprite('dopplegangerPlayer', getProperty('boyfriend.x') + 45, getProperty('boyfriend.y') + 400)
    loadAnimateAtlas('dopplegangerPlayer', 'philly/cutscenes/pico_doppleganger')
    addAnimationBySymbolIndices('dopplegangerPlayer', 'shoot', 'picoDoppleganger', shootPlayerFrames)
    addAnimationBySymbolIndices('dopplegangerPlayer', 'explode', 'picoDoppleganger', explodePlayerFrames)
    addAnimationBySymbolIndices('dopplegangerPlayer', 'explode-loop', 'picoDoppleganger', explodePlayerLoopFrames, 24, true)
    addAnimationBySymbolIndices('dopplegangerPlayer', 'cigarette', 'picoDoppleganger', cigarettePlayerFrames)
    setObjectOrder('dopplegangerPlayer', getObjectOrder('boyfriendGroup'))
    addLuaSprite('dopplegangerPlayer')

    makeFlxAnimateSprite('dopplegangerOpponent', getProperty('dad.x') + 83, getProperty('dad.y') + 400)
    loadAnimateAtlas('dopplegangerOpponent', 'philly/cutscenes/pico_doppleganger')
    addAnimationBySymbolIndices('dopplegangerOpponent', 'shoot', 'picoDoppleganger', shootOpponentFrames)
    addAnimationBySymbolIndices('dopplegangerOpponent', 'explode', 'picoDoppleganger', explodeOpponentFrames)
    addAnimationBySymbolIndices('dopplegangerOpponent', 'explode-loop', 'picoDoppleganger', explodeOpponentLoopFrames, 24, true)
    addAnimationBySymbolIndices('dopplegangerOpponent', 'cigarette', 'picoDoppleganger', cigaretteOpponentFrames)
    setObjectOrder('dopplegangerOpponent', getObjectOrder('dadGroup'))
    addLuaSprite('dopplegangerOpponent')

    makeAnimatedLuaSprite('cigarette', 'philly/cutscenes/cigarette')
    addAnimationByPrefix('cigarette', 'anim', 'cigarette spit', 24, false)
    setObjectOrder('cigarette', getObjectOrder('gfGroup') + 1)
    addLuaSprite('cigarette')
    setProperty('cigarette.visible', false)

    makeFlxAnimateSprite('bloodPool')
    loadAnimateAtlas('bloodPool', 'philly/cutscenes/bloodPool')
    addLuaSprite('bloodPool')
    setProperty('bloodPool.visible', false)

    createInstance('skipSprite', 'flixel.addons.display.FlxPieDial', {0, 0, 40, FlxColor('WHITE'), nil, 40, true, 24})
    callMethod('skipSprite.replaceColor', {FlxColor('BLACK'), FlxColor('TRANSPARENT')})
    setObjectCamera('skipSprite', 'camOther')
    addLuaSprite('skipSprite')
    setProperty('skipSprite.x', screenWidth - (getProperty('skipSprite.width') + 80))
    setProperty('skipSprite.y', screenHeight - (getProperty('skipSprite.height') + 72))
    setProperty('skipSprite.amount', 0)

    if shadersEnabled == true then
        initLuaShader('adjustColor')
        for _, object in ipairs({'dopplegangerPlayer', 'dopplegangerOpponent', 'cigarette', 'bloodPool'}) do
            setSpriteShader(object, 'adjustColor')
            setShaderFloat(object, 'hue', -26)
            setShaderFloat(object, 'saturation', -16)
            setShaderFloat(object, 'contrast', 0)
            setShaderFloat(object, 'brightness', -5)
        end
    end

    for _, music in ipairs({'cutscene', 'cutscene2'}) do
        precacheMusic(music)
    end
    for _, sound in ipairs({'Gasp', 'Cigarette', 'Cigarette2', 'Shoot', 'Explode', 'Spin'}) do
        precacheSound('pico'..sound)
    end
    if not isRunning('custom_events/Set Camera Target') then
        addLuaScript('custom_events/Set Camera Target')
    end
end

local cutsceneFinished = false
function onStartCountdown()
    if seenCutscene == true or isStoryMode == true then
        setUpFinishedCutscene()
        cutsceneFinished = true
    end
    if seenCutscene == false and cutsceneFinished == false then
        setProperty('camHUD.alpha', 0)
        playCutscene()
        return Function_Stop
    end
end

isPlayerShooting = nil
smokerExplodes = nil
shooterCamPos = {}
smokerCamPos = {}
inBetweenCamPos = {}
function playCutscene()
    setProperty('boyfriend.visible', false)
    setProperty('dad.visible', false)
    setUpCutscene()
    triggerEvent('Set Camera Target', 'None,'..tostring(inBetweenCamPos.x)..','..tostring(inBetweenCamPos.y), '0')
    runTimer('startCutsceneMusic', 0.1)
    runTimer('moveToSmoker', 4)
    runTimer('moveToShooter', 6.3)
    runTimer('moveBackToSmoker', 8.75)
    if smokerExplodes then
        runTimer('picoBleeds', 11.2)
    else
        runTimer('picoSpitsCigarette', 11.5)
    end
    runTimer('endCutscene', 13)
end

function setUpCutscene()
    isPlayerShooting = getRandomBool(50)
    smokerExplodes = getRandomBool(8)
    setDataFromSave('Pico_Mix_Variables', 'hasPlayerShooted', isPlayerShooting)
    setDataFromSave('Pico_Mix_Variables', 'smokerExploded', smokerExplodes)
	flushSaveData('Pico_Mix_Variables')
    
    if isPlayerShooting then
        setProperty('cigarette.x', getProperty('boyfriend.x') - 310)
        setProperty('cigarette.y', getProperty('boyfriend.y') + 205)
        setProperty('cigarette.flipX', true)

        setProperty('bloodPool.x', getProperty('dad.x') - 1487)
        setProperty('bloodPool.y', getProperty('dad.y') - 171)

        shooterCamPos = {
            x = getMidpointX('boyfriend') - getProperty('boyfriend.cameraPosition[0]') + getProperty('boyfriendCameraOffset[0]') - 100,
            y = getMidpointY('boyfriend') + getProperty('boyfriend.cameraPosition[1]') + getProperty('boyfriendCameraOffset[1]') - 100
        }
        smokerCamPos = {
            x = getMidpointX('dad') + getProperty('dad.cameraPosition[0]') + getProperty('opponentCameraOffset[0]') + 150,
            y = getMidpointY('dad') + getProperty('dad.cameraPosition[1]') + getProperty('opponentCameraOffset[1]') - 100
        }
    else
        setProperty('cigarette.x', getProperty('boyfriend.x') - 478)
        setProperty('cigarette.y', getProperty('boyfriend.y') + 205)

        setProperty('bloodPool.x', getProperty('boyfriend.x') - 793)
        setProperty('bloodPool.y', getProperty('boyfriend.y') - 170)

        shooterCamPos = {
            x = getMidpointX('dad') + getProperty('dad.cameraPosition[0]') + getProperty('opponentCameraOffset[0]') + 150,
            y = getMidpointY('dad') + getProperty('dad.cameraPosition[1]') + getProperty('opponentCameraOffset[1]') - 100
        }
        smokerCamPos = {
            x = getMidpointX('boyfriend') - getProperty('boyfriend.cameraPosition[0]') + getProperty('boyfriendCameraOffset[0]') - 100,
            y = getMidpointY('boyfriend') + getProperty('boyfriend.cameraPosition[1]') + getProperty('boyfriendCameraOffset[1]') - 100
        }
    end
    inBetweenCamPos = {
        x = (shooterCamPos.x + smokerCamPos.x) / 2,
        y = (shooterCamPos.y + smokerCamPos.y) / 2
    }
end

function setUpFinishedCutscene()
    hasPlayerShooted = getDataFromSave('Pico_Mix_Variables', 'hasPlayerShooted')
    smokerExploded = getDataFromSave('Pico_Mix_Variables', 'smokerExploded')
        
    if smokerExploded then
        setProperty('dad.visible', false)
        playAnim('dopplegangerOpponent', 'explode-loop')

        if shadersEnabled == true then
            removeSpriteShader('cigarette')
            removeSpriteShader('dopplegangerPlayer')
        end
        setProperty('cigarette.visible', false)
        setProperty('dopplegangerPlayer.visible', false)
        removeLuaSprite('cigarette')
        removeLuaSprite('dopplegangerPlayer')

        setProperty('opponentVocals.volume', 0)
        for i = 0, getProperty('notes.length') - 1 do
            if getPropertyFromGroup('notes', i, 'mustPress') == false then
                setPropertyFromGroup('notes', i, 'ignoreNote', true)
            end
        end
        for i = 0, getProperty('unspawnNotes.length') - 1 do
            if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == false then
                setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
            end
        end
        
        setProperty('bloodPool.x', getProperty('dad.x') - 1487)
        setProperty('bloodPool.y', getProperty('dad.y') - 171)
        setProperty('bloodPool.visible', true)
        setProperty('bloodPool.anim.curFrame', getProperty('bloodPool.anim.length') - 1)
    else
        if hasPlayerShooted then
            setProperty('cigarette.x', getProperty('boyfriend.x') - 310)
            setProperty('cigarette.y', getProperty('boyfriend.y') + 205)
            setProperty('cigarette.flipX', true)
        else
            setProperty('cigarette.x', getProperty('boyfriend.x') - 478)
            setProperty('cigarette.y', getProperty('boyfriend.y') + 205)
        end
        setProperty('cigarette.visible', true)
        callMethod('cigarette.animation.curAnim.finish')

        if shadersEnabled == true then
            removeSpriteShader('bloodPool')
            removeSpriteShader('dopplegangerPlayer')
            removeSpriteShader('dopplegangerOpponent')
        end
        setProperty('bloodPool.visible', false)
        setProperty('dopplegangerPlayer.visible', false)
        setProperty('dopplegangerOpponent.visible', false)
        removeLuaSprite('bloodPool')
        removeLuaSprite('dopplegangerPlayer')
        removeLuaSprite('dopplegangerOpponent')
    end
end

function startCutsceneAnim(isPlayerShooting, smokerExplodes)
    local shooter = nil
    local smoker = nil
    if isPlayerShooting then
        shooter = 'Player'
        smoker = 'Opponent'
    else
        shooter = 'Opponent'
        smoker = 'Player'
    end
    
    playAnim('doppleganger'..shooter, 'shoot')
    if smokerExplodes then
        playAnim('doppleganger'..smoker, 'explode')
        runTimer('picoFuckinDies', 8.75)
    else
        playAnim('doppleganger'..smoker, 'cigarette')
    end

    runTimer('delayGasp', 0.3)
    runTimer('picoPointsCigarette', 3.7)
    runTimer('picoShoots', 6.29)
    runTimer('picoSpinsGun', 10.33)
end

local canSkip = true
function onTimerCompleted(tag, loops, loopsLeft)
    if cutsceneFinished == false then
        if tag == 'beatHit' then
            if getProperty('gf.animation.finished') then
                characterDance('gf')
            end
        end
        if tag == 'startCutsceneMusic' then
            if smokerExplodes then
                playMusic('cutscene2')
            else
                playMusic('cutscene')
            end
            runTimer('beatHit', 60 / 150, 0)
            startCutsceneAnim(isPlayerShooting, smokerExplodes)
        end
        if tag == 'delayGasp' then
            playSound('picoGasp', 1, 'cutsceneSound1')
        end
        if tag == 'picoPointsCigarette' then
            if smokerExplodes then
                playSound('picoCigarette2', 1, 'cutsceneSound2')
            else
                playSound('picoCigarette', 1, 'cutsceneSound2')
            end
        end
        if tag == 'moveToSmoker' then
            triggerEvent('Set Camera Target', 'None,'..tostring(smokerCamPos.x)..','..tostring(smokerCamPos.y))
        end
        if tag == 'picoShoots' then
            playSound('picoShoot', 1, 'cutsceneSound3')
        end
        if tag == 'moveToShooter' then
            triggerEvent('Set Camera Target', 'None,'..tostring(shooterCamPos.x)..','..tostring(shooterCamPos.y))
        end
        if tag == 'picoFuckinDies' then
            playSound('picoExplode', 1, 'cutsceneSound4')
        end
        if tag == 'moveBackToSmoker' then
            canSkip = false
            triggerEvent('Set Camera Target', 'None,'..tostring(smokerCamPos.x)..','..tostring(smokerCamPos.y))
            if smokerExplodes then
                playAnim('gf', 'drop70')
                setProperty('gf.specialAnim', true)
            end
        end
        if tag == 'picoSpinsGun' then
            playSound('picoSpin', 1, 'cutsceneSound5')
        end
        if tag == 'picoBleeds' then
            playAnim('bloodPool', 'poolAnim')
            setProperty('bloodPool.visible', true)
        end
        if tag == 'picoSpitsCigarette' then
            playAnim('cigarette', 'anim', true)
            setProperty('cigarette.visible', true)
        end
        if tag == 'endCutscene' then
            if smokerExplodes == false or isPlayerShooting == true then
                cutsceneFinished = true
                startCountdown()
                setProperty('camHUD.alpha', 1)
                cancelTimer('beatHit')
            end
            if smokerExplodes == true then
                if shadersEnabled == true then
                    removeSpriteShader('cigarette')
                end
                setProperty('cigarette.visible', false)
                removeLuaSprite('cigarette')
                if isPlayerShooting == true then
                    if shadersEnabled == true then
                        removeSpriteShader('dopplegangerPlayer')
                    end
                    setProperty('dopplegangerPlayer.visible', false)
                    removeLuaSprite('dopplegangerPlayer')   

                    setProperty('boyfriend.visible', true)
                    setProperty('opponentVocals.volume', 0)
                    for i = 0, getProperty('notes.length') - 1 do
                        if getPropertyFromGroup('notes', i, 'mustPress') == false then
                            setPropertyFromGroup('notes', i, 'ignoreNote', true)
                        end
                    end
                    for i = 0, getProperty('unspawnNotes.length') - 1 do
                        if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == false then
                            setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
                        end
                    end
                else
                    setProperty('dopplegangerOpponent.visible', false)
                    setProperty('dad.visible', true)
                    runTimer('fadeOutScreen', 1)
                    runTimer('goBackToMenu', 2)
                end
            else
                if shadersEnabled == true then
                    removeSpriteShader('bloodPool')
                    removeSpriteShader('dopplegangerPlayer')
                    removeSpriteShader('dopplegangerOpponent')
                end
                setProperty('bloodPool.visible', false)
                setProperty('dopplegangerPlayer.visible', false)
                setProperty('dopplegangerOpponent.visible', false)
                removeLuaSprite('bloodPool')
                removeLuaSprite('dopplegangerPlayer')
                removeLuaSprite('dopplegangerOpponent')

                setProperty('boyfriend.visible', true)
                setProperty('dad.visible', true)
            end
        end
        if tag == 'fadeOutScreen' then
            cameraFade('game', '000000', 1)
        end
        if tag == 'goBackToMenu' then
            endSong()
        end
    end
end

function onEvent(eventName, value1, value2, strumTime)
    if eventName == 'Philly Glow' then
        if value1 == '0' then
            for i, object in ipairs({'dopplegangerPlayer', 'dopplegangerOpponent', 'cigarette', 'bloodPool'}) do
                if luaSpriteExists(object) then
                    setProperty(object..'.color', 0xFFFFFF)
                    if shadersEnabled == true then
                        setSpriteShader(object, 'adjustColor')
                        setShaderFloat(object, 'hue', -26)
                        setShaderFloat(object, 'saturation', -16)
                        setShaderFloat(object, 'contrast', 0)
                        setShaderFloat(object, 'brightness', -5)
                    end
                end
            end
        elseif value1 == '1' then
            for i, object in ipairs({'dopplegangerPlayer', 'dopplegangerOpponent', 'cigarette', 'bloodPool'}) do
                if luaSpriteExists(object) then
                    if shadersEnabled == true then
                        removeSpriteShader(object)
                    end
                    setProperty(object..'.color', getProperty('boyfriend.color'))
                end
            end
        end
    end
end

function onUpdate(elapsed)
    if luaSpriteExists('dopplegangerOpponent') then
        if getProperty('dopplegangerOpponent.anim.finished') then
            if getProperty('dopplegangerOpponent.anim.curSymbol.name') == 'explode' then
                playAnim('dopplegangerOpponent', 'explode-loop')
            end
        end
    end
    if luaSpriteExists('dopplegangerPlayer') then
        if getProperty('dopplegangerPlayer.anim.finished') then
            if getProperty('dopplegangerPlayer.anim.curSymbol.name') == 'explode' then
                playAnim('dopplegangerPlayer', 'explode-loop')
            end
        end
    end
    if luaSpriteExists('bloodPool') then
        if getProperty('bloodPool.anim.curFrame') >= getProperty('bloodPool.anim.length') - 1 then
            callMethod('bloodPool.anim.pause')
        end
    end
end

local holdingTime = 0
function onUpdatePost(elapsed)
    if cutsceneFinished == false and seenCutscene == false then
        if keyPressed('accept') and canSkip == true then
            holdingTime = math.max(0, math.min(1, holdingTime + elapsed))
        elseif holdingTime > 0 then
            holdingTime = math.max(0, math.lerp(holdingTime, -0.1, math.bound(elapsed * 3, 0, 1)))
        end
        setProperty('skipSprite.amount', math.min(1, math.max(0, (holdingTime / 1) * 1.025)))
        setProperty('skipSprite.alpha', math.remapToRange(getProperty('skipSprite.amount'), 0.025, 1, 0, 1))

        if holdingTime >= 1 then
            removeLuaSprite('skipSprite', false)
            cutsceneFinished = true
            stopSound(nil)
            for i = 1, 5 do
                if luaSoundExists('cutsceneSound'..i) then
                    stopSound('cutsceneSound'..i)
                end
            end
            setProperty('camHUD.alpha', 1)
            setProperty('dad.visible', true)
            setProperty('boyfriend.visible', true)
            
            setDataFromSave('Pico_Mix_Variables', 'smokerExploded', false)
            flushSaveData('Pico_Mix_Variables')
            setUpFinishedCutscene()

            startCountdown()
            triggerEvent('Set Camera Target', 'Dad', '0')
        end
    end
end

function math.lerp(a, b, ratio)
    return a + ratio * (b - a) 
end

function math.bound(value, min, max)
    if value < min then
        value = min
    elseif value > max then
        value = max
    end
    return value
end

function math.remapToRange(value, start1, stop1, start2, stop2)
    return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
end