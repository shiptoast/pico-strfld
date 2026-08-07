function init_radio()
 radio_offset=0
 signal_strength=0
 broadcast_range=8
 radio_on=false
 static_tick=0
 broadcast_tick=0
end

function update_radio()
 if game_state!=1 and game_state!=2 then return end

 local can_tune=not pause_story or story_state==3 or story_state==4 or story_state==60
 if can_tune and btn(4) then
  radio_offset=min(275,radio_offset+0.5)
  if story_state==3 then advance_story() end
 end
 if can_tune and btn(5) then
  radio_offset=max(0,radio_offset-0.5)
  if story_state==60 and radio_offset==0 then advance_story() end
 end

 for a in all(artifacts) do a.visible=false end
 ship.target=nil
 signal_strength=0

 if radio_offset==0 then
  if radio_on then sfx(2) end
  radio_on=false
  ship.orbit=nil
  return
 end
 radio_on=true

 local candidates={}
 for a in all(artifacts) do
  local closeness=abs(radio_offset-a.freq)
  if closeness<broadcast_range and not a.off then
   add(candidates,{a=a,strength=1-closeness/broadcast_range})
  end
 end

 for c in all(candidates) do
  if not ship.target or c.strength>signal_strength then
   ship.target=c.a
   signal_strength=c.strength
  end
 end

 if ship.target then
  ship.target.visible=true
  local d=dist2(ship.x,ship.y,ship.target.x,ship.target.y)
  signal_strength=clamp(signal_strength+(1-d/world_size)*0.35,0,1)
  ship.sonar_period=20+(1-signal_strength)*100
  broadcast_tick+=1
  local song_gap=flr(16+(1-signal_strength)*28)
  if broadcast_tick%song_gap==0 and not ship.target.found then
   sfx(3,2,(ship.target.song-1)*2,4)
  end
  if story_state==4 and signal_strength>0.5 then advance_story() end
  if d<52 then
   stop_autopilot()
   ship.orbit=ship.target
   if in_list(radio_cues,story_state) then
    advance_story()
    sfx(2)
   end
   if btnp(3) and not story_input_consumed and (not pause_story or in_list(artifact_cues,story_state)) then
    ship.target.found=true
   end
  else
   ship.orbit=nil
  end
 else
  ship.orbit=nil
  broadcast_tick=0
  static_tick+=1
  if static_tick%24==0 then sfx(2) end
 end
end

function radio_dial_angle()
 return (0.5+radio_offset/275*0.5)%1
end

function draw_radio()
 rectfill(2,83,36,109,6)
 rectfill(4,85,34,107,5)
 rectfill(5,86,18,100,1)
 for x=6,17,3 do
  for y=87,99,3 do pset(x,y,6) end
 end
 circfill(27,94,8,1)
 circ(27,94,7,7)
 local a=radio_dial_angle()
 line(27,94,27+cos(a)*6,94+sin(a)*6,9)
 rectfill(20,103,32,105,1)
 if radio_offset>0 then
  rectfill(20,103,20+signal_strength*12,105,signal_strength>0.7 and 10 or 9)
 end
 print(flr(radio_offset),5,102,7)
end
