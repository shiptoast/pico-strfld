# Starfield PICO-8 overview

## Goal

The PICO-8 port translates the original Ruby/Gosu game into cartridge-scale
systems without changing its central experience: fly an inertial ship through
a large starfield, tune broadcasts on a radio, follow sonar to eleven remote
artifacts, shut each one down, and progress through the complete story to the
two-ship finale.

The original MP3 soundtrack cannot fit in a PICO-8 cartridge. Distinct chip
sound cues preserve functional feedback for typing, thrust, static/power, and
artifact discovery instead.

## Source map

- `starfield.p8`: cartridge wrapper, sound data, label, and include order.
- `constants.lua`: screen/world dimensions, the complete 61 story beats,
  pause states, and radio/artifact cue indices.
- `story.lua`: typewriter text, story gating, title, fades, and finale timing.
- `world.lua`: layered parallax stars, eleven deterministic artifacts,
  shutdown/flicker state, artifact rendering, and minimap.
- `ship.lua`: rotation, thrust, inertia, passive spin, close-artifact orbit,
  engine particles, ship art, and directional sonar.
- `radio.lua`: tuning, static, signal selection/strength, map reveal, approach
  detection, and artifact interaction.
- `main.lua`: PICO-8 lifecycle, draw ordering, HUD, and dithered fades.
- `starfield.html` and `starfield.js`: generated browser export.
- `app/`: untouched original Ruby/Gosu source and media.

## Controls

- Left / right: rotate.
- Up: thrust.
- O / X: tune down / up.
- Down: advance story or shut down an artifact while in close orbit.

The mapping consumes PICO-8's six buttons while retaining the six independent
actions from the keyboard original.

## Running and exporting

PICO-8 is commercial software and is not included. Install a licensed copy and
point `PICO8_BIN` at its executable. The verified headless export command is:

```sh
PICO8_BIN=/path/to/pico8
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
  "$PICO8_BIN" starfield.p8 -export starfield.html
```

This emits `starfield.html` and `starfield.js`. Gameplay lives in the included
Lua files; both browser files are generated artifacts and must be refreshed
after source changes. The cartridge payload is in `starfield.js`, so an
unchanged HTML hash alone does not prove that an export is current.

A short runtime smoke test is:

```sh
timeout 3s env SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
  "$PICO8_BIN" -run starfield.p8
```

The cartridge-native progression smoke test checks collection sizes, first
signal acquisition, map reveal, close orbit, artifact shutdown/story advance,
and the complete ending transition:

```sh
timeout 8s env SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
  "$PICO8_BIN" -run tests/smoke.p8
```

## Parity notes

- The original randomized artifact positions/frequencies are fixed in the
  cartridge so every run is completable and reproducible. The search space,
  tuning range, eleven broadcasts, discovery order, and map/sonar loop remain.
- The world is proportionally scaled from 640x480 in a 20,000-unit world to
  128x128 in a 4,096-unit world.
- Long story beats wrap onto two PICO-8 text rows; wording and gating match the
  original `STORY`, `RADIO_CUES`, and `ARTIFACT_CUES` sequences.
