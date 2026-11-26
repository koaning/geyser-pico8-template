-- Sound for the cart, compiled by `make music` (tools/sfx.lua, which
-- explains the notation). sfx 0-2 are the effects, the song starts at sfx 8.
return {
  first_sfx = 8,

  effects = {
    -- a soft low footstep
    { name = "step", speed = 2, notes = "d1:1:1:5" },
    -- picking up a gem: a quick rising fifth
    { name = "gem", speed = 3, notes = "c3:0:3:0 g3:0:3:0 c4:0:2:5" },
    -- a muted thud at the edge
    { name = "bump", speed = 5, notes = "a0:1:3:3 a0:1:1:5" },
  },

  songs = {
    {
      name = "song", title = "little loop", speed = 50,
      patterns = {
        a = { "cmaj7", "am7", "fmaj7", "dm7/g7" },
      },
      order = { "a" },
    },
  },
}
