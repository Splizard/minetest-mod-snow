local mgname = ""

--Identify the mapgen.
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
function snow.voxelmanip_pine(pos,a,data)
    local c_snow = minetest.get_content_id("default:snow")
    local c_pine_needles = minetest.get_content_id("snow:needles")
    local c_tree = minetest.get_content_id("default:tree")
    local c_air = minetest.get_content_id("air")
    
	local perlin1 = minetest.get_perlin(112,3, 0.5, 150) 
	--Clear ground.
	for x=-1,1 do
	for z=-1,1 do
		local node = a:index(pos.x+x,pos.y,pos.z+z)
		if data[node] == c_snow then
			data[node] = c_air
		end
	end
	end
	--Make tree.
	for i=0, 4 do
		if i==1 or i==2 then
			for x=-1,1 do
			for z=-1,1 do
				local x = pos.x + x
				local z = pos.z + z
				local node = a:index(x,pos.y+i,z)
				data[node] = c_pine_needles
				if snow and x ~= 0 and z ~= 0 and perlin1:get2d({x=x,y=z}) > 0.53 then
					local abovenode = a:index(x,pos.y+i+1,z)
					data[abovenode] = c_snow
				end
			end
			end
		end
		if i==3 or i==4 then
			local x = pos.x
			local y = pos.y+i
			local z = pos.z
			data[a:index(x+1,y,z)] = c_pine_needles
			data[a:index(x-1,y,z)] = c_pine_needles
			data[a:index(x,y,z+1)] = c_pine_needles
			data[a:index(x,y,z-1)] = c_pine_needles
			if snow then
				if perlin1:get2d({x=x+1,y=z}) > 0.53 then
					data[a:index(x+1,y+1,z)] = c_snow
				end
				if perlin1:get2d({x=x+1,y=z}) > 0.53 then
					data[a:index(x-1,y+1,z)] = c_snow
				end
				if perlin1:get2d({x=x,y=z+1}) > 0.53 then
					data[a:index(x,y+1,z+1)] = c_snow
				end
				if perlin1:get2d({x=x,y=z-1}) > 0.53 then
					data[a:index(x,y+1,z-1)] = c_snow
				end
			end
		end
		data[a:index(pos.x,pos.y+i,pos.z)] = c_tree
	end
	data[a:index(pos.x,pos.y+5,pos.z)] = c_pine_needles
	data[a:index(pos.x,pos.y+6,pos.z)] = c_pine_needles
	if snow and perlin1:get2d({x=pos.x,y=pos.z}) > 0.53 then
		data[a:index(pos.x,pos.y+7,pos.z)] = c_snow
	end
end
