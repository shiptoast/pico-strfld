function init_music_menu()
 music_track=0
 music_menu_visible=false
 music_sfx_words={}
 for s=1,4 do
  for note=0,31 do
   add(music_sfx_words,peek2(0x3200+s*68+note*2))
  end
 end
 music(-1)
end

function music_menu_label()
 return "music: "..(music_track==0 and "off" or "track "..music_track)
end

function select_music_track(n)
 music_track=n%(#music_tracks+1)
 if music_track==0 then
  music(-1)
  restore_music_sfx()
 else
  boost_music_sfx()
  music(music_tracks[music_track])
 end
end

function boost_music_sfx()
 local i=1
 for s=1,4 do
  for note=0,31 do
   local addr=0x3200+s*68+note*2
   local packed=music_sfx_words[i]
   local volume=(packed>>9)&7
   if volume>0 then
    packed=(packed&0xf1ff)|(min(7,volume+2)<<9)
   end
   poke2(addr,packed)
   i+=1
  end
 end
end

function restore_music_sfx()
 local i=1
 for s=1,4 do
  for note=0,31 do
   poke2(0x3200+s*68+note*2,music_sfx_words[i])
   i+=1
  end
 end
end

function show_music_menu()
 music_menu_visible=true
end

function update_music_menu()
 if game_state!=0 then
  music_menu_visible=false
  if music_track!=0 then
   music_track=0
   music(-1)
   restore_music_sfx()
  end
  return
 end
 if not music_menu_visible then
  if btnp(2) then show_music_menu() end
  return
 end
 if btnp(0) then select_music_track(music_track-1)
 elseif btnp(1) then select_music_track(music_track+1) end
end

function draw_music_menu()
 if game_state!=0 or fade>0 or not music_menu_visible then return end
 local label="< "..music_menu_label().." >"
 print(label,64-#label*2,94,6)
end
