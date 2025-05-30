-- Everything here is to save the frames of each animation for the cutscene.
local tastyRevengeFrames = {}
local knockoffFrames = {}
local dodgeBulletFrames = {}
local picoIdleFrames = {}
local picoCatchNeneFrames = {}
for i = 0, 399 do
    if i < 190 then
        tastyRevengeFrames[i] = i
    elseif i > 190 and i < 310 then
        dodgeBulletFrames[i - 191] = i
    elseif i > 310 then
        knockoffFrames[i - 311] = i
    end

    if i < 14 then
        if i <= 9 then
            picoIdleFrames[i] = i + 4
        else
            picoIdleFrames[i] = i - 10
        end
    elseif i < 293 then
        picoCatchNeneFrames[i - 14] = i
    end
end

local neneDanceLeftFrames = {}
local neneDanceRightFrames = {}
local otisIdleFrames = {}
local neneGetsSavedFrames = {}
local otisShootsFrames = {}
for i = 0, 783 do
    if i < 15 then
        neneDanceLeftFrames[i] = i
        neneDanceRightFrames[i] = i + 15
        otisIdleFrames[i] = i + 564
    end

    if i >= 160 and i < 414 then
        neneGetsSavedFrames[i - 160] = i
    elseif i >= 654 then
        otisShootsFrames[i - 654] = i
    end
end

-- The actual code for the cutscene from here.
function onCreate()
    if seenCutscene == false then
        makeLuaSprite('tankmenDead', 'tankmanBattlefield/cutscenes/tankmenDead', 1517, 634)
        addLuaSprite('tankmenDead')
        setProperty('tankmenDead.visible', false)

        makeLuaSprite('AbotSpeakerBGCutscene', 'characters/abot/stereoBG', getProperty('gf.x') + 60, getProperty('gf.y') + 365)
        addLuaSprite('AbotSpeakerBGCutscene')

        makeLuaSprite('AbotEyesCutscene', '', getProperty('gf.x') - 60, getProperty('gf.y') + 570)
        makeGraphic('AbotEyesCutscene', 140, 60)
        addLuaSprite('AbotEyesCutscene')

        makeFlxAnimateSprite('AbotPupilsCutscene', getProperty('gf.x') - 608, getProperty('gf.y') - 156)
        loadAnimateAtlas('AbotPupilsCutscene', 'characters/abot/systemEyes')
        addLuaSprite('AbotPupilsCutscene')
        setProperty('AbotPupilsCutscene.anim.curFrame', 17)
        callMethod('AbotPupilsCutscene.anim.pause')

        makeFlxAnimateSprite('neneIntro', getProperty('gf.x') + 685, getProperty('gf.y') + 526)
        loadAnimateAtlas('neneIntro', 'tankmanBattlefield/cutscenes/neneIntro')
        addAnimationBySymbolIndices('neneIntro', 'danceLeft', 'Nene Abot Idle', neneDanceLeftFrames)
        addAnimationBySymbolIndices('neneIntro', 'danceRight', 'Nene Abot Idle', neneDanceRightFrames)
        addAnimationBySymbolIndices('neneIntro', 'idle', 'Nene Abot Idle', otisIdleFrames)
        addAnimationBySymbolIndices('neneIntro', 'anim1', 'Nene Abot Idle', neneGetsSavedFrames)
        addAnimationBySymbolIndices('neneIntro', 'anim2', 'Nene Abot Idle', otisShootsFrames)
        setObjectOrder('neneIntro', getObjectOrder('gfGroup'))
        addLuaSprite('neneIntro')
        setProperty('neneIntro.visible', false)

        makeFlxAnimateSprite('tankmanIntro', getProperty('dad.x') + 798, getProperty('dad.y') + 205)
        loadAnimateAtlas('tankmanIntro', 'tankmanBattlefield/cutscenes/tankmanIntro')
        addAnimationBySymbolIndices('tankmanIntro', 'anim1', 'tankman lines mostly', tastyRevengeFrames)
        addAnimationBySymbolIndices('tankmanIntro', 'anim2', 'tankman lines mostly', knockoffFrames)
        addAnimationBySymbolIndices('tankmanIntro', 'anim3', 'tankman lines mostly', dodgeBulletFrames)
        setObjectOrder('tankmanIntro', getObjectOrder('dadGroup'))
        addLuaSprite('tankmanIntro')
        setProperty('tankmanIntro.visible', false)

        makeFlxAnimateSprite('picoIntro', getProperty('boyfriend.x') + 188, getProperty('boyfriend.y') + 215)
        loadAnimateAtlas('picoIntro', 'tankmanBattlefield/cutscenes/picoIntro')
        addAnimationBySymbolIndices('picoIntro', 'idle', 'pico catch nene full', picoIdleFrames)
        addAnimationBySymbolIndices('picoIntro', 'anim', 'pico catch nene full', picoCatchNeneFrames)
        setObjectOrder('picoIntro', getObjectOrder('boyfriendGroup'))
        addLuaSprite('picoIntro')
        setProperty('picoIntro.visible', false)

        makeAnimatedLuaSprite('bulletShot', 'tankmanBattlefield/cutscenes/Bullet_Shot', -240, 540)
        addAnimationByPrefix('bulletShot', 'anim', 'Bullet Shot0', 24, false)
        addLuaSprite('bulletShot', true)
        setProperty('bulletShot.visible', false)

        createInstance('skipSprite', 'flixel.addons.display.FlxPieDial', {0, 0, 40, FlxColor('WHITE'), nil, 40, true, 24})
        callMethod('skipSprite.replaceColor', {FlxColor('BLACK'), FlxColor('TRANSPARENT')})
        setObjectCamera('skipSprite', 'camOther')
        addLuaSprite('skipSprite')
        setProperty('skipSprite.x', screenWidth - (getProperty('skipSprite.width') + 80))
        setProperty('skipSprite.y', screenHeight - (getProperty('skipSprite.height') + 72))
        setProperty('skipSprite.amount', 0)
        
        precacheSound('stressPicoCutsceneIntro')
        if not isRunning('custom_events/Set Camera Target') then
            addLuaScript('custom_events/Set Camera Target')
        end
        if not isRunning('custom_events/Set Camera Zoom') then
            addLuaScript('custom_events/Set Camera Zoom')
        end
    end
