function onCreatePost()
    setShaderSampler2D('dad', 'altMask', 'characters/masks/tankmanCaptainBloody_mask')
	setShaderFloat('dad', 'thr2', 1)
	setShaderBool('dad', 'useMask', false)
end

function onEvent(event, value1, value2, strumTime)
    if event == 'Change Character' then
        setShaderBool('dad', 'useMask', true)
        callMethod('iconP2.changeIcon', {'tankman'})
        callMethod('set_health', {getProperty('health')})
    end

    if event == 'Change Icon' then
        callMethod('iconP2.changeIcon', {'tankman-bloody'})
        callMethod('set_health', {getProperty('health')})
    end
end