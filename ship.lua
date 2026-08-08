function init_ship()
 ship={
  x=world_size/2+32,y=world_size/2+32,
  vx=0,vy=0,angle=0,thrust=0,target=nil,orbit=nil,
  sonar_tick=0,sonar_period=90,engine_tick=0,particles={},
  autopilot=false,up_tap_frames=0,up_was_down=false
 }
 for i=1,48 do
  add(ship.particles,{x=cx,y=cy,life=0,maxlife=1,vx=0,vy=0,col=8})
 end
end

function stop_autopilot()
 ship.autopilot=false
 ship.up_tap_frames=0
end

function clear_particles()
 for p in all(ship.particles) do
  p.x=cx
  p.y=cy
  p.vx=0
  p.vy=0
  p.life=p.maxlife
  p.col=0
 end
end

function update_ship()
 if game_state==0 or game_state>=3 then
  ship.angle=0.145
  update_particles(true)
  return
 end

 local can_fly=not pause_story
 if can_fly and btn(0) then ship.angle=(ship.angle-0.006)%1 end
 if can_fly and btn(1) then ship.angle=(ship.angle+0.006)%1 end

 local up_down=btn(2)
 local up_pressed=up_down and not ship.up_was_down
 if up_pressed then
  if ship.autopilot then
   stop_autopilot()
  elseif can_fly then
   if ship.up_tap_frames>0 then
    ship.autopilot=true
    ship.up_tap_frames=0
   else
    ship.up_tap_frames=18
   end
  end
 end
 ship.up_was_down=up_down
 if ship.up_tap_frames>0 then ship.up_tap_frames-=1 end

 local firing=can_fly and (up_down or ship.autopilot)
 if firing then
  ship.engine_tick+=1
  ship.vx=clamp(ship.vx-sin(ship.angle)*0.006,-0.85,0.85)
  ship.vy=clamp(ship.vy-cos(ship.angle)*0.006,-0.85,0.85)
  ship.vx*=0.993
  ship.vy*=0.993
  ship.thrust=min(1,ship.thrust+0.04)
  if ship.engine_tick%30==1 then sfx(1) end
 elseif ship.orbit then
  ship.engine_tick=0
  update_orbit()
  ship.thrust*=0.9
 else
  ship.engine_tick=0
  ship.vx*=0.995
  ship.vy*=0.995
  ship.angle=(ship.angle+(ship.vy>0 and -0.0003 or 0.0003))%1
  ship.thrust*=0.94
 end

 ship.x=clamp(ship.x+ship.vx,0,world_size)
 ship.y=clamp(ship.y+ship.vy,0,world_size)
 ship.sonar_tick=(ship.sonar_tick+1)%max(20,ship.sonar_period)
 update_particles(firing)
end

function update_orbit()
 local a=ship.orbit
 local dx=a.x-ship.x
 local dy=a.y-ship.y
 local d=dist2(ship.x,ship.y,a.x,a.y)
 if abs(ship.vx)>0.4 then ship.vx*=0.9 end
 if abs(ship.vy)>0.4 then ship.vy*=0.9 end
 local pull=0.006*min(d/(sh/3),1)
 ship.vx+=dx<0 and -pull or pull
 ship.vy+=dy<0 and -pull or pull
 ship.angle=(0.25-atan2(ship.vx,ship.vy))%1
end

function reset_particle(p)
 p.x=cx+sin(ship.angle)*5
 p.y=cy+cos(ship.angle)*5
 local strength=max(0.25,ship.thrust)
 if game_state==0 or game_state>=3 then strength=1 end
 local speed=(0.55+rnd(0.75))*strength
 local spread=(rnd(1)-0.5)*0.35*strength
 p.vx=sin(ship.angle)*speed+cos(ship.angle)*spread
 p.vy=cos(ship.angle)*speed-sin(ship.angle)*spread
 p.life=0
 p.maxlife=18+flr(rnd(43))*strength
end

