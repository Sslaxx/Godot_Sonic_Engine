# Godot Sonic Engine
## Sonic-feeling 2D platformer engine
### Stuart "Sslaxx" Moore
#### 27th November 2018

# OVERVIEW

## In general

This isn't a game; it's an engine/framework on which to build games from using [Godot](https://godotengine.org/). By design, games that are Sonic-like. It is intended to allow at the very least play as a Sonic-type game through multiple 2D levels. Developers should document the things for their game; this is just the design docs for the framework. It's intended to function as a good, solid base for 2D platformers that are styled after the classic Megadrive Sonic games, that can be extended in any way the developer is able to, with minimal (or preferably no) external dependencies (such as those of GDNative/C#) and can be as cross-platform as Godot supports.

## Platform support

The engine is written in Godot, so depending on the author's wishes the following may be supported:
- Windows
- macOS
- Linux
- Android
- iOS
- Consoles (with specific limitations and difficulties such as getting a publisher etc)

## Gameplay Mechanics

The basic mechanics of the game engine are designed to be reminiscent of classic Megadrive Sonic platformers. How the mechanics of the game are built beyond that basic fact is for the developer(s) to decide.

This starts with **characters** and their **attributes**; the engine will include a default (Sonic), but beyond that is the call of the developer(s). **Game modes** can be arcade-style, or story, or anything else the developer(s) want (e.g., time attacks). Ditto the **scoring system**.

The engine code isn't designed to *dis*allow anything, because it's bare bones beyond having a basic lives/time/score/collectibles system; it's up to the developer(s) to have sufficient knowledge and experience to implement features in a way they want, in a way that'll fit with everything else.

## Level Design

The basic design for levels defines them as discrete acts (ala Sonic 1/2). Levels should be able to tell the engine what will happen, what music will play, and so on during normal (basic) gameplay. Developer(s) will need to implement scripted events, music and so on in levels in a way that suits them.

## Control Scheme

The default control setup of the engine uses the cursor keys and a/s/d for jump/action. This is hopefully self-explanatory. Anything beyond this of course, as has been said many times in this document already, is the perview of the developer(s).

## Game Aesthetics & User Interface

The engine is basic, so should not inhibit any design techniques to be used, look & shape of the characters, environment and pathways.

In-game UI should be minimal; at the least a Sonic-style HUD (score/time/items and lives displayed, nothing else) for normal play.

Any other UI (both in-game and menus and the like) is up to the imagination of the developer(s) and artist(s) in terms of looks, functionality and use. This engine won't have any examples.

# THE UI AND HUD

## The in-game HUD

The root node of the HUD scene is a `CanvasLayer` called `hud_layer`, with a selection of sprites and labels for score/time/lives/collectibles; some of these sprites are animated (so can flash as a warning for example; "default" for normal and "warning" for the obvious). The layer for it is 32 (normally). The HUD could also be made to display some information about items collected as need be, e.g. for shields or invincibility.

`game_space.gd` has a function called `update_hud` which in turn calls the function `hud_layer_update` (should the HUD node exist in the scene tree) which updates the HUD items as necessary.

## The debugging HUD

This HUD is called `debug_hud_layer`, used for displaying debug information during game play. It is only instantiated by `level_generic.gd` if `OS.is_debug_build` returns true.

# LEVELS AND THEIR STRUCTURE

## In general

A "level" consists of an act. It is self-contained; that is, within a single level a single act (i.e., a single scene in Godot) ala Sonic 1/2.

That said, if a developer wants to organise things differently - say a "level" being one entire zone ala 3/K - they're free to do so, but how they do so is up to them.

## Level inheritance and scripting.

The level scenes themselves do not inherit anything, but there is a `level_generic.gd` script which contains basic functionality all levels will use, which inherits from `Node2D`; this should be inherited by the script you make for the level.

The scripting inheritance structure should be:
`your_level_script.gd` -> `level_generic.gd` -> `Node2D`.

The level's scripting should handle things like playing the music, custom events and the like. The `level_generic.gd` script should handle checkpoints, starting and ending a level, etc.

## Nodes of a level

A level's root node is a `Node2D`, called `Level`. The level script that controls events, items etc. pertinent to that level is attached to the root node. The script - and the `level_generic.gd` script it inherits from - initialises the player instance and the HUDs in the level, sets it to the start position etc. The scripts will look for, refer to and use the Level node as `/root/Level` and its subnodes from there. **The root node must be Node2D as this is what the scripting will expect!**

The level data is within the `Tilemap`. This is the tileset and how it's used to construct the level.

`last_checkpoint` is a reference to the last checkpoint a player passed by and is used to reset the player's position to it if they die; it's also used to indicate the starting position of a level.

A level should have a `Camera2D` node. This is normally unused - the player scene's own `Camera2D` node takes precedence - but can be used for cutscenes etc.

For everything else it's a good idea to organise it via groups of some description (both using Node2Ds for grouping and Godot's group functions).

