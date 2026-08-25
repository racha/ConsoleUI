---
layout: page
title: Mouse Look
description: Lock the camera for controller play, unlock with right-click, and keep extra window unlocks optional.
permalink: /features/mouse-look/
last_reviewed: 2026-08-25
---

Mouse Look hides the cursor and lets mouse or right-stick movement turn the camera without holding right mouse. It is optional. The Standard Steam layout keeps it off and uses stick-move → top-left cursor + held right-click instead.

## Enable

1. Apply the [MouseLOCK mapper layout]({{ '/controller/steam-mouselock/' | relative_url }}) if you want walk to start look.
2. Open `/cui` → **Mouse**.
3. Enable **Enable Mouse Look System**.

## Lock Mouse On

| Setting | Default | What it does |
| --- | --- | --- |
| Starting to move | On | Lets **Mouse Lock Start (Mapper)** — F9 beside WASD — lock look |
| Casting spells / actions | On | Locks when a ConsoleUI action binding casts or uses an action |

`/cui look` and the **Mouse Lock Toggle** binding work whenever the system is enabled, even if those checkboxes are off.

## Unlock Mouse On

**Right mouse button** is the only automatic unlock on by default. Everything else starts off:

- Double-tap Shift / Ctrl
- Escape menu
- Bags
- World map
- Character / inspect
- Spellbook
- Talents / skills
- Quests / gossip
- Social / groups
- Vendors / bank / trade
- Professions / trainers
- Other interface windows

Turn a group on only if you want that window to release the cursor.

## Bindings

In WoW Key Bindings → ConsoleUI Mouse:

| Binding | Role |
| --- | --- |
| Mouse Lock | Start look |
| Mouse Unlock | Stop look |
| Mouse Lock Toggle | Toggle, same as `/cui look` |
| Mouse Lock (Hold) / Mouse Unlock (Hold) | Hold variants |
| Mouse Lock Start (Mapper) | Hidden. Receives F9 from the MouseLOCK layout |

## Camera

Invert X, invert Y, and mouse speed live on the same page. Speed range is `0.05` to `4`.

<aside class="callout callout-warning">
  <p class="callout-label">Warning</p>
  <p>While look is locked, touch bars and phone taps cannot hit UI. Unlock with R3 / right-click first, then tap again.</p>
</aside>

## Limitations

- Left click is Blizzard targeting and UI. It does not start or stop Mouse Look.
- Do not bind L3 to held left-mouse for camera.
- Do not add Steam commands for jump or casts. Use ConsoleUI bindings.

If look never starts, confirm F9 is an additional WASD command and Mouse Look is on. If it never lets go, press R3 and check that right-click unlock is still enabled.
