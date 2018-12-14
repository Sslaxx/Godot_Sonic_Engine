# The template structure

Most of the template is covered in [the project structure document](Structure.txt). Won't cover how they work - they're fairly sufficiently documented to hopefully make it obvious. This covers the most basic stuff already in the template and what it's for, including `Scripts\System` `Scenes\System`.

## colour_space

Convenience `Node` script containing a list of colours and their RGB values.

## dice_engine

A `Node` script allowing random numbers to be generated as if they were "rolled" by dice.

## game_space

This `Node` is used for game(play) related variables (anything from scores, lives etc. up), settings (unrelated to application settings, so things like difficulty level would be kept here) and so on.

## global_space

A `Node` script, for non-game(play) related settings (resolution, detail, volume etc). Contains convenience functions for creating and switching to scenes and a function to run code only once.

## jingle_player/music_player/sound_player

These are all using `AudioStreamPlayer`. Jingles are non-looped (usually short) pieces of music. Music is obvious, and sounds are looped sounds (ambient) or non-looped. They're set up to use the respective audio buses. Should cover most basic cases between them.

## Assets/Graphics/Fonts/Roboto-Regular.ttf

Just used as a default font for the UI theme.

## Assets/UI/Default.tres

Used as a default UI/HUD theme for the game.
