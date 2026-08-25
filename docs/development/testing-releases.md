---
layout: page
title: Testing and releases
description: Desktop checks, in-game audit, and what a release ZIP must contain.
permalink: /development/testing-releases/
last_reviewed: 2026-08-25
---

Prove the change before you ship. Desktop checks catch layout math. `/cui test` catches a live client. Release notes name the change only.

## Desktop self-checks

Some files load with the addon and also run under a desktop Lua 5.1+ interpreter (`lua path/to/check_*.lua`).

| File | Loaded in TOC | What it proves |
| --- | --- | --- |
| `actionbars/check_layout.lua` | Yes (`init/actionbars.xml`) | Diamond/square metrics, scale, gaps |
| `actionbars/check_extra.lua` | Yes | Stance / pet packing |
| `radial/check_rings.lua` | Yes (`init/radial.xml`) | Ring slice math |
| `radial/check_navigation.lua` | No | Radial overlay / stick |
| `config/check_mouse.lua` | No | Mouse settings keys |
| `cursor/check_mouselook.lua` | No | Mouse Look policy table |
| `xpbar/check_autohide.lua` | No | XP/Rep hide timing |

`ConsoleUIKeyboard/Core/SelfCheck.lua` loads with the keyboard addon. `/cuik check` runs it in-game.

Do not add `#` length or `hooksecurefunc` to a check file. The 1.12 client parses the whole file if it is in the TOC.

## In-game

| Command | What you get |
| --- | --- |
| `/cui test` (`/cui audit`) | `ConsoleUI:RunAudit()` — copyable report in `/cui` → Debug. Stubs `UseAction` for fire probes. Does not cast, loot, sell, or persist overlay binds. |
| `/cui debug` | Diagnostics report |
| `/cui debug on` | Extra `ConsoleUI_Debug` lines (also the in-memory log) |
| `/cuik check` | Keyboard self-check |

Paste the Debug EditBox, not a chat scrape. Redact realm, character, and paths before an issue.

Live setup to exercise after a UI change:

1. All three bar layouts (controller / flat / full), gold border on and off
2. Quick Menu + one user ring (hold, aim, release, cancel)
3. Cursor on bags, vendor, spellbook, `/cui`
4. Mouse Look lock + right-click unlock; touch while locked (must not click)
5. Stance on a shapeshift class; pet bar with a pet out
6. Copy From between two characters (out of combat)
7. Keyboard `/cuik on` in chat

## Release ZIP

- Both folders: `ConsoleUI` and `ConsoleUIKeyboard`
- TOC `Interface: 11200` and matching `Version`
- `Bindings.xml` at the `ConsoleUI` root (auto-discovered)
- No workspace `context/`, `.cursor/`, or handoff notes
- README / Pages claims match this source
- Saved vars survive update: do not wipe `ConsoleUIDB` or `ConsoleUIProfileDB`

Install on Octo (and any other listed 1.12 client): quit the client, replace both AddOn folders. Do not tell testers `/reload` is enough when lock or TOC behavior changed.

Player list: [Changelog]({{ '/reference/changelog/' | relative_url }}). Add a newest-first block to `ConsoleUI.CHANGELOG` in the same change.

## Release notes

Name the change. Do not describe it.

- **New** X
- **Fixed** X
- **BREAKING** X — only if behavior, defaults, saved vars, or install path changed
