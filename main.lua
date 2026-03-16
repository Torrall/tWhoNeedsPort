local addon, ns = ...
print("read tWhoNeedsPort: main.lua")

addon = {}
addon.internal_name = "tWhoNeedsPort"

local DISTANCE_THRESHOLD = 400
local NO_INSTANCE_KEY = "NO_INSTANCE"

-- create inverted tables
local instance_by_inside_id = {}
local instance_by_outside_id = {}
for k, v in pairs(ns.instances) do
    for _, id in pairs(v.inside_ids) do
        instance_by_inside_id[id] = k
    end
    for _, id in pairs(v.outside_ids) do
        instance_by_outside_id[id] = instance_by_outside_id[id] or {}
        table.insert(instance_by_outside_id[id], k)
    end
end

local function evaluate_member_instance(unit)
    local posY, posX, _, instanceID = UnitPosition(unit)
    -- try if the player is inside a known instance
    if instance_by_inside_id[instanceID] ~= nil then
        local instance_key = instance_by_inside_id[instanceID]
        return ns.instances[instance_key]
    end

    -- player is not in a known instance, exit if no instances are registered to their zone
    if instance_by_outside_id[instanceID] == nil then
        return NO_INSTANCE_KEY
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
            closest_instance = instance_key
            min_distance = distance
        end
    end
    -- is the closest close enough?
    if min_distance > DISTANCE_THRESHOLD then
        return NO_INSTANCE_KEY
    end
    return closest_instance
end

local function get_group_units()
    local units = {}

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            units[#units + 1] = "raid" .. i
        end
    elseif IsInGroup() then
        units[#units + 1] = "player"
        for i = 1, GetNumGroupMembers() do
            units[#units + 1] = "party" .. i
        end
    else
        units[#units + 1] = "player"
    end

    return units
end

function get_all_member_instances()
    local members_by_instance = {}
    for _, unit_id in ipairs(get_group_units()) do
        local instance_key = evaluate_member_instance(unit_id)

        local member_name = UnitName(unit_id)
        members_by_instance[instance_key] = members_by_instance[instance_key] or {}
        table.insert(members_by_instance[instance_key], member_name)

    end
    return members_by_instance
end

function get_most_populated_instance(members_by_instance)
    local most_members = 0
    local most_popular_instance
    for k, v in pairs(members_by_instance) do
        if #v > most_members then
            most_members = #v
            most_popular_instance = k
        end
    end
    return most_popular_instance
end

function evaluate_summon_status()
    local members_by_instance = get_all_member_instances()
    local most_popular_instance_key = get_most_populated_instance(members_by_instance)

    if most_popular_instance_key == NO_INSTANCE_KEY then
        return nil, nil
    end

    local missing_members = {}
    for instance_key, members in pairs(members_by_instance) do
        if instance_key ~= most_popular_instance_key then
            for _, member in ipairs(members) do
                table.insert(missing_members, member)
            end
        end
    end

    return most_popular_instance_key, missing_members
end

function print_summon_status()
    print("check instance")
    local most_popular_instance_key, missing_members = evaluate_summon_status()
    if most_popular_instance_key == nil then
        print("no one is at a known instance")
        return
    end
    local instance = ns.instances[most_popular_instance_key]
    print("instance: " .. instance.name)
    for k, v in ipairs(missing_members) do
        print(k, v)
    end
end

-- add the ticker frame that does the checks
local tickerFrame = CreateFrame("Frame", addon.internal_name .. "TickerFrame", UIParent)

local accumulator = 0
local INTERVAL = 1.0  -- seconds

tickerFrame:SetScript("OnUpdate", function(_, elapsed)
    accumulator = accumulator + elapsed
    if accumulator >= INTERVAL then
        accumulator = accumulator - INTERVAL  -- subtract instead of reset to avoid drift
        print_summon_status()
    end
end)