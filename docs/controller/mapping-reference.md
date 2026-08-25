---
layout: page
title: Mapping reference
description: Shared controller-to-key table, modifier pages, and A/D Turn versus Strafe.
permalink: /controller/mapping-reference/
last_reviewed: 2026-08-25
---

Steam or another mapper owns these base keys. ConsoleUI paints diamonds on top of them and adds named addon actions in WoW’s Key Bindings.

| Controller | Output | Role |
| --- | --- | --- |
| A / X / Y / B | `1` / `2` / `3` / `4` | Face action slots |
| D-pad Down / Left / Up / Right | `5` / `6` / `7` / `8` | D-pad action slots |
| RB / RT | `9` / `0` | Extra action slots |
| LT / LB | Shift / Ctrl | Modifier pages |
| Left stick | W/A/S/D | Movement |
| Right stick | Mouse | Standard: move parks cursor top-left and holds right-click for look. MouseLOCK: mouse movement while look is locked |
| Start / Back | Escape / M | Game menu / map |
| R3 | Right mouse | MouseLOCK unlock. Not “hold to look” on Standard |

## Four action pages

| Held | Keys |
| --- | --- |
| Nothing | `1–0` |
| LT | `SHIFT-1` … `SHIFT-0` |
| LB | `CTRL-1` … `CTRL-0` |
| LT + LB | `CTRL-SHIFT-1` … `CTRL-SHIFT-0` |

LT and LB are modifier chrome, not extra action slots.

## Standard vs MouseLOCK deltas

| | Standard | MouseLOCK |
| --- | --- | --- |
| F9 on WASD | No | Yes, additional command |
| Mouse Look | Off | On |
| Right stick | Move → cursor to top-left + hold right-click | Mouse movement only |
| R3 | Not the look button | Click to unlock |
| L3 | Optional; do not hold left-mouse for camera if you later enable Mouse Look | Do not hold left-mouse for camera |

## A/D Turn vs Strafe

Vanilla defaults bind A/D to Turn Left/Right. On a pad that often feels wrong because the right stick already turns the camera. Bind A/D to Strafe Left/Right for a typical controller move stick.

ConsoleUI Quick Menu and Rings read both Turn and Strafe. You are not required to change A/D, but strafe is the recommended feel.

## Conflicts

If a diamond does nothing, check the matching `1–0` bind in WoW before changing ConsoleUI. If WASD dies after Quick Menu or the keyboard, press B to close the overlay, then see [Troubleshooting]({{ '/reference/troubleshooting/' | relative_url }}).
