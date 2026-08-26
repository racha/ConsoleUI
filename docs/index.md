---
layout: home
title: ConsoleUI
description: Play original Vanilla WoW with a controller.
permalink: /
---

<section class="hero">
  <p class="eyebrow">Original Vanilla · 1.12</p>
  <h1>Play Vanilla WoW with a controller.</h1>
  <p>Action bars, Mouse Look, Quick Menu, Rings, a virtual cursor, touch bars, and a radial keyboard — built for the original 1.12 client.</p>
  <a class="button" href="{{ site.data.project.download }}">Download latest</a>
  <a class="button secondary" href="{{ '/getting-started/install/' | relative_url }}">Start the guide</a>
</section>

<figure>
  <img src="{{ '/assets/images/gameplay/consoleui-gameplay-overview.png' | relative_url }}" alt="ConsoleUI Controller action bars, player and target frames, and XP bar during outdoor Vanilla gameplay.">
  <figcaption>Controller layout in a live original 1.12 scene.</figcaption>
</figure>

<div class="path-grid">
  <a class="card" href="{{ '/getting-started/install/' | relative_url }}">
    <div class="card-kicker">Path 1</div>
    <h2>Install</h2>
    <p>Copy both addon folders, enable them, and open <code>/cui</code>.</p>
  </a>
  <a class="card" href="{{ '/getting-started/controller-setup/' | relative_url }}">
    <div class="card-kicker">Path 2</div>
    <h2>Set up the controller</h2>
    <p>Choose Standard or MouseLOCK, then apply the matching mapper layout.</p>
  </a>
  <a class="card" href="{{ '/getting-started/first-launch/' | relative_url }}">
    <div class="card-kicker">Path 3</div>
    <h2>Learn the features</h2>
    <p>Run the first-launch checklist, then open the feature that matches what you want to do.</p>
  </a>
</div>

## Choose your camera style

Both styles use the same two addons. Pick the mapper layout that matches the camera you want.

<div class="media-pair">
  <figure>
    <img src="{{ '/assets/images/controller-setup/steam-community-layout-standard.png' | relative_url }}" alt="HouseLegend Standard ConsoleUI controller layout. Right-stick move parks the cursor top-left and holds right-click.">
    <figcaption><strong>Standard.</strong> Right-stick move parks the cursor top-left and holds right-click. Mouse Look stays off.</figcaption>
  </figure>
  <figure>
    <img src="{{ '/assets/images/controller-setup/steam-community-layout-mouselock.png' | relative_url }}" alt="HouseLegend MouseLOCK ConsoleUI controller layout. WASD also sends F9. R3 unlocks.">
    <figcaption><strong>MouseLOCK.</strong> WASD also starts Mouse Look. R3 unlocks. Unlock before using touch.</figcaption>
  </figure>
</div>

<p><a href="{{ '/controller/steam-standard/' | relative_url }}">Steam Standard setup</a> · <a href="{{ '/controller/steam-mouselock/' | relative_url }}">Steam MouseLOCK setup</a></p>

<aside class="callout callout-important">
  <p class="callout-label">Important</p>
  <p>Vanilla has no native gamepad API. Steam Input or another mapper turns the pad into keyboard and mouse. ConsoleUI reads those keys. F9 is only the MouseLOCK WASD companion. Do not add mapper commands for jump, casts, or UI actions.</p>
</aside>

## What you get

<div class="feature-grid">
  <a class="card" href="{{ '/features/action-bars/' | relative_url }}"><h3>Action bars</h3><p>Controller, Flat, and Full layouts with modifier pages, stance, and pet bars.</p></a>
  <a class="card" href="{{ '/features/mouse-look/' | relative_url }}"><h3>Mouse Look</h3><p>Lock the camera, unlock with right-click, and keep optional window unlocks off until you want them.</p></a>
  <a class="card" href="{{ '/features/quick-menu/' | relative_url }}"><h3>Quick Menu</h3><p>Open bags, map, spellbook, quests, social, chat, and settings from an eight-slice wheel.</p></a>
  <a class="card" href="{{ '/features/rings/' | relative_url }}"><h3>Rings</h3><p>Build your own eight-slice spell and item wheels. Hold, aim, release.</p></a>
  <a class="card" href="{{ '/features/touch-cursor/' | relative_url }}"><h3>Cursor and touch</h3><p>Navigate Blizzard panels with the stick, and add optional phone or Deck side bars.</p></a>
  <a class="card" href="{{ '/features/keyboard/' | relative_url }}"><h3>Keyboard</h3><p>Type in chat with the radial ConsoleUI Keyboard. Y space, X erase, A send, B close.</p></a>
</div>

## Support boundary

ConsoleUI targets original 1.12 clients: OctoWoW, TurtleWoW, RavenCraft, and Capybara Paradise. It is not a Retail or modern Classic addon.

[Interact]({{ site.data.project.interact }}) is a separate client mod for one-button loot, herbs, veins, and NPCs. It is not inside the ConsoleUI ZIP.

If something fails, start with [Troubleshooting]({{ '/reference/troubleshooting/' | relative_url }}) and include `/cui test` when you [open an issue]({{ site.data.project.issues }}).

## For addon authors

ConsoleUI exposes a small public surface: cursor ignore patterns, frame hooks, `config:Get` / `Set`, locale `T()`, and named bindings.

[Developer overview]({{ '/development/overview/' | relative_url }}) · [Public API]({{ '/development/api/' | relative_url }}) · [Hook your frames]({{ '/development/cursor-integrations/' | relative_url }})

## Credits

Made by **HouseLegend**. Full project credits are listed in `/cui` → About and on the [Credits]({{ '/reference/credits/' | relative_url }}) page. World of Warcraft is a trademark of Blizzard Entertainment. This project is for educational purposes only. It is not affiliated with Blizzard or any private server.
