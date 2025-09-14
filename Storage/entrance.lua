---ENTRANCE---
-- This is the machine connected to the chest that is the entry point of the
-- storage system.

---BEGIN CONFIGURATION---

-- path to the JSON parser
local JSONPath = "../json.lua"

-- path to the storage configuration file
local storagePath = "storage.json"

-- name of protocol used by machines (default: "storage")
local protocol = "storage"

---END CONFIGURATION---

---BEGIN FUNCTIONS---

-- print usage
function usage()
    print("USAGE: entrance <modem_side>")
end

-- initialize "entrance" on rednet
function initRednet(modemSide)
    rednet.open(modemSide)
    rednet.host("storage", "entrance")
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

---END FUNCTIONS---

-- load the JSON parser
JSON = (loadfile(JSONPath))()

-- load the storage configuration
storageConf = JSON:decode(io.open(storagePath, "rb"):read "*a")

--[[
    TODO
    1. [ ] find and hookup chest
    2. [ ] listen for item deposit
    3. [ ] get name of deposited item
    4. [x] lookup item path in storageConf
    5. [ ] use path of item to sort item appropriately (node > side)
    6. [ ] iterate over each slot in inventory until empty reached, return Step 2
    7. [ ] set up listeners on node computers
]]--
