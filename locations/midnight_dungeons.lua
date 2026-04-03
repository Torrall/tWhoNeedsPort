local addon, ns = ...
print("read "..addon..": midnight_dungeons.lua")

ns.instances = ns.instances or {}

ns.instances.magisters_terrace = {
    name = "Magister's Terrace",
    inside_ids = { 2811 },
    outside_ids = { 0 },
    outside_coordinates = {
        x = -4952.1,
        y = 11646.5,
    },
}

ns.instances.murder_row = {
    name = "Murder Row",
    inside_ids = { 2813 },
    outside_ids = { 0 },
    outside_coordinates = {
        x = -4932.8999023438,
        y = 8629.2998046875,
    },
    special_distance_threshold = 65,
}

ns.instances.windrunner_spire = {
    name = "Windrunner Spire",
    inside_ids = { 2805 },
    outside_ids = { 0 },
    outside_coordinates = {
        x = -3212.4001464844,
        y = 5206.7001953125,
    },
}

ns.instances.nexus_point_xenas = {
    name = "Nexus-Point Xenas",
    inside_ids = { 2915 },
    outside_ids = { 2771 },
    outside_coordinates = {
        x = -1786.3000488281,
        y = 1471.0,
    },
}

ns.instances.voidscar_arena = {
    name = "Voidscar Arena",
    inside_ids = { 2923 },
    outside_ids = { 2771 },
    outside_coordinates = {
        x = -458.30001831055,
        y = 4371.2001953125, d
    },
}

ns.instances.blinding_vale = {
    name = "The Blinding Vale",
    inside_ids = { 2859 },
    outside_ids = { 2694 },
    outside_coordinates = {
        x = 1500.0999755859,
        y = -1397.0999755859,
    },
}

ns.instances.maisara_caverns = {
    name = "Maisara Caverns",
    inside_ids = { 2874 },
    outside_ids = { 0 },
    outside_coordinates = {
        x = -7595.2001953125,
        y = 5951.3999023438,
    },
}

ns.instances.den_of_nalorakk = {
    name = "Den of Nalorakk",
    inside_ids = { 2825 },
    outside_ids = { 0 },
    outside_coordinates = {
        x = -6402.8999023438,
        y = 3280.8000488281,
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