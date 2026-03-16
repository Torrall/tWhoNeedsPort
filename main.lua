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
        return instance_key
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
        for i = 1, (GetNumGroupMembers() -1) do
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

        members_by_instance[instance_key] = members_by_instance[instance_key] or {}
        table.insert(members_by_instance[instance_key], unit_id)

    end
    return members_by_instance
end

function get_most_populated_instance(members_by_instance)
    local most_members = 0
    local most_popular_instance
    for k, v in pairs(members_by_instance) do
        if #v > most_members and k ~= NO_INSTANCE_KEY then
            most_members = #v
            most_popular_instance = k
        end
    end
    if most_members == 0 then
        return nil
    end
    return most_popular_instance
end

function evaluate_location_status()
    local members_by_instance = get_all_member_instances()
    local most_popular_instance_key = get_most_populated_instance(members_by_instance)

    if not most_popular_instance_key then --no one is at any instance
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

local function get_class_colored_name(unitID)
    local name = GetUnitName(unitID, false)
    local _, class = UnitClass(unitID)
    local color = RAID_CLASS_COLORS[class]

    if not name or not color then
        return name or unitID
    end

    return string.format("|cff%02x%02x%02x%s|r",
            color.r * 255,
            color.g * 255,
            color.b * 255,
            name)
end

local debug_counter = 0
function print_summon_status()
    print("check summon")
    local lines = {}
    debug_counter = debug_counter + 1
    table.insert(lines, "debug-counter: "..debug_counter)

    local most_popular_instance_key, missing_members = evaluate_location_status()
    if not most_popular_instance_key then
        table.insert(lines,"No one is at a known instance")
        addon.SetDisplayText(lines)
        return
    end
    local instance = ns.instances[most_popular_instance_key]
    table.insert(lines,"Instance: " .. instance.name)
    for _, id in ipairs(missing_members) do
        table.insert(lines,get_class_colored_name(id))
    end
    addon.SetDisplayText(lines)

end

-- add the ticker frame that does the checks
addon.tickerFrame = CreateFrame("Frame", addon.internal_name .. "TickerFrame", UIParent)

local accumulator = 0
local INTERVAL = 0.25  -- seconds

addon.tickerFrame:SetScript("OnUpdate", function(_, elapsed)
    accumulator = accumulator + elapsed
    if accumulator >= INTERVAL then
        accumulator = accumulator - INTERVAL  -- subtract instead of reset to avoid drift
        print_summon_status()
    end
end)

-- Set up the displayFrame
addon.DisplayFrame = CreateFrame("Frame", addon.internal_name.."DisplayFrame", UIParent, "BackdropTemplate")
addon.DisplayFrame:SetSize(300, 200)
addon.DisplayFrame:SetPoint("CENTER")

-- Text child
local displayText = addon.DisplayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
displayText:SetPoint("TOPLEFT", addon.DisplayFrame, "TOPLEFT", 8, -8)
displayText:SetPoint("BOTTOMRIGHT", addon.DisplayFrame, "BOTTOMRIGHT", -8, 8)
displayText:SetJustifyH("LEFT")
displayText:SetJustifyV("TOP")

-- Shift+left-click to move
addon.DisplayFrame:EnableMouse(true)
addon.DisplayFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and IsShiftKeyDown() then
        self:StartMoving()
    end
end)
addon.DisplayFrame:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
end)
addon.DisplayFrame:SetMovable(true)

-- Public setter
function addon.SetDisplayText(lines)
    displayText:SetText(table.concat(lines, "\n"))
end

-- load/unload
local function should_be_active()
    if InCombatLockdown() then return false end
    if not IsInGroup() then return false end

    local _, _, _, _, _, _, _, _, _, _, _, _, difficultyID = GetInstanceInfo()
    if difficultyID == 8 then return false end -- M+

    return true
end

local function set_addon_active(active)
    if active then
        addon.DisplayFrame:Show()
        addon.tickerFrame:Show()
    else
        addon.DisplayFrame:Hide()
        addon.tickerFrame:Hide()
    end
end

local stateFrame = CreateFrame("Frame")
stateFrame:RegisterEvent("PLAYER_REGEN_DISABLED")   -- combat enter
stateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")    -- combat leave
stateFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
stateFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

stateFrame:SetScript("OnEvent", function()
    set_addon_active(should_be_active())
end)

-- Evaluate on load too
set_addon_active(should_be_active())