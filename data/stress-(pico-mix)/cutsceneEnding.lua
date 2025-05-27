function onCreatePost()
    makeLuaSprite('blackScreen')
    makeGraphic('blackScreen', 2000, 2500, '000000')
    screenCenter('blackScreen')
    setObjectCamera('blackScreen', 'camOther')
    addLuaSprite('blackScreen', true)
    setProperty('blackScreen.alpha', 0)

    makeFlxAnimateSprite('tankmanCutscene', getProperty('dad.x') + 725, getProperty('dad.y') + 195)
    loadAnimateAtlas('tankmanCutscene', 'tankmanBattlefield/cutscenes/tankmanEnding')
    addAnimationBySymbol('tankmanCutscene', 'anim', 'tankman stress ending')
    setObjectOrder('tankmanCutscene', getObjectOrder('dadGroup'))
    addLuaSprite('tankmanCutscene', true)
    setProperty('tankmanCutscene.visible', false)
    precacheSound('endCutsceneEnding')

    if not luaSpriteExists('skipSprite') then
        createInstance('skipSprite', 'flixel.addons.display.FlxPieDial', {0, 0, 40, FlxColor('WHITE'), nil, 40, true, 24})
        callMethod('skipSprite.replaceColor', {FlxColor('BLACK'), FlxColor('TRANSPARENT')})
        setObjectCamera('skipSprite', 'camOther')
        addLuaSprite('skipSprite')
        setProperty('skipSprite.x', screenWidth - (getProperty('skipSprite.width') + 80))
        setProperty('skipSprite.y', screenHeight - (getProperty('skipSprite.height') + 72))
        setProperty('skipSprite.amount', 0)
    end

    if shadersEnabled == true then
        runHaxeCode([[
            import flixel.FlxCameraFollowStyle;
            var dropShadowCamera:FlxCamera;
            function activateDropShadowShader() {
                dropShadowCamera = new FlxCamera();
                dropShadowCamera.bgColor = 0x00FFFFFF;
                for (cam in [game.camHUD, game.camOther]) FlxG.cameras.remove(cam, false);
                FlxG.cameras.add(dropShadowCamera, false);
                for (cam in [game.camHUD, game.camOther]) FlxG.cameras.add(cam, false);
                
                getLuaObject('tankmanCutscene').cameras = [dropShadowCamera];
                dropShadowCamera.filters = [new ShaderFilter(game.getLuaObject('dropShadowFilter').shader)];
                dropShadowCamera.follow(game.camFollow, FlxCameraFollowStyle.LOCKON, 0);
            }

            function updateDropShadowShader() {
                if (dropShadowCamera != null) {
                    dropShadowCamera.scroll.x = game.camGame.scroll.x;
                    dropShadowCamera.scroll.y = game.camGame.scroll.y;
                    dropShadowCamera.zoom = game.camGame.zoom;
                    game.getLuaObject('dropShadowFilter').shader.setFloat('zoom', dropShadowCamera.zoom);
                }  
            }
        ]])
    end
end

local cutsceneFinished = false
function onEndSong()
    if cutsceneFinished == false then
        setVar('cutsceneMode', true)
        setProperty('camHUD.visible', false)
        playCutscene()
        return Function_Stop
    end
end

local holdingTime = 0
function onUpdatePost(elapsed)
    if getProperty('inCutscene') == true then
        if shadersEnabled == true then
            runHaxeFunction('updateDropShadowShader')
        end

        if keyPressed('accept') then
            holdingTime = math.max(0, math.min(1, holdingTime + elapsed))
        elseif holdingTime > 0 then
            holdingTime = math.max(0, math.lerp(holdingTime, -0.1, math.bound(elapsed * 3, 0, 1)))
        end
        setProperty('skipSprite.amount', math.min(1, math.max(0, (holdingTime / 1) * 1.025)))
        setProperty('skipSprite.alpha', math.remapToRange(getProperty('skipSprite.amount'), 0.025, 1, 0, 1))

        if holdingTime >= 1 then
            removeLuaSprite('skipSprite')
            cutsceneFinished = true    
            stopSound('cutsceneSound')
            endSong()
        end
    end
end

function playCutscene()
    addLuaSprite('skipSprite')
    setProperty('inCutscene', true)
    setProperty('dad.visible', false)
    setProperty('tankmanCutscene.visible', true)
    activateShader()
    triggerEvent('Set Camera Target', 'Dad,290,-60', '2.8,expoOut')
    triggerEvent('Set Camera Zoom', '0.65', '2,expoOut')
    playAnim('tankmanCutscene', 'anim')
    playSound('stressPicoCutsceneEnding', 1, 'cutsceneSound')
    runTimer('picoAndNeneLaugh', 176 / 24)
    runTimer('startFade', 270 / 24)
    runTimer('endCutsceneEnding', 320 / 24)
end

function activateShader()
    if shadersEnabled == true then
        initLuaShader('dropShadowScreen')
        makeLuaSprite('dropShadowFilter')
        setSpriteShader('dropShadowFilter', 'dropShadowScreen')
        setShaderFloat('dropShadowFilter', 'hue', -38)
        setShaderFloat('dropShadowFilter', 'saturation', -20)
        setShaderFloat('dropShadowFilter', 'contrast', -25)
        setShaderFloat('dropShadowFilter', 'brightness', -46)
                
        setShaderFloat('dropShadowFilter', 'ang', math.rad(45))
        setShaderFloat('dropShadowFilter', 'str', 1)
        setShaderFloat('dropShadowFilter', 'dist', 15)
        setShaderFloat('dropShadowFilter', 'thr', 0.3)

        setShaderFloat('dropShadowFilter', 'AA_STAGES', 2)
        setShaderFloatArray('dropShadowFilter', 'dropColor', {223 / 255, 239 / 255, 60 / 255})
        setShaderBool('dropShadowFilter', 'useMask', false)
        setShaderFloat('dropShadowFilter', 'zoom', 1)
        runHaxeFunction('activateDropShadowShader')
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'picoAndNeneLaugh' then
        playAnim('boyfriend', 'laugh', true)
    end
    if tag == 'startFade' then
        triggerEvent('Set Camera Target', 'Dad,290,-360', '2,quadInOut')
        doTweenAlpha('fadeInScreen', 'blackScreen', 1, 2, 'linear')
    end
    if tag == 'endCutsceneEnding' then
        cutsceneFinished = true
        endSong()
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