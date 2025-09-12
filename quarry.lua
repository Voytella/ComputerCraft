------TURTLE QUARRY------
--pastbin link: https://pastebin.com/rU8CyBVc
--[[
   1) Place chest at bottom-left corner of desired quarry location
   2) Place turtle adjacent to, and facing away from, chest
   3) Place fuel in bottom-right slot
   4) Start program
]]--

-----BEGIN FUNCTIONS-----

---Begin Checking Args---

-- check arguments
function chkArgs(x,y,z)
   if x == nil or y == nil or z == nil then
      usage()
      return 1
   end
end

-- print usage
function usage()
   print("quarry.lua <length> <width> <depth>")
end

----End Checking Args----

-- ensuring enough fuel
function chkFuel (x,y,z)

   local vol = x*y*z

   local estReqFuel =
      vol + --volume of quarry
      (x+y+z) + --cost of surfacing
      (math.ceil(vol/1000) * (2*(x+y+z))) --cost of anticipated inventory dumps

   -- checks if limit is within fuel range
   local fuelLim = 20000
   if estReqFuel > fuelLim then
      print("Specified quarry is too big!")
      return 1
   end

   -- refueling turtle with available fuel
   if turtle.getFuelLevel() < estReqFuel then
      turtle.select(16)
      if not turtle.refuel() then
         print("Please place fuel in bottom-right slot.")
         return 1
      end
   end

   -- alert if not enough fuel is provided
   if turtle.getFuelLevel() < estReqFuel then
      print("Not enough fuel! Please place more in the bottom-right slot.")
      return 1
   end
end

-- determines the direction in which the turtle is facing
function dirFace (y,z)
   if (y%2==1 and z%2==1) then
      return 1
   end
   if (y%2==0 and z%2==1) then
      return 3
   end
   if z%2 == 0 then
      return 4
   end
end

---Begin Inventory Management---

-- empty haul to chest
function dump()
   for ii = 1, 16, 1 do
      turtle.select(ii)
      turtle.drop()
   end
end

-- go to chest
function toChest (x, y, z, xAmt, yAmt, face)

   -- turn the turtle toward the chest
   if face == 1 then
      turtle.turnLeft()
   else
      turtle.turnRight()
   end

   ---move turtle to chest---

   --z
   for ii = 1, z-1, 1 do
      turtle.up()
   end

   --y
   if (face%2 == 1) then
      for ii = 1, y-1, 1 do
         turtle.forward()
      end
   else
      for ii = 1, yAmt-y, 1 do
         turtle.forward()
      end
   end
   turtle.turnLeft()

   --x
   if face < 3 then
      for ii = 1, x-1, 1 do
         turtle.forward()
      end
   else
      for ii = 1, xAmt-x, 1 do
         turtle.forward()
      end
   end

end

-- resume mining after dumping
function resume (x, y, z, xAmt, yAmt, face)
   turtle.turnLeft()
   turtle.turnLeft()

   --x
   if face == 1 then
      for ii = 1, x-1, 1 do
         turtle.forward()
      end
   else
      for ii = 1, xAmt-x, 1 do
         turtle.forward()
      end
   end
   turtle.turnRight()

   --y
   if (face%2 == 1) then
      for ii = 1, y-1, 1 do
         turtle.forward()
      end
   else
      for ii = 1, yAmt-y, 1 do
         turtle.forward()
      end
   end

   --z
   for ii = 1, z-1, 1 do
      turtle.down()
   end

   -- face turtle appropiately
   if face == 1 then
      turtle.turnLeft()
   else
      turtle.turnRight()
   end

end

-- manages inventory space
--[[ inTurn:
     0) not in turn
     1) in right turn
     2) in left turn
]]--
function chkInventory (x, y, z, xAmt, yAmt, inTurn)
   local invFull = true
   for ii = 1, 16, 1 do
      if turtle.getItemCount(ii) == 0 then
         invFull = false
         break
      end
   end
   if invFull then

      if inTurn == 1 then
        turtle.turnLeft()
      end
      if inTurn == 2 then
        turtle.turnRight()
      end

      face = dirFace(y,z)
      toChest(x, y, z, xAmt, yAmt, face)
      dump()
      resume(x, y, z, xAmt, yAmt, face)

      if inTurn == 1 then
        turtle.turnRight()
      end
      if inTurn == 2 then
        turtle.turnLeft()
      end

   end
end

----End Inventory Management----

-- if block, digs it out
function ifDig(x, y, z, xAmt, yAmt, inTurn)
   if turtle.detect() then
      chkInventory(x, y, z, xAmt, yAmt, inTurn)
      turtle.dig()
   end
end

-- if block below, digs it out
function ifDigDown(x, y, z, xAmt, yAmt)
   if turtle.detectDown() then
      chkInventory(x, y, z, xAmt, yAmt)
      turtle.digDown()
   end
end

-- arranges turtle to cut out strips of rectangle
function nextStrip (x, y, z, xAmt, yAmt)
   if ((yAmt%2==1 or z%2==1) and y%2==1)
      or ((yAmt%2 == z%2) and (z%2 == y%2)) then
      turtle.turnRight()
      ifDig(x, y, z, xAmt, yAmt, 1)
      turtle.forward()
      turtle.turnRight()
   else
      turtle.turnLeft()
      ifDig(x, y, z, xAmt, yAmt, 2)
      turtle.forward()
      turtle.turnLeft()
   end
end


------END FUNCTIONS-----

-- preliminary checks
local xAmt, yAmt, zAmt = ...

if chkArgs(xAmt, yAmt, zAmt) == 1 then
    return
end

local xAmt = tonumber(xAmt)
local yAmt = tonumber(yAmt)
local zAmt = tonumber(zAmt)

if chkFuel(xAmt, yAmt, zAmt) == 1 then
    return
end

-- main mining loop
for ii = 1, zAmt, 1 do
   for jj = 1, yAmt, 1 do
      for kk = 1, xAmt-1, 1 do
         ifDig(kk, jj, ii, xAmt, yAmt, 0)
         if kk ~= xAmt then
            turtle.forward()
         end
      end
      if jj ~= yAmt then
         nextStrip(xAmt, jj, ii, xAmt, yAmt)
      end
   end
   if ii ~= zAmt then
      turtle.turnLeft()
      turtle.turnLeft()
      ifDigDown(xAmt, yAmt, ii, xAmt, yAmt)
      turtle.down()
   end
end
toChest(xAmt, yAmt, zAmt, xAmt, yAmt, dirFace(yAmt, zAmt))
dump()
