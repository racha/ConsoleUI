---
layout: page
title: Action bars and layouts
description: Controller, Flat, and Full layouts, modifier pages, stance, and pet bars.
permalink: /features/action-bars/
last_reviewed: 2026-08-25
---

ConsoleUI shows twelve on-screen controls. Ten of them are actions: face `1–4`, D-pad `5–8`, RB `9`, and RT `0`. LT and LB are modifier chrome only. They never get their own action slots.

## When to use it

Use Action Bars whenever you want spells and items on the pad. Change the layout if you prefer pointed diamonds, compact squares, or all three modifier clusters at once.

## Enable and choose a layout

Open `/cui` → **Action Bars**.

- **Controller** — pointed diamond clusters that match a physical pad.
- **Flat** — two rows of squares.
- **Full** — three complete pointed clusters so default, LT, and LB pages stay visible.

Hold LT, LB, or both to reach the other pages. The [mapping table]({{ '/controller/mapping-reference/' | relative_url }}) lists the keys.

Scale is a layout multiplier. Dragging unlocked bars saves the center offset. Combat locks drag.

## Stance and pet

Vanilla never shows both at once.

- Stance appears when the client reports shapeshift or stance forms.
- Pet appears when `PetHasActionBar()` is true.

The addon does not invent a fake always-on stance or pet bar. Stance and pet have their own ConsoleUI bindings. They do not steal `1–0`.

## Limitations

- Gold rings on diamonds follow the HUD gold-border checkbox.
- Empty side-bar slots can look dimmer than main slots. That is the only fill-alpha exception.
- Do not run a second controller-bar addon on the same slots.

Layout screenshots from the same scene will land after Capture Batch D. Until then, use the live `/cui` → Action Bars page as the source of truth.
