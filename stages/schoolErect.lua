function onCreate()
	makeLuaSprite('sky', 'weeb/erect/weebSky', -164, -78)
	setScrollFactor('sky', 0.2, 0.2)
	scaleObject('sky', 6, 6)
	addLuaSprite('sky')
	setProperty('sky.antialiasing', false)

	makeLuaSprite('treesBackground', 'weeb/erect/weebBackTrees', -242, -80)
	setScrollFactor('treesBackground', 0.5, 0.5)
	scaleObject('treesBackground', 6, 6)
	addLuaSprite('treesBackground')
	setProperty('treesBackground.antialiasing', false)

	makeLuaSprite('schoolBuilding', 'weeb/erect/weebSchool', -216, -38)
	setScrollFactor('schoolBuilding', 0.75, 0.75)
	scaleObject('schoolBuilding', 6, 6)
	addLuaSprite('schoolBuilding')
	setProperty('schoolBuilding.antialiasing', false)

	makeLuaSprite('schoolStreet', 'weeb/erect/weebStreet', -200, 6)
	scaleObject('schoolStreet', 6, 6)
	addLuaSprite('schoolStreet')
	setProperty('schoolStreet.antialiasing', false)

	makeLuaSprite('treesBack', 'weeb/erect/weebTreesBack', -200, 6)
	scaleObject('treesBack', 6, 6)
	addLuaSprite('treesBack')
	setProperty('treesBack.antialiasing', false)

	makeAnimatedLuaSprite('trees', 'weeb/erect/weebTrees', -806, -1050, 'packer')
	addAnimation('trees', 'anim', {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}, 12)
	scaleObject('trees', 6, 6)
	addLuaSprite('trees')
	setProperty('trees.antialiasing', false)

	makeAnimatedLuaSprite('fallingPetals', 'weeb/erect/petals', -20, -40)
	addAnimationByPrefix('fallingPetals', 'anim', 'PETALS ALL')
	scaleObject('fallingPetals', 6, 6)
	addLuaSprite('fallingPetals')
	setProperty('fallingPetals.antialiasing', false)

	setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'bf-pixel-dead')
	setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx-pixel')
	setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'gameOver-pixel')
	setPropertyFromClass('substates.GameOverSubstate', 'endSoundName', 'gameOverEnd-pixel')
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
    		setShaderFloat(object, 'hue', -10)
    		setShaderFloat(object, 'saturation', -23)
    		setShaderFloat(object, 'contrast', 24)
    		setShaderFloat(object, 'brightness', -66)
			
            setShaderFloat(object, 'ang', math.rad(90))
    		setShaderFloat(object, 'str', 1)
    		setShaderFloat(object, 'dist', 5)
    		setShaderFloat(object, 'thr', 0.1)

			setShaderFloat(object, 'AA_STAGES', 0)
			setShaderFloatArray(object, 'dropColor', {82 / 255, 53 / 255, 29 / 255})
			runHaxeFunction('setShaderFrameInfo', {object})

			local imageFile = stringSplit(getProperty(object..'.imageFile'), '/')
			if checkFileExists('images/characters/masks/'..imageFile[#imageFile]..'_mask.png') then
				setShaderSampler2D(object, 'altMask', 'characters/masks/'..imageFile[#imageFile]..'_mask')
				setShaderFloat(object, 'thr2', 1)
				setShaderBool(object, 'useMask', true)
			else
				setShaderBool(object, 'useMask', false)
			end

			if _G[object..'Name'] =='gf-pixel' then
				setShaderFloat(object, 'hue', -10)
    			setShaderFloat(object, 'saturation', -25)
    			setShaderFloat(object, 'contrast', 5)
    			setShaderFloat(object, 'brightness', -42)

				setShaderFloat(object, 'dist', 3)
    			setShaderFloat(object, 'thr', 0.3)
			end
		end
	end
end