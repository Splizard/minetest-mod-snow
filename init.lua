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

snow = {}
dofile(minetest.get_modpath("snow").."/mapgen.lua")
dofile(minetest.get_modpath("snow").."/config.lua")

function minetest.item_place_node(itemstack, placer, pointed_thing)
	local item = itemstack:peek_item()
	local def = itemstack:get_definition()
	if def.type == "node" and pointed_thing.type == "node" then
		local pos = pointed_thing.above

		----------------
		--Snow stuff
		--Allows placing nodes "through" snow.
		----------------
		local node = pointed_thing.under
		if minetest.env:get_node(node).name == "snow:snow" then

			--Gets rid of client-side placement block
			minetest.env:add_node(pos,{name="air"})

			minetest.env:remove_node(node)
			pos=node
		end
		----------------

		local oldnode = minetest.env:get_node(pos)
		local olddef = ItemStack({name=oldnode.name}):get_definition()

		if not olddef.buildable_to then
			minetest.log("info", placer:get_player_name() .. " tried to place"
				.. " node in invalid position " .. minetest.pos_to_string(pos)
				.. ", replacing " .. oldnode.name)
			return
		end

		minetest.log("action", placer:get_player_name() .. " places node "
			.. def.name .. " at " .. minetest.pos_to_string(pos))

		local newnode = {name = def.name, param1 = 0, param2 = 0}

		-- Calculate direction for wall mounted stuff like torches and signs
		if def.paramtype2 == 'wallmounted' then
			local under = pointed_thing.under
			local above = pointed_thing.above
			local dir = {x = under.x - above.x, y = under.y - above.y, z = under.z - above.z}
			newnode.param2 = minetest.dir_to_wallmounted(dir)
		-- Calculate the direction for furnaces and chests and stuff
		elseif def.paramtype2 == 'facedir' then
			local playerpos = placer:getpos() or {x=0,y=0,z=0}
			local dir = {x = pos.x - playerpos.x, y = pos.y - playerpos.y, z = pos.z - playerpos.z}
			newnode.param2 = minetest.dir_to_facedir(dir)
			minetest.log("action", "facedir: " .. newnode.param2)
		end

		-- Add node and update
		minetest.env:add_node(pos, newnode)

		-- Run callback
		if def.after_place_node then
			def.after_place_node(pos, placer)
		end

		-- Run script hook (deprecated)
		local _, callback
		for _, callback in ipairs(minetest.registered_on_placenodes) do
			callback(pos, newnode, placer)
		end

		itemstack:take_item()
	end
	return itemstack
end

--Replace leaves so snow gets removed on decay.
minetest.register_node(":default:leaves", {
	description = "Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'default:sapling'},
				rarity = 20,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'default:leaves'},
			}
		}
	},
	--Remove snow above leaves after decay.
	after_destruct = function(pos, node, digger)
		pos.y = pos.y + 1
		local nodename = minetest.env:get_node(pos).name
		if nodename == "snow:snow" then
			minetest.env:remove_node(pos)
		end
	end,
	sounds = default.node_sound_leaves_defaults(),
})

--Snowballs
-------------
snowball_GRAVITY=9
snowball_VELOCITY=19

--Shoot snowball.
local snow_shoot_snowball=function (item, player, pointed_thing)
	local playerpos=player:getpos()
	local obj=minetest.env:add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, "snow:snowball_entity")
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
	local node = minetest.env:get_node(pos)

	--Become item when hitting a node.
	if self.lastpos.x~=nil then --If there is no lastpos for some reason.
		if node.name ~= "air" then
			minetest.env:place_node(self.lastpos,{name="snow:snow"})
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

minetest.register_entity("snow:snowball_entity", snow_snowball_ENTITY)

--Snowball.
minetest.register_craftitem("snow:snowball", {
	Description = "Snowball",
	inventory_image = "snow_snowball.png",
	on_use = snow_shoot_snowball,
})

--Snow.
minetest.register_node("snow:snow", {
	tiles = {"snow_snow.png"},
	drawtype = "nodebox",
	sunlight_propagates = true,
	paramtype = "light",
	param2 = nil,
	--param2 is reserved for what vegetation is hiding inside.
	--mapgen defines the vegetation.
	--1 = Moss
	groups = {crumbly=3,melts=3},
	buildable_to = true,
	drop = 'snow:snowball',
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.35, 0.5}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.35, 0.5}
		},
	},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.45},
	}),
	--Update dirt node underneath snow.
	after_destruct = function(pos, node, digger)
		if node.param2 == 1 then
			minetest.env:add_node(pos,{name="snow:moss",param2=1})
		end
		pos.y = pos.y - 1
		local nodename = minetest.env:get_node(pos).name
		if nodename == "snow:dirt_with_snow" then
			minetest.env:add_node(pos,{name="default:dirt_with_grass"})
		end
	end,
	on_construct = function(pos, newnode)
		pos.y = pos.y - 1
		local nodename = minetest.env:get_node(pos).name
		if nodename == "default:dirt_with_grass" then
			minetest.env:remove_node(pos)
			minetest.env:add_node(pos,{name="snow:dirt_with_snow"})
		elseif nodename == "air" then
			pos.y = pos.y + 1
			minetest.env:remove_node(pos)
		end
	end,
})

--Snow with dirt.
minetest.register_node("snow:dirt_with_snow", {
	description = "Dirt with Snow",
	tiles = {"snow_snow.png", "default_dirt.png", "default_dirt.png^snow_snow_side.png"},
	is_ground_content = true,
	groups = {crumbly=3},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
	--Place snow above this node when placed.
	after_place_node = function(pos, newnode)
		pos.y = pos.y + 1
		local nodename = minetest.env:get_node(pos).name
		if nodename == "air" then
			minetest.env:add_node(pos,{name="snow:snow"})
		end
	end,
})

