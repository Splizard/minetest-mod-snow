--[[
   Snow Biomes

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.
]]--

dofile(minetest.get_modpath("snow").."/util.lua")
dofile(minetest.get_modpath("snow").."/mapgen.lua")
dofile(minetest.get_modpath("snow").."/falling_snow.lua")
dofile(minetest.get_modpath("snow").."/sled.lua")

local needles = {
	description = "Pine Needles",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"snow_needles.png"},
	waving = 1,
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'snow:sapling_pine'},
				rarity = 20,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'snow:needles'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
}

if snow.christmas_content then
	--Cristmas trees.
	needles["drop"]["items"][3] = {
		-- player will get xmas tree with 1/50 chance
		items = {'snow:xmas_tree'},
		rarity = 50,
	}
	
	--Christmas easter egg.
	minetest.register_on_mapgen_init( function()
		if skins then
			skins.add("character_snow_man")
		end
	end)
end

--Pine leaves.
minetest.register_node("snow:needles", needles)

--Decorated Pine leaves.
minetest.register_node("snow:needles_decorated", {
	description = "Decorated Pine Needles",
	drawtype = "allfaces_optional",
	tiles = {"snow_needles_decorated.png"},
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2},
		drop = {
		max_items = 1,
		items = {
			{
				-- player will get xmas tree with 1/20 chance
				items = {'snow:xmas_tree'},
				rarity = 50,
			},
			{
				-- player will get sapling with 1/20 chance
				items = {'snow:sapling_pine'},
				rarity = 20,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'snow:needles_decorated'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("snow:xmas_tree", {
	description = "Christmas Tree",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"snow_xmas_tree.png"},
	inventory_image = "snow_xmas_tree.png",
	wield_image = "snow_xmas_tree.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("snow:sapling_pine", {
	description = "Pine Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"snow_sapling_pine.png"},
	inventory_image = "snow_sapling_pine.png",
	wield_image = "snow_sapling_pine.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
	
})

minetest.register_node("snow:star", {
	description = "Star",
	drawtype = "torchlike",
	tiles = {"snow_star.png"},
	inventory_image = "snow_star.png",
	wield_image = "snow_star.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3},
	sounds = default.node_sound_defaults(),
})

minetest.register_craft({
	type = "fuel",
	recipe = "snow:needles",
	burntime = 1,
})

minetest.register_craft({
	type = "fuel",
	recipe = "snow:sapling_pine",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "snow:needles_decorated",
	burntime = 1,
})

minetest.register_craft({
	type = "fuel",
	recipe = "snow:xmas_tree",
	burntime = 10,
})



--Snowballs
-------------
local snowball_GRAVITY=9
local snowball_VELOCITY=19

--Shoot snowball.
local snow_shoot_snowball=function (item, player, pointed_thing)
	local playerpos=player:getpos()
	local obj=minetest.add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, "snow:snowball_entity")
	local dir=player:get_look_dir()
	obj:setvelocity({x=dir.x*snowball_VELOCITY, y=dir.y*snowball_VELOCITY, z=dir.z*snowball_VELOCITY})
	obj:setacceleration({x=dir.x*-3, y=-snowball_GRAVITY, z=dir.z*-3})
	item:take_item()
	return item
end

--The snowball Entity
snow_snowball_ENTITY={
	physical = false,
	timer=0,
	textures = {"snow_snowball.png"},
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}

--Snowball_entity.on_step()--> called when snowball is moving.
snow_snowball_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

	--Become item when hitting a node.
	if self.lastpos.x~=nil then --If there is no lastpos for some reason.
		if node.name ~= "air" then
			snow.place(pos)
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

minetest.register_entity("snow:snowball_entity", snow_snowball_ENTITY)

--Snowball.
minetest.register_craftitem("snow:snowball", {
	description = "Snowball",
	inventory_image = "snow_snowball.png",
	on_use = snow_shoot_snowball,
})


--Backwards Compatability.
minetest.register_abm({
    nodenames = {"snow:snow1","snow:snow2","snow:snow3","gsnow4","snow:snow5","snow:snow6","snow:snow7","snow:snow8"},
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
    	local level = 7*(tonumber(node.name:sub(-1)))
    	minetest.add_node(pos,{name="default:snow"})
    	minetest.set_node_level(pos, level)
    end,
})

minetest.register_alias("snow:snow", "default:snow")
minetest.register_alias("snow:ice", "default:ice")
minetest.register_alias("snow:dirt_with_snow", "default:dirt_with_snow")
minetest.register_alias("snow:snow_block", "default:snowblock")
minetest.register_alias("snow:ice", "default:ice")


--Snow.
minetest.register_node(":default:snow", {
	description = "Snow",
	tiles = {"default_snow.png"},
	drawtype = "nodebox",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 == "leveled",
	groups = {crumbly=3,melts=3,falling_node=1,not_in_creative_inventory=1},
	buildable_to = true,
	freezemelt = "default:water_flowing",
	drop = {
		max_items = 2,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'snow:moss'},
				rarity = 20,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'snow:snowball'},
			}
		}
	},
	leveled = 7,
	drawtype = "nodebox",
	node_box = {
		type = "leveled",
		fixed = {
			{-0.5, -0.5, -0.5,  0.5, -0.5+2/16, 0.5},
		},
	},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_snow_footstep", gain=0.45},
	}),
	on_construct = function(pos)
		pos.y = pos.y - 1
		if minetest.get_node(pos).name == "default:dirt_with_grass" then
			minetest.add_node(pos, {name="default:dirt_with_snow"})
		end
	end,
	after_destruct = function(pos)
		pos.y = pos.y - 1
		if minetest.get_node(pos).name == "default:dirt_with_snow" then
			minetest.add_node(pos, {name="default:dirt_with_grass"})
		end
	end,
})

