local shootNotes = {}
local runTankmen = {}
function onCreate()
    local songFormat = callMethodFromClass('backend.Paths', 'formatToSongPath', {songPath})
    local shootChart = callMethodFromClass('backend.Song', 'getChart', {'picospeaker', songFormat})
    for _, section in pairs(shootChart.notes) do
        for _, note in pairs(section.sectionNotes) do
            table.insert(shootNotes, note)
        end
    end

    if lowQuality == false then
        local tankNum = 0
        for i = 1, #shootNotes do
            if getRandomBool(16) then
                tankNum = tankNum + 1
                local offset = getRandomInt(25, 50)
                createTankman('tankmanRun'..tankNum, 500, 275 + offset, shootNotes[i][2] < 2)
                runTankmen[tankNum] = {
                    strumTime = shootNotes[i][1],
                    goingRight = shootNotes[i][2] < 2,
                    endingOffset = getRandomFloat(50, 200),
                    speed = getRandomFloat(0.6, 1),
                    isDead = false
                }
            end
        end
    end
end

function onCreatePost()
    if shadersEnabled == true then
		initLuaShader('dropShadow')
        for tankNum = 1, #runTankmen do
            local tag = 'tankmanRun'..tankNum
            setSpriteShader(tag, 'dropShadow')
    		setShaderFloat(tag, 'hue', -38)
    		setShaderFloat(tag, 'saturation', -20)
    		setShaderFloat(tag, 'contrast', -25)
    		setShaderFloat(tag, 'brightness', -46)
			
            setShaderFloat(tag, 'ang', math.rad(135))
    		setShaderFloat(tag, 'str', 1)
    		setShaderFloat(tag, 'dist', 15)
    		setShaderFloat(tag, 'thr', 0.4)

			setShaderFloat(tag, 'AA_STAGES', 2)
			setShaderFloatArray(tag, 'dropColor', {223 / 255, 239 / 255, 60 / 255})
            setShaderBool(tag, 'useMask', false)
            runHaxeCode([[
                import flixel.math.FlxAngle;
                var tankmanRun = getLuaObject(tankmanTag);
                tankmanRun.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
                {
                    tankmanRun.shader.setFloatArray('uFrameBounds', [tankmanRun.frame.uv.x, tankmanRun.frame.uv.y, tankmanRun.frame.uv.width, tankmanRun.frame.uv.height]);
                    tankmanRun.shader.setFloat('angOffset', tankmanRun.frame.angle * FlxAngle.TO_RAD);
                }
            ]], {tankmanTag = tag})
		end
	end
end

function onUpdatePost(elapsed)
    updateTankman()
    if #shootNotes > 0 and getSongPosition() > shootNotes[1][1] then
        noteData = shootNotes[1][2] + 1
        playAnim('gf', 'shoot'..noteData, true)
        setProperty('gf.specialAnim', true)
        table.remove(shootNotes, 1)
    end
end

function createTankman(tag, x, y, facingRight)
    local antialisConfig = getPropertyFromClass('backend.ClientPrefs', 'data.antialiasing')
    local shotAlt = getRandomInt(1, 2)
    makeAnimatedLuaSprite(tag, 'tankmanBattlefield/tankmanKilled1', x, y)
    addAnimationByPrefix(tag, 'run', 'tankman running')
    addAnimationByPrefix(tag, 'shot', 'John Shot '..shotAlt, 24, false)
    addOffset(tag, 'shot', 300, 200)
    scaleObject(tag, 1.05, 1.05, false)
    addLuaSprite(tag)

    local startFrame = getRandomInt(0, getProperty(tag..'.animation.curAnim.numFrames') - 1)
    playAnim(tag, 'run', true, false, startFrame)
    setProperty(tag..'.antialiasing', antialisConfig)
    setProperty(tag..'.flipX', facingRight)
end

function updateTankman()
    for tankNum = 1, #runTankmen do
        local tag = 'tankmanRun'..tankNum
        if luaSpriteExists(tag) then
            local visible = (getProperty(tag..'.x') > -1 * screenWidth) and (getProperty(tag..'.x') < 1.5 * screenWidth)
            setProperty(tag..'.visible', visible)

            if getProperty(tag..'.animation.curAnim.name') == 'run' then
                local curSpeed = (getSongPosition() - runTankmen[tankNum].strumTime) * runTankmen[tankNum].speed
                if runTankmen[tankNum].goingRight == true then
                    setProperty(tag..'.x', (-0.05 * screenWidth - runTankmen[tankNum].endingOffset) + curSpeed)
                else
                    setProperty(tag..'.x', (0.95 * screenWidth + runTankmen[tankNum].endingOffset) - curSpeed)
                end
            elseif getProperty(tag..'.animation.finished') then
                removeLuaSprite(tag)
            end

            if getSongPosition() > runTankmen[tankNum].strumTime then
                if runTankmen[tankNum].isDead == false then
                    playAnim(tag, 'shot', true)
                    runTankmen[tankNum].isDead = true
                end
            end
        end
    end
end