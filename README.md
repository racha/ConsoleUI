# ConsoleUI

**Play Vanilla WoW with a controller.** Built for phones, Steam Deck, Steam Link, and the couch.

ConsoleUI is a controller interface for the **original 1.12 Vanilla client**. It puts your spells on the face buttons, opens bags and menus from a stick wheel, and lets you type in chat without a keyboard.

This release is **v1.0.0-RC4.5** — ready to try, still a release candidate.

---

## Who this is for

You are playing Vanilla on a **private server** and you do not want to sit at a keyboard.

- **OctoWoW**
- **TurtleWoW**
- **RavenCraft**
- **Capybara Paradise**
- other 1.12 / Interface `11200` clients

If the server asks for a **1.12 Vanilla** client, this addon is for that. It will not work on Retail, Classic Era (modern), Wrath, or Cata.

---

## What you get

Two folders. One download.

| Addon | What it does |
| --- | --- |
| **ConsoleUI** | Action bars, Quick Menu, your own Rings, touch bars, cursor, settings |
| **ConsoleUI Keyboard** | On-screen chat keyboard. Turns on when a text box opens |

---

## Highly recommended: Interact

ConsoleUI gives you the pad. **[Interact](https://github.com/vargv666/Interact)** gives you the world.

Vanilla has no “press one button to loot” key. On a phone, Steam Deck, or the couch, that means fishing for herbs, veins, corpses, and NPCs with the right stick. Interact is a small 1.12 client mod that adds the same **Interact** key modern WoW has.

**We strongly recommend installing it with ConsoleUI.** Press one spare button to:

- loot a corpse (press again to take all)
- pick a herb or mine a vein
- skin
- talk to an NPC next to you

It is **not** inside the ConsoleUI zip. Get it from the author:

**https://github.com/vargv666/Interact**

Follow their install notes (it is a client mod, not only an AddOns folder). Then bind **Interact** in the game’s keybindings to a free pad button.

---

## Screenshots

### Settings

Open with `/cui`. Interface, Bars, Bindings, Rings, Blizz Frames, Profiles, About, Debug.

![Settings](screenshots/settings.png)

![Bindings](screenshots/bindings.png)

### Quick Menu

Hold the menu bind, tilt the stick, press **A** to open that panel.

![Quick Menu](screenshots/quick-menu.png)

### Rings

Your own 8-slice wheels — hearthstone, potions, food, a mount. Hold the bind, aim, release.

![Rings](screenshots/user-ring.png)

![Ring editor](screenshots/rings-settings.png)

### Action bars and touch bars

Face buttons and D-pad on screen. Extra buttons on the left and right for a phone or Steam Deck.

![Action bars](screenshots/action-bars.png)

### Chat keyboard

Point at a cluster, press a face button, type. **A** sends, **B** closes, **X** erases, **Y** is space.

![Keyboard](screenshots/keyboard.png)

---

## Install

1. Download **ConsoleUI-1.0.0-RC4.5.zip** from [Releases](https://github.com/racha/ConsoleUI/releases).
2. Open the zip. You will see two folders: `ConsoleUI` and `ConsoleUIKeyboard`.
3. Copy **both** into:

   `World of Warcraft/Interface/AddOns/`

4. At character select, enable **ConsoleUI** and **ConsoleUI Keyboard**.
5. Log in. Type `/cui` to open settings.

Turn **off** any other controller bar addon while you use this. Two addons fighting over the same bars will make a mess.

**Also install [Interact](https://github.com/vargv666/Interact).** Loot, herbs, veins, and NPCs become one button. We recommend it for every controller or phone setup.

If you used an older name (`ConsolePortClassic`), delete that folder first. This one is **ConsoleUI**.

---

## First-time setup (Steam Link)

Vanilla has no real gamepad support. Steam turns the pad into keyboard keys. ConsoleUI then reads those keys. Use the **ConsoleUI** community layout (HouseLegend).

Do this on the **PC that runs the game**. The phone or TV only runs **Steam Link**.

### 1. Add the game to Steam

The community layout is attached to **TurtleWoW**, **OctoWoW**, **RavenCraft**, and **Cappy**. Name the library entry any of those four. `WoW` or `Wow.exe` will not find it.

1. Open **Steam** on the PC.
2. **Games** → **Add a Non-Steam Game to My Library**.
3. **Browse** to your Vanilla `.exe` and add it.
4. In the library, right-click that game → **Properties**.
5. If the name is not already one of **TurtleWoW**, **OctoWoW**, **RavenCraft**, or **Cappy**, set it to whichever server you play.
6. Under **Controller**, turn **Enable Steam Input** on.

### 2. Apply the ConsoleUI layout

1. Still in Properties, open **Controller Layout** (or start the game once, then use the Steam overlay → Controller).
2. Open **Community** layouts.
3. Search for: **`ConsoleUI - WoW 1.12`** (author **HouseLegend**).
4. Apply **ConsoleUI - WoW 1.12 - OctoWoW - TurtleWoW - RavenCraft - Cappy**.

### 3. Fix the right stick for your screen

The right stick is the mouse. TVs, phones, and Steam Link all need a different speed.

1. Edit the layout → **Right Joystick**.
2. Raise or lower **sensitivity** until the cursor is usable on *your* screen.
3. Leave it as mouse move, not a D-pad. Do not turn the triggers into toggles — they must stay **held**.

### 4. Launch from Steam, then Steam Link

1. On the phone / TV, open **Steam Link** and sign into the same Steam account.
2. Connect to the PC.
3. Start that game from the Steam library — not a desktop shortcut.

If you start the game outside Steam, the pad will do nothing. Not using Steam? [WoWpadX](https://github.com/leoaviana/WoWpadX) can send the pad instead.

### Official layout (HouseLegend ConsoleUI)

This is what that community config sends. Copy it if you use Steam Deck, reWASD, or Octo instead.

Steam owns the **base keys**. The addon only writes the **modifier chords**, so your keyboard `1–0`, map, and Escape stay yours.

| Pad | Key | What it does |
| --- | --- | --- |
| A X Y B | `1` `2` `3` `4` | Face buttons |
| D-pad Down / Left / Up / Right | `5` `6` `7` `8` | Left cluster |
| RB | `9` | Right bumper |
| RT | `0` | Right trigger (tenth diamond) |
| **LT** | **Shift** | Page 2 (hold) |
| **LB** | **Ctrl** | Page 3 (hold) |
| Back | `M` | Map (WoW bind, not ours) |
| Start | `Escape` | Game menu (WoW bind, not ours) |
| Left stick | WASD | Walk / strafe (see below) |
| Right stick | Mouse | Move the cursor |
| **L3** (click left stick) | **Left mouse** | Hold to move the camera |
| **R3** (click right stick) | **Right mouse** | Hold to turn the character |

**Rebind A and D to strafe.** Vanilla defaults are Turn Left / Turn Right. On a pad that feels wrong: the right stick already turns the camera. In WoW keybinds, set **A = Strafe Left** and **D = Strafe Right**. Leave W / S as forward / back. The left stick then moves like a normal controller.

Four pages of ten buttons:

- nothing held — base page (your existing `1–0` binds)
- hold **LT** — page 2 (`SHIFT-1`…`SHIFT-0`)
- hold **LB** — page 3 (`CTRL-1`…`CTRL-0`)
- hold **LT + LB** — page 4 (`CTRL-SHIFT-1`…`CTRL-SHIFT-0`)

Put spells on the bars like a normal action bar, or use `/cui` → **Bindings** → **Spell Placement**.

Open `/cui` → **Interface** and pick **Xbox** or **PlayStation** so the on-screen icons match your pad.

---

## How to play

### Action bars

Ten face / D-pad slots. Hold **LT** or **LB** to change page.

`/cui` → **Bars** → **Layout**:

- **Controller Style** — diamond clusters like the pad
- **Flat** — one row of squares, active page only
- **Full** — three controller diamond sets at once (LB | default or LB+LT | LT). The live page is solid; the others fade

`/cui` → **Bars** if you want them bigger, gold-edged, or moved. `/cui` → **Blizz Frames** to scale the minimap, buffs, debuffs, player, target, party, and pets.

### Quick Menu (the Radial Menu)

This is the big gold wheel in the middle of the screen.

1. Bind **Toggle Radial Menu** in `/cui` → **Bindings** (many people put it on a spare button).
2. Hold it. Tilt the **left stick** (or WASD) toward a slice.
3. **A** opens that window (Character, bags, spellbook, quests, map, social, chat, settings).
4. Center buttons while it is open:
   - **Y** — game menu
   - **X** — reload the UI
   - **A** — confirm the highlighted slice
   - **B** — close

Walk keys come back when you close it.

### Rings (your own wheels)

Rings are extra wheels you fill yourself. Eight slices each. Spells or bag items.

**Make one**

1. `/cui` → **Rings** → **New Ring**.
2. Pick the ring on the left.
3. Pick up a spell or an item (from the spellbook or a bag).
4. Drop it on an empty slice.

**Use one**

1. `/cui` → **Bindings**.
2. Select a button (for example LT + D-pad Up).
3. On the right, pick your ring.
4. In the world: **hold** that button, tilt toward a slice, **let go** to use it.

Do not put a ring on **B**. B is also “cancel”, so that fight never ends well. Use an **LT** or **RT** page, or the D-pad.

### Touch bars (phone and Steam Deck)

Two optional strips on the left and right edge of the screen. Tap them with a thumb.

`/cui` → **Bars** → turn **Left touch bar** / **Right touch bar** on. Set how many buttons (1–5) and how far from the edge.

Then `/cui` → **Bindings** → **Touch bars** and give each slot a spell, a jump, a ring, or whatever you want.

### Cursor

When a bag, vendor, or other window is open, the stick can move a cursor around the slots. **A** clicks, **B** closes. Turn pieces of this on or off under Bindings if it gets in the way.

For corpses, herbs, veins, and talking to NPCs in the world, use **[Interact](https://github.com/vargv666/Interact)** — one key, no mouse aim. Highly recommended. See the section above.

### Chat keyboard

Install **ConsoleUI Keyboard** next to ConsoleUI.

Open chat (Quick Menu → Chat, or your chat bind). The gold wheel appears.

- Tilt toward a cluster of four letters.
- Press **Y / X / A / B** for the letter in that diamond.
- **Y** in the center = space
- **X** = erase
- **A** = send
- **B** = close

`/cuik off` turns the keyboard off. `/cuik on` turns it back on.

---

## If something breaks

Do this before you write a report. It saves everyone a lot of guesswork.

1. Type `/cui`
2. Click **Debug**
3. Turn **Debug: ON** at the bottom
4. Do the thing that broke (open the menu, try to walk, open chat…)
5. Go back to **Debug**
6. Press **Select All**, copy (**Ctrl+C** or your paste bind)
7. Paste that into the GitHub issue

Also send:

- the **first red error** on screen, if there is one
- a **screenshot**
- which client you are on (OctoWoW, Turtle, RavenCraft, Capybara…)

Useful extras:

- `/cui debug` — prints the same report in chat
- `/reload` — reload the UI after you change files

If you **cannot walk** after closing a menu or the keyboard, `/reload` once. If it happens again, send the Debug copy.

---

## Commands

| Command | What it does |
| --- | --- |
| `/cui` | Open settings |
| `/cui debug` | Print a diagnostic report |
| `/cui debug on` / `off` | Extra debug messages |
| `/cui modern` / `classic` | Action-bar look |
| `/cui gold` / `gold off` | Gold border on the bars |
| `/cuik` | Keyboard status |
| `/cuik on` / `off` | Enable or disable the chat keyboard |

---

## Credits

ConsoleUI stands on work a lot of people already did.

- [ConsoleExperience Classic](https://github.com/pepordev/ConsoleExperienceClassic) — Pedro / pepordev
- [ConsolePortLK](https://github.com/leoaviana/ConsolePortLK) — leoaviana
- [ConsolePort](https://github.com/seblindfors/ConsolePort) — Sebastian Lindfors / MunkDev
- [Interact](https://github.com/vargv666/Interact) — vargv666 (strongly recommended companion)

Made by **HouseLegend**.

---

## License

Use it, share it, fix it. If you publish a change, keep the credits above.
