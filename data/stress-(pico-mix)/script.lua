function onCreatePost()
    -- Sets up the mask and the shader values related to it. 
    if shadersEnabled == true then
        setShaderSampler2D('dad', 'altMask', 'characters/masks/tankmanCaptainBloody_mask')
        setShaderFloat('dad', 'thr2', 1)
        setShaderBool('dad', 'useMask', false)
    end
end

function onEvent(event, value1, value2, strumTime)
    if event == 'Change Character' then
        if shadersEnabled == true then
            -- Activates the mask, and resets the frame info because of the 'Change CHaracter' event.
            runHaxeCode([[
                import flixel.math.FlxAngle;
                game.dad.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
                {
                    game.dad.shader.setFloatArray('uFrameBounds', [game.dad.frame.uv.x, game.dad.frame.uv.y, game.dad.frame.uv.width, game.dad.frame.uv.height]);
                    game.dad.shader.setFloat('angOffset', game.dad.frame.angle * FlxAngle.TO_RAD);
                }
            ]])
            setShaderBool('dad', 'useMask', true)
        end

        -- This is to avoid the icon changing too soon.
        callMethod('iconP2.changeIcon', {'tankman'})
        callMethod('set_health', {getProperty('health')})
    end

    -- Actually changes the icon.
    if event == 'Change Icon' then
        callMethod('iconP2.changeIcon', {'tankman-bloody'})
        callMethod('set_health', {getProperty('health')})
    end
end