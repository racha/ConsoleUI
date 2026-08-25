---
layout: page
title: Bindings
description: Assign Base, LT, LB, and LT+LB pages, place spells, and keep touch assignments when a bar is hidden.
permalink: /features/bindings/
last_reviewed: 2026-08-25
---

Open `/cui` → **Bindings**. The page selector switches Base, LT, LB, and LT+LB. Select a controller button, then pick the WoW or ConsoleUI action it should run.

## When to use it

Use Bindings to change what a face button, D-pad direction, bumper, trigger, or touch slot does. Use WoW’s Key Bindings screen for named ConsoleUI actions such as Quick Menu, Rings, and Mouse Lock.

## Spell placement

The Bindings workspace includes spell placement. Drop a spell or item onto a slot, or use the Clear control on that slot. X can also clear when the prompt says so.

## Touch assignments

Touch slots are assigned here, not deleted when you hide a side bar. Reducing button count or turning a side off must keep the stored actions for when you show the bar again.

## Mouse actions

Mouse Lock, Mouse Unlock, and Mouse Lock Toggle can be assigned to face buttons, D-pad, bumpers, triggers, modifier pages, or touch actions. The Hold variants stay in WoW’s ConsoleUI Mouse category.

## Limitations

- Do not bind a Ring to the same B input you use to cancel. B cannot cancel that Ring.
- Overlay binds used by Quick Menu and the keyboard must never be saved. ConsoleUI restores movement first.
- Jump and similar protected actions on touch slots are filtered when they are unsafe.

If a button does nothing, check the matching `1–0` WoW bind before editing ConsoleUI.
