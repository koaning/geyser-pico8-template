-- Scripted run for `love <game>-p8.love --shots <dir> [--label <file>] [--all]`
-- (`make screenshots`). It presses the buttons for a player and saves:
--
--   pico8-cart.png    the title screen as a cartridge: the cart label with
--                     the cart's title and byline, like PICO-8 shows carts
--   pico8-title.png   the title screen
--   pico8.png         a game in progress
--   with --label:     the title screen as __label__ text (tools/label.lua)
--
-- The cart's locals are read through the upvalues of its callbacks (see
-- peek), so the cart needs no test hooks.

local shots = {}
shots.__index = shots

-- cartdata the scripted run starts from (it never writes a save)
local SAVE = { [0] = 12 }

-- finds a local of the cart by name among the upvalues of its callbacks
local function peek(env, name)
  local seen, queue = {}, { env._update60 or env._update, env._draw }
  while #queue > 0 do
    local f = table.remove(queue, 1)
    if not seen[f] then
      seen[f] = true
      local i = 1
      while true do
        local n, v = debug.getupvalue(f, i)
        if not n then break end
        if n == name then return v end
        if type(v) == "function" then queue[#queue + 1] = v end
        i = i + 1
      end
    end
  end
end

function shots.new(dir, all, capture, label, cartridge)
  return setmetatable({ dir = dir, all = all, capture = capture, label = label, cartridge = cartridge,
    save = SAVE, buttons = {} }, shots)
end

function shots:start(env)
  local LEFT, RIGHT, UP, DOWN, O = 0, 1, 2, 3, 4
  local self_ = self

  local function frame(buttons, n)
    for _ = 1, n or 1 do
      self_.buttons = {}
      for _, b in ipairs(buttons or {}) do self_.buttons[b] = true end
      coroutine.yield()
    end
  end

  local function shot(name)
    self_.capture(self_.dir .. "/" .. name, 4)
  end

  self.co = coroutine.create(function()
    frame(nil, 30)
    shot("pico8-title.png")
    self_.cartridge(self_.dir .. "/pico8-cart.png")
    if self_.label then self_.label() end

    frame({ O })
    frame()
    -- walk to two gems
    for _ = 1, 2 do
      local st = peek(env, "st")
      local score = st.score
      while st.score == score do
        frame({ st.x < st.gx and RIGHT or st.x > st.gx and LEFT or st.y < st.gy and DOWN or UP })
        frame(nil, 6)
      end
    end
    frame({ DOWN })
    frame(nil, 6)
    shot("pico8.png")
  end)
end

-- called once per cart frame: false when the script is done
function shots:tick()
  if not self.co or coroutine.status(self.co) == "dead" then return false end
  local ok, err = coroutine.resume(self.co)
  if not ok then error(err) end
  return coroutine.status(self.co) ~= "dead"
end

return shots
