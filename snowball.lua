--============
--Snowballs
--============

-- Snowballs were destroying nodes if the snowballs landed just right.
-- Quite a bit of trial-and-error learning here and it boiled down to a 
-- small handful of code lines making the difference. ~ LazyJ

local snowball_GRAVITY=9
local snowball_VELOCITY=19

--Shoot snowball
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
	textures = {"default_snowball.png"},
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}

--Snowball_entity.on_step()--> called when snowball is moving.
snow_snowball_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

	--Become item when hitting a node.
	if self.lastpos.x~=nil then --If there is no lastpos for some reason. ~ Splizard
		-- Check to see what is one node above where the snow is
		-- going to be placed. ~ LazyJ, 2014_04_08
		local abovesnowballtarget = {x=pos.x, y=pos.y+1, z=pos.z}
		-- Identify the name of the node that was found above. ~ LazyJ, 2014_04_08
		local findwhatisabove = minetest.get_node(abovesnowballtarget).name
		-- If the node above is air, then it's OK to go on to the next step. ~ LazyJ, 2014_04_08
		if findwhatisabove == "air" then
			-- If the node where the snow is going is anything except air, then it's OK to put 
			-- the snow on it. ~ Original line of code by Splizard, comment by LazyJ so I can 
			-- keep track of what this code does. ~ LazyJ, 2014_04_07
			if node.name ~= "air" then
				--snow.place(pos) -- this is the original code, I replaced it with 
				-- minetest.place_node and bumped the y position up by 2 (make the snow drop 
				-- from a node above and pile up). ~ LazyJ, 2014_04_07
				minetest.place_node({x=pos.x, y=pos.y+2, z=pos.z}, {name="default:snow"})
				self.object:remove()
			end	
			else -- If findwhatisabove is not equal to "air" then cancel the snowball 
			-- with self.object:remove() ~ LazyJ, 2014_04_08
				self.object:remove()
		end	
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
end



minetest.register_entity("snow:snowball_entity", snow_snowball_ENTITY)



-- Snowball and Default Snowball Merged

-- They both look the same, they do basically the same thing (except one is a leftclick throw 
-- and the other is a rightclick drop),... Why not combine snow:snowball with default:snow and 
-- benefit from both? ~ LazyJ, 2014_04_08

--[[ Save this for reference and occasionally compare to the default code for any updates.

minetest.register_node(":default:snow", {
	description = "Snow",
	tiles = {"default_snow.png"},
	inventory_image = "default_snowball.png",
	wield_image = "default_snowball.png",
	is_ground_content = true,
	paramtype = "light",
	buildable_to = true,
	leveled = 7,
	drawtype = "nodebox",
	freezemelt = "default:water_flowing",
	node_box = {
		type = "leveled",
		fixed = {
			{-0.5, -0.5, -0.5,  0.5, -0.5+2/16, 0.5},
		},
	},
	groups = {crumbly=3,falling_node=1, melts=1, float=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_snow_footstep", gain=0.25},
		dug = {name="default_snow_footstep", gain=0.75},
	}),
	on_construct = function(pos)
		if minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "default:dirt_with_grass" or minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "default:dirt" then
			minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z}, {name="default:dirt_with_snow"})
		end
		-- Now, let's turn the snow pile into a snowblock. ~ LazyJ
		if minetest.get_node({x=pos.x, y=pos.y-2, z=pos.z}).name == "default:snow" and -- Minus 2 because at the end of this, the layer that triggers the change to a snowblock is the second layer more than a full block, starting into a second block (-2) ~ LazyJ, 2014_04_11
			minetest.get_node({x=pos.x, y=pos.y, z=pos.z}).name == "default:snow" then
			minetest.set_node({x=pos.x, y=pos.y-2, z=pos.z}, {name="default:snowblock"})
		end
	end,
	on_use = snow_shoot_snowball  -- This line is from the 'Snow' mod, the reset is default Minetest.
})
--]]



minetest.override_item("default:snow", {
	groups = {cracky=3, crumbly=3, choppy=3, oddly_breakable_by_hand=3,falling_node=1, melts=2, float=1},
	on_construct = function(pos)
		if minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "default:dirt_with_grass"
		or minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "default:dirt" then
			minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z}, {name="default:dirt_with_snow"})
		end
		-- Now, let's turn the snow pile into a snowblock.
		if minetest.get_node({x=pos.x, y=pos.y-2, z=pos.z}).name == "default:snow" and
		-- Minus 2 because at the end of this, the layer that triggers the change to a snowblock
		-- is the second snowball layer more than the full block below. That second layer,from 
		-- what I've observed, seems to push into a third node box above so by subracting 2, 
		-- the swap_node target is moved back down to the first get_node y=pos.
		-- ~ LazyJ, 2014_04_24
			minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "default:snow" then
			minetest.set_node({x=pos.x, y=pos.y-2, z=pos.z}, {name="default:snowblock"})
		end
	end,
	on_use = snow_shoot_snowball  -- This line is from the 'Snow' mod, 
								-- the reset is default Minetest. ~ LazyJ
})



--[[
A note about default torches, melting, and "buildable_to = true" in default snow.

On servers where buckets are disabled, snow and ice stuff is used to set water for crops and
water stuff like fountains, pools, ponds, ect.. It is a common practice to set a default torch on
the snow placed where the players want water to be.

If you place a default torch *on* default snow to melt it, instead of melting the snow is 
*replaced* by the torch. Using "buildable_to = false" would fix this but then the snow would no 
longer pile-up in layers; the snow would stack like thin shelves in a vertical column.

I tinkered with the default torch's code (see below) to check for snow at the position and one 
node above (layered snow logs as the next y position above) but default snow's 
"buildable_to = true" always happened first. An interesting exercise to better learn how Minetest 
works, but otherwise not worth it. If you set a regular torch near snow, the snow will melt 
and disappear leaving you with nearly the same end result anyway. I say "nearly the same" 
because if you set a default torch on layered snow, the torch will replace the snow and be 
lit on the ground. If you were able to set a default torch *on* layered snow, the snow would
melt and the torch would become a dropped item.

~ LazyJ

--]]


-- Some of the ideas I tried. ~ LazyJ
--[[
local can_place_torch_on_top = function(pos)
			if minetest.get_node({x=pos.x, y=pos.y, z=pos.z}).name == "default:snow"
			or minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name == "default:snow" then
				minetest.override_item("default:snow", {buildable_to = false,})
			end
		end 
--]]


--[[
minetest.override_item("default:torch", {
	--on_construct = function(pos)
	on_place = function(itemstack, placer, pointed_thing)
		--if minetest.get_node({x=pos.x, y=pos.y, z=pos.z}).name == "default:snow"
			-- Even though layered snow doesn't look like it's in the next position above (y+1)
			-- it registers in that position. Check the terminal's output to see the coord change.
		--or minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name == "default:snow"
		if pointed_thing.name == "default:snow"
		then minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z}, {name="default:torch"})
		end
	end
})
--]]
