# Starfield for PICO-8

This repository contains a PICO-8 port of Nick Title's original
[Starfield](https://github.com/NickTitle/starfield), a quiet story about a
spaceship, a radio, and a search for something lost.

The port preserves the complete story and its central loop: tune distant
broadcasts, follow the sonar through a large starfield, approach eleven
artifacts, shut them down, and reach the two-ship finale. The original
Ruby/Gosu implementation remains in `app/` as a reference; active PICO-8
development lives in the cartridge and Lua files at the repository root.

## Controls

- Left / right: rotate the ship.
- Up: thrust.
- O / X: tune the radio down / up.
- Down: advance dialogue or shut down an artifact while in close orbit.
- Pause menu, `checkpoint N/11`: advance the playtest state by one completed
  planet, capped at all eleven. This is a testing shortcut, not story input.

Dialogue uses a two-stage Down action. If text is still typing, the first press
reveals the complete block without advancing it. A later press advances.

## Requirements and running

PICO-8 is commercial software and is not included. Install your licensed copy,
then point `PICO8_BIN` at its executable:

```sh
PICO8_BIN=/path/to/pico8
"$PICO8_BIN" -run starfield.p8
```

The checked-in `starfield.html` and `starfield.js` files are a browser export.
[Play the published build](https://shiptoast.github.io/pico-strfld/starfield.html),
or open `starfield.html` through a local web server to test the checked-in
files.

## Source map

- `starfield.p8`: cartridge wrapper, sound data, label, and include order.
- `constants.lua`: story, story gates, controls helpers, and world constants.
- `story.lua`: title, typewriter dialogue, story progression, and finale.
- `world.lua`: stars, artifacts, shutdown state, rendering, and minimap.
- `ship.lua`: flight, orbit, particles, ship art, and sonar.
- `radio.lua`: tuning, signal selection, proximity, and artifact interaction.
- `main.lua`: cartridge lifecycle and draw ordering.
- `tests/smoke.p8`: cartridge-level progression and regression coverage.
- `docs/overview.md`: design, architecture, and validation details.
- `app/`: original Ruby/Gosu source and media, retained for provenance.

## Exporting and testing

Gameplay changes belong in the Lua source files. Regenerate both browser files
after any gameplay change; an unchanged HTML shell does not prove that the
cartridge payload in `starfield.js` is current.

```sh
PICO8_BIN=/path/to/pico8

SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
  "$PICO8_BIN" starfield.p8 -export starfield.html

timeout 8s env SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
  "$PICO8_BIN" -run tests/smoke.p8
```

The smoke cartridge covers repeated checkpoint advances and their cap, coherent
artifact/radio/ship reset state, the preserved radio-off ending, all eleven
proximity gates, paused-dialogue orbit, two-stage text reveal/advance, sustained
orbit momentum, four cardinal orbit headings, one natural artifact shutdown,
the finale cue and transition, ship accents, artifact rotation, and basic flight input. A passing run prints
`starfield smoke: passed` before shutting down.

Before publishing a release, export and test from the exact commit being
released, then verify both generated-file hashes and a desktop/touch browser
launch.

## Intentional differences from the original

- Artifact positions and frequencies are fixed instead of randomized so that
  every cartridge run is reproducible and completable.
- The 20,000-unit, 640x480 world is proportionally scaled to PICO-8's 128x128
  display and a 4,096-unit search space.
- The original MP3 soundtrack cannot fit in a cartridge, so chip-sound cues
  provide engine, radio, typing, discovery, and finale feedback. The original
  soundtrack remains [available on Bandcamp](https://nicktitle.bandcamp.com/album/starfield-soundtrack-wip).

## What's to come

- Record one uninterrupted browser playthrough from the title through all
  eleven shutdowns, radio-off ending, and finale. Current automated coverage
  intentionally jumps between story states.
- Add automated browser coverage or a documented release checklist for
  desktop/touch controls, fresh export, and Lua-to-export hash parity.

This is not an action game.
