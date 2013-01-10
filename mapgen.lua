--Makes pine tree
function snow.make_pine(pos,snow,xmas)
	local env = minetest.env
	local perlin1 = env:get_perlin(112,3, 0.5, 150)
	local try_node = function(pos, node)
		local n = env:get_node(pos).name
		if  n == "air" or n == "snow:needles" or n == "default:leaves" or n == "snow:sapling_pine" or n == "snow:snow" or "snow:needles_decorated" then
			env:add_node(pos,node)
		end
	end
	local leaves = "snow:needles"
	if xmas then leaves = "snow:needles_decorated" end
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
	--Make tree.
	for i=0, 4 do
		local env = minetest.env
		if i==1 or i==2 then
			for x=-1,1 do
			for z=-1,1 do
				local x = pos.x + x
				local z = pos.z + z
				try_node({x=x,y=pos.y+i,z=z},{name=leaves})
				if snow and x ~= 0 and z ~= 0 and perlin1:get2d({x=x,y=z}) > 0.53 then
					try_node({x=x,y=pos.y+i+1,z=z},{name="snow:snow"})
				end
			end
			end
		end
		if i==3 or i==4 then
			local x = pos.x
			local y = pos.y+i
			local z = pos.z
			try_node({x=x+1,y=y,z=z},{name=leaves})
			try_node({x=x-1,y=y,z=z},{name=leaves})
			try_node({x=x,y=y,z=z+1},{name=leaves})
			try_node({x=x,y=y,z=z-1},{name=leaves})
			if snow then
				if perlin1:get2d({x=x+1,y=z}) > 0.53 then
					try_node({x=x+1,y=y+1,z=z},{name="snow:snow"})
				end
				if perlin1:get2d({x=x+1,y=z}) > 0.53 then
					try_node({x=x-1,y=y+1,z=z},{name="snow:snow"})
				end
				if perlin1:get2d({x=x,y=z+1}) > 0.53 then
					try_node({x=x,y=y+1,z=z+1},{name="snow:snow"})
				end
				if perlin1:get2d({x=x,y=z-1}) > 0.53 then
					try_node({x=x,y=y+1,z=z-1},{name="snow:snow"})
				end
			end
		end
		try_node({x=pos.x,y=pos.y+i,z=pos.z},{name="default:tree"})
	end
	try_node({x=pos.x,y=pos.y+5,z=pos.z},{name=leaves})
	try_node({x=pos.x,y=pos.y+6,z=pos.z},{name=leaves})
	if xmas then
		try_node({x=pos.x,y=pos.y+7,z=pos.z},{name="snow:star"})
	elseif snow and perlin1:get2d({x=pos.x,y=pos.z}) > 0.53 then
		try_node({x=pos.x,y=pos.y+7,z=pos.z},{name="snow:snow"})
	end
end



