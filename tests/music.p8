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

function _init()
 reload(0x3100,0x3100,0x1200,"../starfield.p8")
 init_music_menu()
 check(music_track==0 and music_menu_label()=="music: off","music menu starts off")
 check(change_music_track(2) and music_track==1,"right selects track one")
 check(music_menu_label()=="music: track 1","music track label")
 check(stat(54)==0 and stat(57),"track starts at pattern zero")
 check(change_music_track(2) and music_track==0,"right wraps to off")
 check(not stat(57),"off stops music")
 check(change_music_track(1) and music_track==1,"left wraps to track one")
 check(change_music_track(4) and music_track==1,"select keeps menu open")
 patterns_played=stat(55)
end

function _update()
 if stat(55)>patterns_played then
  check(stat(54)==0 and stat(57),"track loops to pattern zero")
  change_music_track(1)
  check(music_track==0 and not stat(57),"left returns to off")
  printh("starfield music: passed")
  extcmd("shutdown")
 end
end
