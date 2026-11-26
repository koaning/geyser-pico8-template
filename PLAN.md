# Plan

## Why

mazing, cairns and mossballs all started from the same skeleton: a PICO-8 cart
split into `#include`d `.lua` files, LuaJIT tests on a stubbed PICO-8 API, a
LÖVE "preview player" standing in for PICO-8 (desktop, browser via love.js,
screenshots), a token-budget meter, sound data compiled from Lua, CI, and
GitHub Pages.

Each copy has since evolved on its own. Lines differing from mazing (as of
2026-11-26):

| file | cairns | mossballs |
|---|---|---|
| `.github/workflows/ci.yml`, `tools/serve.py`, `site/coi-serviceworker.js`, `pico8/preview/synth.lua`, `paseo.json`, `.conductor/settings.toml` | 0 | 0 |
| `tools/p8tokens.lua`, `tools/label.lua`, `.github/workflows/pages.yml`, `scripts/check-deps.sh`, `site/index.html`, `pico8/preview/conf.lua` | 2–9 | 3–4 |
| `tools/pico8_env.lua` | 0 | 16 |
| `AGENTS.md` | 19 | 29 |
| `Makefile` | 30 | 51 |
| `tools/music.lua` | 53 | 120 |
| `pico8/preview/main.lua` | 125 | 311 |
| `tests/cart_smoke.lua` | 142 | 269 |

- The small diffs are almost all just the hard-coded cart name
  (`pico8/mazing.p8` vs `pico8/cairns.p8`).
- The large diffs are real drift. mazing's preview player has `sspr`, `palt`,
  `sget`/`sset`, `cartdata`/`dget`/`dset`, `menuitem`, `poke`/`peek` and
  screenshot/label capture. mossballs stubs most of these or doesn't have them.
  Fixes made in one repo never reach the others.

The template is mainly meant to fix that drift (using `copier update`), not just
to save time when starting a game.

## Status (2026-11-26)

Steps 1–4 are done, in this repo instead of in mazing first: the template was
extracted from mazing's files and made name-agnostic while extracting.
Step 5 (adopting it in the games) is next. Differences from the plan as
written:

