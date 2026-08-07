sw=128
sh=128
world_size=4096
cx=64
cy=58

-- original story beats and gating
story_text={
 "it's all gone; it must be.",
 "...and it's been weeks since i touched these controls.",
 "( o/x control the radio )",
 "just turn the radio on. ( press x )",
 "wait, this isn't just static! ( tune with x )",
 "there must be someone out there...",
 "...somewhere. (check the corner map if you get lost)",
 "(find towers by tuning the radio, then follow the sonar)",
 "it's time to start looking. ( left/right + up to fly! )",
 "hmm; there's nobody here,",
 "... but there's more on the radio.",
 "if i shut this thing down, i'll hear more radio signals.",
 "( press down )",
 "it was nothing, just some old radio tower.",
 "...but i know there's more of these.",
 "...and maybe you escaped. ( tune with o/x )",
 "this one is empty, too.",
 "i'll shut it down and clear the radio some more.",
 "( press down )",
 "each empty artifact is just one less place to look.",
 "did what happened to me happen here too?",
 "...and did what happened to me, happen to you?",
 "( press down )",
 "(tune with o and x)",
 "are you out there looking, too? cause you're not here.",
 "( press down )",
 "either way, i will keep looking.",
 "i'll always be looking.",
 "there's no one here, either.",
 "( press down )",
 "everything on this radio is terrible.",
 "it's still better than static, though.",
 "dark windows. another empty broadcast.",
 "( press down )",
 "am i really, truly, alone?",
 "i still hope one of these signals is yours.",
 "are you broadcasting too?",
 "( press down )",
 "there's only a handful of broadcasts left...",
 "chasing these signals is unbearable;",
 "i still won't stop until there's only static left.",
 "( press down )",
 "but what if i search them all",
 "...and i don't find you?",
 "i've checked this radio so many times now...",
 "i know there's only a few more of these left.",
 "( press down )",
 "should i just turn this radio off?",
 "well...",
 "...have you ever given up on me?",
 "you're not here, but you're somewhere.",
 "i can feel it.",
 "( press down )",
 "...",
 "i can only hear this one last signal.",
 "... ... ... ... ... ...",
 "...and it isn't you.",
 "( press down )",
 "...",
 "it wasn't you.",
 "( turn the radio off with o )"
}

story_pause={
 true,true,true,true,true,true,true,true,false,
 true,true,true,true,true,true,false,true,true,true,true,false,
 true,true,false,true,true,true,false,true,true,true,false,true,true,false,
 true,true,true,false,true,true,true,true,false,true,true,true,true,true,false,
 true,true,true,true,true,false,true,true,true,true,false
}

radio_cues={8,15,20,23,27,31,34,38,43,49,55}
artifact_cues={12,18,22,25,29,33,37,41,46,52,57}

function in_list(list,v)
 for n in all(list) do
  if n==v then return true end
 end
 return false
end

function clamp(v,lo,hi)
 return max(lo,min(hi,v))
end

function dist2(x1,y1,x2,y2)
 local dx=abs(x2-x1)
 local dy=abs(y2-y1)
 local longest=max(dx,dy)
 if longest==0 then return 0 end
 local ratio=min(dx,dy)/longest
 return longest*sqrt(1+ratio*ratio)
end
