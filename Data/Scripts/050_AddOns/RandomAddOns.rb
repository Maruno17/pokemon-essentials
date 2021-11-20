
#Eevee quest
Events.onStepTaken+=proc {|sender,e|
  next if !$game_switches[173]
  next if !$game_switches[179] #If not outside of building
  $game_variables[102]+=1

  if $game_variables[102] % 100 == 0 then
    $game_variables[101]+=1
  end

  if $game_variables[102] >= 400 then
    if $game_variables[102] % 100 == 0 then
      Kernel.pbMessage(_INTL("Eevee is getting tired. You should head back soon!"))
      cry=pbResolveAudioSE(pbCryFile(133))
      pbSEPlay(cry,100,100)
    end
  end
}