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

function artifact_hut_point(a,x,y,px,py,pivot_x,pivot_y)
 local d=sqrt(pivot_x*pivot_x+pivot_y*pivot_y)
 local ca=-pivot_y/d
 local sa=-pivot_x/d
 local dx=px-pivot_x
 local dy=py-pivot_y
 local hx=pivot_x+dx*ca+dy*sa
 local hy=pivot_y-dx*sa+dy*ca
 return artifact_point(a,x,y,hx,hy)
end

function artifact_hut_line(a,x,y,x1,y1,x2,y2,pivot_x,pivot_y,col)
 local ax,ay=artifact_hut_point(a,x,y,x1,y1,pivot_x,pivot_y)
 local bx,by=artifact_hut_point(a,x,y,x2,y2,pivot_x,pivot_y)
 line(ax,ay,bx,by,col)
end

function artifact_hut_fill(a,x,y,x1,y1,x2,y2,pivot_x,pivot_y,col)
 for py=y1,y2 do
  artifact_hut_line(a,x,y,x1,py,x2,py,pivot_x,pivot_y,col)
  if py<y2 then artifact_hut_line(a,x,y,x1,py+0.5,x2,py+0.5,pivot_x,pivot_y,col) end
 end
end

function draw_artifact_tower(a,x,y,r)
 local c=a.col
 local inward=3

 -- tapered legs and two crossed lattice bays
 artifact_tower_line(a,x,y,-r/2,-r+inward,0,-3*r+inward,c)
 artifact_tower_line(a,x,y,r/2,-r+inward,0,-3*r+inward,c)
 artifact_tower_line(a,x,y,-r/2,-r+inward,r/2,-r+inward,c)
 artifact_tower_line(a,x,y,-3*r/8,-3*r/2+inward,3*r/8,-3*r/2+inward,c)
 artifact_tower_line(a,x,y,-r/4,-2*r+inward,r/4,-2*r+inward,c)
 artifact_tower_line(a,x,y,-r/8,-5*r/2+inward,r/8,-5*r/2+inward,c)
 artifact_tower_line(a,x,y,-r/2,-r+inward,3*r/8,-3*r/2+inward,c)
 artifact_tower_line(a,x,y,r/2,-r+inward,-3*r/8,-3*r/2+inward,c)
 artifact_tower_line(a,x,y,-3*r/8,-3*r/2+inward,r/4,-2*r+inward,c)
 artifact_tower_line(a,x,y,3*r/8,-3*r/2+inward,-r/4,-2*r+inward,c)
 artifact_tower_line(a,x,y,-r/4,-2*r+inward,r/8,-5*r/2+inward,c)
 artifact_tower_line(a,x,y,r/4,-2*r+inward,-r/8,-5*r/2+inward,c)

 -- solid shaded surface hut from the original tower
 local house=a.off and 5 or 6
 local roof=a.off and 1 or 5
 local base_pivot_x=-7*r/16
 local base_pivot_y=-3*r/4+inward
 local pivot_d=sqrt(base_pivot_x*base_pivot_x+base_pivot_y*base_pivot_y)
 local hut_dx=base_pivot_x/pivot_d
 local hut_dy=base_pivot_y/pivot_d
 local pivot_x=base_pivot_x+hut_dx
 local pivot_y=base_pivot_y+hut_dy
 artifact_hut_fill(a,x,y,-3*r/4+hut_dx,-r+inward+hut_dy,-r/8+hut_dx,-3*r/4+inward+hut_dy,pivot_x,pivot_y,house)
 for py=-5*r/4+inward,-r+inward do
  local spread=(py+5*r/4-inward)*7/4
  artifact_hut_line(a,x,y,-7*r/16-spread+hut_dx,py+hut_dy,-7*r/16+spread+hut_dx,py+hut_dy,pivot_x,pivot_y,roof)
 end
 artifact_hut_fill(a,x,y,-5*r/8+hut_dx,-15*r/16+inward+hut_dy,-r/2+hut_dx,-7*r/8+inward+hut_dy,pivot_x,pivot_y,0)
 artifact_hut_fill(a,x,y,-5*r/16+hut_dx,-15*r/16+inward+hut_dy,-3*r/16+hut_dx,-3*r/4+inward+hut_dy,pivot_x,pivot_y,c)

 local tx,ty=artifact_point(a,x,y,0,-3*r+inward)
 circfill(tx,ty,2,a.off and 5 or 10)
end

function draw_artifact(a,x,y)
 local r=max(8,min(22,a.size/2))
 circfill(x,y,r,0)
 circfill(x,y,r-1,a.col)
 circfill(x,y,max(2,r-5),a.off and 1 or 7)
 draw_artifact_tower(a,x,y,r)
end

function draw_minimap(now)
 rectfill(3,3,29,29,7)
 rectfill(5,5,27,27,0)
 local mx=5+ship.x/world_size*22
 local my=5+ship.y/world_size*22
 now=now or t()
 if flr(now*2)%2==0 then pset(mx,my,9) end
 for a in all(artifacts) do
  if a.visible and not a.off then
   pset(5+a.x/world_size*22,5+a.y/world_size*22,a.col)
  end
 end
end
