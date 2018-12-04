# Checkpoints

## Overview

Normally used for if the player character goes past one, then gets killed and reset to the checkpoint position. Also used for the starting position of a level. Usually `Area2D`; like collectibles, checkpoints should not affect player movement or physics in any way. The root node of a checkpoint should be called `Checkpoint`.

## How they work

The player passes by a checkpoint object, and a reference to the checkpoint is stored in a variable (`last_checkpoint`); it's up to any developer(s) if the checkpoint stores any other information. Should the player character be killed, after the death animation a function is called on *the checkpoint* that resets the player character's position to its location and resumes player control.

When starting a level, at the beginning there should be an invisible checkpoint `start_checkpoint`, on initialisation of the level's script it will make sure the player character is set to its position.
