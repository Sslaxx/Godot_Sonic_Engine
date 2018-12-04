# Levels and their structure

## Overview

A "level" consists of an act. It is self-contained; that is, within a single level a single act (i.e., a single scene in Godot) ala Sonic 1/2.

That said, if a developer wants to organise things differently - say a "level" being one entire zone ala 3/K - they're free to do so, but how they do so is up to them.

## Level inheritance and scripting.

The level scenes themselves do not inherit anything, but there is a `level_generic.gd` script which contains basic functionality all levels will use, which inherits from `Node2D`; this should be inherited by the script you make for the level.

The scripting inheritance structure should be `your_level_script.gd` -> `level_generic.gd` -> `Node2D`.

The level's scripting should handle things like playing the music, custom events and the like. The `level_generic.gd` script should handle checkpoints, starting and ending a level, etc.

## Nodes of a level

A level's root node is a `Node2D`, called `Level`. The level script that controls events, items etc. pertinent to that level is attached to the root node. The script - and the `level_generic.gd` script it inherits from - initialises the player instance and the HUDs in the level, sets it to the start position etc. The scripts will look for, refer to and use the Level node as `/root/Level` and its subnodes from there. **The root node must be Node2D as this is what the scripting will expect!**

The level data is within the `Tilemap`. This is the tileset and how it's used to construct the level.

`last_checkpoint` is a reference to the last checkpoint a player passed by and is used to reset the player's position to it if they die; it's also used to indicate the starting position of a level.

For everything else it's a good idea to organise it via groups of some description (both using Node2Ds for grouping and Godot's group functions).

Once a player character is instantiated - it *must* be as `/root/Level/Player` - its nodes (such as camera settings) can be adjusted as required to the level's needs.

## Layers of a level (aka Z-index)

It's a good idea to create the background for a level - it's backdrop and parallax - as a separate scene and instantiate that within the level; makes it easier to reuse them.

Assuming a range of layers to be used from -32 to 32:
- and the backdrop proper (the overall background image) -8;
- the parallax for the backdrop (clouds, buildings and the like) -4 to -7;
- the level backdrop (the tiles and other parts that make up a level) should be layers -1 to -3;
- the player, collectibles and enemies are on layer 0;
- foreground elements are layers 1 to 8.

`hud_layer` is used for the HUD layer (which is normally 32). For debugging, `debug_hud_layer` is on layer 99.

**Remember to set the layers/Z-index for everything as needed!**

## Beginning and ending levels

Mostly this is up to the developer(s). A rudimentary system is here for reference.

A level *starts* in `STATE_CUTSCENE` for long enough for a test act card to be shown, then begins.

When the end-level item is passed:
- The camera locks in position.
- `STATE_CUTSCENE` is enabled.
- Once any animation the end-level item has completed ends, display the "you win this level" bit.
- Calculate scores, bonuses here etc.
- Anything else before...
- ...Changing level (or whatever).