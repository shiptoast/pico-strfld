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

function check_scene_star_motion(label)
 local back=stars[1]
 local front=stars[2]
 local wrap=stars[3]
 back.x=40
 back.y=40
 back.z=0.5
 front.x=40
 front.y=40
 front.z=1.5
 local vx,vy=starfield_motion()
 wrap.x=vx>0 and 0.1 or 127.9
 wrap.y=vy>0 and 0.1 or 111.9
 wrap.z=1.5
 update_world()
 local back_dx=back.x-40
 local back_dy=back.y-40
 local front_dx=front.x-40
 local front_dy=front.y-40
 check(dist2(0,0,back_dx,back_dy)>0.1,label.." positive displacement")
 check(abs(front_dx-back_dx*3)<0.01 and abs(front_dy-back_dy*3)<0.01,label.." parallax depth")
 check((vx>0 and wrap.x>127 or wrap.x<1) and (vy>0 and wrap.y>111 or wrap.y<1),label.." wrapping")
end

function _init()
 srand(1986)
 init_story()
 init_ship()
 init_world()
 init_radio()

 update_ship()
 check_scene_star_motion("intro star flyby")
 check(ship.vx==0 and ship.vy==0,"intro flyby is visual only")
 game_state=1
 ship.vx=0.2
 ship.vy=-0.1
 local flight_star=stars[1]
 flight_star.x=40
 flight_star.y=40
 flight_star.z=1
 update_world()
 check(abs(flight_star.x-39.8)<0.01 and abs(flight_star.y-40.1)<0.01,"gameplay star velocity")

 set_playtest_checkpoint(11)
 check(game_state==1 and story_state==58,"checkpoint eleven preserved")
 check(radio_offset>0 and radio_on,"checkpoint eleven keeps ending gate")
 check(playtest_checkpoint_label()=="checkpoint 11/11","checkpoint eleven label")
 advance_playtest_checkpoint()
 check(finale_checkpoint,"finale checkpoint selected")
 check(playtest_checkpoint_label()=="checkpoint 12/11","hidden checkpoint label")
 check(completed_planets()==11,"finale checkpoint preserves world")
 check(story_state==60 and game_state==3,"finale checkpoint enters ending")
 check(fade==0 and finale_tick==0,"finale checkpoint starts visible")
 check(radio_offset==0 and not radio_on,"finale checkpoint radio off")
 check(stat(49)==4,"finale checkpoint music")
 check(#ship.finale_particles[1]==24 and #ship.finale_particles[2]==24,"trail pool sizes")

 check_scene_star_motion("finale star flyby")
 check(ship.vx==0 and ship.vy==0,"finale flyby is visual only")

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
 check(playtest_checkpoint_label()=="checkpoint 12/11","hidden checkpoint label cap")

 printh("starfield finale: passed")
 extcmd("shutdown")
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
