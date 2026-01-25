local snow_nodes = {
	snow    = { "ice_brick", "snow_brick", "snow_cobble" },
	default = { "ice", "snowblock" }
}

if minetest.get_modpath("moreblocks") and
	 minetest.global_exists("stairsplus") then

	for mod, nodes in pairs(snow_nodes) do
		for _, name in pairs(nodes) do
			local nodename = mod .. ":" .. name
			local ndef = table.copy(minetest.registered_nodes[nodename])
			ndef.sunlight_propagates = true
			ndef.groups.melts = 2
			ndef.groups.icemaker = nil
			ndef.groups.cooks_into_ice = nil
			ndef.after_place_node = nil
			if string.find(name, "ice") then
				ndef.use_texture_alpha = "blend"
			else
				ndef.use_texture_alpha = "opaque"
			end
			local mod_namespace = mod
			if mod == "default" then
				-- moreblocks registers stairsplus nodes for default:ice with
				-- moreblocks: prefix and no nodes for default:snowblock.
				-- To follow its convention, we (re-)register default:
				-- stairsplus nodes with moreblocks: prefix.
				mod_namespace = "moreblocks"
			end
			stairsplus:register_all(mod_namespace, name, nodename, ndef)
		end
	end

	-- moreblocks doesn't register snowblock stairsplus nodes, so we need to
	-- unregister the corresponding stairs nodes using aliases ourselves.
	minetest.register_alias_force("stairs:stair_snowblock",
		"moreblocks:stair_snowblock")
	minetest.register_alias_force("stairs:stair_outer_snowblock",
		"moreblocks:stair_snowblock_outer")
	minetest.register_alias_force("stairs:stair_inner_snowblock",
		"moreblocks:stair_snowblock_inner")
	minetest.register_alias_force("stairs:slab_snowblock",
		"moreblocks:slab_snowblock")

	-- Alias stairs: nodes to snow: nodes.
	-- This is needed for users converting from MTG stairs to stairsplus.
	for _, name in ipairs(snow_nodes.snow) do
		minetest.register_alias("stairs:stair_" .. name, "snow:stair_" .. name)
		minetest.register_alias("stairs:stair_outer_" .. name,
			"snow:stair_" .. name .. "_outer")
		minetest.register_alias("stairs:stair_inner_" .. name,
			"snow:stair_" .. name .. "_inner")
		minetest.register_alias("stairs:slab_"  .. name, "snow:slab_"  .. name)
	end

elseif minetest.global_exists("stairs") then -- simple stairs and slabs only

	local stair_prefixes = {"stairs:slab_", "stairs:stair_",
		"stairs:stair_inner_", "stairs:stair_outer_"}
	for i = 1, #stair_prefixes do
		local nodename = stair_prefixes[i] .. "ice"
		local groups = table.copy(minetest.registered_nodes[nodename].groups)
		-- melt probably does nothing but default:ice also has it
		groups.melt = 1
		groups.melts = 2
		minetest.override_item(nodename, {
			groups = groups,
			sunlight_propagates = true,
			tiles = {
				{
					align_style = "world",
					backface_culling = true,
					name = "snow_ice.png^[brighten",
				},
			},
			use_texture_alpha = "blend",
		})

		nodename = stair_prefixes[i] .. "snowblock"
		groups = table.copy(minetest.registered_nodes[nodename].groups)
		groups.melts = 2
		groups.falling_node = 1
		minetest.override_item(nodename, {
			groups = groups
		})
	end

	for _, name in pairs(snow_nodes.snow) do
		local nodename = "snow:" .. name
		local ndef = table.copy(minetest.registered_nodes[nodename])

		local desc_stair = ndef.description .. " Stair"
		local desc_slab  = ndef.description .. " Slab"
		local images = ndef.tiles
		local sounds = ndef.sounds

		local groups = ndef.groups
		groups.melts = 2
		groups.icemaker = nil
		groups.cooks_into_ice = nil

		stairs.register_stair_and_slab(name, nodename,
			groups, images, desc_stair, desc_slab, sounds)

		-- Add transparency if used (ice_brick).
		minetest.override_item("stairs:stair_" .. name,
			{use_texture_alpha = ndef.use_texture_alpha})
		minetest.override_item("stairs:slab_"  .. name,
			{use_texture_alpha = ndef.use_texture_alpha})

		-- Alias all stairs and slabs from snow to the stairs namespace.
		minetest.register_alias("snow:stair_" .. name, "stairs:stair_" .. name)
		minetest.register_alias("snow:slab_"  .. name, "stairs:slab_"  .. name)
	end
end