function snow.place(pos)
	local node = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
	local node = minetest.get_node(pos)
	local drawtype = minetest.registered_nodes[node.name].drawtype

	local bnode = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
	if node.name == "default:snow" and minetest.get_node_level(pos) < 63 then
		if minetest.get_item_group(bnode.name, "leafdecay") == 0 and snow.is_uneven(pos) ~= true then
			minetest.add_node_level(pos, 7)
		end
	elseif node.name == "default:snow" and minetest.get_node_level(pos) == 63 then
		local p = minetest.find_node_near(pos, 10, "default:dirt_with_grass")
		if p and minetest.get_node_light(p, 0.5) == 15 then
			minetest.add_node(p,{name="default:snow"})
		else
			minetest.add_node(pos,{name="default:snowblock"})
		end
	elseif node.name ~= "default:ice" and bnode.name ~= "air" then
		if drawtype == "normal" or drawtype == "allfaces_optional" then
			minetest.add_node({x=pos.x,y=pos.y+1,z=pos.z}, {name="default:snow"})
		elseif drawtype == "plantlike" then
			pos.y = pos.y - 1
			if minetest.get_node(pos).name == "default:dirt_with_grass" then
				minetest.add_node(pos, {name="default:dirt_with_snow"})
			end
		end
	end
end

--Checks if the snow level is even at any given pos.
--Smooth snow
local smooth_snow = snow.smooth_snow
snow.is_uneven = function(pos)
	if smooth_snow then
		local num = minetest.get_node_level(pos)
		local get_node = minetest.get_node
		local add_node = minetest.add_node
		local found
		local foundx
		local foundy
		for x=-1,1 do
		for z=-1,1 do
			local node = get_node({x=pos.x+x,y=pos.y,z=pos.z+z})
			local bnode = get_node({x=pos.x+x,y=pos.y-1,z=pos.z+z})
			local drawtype = minetest.registered_nodes[node.name].drawtype
	
			if drawtype == "plantlike" then
				if bnode.name == "default:dirt_with_grass" then
					add_node({x=pos.x+x,y=pos.y-1,z=pos.z+z}, {name="default:dirt_with_snow"})
					return true
				end
			end
			
			if (not(x == 0 and y == 0)) and node.name == "default:snow" and minetest.get_node_level({x=pos.x+x,y=pos.y,z=pos.z+z}) < num then
				found = true
				foundx = x
				foundz=z
			elseif node.name == "air" and bnode.name ~= "air" then
				if not (bnode.name == "default:snow") then 
					snow.place({x=pos.x+x,y=pos.y-1,z=pos.z+z})
					return true
				end
			end
		end
		end
		if found then
			local node = get_node({x=pos.x+foundx,y=pos.y,z=pos.z+foundz})
			if snow.is_uneven({x=pos.x+foundx,y=pos.y,z=pos.z+foundz}) ~= true then
				minetest.add_node_level({x=pos.x+foundx,y=pos.y,z=pos.z+foundz}, 7)
			end
			return true
		end
	end
