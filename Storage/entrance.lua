---ENTRANCE---
-- This is the machine connected to the chest that is the entry point of the
-- storage system.

---BEGIN CONFIGURATION---

-- path to the JSON parser
local JSONPath = "../json.lua"

-- path to the storage configuration file
local storagePath = "storage.json"

-- path to the layout configuration file
local layoutPath = "layout.json"

-- side on computer on which modem is placed
local modemSide = "back"

-- name of protocol used by machines (default: "storage")
--local protocol = "storage"

---END CONFIGURATION---

---BEGIN FUNCTIONS---

-- print usage
function usage()
    print("USAGE: entrance <modem_side>")
end

-- initialize "entrance" on rednet
function initRednet(modemSide)

    -- turn on the computer's attached modem
    rednet.open(modemSide)
    
end 

-- get a sorted list of the keys of a table
-- https://stackoverflow.com/questions/17436947/how-to-iterate-through-table-in-lua
function getSortedKeys(tab)
    local orderedKeys = {}

    for key in pairs(tab) do
        table.insert(orderedKeys, key)
    end
    
    return table.sort(orderedKeys)  
end

-- check to see if an element is in a table
function isInTable(tab, ele)
    for _, val in pairs(tab) do
        if val == ele then
            return true
        end
    end
    return false
end

-- write an array as a string
function arrayToString(arr)
    string = "{"
    for _, val in pairs(arr) do
        string = string..val.."," 
    end
    return string.."}"
end

-- get the path of an element stored in a hierarchical table
-- returns an array where the elements are, in order, the path to the provided
-- element
function getPath(tab, ele, path)
    
    -- the default value of the "path" is an empty array
    path = path or {}

    --print("DEBUG: path: "..arrayToString(path))

    --[[ (basecase) 
        if the table is not comprised of other tables and 
        if the element is in the table, return the path
        otherwise, return an empty array
    ]]--
    if isInTable(tab, ele) then
        --print("DEBUG: success!")
        return path
    else
        for key, val in pairs(tab) do
            
            -- if the table is not comprised of other tables, then the desired
            -- value was not found and we can move on to the next one     
            if type(val) ~= "table" then 
                return {} 
            end

            --[[ (recursive case)
               1. append the current key to the current path while calling getPath on
                  the current value
               2. if the result is a non-empty array, break the loop
            ]]--
            path[#path+1] = key
            pathResult = getPath(val, ele, path)
            if pathResult ~= nil then
                break
            end
        end
       
         -- return the value from the latest iteration of getPath
         --print("DEBUG: returned pathResult: "..arrayToString(pathResult))
         return pathResult
       
    end
end

-- move everything from the entrance chest to its appropriate chest
function clearEntrance(storageConf, layoutConf)
    
    -- wrap the entrance chest
    entranceChest = peripheral.wrap(layoutConf["Entrance"])

    -- grab the contents of the entrance chest
    entranceContents = entranceChest.list()

    -- run through the entrance chest contents
    for slot, item in pairs(entranceContents) do
         
        -- get the destination of the item
        itemDest = getPath(storageConf, item["name"])

        -- if the item has no assigned destination, throw it in Other
        if itemDest == nil then
            itemDest = "Other"
        end

        -- convert the array to a String
        if type(itemDest) ~= "string" then
            itemDest = itemDest[1]
        end

        -- push the item where it needs to go
        entranceChest.pushItems(layoutConf[itemDest], slot)

    end
end

---END FUNCTIONS---

-- load the JSON parser
JSON = (loadfile(JSONPath))()

-- load the storage configuration
storageConf = JSON:decode(io.open(storagePath, "rb"):read "*a")

-- load the chest layout
layoutConf = JSON:decode(io.open(layoutPath, "rb"):read "*a")

-- initialize rednet connections
initRednet(modemSide)

-- main program loop
while true do

    -- clear the entrance chest if something is in it
    if peripheral.wrap(layoutConf["Entrance"]).list() ~= nil then
        clearEntrance(storageConf, layoutConf)
    end

    -- wait 5 seconds before checking entrance chest again
    sleep(5)
end

