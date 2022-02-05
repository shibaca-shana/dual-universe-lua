

local json = require("dkjson")

--

function readInput()
    local input = getInput()
    if(input) then
        return json.decode(input)
    end
end

--

function renderHeader()
    local rx, ry = getResolution()
    local font = loadFont("Play", 20)
    local headerLayer = createLayer()
    -- add screen border
    setNextFillColor(headerLayer, 0, 0, 0, 0)
    setNextStrokeColor(headerLayer, 0, 0.5, 1, 1)
    setNextStrokeWidth(headerLayer, -5)
    addBoxRounded(headerLayer, 0, 0, rx, ry, 0)
    -- add header
    setNextFillColor(headerLayer, 0, 0.5, 1, 1)
    addQuad(headerLayer, rx/4, 0, rx/3, ry/14, 2*rx/3, ry/14, 3*rx/4, 0)
    setNextTextAlign(headerLayer, AlignH_Center, AlignV_Top)
    addText(headerLayer, font, "Container Management System", rx/2, ry/30)
end


--------
--
--  This method will render, for each container, a circle filled to the percentage of occupied volume  
--    with the name above th circle and the percentage value in the middle of the circle.
--
--  How does this work ?
--    First, a circle is drawn. Then, that circle is split into 100 parts ( to represent 0% to 100% ).
--    Then, for each part / percentage point of occupied volume, a triangle is drawn and filled with a gradient that
--    goes from green (empty container) to red (fully filled container).
--    After this, a new layer is added on top and in that layer, a smaller inner circle is drawn and a text with
--    the percentage of occupied volume is also added to the middle of the main, bigger circle.
--
--------
function renderContainersOverview(containers)
    local rx, ry = getResolution()
    local font = loadFont("Play", 20)
    local fontSmall = loadFont("Play", 13)
    local fontExtraSmall = loadFont("Play", 10)
    local pieChartLayer = createLayer()
    local percentageLayer = createLayer()
        
    local rowElementCounter = 1
    local rowNum = 0
    for containerId, container in pairs(containers) do
        
        -- calculate filled volume percentage
        local volPercentageVal = container['itemsVolume'] / container['maxVolume'] * 100
        
        local radius = 100
        local circleCenterX = (rowElementCounter*2-1)*rx/8
        local circleCenterY = (rowNum*1.4+1)*ry/3
                
        -- get the container chart position to determine when it is clicked
        local leftX, rightX, upY, lowY = radius*math.cos(math.pi)+circleCenterX, radius*math.cos(2*math.pi)+circleCenterX, radius*math.sin(3*math.pi/2)+circleCenterY, radius*math.sin(math.pi/2)+circleCenterY
        if click and cx >= leftX and cx <= rightX and cy >= upY and cy <= lowY then
            local output = {}
            output['command'] = 'SHOW_ITEMS_LIST'            
            output['id'] = containerId
            setOutput(json.encode(output))
        end
        
        -- build base circle
        setNextStrokeColor(pieChartLayer, 0.5, 0.5, 0.5, 1)
        setNextFillColor(pieChartLayer, 0, 0, 0, 1)
        setNextStrokeWidth(pieChartLayer, -5)
        addCircle(pieChartLayer, circleCenterX, circleCenterY, radius)
        
        local startAngle = 3*math.pi/2
        local stepAngleSize = 3.6*math.pi/180
        
        setNextTextAlign(percentageLayer, AlignH_Center, AlignV_Top)
        addText(percentageLayer, font, container['name'], (radius+35)*math.cos(startAngle)+circleCenterX, (radius+35)*math.sin(startAngle)+circleCenterY)
        setNextTextAlign(percentageLayer, AlignH_Center, AlignV_Top)
        addText(percentageLayer, fontSmall, '(Current mass: '..string.format('%.1f', (container['totalMass']/1000))..' t)', (radius+15)*math.cos(startAngle)+circleCenterX, (radius+15)*math.sin(startAngle)+circleCenterY)
        --addText(percentageLayer, fontSmall, '(Max Volume: '..(container['maxVolume']/1000)..' kL)', (radius+15)*math.cos(startAngle)+circleCenterX, (radius+15)*math.sin(startAngle)+circleCenterY)
        
        -- fill the circle with the correct amount of filled volume
        for counter = 0, volPercentageVal-1 do
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
        addText(percentageLayer, font, string.format('%.1f', volPercentageVal)..'%', circleCenterX, circleCenterY)
        setNextTextAlign(percentageLayer, AlignH_Center, AlignV_Top)
        addText(percentageLayer, fontExtraSmall, '( '..string.format('%.1f', (container['itemsVolume']/1000))..' kL )', circleCenterX, circleCenterY+14)
        if(rowElementCounter < 4) then
            rowElementCounter = rowElementCounter+1
        else
            rowNum = rowNum+1
            rowElementCounter = 1
        end
    end
end

--

