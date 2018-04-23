--Global config and function table.
snow = {
	snowball_gravity = tonumber(minetest.settings:get("snowball_gravity")) or 0.91,
	snowball_velocity = tonumber(minetest.settings:get("snowball_velocity")) or 19,
	sleds = minetest.settings:get_bool("sleds"),
	enable_snowfall = minetest.settings:get_bool("enable_snowfall"),
	lighter_snowfall = minetest.settings:get_bool("lighter_snowfall"),
	debug = minetest.settings:get_bool("debug"),
	smooth_biomes = minetest.settings:get_bool("smooth_biomes"),
	christmas_content = minetest.settings:get_bool("christmas_content"),
	smooth_snow = minetest.settings:get_bool("smooth_snow"),
	min_height = tonumber(minetest.settings:get("min_height")) or 3,
	mapgen_rarity = tonumber(minetest.settings:get("mapgen_rarity")) or 18,
	mapgen_size = tonumber(minetest.settings:get("mapgen_size")) or 210,
	disable_mapgen =  minetest.settings:get_bool("disable_mapgen"),
}

if snow.sleds == nil then
	snow.sleds = true
end

if snow.debug == nil then
	snow.debug = false
end

if snow.disable_mapgen == nil then
	snow.disable_mapgen = true
end

if snow.enable_snowfall == nil then
	snow.enable_snowfall = true
end

-- functions for dynamically changing settings

local on_configurings,n = {},1
function snow.register_on_configuring(func)
	on_configurings[n] = func
	n = n+1
end

local function change_setting(name, value)
	if snow[name] == value then
		return
	end
	for i = 1,n-1 do
		if on_configurings[i](name, value) == false then
			return
		end
	end
	snow[name] = value
end


local function value_from_string(v)
	if v == "true" then
		v = true
	elseif v == "false" then
		v = false
	else
		local a_number = tonumber(v)
		if a_number then
			v = a_number
		end
	end
	return v
end