Once a player character is instantiated - it *must* be as `/root/Level/Player` - its nodes (such as camera settings) can be adjusted as required to the level's needs.

## Layers and Z-index of a level

It's a good idea to create the background for a level - it's backdrop and parallax - as a separate scene and instantiate that within the level; makes it easier to reuse them.

Assuming Z-index is ranged from -32 to 32:
- the backdrop proper (the overall background image) -8;
- the parallax for the backdrop (clouds, buildings and the like) -4 to -7;
- the level backdrop (the tiles and other parts that make up a level) should be -1 to -3;
- the level scene itself, player, collectibles and enemies are on 0;
- foreground elements are 1 to 8.

The `CanvasLayer` that `hud_layer` uses normally has its layer set to 32. For debugging, `debug_hud_layer` is on layer 99.

**Remember to set the layers/Z-index for everything as needed!**

## Beginning and ending levels

Mostly this is up to the developer(s). A rudimentary system is here for reference.

A level *starts* in `STATE_CUTSCENE` for long enough for a test act card to be shown, then begins.

When the end-level item is passed:
- The camera locks in position.
- `STATE_CUTSCENE` is enabled.
- Once any animations for the end-level end, display the "you win this level" bit.
- Calculate appropriate scores, bonuses here etc.
- Anything else before...
- ...Changing level (or whatever).

# SCORE, TIME, LIVES

## In general

Sonic and similar games are pretty arcade-like in having a score and lives system. Time can also play an important part (like in Sonic games where each level has a ten minute time limit before losing a life).

There are basic score, items, lives and time variables in `game_space.gd`. These should provide, hopefully, the basis of something more expansive if needed. These use timers, getters and setters to make them work (setters will perform whatever animations are required, update the HUD etc).

## Time

Time is stored in a `Vector2` called `level_time` (with x representing minutes, y seconds). `game_space.gd` has an attached timer called, simply, `Timer`, set to repeat every second. Every time it does, it advances the `level_time` variable. How this affects the game beyond showing the player how long they've been in a level is up to any developer(s). Sonic games have a ten minute limit for their levels.

## Score

Score gives the player an indication of how well they're doing - the higher the score the better.

## Lives

Basically, how many chances the player has to get through the game before it ends. Lives can be affected by many things - obvious ones being extra life bonuses or being killed by hazards/hostiles.

# THE PLAYER; SCENE, NODES AND SCRIPT(S)

## Scene structure and functionality

The player is a scene which has a root node of the type `KinematicBody2D` which is to be named `Player`. As a `KinematicBody2D` it has access to a wide variety of functions like `is_on_floor` and `move_and_slide`.

### Scripts and inheritance

Player scenes have a script which inherits from `player_generic.gd`, which in turn inherits `KinematicBody2D`.

The scripting inheritance structure should be:
`your_player_script.gd` -> `player_generic.gd` -> `KinematicBody2D`.

The `player_generic.gd` script contains all the physics values and functions that will allow the character to function; it will act on the state values given. The `your_player_script.gd` should contain those values that need adjusting for a specific character, and any character-specific functions. How the functions would work is an excersize left to the developer(s). As a physics item most processing should be done within `_physics_process` (or functions called from within it); input should be (mostly) handled by `_input`.

### Determining who the player character is

`game_space.gd` has a global variable `player_character` which is set by the `_ready` function of `your_player_script.gd` to point to the scene in question.

### Values defined by player_generic.gd/custom player character scripts

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

Default values only should be in `player_generic.gd`. Speeds/heights etc. should normally be in pixels per second.

### Camera

The player scene has a `Camera2D` node which allows the level to scroll with the player. It's `limit_` settings should be adjusted by whatever level the player is in to fit the boundaries of the level.

