local progressUpdate = 5
local refreshTick = 5

local radius = 130

local sW, sH = guiGetScreenSize()

local imgSize = {
    w = sH,
    h = sH,
}

local texture = dxCreateTexture(imgSize.w, imgSize.h)
local pixels = dxGetTexturePixels(texture)

local boundX, boundY = 3000, 3000
local x, y = -boundX - progressUpdate, boundY

Update = function()
    local t = 0
    while true do
        if (y <= -boundY) then
            y = boundY
            x = x + (radius)
        end

        y = y - progressUpdate

        for x2 = 0, radius do
            local z = getGroundPosition(x + x2, y, 500) or 0
            setCameraMatrix(x + x2, y, z + 400, x, y, z)

            local color = {255, 255, 255}

            if testLineAgainstWater(x + x2, y, z + 100, x + x2, y, z - 1) then
                color = {115, 140, 220}
            else
                local ray, _, _, _, _, _, _, _, material = processLineOfSight(x + x2, y, z + 1, x + x2, y, z - 1, true, false, false, true, false,
                                                                              false, false, false, localPlayer, false, false)
                if ray and material then
                    if materialColors[material] then
                        color = materialColors[material]
                    else
                        outputChatBox(inspect({'not material', material}))
                    end
                end
            end

            local pX = reMap(x + x2, -boundY, boundX, 0, imgSize.w)
            local pY = reMap(y, boundX, -boundY, 0, imgSize.h)

            dxSetPixelColor(pixels, pX, pY, color[1], color[2], color[3])
        end

        if (x > boundX) then
            local pngPixels = dxConvertPixels(pixels, 'png')
            local newImg = fileCreate('map.png')
            fileWrite(newImg, pngPixels)
            fileClose(newImg)

            if isTimer(timer_C) then
                killTimer(timer_C)
            end
            coroutine.yield()
        end

        t = t + 1
        if t >= refreshTick then
            coroutine.yield()
            t = 0
        end
    end
end

updateC = coroutine.create(Update)
timer_C = setTimer(function()
    if coroutine.status(updateC) ~= 'dead' then
        coroutine.resume(updateC)
    end
    dxSetTexturePixels(texture, pixels)
end, refreshTick, 0)

addEventHandler('onClientRender', root, function()
    if texture then
        dxDrawImage(sW / 2 - imgSize.w / 2, sH / 2 - imgSize.h / 2, imgSize.w, imgSize.h, texture, 0, 0, 0, tocolor(200, 200, 200, 255))
    end
end)

reMap = function(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
end

function resourceStop()
    setCameraTarget(localPlayer)
end

addEventHandler("onClientResourceStop", resourceRoot, resourceStop)
