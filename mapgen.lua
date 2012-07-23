--Snow biomes are found at 0.53 and greater perlin noise.
minetest.register_on_generated(function(minp, maxp, seed)
if maxp.y >= -10 then
		local debug = snow.debug

		--Choose a biome type.
		local pr = PseudoRandom(seed+57)
		local biome = pr:next(1, 10)
		local icebergs = biome == 2
		local icesheet = biome == 3
		local cool = biome > 9   --only spawns ice on edge of water
		local icecave = biome == 5
		local icehole = biome == 6 --icesheet with holes

		--Misc biome settings.
		local icy = pr:next(1, 2) == 2   --If enabled spawns ice in sand instead of snow blocks.
		local mossy = pr:next(1,2) == 1  --Spawns moss in snow.
		local shrubs = pr:next(1,2) == 1 --Spawns dry shrubs in snow.

		-- Assume X and Z lengths are equal
		local divlen = 16
		local divs = (maxp.x-minp.x);
		local x0 = minp.x
		local z0 = minp.z
		local x1 = maxp.x
		local z1 = maxp.z

		--Should make things a bit faster.
		local env = minetest.env

		--Debugging function
		local biomeToString = function(num)
			if num == 1 or num == 7 or num == 8 or num == 4 then return "normal"
			elseif num == 2 then return "icebergs"
			elseif num == 3 then return "icesheet"
			elseif num == 5 then return "icecave"
			elseif num == 9 or num == 10 then return "cool"
			elseif num == 6 then return "icehole"
			else return "unknown "..num end
		end

		--Get map specific perlin
		local perlin1 = env:get_perlin(112,3, 0.5, 150)
		pr = PseudoRandom(seed+68)

		--Speed hack: checks the corners and middle of the chunk for "snow biome".
		if not (perlin1:get2d({x=x0, y=z0}) > 0.53) and not (perlin1:get2d({x=x1, y=z1}) > 0.53)
		and not (perlin1:get2d({x=x0, y=z1}) > 0.53) and not (perlin1:get2d({x=x1, y=z0}) > 0.53)
		and not (perlin1:get2d({x=(x1-x0)/2, y=(z1-z0)/2}) > 0.53) then
			if debug then print(biomeToString(biome)..": ABORTED!") end
			return
		end

		--Loop through chunk.
		for j=0,divs do
		for i=0,divs do

			local x = x0+i
			local z = z0+j

			--Check if we are in a "Snow biome"
			local test = perlin1:get2d({x=x, y=z})
			if test > 0.53 then

				-- Find ground level (0...15)
				local ground_y = nil
				for y=maxp.y,0,-1 do
					if env:get_node({x=x,y=y,z=z}).name ~= "air" then
						ground_y = y
						break
					end
				end

				-- Snowy biome stuff
				local node = env:get_node({x=x,y=ground_y,z=z})

				if ground_y and node.name == "default:dirt_with_grass" then
						if shrubs and pr:next(1,28) == 1 then
							--Spawns dry shrubs.
							env:add_node({x=x,y=ground_y,z=z}, {name="snow:dirt_with_snow"})
							env:add_node({x=x,y=ground_y+1,z=z}, {name="default:dry_shrub"})
						elseif mossy and pr:next(1,10) == 1 then
							--Spawns moss inside snow.
							env:add_node({x=x,y=ground_y,z=z}, {name="snow:dirt_with_snow"})
							env:add_node({x=x,y=ground_y+1,z=z}, {name="snow:snow",param2=1})
						else
							--Spawns snow.
							env:add_node({x=x,y=ground_y,z=z}, {name="snow:dirt_with_snow"})
							env:add_node({x=x,y=ground_y+1,z=z}, {name="snow:snow"})
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
				elseif ground_y and node.name == "default:desert_sand" then
					--Abort genaration.
					if debug then
						print(biomeToString(biome)..": ABORTED!")
					end
					return
				end
			end
		end
		end
		if debug then
			print(biomeToString(biome)..": Snow Biome Genarated")
		end
end
end
)