local addon, ns = ...
print("read " .. addon .. ": midnight_season_2.lua")

ns.instances = ns.instances or {}

ns.instances.altar_of_fangs = {
    name = "Altar of Fangs",
    inside_ids = { 99999 },
    outside_ids = { 2916 },
    outside_coordinates = {
        x = -10400,
        y = 4920,
    },
}

ns.instances.kings_rest = {
    name = "Kings' Rest",
    inside_ids = { 1762 },
    outside_ids = { 1642 },
    outside_coordinates = {
        x = 2512,
        y = -861,
    },
}

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