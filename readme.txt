   _____                       __  __           _ 
  / ____|                     |  \/  |         | |
 | (___  _ __   _____      __ | \  / | ___   __| |
  \___ \| '_ \ / _ \ \ /\ / / | |\/| |/ _ \ / _` |
  ____) | | | | (_) \ V  V /  | |  | | (_) | (_| |
 |_____/|_| |_|\___/ \_/\_/   |_|  |_|\___/ \__,_|
  
By Splizard.

Forum post: http://minetest.net/forum/viewtopic.php?id=2290
Github: https://github.com/Splizard/minetest-mod-snow

INSTALL:
----------
Place this folder in your minetest mods folder.
(http://dev.minetest.net/Installing_Mods)

NOTICE
While this mod is installed you may experience slow map loading while a snow biome is generated.

USAGE:
-------
If you walk around a bit you will find snow biomes scattered around the world.

There are nine biome types:
* Normal
* Icebergs
* Icesheet
* Broken icesheet
* Icecave
* Coast
* Alpine
* Snowy
* Plain
  
Snow can be picked up and thrown as snowballs or crafted into snow blocks.
Snow and ice melts when near warm blocks such as torches or igniters such as lava.
Snow blocks freeze water source blocks around them.
Moss can be found in the snow, when moss is placed near cobble it spreads.
Christmas trees can be found when digging pine needles.

CRAFTING:
-----------
Snow Block:

Snowball    Snowball
Snowball    Snowball

Snow Brick:

Snow Block    Snow Block
Snow Block    Snow Block

MAPGEN_V7:
------------
If you are using minetest 0.4.8 or the latest dev version of minetest you can choose to generate a v7 map.
This option can be found when creating a new map from the menu.
Snow Biomes has support for this and includes a base grass biome for this.
There are a couple of bugs and limitations with this such as no ice being generated at the moment.

Config file:
------------
After starting a game in minetest with snow mod, a config file will be placed in this folder that contains the various options for snow mod.

UNINSTALL:
------------
Simply delete the folder snow from the mods folder.