end

local cutsceneFinished = false
function onStartCountdown()
    if cutsceneFinished == false and seenCutscene == false then
        setVar('cutsceneMode', true)
        setProperty('camHUD.visible', false)
        playCutscene()
        return Function_Stop
    end
end

function onSongStart()
    if seenCutscene == false then
        if luaSpriteExists('tankmanIntro') then
            setProperty('dad.visible', true)
            if shadersEnabled == true then
                removeSpriteShader('tankmanIntro')
            end
            setProperty('tankmanIntro.visible', false)
            removeLuaSprite('tankmanIntro')
        end
    end
end

function playCutscene()
    setProperty('gf.visible', false)
    setProperty('dad.visible', false)
    setProperty('boyfriend.visible', false)
    setProperty('neneIntro.visible', true)
    setProperty('tankmanIntro.visible', true)
    setProperty('picoIntro.visible', true)
    triggerEvent('Set Camera Target', 'Dad,350,-60', '0')
    triggerEvent('Set Camera Zoom', '0.95,stage', '0')

    runTimer('startCutscene', 0.1)
    runTimer('camFocusNene', 6.3)
    runTimer('tankmenGunpointsNene', 6.41)
    runTimer('neneStabsTankmen', 8.55)
    runTimer('camFocusOtis', 11.2)
    runTimer('camFocusPico1', 12.65)
    runTimer('picoCatchesNene', 13.77)
    runTimer('camFocusPico2', 13.85)
    runTimer('camFocusTankman', 23.9)
    runTimer('tankmanMocksOtis', 24.31)
    runTimer('otisShoots', 26.95)
    runTimer('tankmanDodgesBullet', 27.83)
    runTimer('resetCamPos', 30.5)
    runTimer('endCutsceneIntro', 32)
end

