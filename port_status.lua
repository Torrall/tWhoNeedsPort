local addon, ns = ...
print("read "..addon..": port_status.lua")

local status_list = {}

local SAFETY_MARGIN = 0.5 --seconds
local KEEP_ACCEPTED_STATUS_FOR = 60.0 --seconds
local SUMMON_DURATION = 120 --seconds

local NO_SUMMON = "NO_SUMMON"
local SUMMON_PENDING = "SUMMON_PENDING"
local SUMMON_ACCEPTED = "SUMMON_ACCEPTED"

local STRING_MAPPING = {
    NO_SUMMON = "",
    SUMMON_PENDING = "|cff888888pending|r",
    SUMMON_ACCEPTED = "|cff888888accepted|r",
}

local function eval_summon_status(unitID)
    local guid = UnitGUID(unitID)
    local has_summon = C_IncomingSummon.HasIncomingSummon(unitID) or false

    local old_status
    if not(status_list[guid]) then
        old_status = NO_SUMMON
    end

    -- trivial case: no summon now and before
    if old_status == NO_SUMMON and not(has_summon) then
        return NO_SUMMON
    end

    -- first change case: has summon now but did not have last check -> fresh summon
    if has_summon and old_status == NO_SUMMON then
        status_list[guid] = {
            status = SUMMON_PENDING,
            expiration_time = GetTime() + SUMMON_DURATION - SAFETY_MARGIN
        }
        return SUMMON_PENDING
    end

    -- second change case: had summon but does not now -> assume accepted
    if not(has_summon) and old_status == SUMMON_PENDING then
        status_list[guid] = {
            status = SUMMON_ACCEPTED,
            expiration_time = GetTime() + KEEP_ACCEPTED_STATUS_FOR - SAFETY_MARGIN
        }
        return SUMMON_PENDING
    end

    -- something was pending (summon or accept) but has expired - cleanup
    local time_left = status_list[guid].expiration_time - GetTime()
    if time_left <= 0 then
        status_list[guid] = nil
        return NO_SUMMON
    end

    return status_list[guid].status
end

function ns.GetSummonStatuswString(unitID)
    local status = eval_summon_status(unitID)
    return STRING_MAPPING[status]
end