--Snow biomes are found at 0.53 and greater perlin noise.
minetest.register_on_generated(function(minp, maxp, seed)
if maxp.y >= -10 then
		local debug = snow.debug

		--Should make things a bit faster.
		local env = minetest.env

		--Get map specific perlin
		local perlin1 = env:get_perlin(112,3, 0.5, 150)

		-- Assume X and Z lengths are equal
		local divlen = 16
		local divs = (maxp.x-minp.x);
		local x0 = minp.x
		local z0 = minp.z
		local x1 = maxp.x
		local z1 = maxp.z

		--Speed hack: checks the corners and middle of the chunk for "snow biome".
		if not ( perlin1:get2d( {x=x0, y=z0} ) > 0.53 ) 					--top left
		and not ( perlin1:get2d( { x = x0 + ( (x1-x0)/2), y=z0 } ) > 0.53 )--top middle
		and not (perlin1:get2d({x=x1, y=z1}) > 0.53) 						--bottom right
		and not (perlin1:get2d({x=x1, y=z0+((z1-z0)/2)}) > 0.53) 			--right middle
		and not (perlin1:get2d({x=x0, y=z1}) > 0.53)  						--bottom left
		and not (perlin1:get2d({x=x1, y=z0}) > 0.53)						--top right
		and not (perlin1:get2d({x=x0+((x1-x0)/2), y=z1}) > 0.53) 			--left middle
		and not (perlin1:get2d({x=(x1-x0)/2, y=(z1-z0)/2}) > 0.53) 			--middle
		and not (perlin1:get2d({x=x0, y=z1+((z1-z0)/2)}) > 0.53) then		--bottom middle
			return
		end

		--Choose a biome types.
		local pr = PseudoRandom(seed+57)
		local biome

		--Land biomes
		biome = pr:next(1, 5)
		local snowy = biome == 1 --spawns alot of snow
		local plain = biome == 2 --spawns not much
		local alpine = biome == 3 --rocky terrain
		-- biome == 4 or biome == 5 -- normal biome

		--Water biomes
		biome2 = pr:next(1, 5)
		local cool = biome == 1  --only spawns ice on edge of water
		local icebergs = biome == 2
		local icesheet = biome == 3
		local icecave = biome == 4
		local icehole = biome == 5 --icesheet with holes

		--Misc biome settings.
		local icy = pr:next(1, 2) == 2   --If enabled spawns ice in sand instead of snow blocks.
		local mossy = pr:next(1,2) == 1  --Spawns moss in snow.
		local shrubs = pr:next(1,2) == 1 --Spawns dry shrubs in snow.
		local pines = pr:next(1,2) == 1 --spawns pines.

		--Debugging function
		local biomeToString = function(num,num2)
			local biome, biome2
			if num == 1 then biome = "snowy"
			elseif num == 2 then biome = "plain"
			elseif num == 3 then biome = "alpine"
			elseif num == 4 or num == 5 then biome = "normal"
			else biome =  "unknown "..num end

			if num2 == 1 then biome2 = "cool"
			elseif num2 == 2 then biome2 = "icebergs"
			elseif num2 == 3 then biome2 = "icesheet"
			elseif num2 == 4 then biome2 = "icecave"
			elseif num2 == 5 then biome2 = "icehole"
			else biome2 =  "unknown "..num end

			return biome, biome2
		end

		local make_pine = snow.make_pine
		local smooth = snow.smooth

		--Reseed random.
		pr = PseudoRandom(seed+68)

		if alpine then
			local trees = env:find_nodes_in_area(minp, maxp, {"default:leaves","default:tree"})
			for i,v in pairs(trees) do
				env:remove_node(v)
			end
		end

		--Loop through chunk.
		for j=0,divs do
		for i=0,divs do

			local x = x0+i
			local z = z0+j

				--Check if we are in a "Snow biome"
                local in_biome = false
                local test = perlin1:get2d({x=x, y=z})
                if smooth and (not snowy) and (test > 0.73 or (test > 0.43 and pr:next(0,29) > (0.73 - test) * 100 )) then
                    in_biome = true
                elseif (not smooth or snowy) and test > 0.53 then
					in_biome = true
                end

                if in_biome then

                if not plain or pr:next(1,12) == 1 then

					 -- Find ground level (0...15)
					local ground_y = nil
					for y=maxp.y,minp.y+1,-1 do
						if env:get_node({x=x,y=y,z=z}).name ~= "air" then
							ground_y = y
							break
						end
					end

					-- Snowy biome stuff
					local node = env:get_node({x=x,y=ground_y,z=z})

					if ground_y and (node.name == "default:dirt_with_grass" or node.name == "default:junglegrass") then
							local veg
							if mossy and pr:next(1,10) == 1 then veg = 1 end
							if alpine then
								--Gets rid of dirt
								env:add_node({x=x,y=ground_y+1,z=z}, {name="snow:snow",param2=veg})
								for y=ground_y,-6,-1 do
									if env:get_node({x=x,y=y,z=z}) and env:get_node({x=x,y=y,z=z}).name == "default:stone" then
										break
									else
										env:add_node({x=x,y=y,z=z},{name="default:stone"})
									end
								end
							elseif (shrubs and pr:next(1,28) == 1) or node.name == "default:junglegrass" then
								--Spawns dry shrubs.
								env:add_node({x=x,y=ground_y,z=z}, {name="snow:dirt_with_snow"})
								if snowy then
									env:add_node({x=x,y=ground_y+1,z=z}, {name="snow:snow_block", param2=3})
								else
									env:add_node({x=x,y=ground_y+1,z=z}, {name="default:dry_shrub"})
								end
							elseif pines and pr:next(1,36) == 1 then
								--Spawns pines.
								env:add_node({x=x,y=ground_y,z=z}, {name="default:dirt_with_grass"})
								make_pine({x=x,y=ground_y+1,z=z},true)
							elseif snowy then
								--Spawns snow blocks.
								env:add_node({x=x,y=ground_y+1,z=z}, {name="snow:snow_block"})
								env:add_node({x=x,y=ground_y+2,z=z}, {name="snow:snow",param2=veg})
							else
								--Spawns snow.
								env:add_node({x=x,y=ground_y,z=z}, {name="snow:dirt_with_snow"})
								env:add_node({x=x,y=ground_y+1,z=z}, {name="snow:snow",param2=veg})
							end
					elseif ground_y and node.name == "default:sand" then
						--Spawns ice in sand if icy, otherwise spawns snow on top.
						if not icy then
							env:add_node({x=x,y=ground_y+1,z=z}, {name="snow:snow"})
							env:add_node({x=x,y=ground_y,z=z}, {name="snow:snow_block"})
						else
							env:add_node({x=x,y=ground_y,z=z}, {name="snow:ice"})
						end
					elseif ground_y and env:get_node({x=x,y=ground_y,z=z}).name == "default:leaves" then
						env:add_node({x=x,y=ground_y+1,z=z}, {name="snow:snow"})
					elseif ground_y and env:get_node({x=x,y=ground_y,z=z}).name == "default:papyrus" then
						for i=ground_y, ground_y-4, -1 do
							if env:get_node({x=x,y=i,z=z}).name == "default:papyrus" then
								env:add_node({x=x,y=ground_y+1,z=z}, {name="snow:snow"})
								env:add_node({x=x,y=i,z=z}, {name="snow:snow_block", param2=2})
							end
						end
					elseif ground_y and node.name == "default:water_source" then
						if not icesheet and not icecave and not icehole then
							--Coastal ice.
							local x1 = env:get_node({x=x+1,y=ground_y,z=z}).name
							local z1 = env:get_node({x=x,y=ground_y,z=z+1}).name
							local xz1 = env:get_node({x=x+1,y=ground_y,z=z+1}).name
							local xz2 = env:get_node({x=x-1,y=ground_y,z=z-1}).name
							local x2 = env:get_node({x=x-1,y=ground_y,z=z}).name
							local z2 = env:get_node({x=x,y=ground_y,z=z-1}).name
							local y = env:get_node({x=x,y=ground_y-1,z=z}).name
							local rand = pr:next(1,4) == 1
							if
							((x1  and x1 ~= "default:water_source"  and x1 ~= "snow:ice"  and x1 ~= "air" and x1 ~= "ignore") or ((cool or icebergs) and x1 == "snow:ice"  and rand)) or
							((z1  and z1 ~= "default:water_source"  and z1 ~= "snow:ice"  and z1 ~= "air" and z1 ~= "ignore") or ((cool or icebergs) and z1 == "snow:ice"  and rand)) or
							((xz1 and xz1 ~= "default:water_source" and xz1 ~= "snow:ice" and xz1 ~= "air"and xz1 ~= "ignore") or ((cool or icebergs) and xz1 == "snow:ice" and rand)) or
							((xz2 and xz2 ~= "default:water_source" and xz2 ~= "snow:ice" and xz2 ~= "air"and xz2 ~= "ignore") or ((cool or icebergs) and xz2 == "snow:ice" and rand)) or
							((x2  and x2 ~= "default:water_source"  and x2 ~= "snow:ice"  and x2 ~= "air" and x2 ~= "ignore") or ((cool or icebergs) and x2 == "snow:ice"  and rand)) or
							((z2  and z2 ~= "default:water_source"  and z2 ~= "snow:ice"  and z2 ~= "air" and z2 ~= "ignore") or ((cool or icebergs) and z2 == "snow:ice"  and rand)) or
							(y ~= "default:water_source" and y ~= "snow:ice" and y ~= "air") or (pr:next(1,6) == 1 and icebergs) then
									env:add_node({x=x,y=ground_y,z=z}, {name="snow:ice"})
							end
						else
							--Icesheets, Broken icesheet, Icecaves
							if (icehole and pr:next(1,10) > 1) or icecave or icesheet then
								env:add_node({x=x,y=ground_y,z=z}, {name="snow:ice"})
							end
							if icecave then
								--Gets rid of water underneath ice
								for y=ground_y-1,-60,-1 do
									if env:get_node({x=x,y=y,z=z}) and env:get_node({x=x,y=y,z=z}).name ~= "default:water_source" then
										break
									else
										env:remove_node({x=x,y=y,z=z})
									end
								end
							end
						end
					--~ elseif ground_y and node.name == "snow:snow" and node.name ~= "snow:ice" then
						--~ --Abort genaration.
						--~ local name = env:get_node({x=x,y=ground_y-1,z=z}).name
						--~ if name ~= "default:leaves" and name ~= "snow:needles" then
							--~ if debug then
								--~ print(biomeToString(biome)..": snow found ABORTED!")
							--~ end
							--~ return
						--~ end
					end
				end
			end
		end
		end
		if debug then
			biome_string,biome2_string = biomeToString(biome,biome2)
			print(biome_string.." and "..biome2_string..": Snow Biome Genarated near x"..minp.x.." z"..minp.z)
		end
end
end
)