local cutsceneSprites = {
    'tankmanIntro',
    'picoIntro',
    'neneIntro',
    'tankmenDead',
    'AbotSpeakerBGCutscene',
    'AbotEyesCutscene',
    'AbotPupilsCutscene'
}
function activateShader()
    if shadersEnabled == true then
        initLuaShader('adjustColor')
        for i, object in ipairs(cutsceneSprites) do
            setSpriteShader(object, 'adjustColor')
    		setShaderFloat(object, 'hue', -38)
    		setShaderFloat(object, 'saturation', -20)
    		setShaderFloat(object, 'contrast', -25)
    		setShaderFloat(object, 'brightness', -46)
        end
    end
end

-- Skip cutscene behaviour.
local holdingTime = 0
function onUpdatePost(elapsed)
    if cutsceneFinished == false and seenCutscene == false then
        if getProperty('AbotPupilsCutscene.anim.curFrame') >= 17 then
            callMethod('AbotPupilsCutscene.anim.pause')
        end

        if keyPressed('accept') then
            holdingTime = math.max(0, math.min(1, holdingTime + elapsed))
        elseif holdingTime > 0 then
            holdingTime = math.max(0, math.lerp(holdingTime, -0.1, math.bound(elapsed * 3, 0, 1)))
        end
        setProperty('skipSprite.amount', math.min(1, math.max(0, (holdingTime / 1) * 1.025)))
        setProperty('skipSprite.alpha', math.remapToRange(getProperty('skipSprite.amount'), 0.025, 1, 0, 1))

        if holdingTime >= 1 then
            removeLuaSprite('skipSprite', false)
            cutsceneFinished = true
            stopSound('cutsceneSound')
            setVar('cutsceneMode', false)
            setProperty('camHUD.visible', true)
            setProperty('gf.visible', true)
            setProperty('dad.visible', true)
            setProperty('boyfriend.visible', true)

            for i, object in ipairs(cutsceneSprites) do
                if shadersEnabled == true then
                    removeSpriteShader(object)
                end
                setProperty(object..'.visible', false)
                removeLuaSprite(object)
            end
            
            startCountdown()
            triggerEvent('Set Camera Target', 'Dad', '0')
            triggerEvent('Set Camera Zoom', '1,stage', '0')
        end
    end
end

