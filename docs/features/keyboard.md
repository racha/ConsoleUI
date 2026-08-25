---
layout: page
title: ConsoleUI Keyboard
description: Type in chat and other text fields with the optional radial keyboard addon.
permalink: /features/keyboard/
last_reviewed: 2026-08-25
---

`ConsoleUIKeyboard` is a second addon folder. It requires ConsoleUI. Install both, then enable both at character selection.

## When it opens

The keyboard appears when a text field needs input — most often chat. It uses the same gold ring chrome as Quick Menu, without slice wedges.

## Center actions

| Button | Action |
| --- | --- |
| Y | Space |
| X | Erase |
| A | Accept / send |
| B | Close / cancel |

Steer to a letter cluster, then press the matching face button. Those four center icons do not change.

## Commands

```text
/cuik
/cuik on
/cuik off
/cuik check
```

`/cuik off` disables the keyboard without removing ConsoleUI. Language and “show for” options live in `/cui` → **General**.

## Limitations

- The keyboard steals WASD and face keys while open, then restores them.
- Do not type private text into a screenshot. Redact chat before sharing.
- Custom layouts can be stored with the character profile. The learned dictionary stays account-wide and outside Copy From.