- The game name lives in a game-owned `game.mk` (`GAME := mazing`) that the
  shared Makefile `include`s. It also holds per-game hooks: `PREVIEW_EXTRA`
  (e.g. `tools/solve.lua` for mazing's shots), `TEST_EXTRA` and extra targets
  (e.g. cairns' level generator). The Lua tools take the cart from `$CART`
  (exported by the Makefile) or the only `pico8/*.p8` (`tools/cart.lua`).
- `site/index.html` has `@GAME@`/`@TITLE@` placeholders filled in by
  `make site`; `make pico8-preview` writes a `game.lua` into the .love for
  `conf.lua`; the preview player loads whichever `cart/*.p8` is in the .love.
- `tools/pico8_env.lua` loads every `#include` except `main.lua` (mazing:
  levels, rules; mossballs: board, rules, ai) instead of a hard-coded list;
  `opts.globals` covers mossballs' `ai_tick` stub. Its `sub(s, i)` now
  defaults to the end of the string like PICO-8 (it used to return one char;
  no game relied on that).
- `tests/run.lua` is gone: CI runs `make test`, and `make unit` runs every
  `tests/test_*.lua` (mazing's `test_rules`, mossballs' `test_brain`).
- `tools/scores.lua` returns `{ first_sfx, effects, songs }`; leaving
  `effects` out keeps the cart's own sfx (mossballs). The music check now
  requires a `music(n` call for every song's first pattern.
- Agent notes: AGENTS.md is generic and template-managed; game notes go in a
  game-owned `GAME.md`, and CLAUDE.md loads both.

## Steps

### 1. Make the shared files name-agnostic (in mazing)

- Makefile: `GAME ?= mazing`, and derive `CART := pico8/$(GAME).p8`,
  `dist/$(GAME)-p8.love`, `dist/$(GAME).bin`, etc. from it.
- `tools/p8tokens.lua`, `tools/label.lua`: take the cart path from `arg`
  (the Makefile passes `$(CART)`), no hard-coded default name.
- `pages.yml`, `check-deps.sh`, `site/index.html`, `preview/conf.lua`: read the
  name/title from one place (a Makefile variable or a small generated
  `game.lua`).
- Goal: everything outside the game-owned list below is byte-identical
  between games.

### 2. Split the preview player and smoke test into a core and game hooks

- `pico8/preview/main.lua`: the generic PICO-8 stand-in. Start from mazing's
  (the most complete) and add whatever mossballs has that mazing doesn't.
  `pico8/preview/shots.lua` stays game-owned (the scripted screenshot run).
- `tests/cart_smoke.lua`: move the generic stub API and boot loop into
  `tests/pico8_stub.lua`; keep the game-specific playthrough in
  `tests/cart_smoke.lua`.
- `tools/music.lua`: put the generic compiler in `tools/sfx.lua` and the scores
  in a game-owned `tools/scores.lua`.

### 3. Extract the template repo

Template-managed (updated via `copier update`):

```
.github/workflows/{ci,pages}.yml
.conductor/settings.toml, paseo.json
Makefile
scripts/check-deps.sh
site/{index.html,coi-serviceworker.js,lovejs/README.md}
pico8/preview/{main,conf,synth}.lua
tests/{run,pico8_stub}.lua
tools/{serve.py,p8tokens.lua,pico8_env.lua,label.lua,sfx.lua}
AGENTS.md            (generic part; game notes go in a separate section/file)
```

Game-owned (generated once as a minimal working example, then excluded from
updates via `_skip_if_exists`):

```
pico8/{{game}}.p8, pico8/main.lua, pico8/rules.lua
pico8/preview/shots.lua
tests/test_rules.lua, tests/cart_smoke.lua
tools/scores.lua
README.md
```

copier questions: `game` (slug, used for the cart filename), `title`,
`description`, `author`, maybe `cartdata_id`.

The sample game should be tiny (move a sprite on a grid, one rule, one sfx)
but pass `make test`, `make serve` and `make screenshots`, so CI is green from
the first commit.

### 4. Test the template in CI

A workflow in this repo runs `copier copy . /tmp/demo --defaults` and then
`make test` in `/tmp/demo`, so a broken template fails here and not in a game.

### 5. Adopt it in the three games

For each of mazing, cairns and mossballs:

1. On a branch, run `copier copy gh:koaning/geyser-pico8-template . --overwrite`
   (with `game=<name>`). This writes `.copier-answers.yml`.
2. Resolve the diff by hand. Port game-specific needs back into the template
   core (e.g. whatever API mossballs' AI or cairns' `tools/genlevels.lua`
   relies on) instead of keeping local patches.
3. `make test` and `make screenshots` must pass; open a PR.

Order: mazing first (the template is extracted from it), then cairns (closest
to mazing), then mossballs (biggest drift).

## Open questions

- Should the token meter, label tool and music compiler be a separate small
  Lua package instead of copied files? Copier is simpler for now.
- Is a plain GitHub template (no updates) still worth offering next to copier?
  It costs nothing, but games made that way will drift again.

## Sibling: geyser-love2d-template

A LÖVE template will live next to this one. To keep the two consistent:

- Same conventions: `make test` as the one CI entry point, `make serve` for the
  browser build via love.js, `make screenshots` for the README images,
  AGENTS.md describing the workflow, and copier for create and update.
- Candidates to share rather than copy: `tools/serve.py`,
  `site/coi-serviceworker.js`, the love.js fetch and site steps, and the
  Pages workflow. For now both templates carry their own copies; if they
  drift, move them into a shared `geyser-common` copier template (copier
  supports applying several templates to one project, each with its own
  answers file).
- The pico8 preview player is a LÖVE program already, so the love2d template
  can reuse its packaging, love.js and screenshot code.
- Name things the same way in both (`GAME`, `dist/$(GAME).love`, `site/`).
