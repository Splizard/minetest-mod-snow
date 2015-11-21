--Global config and function table.
snow = {
	snowball_gravity = 100/109,
	snowball_velocity = 19,
	sleds = true,
	enable_snowfall = true,
	lighter_snowfall = false,
	debug = false,
	smooth_biomes = true,
	christmas_content = true,
	smooth_snow = true,
	min_height = 3,
	mapgen_rarity = 18,
	mapgen_size = 210,
}

--Config documentation.
local doc = {
	snowball_gravity = "The gravity of thrown snowballs",
	snowball_velocity = "How fast players throw snowballs",
	sleds = "Disable this to prevent sleds from being riden.",
	enable_snowfall = "Enables falling snow.",
	lighter_snowfall = "Reduces the amount of resources and fps used by snowfall.",
	debug = "Enables debug output. Currently it only prints mgv6 info.",
	smooth_biomes = "Enables smooth transition of biomes (mgv6)",
	smooth_snow = "Disable this to stop snow from being smoothed.",
	christmas_content = "Disable this to remove christmas saplings from being found.",
	min_height = "The minumum height a snow biome will generate (mgv7)",
	mapgen_rarity = "mapgen rarity in %",
	mapgen_size = "size of the generated… (has an effect to the rarity, too)",
}

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

local allowed_types = {string = true, number = true, boolean = true}

--Manage config.
--Saves contents of config to file.
local function saveConfig(path, config, doc)
	local file = io.open(path,"w")
	if not file then
		minetest.log("error", "[snow] could not open config file for writing at "..path)
		return
	end
	for i,v in pairs(config) do
		if allowed_types[type(v)] then
			if doc and doc[i] then
				file:write("# "..doc[i].."\n")
			end
			file:write(i.." = "..tostring(v).."\n")
		end
	end
	file:close()
end
--Loads config and returns config values inside table.
local function loadConfig(path)
	local file = io.open(path,"r")
  	if not file then
 		--Create config file.
		return
	end
	io.close(file)
 	local config = {}
	for line in io.lines(path) do
		if line:sub(1,1) ~= "#" then
			local i, v = line:match("^(%S*) = (%S*)")
			if i and v then
				config[i] = value_from_string(v)
			end
		end
	end
	return config
end

local modpath = minetest.get_modpath("snow")

minetest.register_on_shutdown(function()
	saveConfig(modpath.."/config.txt", snow, doc)
end)

local config = loadConfig(modpath.."/config.txt")
if config then
	for i,v in pairs(config) do
		if type(snow[i]) == type(v) then
			snow[i] = v
		else
			minetest.log("error", "[snow] wrong type of setting "..i)
		end
	end
else
	saveConfig(modpath.."/config.txt", snow, doc)
end

for i,v in pairs(snow) do
	if allowed_types[type(v)] then
		local v = minetest.setting_get("snow_"..i)
		if v ~= nil then
			snow[i] = value_from_string(v)
		end
	end
end


--MENU

local function get_formspec()
	local p = -0.5
	local formspec = "label[0,-0.3;Settings:]"
	for i,v in pairs(snow) do
		local t = type(v)
		if t == "string"
		or t == "number" then
			p = p + 1.5
			formspec = formspec.."field[0.3,"..p..";2,1;snow:"..i..";"..i..";"..v.."]"
		elseif t == "boolean" then
			p = p + 0.5
			formspec = formspec.."checkbox[0,"..p..";snow:"..i..";"..i..";"..tostring(v).."]"
		end
	end
	p = p + 1
	formspec = "size[4,"..p..";]\n"..formspec
	return formspec
end

minetest.register_chatcommand("snow", {
	description = "Show a menu for various actions",
	privs = {server=true},
	func = function(name)
		minetest.chat_send_player(name, "Showing snow menu…")
		minetest.show_formspec(name, "snow:menu", get_formspec())
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "snow:menu" then
		return
	end
	for i,v in pairs(snow) do
		local t = type(v)
		if allowed_types[t] then
			local field = fields["snow:"..i]
			if field then
				if t == "string" then
					snow[i] = field
				elseif t == "number" then
					local valid_number = tonumber(field)
					if valid_number then
						snow[i] = valid_number
					end
				elseif t == "boolean" then
					if field == "true" then
						snow[i] = true
					elseif field == "false" then
						snow[i] = false
					end
				end
			end
		end
	end
end)