function renderContainerItemsList(itemsList)
        
    local rx, ry = getResolution()
    local font = loadFont("Play", 20)
    local tableTitleFont = loadFont("Play", 22)
    local backButtonLayer = createLayer()
    local backTextLayer = createLayer()
    local tableLayer = createLayer()
    
    -- add back button to the containers overview
    local quadVerticeAx, quadVerticeAy = rx/18, ry/12
    local quadVerticeBx, quadVerticeBy = rx/18, ry/7
    local quadVerticeCx, quadVerticeCy = 2.1*rx/10, ry/7
    local quadVerticeDx, quadVerticeDy = 2.1*rx/10, ry/12
    local triaguleOuterVertice = rx/28
    setNextFillColor(backButtonLayer, 0.8, 0, 0, 1)
    addQuad(backButtonLayer, quadVerticeAx, quadVerticeAy, quadVerticeBx, quadVerticeBy, quadVerticeCx, quadVerticeCy, quadVerticeDx, quadVerticeDy)
    setNextFillColor(backButtonLayer, 0.8, 0, 0, 1)
    addTriangle(backButtonLayer, quadVerticeAx, quadVerticeAy, quadVerticeBx, quadVerticeBy, triaguleOuterVertice, (quadVerticeBy+quadVerticeDy)/2)
    setNextTextAlign(backTextLayer, AlignH_Center, AlignV_Middle)
    addText(backTextLayer, font, 'Back to overview', (quadVerticeAx+quadVerticeCx)/2, (quadVerticeAy+quadVerticeCy)/2)
    
    if click and cx >= triaguleOuterVertice and cx <= quadVerticeCx and cy >= quadVerticeAy and cy <= quadVerticeBy then
        local output = {}
        output['command'] = 'SHOW_OVERVIEW'
        setOutput(json.encode(output)) 
    end
    
    -- add title with container name
    setNextTextAlign(tableLayer, AlignH_Center, AlignV_Middle)
    addText(tableLayer, loadFont("Play", 28), itemsList['name']..' (Top 10 items per volume)', rx/2, ry/6)
    
    
    -- add table with items
    local firstTableLineAx, firstTableLineAy = rx/18, ry/4.5
    local firstTableLineBx, firstTableLineBy = rx/18, ry/3.5
    local firstTableLineCx, firstTableLineCy = rx/4, ry/3.5
    local firstTableLineDx, firstTableLineDy = rx/4, ry/4.5
    local lineHeight = firstTableLineCy-firstTableLineAy
    local lineWidth = firstTableLineCx-firstTableLineAx
    local countItems = 1

    setNextFillColor(tableLayer, 0.6, 0.6, 0.6, 0.7)
    addQuad(tableLayer, firstTableLineAx, firstTableLineAy, firstTableLineBx, firstTableLineBy, 3*lineWidth+firstTableLineCx, firstTableLineCy, 3*lineWidth+firstTableLineDx, firstTableLineDy)
    setNextTextAlign(tableLayer, AlignH_Center, AlignV_Middle)
    setNextFillColor(tableLayer, 0, 0, 0, 1)
    addText(tableLayer, tableTitleFont, 'Item', (firstTableLineAx+firstTableLineCx)/2, (firstTableLineAy+firstTableLineCy)/2)
    setNextTextAlign(tableLayer, AlignH_Center, AlignV_Middle)
    setNextFillColor(tableLayer, 0, 0, 0, 1)
    addText(tableLayer, tableTitleFont, 'Volume (L)', 1.7*lineWidth+(firstTableLineAx+firstTableLineCx)/2, (firstTableLineAy+firstTableLineCy)/2)
    setNextTextAlign(tableLayer, AlignH_Center, AlignV_Middle)
    setNextFillColor(tableLayer, 0, 0, 0, 1)
    addText(tableLayer, tableTitleFont, 'Percentage of Max. Volume', 2.8*lineWidth+(firstTableLineAx+firstTableLineCx)/2, (firstTableLineAy+firstTableLineCy)/2)
    
    -- uncomment line below for testing screen without retrieving data from programming board
    --itemsList = getMockItemsList()
    if itemsList == nil or itemsList['items'] == nil then
        return
    end
    
    for _, item in ipairs(itemsList['items']) do
        if countItems % 2 == 0 then
            setNextFillColor(tableLayer, 0.6, 0.6, 0.6, 0.7)
        else
            setNextFillColor(tableLayer, 0, 0, 0, 1)
        end
        addQuad(tableLayer, firstTableLineAx, countItems*lineHeight+firstTableLineAy, firstTableLineBx, countItems*lineHeight+firstTableLineBy, 3*lineWidth+firstTableLineCx, countItems*lineHeight+firstTableLineCy, 3*lineWidth+firstTableLineDx, countItems*lineHeight+firstTableLineDy)
        setNextTextAlign(tableLayer, AlignH_Left, AlignV_Middle)
        addText(tableLayer, font, item['name'], (firstTableLineAx+firstTableLineCx-50)/2, countItems*lineHeight+(firstTableLineAy+firstTableLineCy)/2)
        setNextTextAlign(tableLayer, AlignH_Center, AlignV_Middle)
        addText(tableLayer, font, string.format('%.1f', item['volume']), 1.7*lineWidth+(firstTableLineAx+firstTableLineCx)/2, countItems*lineHeight+(firstTableLineAy+firstTableLineCy)/2)
        setNextTextAlign(tableLayer, AlignH_Center, AlignV_Middle)
        addText(tableLayer, font, string.format('%.1f', (item['volume']/itemsList['maxVolume'])*100)..'%', 2.8*lineWidth+(firstTableLineAx+firstTableLineCx)/2, countItems*lineHeight+(firstTableLineAy+firstTableLineCy)/2)
        countItems = countItems+1
    end
end

--
-- For testing items list table. Avoid triggering acquireContainer multiple times during testing
--
function getMockItemsList()
    local mock = {}
    mock['maxVolume'] = 1000000.00
    mock['items'] = {}
    for i=1,10 do
        local mockItem = {}
        mockItem['name'] = 'item '..i
        mockItem['volume'] = 2000*i
        mockItem['mass'] = 100*i
        table.insert(mock['items'], mockItem)
    end
    return mock
end

--------------------------------------------

local input = readInput()

cx, cy = getCursor()
click = getCursorPressed()

renderHeader()

if(input['SHOW_OVERVIEW']) then
    renderContainersOverview(input['SHOW_OVERVIEW'])
elseif(input['SHOW_ITEMS_LIST']) then
    renderContainerItemsList(input['SHOW_ITEMS_LIST'])
end


requestAnimationFrame(5)

