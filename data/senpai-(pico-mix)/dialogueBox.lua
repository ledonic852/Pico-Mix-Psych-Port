dialogueBoxData = {
    musicName = 'Lunchbox',
    soundIntro = 'ANGRY_TEXT_BOX',
    useMusic = true,
    useSoundIntro = false
}
bfDialogueData = {
    name = 'pico',
    expressions = {
        normal = {x = 0, y = 0},
        peeved = {x = 50, y = 45}
    }
}
dadDialogueData = {
    name = 'senpai',
    expressions = {
        normal = {x = 0, y = 0},
        bwuh = {x = 10, y = 0}
    }
}
gfDialogueData = {
    name = 'nene',
    expressions = {
        normal = {x = 0, y = 0},
        peeved = {x = 30, y = 60}
    }
}

local dialogueFinished = false
function onCreate()
    setVar('dialogueFinished', dialogueFinished)
    if dialogueBoxData.useMusic == true then
        playMusic(dialogueBoxData.musicName, 0, true)
        soundFadeIn(nil, 1, 0, 0.8)
    end
    if dialogueBoxData.useSoundIntro == true then
        playSound(dialogueBoxData.soundIntro)
    end
end

local dialogueList = {}
function createDialogueBox(isMad)
    local dialogueFile = callMethodFromClass('backend.Paths', 'txt', {songPath..'/dialogue'})
    dialogueList = callMethodFromClass('backend.CoolUtil', 'coolTextFile', {dialogueFile})

    setProperty('inCutscene', true)
    makeLuaSprite('dialogueBG')
    makeGraphic('dialogueBG', 2000, 2500, 'B3DFD8')
    screenCenter('dialogueBG')
    setObjectCamera('dialogueBG', 'camHUD')
    addLuaSprite('dialogueBG', true)
    if alpha ~= nil then
        setProperty('dialogueBG.alpha', alpha)
    else
        setProperty('dialogueBG.alpha', 0.7)
    end

    makeAnimatedLuaSprite('dialogueBox', 'weeb/pixelUI/dialogueBox-school', -20, 40)
    addAnimationByPrefix('dialogueBox', 'open', 'normalEntrance', 24, false)
    addAnimationByPrefix('dialogueBox', 'openMad', 'madEntrance', 24, false)
    setObjectCamera('dialogueBox', 'camHUD')
    scaleObject('dialogueBox', 6 * 0.9, 6 * 0.9)
    screenCenter('dialogueBox', 'x')
    addLuaSprite('dialogueBox', true)
    setProperty('dialogueBox.antialiasing', false)
    if isMad == true then
        playAnim('dialogueBox', 'openMad')
    else
        playAnim('dialogueBox', 'open')
    end

    makeAnimatedLuaSprite('portraitLeft', 'weeb/pixelUI/portraits/portrait-'..dadDialogueData.name, 330, 265)
    addAnimationByPrefix('portraitLeft', 'appear', 'portraitEnter', 24, false)
    setObjectCamera('portraitLeft', 'camHUD')
    setObjectOrder('portraitLeft', getObjectOrder('dialogueBox'))
    scaleObject('portraitLeft', 6 * 0.9, 6 * 0.9, false)
    addLuaSprite('portraitLeft', true)
    setProperty('portraitLeft.antialiasing', false)
    setProperty('portraitLeft.visible', false)

    makeAnimatedLuaSprite('portraitRight', 'weeb/pixelUI/portraits/portrait-'..bfDialogueData.name, 975, 295)
    addAnimationByPrefix('portraitRight', 'appear', 'portraitEnter', 24, false)
    setObjectCamera('portraitRight', 'camHUD')
    setObjectOrder('portraitRight', getObjectOrder('dialogueBox'))
    scaleObject('portraitRight', 6 * 0.9, 6 * 0.9, false)
    addLuaSprite('portraitRight', true)
    setProperty('portraitRight.antialiasing', false)
    setProperty('portraitRight.visible', false)

    makeAnimatedLuaSprite('portraitMiddle', 'weeb/pixelUI/portraits/portrait-'..gfDialogueData.name, 660, 310)
    addAnimationByPrefix('portraitMiddle', 'appear', 'portraitEnter', 24, false)
    setObjectCamera('portraitMiddle', 'camHUD')
    setObjectOrder('portraitMiddle', getObjectOrder('dialogueBox'))
    scaleObject('portraitMiddle', 6 * 0.9, 6 * 0.9, false)
    addLuaSprite('portraitMiddle', true)
    setProperty('portraitMiddle.antialiasing', false)
    setProperty('portraitMiddle.visible', false)

    makeLuaSprite('handSelectBox', 'weeb/pixelUI/hand_textbox', 1042, 585)
    setObjectCamera('handSelectBox', 'camHUD')
    scaleObject('handSelectBox', 6 * 0.9, 6 * 0.9)
    addLuaSprite('handSelectBox', true)
    setProperty('handSelectBox.antialiasing', false)
    setProperty('handSelectBox.visible', false)

    createInstance('dialogueText', 'flixel.addons.text.FlxTypeText', {200, 495, screenWidth * 0.7, '', 32})
    setObjectCamera('dialogueText', 'camHUD')
    setTextFont('dialogueText', 'pixel-latin.ttf')
    setTextColor('dialogueText', '3F2021')
    setTextBorder('dialogueText', 1, 'D89494', 'shadow')
    addInstance('dialogueText', true)
    callMethod('dialogueText.shadowOffset.set', {2, 2})
    runHaxeCode([[
        getLuaObject('dialogueText').sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
        return; // DON'T REMOVE THIS LINE FOR THE LOVE OF GOD.
    ]])

    local skipText = callMethodFromClass('backend.Language', 'getPhrase', {'dialogue_skip', 'Press BACK to Skip'})
    makeLuaText('skipText', skipText, 300, screenWidth - 320, screenHeight - 30)
    setTextSize('skipText', 16)
    setTextFont('skipText', 'nokiafc22.ttf')
    setTextAlignment('skipText', 'right')
    setTextBorder('skipText', 2, '000000', 'outline_fast')
    addLuaText('skipText')
