# AGENTS.md

Start with `docs/overview.md`.

The original Ruby/Gosu implementation remains under `app/`. The PICO-8 port
uses `starfield.p8` as its cartridge wrapper and includes, in order:

1. `constants.lua`
2. `story.lua`
3. `world.lua`
4. `ship.lua`
5. `radio.lua`
6. `main.lua`

Treat `starfield.js` as generated. Gameplay changes belong in the included
Lua files; regenerate `starfield.html` and `starfield.js` afterward with the
verified command documented in `docs/overview.md`.
