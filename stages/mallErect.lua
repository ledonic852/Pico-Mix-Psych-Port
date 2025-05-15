function onCreate()
	makeLuaSprite('mallWall', 'christmas/erect/bgWalls', -1000, -440)
	scaleObject('mallWall', 0.9, 0.9)
	setScrollFactor('mallWall', 0.2, 0.2)
	addLuaSprite('mallWall')

	if lowQuality == false then
		makeAnimatedLuaSprite('topBoppers', 'christmas/erect/upperBop', -240, -40)
		addAnimationByPrefix('topBoppers', 'idle', 'upperBop', 24, false)
		scaleObject('topBoppers', 0.85, 0.85)
		setScrollFactor('topBoppers', 0.33, 0.33)
		addLuaSprite('topBoppers')

		makeLuaSprite('escalators', 'christmas/erect/bgEscalator', -1100, -540)
		scaleObject('escalators', 0.9, 0.9)
		setScrollFactor('escalators', 0.3, 0.3)
		addLuaSprite('escalators')
	end

	makeLuaSprite('christmasTree', 'christmas/erect/christmasTree', 370, -250)
	setScrollFactor('christmasTree', 0.4, 0.4)
	addLuaSprite('christmasTree')

	if lowQuality == false then
		makeLuaSprite('fog', 'christmas/erect/white', -1000, 100)
		scaleObject('fog', 0.9, 0.9)
		setScrollFactor('fog', 0.85, 0.85)
		addLuaSprite('fog')
	end

	makeAnimatedLuaSprite('bottomBoppers', 'christmas/erect/bottomBop', -410, 100)
	addAnimationByPrefix('bottomBoppers', 'idle', 'bop0', 24, false)
	addAnimationByPrefix('bottomBoppers', 'hey', 'hey0', 24, false)
	setScrollFactor('bottomBoppers', 0.9, 0.9)
	addLuaSprite('bottomBoppers')

	makeLuaSprite('snowGround', 'christmas/fgSnow', -600, 680)
	addLuaSprite('snowGround')

	makeAnimatedLuaSprite('santa', 'christmas/santa', -840, 150)
	addAnimationByPrefix('santa', 'idle', 'santa idle in fear', 24, false)
	addLuaSprite('santa')
end

function onCreatePost()
	if shadersEnabled == true then
        initLuaShader('adjustColor')
        for i, object in ipairs({'boyfriend', 'dad', 'gf', 'santa'}) do
            setSpriteShader(object, 'adjustColor')
            setShaderFloat(object, 'hue', 5)
            setShaderFloat(object, 'saturation', 20)
            setShaderFloat(object, 'contrast', 0)
            setShaderFloat(object, 'brightness', 0)
        end
	end
end

--[[
	Everything below is to make the characters bop their head on beat.
	It also checks if the 'Hey' event is played to make the ones at the bottom cheer aswell.
	Shoutout for MrCatz for making the animation! Check his socials in the Credits Menu.
]]
local heyTimer = 0
function onUpdate(elapsed)
	if heyTimer > 0 then
		heyTimer = heyTimer - elapsed
		if heyTimer <= 0 then
			playAnim('bottomBoppers', 'idle', true);
			heyTimer = 0
		end
	end
end

function onCountdownTick(swagCounter)
	if lowQuality == false then
		playAnim('topBoppers', 'idle', true)
	end
	playAnim('bottomBoppers', 'idle', true)
	playAnim('santa', 'idle', true)
end

function onBeatHit()
	if lowQuality == false then
		playAnim('topBoppers', 'idle', true)
	end
	if heyTimer <= 0 then
		playAnim('bottomBoppers', 'idle', true)
	end
	playAnim('santa', 'idle', true)
end

function onEvent(eventName, value1, value2)
	if eventName == 'Hey!' then
		if value1 ~= '0' or string.lower(value1) ~= 'bf' or string.lower(value1) ~= 'boyfriend' then
			playAnim('bottomBoppers', 'hey', true)
			if value2 == '' then
				heyTimer = 0.6
			else
				heyTimer = tonumber(value2)
			end
		end
	end
end