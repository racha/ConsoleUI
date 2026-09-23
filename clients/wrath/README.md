# Wrath 3.3.5a port (in progress)

The Vanilla 1.12 addon remains unchanged. Run `scripts/build-client.sh wrath`
to generate `dist/clients/wrath/ConsoleUI/`. Do not publish or install this
as a complete ConsoleUI release yet.

The first slice uses the shared diamond layout and textures, but performs
actions through `SecureActionButtonTemplate` and changes modifier pages with
`RegisterStateDriver`. Keys 1–0 plus Shift/Ctrl chords are temporary override
bindings, not saved to the user's binding file.

Run `lua clients/wrath/check_securebar.lua` for a desktop check. The test
cannot prove the 3.3.5a client accepts the secure snippets or combat clicks.
For a first live smoke test, use a separate 3.3.5a installation and back up
its AddOns/WTF first. Install only the generated `ConsoleUI` folder. Put an
ability in Blizzard action slot 1, press `1`, then repeat in combat. Put a
second ability in slot 11 and try Shift+1. Confirm the diamond icon changes,
both abilities fire, `/reload` works, and no blocked-action popup appears.

Still required for a full port: correct icon clipping and all bar layouts;
stance, pet, touch, vehicle and possess states; safe spell placement and
profiles; Quick Menu and Rings; cursor and panel navigation; Mouse Look; HUD,
loot, settings, and the keyboard addon. The Wrath client must be used for
combat-lockdown and gameplay verification.
