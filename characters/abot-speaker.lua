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

    if visualizerActive == false then
        for i = 0, 6 do
            callMethod('AbotSpeaker.vizSprites['..i..'].animation.addByPrefix', {'idle', 'viz'..(i + 1), 24, false})
        end
    end

    runHaxeCode([[
        var abot = getLuaObject('AbotSpeaker');
        function startVisualizer() abot.snd = FlxG.sound.music;
        function stopVisualizer() {
            abot.analyzer = null;
            for (i in 0...abot.vizSprites.length) {
                abot.vizSprites[i].animation.curAnim.finish();
            }
        }

        function speakerShaderCheck(character:String) return abot.speaker.shader == getAttachedCharacter(character).shader;
        function applySpeakerShader(character:String) {
            for (object in [abot.speaker, abot.bg, abot.eyes, abot.eyeBg]) {
                object.shader = getAttachedCharacter(character).shader;
            }
            for (i in 0...abot.vizSprites.length) {
                abot.vizSprites[i].shader = getAttachedCharacter(character).shader;
            }
        }

        function getAttachedCharacter(character:String) {
            switch(character) {
                case 'boyfriend':
                    return game.boyfriend;
                case 'dad':
                    return game.dad;
                case 'gf':
                    return game.gf;
                default:
                    return getLuaObject('AbotSpeaker');
            }
        }
    ]])

    if characterName ~= '' then
        if _G[characterType..'Name'] ~= characterName then
            setProperty('AbotSpeaker.visible', false)
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
            callMethod('AbotSpeaker.beatHit')
            for i = 0, 6 do
                callMethod('AbotSpeaker.vizSprites['..i..'].animation.play', {'idle', true})
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
            callMethod('AbotSpeaker.beatHit')
            for i = 0, 6 do
                callMethod('AbotSpeaker.vizSprites['..i..'].animation.play', {'idle', true})
            end
        end
    end
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
    if runHaxeFunction('speakerShaderCheck', {characterType}) == false then
        runHaxeFunction('applySpeakerShader', {characterType})
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