### Physics

Wherever possible the default collision functions should be used - `is_on_floor` and the like. Look at gotchas about these functions - for example, it sounds like `is_on_floor` and its relations can only be used if the player is moving (not particularly surprising if so as a lot of other physics-based functionality has the same restriction) - and try to find (actually working) workarounds, and to stick within limitations which cannot be worked around (or find ways to use them to your advantage if feasible).

All physics bodies need a collision shape of some type; what works best depends on your project. Multiple collision shapes may also be necessary.

### Movement and speed

Movement is controlled overall by the movement state, which is a bitmask determining how and why the character can move. The movement state and direction will dictate how the speed is worked out. The movement state is the direction the player *is going to move in*; the movement direction variable the direction the player *is currently moving in*. All speed variables are measured by pixels per second.

### Animations

All player characters use `AnimatedSprite` to deal with sprites and their animations; every sprite has animations common to them and these must be given the same names across different player characters.

The character's moving animation will change depending on how fast they're going, and what animation is playing should ultimately be controlled by player state.

### Life and Death

Death is implemented via a sprite node with a Z-index of 99 that has its animation taken from the player character's death animation (relevant to how the player character was killed). The camera is locked in position and the HUD hidden, the animation plays (from the player's position to off-screen). Then, either time over or game over happens if necessary. If game over happens the game is restarted. Otherwise, the player is reset to the last good checkpoint position (by the last checkpoint passed), control is given back, and the game resumes.

## Player movement in general

### How it works

Velocity and speed should be separate. Velocity (the amount of directional speed the player travels at) is determined by Speed. The direction of the speed is controlled by movement. -1 is left/up (x, y), 0 is none, 1 is down/right.

Movement direction is handled by:

1: `moving_in` - string variable holding a value about which direction has been pressed. `moving_in = ("left" if Input.is_action_pressed ("move_left") else ("right" if Input.is_action_pressed ("move_right") else "nil"))`

