function init_story()
 game_state=0 -- title, play, fadeout, finale, black
 story_state=0
 pause_story=true
 story_scan=0
 story_tick=0
 story_hold=0
 story_input_consumed=false
 fade=128
 finale_tick=0
end

function set_story(n)
 story_state=clamp(n,0,#story_text-1)
 pause_story=story_pause[story_state+1]
 story_scan=0
 story_tick=0
 story_hold=60
 sfx(0)
end

function advance_story()
 if story_state>=#story_text-1 then
  game_state=2
  pause_story=true
  return
 end
 set_story(story_state+1)
end

function press_story_down()
 if story_scan<#story_text[story_state+1] then
  story_scan=#story_text[story_state+1]
  story_input_consumed=true
  return
 end
 if pause_story and story_hold==0 and not in_list(artifact_cues,story_state) and story_state!=3 then
  advance_story()
 end
end

function update_story()
 story_input_consumed=false
 if game_state==0 then
  fade=max(0,fade-0.5)
  if fade==0 and btnp(3) then
   game_state=1
   set_story(0)
  end
  return
 end

 if game_state==2 then
  fade=min(128,fade+0.25)
  if fade>=128 then
   game_state=3
   finale_tick=0
   sfx(4,3)
  end
  return
 end

 if game_state==3 then
  finale_tick+=1
  if finale_tick>1500 and finale_tick%4==0 then fade=max(0,fade-1) end
  if finale_tick>4380 then
   game_state=4
   fade=128
  end
  return
 end

 story_hold=max(0,story_hold-1)
 if btnp(3) then press_story_down() end

 story_tick+=1
 if story_tick%2==0 and story_scan<#story_text[story_state+1] then
  story_scan+=1
  if story_scan%3==0 then sfx(0) end
 end
end

function draw_story()
 if game_state==0 then
  print("starfield",33,28,7)
  print("a quiet search",34,39,6)
  if fade==0 then print("press down to begin",25,82,7) end
  return
 end
 if game_state>=3 then return end

 local text=sub(story_text[story_state+1],1,story_scan)
 local line1=text
 local line2=""
 if #text>31 then
  local cut=31
  while cut>1 and sub(text,cut,cut)!=" " do cut-=1 end
  line1=sub(text,1,cut-1)
  line2=sub(text,cut+1)
 end
 rectfill(0,112,127,127,7)
 line(0,112,127,112,6)
 print(line1,2,114,5)
 print(line2,2,120,5)
 if pause_story and flr(t()/0.5)%2==0 then print("*down*",99,104,7) end
end
