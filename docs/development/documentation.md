---
layout: page
title: Documentation maintenance
description: How this guide is built, previewed, and kept honest against the Lua.
permalink: /development/documentation/
last_reviewed: 2026-08-25
---

Player and developer docs live in `docs/`. GitHub Pages hosts the Vite + React app in `web/` at `https://racha.github.io/ConsoleUI/` (`base: /ConsoleUI/`). The storefront README is `README.md` at the repository root.

## What to edit

| Path | Job |
| --- | --- |
| `docs/_data/project.yml` | Version, download, issues, Interact URL |
| `docs/_data/navigation.yml` | Sidebar (keep `web/src/nav.js` in sync) |
| `docs/_data/pages.yml` | Prev/next (keep `web/src/pages.js` in sync) |
| `docs/_data/screenshots.yml` | Image ledger (status, alt, page) |
| `docs/**/*.md` | Pages. The app loads these at build time. |
| `ConsoleUI/config/changelog.lua` | In-game What’s new. Keep [Changelog]({{ '/reference/changelog/' | relative_url }}) in sync. |
| `docs/assets/` | Images and icons. `web` copies them on `npm run dev` / `build`. |
| `web/` | React shell, search, GitHub Pages build |
| `.github/workflows/pages.yml` | Actions build → Pages |
| `README.md` | GitHub storefront |

Keep facts in `project.yml` and the Lua. Do not hard-code a release candidate in body copy.

## Local preview

From `web/`:

```text
npm install
npm run dev
```

Opens `http://127.0.0.1:8767/`. After a markdown edit, refresh. Do not open `file://`.

`python3 docs/tools/preview.py` is the older static dump. The React app is what Pages will serve.

## Honesty rules

- Document **workspace** Lua (`ConsoleUI/`, `ConsoleUIKeyboard/`), not an old unpacked ZIP.
- Settings sidebar today: General, Mouse, Action Bars, HUD, Bindings, Rings, Frames, Profiles, About. Debug is not a normal nav row (`/cui debug`, `/cui test`).
- Do not publish private crash notes, local disk paths, or unshipped experiments.
- Release notes: **New** / **Fixed** / **BREAKING** only.

## Screenshots

The live set is three owner shots: gameplay overview, Steam Standard layout, Steam MouseLOCK layout. Do not request more unless the owner asks. Every public image needs a kebab-case filename, a ledger row, alt text, and a caption that says what the shot is. Keep raw captures out of the public repo.

## Developer pages

When you add a public function, add it to [Public API]({{ '/development/api/' | relative_url }}) in the same change. When you add a settings key, add the default, widget, Reset, and `T()` key — then mention the key on [Settings and profiles]({{ '/development/settings-and-profiles/' | relative_url }}) if other addons may read it.
