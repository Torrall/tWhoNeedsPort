local addon, ns = ...
print("read " .. addon .. ": midnight_season_2.lua")

ns.instances = ns.instances or {}


--[[

ns.instances.template_dungeon = {
    name = "template-dungeon",
    inside_ids = { 99999 },
    outside_ids = { 99999 },
    outside_coordinates = {
        x = 0.0,
        y = 0.0,
    },
}

]]