end

local dialogueData = {}
local dialogueStarted = false
local dialogueEnded = false
local senpaiDisgusted = false
function onUpdatePost(elapsed)
    if getProperty('inCutscene') == true and dialogueFinished == false then
        if getProperty('dialogueBox.animation.finished') == true and dialogueStarted == false then
            dialogueStarted = true
            dialogueStart()
        end

        if keyJustPressed('back') then
            if dialogueStarted == true then
                dialogueFinish()
            end
        elseif keyJustPressed('accept') then
            if dialogueEnded == true then
                if dialogueList[2] == nil and dialogueList[1] == nil then
                    if getProperty('dialogueText.paused') == false then
                        dialogueFinish()
                    else
                        dialogueStart()
                        playSound('clickText', 0.8)
                    end
                else
                    dialogueStart()
                    playSound('clickText', 0.8)
                end
            elseif dialogueStarted == true then
                dialogueSkip()
            end
        end

        if dialogueEnded == false then
            if dialogueData.pausePos[1] ~= nil then
                stopDialogue = dialogueData.pausePos[1] - 1
            else
                stopDialogue = getProperty('dialogueText._finalText.length')
            end

            if getProperty('dialogueText._length') == stopDialogue then
                dialogueEnded = true
                setProperty('handSelectBox.visible', true)

                if dialogueData.pausePos[1] ~= nil then
                    setProperty('dialogueText.paused', true)
                    table.remove(dialogueData.pausePos, 1)
                end
            end
        end

        --[[
            Specific dialogue events here, cause I'm too lazy to implement a system in the script itself.
            You don't know how long it took me to make the dialogue system in its own, so fuck this.
        ]]
        if dialogueData.char == 'dad' and dialogueBoxData.useMusic == true then
            if dialogueData.expression == 'bwuh' and senpaiDisgusted == false then
                senpaiDisgusted = true
                setSoundVolume(nil, 0)
            elseif dialogueData.expression == 'normal' and senpaiDisgusted == true then
                senpaiDisgusted = false
                soundFadeIn(nil, 1, 0, 0.8)
            end
        end
    end
end

