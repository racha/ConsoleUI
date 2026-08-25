---
layout: page
title: FAQ
description: Short answers to the questions that come up before the first session.
permalink: /reference/faq/
last_reviewed: 2026-08-25
---

## Does ConsoleUI work on Retail or modern Classic?

No. It targets original 1.12 only.

## Do I need both folders?

Yes. Copy `ConsoleUI` and `ConsoleUIKeyboard`. The keyboard addon depends on ConsoleUI.

## Why does my controller do nothing?

Vanilla has no gamepad API. Steam Input or another mapper must turn the pad into keyboard and mouse, and the game must be launched through that mapper.

## Standard or MouseLOCK?

Standard: any right-stick move parks the cursor top-left and holds right-click so Vanilla looks around. Center the stick to use the cursor. MouseLOCK locks look when you walk and unlocks with R3. Use one layout, not both. Mouse Look stays off on Standard.

## Why can’t I tap the screen?

Mouse Look is locked. Unlock with right-click / R3, then tap.

## Do I have to rebind A/D to strafe?

No. Quick Menu and Rings support Turn and Strafe. Strafe usually feels better on a pad.

## Can I keep named profiles?

No. Each character has one automatic profile. Copy From copies another character’s setup.

## What changed in this version?

The [Changelog]({{ '/reference/changelog/' | relative_url }}) lists every shipped version. Same blocks as in-game What’s new.

## Who made ConsoleUI?

HouseLegend. The same credit list as `/cui` → About is on the [Credits]({{ '/reference/credits/' | relative_url }}) page. World of Warcraft is a trademark of Blizzard Entertainment. This project is for educational purposes only. It is not affiliated with Blizzard or any private server.

## Is Interact included?

No. [Interact](https://github.com/vargv666/Interact) is a separate client mod.

## Can another addon use the virtual cursor?

Yes. Register ignore patterns and hook your window. See [Cursor integrations]({{ '/development/cursor-integrations/' | relative_url }}) and the [Public API]({{ '/development/api/' | relative_url }}).