--Gets rid of snow when the node underneath is dug.
local unsnowify = function(pos, node, digger)
	if node.name == "default:dry_shrub" then
		pos.y = pos.y - 1
		local nodename = minetest.env:get_node(pos).name
		if nodename == "snow:dirt_with_snow" then
			minetest.env:add_node(pos,{name="default:dirt_with_grass"})
		end
		pos.y = pos.y + 1
	end
	pos.y = pos.y + 1
	local nodename = minetest.env:get_node(pos).name
	if nodename == "snow:snow" then
		minetest.env:remove_node(pos)
	end
end

minetest.register_on_dignode(unsnowify)

--Snow block.
minetest.register_node("snow:snow_block", {
	description = "Snow",
	tiles = {"snow_snow.png"},
	is_ground_content = true,
	groups = {crumbly=3,melts=2,falling_node=1},
	drop = 'snow:snow_block',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
})

--Ice.
minetest.register_node("snow:ice", {
	description = "Ice",
	tiles = {"snow_ice.png"},
	is_ground_content = true,
	groups = {snappy=2,cracky=3,melts=1},
	drop = 'snow:ice',
	paramtype = "light",
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults({
		footstep = {name="default_stone_footstep", gain=0.4},
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
	groups = {crumbly=3},
})

minetest.register_craft({
    output = 'snow:snow_block',
    recipe = {
        {'snow:snowball', 'snow:snowball'},
        {'snow:snowball', 'snow:snowball'},
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
    neighbors = {"default:desert_sand", "group:igniter","default:torch","default:furnace_active","group:hot"},
    interval = 2,
    chance = 2,
    action = function(pos, node, active_object_count, active_object_count_wider)
		local intensity = minetest.get_item_group(node.name,"melts")
		if intensity == 1 then
			minetest.env:add_node(pos,{name="default:water_source"})
		elseif intensity == 2 then
			local check_place = function(pos,node)
				if minetest.env:get_node(pos).name == "air" then
					minetest.env:place_node(pos,node)
				end
			end
			minetest.env:add_node(pos,{name="default:water_flowing"})
			check_place({x=pos.x+1,y=pos.y,z=pos.z},{name="default:water_flowing"})
			check_place({x=pos.x-1,y=pos.y,z=pos.z},{name="default:water_flowing"})
			check_place({x=pos.x,y=pos.y+1,z=pos.z},{name="default:water_flowing"})
			check_place({x=pos.x,y=pos.y-1,z=pos.z},{name="default:water_flowing"})
		elseif intensity == 3 then
			minetest.env:add_node(pos,{name="default:water_flowing"})
		end
		nodeupdate(pos)
    end,
})

--Freezing
--Water freezes when in contact with snow.
minetest.register_abm({
    nodenames = {"default:water_source"},
    neighbors = {"snow:snow", "snow:snow_block"},
    interval = 20,
    chance = 4,
    action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.env:add_node(pos,{name="snow:ice"})
    end,
})

--Spread moss to cobble.
minetest.register_abm({
    nodenames = {"default:cobble"},
    neighbors = {"snow:moss"},
    interval = 20,
    chance = 6,
    action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.env:add_node(pos,{name="default:mossycobble"})
    end,
})

if snow.enable_snowfall then

	--Snowing (WIP)
	snow_fall=function (pos)
		local obj=minetest.env:add_entity(pos, "snow:fall_entity")
		obj:setvelocity({x=0, y=-1, z=0})
	end

	-- The snowfall Entity
	snow_fall_ENTITY={
		physical = true,
		timer=0,
		textures = {"snow_snowfall.png"},
		lastpos={},
		collisionbox = {0,0,0,0,0,0},
	}


	-- snowfall_entity.on_step()--> called when snow is falling
	snow_fall_ENTITY.on_step = function(self, dtime)
		self.timer=self.timer+dtime
		local pos = self.object:getpos()
		local node = minetest.env:get_node(pos)

		if self.object:getvelocity().y == 0 then
			minetest.env:place_node(self.lastpos,{name="snow:snow"})
			self.object:remove()
		end

		self.lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
	end

	minetest.register_entity("snow:fall_entity", snow_fall_ENTITY)

	--Snowing abm
	minetest.register_abm({
		nodenames = {"default:dirt_with_grass"},
		interval = 30,
		chance = 50,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local env = minetest.env
			local perlin1 = env:get_perlin(112,3, 0.5, 150)
			local test = perlin1:get2d({x=pos.x, y=pos.z})
			if test > 0.53 then
				if pos.y >= -10 then
					if not env:find_node_near(pos, 10, "default:desert_sand") then
						local ground_y = nil
						for y=10,0,-1 do
							if env:get_node({x=pos.x,y=y,z=pos.z}).name ~= "air" then
								ground_y = y
								break
							end
						end
						if ground_y then
							local n = env:get_node({x=pos.x,y=ground_y,z=pos.z})
							if math.random(4) == 1 or (n.name ~= "snow:snow" and n.name ~= "snow:snow_block" and n.name ~= "snow:ice" and n.name ~= "default:water_source") then
								snow_fall({x=pos.x,y=ground_y+15,z=pos.z})
								if snow.debug then
									print("snowfall at x"..pos.x.." y"..pos.z)
								end
							end
						end
					end
				end
			end
		end
	})
end
