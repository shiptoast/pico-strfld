pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include ../constants.lua
#include ../music.lua

function check(ok,label)
 if not ok then
  printh("fail: "..label)
  extcmd("shutdown")
 end
end

function music_words_match(loud)
 local i=1
 for s=1,4 do
  for note=0,31 do
   local expected=music_sfx_words[i]
   local volume=(expected>>9)&7
   if loud and volume>0 then
    expected=(expected&0xf1ff)|(min(7,volume+2)<<9)
   end
   if peek2(0x3200+s*68+note*2)!=expected then return false end
   i+=1
  end
 end
 return true
end

function _init()
 reload(0x3100,0x3100,0x1200,"../starfield.p8")
 game_state=0
 init_music_menu()
 check(music_track==0 and not music_menu_visible,"title menu starts hidden")
 show_music_menu()
 check(music_menu_visible and music_menu_label()=="music: off","up reveals title menu")
 select_music_track(1)
 check(music_track==1,"right selects track one")
 check(music_menu_label()=="music: track 1","music track label")
 check(music_words_match(true),"title music preserves boosted note data")
 check(stat(54)==0 and stat(57),"track starts at pattern zero")
 select_music_track(2)
 check(music_track==0,"right wraps to off")
 check(not stat(57),"off stops music")
 check(music_words_match(false),"off restores gameplay sfx data")
 select_music_track(-1)
 check(music_track==1,"left wraps to track one")
 patterns_played=stat(55)
end

function _update()
 if stat(55)>patterns_played then
  check(stat(54)==0 and stat(57),"track loops to pattern zero")
  game_state=1
  update_music_menu()
  check(not music_menu_visible and music_track==0 and not stat(57),"gameplay closes menu and stops music")
  check(music_words_match(false),"gameplay restores sfx data")
  printh("starfield music: passed")
  extcmd("shutdown")
 end
end
