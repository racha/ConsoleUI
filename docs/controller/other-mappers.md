---
layout: page
title: Other mapper software
description: Mapper-agnostic outputs ConsoleUI needs when you are not using the official Steam layouts.
permalink: /controller/other-mappers/
last_reviewed: 2026-08-25
---

Any mapper can work if it emits the same keyboard and mouse signals. ConsoleUI cannot repair a mapper that sends different keys or eats the mouse.

## Required outputs

| Controller | Output |
| --- | --- |
| A / X / Y / B | `1` / `2` / `3` / `4` |
| D-pad Down / Left / Up / Right | `5` / `6` / `7` / `8` |
| RB / RT | `9` / `0` |
| LT / LB | Shift / Ctrl |
| Left stick | W/A/S/D |
| Right stick | Mouse movement |
| Start / Back | Escape / M |
| R3 | Right mouse click |

For MouseLOCK behavior, add F9 **alongside** W/A/S/D and let the hidden **Mouse Lock Start (Mapper)** binding receive it. Do not add mapper actions for jump or spell casts.

## Standard vs MouseLOCK on a generic mapper

- **Standard:** on any right-stick move, park the cursor in the top-left and hold right-click so WoW treats the stick as camera look. `/cui` → Mouse Look is off. Do not use “hold R3 to look.”
- **MouseLOCK:** right stick is still mouse movement. WASD also emits F9. R3 clicks right mouse to unlock. `/cui` → Mouse Look is on. L3 must not be held left-mouse for camera.

## About WoWpadX and reWASD

Those tools can supply the same table. Application-specific click paths are not documented here until a current version has been tested. Treat any third-party tutorial as an example, not a ConsoleUI requirement.

If a mapper consumes the mouse or injects extra clicks on look, start with [Troubleshooting]({{ '/reference/troubleshooting/' | relative_url }}).
