function onCreate()
	makeLuaSprite('bar', 'tankmanBattlefield/erect/bg', -985, -805)
	scaleObject('bar', 1.15, 1.15)
	addLuaSprite('bar')

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

function onCreatePost()
	if shadersEnabled == true then
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

function onUpdatePost(elapsed)
	if shadersEnabled == true then
		for i, object in ipairs({'boyfriend', 'dad', 'gf'}) do
			setShaderFloatArray(object, 'uFrameBounds', {getProperty(object..'.frame.uv.x'), getProperty(object..'.frame.uv.y'), getProperty(object..'.frame.uv.width'), getProperty(object..'.frame.uv.height')})
			setShaderFloat(object, 'angOffset', math.rad(getProperty(object..'.frame.angle')))
		end
	end
end

sniperSpecialAnim = false
function onBeatHit()
	if getRandomBool(2) and sniperSpecialAnim == false then
		playAnim('sniper', 'sip', true)
		runTimer('sipAnimLength', getProperty('sniper.animation.curAnim.numFrames') / 24)
		sniperSpecialAnim = true
	end

	if curBeat % 2 == 0 then
		if sniperSpecialAnim == false then
			playAnim('sniper', 'idle')
		end
		playAnim('tankguy', 'idle', true)
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'sipAnimLength' then
		sniperSpecialAnim = false
	end
end