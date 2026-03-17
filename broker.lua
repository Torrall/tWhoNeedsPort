local addon, ns = ...
print("read "..addon..": broker.lua")

local LDB = LibStub("LibDataBroker-1.1", true)

if LDB then
    ns.broker = LDB:NewDataObject(ns.internal_name, {
        type  = "data source",
        label = ns.internal_name,
        text  = ns.internal_name,
        icon  = "Interface\\Icons\\INV_Misc_MeetingStone_01",

        OnClick = function(_, button)
            if button == "LeftButton" then
                ns.manual_active = not(ns.manual_active)
                ns.check_and_set_active_status()
            end
        end,

        OnTooltipShow = function(tooltip)
            tooltip:AddLine(ns.internal_name)
            tooltip:AddLine("Left-click to toggle addon (display and checks)", 1, 1, 1)
        end,
    })
else
    -- if no databroker to toogle - must be active by default
    ns.manual_active = true
end