end

--Snow with dirt.
minetest.register_node(":default:dirt_with_snow", {
	description = "Dirt with Snow",
	tiles = {"default_snow.png", "default_dirt.png", "default_dirt.png^snow_snow_side.png"},
	is_ground_content = true,
	groups = {crumbly=3},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_snow_footstep", gain=0.4},
	}),
})

--Snow block.
minetest.register_node(":default:snowblock", {
	description = "Snow",
	tiles = {"default_snow.png"},
	freezemelt = "default:water_source",
	is_ground_content = true,
	groups = {crumbly=3,melts=2,falling_node=1},
	drop = 'default:snowblock',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_snow_footstep", gain=0.4},
	}),
})

--Snow brick.
minetest.register_node("snow:snow_brick", {
	description = "Snow Brick",
	tiles = {"snow_snow_brick.png"},
	is_ground_content = true,
	groups = {crumbly=3,melts=2},
	drop = 'snow:snow_brick',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
})

--Moss.
minetest.register_node("snow:moss", {
	description = "Moss",
	tiles = {"snow_moss.png"},
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	selection_box = {
		type = "wallmounted",
	},
	is_ground_content = true,
	groups = {crumbly=3, flammable=2, attached_node=1},
})

minetest.register_craft({
    output = 'snow:snow_block',
    recipe = {
        {'snow:snowball', 'snow:snowball'},
        {'snow:snowball', 'snow:snowball'},
    },
})

minetest.register_craft({
    output = 'snow:snow_brick',
    recipe = {
        {'default:snowblock', 'default:snowblock'},
        {'default:snowblock', 'default:snowblock'},
    },
})

--Melting
--Any node part of the group melting will melt when near warm nodes such as lava, fire, torches, etc.
--The amount of water that replaces the node is defined by the number on the group:
--1: one water_source
--2: four water_flowings
--3: one water_flowing
minetest.register_abm({
    nodenames = {"group:melts"},
    neighbors = {"group:igniter","default:torch","default:furnace_active","group:hot"},
    interval = 2,
    chance = 2,
    action = function(pos, node, active_object_count, active_object_count_wider)
		local intensity = minetest.get_item_group(node.name,"melts")
		if intensity == 1 then
			minetest.add_node(pos,{name="default:water_source"})
		elseif intensity == 2 then
			local check_place = function(pos,node)
				if minetest.get_node(pos).name == "air" then
					minetest.place_node(pos,node)
				end
			end
			minetest.add_node(pos,{name="default:water_flowing"})
			check_place({x=pos.x+1,y=pos.y,z=pos.z},{name="default:water_flowing"})
			check_place({x=pos.x-1,y=pos.y,z=pos.z},{name="default:water_flowing"})
			check_place({x=pos.x,y=pos.y+1,z=pos.z},{name="default:water_flowing"})
			check_place({x=pos.x,y=pos.y-1,z=pos.z},{name="default:water_flowing"})
		elseif intensity == 3 then
			minetest.add_node(pos,{name="default:water_flowing"})
		end
		nodeupdate(pos)
    end,
})

--Freezing
--Water freezes when in contact with snow.
minetest.register_abm({
    nodenames = {"default:water_source"},
    neighbors = {"default:snow", "default:snowblock"},
    interval = 20,
    chance = 4,
    action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.add_node(pos,{name="default:ice"})
    end,
})

--Spread moss to cobble.
minetest.register_abm({
    nodenames = {"default:cobble"},
    neighbors = {"snow:moss"},
    interval = 20,
    chance = 6,
    action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.add_node(pos,{name="default:mossycobble"})
    end,
})

--Grow saplings
minetest.register_abm({
    nodenames = {"snow:sapling_pine"},
    interval = 10,
    chance = 50,
    action = function(pos, node, active_object_count, active_object_count_wider)
		snow.make_pine(pos,false)
    end,
})

--Grow saplings
minetest.register_abm({
    nodenames = {"snow:xmas_tree"},
    interval = 10,
    chance = 50,
    action = function(pos, node, active_object_count, active_object_count_wider)
		snow.make_pine(pos,false,true)
    end,
})