function dialogueStart()
    if getProperty('dialogueText.paused') == false then
        dialogueData = getCurrentDialogueData()
        callMethod('dialogueText.resetText', {dialogueData.text:gsub('|', '')})
    end
    callMethod('dialogueText.start', {0.04})

    dialogueEnded = false
    setProperty('handSelectBox.visible', false)
    for char, side in pairs({dad = 'Left', bf = 'Right', gf = 'Middle'}) do
        if dialogueData.char == char then
            changeExpression(dialogueData.char, dialogueData.expression)
            if getProperty('portrait'..side..'.visible') == false then
                setProperty('portrait'..side..'.visible', true)
                playAnim('portrait'..side, 'appear', true)
            else
                callMethod('portrait'..side..'.animation.curAnim.finish')
            end
            setProperty('portrait'..side..'.alpha', 1)
        else
            setProperty('portrait'..side..'.alpha', 0)
        end
    end
end

function dialogueSkip()
    if getProperty('dialogueText.paused') == false then
        if dialogueData.pausePos[1] ~= nil then
            setProperty('dialogueText._length', dialogueData.pausePos[1] - 1)
            setProperty('dialogueText.paused', true)
            table.remove(dialogueData.pausePos, 1)
        else
            callMethod('dialogueText.skip')
        end
    end
    setProperty('handSelectBox.visible', true)
    playSound('clickText', 0.8)
    dialogueEnded = true
end

function dialogueFinish()
    dialogueSkip()
    dialogueFinished = true
    setVar('dialogueFinished', dialogueFinished)
    cancelTimer('dialogueBGFadeIn')
    if dialogueBoxData.useMusic == true then
        soundFadeOut(nil, 1.5, 0)
    end
    setProperty('skipText.visible', false)
    runTimer('destroyDialogueBox', 0.2, 5)
    runTimer('startGame', 1.5)
end

function getCurrentDialogueData()
    local split = stringSplit(dialogueList[1], '::')
    table.remove(dialogueList, 1)

    local dialogue = split[3]
    local textPause = {}
    local pause = dialogue:find('|')
    local lastPause = 1
    while pause ~= nil do
        table.insert(textPause, pause)
        dialogue:gsub('|', '', 1)
        lastPause = textPause[#textPause]
        pause = dialogue:find('|', lastPause + 1)
    end

    for i = 1, #textPause do
        textPause[i] = textPause[i] - (i - 1)
    end
    
    return {char = split[1], expression = split[2], text = split[3], pausePos = textPause}
end

function changeExpression(character, newExpression)
    local charSide = ''
    local charName = ''
    local charExpressions = {}
    for char, side in pairs({dad = 'Left', bf = 'Right', gf = 'Middle'}) do
        if character == char then
            charSide = side
            charName = _G[character..'DialogueData'].name
            charExpressions = _G[character..'DialogueData'].expressions
        end
    end

    for expression, offset in pairs(charExpressions) do
        if expression == newExpression then
            if newExpression == 'normal' then
                loadFrames('portrait'..charSide, 'weeb/pixelUI/portraits/portrait-'..charName)
            else
                loadFrames('portrait'..charSide, 'weeb/pixelUI/portraits/portrait-'..charName..'-'..expression)
            end
            addAnimationByPrefix('portrait'..charSide, 'appear', 'portraitEnter', 24, false)
            addOffset('portrait'..charSide, 'appear', offset.x, offset.y)
            playAnim('portrait'..charSide, 'appear')
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'dialogueBGFadeIn' then
        alpha = ((loops - loopsLeft) / loops) * 0.7
        setProperty('dialogueBG.alpha', alpha)
    end
    if tag == 'destroyDialogueBox' then
        for i, object in ipairs({'dialogueBG', 'dialogueBox', 'handSelectBox', 'dialogueText', 'skipText'}) do
            if i == 1 then
                setProperty(object..'.alpha', getProperty(object..'.alpha') - (1 / 5) * 0.7)
            else
                setProperty(object..'.alpha', getProperty(object..'.alpha') - (1 / 5))
            end
        end
        for _, side in ipairs({'Left', 'Right', 'Middle'}) do
            setProperty('portrait'..side..'.visible', false)
        end 
    end
    if tag == 'startGame' then
        for i, object in ipairs({'dialogueBG', 'dialogueBox', 'handSelectBox', 'dialogueText', 'skipText'}) do
            if i < 4 then
                removeLuaSprite(object)
            else
                removeLuaText(object)
            end
        end
        for _, side in ipairs({'Left', 'Right', 'Middle'}) do
            removeLuaSprite('portrait'..side)
        end
        triggerEvent('Set Camera Target', '', '')
        startCountdown()
    end
end