--Identify content ID's of nodes		
local c_dirt_with_grass  = minetest.get_content_id("default:dirt_with_grass")
local c_dirt  = minetest.get_content_id("default:dirt")
local c_tree = minetest.get_content_id("default:tree")
local c_apple = minetest.get_content_id("default:apple")
local c_snow = minetest.get_content_id("default:snow")
local c_snow_block = minetest.get_content_id("default:snowblock")
local c_dirt_with_snow = minetest.get_content_id("default:dirt_with_snow")
local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")
local c_stone  = minetest.get_content_id("default:stone")
local c_dry_shrub  = minetest.get_content_id("default:dry_shrub")
local c_leaves = minetest.get_content_id("default:leaves")
local c_jungleleaves = minetest.get_content_id("default:jungleleaves")
local c_junglegrass = minetest.get_content_id("default:junglegrass")
local c_ice = minetest.get_content_id("default:ice")
local c_water = minetest.get_content_id("default:water_source")
local c_papyrus = minetest.get_content_id("default:papyrus")
local c_sand = minetest.get_content_id("default:sand")

--Snow biomes are found at 0.53 and greater perlin noise.
minetest.register_on_generated(function(minp, maxp, seed)
	--if maxp.y >= -10 and maxp.y > snow.min_height then
	
		--Start timer
		local t1 = os.clock()
		local in_biome = false
		
		--Load Voxel Manipulator
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local a = VoxelArea:new{
		        MinEdge={x=emin.x, y=emin.y, z=emin.z},
		        MaxEdge={x=emax.x, y=emax.y, z=emax.z},
		}
		local data = vm:get_data()
		
		local debug = snow.debug
		local min_height = snow.min_height

		--Should make things a bit faster.
		local env = minetest.env
		
		
		-- Assume X and Z lengths are equal
		local divlen = 16
		local divs = (maxp.x-minp.x)+1;
		local x0 = minp.x
		local z0 = minp.z
		local x1 = maxp.x
		local z1 = maxp.z


		--Get map specific perlin noise.
    	local perlin1 = env:get_perlin(112,3, 0.5, 150)

		--Speed hack: checks the corners and middle of the chunk for "snow biome".
		--[[if not ( perlin1:get2d( {x=x0, y=z0} ) > 0.53 ) 					--top left
		and not ( perlin1:get2d( { x = x0 + ( (x1-x0)/2), y=z0 } ) > 0.53 )--top middle
		and not (perlin1:get2d({x=x1, y=z1}) > 0.53) 						--bottom right
		and not (perlin1:get2d({x=x1, y=z0+((z1-z0)/2)}) > 0.53) 			--right middle
		and not (perlin1:get2d({x=x0, y=z1}) > 0.53)  						--bottom left
		and not (perlin1:get2d({x=x1, y=z0}) > 0.53)						--top right
		and not (perlin1:get2d({x=x0+((x1-x0)/2), y=z1}) > 0.53) 			--left middle
		and not (perlin1:get2d({x=(x1-x0)/2, y=(z1-z0)/2}) > 0.53) 			--middle
		and not (perlin1:get2d({x=x0, y=z1+((z1-z0)/2)}) > 0.53) then		--bottom middle
			return
		end]]

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

		local spawn_pine = snow.voxelmanip_pine
		local smooth = snow.smooth_biomes
		local legacy = snow.legacy

		--Reseed random.
		pr = PseudoRandom(seed+68)

		--[[if alpine then
			local trees = env:find_nodes_in_area(minp, maxp, {"default:leaves","default:tree"})
			for i,v in pairs(trees) do
				env:remove_node(v)
			end
		end]]
		
		local write_to_map = false
    	
		--Loop through chunk.
		for x = minp.x, maxp.x do
		for z = minp.z, maxp.z do
				
				--Check if we are in a "Snow biome"
		        local in_biome = false
		        local test = perlin1:get2d({x=x, y=z})
		        if smooth and (not snowy) and (test > 0.73 or (test > 0.43 and pr:next(0,29) > (0.73 - test) * 100 )) then
		            in_biome = true
		        elseif (not smooth or snowy) and test > 0.53 then
					in_biome = true
		        end
				if not in_biome then
					if alpine == true and test > 0.43 then
						local ground_y = nil
						for y=maxp.y,minp.y,-1 do
							local n = data[a:index(x, y, z)]
							if n ~= c_air and n ~= c_ignore then
								ground_y = y
								break
							end
						end
						if ground_y then
							local node = a:index(x, ground_y, z)
							if (data[node] == c_leaves or data[node] == c_jungleleaves) then
						
								for y=ground_y,-6,-1 do
									local stone = a:index(x, y, z)
									if data[stone] ~= c_leaves and data[stone] ~= c_jungleleaves and data[stone] ~= c_tree and data[stone] ~= c_air and data[stone] ~= c_apple then
										break
									else
										data[stone] = c_air
									end
								end
							end			
						end	
					end
					
		        elseif in_biome then
					write_to_map = true
		        
		        	local perlin2 = env:get_perlin(322345,3, 0.5, 80)
		        	local icetype = perlin2:get2d({x=x, y=z})
    				local cool = icetype > 0  --only spawns ice on edge of water
					local icebergs = icetype > -0.2 and icetype <= 0
					local icehole = icetype > -0.4 and icetype <= -0.2
					local icesheet = icetype > -0.6 and icetype <= -0.4
					local icecave = icetype <= -0.6

		        --if not plain or pr:next(1,12) == 1 then

					 -- Find ground level (0...15)
					local ground_y = nil
					for y=maxp.y,minp.y,-1 do
						local n = data[a:index(x, y, z)]
						if n ~= c_air and n ~= c_ignore then
							ground_y = y
							break
						end
					end
				
					if ground_y then --and ground_y > min_height then

						-- Snowy biome stuff
						local node = a:index(x, ground_y, z)
						local abovenode = a:index(x, ground_y+1, z)
						local belownode = a:index(x, ground_y+2, z)

						if ground_y and data[node] == c_dirt_with_grass then
								--local veg
								--if legacy and mossy and pr:next(1,10) == 1 then veg = 1 end
								if alpine and test > 0.53 then
									--Gets rid of dirt
									data[abovenode] = c_snow
									for y=ground_y,-6,-1 do
										local stone = a:index(x, y, z)
										if data[stone] ==  c_stone then
											break
										else
											data[stone] = c_stone
										end
									end
								elseif (shrubs and pr:next(1,28) == 1) then
									--Spawns dry shrubs.
									data[node] = c_dirt_with_snow
									data[abovenode] = c_dry_shrub
								elseif pines and pr:next(1,36) == 1 then
									--Spawns pines.
									data[node] = c_dirt_with_snow
									spawn_pine({x=x, y=ground_y+1, z=z},a,data)
								elseif snowy then
									--Spawns snow blocks.
									data[abovenode] = c_snow_block
								else
									--Spawns snow.
									data[node] = c_dirt_with_snow
									data[abovenode] = c_snow
								end
						elseif ground_y and data[belownode] == c_sand then
							--Spawns ice in sand if icy, otherwise spawns snow on top.
							if not icy then
								data[node] = c_snow
							else
								data[belownode] = c_ice
							end
						elseif ground_y and data[node] == c_leaves or data[node] == c_jungleleaves or data[node] == c_apple then
							if alpine then
								--Gets rid of dirt
								data[abovenode] = c_snow
								for y=ground_y,-6,-1 do
									local stone = a:index(x, y, z)
									if data[stone] ==  c_stone then
										break
									else
										data[stone] = c_stone
									end
								end
							else
								data[abovenode] = c_snow
							end
						elseif ground_y and data[node] == c_junglegrass then
							data[node] = c_dry_shrub
						elseif ground_y and data[node] == c_papyrus then
							for i=ground_y, ground_y-4, -1 do
								local papyrus = a:index(x, y, z)
								if data[papyrus] == c_papyrus then
									local papyrusabove = a:index(x, ground_y, z)
									data[papyrusabove] = c_snow
									data[papyrus] = c_snow_block
								end
							end
						elseif ground_y and data[node] == c_water then
							if not icesheet and not icecave and not icehole then
								--Coastal ice.
								local x1 = data[a:index(x+1,ground_y,z)]
								local z1 = data[a:index(x,ground_y,z+1)]
								local xz1 = data[a:index(x+1,ground_y,z+1)]
								local xz2 = data[a:index(x-1,ground_y,z-1)]
								local x2 = data[a:index(x-1,ground_y,z)]
								local z2 = data[a:index(x,ground_y,z-1)]
								local y = data[a:index(x,ground_y-1,z)]
								local rand = pr:next(1,4) == 1
								if
								((x1  and x1 ~= c_water  and x1 ~= c_ice and x1 ~= c_air and x1 ~= c_ignore) or ((cool or icebergs) and x1 == c_ice and rand)) or
								((z1  and z1 ~= c_water  and z1 ~= c_ice  and z1 ~= c_air and z1 ~= c_ignore) or ((cool or icebergs) and z1 == c_ice  and rand)) or
								((xz1 and xz1 ~= c_water and xz1 ~= c_ice and xz1 ~= c_air and xz1 ~= c_ignore) or ((cool or icebergs) and xz1 == c_ice and rand)) or
								((xz2 and xz2 ~= c_water and xz2 ~= c_ice and xz2 ~= c_air and xz2 ~= c_ignore) or ((cool or icebergs) and xz2 == c_ice and rand)) or
								((x2  and x2 ~= c_water  and x2 ~= c_ice  and x2 ~= c_air and x2 ~= c_ignore) or ((cool or icebergs) and x2 == c_ice and rand)) or
								((z2  and z2 ~= c_water  and z2 ~= c_ice and z2 ~= c_air and z2 ~= c_ignore) or ((cool or icebergs) and z2 == c_ice and rand)) or
								(y ~= c_water and y ~= c_ice and y ~= "air") or (pr:next(1,6) == 1 and icebergs) then
										data[node] = c_ice
								end
							else
								--Icesheets, Broken icesheet, Icecaves
								if (icehole and pr:next(1,10) > 1) or icecave or icesheet then
									data[node] = c_ice
								end
								if icecave then
									--Gets rid of water underneath ice
									for y=ground_y-1,-60,-1 do
										local water = a:index(x, y, z)
										if data[water] ~= c_water then
											break
										else
											data[water] = c_air
										end
									end
								end
							end
						end
					
					end
				--end
			
			end
		end
		end
		
		if write_to_map then
			vm:set_data(data)
	   
			vm:calc_lighting(
					{x=minp.x-16, y=minp.y, z=minp.z-16},
					{x=maxp.x+16, y=maxp.y, z=maxp.z+16}
			)

			vm:write_to_map(data)
			vm:update_map()

		
			if debug then
				biome_string,biome2_string = biomeToString(biome,biome2)
				print(biome_string.." and "..biome2_string..": Snow Biome Genarated near x"..minp.x.." z"..minp.z)
				print(string.format("elapsed time: %.2fms", (os.clock() - t1) * 1000))
			end
		end
	--end
end)
