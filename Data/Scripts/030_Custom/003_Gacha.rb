GACHA_POKES={
  :UB=>[:AEGISLASH,:BLAZIKEN,:DARKRAI],
  :OU=>[:ALAKAZAM],
  :UU=>[:PIDGEOT],
  :RU=>[:PIDGEY],
  :PU=>[:WEEDLE,:CATERPIE],
}
ratio=[1,4,15,30,50]

def pbGacha
  if Kernel.pbConfirmMessage(_INTL("Open a gacha?"))
     list=GACHA_POKES
     pkmn=list[index]    
    pkmn=getID(PBSpecies,pkmn)
	  $PokemonBag.pbDeleteItem(:TICKET)
	  Kernel.pbMessage(_INTL("Gacha as open!!!!"))
	  Kernel.pbAddPokemon(pkmn)	
  end
end  









