pico-8 cartridge // http://www.pico-8.com
version 42
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

function _init()
 srand(1986)
 init_story()
 init_ship()
 init_world()
 init_radio()

 check(#story_text==61,"story count")
 check(#story_pause==61,"pause count")
 check(#artifacts==11,"artifact count")
 check(#stars==150,"star count")

 game_state=1
 for count=1,#artifacts do
  local stale=artifacts[count]
  stale.found=true
  stale.shutdown=77
  stale.flicker=false
  stale.visible=true
  ship.target=stale
  ship.orbit=stale
  ship.vx=1
  ship.vy=-1
  radio_offset=stale.freq
  signal_strength=1
  radio_on=true
  broadcast_tick=99
  static_tick=99

  advance_playtest_checkpoint()
  check(completed_planets()==count,"checkpoint count "..count)
  check(story_state==artifact_cues[count]+1,"checkpoint story "..count)
  check(game_state==1,"checkpoint stays in play "..count)
  check(not ship.target and not ship.orbit,"checkpoint clears ship state "..count)
  check(ship.vx==0 and ship.vy==0,"checkpoint clears velocity "..count)
  check(signal_strength==0 and broadcast_tick==0 and static_tick==0,"checkpoint clears radio state "..count)

  for i=1,#artifacts do
   local a=artifacts[i]
   check(a.off==(i<=count),"checkpoint artifact off "..count..":"..i)
   check(not a.found and a.flicker and not a.visible,"checkpoint artifact transient "..count..":"..i)
   check(a.shutdown==(i<=count and 180 or 0),"checkpoint artifact shutdown "..count..":"..i)
   check(a.col==(i<=count and 5 or a.base_col),"checkpoint artifact color "..count..":"..i)
  end

  if count<#artifacts then
   local next_artifact=artifacts[count+1]
   radio_offset=next_artifact.freq
   update_radio()
   check(ship.target==next_artifact,"checkpoint next search "..count)
  end
 end

 advance_playtest_checkpoint()
 advance_playtest_checkpoint()
 check(completed_planets()==11,"checkpoint cap")
 check(story_state==58,"checkpoint cap story")
 check(game_state==1,"checkpoint does not skip ending")
 check(radio_offset>0 and radio_on,"checkpoint finale radio remains on")
 set_story(60)
 radio_offset=0.5
 poke(0x5f4c,16)
 update_radio()
 poke(0x5f4c,0)
 check(game_state==2,"checkpoint preserves radio-off ending")

 init_story()
 init_ship()
 init_world()
 init_radio()

 game_state=1
 set_story(0)
 story_hold=0
 story_scan=3
 local typing_state=story_state
 press_story_down()
 check(story_scan==#story_text[story_state+1],"down completes typing")
 check(story_state==typing_state,"typing skip does not advance")
 check(story_input_consumed,"typing skip consumes down")
 story_input_consumed=false
 press_story_down()
 check(story_state==typing_state+1,"second down advances")

 local spawn_x,spawn_y=ship.x,ship.y
 for i=1,#artifacts do
  for j=1,#artifacts do
   artifacts[j].off=j!=i
   artifacts[j].found=false
  end
  local a=artifacts[i]
  ship.x=spawn_x
  ship.y=spawn_y
  ship.orbit=nil
  set_story(radio_cues[i])
  radio_offset=a.freq
  update_radio()
  check(story_state==radio_cues[i],"planet "..i.." requires movement")
  check(not ship.orbit,"planet "..i.." no false orbit")
  check(dist2(ship.x,ship.y,a.x,a.y)>52,"planet "..i.." outside spawn range")

  ship.x=a.x
  ship.y=a.y+20
  update_radio()
  check(story_state==radio_cues[i]+1,"planet "..i.." proximity arrival")
  check(ship.orbit==a,"planet "..i.." close orbit")
 end

 init_ship()
 init_world()
 init_radio()

 set_story(4)
 radio_offset=24
 update_radio()
 check(story_state==5,"first signal gate")
 check(ship.target==artifacts[1],"radio target")
 check(artifacts[1].visible,"map reveal")

 set_story(8)
 update_radio()
 check(story_state==8,"arrival requires movement")
 check(not ship.orbit,"no false close orbit")
 check(dist2(ship.x,ship.y,artifacts[1].x,artifacts[1].y)>52,"spawn outside arrival range")

 ship.x=artifacts[1].x
 ship.y=artifacts[1].y+20
 update_radio()
 check(story_state==9,"arrival gate")
 check(ship.orbit==artifacts[1],"close orbit")
 check(pause_story,"arrival dialog pauses flight")
 ship.vx=0
 ship.vy=0
 local orbit_y=ship.y
 update_ship()
 check(ship.vy<0 and ship.y<orbit_y,"orbit continues during dialog")

 ship.x=artifacts[1].x
 ship.y=artifacts[1].y+20
 ship.vx=0.25
 ship.vy=0
 local late_orbit_radius=0
 local late_orbit_speed=0
 for i=1,600 do
  update_radio()
  update_ship()
  if i>480 then
   late_orbit_radius=max(late_orbit_radius,dist2(ship.x,ship.y,artifacts[1].x,artifacts[1].y))
   late_orbit_speed=max(late_orbit_speed,dist2(0,0,ship.vx,ship.vy))
  end
 end
 check(ship.orbit==artifacts[1],"orbit remains captured")
 check(late_orbit_radius>8,"orbit does not collapse into planet")
 check(late_orbit_speed>0.1,"orbit preserves momentum")

 ship.x=artifacts[1].x
 ship.y=artifacts[1].y
 ship.vx=0.25
 ship.vy=0
 update_orbit()
 check(abs(ship.angle-0.25)<0.001,"orbit faces rightward velocity")
 ship.vx=0
 ship.vy=-0.25
 update_orbit()
 check(abs(ship.angle)<0.001,"orbit faces upward velocity")
 ship.vx=-0.25
 ship.vy=0
 update_orbit()
 check(abs(ship.angle-0.75)<0.001,"orbit faces leftward velocity")
 ship.vx=0
 ship.vy=0.25
 update_orbit()
 check(abs(ship.angle-0.5)<0.001,"orbit faces downward velocity")

 set_story(12)
 artifacts[1].found=true
 for i=1,180 do update_world() end
 check(artifacts[1].off,"artifact shutdown")
 check(story_state==13,"shutdown gate")
 check(completed_planets()==1,"natural checkpoint count")
 advance_playtest_checkpoint()
 check(completed_planets()==2,"natural then shortcut advances")
 check(artifacts[2].off and not artifacts[3].off,"natural shortcut boundary")
 check(story_state==artifact_cues[2]+1,"natural shortcut story")

 set_story(60)
 advance_story()
 check(game_state==2,"ending trigger")
 for i=1,512 do update_story() end
 check(game_state==3,"finale entry")
 check(stat(49)==4,"finale cue")
 for i=1,4381 do update_story() end
 check(game_state==4,"final black")

 cls()
 draw_ship(cx,cy,9,0.145)

 game_state=1
 pause_story=false
 ship.orbit=nil
 ship.angle=0.25
 ship.vx=0
 ship.vy=0
 poke(0x5f4c,2)
 update_ship()
 poke(0x5f4c,0)
 check(ship.angle>0.25,"right input")
 poke(0x5f4c,4)
 update_ship()
 poke(0x5f4c,0)
 check(abs(ship.vx)+abs(ship.vy)>0,"thrust input")

 local a=artifacts[1]
 a.rot=0
 local ax0,ay0=artifact_point(a,cx,cy,0,-10)
 a.rot=0.25
 local ax1,ay1=artifact_point(a,cx,cy,0,-10)
 check(abs(ax0-ax1)>5 and abs(ay0-ay1)>5,"artifact rotation")

 printh("starfield smoke: passed")
 extcmd("shutdown")
end
