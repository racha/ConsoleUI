---
layout: page
title: Localization
description: T() keys, translation files, and how language is chosen.
permalink: /development/localization/
last_reviewed: 2026-08-25
---

## How strings resolve

```lua
local T = ConsoleUI.locale.T
local label = T("Enable Mouse Look System")
```

`Locale:Translate(key)` looks up `ConsoleUI_translation[current][key]`, then `enUS`, then returns the key itself.

`Locale.T` is a plain function, not a method. Call `T("key")`, not `T:key()`.

## Files

| File | Role |
| --- | --- |
| `locale/locale.lua` | `Translate`, `T`, `Initialize`, `SetLanguage` |
| `locale/translations_enUS.lua` | Source of truth for English UI |
| `translations_deDE.lua`, `esES.lua`, `zhCN.lua`, `zhTW.lua` | Other locales |

New user-visible strings go in **enUS first**. Other files can lag; the key will show in English until translated.

## Language selection

`/cui` → General can pin a language. `nil` means “use `GetLocale()`”. `Locale:Initialize` runs from `InitializeDB`. Changing language may require `/reload` for already-built FontStrings.

## Binding names

`keybindings.lua` sets each `BINDING_NAME_` string through `L()`, which is the same translation table. Add both the Bindings.xml `name` and the matching `BINDING_NAME_` line together.

## Rules

- Do not put `|Tpath:size|t` inside FontStrings. Use Texture objects.
- Do not ship a third-party font. GameFont* / NumberFontNormal only.
- Keep keys stable. Renaming a key orphans existing translations.
