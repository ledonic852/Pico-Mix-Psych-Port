function onCreate()
	addHaxeLibrary('FlxAngle', 'flixel.math')
	makeLuaSprite('bar', 'tankmanBattlefield/erect/bg', -985, -805)
	scaleObject('bar', 1.15, 1.15)
	addLuaSprite('bar')

	if lowQuality == false then
		makeAnimatedLuaSprite('sniper', 'tankmanBattlefield/erect/sniper', -127, 349)
		addAnimationByPrefix('sniper', 'idle', 'Tankmanidlebaked instance 1', 24, false)
		addAnimationByPrefix('sniper', 'sip', 'tanksippingBaked instance 1', 24, false)
		scaleObject('sniper', 1.15, 1.15)
		addLuaSprite('sniper')
		playAnim('sniper', 'idle')

		makeAnimatedLuaSprite('tankguy', 'tankmanBattlefield/erect/guy', 1398, 407)
		addAnimationByPrefix('tankguy', 'idle', 'BLTank2 instance 1', 24, false)
		scaleObject('tankguy', 1.15, 1.15)
		addLuaSprite('tankguy')
	end

	-- Sets and precaches the Tankman death voicelines.
	if stringStartsWith(boyfriendName, 'pico') then
		charVariant = '-pico'
		maxVoicelines = 10
	else
		charVariant = ''
		maxVoicelines = 25
	end

	for i = 1, maxVoicelines do
		precacheSound('jeffGameover'..charVariant..'/jeffGameover-'..i)
	end
end

function onCreatePost()
	if shadersEnabled == true then
		runHaxeCode([[
            import flixel.math.FlxAngle;
			function setShaderFrameInfo(objectName:String) {
				var object:FlxSprite;
				switch(objectName) {
					case 'boyfriend':
                    	object = game.boyfriend;
                	case 'dad':
                    	object = game.dad;
                	case 'gf':
                    	object = game.gf;
                	default:
                    	object = game.getLuaObject(objectName);
				}

				object.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
            	{
					if (object.shader != null) {
						object.shader.setFloatArray('uFrameBounds', [object.frame.uv.x, object.frame.uv.y, object.frame.uv.width, object.frame.uv.height]);
                		object.shader.setFloat('angOffset', object.frame.angle * FlxAngle.TO_RAD);
					}
            	}
			}
        ]])

		initLuaShader('dropShadow')
        for i, object in ipairs({'boyfriend', 'dad', 'gf'}) do
            setSpriteShader(object, 'dropShadow')
    		setShaderFloat(object, 'hue', -38)
    		setShaderFloat(object, 'saturation', -20)
    		setShaderFloat(object, 'contrast', -25)
    		setShaderFloat(object, 'brightness', -46)
			
            setShaderFloat(object, 'ang', math.rad(90))
    		setShaderFloat(object, 'str', 1)
    		setShaderFloat(object, 'dist', 15)
    		setShaderFloat(object, 'thr', 0.1)

			setShaderFloat(object, 'AA_STAGES', 2)
			setShaderFloatArray(object, 'dropColor', {223 / 255, 239 / 255, 60 / 255})
			runHaxeFunction('setShaderFrameInfo', {object})

			local imageFile = stringSplit(getProperty(object..'.imageFile'), '/')
			if checkFileExists('images/characters/masks/'..imageFile[#imageFile]..'_mask.png') then
				setShaderSampler2D(object, 'altMask', 'characters/masks/'..imageFile[#imageFile]..'_mask')
				setShaderFloat(object, 'thr2', 1)
				setShaderBool(object, 'useMask', true)
			else
				setShaderBool(object, 'useMask', false)
			end

			if _G[object..'Name'] =='gf-tankmen' then
				setShaderFloat(object, 'thr2', 0.4)
			end

			if object == 'dad' then
				setShaderFloat(object, 'ang', math.rad(135))
    			setShaderFloat(object, 'thr', 0.3)
			end
		end
	end
end

--[[
	This handles the tankmen bopping their heads on beat, 
	and also randomly make the sniper guy drink his cup.
]]
sniperSpecialAnim = false
function onCountdownTick(counter)
	if lowQuality == false then
		if getRandomBool(2) and sniperSpecialAnim == false then
			playAnim('sniper', 'sip', true)
			runTimer('sipAnimLength', getProperty('sniper.animation.curAnim.numFrames') / 24)
			sniperSpecialAnim = true
		end

		if counter % 2 == 0 then
			if sniperSpecialAnim == false then
				playAnim('sniper', 'idle', true)
			end
			playAnim('tankguy', 'idle', true)
		end
	end
end

function onBeatHit()
	if lowQuality == false then
		if getRandomBool(2) and sniperSpecialAnim == false then
			playAnim('sniper', 'sip', true)
			runTimer('sipAnimLength', getProperty('sniper.animation.curAnim.numFrames') / 24)
			sniperSpecialAnim = true
		end

		if curBeat % 2 == 0 then
			if sniperSpecialAnim == false then
				playAnim('sniper', 'idle', true)
			end
			playAnim('tankguy', 'idle', true)
		end
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'sipAnimLength' then
		sniperSpecialAnim = false
	end
end

-- Everything from here handles Tankman voiceline's when you die (skill issue dumbass). 
startedDeathSound = false
deathSoundEnded = false
function onUpdate(elapsed)
	if inGameOver == true and startedDeathSound == false then
		curAnim = (getPropertyFromGameOver('boyfriend.animation.curAnim.name') or getPropertyFromGameOver('boyfriend.atlas.anim.curSymbol.name'))
		if curAnim == 'firstDeath' then
			animEnded = (getPropertyFromGameOver('boyfriend.animation.curAnim.finished') or getPropertyFromGameOver('boyfriend.atlas.anim.finished'))
			if animEnded then
				local jeffVariant = getRandomInt(1, maxVoicelines)
				playSound('jeffGameover'..charVariant..'/jeffGameover-'..jeffVariant, 1, 'jeffVoiceline')
				startedDeathSound = true
			end
		end
	end
end

function onUpdatePost(elapsed)
	if inGameOver == true and deathSoundEnded == false then
		setSoundVolume(nil, 0.2)
	end
end

local gameOverFinished = false
function onGameOverConfirm()
	gameOverFinished = true
end

function onSoundFinished(tag)
	if tag == 'jeffVoiceline' and gameOverFinished == false then
		soundFadeIn(nil, 4, 0.2, 1)
		deathSoundEnded = true
	end
end

function getPropertyFromGameOver(property)
    if getPropertyFromClass('substates.GameOverSubstate', property) ~= nil then
        return getPropertyFromClass('substates.GameOverSubstate', property)
    else
        return getPropertyFromClass('substates.GameOverSubstate', 'instance.'..property)
    end
end