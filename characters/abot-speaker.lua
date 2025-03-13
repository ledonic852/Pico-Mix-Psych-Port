local characterType = ''
local characterName = ''
local offsetData = {0, 0}
local propertyTracker = {
    {'x', nil},
    {'y', nil},
    {'color', nil},
    {'scrollFactor.x', nil},
    {'scrollFactor.y', nil},
    {'angle', nil},
    {'alpha', nil},
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

    if characterType ~= '' then
        runHaxeCode([[
            function startVisualizer() getLuaObject('AbotSpeaker').snd = FlxG.sound.music;
            function speakerShaderCheck() return getLuaObject('AbotSpeaker').speaker.shader == ]]..characterType..[[.shader;
            function applySpeakerShader() {
                var abot = getLuaObject('AbotSpeaker');
                for (object in [abot.speaker, abot.bg, abot.eyes, abot.eyeBg]) {
                    object.shader = ]]..characterType..[[.shader;
                }
                for (i in 0...abot.vizSprites.length) {
                    abot.vizSprites[i].shader = ]]..characterType..[[.shader;
                }
            }
        ]])
    else
        runHaxeCode([[
            function startVisualizer() getLuaObject('AbotSpeaker').snd = FlxG.sound.music;
        ]])
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
    if characterType ~= '' then
        if runHaxeFunction('speakerShaderCheck') == false then
            runHaxeFunction('applySpeakerShader')
        end
    end
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