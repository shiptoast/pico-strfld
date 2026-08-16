function init_music_menu()
 music_track=0
 music(-1)
end

function music_menu_label()
 return "music: "..(music_track==0 and "off" or "track "..music_track)
end

function select_music_track(n)
 music_track=n%(#music_tracks+1)
 if music_track==0 then music(-1)
 else music(music_tracks[music_track]) end
end

function update_music_menu()
 if game_state!=0 then
  if music_track!=0 then
   music_track=0
   music(-1)
  end
  return
 end
 if btnp(0) then select_music_track(music_track-1)
 elseif btnp(1) then select_music_track(music_track+1) end
end

function draw_music_menu()
 if game_state!=0 or fade>0 then return end
 local label="< "..music_menu_label().." >"
 print(label,64-#label*2,94,6)
end
