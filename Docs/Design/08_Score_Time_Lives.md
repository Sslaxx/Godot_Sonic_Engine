# Score, time and lives

## Overview

Sonic and similar games are pretty arcade-like in having a score and lives system. Time can also play an important part (like in Sonic games where each level has a ten minute time limit before losing a life).

There are basic score, items, lives and time variables in `game_space.gd`. These should provide, hopefully, the basis of something more expansive if needed. These use timers, getters and setters to make them work.

## The HUD

The HUD `hud_layer` should show the information about score/time/lives etc. It may also display some information about items collected as need be, e.g. for shields or invincibility.

## Time

Time is stored in a `Vector2` called `Level_Time` (with x representing minutes, y seconds). `game_space.gd` has an attached timer called, simply, `Timer`, set to repeat every second. Every time it does, it advances the `Level_Time` variable. How this affects the game beyond showing the player how long they've been in a level is up to any developer(s).

## Score

Score gives the player an indication of how well they're doing - the higher the score the better.

## Lives

Basically, how many chances the player has to get through the game before it ends. Lives can be affected by many things.
