-- game rules, kept free of drawing and input so tests/test_rules.lua can
-- run them under luajit (tools/pico8_env.lua)

-- a w x h field: you start in the top left corner, a gem lies somewhere else
function rules_new(w, h)
  local st = { w = w, h = h, x = 1, y = 1, score = 0 }
  rules_place_gem(st)
  return st
end

-- drops the gem on a random cell that isn't yours
function rules_place_gem(st)
  repeat
    st.gx, st.gy = flr(rnd(st.w)) + 1, flr(rnd(st.h)) + 1
  until st.gx ~= st.x or st.gy ~= st.y
end

-- one step by dx, dy: "bump" into the edge (you stay put), "gem" when you
-- pick the gem up (it lands somewhere new), else "step"
function rules_move(st, dx, dy)
  local nx, ny = st.x + dx, st.y + dy
  if nx < 1 or ny < 1 or nx > st.w or ny > st.h then return "bump" end
  st.x, st.y = nx, ny
  if nx == st.gx and ny == st.gy then
    st.score = st.score + 1
    rules_place_gem(st)
    return "gem"
  end
  return "step"
end
