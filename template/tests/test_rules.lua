-- Rule tests: run pico8/rules.lua (the cart's own code) under luajit.
--
-- Run from the repo root:  luajit tests/test_rules.lua

package.path = "tools/?.lua;" .. package.path
local pico8_env = require("pico8_env")

local passed = 0
local function test(name, fn)
  local ok, err = pcall(fn)
  if not ok then
    io.stderr:write("FAIL " .. name .. "\n  " .. tostring(err) .. "\n")
    os.exit(1)
  end
  passed = passed + 1
end

local function fresh(seed)
  local env = pico8_env.new(".", pico8_env.make_rng(seed or 1))
  return env, env.rules_new(5, 4)
end

test("you start in the top left, the gem elsewhere", function()
  for seed = 1, 50 do
    local _, st = fresh(seed)
    assert(st.x == 1 and st.y == 1 and st.score == 0)
    assert(st.gx >= 1 and st.gx <= 5 and st.gy >= 1 and st.gy <= 4)
    assert(st.gx ~= 1 or st.gy ~= 1, "the gem shouldn't start under you")
  end
end)

test("the edge stops you", function()
  local env, st = fresh()
  assert(env.rules_move(st, -1, 0) == "bump")
  assert(env.rules_move(st, 0, -1) == "bump")
  assert(st.x == 1 and st.y == 1)
end)

test("walking onto the gem scores and moves it", function()
  local env, st = fresh()
  st.gx, st.gy = 2, 1
  assert(env.rules_move(st, 1, 0) == "gem")
  assert(st.score == 1 and st.x == 2)
  assert(st.gx ~= 2 or st.gy ~= 1, "the gem should land somewhere new")
  st.gx, st.gy = 5, 4
  assert(env.rules_move(st, 0, 1) == "step")
  assert(st.score == 1 and st.y == 2)
end)

print("Rules: " .. passed .. " tests passed.")