2: relevant state is set for which direction, movement direction value `movement_direction` is set to the appropriate value (if it isn't already set to the opposite value that is). `enum MovementState` `player_state`

3: so long as `moving_in` is not nil, increase acceleration `player_speed` up to the maximum `maximum_player_speed`.

4: if `moving_in` is nil for any reason, decelerate using `decelerate_no_movement_rate`. If `movement_direction` is different from the movement state, decelerate using `decelerate_rate`.

5: if stopped, and the movement state is different from `movement_direction`, change `movement_direction` to reflect the movement state and start to accelerate. Unless `moving_in` is nil *and* the player is on a floor surface, in which case set `movement_direction` to 0 and movement state to `STATE_IDLE` instead.

6: speed is positive only - direction is handled by `movement_direction` (i.e., it has values from -1 to 1). Ultimately, velocity on the x-axis should be set ala `velocity.x = player_speed * movement_direction`

7: The move line should ultimately be like: `velocity = move_and_slide (velocity, floor_normal[...])`

### What complicates this?

Complexity is added if different characters with different abilities are playable. A flying character, for example, would need to take into account time in air (if flying) and flight speed; a character that could climb walls would need additional wall/ceiling/floor detection when wall-climbing and gliding and separate states for these.

There may well be corner cases/situations that are not immediately obvious.

## Jumping

### How it works:

1: `jump_held` is a variable that is true so long as the key for jumping is held down. The first time it is held down `STATE_JUMPING` is added to `player_state` to signify to the state machine logic that the play is jumping.

2: So long as `jump_held` is true, `jump_amount` is increased by `jump_adding`, up until the maximum jump height for the character `jump_max`.

3: Once jump has been released and `jump_held` is false, begin the jump. `jump_direction` is set to -1 and the player's y position is affected by `jump_speed`, until it reaches `jump_amount`. Then `jump_direction` is set to 1 and the player falls.

## Generic player states

### In general

These are the basic states that are used by the code, as bitmask values, to control characters. Custom states - for example, character-specific states, e.g. `STATE_KNUCKLES_GLIDING` - should be documented by whoever is developing the game.

#### STATE_IDLE (0)

Not really a state, per se. This is an absence of state or player input. Player character is not necessarily on the ground so any checks using this state need to take this into account.

#### STATE_MOVE_LEFT (1) / STATE_MOVE_RIGHT (2)

See the section on player movement document for more info.

#### STATE_JUMPING (4)

The player jumping in the direction the character is moving in. Height is determined by how long the jump button is pressed; speed is determined by how fast the player is moving.

#### STATE_CROUCHING (8)

The player character will crouch/squat when looking down (holding down the down movement button). Normally player movement is not possible while crouching, but spinning is possible .

#### STATE_SPINNING (16)

If the player is crouching down and presses the jump button, they'll start to spin (ala Sonic 1/2/etc). The more it's pressed, the more momentum is built up (up to a maximum) ready for release. When jump is released the player will burst forward at the speed of (maximum speed plus momentum), gradually decelerating over time, in the direction that the player is facing in or the movement button being held down (the button takes precedence).

#### STATE_CUTSCENE (32)

No player control is available during a cutscene; if the player character is to move etc. it should be handled by the relevant scene's script (be that a level or something else).

# COLLECTIBLES, POWER-UPS

## In general

Most Sonic-type games have one type of collectible that counts towards an extra life (typically 1 life per 100 collected). They usually don't immediately add to the score, but are often added up at the end (how many the player has). They are usually lost (but some might be re-collectible) after collision with something that harms the player; Sonic games will kill the player character if they are hit without any rings.

## Collectibles

Collectibles should have at least exportable variable that defines its points value. Beyond that is up to any developers. They should also not (usually) impact on physics - that is, they do not slow the player down on impact or the like. They should be `Area2D`s.

Collectibles are kept check of by two variables, `collectibles` and `collectibles_lives`. The latter variable is used to keep track of how many items towards the next life bonus the player has collected. By default the player is not aware of what this variable's value is.

## Powerups

Powerups (or downs) are (at least in Sonic type games) usually items that are destroyed (ala Badniks) to give either a temporary or permanent power-up (sometimes down) to the player character, or extra lives or collectibles. This means that (usually) they would be `KinematicBody2D` shapes. Temporary power-ups should use a related timer node created in `game_space.gd`; for example invincibility may use a timer called `Invincibility_Timer`.

# HOSTILES (ENVIRONMENT AND ENEMIES)

## In general

"Hostiles" can mean the bad guys the player has to fight against during the game. It can also mean environmental hazards, such as spikes or water that may either damage or kill the player character (immediately or over a period of time) and/or affect their speed.

## Enemies (bad guys, bosses etc)

Most enemies, like the player, will be based on `KinematicBody2D`. As such, most enemies will inherit from `generic_enemy.gd`, which in turn inherits from `KinematicBody2D`.

`enemy_name.gd` -> `generic_enemy.gd` -> `KinematicBody2D`

Some enemies may have multiple components - rising spikes, or firing bullets. Some enemies may self-destruct, firing projectiles in different directions. Other enemies may do completely different things, or only be vulnerable at certain times or at certain spots. How these are implemented is on the developer(s) of any game. Enemies will need more things coded for them - the only values `generic_enemy.gd` will have are exported variables for score value and number of hits they can take. But things like rising spikes can be handled by discrete sub-objects using an animation. Bullets, projectiles will need to take into account the angles they're being "fired" from.

## Environmental hazards (water, spikes, pits etc)

Spikes and pits can be easier to code relatively speaking - both can just react to the player's colliding with their collision shapes. Hazards like water may be more difficult. A simple way to code water is to make it lethal upon entry. But most Sonic-type games have water be a hazard over time - after a certain point the player character will drown. For spikes or pits, `Area2D` and/or `StaticBody2D` may be most useful.

Some environmental hazards will have fullscreen effects, like water, and may also affect the player's movement speed.

# CHECKPOINTS

## In general

Normally used for if the player character goes past one, then gets killed and reset to the checkpoint position. Also used for the starting position of a level. Usually `Area2D`; like collectibles, checkpoints should not affect player movement or physics in any way. The root node of a checkpoint should be called `Checkpoint`.

## How they work

The player passes by a checkpoint object (once only), and a reference to that checkpoint is stored in a variable in `game_space` (`last_checkpoint`); it's up to any developer(s) if the checkpoint stores any other information. Should the player character be killed, after the death animation a function `return_to_checkpoint` is called on the checkpoint that resets the player character's position to its location and resumes player control.

At the beginning of the level there should be an invisible checkpoint `start_checkpoint`, on initialisation of the level's script it will make sure the player character is set to its position.
