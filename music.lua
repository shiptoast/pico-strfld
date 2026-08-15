function init_music_menu()
 music_track=0
 music(-1)
 refresh_music_menu()
end

function music_menu_label()
 return "music: "..(music_track==0 and "off" or "track "..music_track)
end

function refresh_music_menu()
 menuitem(2,music_menu_label(),change_music_track)
end

function select_music_track(n)
 music_track=n%(#music_tracks+1)
 if music_track==0 then music(-1)
 else music(music_tracks[music_track]) end
 refresh_music_menu()
end

function change_music_track(buttons)
 if buttons&1>0 then select_music_track(music_track-1)
 elseif buttons&2>0 then select_music_track(music_track+1) end
 return true
end
