---
layout: page
title: Developer overview
description: Runtime, repository layout, and the contract for extending ConsoleUI on original 1.12.
permalink: /development/overview/
last_reviewed: 2026-08-25
---

ConsoleUI is a Lua addon for **original World of Warcraft 1.12**. There is no gamepad API. A mapper turns the pad into keyboard and mouse. ConsoleUI reads those keys and draws controller UI.

This section is for people who want to:

- write a small **integration addon** that works with ConsoleUI (cursor, frames, ignores);
- **contribute** to ConsoleUI itself;
- understand load order, saved variables, and 1.12 limits before copying modern ConsolePort code.

Player setup lives in the rest of the guide. Do not document private crash notes, local paths, or unshipped experiments here.

## Runtime

| Fact | Value |
| --- | --- |
| Client | Original 1.12 |
| Language | Lua 5.0 (some private servers add extras; write 5.0-safe code) |
| Two addons | `ConsoleUI` (required) and `ConsoleUIKeyboard` (`RequiredDeps: ConsoleUI`) |
| Saved (account) | `ConsoleUIProfileDB` |
| Saved (character) | `ConsoleUIDB` |
| Keyboard saved | `ConsoleUIKeyboardDB`, `ConsoleUIKeyboardLayout`, `ConsoleUIKeyboardDictionary` |

Primary tested client: OctoWoW. TurtleWoW and other 1.12 cores are intended targets. Retail and modern Classic are unsupported.

## Repository layout

| Path | Role |
| --- | --- |
| `ConsoleUI/` | Main addon source |
| `ConsoleUIKeyboard/` | Radial keyboard |
| `docs/` | This GitHub Pages site |
| `README.md` | Player front door |

Reference trees such as `ConsolePort/` or `ConsolePortLK/` are look-and-behavior references only. Do not import `hooksecurefunc`, `C_Timer`, `SetGamePadFreeLook`, `MaskTexture`, or `#` length.

## Supported vs internal

**Supported for other addons** (stable enough to call after `PLAYER_ENTERING_WORLD`):

- Cursor ignore helpers and `/cuiignore`
- `ConsoleUI.hooks:HookDynamicFrame` / `TryHookNamedFrame`
- Reading `ConsoleUI.config:Get` for published keys
- Binding to public `Bindings.xml` names
- Slash commands listed in [Commands]({{ '/reference/commands/' | relative_url }})

**Internal.** Use only if you are patching ConsoleUI itself:

- Overlay bind steal/restore (`ConsoleUI_ParkTransientPadKeys`, radial/keyboard overlay)
- Action-bar button construction, SliceMask, diamond chrome
- Profile restore jobs and action-bar serialization
- Mouse Look start stacks

If a function is not listed on [Public API]({{ '/development/api/' | relative_url }}), treat it as internal.

## 1.12 rules that will break a load

- No `#` length operator. The client parses the **whole file**.
- Prefer `table.getn`. Avoid new `ipairs` loops in compatibility work.
- No `hooksecurefunc`. Wrap scripts yourself and keep the original.
- No stock `C_Timer`. Do not assume Octo ClassicAPI timers are safe for protected camera calls.
- No `MaskTexture`. Shape is TGA alpha. Power-of-2 files. Replace-in-place TGA is cached — new pixels need a new filename.
- `SetVertexColor` is rgb. Alpha is `SetAlpha`.
- `MouseIsOver(frame)`, not `frame:IsMouseOver()`.
- Do not steal `SHIFT-ESCAPE`. No `hasArrow` dropdowns (1.12 stack-overflows).
- Do not wrap `_G.MoveForwardStart`, `JumpOrAscendStart`, `CameraOrSelectOrMoveStart`, `TurnOrActionStart`, or `UseAction`. That taints movement and can block the client.

## Where to go next

1. [Public API]({{ '/development/api/' | relative_url }}) — what another addon may call
2. [Cursor integrations]({{ '/development/cursor-integrations/' | relative_url }}) — hook frames and ignore junk buttons
3. [Architecture]({{ '/development/architecture/' | relative_url }}) — TOC order and modules
4. [Input and bindings]({{ '/development/input-and-bindings/' | relative_url }}) — mapper vs WoW vs ConsoleUI
5. [Settings and profiles]({{ '/development/settings-and-profiles/' | relative_url }}) — defaults, Get/Set, Copy From
6. [Visual language]({{ '/development/visual-language/' | relative_url }}) — chrome numbers for patches
7. [Extending]({{ '/development/extending/' | relative_url }}) — recipes
8. [Testing and releases]({{ '/development/testing-releases/' | relative_url }}) — checks before you ship
