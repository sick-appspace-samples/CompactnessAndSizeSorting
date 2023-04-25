
--Start of Global Scope---------------------------------------------------------

print('AppEngine Version: ' .. Engine.getVersion())

-- Delay in ms between visualization steps for demonstration purpose
local DELAY = 1000

-- Creating viewer
local viewer = View.create()

-- Setting up graphical overlay attributes
local dotDecoration = View.ShapeDecoration.create()
dotDecoration:setPointType('DOT')
dotDecoration:setPointSize(20)
dotDecoration:setLineColor(0, 255, 0) -- Green

local regionDecoration = View.PixelRegionDecoration.create()
regionDecoration:setColor(0, 255, 0, 100) -- Transparent green

local textDecoration = View.TextDecoration.create()
textDecoration:setSize(40)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

local function main()
  viewer:clear()
  local img = Image.load('resources/CompactnessAndSizeSorting.bmp')
  viewer:addImage(img)
  viewer:present()
  Script.sleep(DELAY) -- for demonstration purpose only

  -- Reducing noise using a median filter
  img = img:median(5)

  -- Finding blobs
  local objectRegion = img:threshold(0, 100)
  local objectRegion2 = objectRegion:dilate(5) -- Closing gap in open washer
  viewer:addPixelRegion(objectRegion2, regionDecoration)
  viewer:present()
  Script.sleep(DELAY) -- for demonstration purpose only
  local objectRegionNoHoles = objectRegion2:fillHoles()
  local blobs = objectRegionNoHoles:findConnected(50)

  -- Filtering for round blobs and sorting in ascending order by size
  local objectFilter = Image.PixelRegion.Filter.create()
  objectFilter:setRange('COMPACTNESS', 0.88, 1)
  objectFilter:setRange('AREA', 1000, 200000)
  objectFilter:sortBy('AREA', true)
  local selectedBlobs = objectFilter:apply(blobs, img)

  -- Plotting marker in each hole and printing the blob sort order number
  viewer:clear()
  viewer:addImage(img)
  local centers = selectedBlobs:getCenterOfGravity(img)
  for i = 1, #centers do
    viewer:addShape(centers[i], dotDecoration)
    textDecoration:setPosition(centers[i]:getX() + 20, centers[i]:getY())
    viewer:addText(tostring(math.floor(i)), textDecoration)

    viewer:present() -- presenting single steps
    Script.sleep(DELAY) -- for demonstration purpose only
  end
  print(#selectedBlobs .. ' blobs selected')
  print('App finished.')
end

--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
