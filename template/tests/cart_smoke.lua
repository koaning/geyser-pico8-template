-- Cart smoke test: boots pico8/main.lua on a stubbed PICO-8 API
-- (tests/pico8_stub.lua) and plays it through its buttons: start from the
-- title, walk to a few gems, bump into the edge, let the time run out, and
-- check the best score is saved.
--
-- Run from the repo root:  luajit tests/cart_smoke.lua

package.path = "tests/?.lua;tools/?.lua;" .. package.path
local stub = require("pico8_stub")
local LEFT, RIGHT, UP, DOWN, O = stub.LEFT, stub.RIGHT, stub.UP, stub.DOWN, stub.O

local function boot(save)
  return stub.boot({ seed = 7, save = save, peek = { "scene", "st", "left", "best" } })
end

local game = boot()
assert(game.peek().scene == "title", "the cart should boot into the title")
game.wait(10)
game.frame({ O })
local s = game.peek()
assert(s.scene == "play" and s.st.score == 0, "O should start a game")

-- the top left corner: up is the edge
game.frame({ UP })
assert(game.peek().st.y == 1, "the edge should stop you")

-- walk to the gem three times
for n = 1, 3 do
  local st = game.peek().st
  while st.x ~= st.gx or st.y ~= st.gy do
    game.frame({ st.x < st.gx and RIGHT or st.x > st.gx and LEFT or st.y < st.gy and DOWN or UP })
    game.frame()
    if st.score == n then break end
  end
  assert(st.score == n, "walking onto the gem should score")
end

-- wait for the clock
for _ = 1, 30 * 60 do
  if game.peek().scene == "title" then break end
  game.frame()
end
assert(game.peek().scene == "title", "the game should end when the time runs out")
assert(game.data[0] == 3, "the best score should be saved")

-- a reboot remembers it
local again = boot(game.data)
assert(again.peek().best == 3, "the best score should survive a reboot")

print("Cart smoke: played a game through the buttons, scored 3, best score saved.")
