function init_world()
 stars={}
 for i=1,150 do
  add(stars,{
   x=rnd(sw),y=rnd(112),z=0.35+rnd(1.4),
   size=flr(rnd(2))+1,
   col=rnd(1)<0.15 and (8+flr(rnd(7))) or 6
  })
 end

 -- Fixed counterparts to the original random broadcasts ensure that
 -- every cartridge is completable while retaining a large search space.
 local data={
  {2220,1880,24,8},{1680,2750,48,9},{2860,2420,72,10},
  {3150,1250,96,11},{940,1720,120,12},{3520,3300,144,13},
  {1180,3450,168,14},{2600,3660,192,8},{620,740,216,9},
  {3750,680,240,10},{2050,460,264,11}
 }
 artifacts={}
 local song=0
 for d in all(data) do
  song+=1
  add(artifacts,{
   x=d[1],y=d[2],freq=d[3],col=d[4],
   base_col=d[4],
   song=song,
   size=36+flr(rnd(18)),rot=rnd(1),dir=rnd(1)<0.5 and -1 or 1,
   visible=false,found=false,off=false,shutdown=0,flicker=true
  })
 end
end

function completed_planets()
 local count=0
 for a in all(artifacts) do
  if a.off then count+=1 end
 end
 return count
end

function set_playtest_checkpoint(count)
 count=clamp(count,0,#artifacts)
 for i=1,#artifacts do
  local a=artifacts[i]
  local completed=i<=count
  a.off=completed
  a.found=false
  a.shutdown=completed and 180 or 0
  a.flicker=true
  a.visible=false
  a.col=completed and 5 or a.base_col
 end

 ship.target=nil
 ship.orbit=nil
 ship.vx=0
 ship.vy=0
 ship.thrust=0
 clear_particles()
 stop_autopilot()
 ship.up_was_down=false
 ship.sonar_tick=0
 ship.sonar_period=90
 radio_offset=count==#artifacts and artifacts[#artifacts].freq or 0
 signal_strength=0
 radio_on=radio_offset>0
 static_tick=0
 broadcast_tick=0
 game_state=1
 fade=0
 finale_tick=0
 if count>0 then set_story(artifact_cues[count]+1)
 else set_story(radio_cues[1]) end
end

function refresh_playtest_menu()
 local count=completed_planets()
 menuitem(1,"checkpoint "..count.."/"..#artifacts,advance_playtest_checkpoint)
end

function advance_playtest_checkpoint()
 set_playtest_checkpoint(min(#artifacts,completed_planets()+1))
 refresh_playtest_menu()
end

function update_world()
 for s in all(stars) do
  s.x-=ship.vx*s.z
  s.y-=ship.vy*s.z
  if s.x<0 then s.x+=sw end
  if s.x>=sw then s.x-=sw end
  if s.y<0 then s.y+=112 end
  if s.y>=112 then s.y-=112 end
 end

 for a in all(artifacts) do
  a.rot=(a.rot+0.001*a.dir)%1
  if a.found and not a.off then
   a.shutdown+=1
   a.flicker=flr(a.shutdown/3)%2==0
   if a.shutdown==1 then sfx(3) end
   if a.shutdown>=180 then
    a.off=true
    a.flicker=true
    a.col=5
    ship.target=nil
    ship.orbit=nil
    refresh_playtest_menu()
    advance_story()
   end
  end
 end
end

function draw_stars(front)
 for s in all(stars) do
  if (s.z>1)==front then
   if s.size==1 then pset(s.x,s.y,s.col)
   else rectfill(s.x-1,s.y-1,s.x,s.y,s.col) end
  end
 end
end

function artifact_screen(a)
 return cx+(a.x-ship.x),cy+(a.y-ship.y)
end

function draw_artifacts()
 for a in all(artifacts) do
  local x,y=artifact_screen(a)
  if abs(x-cx)<170 and abs(y-cy)<150 and a.flicker then
   draw_artifact(a,x,y)
  end
 end
end

function artifact_point(a,x,y,px,py)
 local rx,ry=rotpt(px,py,a.rot)
 return x+rx,y+ry
end

function artifact_tower_line(a,x,y,x1,y1,x2,y2,col)
 local ax,ay=artifact_point(a,x,y,x1,y1)
 local bx,by=artifact_point(a,x,y,x2,y2)
 line(ax,ay,bx,by,col)
end

function draw_artifact_tower(a,x,y,r)
 local c=a.col

 -- tapered legs and two crossed lattice bays
 artifact_tower_line(a,x,y,-r/2,-r,0,-3*r,c)
 artifact_tower_line(a,x,y,r/2,-r,0,-3*r,c)
 artifact_tower_line(a,x,y,-r/2,-r,r/2,-r,c)
 artifact_tower_line(a,x,y,-3*r/8,-3*r/2,3*r/8,-3*r/2,c)
 artifact_tower_line(a,x,y,-r/4,-2*r, r/4,-2*r,c)
 artifact_tower_line(a,x,y,-r/8,-5*r/2,r/8,-5*r/2,c)
 artifact_tower_line(a,x,y,-r/2,-r,3*r/8,-3*r/2,c)
 artifact_tower_line(a,x,y,r/2,-r,-3*r/8,-3*r/2,c)
 artifact_tower_line(a,x,y,-3*r/8,-3*r/2,r/4,-2*r,c)
 artifact_tower_line(a,x,y,3*r/8,-3*r/2,-r/4,-2*r,c)
 artifact_tower_line(a,x,y,-r/4,-2*r,r/8,-5*r/2,c)
 artifact_tower_line(a,x,y,r/4,-2*r,-r/8,-5*r/2,c)

 -- small surface equipment hut from the original tower
 local house=a.off and 5 or 6
 artifact_tower_line(a,x,y,-7*r/8,-r,-r/4,-r,house)
 artifact_tower_line(a,x,y,-7*r/8,-r,-7*r/8,-5*r/4,house)
 artifact_tower_line(a,x,y,-7*r/8,-5*r/4,-r/4,-5*r/4,house)
 artifact_tower_line(a,x,y,-r/4,-5*r/4,-r/4,-r,house)
 artifact_tower_line(a,x,y,-r,-5*r/4,-9*r/16,-3*r/2,c)
 artifact_tower_line(a,x,y,-9*r/16,-3*r/2,-r/8,-5*r/4,c)
 local wx,wy=artifact_point(a,x,y,-9*r/16,-9*r/8)
 pset(wx,wy,0)

 local tx,ty=artifact_point(a,x,y,0,-3*r)
 circfill(tx,ty,1,a.off and 5 or 10)
end

function draw_artifact(a,x,y)
 local r=max(8,min(22,a.size/2))
 circfill(x,y,r,0)
 circfill(x,y,r-1,a.col)
 circfill(x,y,max(2,r-5),a.off and 1 or 7)
 draw_artifact_tower(a,x,y,r)
end

function draw_minimap()
 rectfill(3,3,29,29,7)
 rectfill(5,5,27,27,0)
 local mx=5+ship.x/world_size*22
 local my=5+ship.y/world_size*22
 if flr(t()*2)%2==0 then rectfill(mx-1,my-1,mx+1,my+1,7) end
 for a in all(artifacts) do
  if a.visible and not a.off then
   pset(5+a.x/world_size*22,5+a.y/world_size*22,a.col)
  end
 end
end
