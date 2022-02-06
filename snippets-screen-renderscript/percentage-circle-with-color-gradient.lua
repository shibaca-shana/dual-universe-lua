
cx, cy = getCursor()
click = getCursorPressed()

--------
--
--  This method will render a circle filled to the percentage corresponding to (value/total*100) 
--    with a title and subtitle above th circle and the percentage value in the middle of the circle.
--  If the circle is clicked, the function sets the output of the script (with whatever...).
--
--  How does this work ?
--    1. Draw a circle and split it into 100 parts ( to represent 0% to 100% ).
--    2. For each percentage point, a triangle is drawn and filled with a gradient that
--    goes from green (0%) to red (100%).
--    3. A new layer is added on top and in that layer, a smaller inner circle is drawn and a text with
--    the percentage is also added to the middle of the main, bigger circle.
--
--------
function renderPercentageCicle(circleCenterX, circleCenterY, radius, title, subtitle = '', value, total)
    local font = loadFont("Play", 20)
    local fontSmall = loadFont("Play", 13)
    local fontExtraSmall = loadFont("Play", 10)
    local pieChartLayer = createLayer()
    local percentageLayer = createLayer()
        
    -- calculate filled volume percentage
    local percentageVal = value / total * 100

    -- get the circle position to determine when it is clicked
    local leftX, rightX, upY, lowY = radius*math.cos(math.pi)+circleCenterX, radius*math.cos(2*math.pi)+circleCenterX, radius*math.sin(3*math.pi/2)+circleCenterY, radius*math.sin(math.pi/2)+circleCenterY
    if click and cx >= leftX and cx <= rightX and cy >= upY and cy <= lowY then
        setOutput('You clicked inside the circle!')
    end

    -- build base circle
    setNextStrokeColor(pieChartLayer, 0.5, 0.5, 0.5, 1)
    setNextFillColor(pieChartLayer, 0, 0, 0, 1)
    setNextStrokeWidth(pieChartLayer, -5)
    addCircle(pieChartLayer, circleCenterX, circleCenterY, radius)

    local startAngle = 3*math.pi/2
    local stepAngleSize = 3.6*math.pi/180

    setNextTextAlign(percentageLayer, AlignH_Center, AlignV_Top)
    addText(percentageLayer, font, title, (radius+35)*math.cos(startAngle)+circleCenterX, (radius+35)*math.sin(startAngle)+circleCenterY)
    setNextTextAlign(percentageLayer, AlignH_Center, AlignV_Top)
    addText(percentageLayer, fontSmall, subtitle, (radius+15)*math.cos(startAngle)+circleCenterX, (radius+15)*math.sin(startAngle)+circleCenterY)

    -- fill the circle with the correct percentage amount
    for counter = 0, percentageVal-1 do
        local stepA, stepB = counter*stepAngleSize, (counter+1)*stepAngleSize
        local aX, aY = radius*math.cos(startAngle+stepA), radius*math.sin(startAngle+stepA)
        local bX, bY = radius*math.cos(startAngle+stepB), radius*math.sin(startAngle+stepB)
        setNextFillColor(pieChartLayer, 0.01*counter, 1-(counter/110), 0.1, 1)
        addTriangle(pieChartLayer, circleCenterX, circleCenterY, aX+circleCenterX, aY+circleCenterY, bX+circleCenterX, bY+circleCenterY)
    end

    -- build inner circle with the percentage value
    setNextFillColor(percentageLayer, 0, 0, 0, 1)
    setNextStrokeWidth(percentageLayer, 0)
    addCircle(percentageLayer, circleCenterX, circleCenterY, 35)
    setNextTextAlign(percentageLayer, AlignH_Center, AlignV_Middle)
    addText(percentageLayer, font, string.format('%.1f', percentageVal)..'%', circleCenterX, circleCenterY)
end
