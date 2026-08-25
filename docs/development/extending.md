---
layout: page
title: Extending ConsoleUI
description: Recipes for integration addons and for patches inside ConsoleUI.
permalink: /development/extending/
last_reviewed: 2026-08-25
---

Start with [Developer overview]({{ '/development/overview/' | relative_url }}) and the [Public API]({{ '/development/api/' | relative_url }}). Most third-party work is [cursor integrations]({{ '/development/cursor-integrations/' | relative_url }}).

## Public API cheat sheet

| You want | Use |
| --- | --- |
| Cursor skips my decorative button | `ConsoleUI_AddCursorIgnorePattern("MyAddonFoo")` or `/cuiignore add` |
| Cursor works in my window | `ConsoleUI.hooks:HookDynamicFrame(frame, "Label")` |
| Read a ConsoleUI setting | `ConsoleUI.config:Get("barLayout")` |
| Open settings | `/cui` — not a Lua export beyond `ConsoleUI.config:Toggle()` |
| Toggle Mouse Look | `/cui look` or binding `ConsoleUI_MOUSELOOK` |
| Translate a ConsoleUI key | `ConsoleUI.locale.T("Enable Mouse Look System")` |
| Keyboard on/off | `/cuik on` / `/cuik off` |

Wait for `PLAYER_ENTERING_WORLD` (or `VARIABLES_LOADED` if you only touch saved ignore patterns). Guard every call: `if ConsoleUI_AddCursorIgnorePattern then`.

## Recipe: open my frame from a pad button

Do not steal `1–0` or WASD. Add a **your** `Bindings.xml` action, or ask the player to bind a free key to a slash that shows your frame.

If you contribute to ConsoleUI instead: add `ConsoleUI_MYTHING` to `Bindings.xml`, a `ConsoleUI_MyThing()` function, a Bindings UI row, and an enUS string. Decide `runOnUp` if it is a hold overlay.

## Recipe: add a setting inside ConsoleUI

See [Settings and profiles]({{ '/development/settings-and-profiles/' | relative_url }}). Default → widget on the owning page → live apply → Reset → `T()` key → migrate flag only if the old key changed meaning.

## Recipe: add a binding inside ConsoleUI

XML + implementation + `BINDING_NAME_` + Bindings UI + translation. If it is a radial/keyboard overlay, never persist it. If it is touch-capable, update `proxied.lua` allow/deny lists.

## Recipe: add a translation

Add the English key to `translations_enUS.lua`. Use `T("that exact key")` in Lua. Other locale files are optional until someone translates them.

## What not to depend on

- Modern ConsolePort modules (`SetGamePadFreeLook`, nameplates, `C_Timer` from FrameXML)
- `IsMouselooking()` as truth — ConsoleUI tracks `mouselook.looking`
- Calling `SaveBindings` while Quick Menu or the keyboard is open
- Editing shipped `check_*.lua` expectations without updating the desktop suite

## Keyboard from another addon

`ConsoleUIKeyboard` is a separate addon. `RequiredDeps: ConsoleUI`. Control it with `/cuik`. There is no supported “type this string” API. `showFor` is `chat` or `everything` in `ConsoleUIKeyboardDB`.
