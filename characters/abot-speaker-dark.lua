local characterType = ''
local characterName = ''
local offsetData = {0, 0}
local propertyTracker = {
    {'x', nil},
    {'y', nil},
    {'scrollFactor.x', nil},
    {'scrollFactor.y', nil},
    {'angle', nil},
    {'antialiasing', nil},
    {'visible', nil}
}

local visualizerActive = nil
function onCreate()
    --[[
        This is how the script recognizes which option you chose to use.
        However, if you decide to take Abot inside another mod,
        the 'visualizerActive' variable will default to 'true' to avoid any bugs or issues.
    ]]
    if getModSetting('visualizerActive', currentModDirectory) == nil then
        visualizerActive = true
    else
        visualizerActive = getModSetting('visualizerActive', currentModDirectory)
    end
end

function createSpeaker(attachedCharacter, offsetX, offsetY)
    characterName = attachedCharacter
    offsetData = {offsetX, offsetY}
    if getCharacterType(attachedCharacter) ~= nil then
        characterType = getCharacterType(attachedCharacter)
    end

    createInstance('AbotSpeakerDark', 'states.stages.objects.ABotSpeaker', {0, 0})
    addLuaSprite('AbotSpeakerDark')

    local looksAtPlayer = getPropertyFromClass('states.PlayState', 'SONG.notes['..curSection..'].mustHitSection')
    if looksAtPlayer == false then
        callMethod('AbotSpeakerDark.lookLeft')
        setProperty('AbotSpeakerDark.eyes.anim.curFrame', getProperty('AbotSpeakerDark.eyes.anim.length') - 1)
    else
        callMethod('AbotSpeakerDark.lookRight')
        setProperty('AbotSpeakerDark.eyes.anim.curFrame', getProperty('AbotSpeakerDark.eyes.anim.length') - 1)
    end

    if visualizerActive == false then
        for i = 0, 6 do
            callMethod('AbotSpeakerDark.vizSprites['..i..'].animation.addByPrefix', {'idle', 'viz'..(i + 1), 24, false})
        end
    end

    runHaxeCode([[
        var abot = getLuaObject('AbotSpeakerDark');
        function startVisualizer() abot.snd = FlxG.sound.music;
        function stopVisualizer() {
            abot.analyzer = null;
            for (i in 0...abot.vizSprites.length) {
                abot.vizSprites[i].animation.curAnim.finish();
            }
        }
    ]])
    setProperty('AbotSpeakerDark.bg.color', 0x616785)
    setProperty('AbotSpeakerDark.eyeBg.color', 0x6F96CE)
    
    initLuaShader('textureSwap')
    setSpriteShader('AbotSpeakerDark.speaker', 'textureSwap')
    setShaderSampler2D('AbotSpeakerDark.speaker', 'image', 'abot/dark/abotSystem/spritemap1')
    setShaderFloat('AbotSpeakerDark.speaker', 'fadeAmount', 1)

    initLuaShader('adjustColor')
    for i = 0, getProperty('AbotSpeakerDark.vizSprites.length') - 1 do
        setSpriteShader('AbotSpeakerDark.vizSprites['..i..']', 'adjustColor')
        setShaderFloat('AbotSpeakerDark.vizSprites['..i..']', 'hue', -26)
        setShaderFloat('AbotSpeakerDark.vizSprites['..i..']', 'saturation', -45)
        setShaderFloat('AbotSpeakerDark.vizSprites['..i..']', 'contrast', 0)
        setShaderFloat('AbotSpeakerDark.vizSprites['..i..']', 'brightness', -12)
    end

    if characterName ~= '' then
        if _G[characterType..'Name'] ~= characterName then
            setProperty('AbotSpeakerDark.visible', false)
        end
    end
end

function onSongStart()
    if visualizerActive == true then
        runHaxeFunction('startVisualizer')
    end
end

function onEndSong()
    if visualizerActive == true then
        runHaxeFunction('stopVisualizer')
    end
end

function onCountdownTick(counter)
    if visualizerActive == false then
        if characterType == 'gf' then
            characterSpeed = getProperty('gfSpeed')
        else
            characterSpeed = 1
        end
        if characterType ~= '' then
            danceEveryNumBeats = getProperty(characterType..'.danceEveryNumBeats')
        else
            danceEveryNumBeats = 1
        end
        if counter % (danceEveryNumBeats * characterSpeed) == 0 then
            callMethod('AbotSpeakerDark.beatHit')
            for i = 0, 6 do
                callMethod('AbotSpeakerDark.vizSprites['..i..'].animation.play', {'idle', true})
            end
        end
    end
end

