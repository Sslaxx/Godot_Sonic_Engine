# PLAYER MOVEMENT - how to handle it

## How it works

Velocity and speed should be separate. Velocity (the amount of directional speed the player travels at) is determined by Speed. The direction of the speed is controlled by movement. -1 is left/up (x, y), 0 is none, 1 is down/right.

Movement direction is handled by:

1: `moving_in` - string variable holding a value about which direction has been pressed. `moving_in = ("left" if Input.is_action_pressed ("move_left") else ("right" if Input.is_action_pressed ("move_right") else "nil"))`

2: relevant state is set for which direction, movement direction value `movement_direction` is set to the appropriate value (if it isn't already set to the opposite value that is). `enum MovementState` `player_state`

3: so long as `moving_in` is not nil, increase acceleration `player_speed`.

4: if `moving_in` is nil for any reason, decelerate. If `movement_direction` is different from the movement state, decelerate.

5: if stopped, and the movement state is different from `movement_direction`, change `movement_direction` to reflect the movement state and start to accelerate. Unless `moving_in` is nil *and* the player is on a floor surface, in which case set `movement_direction` to 0 and movement state to `STATE_IDLE` instead.

6: speed is positive only - direction is handled by `movement_direction` (i.e., it has values from -1 to 1). This *should* eliminate the need for abs checks; the only time the direction vector needs to be used should be `move_and_slide`. Ultimately, velocity on the x-axis should be set to speed ala `velocity.x = player_speed * movement_direction`

7: jumping is handled differently, so a move line should ultimately be like: `velocity = move_and_slide (velocity)[...])`

## What complicates this?

Complexity is added if different characters with different abilities are playable. A flying character, for example, would need to take into account time in air (if flying) and flight speed; a character that could climb walls would need additional wall/ceiling/floor detection when wall-climbing and gliding and separate states for these.

There may well be corner cases/situations that are not immediately obvious.
