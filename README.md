# geyser-pico8-template

A [copier](https://copier.readthedocs.io) template for bootstrapping PICO-8 games
with the toolchain shared by these three games:

- [koaning/mazing](https://github.com/koaning/mazing): crate-pushing puzzle
- [koaning/cairns](https://github.com/koaning/cairns): puzzle with a level generator
- [koaning/mossballs](https://github.com/koaning/mossballs): board game with an AI opponent

Part of the "geyser" family of game templates; a sibling
`geyser-love2d-template` for LÖVE games is planned (see PLAN.md).

**Status:** this repo only has the plan so far. See [PLAN.md](PLAN.md).

## Intended usage

```sh
# new game
copier copy gh:koaning/geyser-pico8-template mygame

# pull template improvements into an existing game
cd mygame && copier update
```

The repo will also be marked as a GitHub template, so "Use this template" works
too, but only the copier route gets later updates.
