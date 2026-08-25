---
layout: page
title: Public API
description: Every ConsoleUI symbol another addon may call, and what stays internal.
permalink: /development/api/
last_reviewed: 2026-08-25
---

Wait for `PLAYER_ENTERING_WORLD` (or `VARIABLES_LOADED` if you only touch saved ignore patterns). Guard every name: `if ConsoleUI_AddCursorIgnorePattern then`.

If a symbol is not in this table, treat it as internal. It may move or vanish.

## Cursor (other addons)

| Symbol | Returns | Notes |
| --- | --- | --- |
| `ConsoleUI_AddCursorIgnorePattern(pattern)` | `true, cleaned` or `false, error` | Lua pattern, max 200 chars, max 100 custom. Account-wide `ConsoleUIProfileDB.cursorIgnorePatterns`. |
| `ConsoleUI_RemoveCursorIgnorePattern(patternOrIndex)` | `true, removed` or `false, error` | Exact pattern or 1-based index. |
| `ConsoleUI.hooks:HookDynamicFrame(frame, label)` | — | Wrap OnShow/OnHide once (`ceHooked`). Original scripts run first. Starts the cursor if the frame is already visible. |
| `ConsoleUI.hooks:TryHookNamedFrame("Name", label)` | — | `getglobal`; no-op if missing. Safe to call again. |
| `ConsoleUI.hooks:RestoreFrameScripts(frame)` | — | Undo a hook. Rare. |

Slash (same store): `/cuiignore add`, `remove`, `list`, `test`. Alias `/ceignore`.

See [Cursor integrations]({{ '/development/cursor-integrations/' | relative_url }}) for a full addon example.

## Settings

| Symbol | Notes |
| --- | --- |
| `ConsoleUI.config:Get(key)` | Saved `ConsoleUIDB.config[key]`, else `Config.DEFAULTS[key]`. Touch counts are clamped 1–5. |
| `ConsoleUI.config:Set(key, value)` | Writes the character DB, marks the profile dirty, applies `mouseLook*` and `debugEnabled` immediately. |
| `ConsoleUI.config:Toggle()` | Open or close `/cui`. Creates the window if needed. |
| `ConsoleUI.config:Show()` / `:Hide()` | Same window. |

Do not invent keys and expect a settings row. Keys live in `config/config.lua` `Config.DEFAULTS`. See [Settings and profiles]({{ '/development/settings-and-profiles/' | relative_url }}).

## Locale

| Symbol | Notes |
| --- | --- |
| `ConsoleUI.locale.T(key)` | Function, not a method. Current locale → enUS → key. |
| `ConsoleUI.locale:Translate(key)` | Same lookup. |
| `ConsoleUI.locale:SetLanguage(lang)` | `false` if that file is missing. |
| `ConsoleUI.locale:GetAvailableLanguages()` | Sorted list of loaded locale codes. |

Shipped translation files: `enUS`, `deDE`, `esES`, `zhCN`, `zhTW`.

## Profiles

| Symbol | Notes |
| --- | --- |
| `ConsoleUI.profiles:GetCurrentProfile()` | Live character record. |
| `ConsoleUI.profiles:ListCopySources()` | Other characters + imported legacy templates. |
| `ConsoleUI.profiles:CopyFrom(sourceKey)` | `true` or `false, reason`. Combat and in-flight restore reject. |
| `ConsoleUI.profiles:MarkDirty(actionBars)` | Debounced save. |

Prefer the `/cui` → Profiles UI. Power tools must handle the error string.

## Mouse Look (player-owned)

These exist so bindings and `/cui look` work. Another addon should not start look to “help.” Unlock only if the player asked you to.

| Symbol | Binding / slash |
| --- | --- |
| `ConsoleUI_MouseLock()` | `ConsoleUI_MOUSELOCK` |
| `ConsoleUI_MouseUnlock()` | `ConsoleUI_MOUSEUNLOCK` |
| `ConsoleUI_MouseLockToggle()` / `ConsoleUI_MouseLook()` | `ConsoleUI_MOUSELOOK`, `/cui look` |
| `ConsoleUI_MouseLockHold(isDown)` | `ConsoleUI_MOUSELOCK_HOLD` (`runOnUp`) |
| `ConsoleUI_MouseUnlockHold(isDown)` | `ConsoleUI_MOUSEUNLOCK_HOLD` |
| `ConsoleUI_MouseLookStart()` | Hidden `ConsoleUI_MOUSELOOK_START` (F9 mapper companion) |

Do not call these from `OnUpdate`, a timer, or login `ADDON_LOADED`.

## Bindings you may point at

Your addon may `SetBinding` a **free** key to a ConsoleUI action. Do not steal WASD, `1–0`, or `SHIFT-ESCAPE`.

`ConsoleUI_ACTION_1` through `50`, cursor move/click/pickup/bind/delete/unequip/close, `ConsoleUI_TOGGLE_RADIAL` and radial direction/face actions, `ConsoleUI_RING_1` through `8`, `ConsoleUI_RING_CANCEL`, `ConsoleUI_INTERACT`, `ConsoleUI_UNIT_MENU`, Mouse Look names above, `ConsoleUI_STANCE_1` through `8`, `ConsoleUI_PET_1` through `10`, `ConsoleUI_PET_FOLLOW`, `ConsoleUI_PLACEMENT_CLEAR`.

Full list: [Input and bindings]({{ '/development/input-and-bindings/' | relative_url }}).

## Print / debug

| Symbol | Notes |
| --- | --- |
| `ConsoleUI_Print(msg)` | Chat line. |
| `ConsoleUI_Debug(msg)` | Only if `debugEnabled`. Also written to the in-memory Debug log. |
| `ConsoleUI:RunAudit()` | `/cui test`. Copyable report. Does not cast, loot, or persist overlay binds. |

## Keyboard (separate addon)

`RequiredDeps: ConsoleUI`. No “type this string” API.

| Control | Notes |
| --- | --- |
| `/cuik on` / `off` | `ConsoleUIKeyboardDB.disabled` |
| `/cuik check` | `ConsoleUIKeyboard:RunSelfCheck(true)` |
| `showFor` | `"chat"` or `"everything"` |

## Slash surface

| Command | Job |
| --- | --- |
| `/cui` | Settings |
| `/cui look` / `test` / `debug` / `help` | Mouse Look, audit, diagnostics |
| `/cui gold` / `gold off` / `modern` / `classic` | Bar chrome shortcuts |
| `/cuiignore` | Cursor ignore store |
| `/cuihealer` | Healer mode |
| `/cuik` | Keyboard |

Player-facing list: [Commands]({{ '/reference/commands/' | relative_url }}).

## Internal — do not call from another addon

- `ConsoleUI_SaveBindings`, `ConsoleUI_ParkTransientPadKeys`, overlay steal/restore
- `ConsoleUI_ActionButton`, SliceMask, `EnsureDiamond`, placement internals
- Profile restore jobs and action-bar serialization
- Wrapping `MoveForwardStart`, `JumpOrAscendStart`, click-look (`CameraOrSelectOrMoveStart` / `Stop`), `TurnOrActionStart` / `Stop`, or `UseAction`
- `MouselookStart` / `MouselookStop` from your own `OnUpdate` or login path