function update_particles(firing)
 for p in all(ship.particles) do
  p.life+=1
  p.x+=p.vx
  p.y+=p.vy
  p.vx*=0.985
  p.vy*=0.985
  local q=p.life/max(1,p.maxlife)
  p.col=q<0.25 and 7 or (q<0.55 and 10 or (q<0.8 and 9 or 8))
  if p.life>=p.maxlife then
   if firing or game_state==0 or game_state>=3 then reset_particle(p)
   else p.col=0 end
  end
 end
end

function rotpt(x,y,a)
 return x*cos(a)+y*sin(a),-x*sin(a)+y*cos(a)
end

function fill_tri(x1,y1,x2,y2,x3,y3,col)
 local minx=flr(min(x1,min(x2,x3)))
 local maxx=ceil(max(x1,max(x2,x3)))
 local miny=flr(min(y1,min(y2,y3)))
 local maxy=ceil(max(y1,max(y2,y3)))
 local d=(y2-y3)*(x1-x3)+(x3-x2)*(y1-y3)
 if d==0 then
  line(x1,y1,x2,y2,col)
  line(x2,y2,x3,y3,col)
  return
 end
 for py=miny,maxy do
  for px=minx,maxx do
   local a=((y2-y3)*(px+0.5-x3)+(x3-x2)*(py+0.5-y3))/d
   local b=((y3-y1)*(px+0.5-x3)+(x1-x3)*(py+0.5-y3))/d
   if a>=0 and b>=0 and a+b<=1 then pset(px,py,col) end
  end
 end
end

function draw_ship(x,y,col,angle)
 local function rp(px,py)
  local rx,ry=rotpt(px,py,angle)
  return x+rx,y+ry
 end
 local ax,ay=rp(0,-7)
 local bx,by=rp(-6,5)
 local dx,dy=rp(0,3)
 local ex,ey=rp(6,5)
 fill_tri(ax,ay,bx,by,dx,dy,0)
 fill_tri(ax,ay,dx,dy,ex,ey,0)
 ax,ay=rp(0,-5)
 bx,by=rp(-4,4)
 dx,dy=rp(0,2)
 ex,ey=rp(4,4)
 fill_tri(ax,ay,bx,by,dx,dy,col)
 fill_tri(ax,ay,dx,dy,ex,ey,col)
 if col==9 then
  local l1x,l1y=rp(-4,-1)
  local l2x,l2y=rp(-1,2)
  local l3x,l3y=rp(-4,4)
  fill_tri(l1x,l1y,l2x,l2y,l3x,l3y,0)
  l1x,l1y=rp(-4,0)
  l2x,l2y=rp(-2,2)
  l3x,l3y=rp(-4,3)
  fill_tri(l1x,l1y,l2x,l2y,l3x,l3y,4)
  local r1x,r1y=rp(4,0)
  local r2x,r2y=rp(1,2)
  local r3x,r3y=rp(4,4)
  fill_tri(r1x,r1y,r2x,r2y,r3x,r3y,0)
  r1x,r1y=rp(4,1)
  r2x,r2y=rp(2,2)
  r3x,r3y=rp(4,3)
  fill_tri(r1x,r1y,r2x,r2y,r3x,r3y,3)
 end
 local wx,wy=rp(0,-2)
 circfill(wx,wy,1,5)
end

function draw_particles()
 for p in all(ship.particles) do
  if p.col!=0 then pset(p.x,p.y,p.col) end
 end
end

function sonar_front_distance(age)
 return age*18+8
end

function draw_sonar_front(ang,d,i,col)
 local stagger=(i-1)/3
 for j=-3,3 do
  local sweep=(j+stagger)/36
  local x=cx+cos(ang+sweep)*d
  local y=cy+sin(ang+sweep)*d
  circ(x,y,1,col or 12)
 end
end

function draw_sonar()
 if not ship.target or radio_offset==0 then return end
 local a=ship.target
 local dx=a.x-ship.x
 local dy=a.y-ship.y
 local ang=atan2(dx,dy)
 local phase=ship.sonar_tick/max(1,ship.sonar_period)
 for i=0,2 do
  local age=(phase+i/3)%1
  draw_sonar_front(ang,sonar_front_distance(age),i)
 end
end
