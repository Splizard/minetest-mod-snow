local mgname = ""

--Identify the mapgen.
if minetest.register_on_mapgen_init then
	minetest.register_on_mapgen_init(function(MapgenParams)
		if MapgenParams.mgname then
			mgname = MapgenParams.mgname
		else
			io.write("[MOD] Snow Biomes: WARNING! mapgen could not be identifyed!\n")
		end
		if mgname == "v7" then
			--Load mapgen_v7 compatibility.
			dofile(minetest.get_modpath("snow").."/mapgen_v7.lua")
		else
			--Load mapgen_v6 compatibility.
			dofile(minetest.get_modpath("snow").."/mapgen_v6.lua")
		end
	end)
else
	--Fall back to mapgen_v6.
	dofile(minetest.get_modpath("snow").."/mapgen_v6.lua")
end

local pine_tree = {
	axiom="TABff",
	rules_a="[&T+f+ff+ff+ff+f]GA",
	rules_b="[&T+f+Gf+Gf+Gf]GB",
	trunk="default:tree",
	leaves="snow:needles",
	angle=90,
	iterations=1,
	random_level=0,
	trunk_type="single",
	thin_branches=true,
}
local xmas_tree = {
	axiom="TABff",
	rules_a="[&T+f+ff+ff+ff+f]GA",
	rules_b="[&T+f+Gf+Gf+Gf]GB",
	trunk="default:tree",
	leaves="snow:needles_decorated",
	angle=90,
	iterations=1,
	random_level=0,
	trunk_type="single",
	thin_branches=true,
}

--Makes pine tree
function snow.make_pine(pos,snow,xmas)
	local env = minetest.env
	local perlin1 = env:get_perlin(112,3, 0.5, 150)
	local try_node = function(pos, node)
		local n = env:get_node(pos).name
		if n == "air" or n == "ignore" then
			env:add_node(pos,node)
		end
	end
	--Clear ground.
	for x=-1,1 do
	for z=-1,1 do
		if env:get_node({x=pos.x+x,y=pos.y,z=pos.z+z}).name == "snow:snow" then
			env:remove_node({x=pos.x+x,y=pos.y,z=pos.z+z})
		end
		if env:get_node({x=pos.x+x,y=pos.y,z=pos.z+z}).name == "snow:snow_block" then
			env:remove_node({x=pos.x+x,y=pos.y,z=pos.z+z})
		end
	end
	end
	if xmas then
		env:remove_node(pos)
		minetest.env:spawn_tree(pos, xmas_tree)
	else
		minetest.env:spawn_tree(pos, pine_tree)
	end
	if snow then
		local x,z = pos.x,pos.z
		try_node({x=x+1,y=pos.y+3,z=z+1},{name="snow:snow"})
		try_node({x=x-1,y=pos.y+3,z=z-1},{name="snow:snow"})
		try_node({x=x-1,y=pos.y+3,z=z+1},{name="snow:snow"})
		try_node({x=x+1,y=pos.y+3,z=z-1},{name="snow:snow"})
		
		try_node({x=x+1,y=pos.y+5,z=z},{name="snow:snow"})
		try_node({x=x-1,y=pos.y+5,z=z},{name="snow:snow"})
		try_node({x=x,y=pos.y+5,z=z+1},{name="snow:snow"})
		try_node({x=x,y=pos.y+5,z=z-1},{name="snow:snow"})
	end
	if xmas then
		try_node({x=pos.x,y=pos.y+7,z=pos.z},{name="snow:star"})
	elseif snow and perlin1:get2d({x=pos.x,y=pos.z}) > 0.53 then
		try_node({x=pos.x,y=pos.y+7,z=pos.z},{name="snow:snow"})
	end
end
