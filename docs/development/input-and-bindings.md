---
layout: page
title: Input and bindings
description: Mapper keys, Bindings.xml names, overlay steal, and what another addon may bind.
permalink: /development/input-and-bindings/
last_reviewed: 2026-08-25
---

## Three owners

| Layer | Owns | Examples |
| --- | --- | --- |
| Mapper (Steam, etc.) | Physical pad → keyboard/mouse | A → `1`, LT → Shift, right stick → mouse |
| WoW | Key → action | `1` → Action Button 1, or `1` → `ConsoleUI_ACTION_1` |
| ConsoleUI | Named actions and UI | `ConsoleUI_ToggleRadialMenu()`, cursor click, Mouse Look |

ConsoleUI cannot see the pad. If Steam sends the wrong key, the diamond will not fire.

## Public binding names

Defined in `Bindings.xml`. Headers and labels are set in `keybindings.lua` (`BINDING_HEADER_CONSOLEUI`, `BINDING_NAME_ConsoleUI_ACTION_1`, and the rest).

| Header | Names | Implementation |
| --- | --- | --- |
| ConsoleUI | `ConsoleUI_ACTION_1` … `40` | `ConsoleUI_ActionButton(n)` — main + modifier pages |
| Left Touch Bar | `ConsoleUI_ACTION_41` … `45` | Touch left |
| Right Touch Bar | `ConsoleUI_ACTION_46` … `50` | Touch right |
| Cursor | `ConsoleUI_CURSOR_MOVE_UP` / `DOWN` / `LEFT` / `RIGHT`, `CLICK_LEFT` / `RIGHT`, `PICKUP`, `BIND`, `DELETE`, `UNEQUIP`, `CLOSE` | `cursor/actions.lua` |
| Radial | `ConsoleUI_TOGGLE_RADIAL`, `RADIAL_UP` / `DOWN` / `LEFT` / `RIGHT`, `RADIAL_ACTION_A` / `X` / `Y` / `B` | Quick Menu. Direction/face binds use `runOnUp="true"` |
| Rings | `ConsoleUI_RING_1` … `8`, `ConsoleUI_RING_CANCEL` | Hold/aim/release |
| Interact / unit | `ConsoleUI_INTERACT`, `ConsoleUI_UNIT_MENU` | Nearest interact, unit menu |
| Mouse | `ConsoleUI_MOUSELOCK`, `MOUSEUNLOCK`, `MOUSELOOK` (toggle), hold variants, hidden `MOUSELOOK_START` | Mouse Look |
| Stance / pet | `ConsoleUI_STANCE_1` … `8`, `ConsoleUI_PET_1` … `10`, `ConsoleUI_PET_FOLLOW` | Extra bars |
| Placement | `ConsoleUI_PLACEMENT_CLEAR` | Clear the hovered placement chip |

Your addon may `SetBinding("F8", "ConsoleUI_TOGGLE_RADIAL")` if the key is free. Prefer letting the player bind it in `/cui` → Bindings.

Do **not** auto-claim WASD, `1–0`, or `SHIFT-ESCAPE`.

## Overlay binds (internal)

While Quick Menu or the keyboard is open, ConsoleUI remaps stick/face keys to overlay actions. Those remaps must stay in memory only.

`ConsoleUI_SaveBindings` restores overlay keys, then calls `SaveBindings`. If you call `SaveBindings` yourself while a ring is open, you can persist overlay binds and kill WASD after `/reload`.

`runOnUp="true"` is required on radial/ring direction binds. Without it, a 1.12 client can omit press state and the stick latches.

## Protected actions

1.12 protects click-look and movement APIs. ConsoleUI uses `MouselookStart` / `MouselookStop` for camera lock. Touch slots filter unsafe `RunBinding` targets (jump / auto-run style actions).

Do not wrap:

- `MoveForwardStart` and the other Move* / jump functions
- `CameraOrSelectOrMoveStart` / `Stop`
- `TurnOrActionStart` / `Stop`
- `UseAction`

A wrap taints the keybind. Octo then shows `ADDON_ACTION_BLOCKED` and the character may not walk.

## Proxied actions

`/cui` → Bindings stores logical actions in `ConsoleUIDB.proxiedActions` (jump, bags, rings, mouse lock, …). The main bar still uses action slots `1–120` as usual. Touch and some pad buttons fire proxied names through `config/proxied.lua`.

If you add a new named action inside ConsoleUI: XML binding + `_G` function + Bindings UI row + translation + (if touch-safe) proxied allow-list.

## Mouse Look for other addons

Do not start look yourself. The player owns `/cui` → Mouse.

If you only need to **unlock** when your window opens, prefer asking the user to enable the matching Unlock Mouse On group, or document that they should press R3. There is no supported “force unlock” export beyond the existing settings and `ConsoleUI_MouseUnlock()`.

`ConsoleUI_MOUSELOOK_START` is hidden. It exists so the MouseLOCK mapper can emit F9 beside WASD. Do not bind it to a face button.
