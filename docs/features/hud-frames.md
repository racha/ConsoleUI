---
layout: page
title: HUD and Frames
description: XP, reputation, cast, swing timer, loot, hint bar, minimap, auras, and unit-frame scale and offset.
permalink: /features/hud-frames/
last_reviewed: 2026-08-25
---

## HUD

Open `/cui` → **HUD** for XP, reputation, cast, swing timer, loot, and the hint bar.

- XP and reputation use the watch-bar art. Hidden bars come back for real progress, not for a quiet data refresh.
- Cast is a thin gold strip with the spell name and time under it.
- Swing Timer tracks main-hand and off-hand melee swings on linked bars. Ranged weapons use one bar split into Draw, Shoot, and Cooldown segments; an interrupted draw flashes red and a fired shot flashes white.
- Swing Timer settings control width, height, bar gap, position, color, spark, each weapon label, timer label, and combat-only fade. Main-hand and off-hand positions move together.
- Loot and group rolls can stay on ConsoleUI or return to Blizzard.
- The hint bar names A/B/X/Y for the current cursor node.

## Frames

Open `/cui` → **Frames** for Minimap, Buffs/Debuffs, Player/Pet, Target, Party, and Party Pet. Each group has scale and offset. Saved keys stay stable across updates.

Unlock bars and frames in `/cui` before dragging. Combat locks drag. Positions save as a center offset.
