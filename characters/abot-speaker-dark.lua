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

function createSpeaker(attachedCharacter, offsetX, offsetY)
    characterName = attachedCharacter
    offsetData = {offsetX, offsetY}
    if getCharacterType(attachedCharacter) ~= nil then
        characterType = getCharacterType(attachedCharacter)
    end

    createInstance('AbotSpeaker', 'states.stages.objects.ABotSpeaker', {0, 0})
    addLuaSprite('AbotSpeaker')

    local looksAtPlayer = getPropertyFromClass('states.PlayState', 'SONG.notes['..curSection..'].mustHitSection')
    if looksAtPlayer == false then
        callMethod('AbotSpeaker.lookLeft')
        setProperty('AbotSpeaker.eyes.anim.curFrame', getProperty('AbotSpeaker.eyes.anim.length') - 1)
    else
        callMethod('AbotSpeaker.lookRight')
        setProperty('AbotSpeaker.eyes.anim.curFrame', getProperty('AbotSpeaker.eyes.anim.length') - 1)
    end

    runHaxeCode([[
        function startVisualizer() getLuaObject('AbotSpeaker').snd = FlxG.sound.music;
    ]])
    setProperty('AbotSpeaker.bg.color', 0x616785)
    setProperty('AbotSpeaker.eyeBg.color', 0x6F96CE)
    
    initLuaShader('textureSwap')
    setSpriteShader('AbotSpeaker.speaker', 'textureSwap')
    setShaderSampler2D('AbotSpeaker.speaker', 'image', 'abot/dark/abotSystem/spritemap1')
    setShaderFloat('AbotSpeaker.speaker', 'fadeAmount', 1)

    initLuaShader('adjustColor')
    for i = 0, getProperty('AbotSpeaker.vizSprites.length') - 1 do
        setSpriteShader('AbotSpeaker.vizSprites['..i..']', 'adjustColor')
        setShaderFloat('AbotSpeaker.vizSprites['..i..']', 'hue', -26)
        setShaderFloat('AbotSpeaker.vizSprites['..i..']', 'saturation', -45)
        setShaderFloat('AbotSpeaker.vizSprites['..i..']', 'contrast', 0)
        setShaderFloat('AbotSpeaker.vizSprites['..i..']', 'brightness', -12)
    end

    if characterName ~= '' then
        if _G[characterType..'Name'] ~= characterName then
            setProperty('AbotSpeaker.visible', false)
        end
    end
end

function onSongStart()
    runHaxeFunction('startVisualizer')
end

function onMoveCamera(character)
    if character == 'boyfriend' then
        callMethod('AbotSpeaker.lookRight')
    end

    if character == 'dad' then
        callMethod('AbotSpeaker.lookLeft')
    end
end

function onEvent(eventName, value1, value2, strumTime)
    if eventName == 'Change Character' then
        if getCharacterType(value2) == characterType and value2 ~= characterName then
            setProperty('AbotSpeaker.visible', false)
        elseif characterName ~= '' then
            createSpeaker(characterName, offsetData[1], offsetData[2])
        end
    end
    if eventName == 'Set Camera Target' then
        for _, startStringBF in ipairs({'0', 'bf', 'boyfriend'}) do
            if stringStartsWith(string.lower(value1), startStringBF) then
                callMethod('AbotSpeaker.lookRight')
            end
        end
        for _, startStringDad in ipairs({'1', 'dad', 'opponent'}) do
            if stringStartsWith(string.lower(value1), startStringDad) then
                callMethod('AbotSpeaker.lookLeft')
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
                    setProperty('AbotSpeaker.'..propertyTracker[property][1], propertyTracker[property][2] + offsetData[property])
                end
            else
                if propertyTracker[property][2] ~= getProperty(characterType..'.'..propertyTracker[property][1]) then
                    propertyTracker[property][2] = getProperty(characterType..'.'..propertyTracker[property][1])
                    setProperty('AbotSpeaker.'..propertyTracker[property][1], propertyTracker[property][2])
                end
            end
        end
    end
end

function translateAlpha(value)
    setShaderFloat('AbotSpeaker.speaker', 'fadeAmount', value)
    for i = 0, getProperty('AbotSpeaker.vizSprites.length') - 1 do
        setShaderFloat('AbotSpeaker.vizSprites['..i..']', 'hue', interpolateFloat(0, -26, value))
        setShaderFloat('AbotSpeaker.vizSprites['..i..']', 'saturation', interpolateFloat(0, -45, value))
        setShaderFloat('AbotSpeaker.vizSprites['..i..']', 'contrast', interpolateFloat(0, 0, value))
        setShaderFloat('AbotSpeaker.vizSprites['..i..']', 'brightness', interpolateFloat(0, -12, value))
    end

    setProperty('AbotSpeaker.bg.color', interpolateColor(0xFFFFFF, 0x616785, value))
    setProperty('AbotSpeaker.eyeBg.color', interpolateColor(0xFFFFFF, 0x6F96CE, value))
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