---
layout: page
title: Steam MouseLOCK layout
description: Persistent controller camera using ConsoleUI Mouse Look and the HouseLegend MouseLOCK Steam layout.
permalink: /controller/steam-mouselock/
last_reviewed: 2026-08-25
---

Use this path when walking should keep the camera locked without holding right mouse.

<figure>
  <img src="{{ '/assets/images/controller-setup/steam-community-layout-mouselock.png' | relative_url }}" alt="HouseLegend MouseLOCK ConsoleUI controller layout. WASD also sends F9. R3 unlocks.">
  <figcaption>MouseLOCK layout. Right stick is mouse movement. WASD also sends F9. R3 unlocks. Do not hold L3 as left-mouse for camera.</figcaption>
</figure>

<ol class="steps">
  <li>Add the executable you actually launch (<code>WoW.exe</code>, <code>Wow.exe</code>, or <code>VanillaTweaks.exe</code>) as a non-Steam game. Name the library entry OctoWoW, TurtleWoW, RavenCraft, or Cappy. Enable Steam Input.</li>
  <li>Open Community layouts and choose the HouseLegend <strong>ConsoleUI --MouseLOCK -- Layout</strong>.</li>
  <li>Keep the right stick as mouse movement. Do not bind the stick itself to held right-click.</li>
  <li>Confirm each WASD direction still sends its movement key <em>and</em> F9 as an additional command. F9 must not replace W/A/S/D.</li>
  <li>In <code>/cui</code> → <strong>Mouse</strong>, enable <strong>Enable Mouse Look System</strong>.</li>
  <li>Leave <strong>Starting to move</strong> on if you want walk to lock. Right-click unlock stays on by default.</li>
  <li>Use R3 / right-click to unlock before tapping the screen or touch bars.</li>
</ol>

<aside class="callout callout-warning">
  <p class="callout-label">Warning</p>
  <p>While Mouse Look is locked, the client holds the cursor. Touch buttons cannot be clicked until you unlock. That is expected.</p>
</aside>

F9 is only the WASD companion. Jump, casts, modifiers, Rings, and UI actions use ConsoleUI or WoW bindings. Do not add more Steam commands for those.

The hidden binding **Mouse Lock Start (Mapper)** is what F9 fires. You do not bind F9 yourself unless you are building a custom mapper.

## Test

1. Walk. The cursor hides and the right stick turns the camera.
2. Stay moving. Look stays locked.
3. Press R3. The cursor returns.
4. Walk again. Look locks again.
5. Cast a bound action if **Casting spells / actions** is on. Look stays or becomes locked.
6. Unlock, then open a bag or tap a touch control.

Camera invert and mouse speed are on the same Mouse page. Next: [Mouse Look]({{ '/features/mouse-look/' | relative_url }}).
