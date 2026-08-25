---
layout: page
title: Architecture
description: TOC load order, modules, saved variables, and how ConsoleUI starts.
permalink: /development/architecture/
last_reviewed: 2026-08-25
---

`ConsoleUI` is a Frame created in `main.lua`. Other files attach tables onto that global: `ConsoleUI.config`, `ConsoleUI.cursor`, `ConsoleUI.hooks`, and so on.

## Load order

`ConsoleUI.toc` (1.12):

```text
main.lua
init/locale.xml          → locale + translations
keybindings.lua          → BINDING_NAME_* strings + pad helpers
init/actionbars.xml      → layout, slicemask, bars, extra, check_layout, check_extra, placement, autorank
init/cursor.xml          → cursor, tooltip, hints, hintbar, unit, actions, mouselook, keybindings, hooks
init/radial.xml          → Quick Menu, Rings, editor, check_rings
init/config.xml          → profiles, proxied, settings, mouse, unitframes, onboarding, changelog, bindings UI
init/xpbar.xml
init/castbar.xml
init/loot.xml
audit.lua
```

`Bindings.xml` is discovered automatically at the addon root. Do not list it again in the TOC.

`ConsoleUIKeyboard.toc` requires ConsoleUI, then loads `Core/Init.lua`, languages, keyboard, charset, dictionary, autocomplete, config, self-check.

## Startup events (`main.lua`)

| Event | What runs |
| --- | --- |
| `ADDON_LOADED` / `ConsoleUI` | Ensure `ConsoleUIDB` exists |
| `VARIABLES_LOADED` | `config:InitializeDB()`, action bars, autorank, cursor tooltip, **hooks**, radial, placement, XP, cast, loot |
| `PLAYER_ENTERING_WORLD` (once) | Keybindings init, overlay repair, welcome, onboarding, changelog, profile restore resume |
| `PLAYER_LOGOUT` | `profiles:SaveCurrentProfile` (skips a partial bar if a restore is in flight) |

Integration addons should wait until **`PLAYER_ENTERING_WORLD`** (or later) before calling ConsoleUI APIs. `VARIABLES_LOADED` is early enough for ignore patterns if you only need saved vars.

## Module map

| Global / table | Files | Job |
| --- | --- | --- |
| `ConsoleUI` | `main.lua` | Frame, log, print, welcome, diagnostics |
| `ConsoleUI.config` | `config/config.lua` | Defaults, Get/Set, `/cui` window, sidebar |
| `ConsoleUI.locale` | `locale/*.lua` | `T(key)` translations |
| `ConsoleUI.actionbars` | `actionbars/*.lua` | Diamonds/squares, scale, stance, pet, touch bars |
| `ConsoleUI.cursor` | `cursor/cursor.lua` | Virtual cursor, ignore patterns |
| `ConsoleUI.hooks` | `cursor/hooks.lua` | OnShow/OnHide wrap so the cursor appears |
| `ConsoleUI.mouselook` | `cursor/mouselook.lua` | Mouse Look lock/unlock |
| `ConsoleUI.radial` | `radial/radial.lua` | Quick Menu |
| `ConsoleUI.rings` | `radial/rings.lua` | User rings |
| `ConsoleUI.profiles` | `config/profiles.lua` | Account-wide character snapshots, Copy From |
| `ConsoleUI.proxied` | `config/proxied.lua` | Named WoW actions on pad/touch slots |
| `ConsoleUI.xpbar` / `castbar` / `loot` | matching folders | HUD |
| `ConsoleUIKeyboard` | Keyboard `Core/` | Radial keyboard |

## Saved variables

### `ConsoleUIDB` (per character)

Live character state: `config`, `proxiedActions`, `rings`, onboarding/changelog flags, migration markers. RC6 named-profile tables are left in place as a rollback/import source. Do not delete them from an integration addon.

### `ConsoleUIProfileDB` (account)

Schema v2. One automatic record per `realm/character`. Also stores:

- `cursorIgnorePatterns` — persistent custom cursor ignores
- `characters` — settings, bindings, rings, action bars, keyboard prefs
- `backups` — pre-copy history
- imported legacy templates

Copy From deep-copies another character into the current one. Combat rejects the copy. Dictionary data for the keyboard stays in `ConsoleUIKeyboardDictionary`, not in the profile.

### Keyboard

`ConsoleUIKeyboardDB.disabled` and `showFor` (`chat` or `everything`) can ride with the character snapshot. The learned dictionary does not.

## Input boundary

```text
pad → Steam/mapper keys → WoW bindings → ConsoleUI_* functions → UI
```

ConsoleUI never receives `OnGamePadButtonDown`. If the mapper is wrong, Lua cannot invent a stick.

Quick Menu and the keyboard **steal** WASD and face keys in memory, then restore. `ConsoleUI_SaveBindings` restores overlay binds before `SaveBindings`. Never persist radial overlay keys (`ConsoleUI_RADIAL_UP` and the other direction/face binds) or keyboard overlay keys.

## Visual construction (contributors)

Chrome is TGA, not Lua-drawn rounded rects.

- Diamonds: `KeyN/W/S/E` plate + inner rim + optional gold ring. Icon clip is `SliceMask` (16 strips).
- Squares: `KeySq`. **No** SliceMask.
- Rings: shared 520×520 chrome. See the in-repo visual rules if you edit textures.
- Gold token `{1.00, 0.82, 0.18}`. Black fill alpha 1 on diamonds.

Parent textures paint **under** children. Chrome that must sit on the icon lives on a child frame.

## OptionalDeps

TOC lists `pfUI`, `Quiver`, `SimpleActionSets`, `ModernMapMarkers`. Those are compatibility hooks (bags, maps), not required libraries. Bagshui and Bagnon are detected at runtime in `hooks.lua` the same way.
