function onCreatePost()
    makeAnimatedLuaSprite('muzzleFlash', 'characters/otis_flashes')
    addAnimationByPrefix('muzzleFlash', 'shoot1', 'shoot back0', 24, false)
    addAnimationByPrefix('muzzleFlash', 'shoot2', 'shoot back low0', 24, false)
    addAnimationByPrefix('muzzleFlash', 'shoot3', 'shoot forward0', 24, false)
    addAnimationByPrefix('muzzleFlash', 'shoot4', 'shoot forward low0', 24, false)
    setObjectOrder('muzzleFlash', getObjectOrder('gfGroup') + 1)
    addLuaSprite('muzzleFlash')

    --[[
        If you ever want to use Abot Speaker on another character,
        just copy and paste this below, and change what's between '{}'.
    
        WARNING: The speaker can only get attached to BF, Dad, or GF type characters.
        Else, the offsets act as simple x and y positions.
        Go check the 'abot-speaker' script for more information at line 385.
    ]]
    addLuaScript('characters/abot-speaker')
    callScript('characters/abot-speaker', 'createSpeaker', {'otis-speaker', 5, 10}) -- {characterName, offsetX, offsetY}

    -- Some extra code to set up the speaker's shader in the 'tankErect' stage.
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

-- Everything underneath is for the muzzle flash when Otis shoots.
function onUpdatePost(elapsed)
    local gfCurAnim = getProperty('gf.animation.curAnim.name')
    updateMuzzleFlash(gfCurAnim)
    
    if stringStartsWith(gfCurAnim, 'shoot') then
        if getProperty('muzzleFlash.animation.curAnim.name') ~= gfCurAnim then
            playAnim('muzzleFlash', gfCurAnim, true)
            setBlendMode('muzzleFlash', 'ADD')
        end
    end
end

function updateMuzzleFlash(curAnim)
    if getProperty('muzzleFlash.animation.curAnim.curFrame') > 1 then
        setProperty('muzzleFlash.blend', nil)
    end
    setProperty('muzzleFlash.visible', not getProperty('muzzleFlash.animation.finished'))

    if curAnim == 'shoot1' then
        setProperty('muzzleFlash.x', getProperty('gf.x') + 640)
        setProperty('muzzleFlash.y', getProperty('gf.y') - 20)
    elseif curAnim == 'shoot2' then
        setProperty('muzzleFlash.x', getProperty('gf.x') + 650)
        setProperty('muzzleFlash.y', getProperty('gf.y') - 50)
    elseif curAnim == 'shoot3' then
        setProperty('muzzleFlash.x', getProperty('gf.x') - 540)
        setProperty('muzzleFlash.y', getProperty('gf.y') - 50)
    elseif curAnim == 'shoot4' then
        setProperty('muzzleFlash.x', getProperty('gf.x') - 570)
        setProperty('muzzleFlash.y', getProperty('gf.y') - 90)
    end
end