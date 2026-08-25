---
layout: page
title: Install ConsoleUI
description: Copy both addon folders into an original Vanilla 1.12 client and confirm /cui opens.
permalink: /getting-started/install/
last_reviewed: 2026-08-25
---

## Requirements

- An original Vanilla 1.12 client.
- A controller-to-key mapper such as Steam Input or another mapper that can output the [required keys]({{ '/controller/mapping-reference/' | relative_url }}).
- The [latest ConsoleUI release ZIP]({{ site.data.project.download }}).

Retail, modern Classic Era, Wrath, and Cataclysm are unsupported.

## Install the two folders

<ol class="steps">
  <li>Download latest from <a href="{{ site.data.project.download }}">GitHub Releases</a>.</li>
  <li>Quit WoW completely. Do not update over a running client.</li>
  <li>Open the ZIP. You should see two folders: <code>ConsoleUI</code> and <code>ConsoleUIKeyboard</code>.</li>
  <li>Copy both folders into the client's <code>Interface/AddOns/</code> directory.</li>
  <li>If you are updating, replace the existing folders. Saved settings stay in the client's WTF folder.</li>
  <li>Start the client. At character selection, open AddOns and enable both entries.</li>
  <li>Log in and type <code>/cui</code>.</li>
</ol>

The final paths must be:

```text
Interface/AddOns/ConsoleUI/
Interface/AddOns/ConsoleUIKeyboard/
```

Do not put the ZIP's outer wrapper folder inside `AddOns`. The addon names will not appear if you do.

<aside class="callout">
  <p class="callout-label">Note</p>
  <p>Keep other controller-bar addons disabled while you first test ConsoleUI. Two addons writing the same bars or bindings make diagnosis unreliable.</p>
</aside>

## Verify the install

You are done with this page when all of these are true:

- `/cui` opens the settings window.
- The version in `/cui` → About matches the release you installed.
- ConsoleUI Keyboard is enabled next to ConsoleUI on the AddOns screen.
- Movement still works with the keyboard before you change mapper settings.

Next: add the client to Steam (read [which `.exe` to pick](#which-exe-to-add-to-steam)), [choose a camera style]({{ '/getting-started/controller-setup/' | relative_url }}), then run [First launch]({{ '/getting-started/first-launch/' | relative_url }}).

## Which .exe to add to Steam

The file you launch is not always `WoW.exe`. Add the executable **you actually start**.

| File | When you see it |
| --- | --- |
| `WoW.exe` / `Wow.exe` | Stock 1.12 client, many private-server installs |
| `VanillaTweaks.exe` | Launchers that wrap the client (common on Octo and similar packs) |

Steam → Games → Add a Non-Steam Game → Browse to that file. If you add `WoW.exe` but you always start `VanillaTweaks.exe`, Steam Input will not sit on the process you play.

Community layouts key off the **Steam library name**, not the exe name. `Wow.exe` as the library title will not find the HouseLegend layouts. Name the entry **OctoWoW**, **TurtleWoW**, **RavenCraft**, or **Cappy** — whichever you play.

## Updating later

Quit the client, replace both folders from the new ZIP, and start the client again. `/reload` is not enough after binding or Mouse Look changes. Settings and the automatic character profile survive an update.
