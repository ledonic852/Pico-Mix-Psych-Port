local neneComboAnim = nil
local animOptions = {Disabled = 'none', Psych = 'psych', Vanilla = 'vanilla'}
function onCreate()
    --[[
        This is how the script recognizes which option you chose to use.
        However, if you decide to take Nene inside another mod,
        the 'neneComboAnim' variable will default to 'none' to avoid any bugs or issues.
        If that's the case, you can manually choose which option to pick by putting a string from 'animOptions'.
    ]]
    for optionName, optionStr in pairs(animOptions) do
        if getModSetting('neneComboAnim', currentModDirectory) == optionName then
            neneComboAnim = optionStr
        elseif getModSetting('neneComboAnim', currentModDirectory) == nil then
            neneComboAnim = 'none'
        end
    end
end

function onCreatePost()
    --[[
        If you ever want to use Abot Speaker on another character,
        just copy and paste this below, and change what's between '{}'.
    
        WARNING: The speaker can only get attached to BF, Dad, or GF type characters.
        Else, the offsets act as simple x and y positions.
        Go check the Abot Speaker's script for more information at line 374.
    ]]
    addLuaScript('characters/abot-speaker-pixel')
    callScript('characters/abot-speaker-pixel', 'createSpeaker', {'nene-pixel', 0, 0}) -- {characterName, offsetX, offsetY}
    if curStage == 'schoolErect' then
        setVar('trackShader', false) -- Check line 30 of 'abot-speaker-pixel' to know its use.
        if shadersEnabled == true then
            initLuaShader('dropShadow')
            setSpriteShader('AbotPixelSpeakers', 'dropShadow')
            setShaderFloat('AbotPixelSpeakers', 'hue', -10)
            setShaderFloat('AbotPixelSpeakers', 'saturation', -23)
            setShaderFloat('AbotPixelSpeakers', 'contrast', 24)
            setShaderFloat('AbotPixelSpeakers', 'brightness', -66)
                
            setShaderFloat('AbotPixelSpeakers', 'ang', math.rad(90))
            setShaderFloat('AbotPixelSpeakers', 'str', 1)
            setShaderFloat('AbotPixelSpeakers', 'dist', 5)
            setShaderFloat('AbotPixelSpeakers', 'thr', 1)

            setShaderFloat('AbotPixelSpeakers', 'AA_STAGES', 0)
            setShaderFloatArray('AbotPixelSpeakers', 'dropColor', {82 / 255, 53 / 255, 29 / 255})

            setShaderSampler2D('AbotPixelSpeakers', 'altMask', 'characters/abot/pixel/masks/aBotPixelSpeaker_mask')
            setShaderFloat('AbotPixelSpeakers', 'thr2', 0)
            setShaderBool('AbotPixelSpeakers', 'useMask', true)

            initLuaShader('adjustColor')
            for _, object in ipairs({'AbotSpeakerPixel', 'AbotSpeakerBGPixel', 'AbotHeadPixel'}) do
                setSpriteShader(object, 'adjustColor')
                setShaderFloat(object, 'hue', -10)
                setShaderFloat(object, 'saturation', -23)
                setShaderFloat(object, 'contrast', 24)
                setShaderFloat(object, 'brightness', -66)
            end
            for bar = 1, 7 do
                setSpriteShader('AbotSpeakerVisualizerPixel'..bar, 'adjustColor')
                setShaderFloat('AbotSpeakerVisualizerPixel'..bar, 'hue', -10)
                setShaderFloat('AbotSpeakerVisualizerPixel'..bar, 'saturation', -23)
                setShaderFloat('AbotSpeakerVisualizerPixel'..bar, 'contrast', 24)
                setShaderFloat('AbotSpeakerVisualizerPixel'..bar, 'brightness', -66)
            end
        end
	end
end

function onUpdatePost(elapsed)
	if shadersEnabled == true then
		setShaderFloatArray('AbotPixelSpeakers', 'uFrameBounds', {getProperty('AbotPixelSpeakers.frame.uv.x'), getProperty('AbotPixelSpeakers.frame.uv.y'), getProperty('AbotPixelSpeakers.frame.uv.width'), getProperty('AbotPixelSpeakers.frame.uv.height')})
	    setShaderFloat('AbotPixelSpeakers', 'angOffset', math.rad(getProperty('AbotPixelSpeakers.frame.angle')))
	end
end

function onUpdatePost(elapsed)
    if songName ~= "Blazin'" then
        transitionAnim()
    end
end

--[[
    This function is what controls Nene's animations dependently of the player's health.
    When the player's health is low, Nene will smoothly go to her 'raiseKnife' anim.
    If the player gains enough health, Nene will go back to bopping her head.
]]
local animTrans = 0
local blinkDelay = 3
function transitionAnim()
    if animTrans == 0 then -- Nene noticed the player being low on health.
        if getHealth() <= 0.5 then
            animTrans = 1
        else
            animTrans = 0
        end
    elseif animTrans == 1 then -- Nene stops bopping her head and raises her knife.
        if getHealth() > 0.5 then
            animTrans = 0
        elseif getProperty('gf.animation.name') == 'danceLeft' then
            comboAnimActive = false
            setProperty('gf.specialAnim', true)
            if getProperty('gf.animation.curAnim.curFrame') >= 6 then
                callMethod('AbotSpeakerPixel.animation.curAnim.finish')
            end
            if getProperty('gf.animation.finished') then
                animTrans = 2
                playAnim('gf', 'raiseKnife')
                setProperty('gf.specialAnim', true)
                changedBeat = curBeat
            end
        end
    elseif animTrans == 2 then -- Nene keeps raising her knife while randomly blinking on beat, or lowers her knife.
        callMethod('AbotSpeakerPixel.animation.curAnim.finish')
        if getHealth() > 0.5 then
            animTrans = 3
            playAnim('gf', 'lowerKnife')
            setProperty('gf.specialAnim', true)
        elseif getProperty('gf.animation.finished') then
            if getProperty('gf.animation.name') ~= 'idleKnife' or curBeat - changedBeat == blinkDelay then
                blinkDelay = getRandomInt(3, 7)
                changedBeat = curBeat
                playAnim('gf', 'idleKnife')
                setProperty('gf.specialAnim', true)
            else
                lastFrame = getProperty('gf.animation.numFrames')
                playAnim('gf', 'idleKnife', false, false, lastFrame)
                setProperty('gf.specialAnim', true)
            end
        end
    elseif animTrans == 3 then -- Nene goes back to bopping her head.
        callMethod('AbotSpeakerPixel.animation.curAnim.finish')
        if getProperty('gf.animation.finished') then
            animTrans = 0
            comboAnimActive = true
            setProperty('gf.danced', false)
            characterDance('gf')
            playAnim('AbotSpeakerPixel', 'idle', true)
        end   
    end
end