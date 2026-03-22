local addon, ns = ...
print("read "..addon..": midnight_raids.lua")

ns.instances = ns.instances or {}

ns.instances.the_voidspire = {
    name = "The Voidspire",
    inside_ids = { 99999 },
    outside_ids = { 2771 },
    outside_coordinates = {
        x = 252.69999694824,
        y = 1219.0999755859,
    },
}

ns.instances.the_dreamrift = {
    name = "The Dreamrift",
    inside_ids = { 2939 },
    outside_ids = { 2694 },
    outside_coordinates = {
        x = -1083,
        y = -636.5,
    },
}

ns.instances.march_on_quel_danas = {
    name = "March on Quel'Danas",
    inside_ids = { 99999 },
    outside_ids = { 0 },
    outside_coordinates = {
        x = -4582.8999023438,
        y = 10077.700195312,
    },
}

--[[

ns.instances.template_raid = {
    name = "template-raid",
    inside_ids = { 99999 },
    outside_ids = { 99999 },
    outside_coordinates = {
        x = 0.0,
        y = 0.0,
    },
}

]]