local addon = ...

local status_list = {}

local SAFETY_MARGIN = 0.5 --seconds
local KEEP_ACCEPTED_STATUS_FOR = 60.0 --seconds

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
    local time_left = C_PartyInfo.GetSummonConfirmTimeLeft(unitID) or 0

    -- first case: pending summon
    if time_left > 0 then
        status_list[guid] = {
            status = SUMMON_PENDING,
            expiration_time = GetTime() + time_left -SAFETY_MARGIN
        }
        return SUMMON_PENDING
    end
    -- second case: no summon pending and no old info
    if not(status_list[guid]) then
        return NO_SUMMON
    end

    -- from now on we can assume that there was an old status
    local old_status = status_list[guid].status
    local old_time_left = status_list[guid].expiration_time - GetTime()

    -- third case no summon shown pending but there was one before - we assume accepted
    if old_time_left > 0 and old_status == SUMMON_PENDING then
        status_list[guid] = {
            status = SUMMON_ACCEPTED,
            expiration_time = GetTime() + KEEP_ACCEPTED_STATUS_FOR -SAFETY_MARGIN
        }
        return SUMMON_ACCEPTED
    end


    -- fourth case: something was pending (summon or accept) but has expired - cleanup
    if old_time_left <= 0 then
        status_list[guid] = nil
        return NO_SUMMON
    end
end

function addon.get_summon_status_string(unitID)
    local status = eval_summon_status()
    return STRING_MAPPING[status]
end