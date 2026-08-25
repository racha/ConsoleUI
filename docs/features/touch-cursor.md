---
layout: page
title: Touch bars and cursor
description: Optional phone and Deck side bars, plus stick navigation through Blizzard panels.
permalink: /features/touch-cursor/
last_reviewed: 2026-08-25
---

## Touch bars

Touch bars are optional left and right strips for extra actions. Configure size, count, position, and visibility under `/cui` → **Action Bars**. Assign the slots under **Bindings**.

Hiding a bar or lowering the button count must not wipe assignments. The actions wait until the bar is shown again.

<aside class="callout callout-warning">
  <p class="callout-label">Warning</p>
  <p>Touch cannot click while Mouse Look is locked. Unlock with right-click / R3, then tap.</p>
</aside>

## Virtual cursor

When a supported Blizzard panel is open, ConsoleUI moves a cursor with the stick or D-pad.

| Input | Typical action |
| --- | --- |
| A | Select / click |
| B | Close / back |
| X / Y | Extra actions named on the hint bar |
| Stick / D-pad | Move between nodes |

The hint bar explains the current node. Tooltips follow the cursor.

## Ignore patterns

To keep the cursor off another addon’s frame without editing ConsoleUI files:

```text
/cuiignore add <Lua pattern>
/cuiignore remove <number or exact pattern>
/cuiignore list
/cuiignore test <frame name>
```

Patterns are stored in account-wide profile data. Integration addons: [Cursor integrations]({{ '/development/cursor-integrations/' | relative_url }}).
