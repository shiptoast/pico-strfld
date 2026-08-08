pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include ../constants.lua
#include ../story.lua
#include ../world.lua
#include ../ship.lua
#include ../radio.lua

function check(ok,label)
 if not ok then
  printh("fail: "..label)
  extcmd("shutdown")
 end
end

function trail_stats(index)
 local count,x,y=0,0,0
 for p in all(ship.finale_particles[index]) do
  if p.col!=0 then
   count+=1
   x+=p.x
   y+=p.y
  end
 end
 if count>0 then
  x/=count
  y/=count
 end
 return count,x,y
end

function _init()
 srand(1986)
 init_story()
 init_ship()
 init_world()
 init_radio()

 set_playtest_checkpoint(11)
 check(game_state==1 and story_state==58,"checkpoint eleven preserved")
 check(radio_offset>0 and radio_on,"checkpoint eleven keeps ending gate")
 advance_playtest_checkpoint()
 check(finale_checkpoint,"finale checkpoint selected")
 check(completed_planets()==11,"finale checkpoint preserves world")
 check(story_state==60 and game_state==3,"finale checkpoint enters ending")
 check(fade==0 and finale_tick==0,"finale checkpoint starts visible")
 check(radio_offset==0 and not radio_on,"finale checkpoint radio off")
 check(stat(49)==4,"finale checkpoint music")
 check(#ship.finale_particles[1]==24 and #ship.finale_particles[2]==24,"trail pool sizes")

 local x1,y1=finale_ship_position(1)
 local x2,y2=finale_ship_position(2)
 local p1=ship.finale_particles[1][1]
 local p2=ship.finale_particles[2][1]
 p1.life=p1.maxlife
 p2.life=p2.maxlife
 update_finale_particles()
 check(abs(p1.x-x1-sin(ship.angle)*5)<0.01 and abs(p1.y-y1-cos(ship.angle)*5)<0.01,"first trail origin")
 check(abs(p2.x-x2-sin(ship.angle)*5)<0.01 and abs(p2.y-y2-cos(ship.angle)*5)<0.01,"second trail origin")

 for i=1,24 do update_finale_particles() end
 local count1,cx1,cy1=trail_stats(1)
 local count2,cx2,cy2=trail_stats(2)
 check(count1>0 and count2>0,"both trails live")
 check(dist2(cx1,cy1,cx2,cy2)>4,"trails spatially distinct")
 for i=1,24 do update_finale_particles() end
 count1,cx1,cy1=trail_stats(1)
 count2,cx2,cy2=trail_stats(2)
 check(count1>0 and count2>0,"both trails persist")
 check(dist2(cx1,cy1,cx2,cy2)>4,"trails remain distinct")
 advance_playtest_checkpoint()
 check(finale_checkpoint and game_state==3,"finale checkpoint cap")

 printh("starfield finale: passed")
 extcmd("shutdown")
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
