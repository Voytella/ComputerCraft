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
function sortedKeys(tab)
    local orderedKeys = {}

    for key in pairs(tab) do
        table.insert(orderedKeys, key)
    end
    
    return table.sort(orderedKeys)  
end

---END FUNCTIONS---

-- load the JSON parser
JSON = (loadfile JSONPath)()

-- load the storage configuration
local storageConf = JSON:decode(io.open(storagePath, "rb"):read "*a")

--[[
    TODO
    1. find and hookup chest
    2. listen for item deposit
    3. get name of deposited item
    4. lookup item name in storageConf
    5. use path of item to sort item appropriately (node > side)
    6. iterate over each slot in inventory until empty reached, return Step 2
    7. set up listeners on node computers
]]--
