function _init()
 srand(1986)
 init_story()
 init_ship()
 init_world()
 init_radio()
 refresh_playtest_menu()
end

function _update60()
 update_story()
 update_radio()
 update_ship()
 update_world()
end

function draw_fade()
 if fade<=0 then return end
 if fade>=128 then
  rectfill(0,0,127,127,0)
  return
 end
 if fade<32 then fillp(0x1111)
 elseif fade<64 then fillp(0x5a5a)
 elseif fade<96 then fillp(0xaaaa)
 else fillp(0xeeee) end
 rectfill(0,0,127,127,0)
 fillp()
end

function _draw()
 cls(0)
 draw_stars(false)

 if game_state==1 or game_state==2 then
  draw_artifacts()
  draw_particles()
  draw_ship(cx,cy,9,ship.angle)
 elseif game_state==0 then
  draw_particles()
  draw_ship(cx,cy,9,ship.angle)
 elseif game_state==3 then
  draw_particles()
  draw_ship(cx+5,cy+5,9,ship.angle)
  draw_ship(cx-5,cy-5,15,ship.angle)
 end

 draw_stars(true)
 if game_state==1 or game_state==2 then
  draw_sonar()
  draw_minimap()
  draw_radio()
 end
 draw_story()
 draw_fade()
end
