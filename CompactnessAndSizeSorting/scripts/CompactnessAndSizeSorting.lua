--[[----------------------------------------------------------------------------

  Application Name:
  CompactnessAndSizeSorting
                                                                                             
  Summary:
  Finding round blobs and sorting in ascending order of size.
  
  How to Run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting a breakpoint on the first row inside the 'main'
  function allows debugging step-by-step after the 'Engine.OnStarted' event.
  Results can be seen in the image viewer on the DevicePage.
  Restarting the Sample may be necessary to show images after loading the webpage.
  To run this Sample a device with SICK Algorithm API and AppEngine >= V2.5.0 is
  required. For example SIM4000 with latest firmware. Alternatively the Emulator
  in AppStudio 2.3 or higher can be used.
  
  More Information:
  Tutorial "Algorithms - Blob Analysis".

------------------------------------------------------------------------------]]
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
  local imageID = viewer:addImage(img)
  viewer:present()
  Script.sleep(DELAY) -- for demonstration purpose only

  -- Reducing noise using a median filter
  img = img:median(5)

  -- Finding blobs
  local objectRegion = img:threshold(0, 100)
  local objectRegion2 = objectRegion:dilate(5) -- Closing gap in open washer
  viewer:addPixelRegion(objectRegion2, regionDecoration, nil, imageID)
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
  imageID = viewer:addImage(img)
  for i = 1, #selectedBlobs do
    local center = selectedBlobs[i]:getCenterOfGravity(img)
    viewer:addShape(center, dotDecoration, nil, imageID)
    textDecoration:setPosition(center:getX() + 20, center:getY())
    viewer:addText(tostring(math.floor(i)), textDecoration, nil, imageID)

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
