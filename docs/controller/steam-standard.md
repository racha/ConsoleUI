---
layout: page
title: Steam Standard layout
description: Right-stick look by parking the cursor top-left and holding right-click. Mouse Look stays off.
permalink: /controller/steam-standard/
last_reviewed: 2026-08-25
---

Use this path when you want Vanilla’s own right-click camera, driven by the right stick. ConsoleUI Mouse Look stays **off**.

Any right-stick movement parks the cursor in the **top-left** and **holds right-click**. That is how the layout emulates mouse look. It is not “hold R3 to look.”

<figure>
  <img src="{{ '/assets/images/controller-setup/steam-community-layout-standard.png' | relative_url }}" alt="HouseLegend Standard ConsoleUI controller layout. Right-stick move parks the cursor top-left and holds right-click.">
  <figcaption>Standard layout. Right-stick move parks the cursor top-left and holds right-click. Mouse Look stays off.</figcaption>
</figure>

<ol class="steps">
  <li>In Steam, add the executable you actually launch: <code>WoW.exe</code>, <code>Wow.exe</code>, or <code>VanillaTweaks.exe</code>. Name the library entry OctoWoW, TurtleWoW, RavenCraft, or Cappy so community layouts appear. The exe filename will not find them.</li>
  <li>Open the game’s Properties → Controller and enable Steam Input.</li>
  <li>Open Controller Layout → Community layouts and choose the HouseLegend <strong>ConsoleUI</strong> standard layout — not the MouseLOCK layout.</li>
  <li>Leave the Standard right-stick action as shipped: stick move → cursor to top-left + hold right-click. Do not change that to “hold R3 to look.”</li>
  <li>Tune stick-as-mouse sensitivity for your TV, monitor, or phone. There is no universal number.</li>
  <li>In <code>/cui</code> → <strong>Mouse</strong>, turn <strong>Enable Mouse Look System</strong> off.</li>
</ol>

## Test

- Left stick walks.
- Face buttons and D-pad press the matching diamonds.
- Move the right stick. The cursor jumps to the top-left, right-click stays held, and the camera turns.
- Center the stick. The hold ends so you can use the cursor or touch.
- Touch buttons work when the stick is centered. They do not need a Mouse Look unlock.

Shared keys are in [Mapping reference]({{ '/controller/mapping-reference/' | relative_url }}). If you want a locked camera instead, switch to [Steam MouseLOCK]({{ '/controller/steam-mouselock/' | relative_url }}).
