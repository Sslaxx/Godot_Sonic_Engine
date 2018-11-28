# Levels and their structure

## Overview

A "level" consists of an act. It is self-contained; that is, within a single level a single act (i.e., a single scene) ala Sonic 1/2. That said, if a developer wants to organise things differently - say a "level" being one entire zone ala 3/K - they're free to do so.

## Level inheritance and scripting.

Levels (as in the scenes) do not inherit anything, but there is a `level_generic.gd` which contains basic functionality all levels will use; this should be inherited by the script you make for the level.

The scripting inheritance structure should be `your_level_script.gd` -> `level_generic.gd` -> `Node2D`.

The level's scripting should handle things like playing the music, custom events and the like. The `level_generic.gd` script should handle checkpoints, starting and ending a level, etc.

## Nodes of a level

A level's root node is a `Node2D`, called `Level`. The level script that controls events, items etc. pertinent to that level is attached to the root node. The script - and the `level_generic.gd` script it inherits from - initialises the player instance in the level, sets it to the start position etc. The scripts will look for, refer to and use the Level node as `/root/Level` and its subnodes from there. **The root node must be Node2D as this is what the scripting will expect!**

The level data is within the `Tilemap`. This is the tileset and how it's used to construct the level.

`checkpoint_position` is used for restarting the player from a checkpoint if they die; it's also used to indicate the starting position of a level.

It's a good idea to create the background for a level - it's backdrop and parallax - as a separate scene and instantiate that within the level; makes it easier to reuse them.

`hud_layer` is used for the HUD layer (which is normally 32). For debugging, `debug_hud_layer` is on layer 99.

For everything else it's a good idea to organise it via groups of some description.

**Remember to set the layers/Z-order for everything as needed!**

Once a player character is instantiated - it *must* be as `/root/Level/Player` - it's nodes (such as camera settings) can be adjusted as required to the level's needs.
