--Global config and function table.
snow = {
	legacy = true,
	enable_snowfall = true,
	lighter_snowfall = false,
	debug = false,
	smooth_biomes = true,
	christmas_content = true,
	smooth_snow = true,
	min_height = 3,
}

--Config documentation.
local doc = {
	legacy = "Whether you are running a legacy minetest version (auto-detected).",
	enable_snowfall = "Enables falling snow.",
	lighter_snowfall = "Reduces the amount of resources and fps used by snowfall.",
	debug = "Enables debug output.",
	smooth_biomes = "Enables smooth transition of biomes",
	christmas_content = "Disable this to remove christmas saplings from being found.",
	smooth_snow = "Disable this to stop snow from being smoothed.",
	min_height = "The minumum height a snow biome will generate.",
}

--Manage config.
--Saves contents of config to file.
local function saveConfig(path, config, doc)
	local file = io.open(path,"w")
	if file then
		for i,v in pairs(config) do
			local t = type(v)
			if t == "string" or t == "number" or t == "boolean" then
				if doc and doc[i] then
					file:write("# "..doc[i].."\n")
				end
				file:write(i.." = "..tostring(v).."\n")
			end
		end
	end
end
--Loads config and returns config values inside table.
local function loadConfig(path)
	local config = {}
	local file = io.open(path,"r")
  	if file then
  		io.close(file)
		for line in io.lines(path) do
			if line:sub(1,1) ~= "#" then
				i, v = line:match("^(%S*) = (%S*)")
				if i and v then
					if v == "true" then v = true end
					if v == "false" then v = false end
					if tonumber(v) then v = tonumber(v) end
					config[i] = v
				end
			end
		end
		return config
	else
		--Create config file.
		return nil
	end
end

minetest.register_on_shutdown(function() saveConfig(minetest.get_modpath("snow").."/config.txt", snow, doc) end)

local config = loadConfig(minetest.get_modpath("snow").."/config.txt")
if config then
	for i,v in pairs(config) do
		snow[i] = v
	end
else
	saveConfig(minetest.get_modpath("snow").."/config.txt", snow, doc)
end

for i,v in pairs(snow) do
	local t = type(v)
	if t == "string" or t == "number" or t == "boolean" then
		local v = minetest.setting_get("snow_"..i)
		if v ~= nil then
			if v == "true" then v = true end
			if v == "false" then v = false end
			if tonumber(v) then v = tonumber(v) end
			snow[i] = v
		end
	end
end

--AUTO DETECT and/or OVERIDEN values--

--legacy--
--Detect if we are running the latest minetest.
if minetest.register_on_mapgen_init and minetest.get_heat and minetest.get_humidity then
	snow.legacy = false
else
	snow.legacy = true
end
if config and snow.legacy ~= config.legacy then
	saveConfig(minetest.get_modpath("snow").."/config.txt", snow, doc)
end
