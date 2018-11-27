# Generic (character-independent) states

## STATE_IDLE (0)

Not really a state, per se. This is an absence of state or player input. Player character is not necessarily on the ground so any checks using this state need to take this into account.

## STATE_MOVE_LEFT (1) / STATE_MOVE_RIGHT (2)

See the [player movement](Player_movement.md) document for more info.

## STATE_JUMPING (4)

The player jumping in the direction the character is moving in. Height is determined by how long the jump button is pressed; speed is determined by how fast the player is moving.

## STATE_CROUCHING (8)

The player character will crouch/squat when looking down (holding down the down movement button). Normally player movement is not possible while crouching, but spinning is possible .

## STATE_SPINNING (16)

If the player is crouching down and presses the jump button, they'll start to spin (ala Sonic 1/2/etc). The more it's pressed, the more momentum is built up (up to a maximum) ready for release. When jump is released the player will burst forward at the speed of (maximum speed plus momentum), gradually decelerating over time, in the direction that the player is facing in or the movement button being held down (the button takes precedence).

## STATE_CUTSCENE (32)

No player control is available during a cutscene; if the player character is to move etc. it should be handled by the relevant scene's script (be that a level or something else).
