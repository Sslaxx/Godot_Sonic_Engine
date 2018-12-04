# Collectibles and Power-ups

## Overview

Most Sonic-type games have one type of collectible that counts towards an extra life (typically 1 life per 100 collected). They usually don't immediately add to the score, but are often added up at the end (how many the player has). They are usually lost (but some might be re-collectible) after collision with something that harms the player; Sonic games will kill the player character if they are hit without any rings.

### Collectibles

Collectibles should have at least exportable variable that defines its points value. Beyond that is up to any developers. They should also not (usually) impact on physics - that is, they do not slow the player down on impact or the like. They should be `Area2D`s.

### Powerups

Powerups (or downs) are (at least in Sonic type games) usually items that are destroyed (ala Badniks) to give either a temporary or permanent power-up (sometimes down) to the player character, or extra lives or collectibles. This means that (usually) they would be `KinematicBody2D` shapes. Temporary power-ups use a related timer node in `game_space.gd`; for example invincibility may use a timer called `Invincibility_Timer`.