function onBeatHit()
    if visualizerActive == false then
        if characterType == 'gf' then
            characterSpeed = getProperty('gfSpeed')
        else
            characterSpeed = 1
        end
        if characterType ~= '' then
            danceEveryNumBeats = getProperty(characterType..'.danceEveryNumBeats')
        else
            danceEveryNumBeats = 1
        end
        if curBeat % (danceEveryNumBeats * characterSpeed) == 0 then
            callMethod('AbotSpeakerDark.beatHit')
            for i = 0, 6 do
                callMethod('AbotSpeakerDark.vizSprites['..i..'].animation.play', {'idle', true})
            end
        end
    end
end

function onMoveCamera(character)
    if character == 'boyfriend' then
        callMethod('AbotSpeakerDark.lookRight')
    end

    if character == 'dad' then
        callMethod('AbotSpeakerDark.lookLeft')
    end
end

function onEvent(eventName, value1, value2, strumTime)
    if eventName == 'Change Character' then
        if getCharacterType(value2) == characterType and value2 ~= characterName then
            setProperty('AbotSpeakerDark.visible', false)
        elseif characterName ~= '' then
            createSpeaker(characterName, offsetData[1], offsetData[2])
        end
    end
    if eventName == 'Set Camera Target' then
        for _, startStringBF in ipairs({'0', 'bf', 'boyfriend'}) do
            if stringStartsWith(string.lower(value1), startStringBF) then
                callMethod('AbotSpeakerDark.lookRight')
            end
        end
        for _, startStringDad in ipairs({'1', 'dad', 'opponent'}) do
            if stringStartsWith(string.lower(value1), startStringDad) then
                callMethod('AbotSpeakerDark.lookLeft')
            end
        end
    end
end

function onUpdatePost(elapsed)
    for property = 1, #propertyTracker do
        if characterType ~= '' then
            translateAlpha(getProperty(characterType..'.alpha'))
            if property < 3 then
                if propertyTracker[property][2] ~= getProperty(characterType..'.'..propertyTracker[property][1]) then
                    propertyTracker[property][2] = getProperty(characterType..'.'..propertyTracker[property][1])
                    setProperty('AbotSpeakerDark.'..propertyTracker[property][1], propertyTracker[property][2] + offsetData[property])
                end
            else
                if propertyTracker[property][2] ~= getProperty(characterType..'.'..propertyTracker[property][1]) then
                    propertyTracker[property][2] = getProperty(characterType..'.'..propertyTracker[property][1])
                    setProperty('AbotSpeakerDark.'..propertyTracker[property][1], propertyTracker[property][2])
                end
            end
        end
    end
end

function translateAlpha(value)
    setShaderFloat('AbotSpeakerDark.speaker', 'fadeAmount', value)
    for i = 0, getProperty('AbotSpeakerDark.vizSprites.length') - 1 do
        setShaderFloat('AbotSpeakerDark.vizSprites['..i..']', 'hue', interpolateFloat(0, -26, value))
        setShaderFloat('AbotSpeakerDark.vizSprites['..i..']', 'saturation', interpolateFloat(0, -45, value))
        setShaderFloat('AbotSpeakerDark.vizSprites['..i..']', 'contrast', interpolateFloat(0, 0, value))
        setShaderFloat('AbotSpeakerDark.vizSprites['..i..']', 'brightness', interpolateFloat(0, -12, value))
    end

    setProperty('AbotSpeakerDark.bg.color', interpolateColor(0xFFFFFF, 0x616785, value))
    setProperty('AbotSpeakerDark.eyeBg.color', interpolateColor(0xFFFFFF, 0x6F96CE, value))
end

function interpolateColor(color1, color2, factor)
    redColor1 = color1 / (16^4)
    greenColor1 = (redColor1 - math.floor(redColor1)) * 256
    blueColor1 = (greenColor1 - math.floor(greenColor1)) * 256

    redColor2 = color2 / (16^4)
    greenColor2 = (redColor2 - math.floor(redColor2)) * 256
    blueColor2 = (greenColor2 - math.floor(greenColor2)) * 256

    targetRed = (math.floor(redColor2) - math.floor(redColor1)) * factor + math.floor(redColor1)
    targetGreen = (math.floor(greenColor2) - math.floor(greenColor1)) * factor + math.floor(greenColor1)
    targetBlue = (math.floor(blueColor2) - math.floor(blueColor1)) * factor + math.floor(blueColor1)
    
    return math.floor(targetRed) * 16^4 + math.floor(targetGreen) * 16^2 + math.floor(targetBlue)
end

function interpolateFloat(value1, value2, factor)
    return (value2 - value1) * factor + value1
end

function getCharacterType(characterName)
    if boyfriendName == characterName then
        return 'boyfriend'
    elseif dadName == characterName then
        return 'dad'
    elseif gfName == characterName then
        return 'gf'
    end
end