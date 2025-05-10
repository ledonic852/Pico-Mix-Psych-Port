function onCreatePost()
    --[[
        If you ever want to use Abot Speaker on another character,
        just copy and paste this below, and change what's between '{}'.
    
        WARNING: The speaker can only get attached to BF, Dad, or GF type characters.
        Else, the offsets act as simple x and y positions.
        Go check the Abot Speaker's script for more information at line 374.
    ]]
    addLuaScript('characters/abot-speaker')
    callScript('characters/abot-speaker', 'createSpeaker', {'otis-speaker', 5, 10}) -- {characterName, offsetX, offsetY}
    if curStage == 'tankErect' then
        setVar('trackShader', false) -- Check line 30 of 'abot-speaker' to know its use.
        if shadersEnabled == true then
            initLuaShader('adjustColor')
            for _, object in ipairs({'AbotSpeaker', 'AbotSpeakerBG', 'AbotPupils', 'AbotEyes'}) do
                setSpriteShader(object, 'adjustColor')
                setShaderFloat(object, 'hue', -10)
                setShaderFloat(object, 'saturation', -20)
                setShaderFloat(object, 'contrast', -25)
                setShaderFloat(object, 'brightness', -30)
            end

            for bar = 1, 7 do
                setSpriteShader('AbotSpeakerVisualizer'..bar, 'adjustColor')
                setShaderFloat('AbotSpeakerVisualizer'..bar, 'hue', -30)
                setShaderFloat('AbotSpeakerVisualizer'..bar, 'saturation', -10)
                setShaderFloat('AbotSpeakerVisualizer'..bar, 'contrast', 0)
                setShaderFloat('AbotSpeakerVisualizer'..bar, 'brightness', -12)
            end
        end
	end
end