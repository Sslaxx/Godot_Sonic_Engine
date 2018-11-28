# Hostiles and other bad things

## Overview

"Hostiles" can mean the bad guys the player has to fight against during the game. It can also mean environmental hazards, such as spikes or water that may either damage or kill the player character (immediately or over a period of time) or affect their speed.

### Enemies (bad guys, bosses etc)

Most enemies, like the player, will be based on `KinematicBody2D`. As such, most enemies will inherit from `generic_enemy.gd`, which in turn inherits from `KinematicBody2D`.

`enemy_name.gd` -> `generic_enemy.gd` -> `KinematicBody2D`

Some enemies may have multiple components - rising spikes, or firing bullets. Some enemies may self-destruct, firing projectiles in different directions. Other enemies may do completely different things, or only be vulnerable at certain times or at certain spots. How these are implemented is on the developer(s) of any game. Enemies will need more things coded for them - the only values `generic_enemy.gd` will have are exported variables for score value and number of hits they can take. But things like rising spikes can be handled by discrete sub-objects using an animation. Bullets, projectiles will need to take into account angles they're being "fired" from.

### Environmental hazards (water, spikes, pits etc)

Spikes and pits can be easier to code relatively speaking - both can just react to the player's colliding with their collision shapes. Hazards like water may be more difficult. A simple way to code water is to make it lethal upon entry. But most Sonic-type games have water be a hazard over time - after a certain point the player character will drown. For spikes or pits, `Area2D` and/or `StaticBody2D` may be most useful.

Some environmental hazards will have fullscreen effects, like water, and may also affect the player's movement speed.
