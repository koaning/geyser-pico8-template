# geyser-pico8-template

A [copier](https://copier.readthedocs.io) template for bootstrapping PICO-8 games
with the toolchain shared by these three games:

- [koaning/mazing](https://github.com/koaning/mazing): crate-pushing puzzle
- [koaning/cairns](https://github.com/koaning/cairns): puzzle with a level generator
- [koaning/mossballs](https://github.com/koaning/mossballs): board game with an AI opponent

Part of the "geyser" family of game templates; a sibling
`geyser-love2d-template` for LÖVE games is planned (see PLAN.md).

**Status:** the template works (steps 1–4 of [PLAN.md](PLAN.md)); the three
games haven't adopted it yet (step 5).

## Usage

```sh
# new game (asks for game, title, description, author, cartdata_id)
uvx copier copy gh:koaning/geyser-pico8-template mygame
cd mygame && make test

# pull template improvements into an existing game
uvx copier update
```

Files are rendered through Jinja, so GitHub's "Use this template" button
doesn't work; use copier.

## What you get

A tiny working sample game (walk a grid, grab gems for 30 seconds, best score
saved) that passes `make test`, `make serve` and `make screenshots` from the
first commit, plus the shared toolchain:

| | |
|---|---|
| `make test` | `tests/test_*.lua`, cart smoke test, token meter, sound check |
| `make serve` | the cart in the browser on a LÖVE PICO-8 stand-in via love.js |
| `make screenshots` | scripted run → `docs/screenshots/` and the cart label |
| `make music` | compile `tools/scores.lua` into `__sfx__` / `__music__` |
| `make pico8`, `make play` | run / export with the real PICO-8 |

**Template-managed** (overwritten by `copier update`; fix them here):
`Makefile`, `AGENTS.md`, `CLAUDE.md`, `.github/workflows/`, `.conductor/`,
`paseo.json`, `scripts/`, `site/`, `pico8/preview/{main,conf,synth}.lua`,
`tests/pico8_stub.lua`, `tools/{cart,label,p8tokens,pico8_env,serve,sfx}`.

**Game-owned** (generated once, then left alone, see `_skip_if_exists` in
`copier.yml`): `game.mk` (`GAME`, `TITLE`, `PREVIEW_EXTRA`, `TEST_EXTRA`,
extra targets), `GAME.md`, `README.md`, `pico8/<game>.p8`,
`pico8/{main,rules}.lua`, `pico8/preview/shots.lua`, `tests/test_*.lua`,
`tests/cart_smoke.lua`, `tools/scores.lua`, `docs/screenshots/`.

## Developing the template

The template lives in `template/`. To try it out:

```sh
uvx copier copy --defaults --trust --vcs-ref HEAD -d game=demo . /tmp/demo
cd /tmp/demo && make test
```

`.github/workflows/template.yml` does that in CI, and also builds the site and
the screenshots.
