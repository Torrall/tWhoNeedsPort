local addon, ns = ...
print("read " .. addon .. ": midnight_season_1.lua")

ns.instances = ns.instances or {}

ns.instances.seat_of_the_triumvirate = {
    name = "Seat of the Triumvirate",
    inside_ids = { 99999 },
    outside_ids = { 1669 },
    outside_coordinates = {
        x = 10836.100585938,
        y = 5396.3002929688,
    },
}

ns.instances.algethar_academy = {
    name = "Algeth'ar Academy",
    inside_ids = { 2526 },
    outside_ids = { 2444 },
    outside_coordinates = {
        x = -2777.1999511719,
        y = 1343.9000244141,
    },
}

ns.instances.skyreach = {
    name = "Skyreach",
    inside_ids = { 1209 },
    outside_ids = { 1116 },
    outside_coordinates = {
        x = 2526.1999511719,
        y = 31.10000038147,
    },
}

ns.instances.pit_of_saron = {
    name = "Pit of Saron",
    inside_ids = { 658 },
    outside_ids = { 571 },
    outside_coordinates = {
        x = 2024.0999755859,
        y = 5613.3999023438,
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