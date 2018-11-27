# Godot Sonic Engine
## Sonic-feeling 2D platformer engine
### Stuart \"Sslaxx\" Moore
#### 27th November 2018

## Game Analysis

This isn\'t a game; it\'s an engine/framework on which to build games from. By design, games that are Sonic-like. It is intended to allow at the very least play as a Sonic-type game through multiple 2D levels.

## Mission Statement

Create a good, solid base for 2D platformers that are styled after the classic Megadrive Sonic games, that can be extended in any way the developer is able to, with minimal (or preferably no) external dependencies (such as those of GDNative/C\#) and can be as cross-platform as Godot supports.

## Genre

Whatever the developer(s) want.

## Platforms

The engine is written in Godot, so depending on the author\'s wishes:
- Windows
- macOS
- Linux
- Android
- iOS
- Consoles (with specific limitations and difficulties such as getting a publisher etc)

## Target Audience

The engine\'s target audience is anyone with at least basic experience with Godot.

## Overview of Gameplay

As it stands, the basic gameplay will be very Sonic-esque: run through levels, collecting items, destroying enemies, completing any special stages etc.

## Player Experience

Player experience and expectations are up to the developer(s) of any game made using this code to manage.

## Gameplay Guidelines

In terms of content and its audience, this again is up to the developer(s) of any game made using this code to manage.

## Game Objectives & Rewards

This is up to the developer(s) of any game made using this code to decide how to represent.

## Gameplay Mechanics

The basic mechanics of the game engine are designed to be reminiscent of classic Megadrive Sonic platformers. How the mechanics of the game are built beyond that basic fact is for the developer(s) to decide.

This starts with **characters** and their **attributes**; the engine will include a default (Sonic), but beyond that is the call of the developer(s). **Game modes** can be arcade-style, or story, or anything else the developer(s) want (e.g., time attacks). Ditto the **scoring system**.

The engine code isn\'t designed to *dis*allow anything, because it's bare bones beyond having a basic lives/time/score/collectibles system; it\'s up to the developer(s) to have sufficient knowledge and experience to implement features in a way they want, in a way that\'ll fit with everything else.

## Level Design

The basic design for levels (zones) places them in two acts, one after the other, in the same level (ala Sonic 3/K). Levels should be able to tell the engine what will happen, what music will play, and so on during normal (basic) gameplay.

## Control Scheme

The default control setup of the engine uses the cursor keys and a/s/d for jump/action. This is hopefully self-explanatory. Anything beyond this of course, as has been said many times in this document already, is the perview of the developer(s).

## Game Aesthetics & User Interface

The engine is basic, so should not inhibit any design techniques to be used, look & shape of the characters, environment and pathways.

In-game UI should be minimal; at the least a Sonic-style HUD (score/time/items and lives displayed, nothing else) for normal play.

Any UI (both in-game and menus and the like) is up to the imagination of the developer(s) and artist(s) in terms of looks, functionality and use.
