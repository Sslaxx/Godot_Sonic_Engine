# The player scene, nodes and script(s)

## Overview

The player is a scene which has a root node of the type `KinematicBody2D` which is to be named `Player`. As a `KinematicBody2D` it has access to a wide variety of functions like `is_on_floor` and `move_and_slide`.

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
- Player speed affectors for things like water, speed shoes etc
- The state machine (used by all characters, so custom states need to be added to this as required)

Default values only should be in `player_generic.gd`. Speeds/heights etc. should be in pixels per second.

## Nodes used by the player scene

All physics bodies need a collision shape of some type; what works best depends on your project. All player characters use `AnimatedSprite` to deal with sprites and their animations; every sprite has animations common to them and these must be given the same names across different player characters. Players need a custom `Camera2D` in order to allow scrolling to work; levels can adjust this node as necessary for them to scroll correctly.

## Physics

Wherever possible the default collision functions should be used - `is_on_floor` and the like. Look at gotchas about these functions - for example, it sounds like `is_on_floor` and its relations can only be used if the player is moving (not particularly surprising if so as a lot of other physics-based functionality has the same restriction) - and try to find (actually working) workarounds, and to stick within limitations which cannot be worked around (or find ways to use them to your advantage if feasible).

## Movement and speed

Movement is controlled overall by the movement state, which is a bitmask determining how and why the character can move. The movement state and direction will dictate how the speed is worked out.

## Animations

Wherever possible animation names should be the same across playable characters (or non-playable characters) for ease of scripting.

The character's moving animation will change depending on how fast they're going.

## Life and Death

Death is implemented via a sprite node with a Z-index of 99 that has its animation taken from the player character's death animation (relevant to how the player character was killed). The camera is locked in position and the HUD hidden, the animation plays (from the player's position to off-screen). Then, either time over or game over happens if necessary. If game over happens the game is restarted. Otherwise, the player is reset to the last good checkpoint position (by the last checkpoint passed), control is given back, and the game resumes.
