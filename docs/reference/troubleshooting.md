---
layout: page
title: Troubleshooting
description: Fix the common controller, camera, movement, touch, and overlay problems.
permalink: /reference/troubleshooting/
last_reviewed: 2026-08-25
---

## Controller does nothing

Launch through Steam or the mapper. Enable Steam Input. Apply the matching Standard or MouseLOCK layout. Enable both addon folders. Press `1` on the keyboard. If that diamond fires, the addon is fine and the mapper is not reaching WoW.

## Character cannot move

Close Quick Menu and the keyboard with B. Test W. `/reload` once if the overlay bind leaked. If a protected-action popup appears, do not spam Ignore — note the first error and run `/cui debug`.

## Camera will not lock

Confirm the MouseLOCK layout, F9 as an additional WASD command, and **Enable Mouse Look System**. `/cui look` should still toggle. L3 must not be held left-mouse.

## Camera will not unlock

Press R3 / right-click. Confirm **Right mouse button** is still checked under Unlock Mouse On.

## Touch does not click

Unlock Mouse Look first. Touch cannot hit UI while the client holds the cursor.

## Quick Menu only moves vertically

Check whether A/D are Turn or Strafe. The binds must match what the mapper sends.

## Keyboard does not open

Enable `ConsoleUIKeyboard` at character selection. `/cuik on`. Open a fresh chat line.

## Bindings look wrong after a copy

Copy From reports unresolved slots. Different-class copies warn. Check the restore report before overwriting again.

## Report a bug

Include client, addon version, mapper/layout, exact steps, first red error, a screenshot, and `/cui test` output. Remove private names, paths, and chat before posting. Open an issue at [github.com/racha/ConsoleUI/issues]({{ site.data.project.issues }}).
