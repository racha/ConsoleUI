---
layout: page
title: Visual language
description: Chrome numbers ConsoleUI already uses. Copy them. Do not invent a fourth gold or a Lua-drawn rounded rect.
permalink: /development/visual-language/
last_reviewed: 2026-08-25
---

Lua + TGA are the spec. If in-game does not match these numbers, the Lua is wrong. Source: `actionbars/layout.lua`, `radial/radial.lua`, `radial/rings.lua`, `ConsoleUIKeyboard/Core/Charset.lua`.

This page is for **patches inside ConsoleUI**. Other addons should not restyle ConsoleUI chrome.

## Tokens

| Token | Value |
| --- | --- |
| Gold | `{1.00, 0.82, 0.18}` |
| Black fill | `{0, 0, 0}` alpha **1** |
| White (pressed / current) | `{1, 1, 1}` on plate + inner rim |
| Idle slice label | `{0.93, 0.93, 0.93}` |
| Selected slice label | `{0.07, 0.07, 0.07}` |

`SetVertexColor` is rgb. Alpha is `SetAlpha`. Never `SetAlpha` < 1 on a diamond or square **fill**. Empty side-bar slots may drop plate alpha to `0.5` — that is the only exception.

1.12 has no `MaskTexture`. Shape is TGA alpha. Power-of-2 files. Replace-in-place TGA is cached — new pixels need a **new filename**.

Do not tint `UI-Tooltip-Background` gold. Dark stock tex × gold = beige. Use `textures/hud/White.tga` or the Key* TGA.

## Diamonds (controller, face clusters)

`Layout.HIT` **56**. Face step `Layout.INNER` **33**.

Three layers on one button. Do not invent a fourth chrome file. Do not draw rounded rects in Lua.

| Layer | Texture | Inset | Job |
| --- | --- | --- | --- |
| Plate | `KeyN` / `W` / `S` / `E` | `-5 / +5` (`PLATE` 5) | Solid black (white when active) |
| Rim | `KeyHiIn` | `RIM_IN` 0 | Thin inner edge |
| Ring | `KeyHiN` / `W` / `S` / `E` | `-6 / +6` (`GOLD_OUT` 6) | Gold outline. Hide when `barGoldBorder` is off |

Icon clip is **SliceMask**: 16 horizontal strips. Clip size `HIT - ICON_IN*2` → **42** at default 56 (`ICON_IN` 7). Spell/item crop `0.08..0.92`. Custom glyphs `0,1`.

Pip (ABXY / D-pad) `22×22` on the inner edge. `barActionGlyphs` hides ABXY + D-pad only. LB/LT/RB/RT stay.

Parent textures paint **under** children. Chrome that must sit on the icon lives on `diamondChrome`, then raise it.

## Squares (flat layout, stance, pet)

Same three layers, `KeySq` / `KeyHiSq` / `KeyHiSqIn`. **No SliceMask.**

Icon is one texture, `HIT - 14` → **42** on a 56, **118** on the pet hub (`PET_HUB` 132). `SQUARE_GAP` **8**. `SquareStep(56)` = `56+12+8` = **76**. Pet spell gap `PET_SQUARE_GAP` **2**.

Stance hides unless `GetNumShapeshiftForms() > 0`. Pet hides unless `PetHasActionBar()`. No ABXY pips on stance/pet.

## Rings (Quick Menu, user rings, keyboard chrome)

All three rings share one chrome. Do not change sizes on one ring and not the others.

| Piece | Size | File | Color / alpha |
| --- | --- | --- | --- |
| Frame | `520×520`, `CENTER` | — | Keyboard **host** is `240×240`; chrome textures stay 452/456/164 |
| Donut | 452 | `Donut.tga` | `0.12,0.12,0.12` alpha **0.75** (donut only) |
| Outer gold | 456 | `Ring.tga` | Gold alpha `0.90` |
| Inner gold | 164 | `Inner.tga` | Gold alpha `0.90` |
| Stick radius | **154** | — | — |
| Slice highlight | 452 | `SliceN.tga` | White `0.92` selected / `0` idle |
| Separators | 452 | `Separators.tga` | White `0.95` |

8 slices. Mids `90, 45, 0, 315, 270, 225, 180, 135` (TOP first, clockwise). Chat keyboard has **no** slices/separators.

Slice icon `36×36`, crop `0.08..0.92`. Label `GameFontNormal` under the icon.

Diamond cluster (chat + Quick Menu center): hitbox `56×56`, offset **33**. Fill `KeyN/W/S/E` alpha **1**. Gold `KeyHi*` on when that cluster is selected (Quick Menu center gold always on).

Do not swap center-cluster icons (chat Y/X/A/B and Quick Menu menu/reload/confirm/back). No `|T...|t` in FontStrings. No ABXY pips on Quick Menu center.

User rings: same chrome + slice icons. No face diamonds. Item count badge `CountBadge.tga` `16×16` on the 36 icon.

## HUD bars

Cast: 6px gold strip, 1px black rim, name + time **under** the strip. XP/Rep: `WatchRim.tga` / `WatchFillShade.tga`, crop the fill, gray ticks. Do not put cast fill on the host frame. Details live in the HUD player page and `castbar/castbar.lua` / `xpbar/xpbar.lua`.

## Scale

Bar scale is a **layout multiplier** baked into size and padding (`Layout.ApplyScale`). Do not `SetScale` the main diamonds — `SetPoint` stays in unscaled pixels and buttons overlap or float.

Stance/pet sliders default **1.0**. Visual size uses `STANCE_BASE` **0.8** and `PET_BASE` **0.6** via `host:SetScale(user * BASE)`. Changing the slider must not move the center.

## Do not

- Mix `KeyN` chrome with square icons, or `KeySq` with SliceMask
- Change chrome insets on one surface and not the others
- Use `hasArrow` dropdowns or steal `SHIFT-ESCAPE`
- Invent a new gold, hit size, or rounded-rect draw
