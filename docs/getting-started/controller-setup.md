---
layout: page
title: Controller setup
description: Understand the mapper, WoW bindings, and ConsoleUI layers, then pick Standard or MouseLOCK.
permalink: /getting-started/controller-setup/
last_reviewed: 2026-08-25
---

ConsoleUI never sees a gamepad. The working pipeline is:

```text
controller → mapper (keyboard + mouse) → WoW bindings → ConsoleUI
```

Steam Input, WoWpadX, reWASD, or another mapper owns the first conversion. Add the process you play: `WoW.exe`, `Wow.exe`, or `VanillaTweaks.exe`. WoW owns normal keys such as `1–0`, `WASD`, `Escape`, and `M`. ConsoleUI owns its named addon actions and the on-screen UI.

## Pick one camera style

| | Standard | MouseLOCK |
| --- | --- | --- |
| Camera | Stick move parks the cursor top-left and holds right-click | ConsoleUI Mouse Look locks the camera |
| Right stick | Mouse movement plus that right-click hold | Mouse movement only |
| Movement | WASD only | WASD plus F9 as an additional command |
| Cursor back | Center the stick | R3 / right-click |
| Mouse Look in `/cui` | Off | On |
| Best when | You want Vanilla RMB look from the stick | You want a locked controller camera |

Use one layout. Mixing Standard’s held right-click with Mouse Look on will fight itself.

- [Steam Standard]({{ '/controller/steam-standard/' | relative_url }})
- [Steam MouseLOCK]({{ '/controller/steam-mouselock/' | relative_url }})
- [Other mappers]({{ '/controller/other-mappers/' | relative_url }})

The shared button table lives in [Mapping reference]({{ '/controller/mapping-reference/' | relative_url }}).

<aside class="callout callout-warning">
  <p class="callout-label">Warning</p>
  <p>F9 belongs only to the MouseLOCK layout’s WASD additional command. Do not add mapper commands for jump, spell casts, modifiers, Rings, or UI actions. ConsoleUI already owns those.</p>
</aside>

## After the layout is applied

1. Launch the game through the mapper or Steam.
2. Confirm W/A/S/D walk and `1–0` press the matching diamonds.
3. Open `/cui` → Mouse and match the camera style you chose.
4. Continue with [First launch]({{ '/getting-started/first-launch/' | relative_url }}).
