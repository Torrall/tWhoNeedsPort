local addon, ns = ...
print("read tWhoNeedsPort: main.lua")

ns.instance = {}

local distance_threshold = 400

-- create inverted tables
local instance_by_inside_id = {}
local instance_by_outside_id = {}
for k, v in pairs(ns.instances) do
    for id in v.inside_ids do
        instance_by_inside_id[id] = k
    end
    for id in v.outside_ids do
        if instance_by_outside_id[id] == nil then
            instance_by_outside_id[id] = {}
        end
        instance_by_outside_id[id].insert(k)

    end
end

local function evaluate_player_instance(unit)
    local posY, posX, _, instanceID = UnitPosition(unit)
    -- try if the player is inside a known instance
    if instance_by_inside_id[instanceID] ~= nil then
        local instance_key = instance_by_inside_id[instanceID]
        return ns.instances[instance_key]
    end

    -- player is not in a known instance, exit if no instances are registered to their zone
    if instance_by_outside_id[instanceID] == nil then
        return nil
    end

    -- at least one instance is in the players zone; find the closest one
    local min_distance = 1000000000000
    local closest_instance
    for _, instance_key in pairs(instance_by_outside_id[instanceID]) do
        local instance = ns.instances[instance_key]
        local distance_x = instance.outside_coordinates.x - posX
        local distance_y = instance.outside_coordinates.y - posY
        local distance = math.sqrt(distance_x ^ 2 + distance_y ^ 2)

        if distance < min_distance then
            closest_instance = instance
            min_distance = distance
        end
    end
    -- is the closest close enough?
    if min_distance > distance_threshold then
        return nil
    end
    return closest_instance
end