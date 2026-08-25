---
layout: page
title: Settings and profiles
description: Defaults, Get/Set, migrations, and the account-wide character profile store.
permalink: /development/settings-and-profiles/
last_reviewed: 2026-08-25
---

## Read and write a ConsoleUI setting

```lua
local Config = ConsoleUI.config
local layout = Config:Get("barLayout")           -- "controller" | "flat" | "full"
Config:Set("barGoldBorder", true)
```

`Get` returns the saved value, or `Config.DEFAULTS[key]` if missing. `Set` writes `ConsoleUIDB.config[key]`, marks the character profile dirty, and applies a few keys immediately (debug, `mouseLook*`).

Do **not** invent keys from an integration addon and expect `/cui` to show them. Settings UI is owned by ConsoleUI. If you need a player-facing option, add it in ConsoleUI (default + widget + reset + translation) or keep it in your own saved vars.

## Adding a setting (contributors)

1. Add the key to `Config.DEFAULTS` in `config/config.lua`.
2. `InitializeDB` already copies missing defaults. No extra loop needed.
3. Add a checkbox/edit box on the owning sidebar page (`CreateCheckbox`, `CreateEditBox` — edit boxes must `Commit()` so arrows and Enter call `setFunc`).
4. Apply live where it is safe. Combat-sensitive work should wait.
5. Include the key in the section Reset.
6. Add `T("Visible label")` to `locale/translations_enUS.lua` (and other locales if you have them).
7. Add a `*V1` migrate flag **only** when an existing key’s meaning or shape changes. Never wipe the user’s DB to “clean up.”

Sidebar order today: General, Mouse, Action Bars, HUD, Bindings, Rings, Frames, Profiles, About. Debug is not a normal sidebar row.

Published default groups include Mouse Look (`mouseLookEnabled`, lock/unlock keys), bar layout/scale, touch bars, XP/rep/cast, hint bar, stance/pet offsets, loot, language, and bag behavior. Read `Config.DEFAULTS` before documenting a key.

## Profiles

`ConsoleUI.profiles` stores **one automatic profile per character** on `ConsoleUIProfileDB.characters[realm/character]`.

| Method | Notes |
| --- | --- |
| `GetCurrentProfile()` | Live character record |
| `ListCopySources()` | Other characters + imported legacy templates |
| `CopyFrom(sourceKey)` | `true` or `false, reason`. Fails in combat or if a restore is running |
| `MarkDirty(actionBars)` | Debounced save. `true` also dirties action bars |
| `SaveCurrentProfile(includeActionBars)` | Called on logout |

Copy includes: config, proxied assignments, rings, action bars, keyboard prefs (`ConsoleUIKeyboardDB` + layout). It does **not** include onboarding/changelog flags or migrate markers (`CONFIG_METADATA` stays on the target character), the in-memory Debug log, transient overlay binds, the hidden F9 mapper bind, account-wide `cursorIgnorePatterns`, or `ConsoleUIKeyboardDictionary`.

Action-bar restore is a single job: suppress autosave, pause in combat, report unresolved slots. Spells store rank/name/texture. Macros prefer name/body over numeric ID. Items store ID/link/name.

Integration addons should not call `CopyFrom` unless they are a power-user tool and they handle the boolean + error string.

## Migrations

Existing flags in `InitializeDB` (examples): `barSizeV2`, `watchBarV2`, `castBarSlimV1`, extra-bar scale v2. New flags must be sticky (`if not ConsoleUIDB.config.myFlagV1 then …; ConsoleUIDB.config.myFlagV1 = true end`) so they run once.

RC6 `ConsoleUIDB.profiles` is imported as copyable templates and backed up. Do not delete `ConsoleUIDB` to force a “fresh” profile.
