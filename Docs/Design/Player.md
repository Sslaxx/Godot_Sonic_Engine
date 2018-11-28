# The player scene, nodes and script(s)

## Overview

The player is a scene which has a root node of the type `KinematicBody2D`. It should be named `Player`. As a `KinematicBody2D` it has access to a wide variety of functions like `is_on_floor` and `move_and_slide`.

## Scripts and inheritance

Player scenes have a script which inherits from `player_generic.gd`, which in turn inherits `KinematicBody2D`.

The scripting inheritance structure should be `your_player_script.gd` -> `player_generic.gd` -> `KinematicBody2D`.

The `player_generic.gd` script contains all the physics values and functions that will allow the character to function; it will act on the state values given. The `your_player_script.gd` should contain those values that need adjusting for a specific character, and any character-specific functions. How the functions would work is an excersize left to the developer(s). As a physics item most processing should be done within `_physics_process` (or functions called from within it); input should be (mostly) handled by `_input`.

## Values defined by player_generic.gd/custom player character scripts

These should include:
- Maximum speed
- Rate of acceleration
- Rate of deceleration (not by braking)
- Rate of braking deceleration
- Angle of jump
- Maximum jump height
- Maximum jump speed
- Friction values
- Player velocity, movement states etc
- The state machine (used by all characters, so custom states need to be added to this as required)

Default values only should be in `player_generic.gd`. Speeds/heights etc. should be in pixels per second.

## Nodes used by the player scene.

All physics bodies need a collision shape of some type; what works best depends on your project. All player characters use `AnimatedSprite` to deal with sprites and their animations; every sprite has animations common to them and these must be given the same names across different player characters. Players need a custom `Camera2D` in order to allow scrolling to work; levels can adjust this node as necessary for them to scroll correctly.
