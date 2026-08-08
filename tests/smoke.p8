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

function pixel_near(x,y,col)
 for py=y-1,y+1 do
  for px=x-1,x+1 do
   if pget(px,py)==col then return true end
  end
 end
 return false
end

function check_hut_radial(a,x,y,label)
 local base_x,base_y=-7,-9
 local d=sqrt(base_x*base_x+base_y*base_y)
 local dx,dy=base_x/d,base_y/d
 local hut_pivot_x,hut_pivot_y=base_x+dx,base_y+dy
 local pivot_x,pivot_y=artifact_point(a,x,y,hut_pivot_x,hut_pivot_y)
 local old_pivot_x,old_pivot_y=artifact_point(a,x,y,base_x,base_y)
 local apex_x,apex_y=artifact_hut_point(a,x,y,-7+dx,-17+dy,hut_pivot_x,hut_pivot_y)
 local mark_x,mark_y=artifact_hut_point(a,x,y,-6.5+dx,-16+dy,hut_pivot_x,hut_pivot_y)
 local old_mark_x,old_mark_y=artifact_hut_point(a,x,y,-6.5,-16,base_x,base_y)
 local left_x,left_y=artifact_hut_point(a,x,y,-12+dx,-9+dy,hut_pivot_x,hut_pivot_y)
 local right_x,right_y=artifact_hut_point(a,x,y,-2+dx,-9+dy,hut_pivot_x,hut_pivot_y)
 local radial_x=pivot_x-x
 local radial_y=pivot_y-y
 local axis_x=apex_x-pivot_x
 local axis_y=apex_y-pivot_y
 local edge_x=right_x-left_x
 local edge_y=right_y-left_y
 check(abs(axis_x*radial_y-axis_y*radial_x)<0.1 and axis_x*radial_x+axis_y*radial_y>0,"artifact hut follows radius "..label)
 check(abs(edge_x*radial_x+edge_y*radial_y)<0.1,"artifact hut edge is tangent "..label)
 check(pixel_near(apex_x,apex_y,5),"artifact hut roof renders radially "..label)
 check(pixel_near(left_x,left_y,6) and pixel_near(right_x,right_y,6),"artifact hut seated edge renders "..label)
 check(pget(mark_x,mark_y)==5 and pget(old_mark_x,old_mark_y)!=5,"artifact hut moves one pixel outward "..label)
 local pivot_r=sqrt((pivot_x-x)*(pivot_x-x)+(pivot_y-y)*(pivot_y-y))
 local old_pivot_r=sqrt((old_pivot_x-x)*(old_pivot_x-x)+(old_pivot_y-y)*(old_pivot_y-y))
 check(abs(pivot_r-old_pivot_r-1)<0.01,"artifact hut pivot moves one pixel outward "..label)
 local contact=0
 for i=0,4 do
  local scale=1-i/8
  local jx,jy=artifact_point(a,x,y,-7*scale,-9*scale)
  if pget(jx,jy)!=0 then contact+=1 end
 end
 check(contact==5,"artifact hut keeps surface contact "..label)
end

function visible_particle_count()
 local count=0
 for p in all(ship.particles) do
  if p.col!=0 then count+=1 end
 end
 return count
end