local neneDanced = false
function onTimerCompleted(tag, loops, loopsLeft)
    if cutsceneFinished == false then
        -- This is to make the characters bop their head to the beat of the cutscene's music.
        if tag == 'beatHit' then
            if getProperty('neneIntro.anim.finished') then
                if getProperty('neneIntro.anim.curSymbol.name') == 'anim1' then
                    setProperty('tankmenDead.visible', true)
                    runTimer('startTankmenFlicker', 113 / 24)
                end
                if loopsLeft >= -16 then
                    neneDanced = not neneDanced
                    if neneDanced == true then
                        playAnim('neneIntro', 'danceRight')
                    else
                        playAnim('neneIntro', 'danceLeft')
                    end
                elseif loopsLeft > -80 then
                    playAnim('neneIntro', 'idle')
                end
            end
            if loopsLeft > -28 then
                playAnim('picoIntro', 'idle')
                if loopsLeft % 2 == 1 then
                    if getRandomBool(2) and getProperty('sniper.animation.name') ~= 'sip' then
                        playAnim('sniper', 'sip')
                    elseif getProperty('sniper.animation.finished') then
                        playAnim('sniper', 'idle')
                    end
                    playAnim('tankguy', 'idle')
                end
            end
        end
        -- Starts the cutscene with music and animations.
        if tag == 'startCutscene' then
            playAnim('tankmanIntro', 'anim1')
            playAnim('neneIntro', 'danceLeft')
            playAnim('picoIntro', 'idle')
            setProperty('neneIntro.anim.curFrame', getProperty('neneIntro.anim.length') - 1)
            setProperty('picoIntro.anim.curFrame', getProperty('picoIntro.anim.length') - 1)
            playSound('stressPicoCutsceneIntro', 1, 'cutsceneSound')
            runTimer('beatHit', 60 / 158, 0)
            activateShader()
        end
        -- Camera zooms onto Nene.
        if tag == 'camFocusNene' then
            triggerEvent('Set Camera Target', 'Dad,350,-240', '1.5,quadOut')
            triggerEvent('Set Camera Zoom', '1.5,stage', '1.5,quadOut')
        end
        -- The tankmen points their gun to Nene.
        if tag == 'tankmenGunpointsNene' then
            playAnim('neneIntro', 'anim1')
        end
        -- Nene stabs one of the tankmen on the forehead.
        if tag == 'neneStabsTankmen' then
            triggerEvent('Set Camera Target', 'Dad,330,-240', '0.4,expoOut')
        end
        -- Camera moves towards the incoming Otis.
        if tag == 'camFocusOtis' then
            triggerEvent('Set Camera Target', 'GF,-40,-400', '1.5,quadInOut')
            triggerEvent('Set Camera Zoom', '1.05,stage', '1.5,quadInOut')
        end
        -- First part of the camera coming back to Pico.
        if tag == 'camFocusPico1' then
            triggerEvent('Set Camera Target', 'BF,200', '1.2,expoIn')
            triggerEvent('Set Camera Zoom', '1.4,stage', '1.2,expoIn')
        end
        -- Pico ctaches Nene while Otis takes care of the tankmen.
        if tag == 'picoCatchesNene' then
            playAnim('picoIntro', 'anim')
            playAnim('tankmanIntro', 'anim2')
            setProperty('tankmanIntro.anim.curFrame', 0)
            callMethod('tankmanIntro.anim.pause')
            setProperty('AbotPupilsCutscene.anim.curFrame', 0)
            callMethod('AbotPupilsCutscene.anim.pause')
        end
        -- Second part of the camera coming back to Pico.
        if tag == 'camFocusPico2' then
            triggerEvent('Set Camera Target', 'BF,230,20', '1,quadOut')
        end
        -- The tankman on the side starts to flicker.
        if tag == 'startTankmenFlicker' then
            setProperty('tankmenDead.visible', false)
            runTimer('tankmenFlicker1', 4 / 24, 4)
        end
        -- The tankman is flickering.
        if tag == 'tankmenFlicker1' then
            setProperty('tankmenDead.visible', not getProperty('tankmenDead.visible'))
            if loopsLeft == 0 then
                runTimer('tankmenFlicker2', 2 / 24, 4)
            end
        end
        -- The tankman is gone. :(
        if tag == 'tankmenFlicker2' then
            setProperty('tankmenDead.visible', not getProperty('tankmenDead.visible'))
        end
        -- Camera moves back to Tankman.
        if tag == 'camFocusTankman' then
            triggerEvent('Set Camera Target', 'Dad,160,-60', '1,expoInOut')
            triggerEvent('Set Camera Zoom', '1.2,stage', '1,expoInOut')
        end
        -- Tankman mocks Otis in frustration.
        if tag == 'tankmanMocksOtis' then
            playAnim('tankmanIntro', 'anim2')
            playAnim('AbotPupilsCutscene', '', true)
        end
        -- Otis shoots towards Tankman.
        if tag == 'otisShoots' then
            playAnim('neneIntro', 'anim2')
            runTimer('startBulletAnim', 20 / 24)
        end
        -- Bullet gets shot.
        if tag == 'startBulletAnim' then
            triggerEvent('Set Camera Target', 'Dad,130,-60', '0.2,backOut')
            setProperty('bulletShot.visible', true)
            playAnim('bulletShot', 'anim')
        end
        -- Tankman dodges the bullet.
        if tag == 'tankmanDodgesBullet' then
            playAnim('tankmanIntro', 'anim3')
        end
        -- Camera comes back into position before game starts.
        if tag == 'resetCamPos' then
            triggerEvent('Set Camera Target', 'Dad', '2.5,quadInOut')
            triggerEvent('Set Camera Zoom', '1,stage', '2.5,quadInOut ')
        end
        -- The cutscene ends.
        if tag == 'endCutsceneIntro' then
            cutsceneFinished = true
            setVar('cutsceneMode', false)
            setProperty('camHUD.visible', true)
            setProperty('gf.visible', true)
            setProperty('boyfriend.visible', true)
            for i, object in ipairs(cutsceneSprites) do
                if i > 1 then
                    if shadersEnabled == true then
                        removeSpriteShader(object)
                    end
                    setProperty(object..'.visible', false)
                    removeLuaSprite(object)
                end
            end
            startCountdown()
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