function _init()
 srand(1986)
 init_story()
 init_ship()
 init_world()
 init_radio()

 game_state=0
 fade=0
 for i=1,40 do update_ship() end
 check(visible_particle_count()>0,"title exhaust active")
 start_flight()
 check(game_state==1,"title enters flight")
 check(visible_particle_count()==0,"title exhaust clears for flight")

 check(#story_text==61,"story count")
 check(#story_pause==61,"pause count")
 check(#artifacts==11,"artifact count")
 check(#stars==150,"star count")

 game_state=1
 for count=1,#artifacts do
  pause_story=false
  ship.thrust=1
  for i=1,24 do update_particles(true) end
  check(visible_particle_count()>0,"checkpoint has exhaust "..count)
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
  check(visible_particle_count()==0,"checkpoint clears exhaust "..count)
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
 poke(0x5f4c,32)
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

 ship.x=world_size/2
 ship.y=world_size/2
 ship.target=artifacts[1]
 ship.target.x=ship.x+100
 ship.target.y=ship.y
 radio_offset=ship.target.freq
 ship.sonar_tick=45
 ship.sonar_period=90
 cls()
 draw_sonar()
 local sonar_pixels=0
 local sonar_miny=127
 local sonar_maxy=0
 local sonar_left=0
 local front_sum={0,0,0}
 local front_count={0,0,0}
 for py=0,127 do
  for px=0,127 do
   if pget(px,py)==12 then
    sonar_pixels+=1
    sonar_miny=min(sonar_miny,py)
    sonar_maxy=max(sonar_maxy,py)
    if px<cx then sonar_left+=1 end
    local rd=dist2(cx,cy,px,py)
    for i=0,2 do
     local d=((0.5+i/3)%1)*26+8
     if abs(rd-d)<1.5 then
      front_sum[i+1]+=py
      front_count[i+1]+=1
     end
    end
   end
  end
 end
 check(sonar_pixels>45 and sonar_maxy-sonar_miny>24,"sonar renders broad bubble arcs")
 check(sonar_left==0,"sonar stays target-directed")
 local front_mean={}
 for i=0,2 do
  local d=((0.5+i/3)%1)*26+8
  local sweep=(i-1)/72
  local front_x=cx+cos(sweep)*d
  local front_y=cy+sin(sweep)*d
  check(pixel_near(front_x,front_y,12),"sonar renders staggered successive arc fronts")
  front_mean[i+1]=front_sum[i+1]/max(1,front_count[i+1])
 end
 check(front_mean[1]>front_mean[2] and front_mean[2]>front_mean[3],"sonar blips offset between arc fronts")
 ship.target.x=ship.x
 ship.target.y=ship.y+100
 cls()
 draw_sonar()
 local sonar_minx=127
 local sonar_maxx=0
 local sonar_above=0
 for py=0,127 do
  for px=0,127 do
   if pget(px,py)==12 then
    sonar_minx=min(sonar_minx,px)
    sonar_maxx=max(sonar_maxx,px)
    if py<cy then sonar_above+=1 end
   end
  end
 end
 check(sonar_maxx-sonar_minx>24 and sonar_above==0,"sonar arcs follow turned target bearing")
 ship.target=nil
 cls()
 draw_sonar()
 sonar_pixels=0
 for py=0,127 do
  for px=0,127 do
   if pget(px,py)==12 then sonar_pixels+=1 end
  end
 end
 check(sonar_pixels==0,"sonar clears without a target")

 for a in all(artifacts) do a.visible=false end
 local marker_x=5+ship.x/world_size*22
 local marker_y=5+ship.y/world_size*22
 cls()
 draw_minimap(0)
 local marker_pixels=0
 for py=marker_y-1,marker_y+1 do
  for px=marker_x-1,marker_x+1 do
   if pget(px,py)==9 then marker_pixels+=1 end
  end
 end
 check(pget(marker_x,marker_y)==9 and marker_pixels==1,"minimap ship marker is one body-color pixel")
 cls()
 draw_minimap(0.5)
 marker_pixels=0
 for py=marker_y-1,marker_y+1 do
  for px=marker_x-1,marker_x+1 do
   if pget(px,py)==9 then marker_pixels+=1 end
  end
 end
 check(marker_pixels==0,"minimap ship marker keeps off blink phase")

 local collision=artifacts[1]
 collision.x=ship.x
 collision.y=ship.y
 collision.col=12
 collision.visible=true
 collision.off=false
 cls()
 draw_minimap(0)
 check(pget(marker_x,marker_y)==9,"minimap ship marker covers collocated artifact when lit")
 cls()
 draw_minimap(0.5)
 check(pget(marker_x,marker_y)==12,"minimap collocated artifact shows during ship off phase")

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

 game_state=0
 init_ship()
 for i=1,48 do update_ship() end
 local title_trail=0
 for p in all(ship.particles) do
  if p.col!=0 then title_trail=max(title_trail,dist2(cx,cy,p.x,p.y)) end
 end
 check(title_trail>18,"title exhaust reaches beyond hull")

 game_state=1
 init_ship()
 ship.thrust=1
 ship.angle=0
 for i=1,24 do update_particles(true) end
 ship.angle=0.18
 for i=1,24 do update_particles(true) end
 local trail_min_x=128
 local trail_max_x=0
 local trail_max_y=0
 for p in all(ship.particles) do
  if p.col!=0 then
   trail_min_x=min(trail_min_x,p.x)
   trail_max_x=max(trail_max_x,p.x)
   trail_max_y=max(trail_max_y,p.y)
  end
 end
 check(trail_max_y-cy>12,"turning exhaust retains old heading")
 check(trail_max_x-trail_min_x>12,"turning exhaust visibly whips")

 init_ship()
 set_story(8)
 local previous_dial_x=nil
 for sample=0,10 do
  radio_offset=sample*27.5
  local sample_angle=radio_dial_angle()
  local sample_x=cos(sample_angle)
  local sample_y=sin(sample_angle)
  check(sample_y<=0.001,"dial stays on top arc "..sample)
  if previous_dial_x then
   check(sample_x>=previous_dial_x,"dial sweeps left to right "..sample)
  end
  previous_dial_x=sample_x
 end
 radio_offset=0
 check(abs(cos(radio_dial_angle())+1)<0.001,"dial starts at left endpoint")
 radio_offset=275
 check(abs(cos(radio_dial_angle())-1)<0.001,"dial ends at right endpoint")

 radio_offset=100
 local dial_x=cos(radio_dial_angle())
 poke(0x5f4c,16)
 update_radio()
 poke(0x5f4c,0)
 check(radio_offset==100.5,"o tunes counterclockwise")
 check(cos(radio_dial_angle())>dial_x,"o moves dial right across top arc")
 local o_x=cos(radio_dial_angle())
 poke(0x5f4c,32)
 update_radio()
 poke(0x5f4c,0)
 check(radio_offset==100,"x tunes clockwise")
 check(cos(radio_dial_angle())<o_x,"x moves dial left across top arc")

 init_ship()
 set_story(8)
 poke(0x5f4c,4)
 update_ship()
 poke(0x5f4c,0)
 update_ship()
 check(not ship.autopilot,"single up remains manual")
 poke(0x5f4c,4)
 update_ship()
 check(ship.autopilot,"double up engages autopilot")
 poke(0x5f4c,0)
 local auto_speed=dist2(0,0,ship.vx,ship.vy)
 update_ship()
 check(ship.autopilot,"engaging tap does not cancel autopilot")
 check(dist2(0,0,ship.vx,ship.vy)>auto_speed,"autopilot applies thrust")
 poke(0x5f4c,4)
 update_ship()
 check(not ship.autopilot,"next up disengages autopilot")
 poke(0x5f4c,0)
 update_ship()

 init_ship()
 set_story(8)
 poke(0x5f4c,4)
 for i=1,20 do update_ship() end
 check(not ship.autopilot,"held up does not count as double tap")
 poke(0x5f4c,0)
 update_ship()
 init_world()
 poke(0x5f4c,4)
 update_ship()
 poke(0x5f4c,0)
 update_ship()
 poke(0x5f4c,4)
 update_ship()
 poke(0x5f4c,0)
 update_ship()
 check(ship.autopilot,"autopilot reengages")
 radio_offset=artifacts[1].freq
 ship.x=artifacts[1].x
 ship.y=artifacts[1].y+20
 update_radio()
 check(ship.orbit==artifacts[1],"autopilot planet arrival")
 check(not ship.autopilot,"planet arrival disengages autopilot")

 local a=artifacts[1]
 a.rot=0
 local ax0,ay0=artifact_point(a,cx,cy,0,-10)
 a.rot=0.25
 local ax1,ay1=artifact_point(a,cx,cy,0,-10)
 check(abs(ax0-ax1)>5 and abs(ay0-ay1)>5,"artifact rotation")

 a.rot=0
 a.col=12
 a.off=false
 a.size=32
 cls()
 draw_artifact(a,cx,cy)
 local lower_cross=0
 local upper_cross=0
 local stray_width=0
 local hut_pixels=0
 local beacon_pixels=0
 for py=cy-30,cy-20 do
  for px=cx-3,cx+3 do
   if pget(px,py)==12 then lower_cross+=1 end
  end
 end
 for py=cy-39,cy-31 do
  for px=cx-3,cx+3 do
   if pget(px,py)==12 then upper_cross+=1 end
  end
 end
 for py=cy-44,cy-23 do
  for px=cx-24,cx+24 do
   if abs(px-cx)>12 and pget(px,py)==12 then stray_width+=1 end
  end
 end
 for py=cy-19,cy-4 do
  for px=cx-17,cx+2 do
   if pget(px,py)==6 or pget(px,py)==5 then hut_pixels+=1 end
  end
 end
 for py=cy-47,cy-43 do
  for px=cx-2,cx+2 do
   if pget(px,py)==10 then beacon_pixels+=1 end
  end
 end
 check(lower_cross>0 and upper_cross>0,"artifact crossed lattice renders")
 check(stray_width==0,"artifact tower keeps tapered silhouette")
 check(hut_pixels>30,"artifact surface hut is solid")
 check(beacon_pixels>=13,"artifact beacon is materially enlarged")

 local new_beacon_x,new_beacon_y=artifact_point(a,cx,cy,0,-45)
 local old_beacon_x,old_beacon_y=artifact_point(a,cx,cy,0,-48)
 local hut_d=sqrt(130)
 local hut_dx,hut_dy=-7/hut_d,-9/hut_d
 local hut_pivot_x,hut_pivot_y=-7+hut_dx,-9+hut_dy
 local new_hut_x,new_hut_y=artifact_hut_point(a,cx,cy,-7+hut_dx,-11+hut_dy,hut_pivot_x,hut_pivot_y)
 local old_hut_x,old_hut_y=artifact_hut_point(a,cx,cy,-7+hut_dx,-14+hut_dy,hut_pivot_x,hut_pivot_y)
 check(pget(new_beacon_x,new_beacon_y)==10 and pget(old_beacon_x,old_beacon_y)!=10,"artifact beacon moves inward upright")
 check(pixel_near(new_hut_x,new_hut_y,6) and pget(old_hut_x,old_hut_y)!=6,"artifact hut moves inward upright")
 check_hut_radial(a,cx,cy,"upright")

 a.rot=0.125
 cls()
 draw_artifact(a,cx,cy)
 new_beacon_x,new_beacon_y=artifact_point(a,cx,cy,0,-45)
 old_beacon_x,old_beacon_y=artifact_point(a,cx,cy,0,-48)
 new_hut_x,new_hut_y=artifact_hut_point(a,cx,cy,-7+hut_dx,-11+hut_dy,hut_pivot_x,hut_pivot_y)
 old_hut_x,old_hut_y=artifact_hut_point(a,cx,cy,-7+hut_dx,-14+hut_dy,hut_pivot_x,hut_pivot_y)
 check(pget(new_beacon_x,new_beacon_y)==10 and pget(old_beacon_x,old_beacon_y)!=10,"artifact beacon moves inward rotated")
 check(pixel_near(new_hut_x,new_hut_y,6) and pget(old_hut_x,old_hut_y)!=6,"artifact hut moves inward rotated")
 check_hut_radial(a,cx,cy,"rotated")

 printh("starfield smoke: passed")
 extcmd("shutdown")
end
