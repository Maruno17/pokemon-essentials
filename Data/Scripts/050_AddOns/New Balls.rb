###################
## NEW POKEBALLS  #
###################

#GENDER BALL (24) - switch le gender du pokemon
#catch rate: pokeball
BallHandlers::OnCatch.add(:GENDERBALL,proc{|ball,battle,pokemon|
if pokemon.gender == 0 
  pokemon.makeFemale 
elsif  pokemon.gender == 1 
  pokemon.makeMale
end
})

#BOOST BALL 25 - rend le pokemon traded
#catch rate: 80% pokeball
BallHandlers::ModifyCatchRate.add(:TRADEBALL,proc{|ball,catchRate,battle,pokemon|
  catchRate=(catchRate*0.8).floor(1)
next catchRate
})
BallHandlers::OnCatch.add(:TRADEBALL,proc{|ball,battle,pokemon|
  pokemon.obtain_method = 2
})

#ABILITY BALL 26 - change l'ability
#catch rate: 60% pokeball
BallHandlers::ModifyCatchRate.add(:ABILITYBALL,proc{|ball,catchRate,battle,pokemon|
  catchRate=(catchRate*0.6).floor(1)
next catchRate
})
BallHandlers::OnCatch.add(:ABILITYBALL,proc{|ball,battle,pokemon|
  species = getSpecies(dexNum(pokemon))
  pokemon.ability= species.hidden_abilities[-1]
})

#VIRUS BALL 27  - give pokerus
#catch rate: 40% pokeball
BallHandlers::ModifyCatchRate.add(:VIRUSBALL,proc{|ball,catchRate,battle,pokemon|
  catchRate=(catchRate*0.4).floor(1)
next catchRate
})
BallHandlers::OnCatch.add(:VIRUSBALL,proc{|ball,battle,pokemon|
  pokemon.givePokerus
})

#SHINY BALL 28  - rend shiny
#catchrate: 20% pokeball
BallHandlers::ModifyCatchRate.add(:SHINYBALL,proc{|ball,catchRate,battle,pokemon|
  catchRate=(catchRate*0.2).floor(1)
next catchRate
})
BallHandlers::OnCatch.add(:SHINYBALL,proc{|ball,battle,pokemon|
  pokemon.glitter=true
})

#PERFECTBALL 29
#catch rate: 10% pokeball
BallHandlers::ModifyCatchRate.add(:PERFECTBALL,proc{|ball,catchRate,battle,pokemon|
  catchRate=(catchRate*0.1).floor(1)
next catchRate
})
BallHandlers::OnCatch.add(:PERFECTBALL,proc{|ball,battle,pokemon|
  stats = [:ATTACK, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED, :DEFENSE, :HP]
  first = rand(5)
  second = rand(5)
  pokemon.iv[stats[first]] = 31
  pokemon.iv[stats[second]] = 31
})


#DREAMBALL  - endormi
BallHandlers::ModifyCatchRate.add(:DREAMBALL,proc{|ball,catchRate,battle,battler|
   battler.status = :SLEEP
   next catchRate
})
#TOXICBALL  - empoisonné
BallHandlers::ModifyCatchRate.add(:TOXICBALL,proc{|ball,catchRate,battle,battler|
  battler.status = :POISON
   next catchRate
})
#SCORCHBALL - brulé
BallHandlers::ModifyCatchRate.add(:SCORCHBALL,proc{|ball,catchRate,battle,battler|
   battler.status = :BURN
   next catchRate
})
#FROSTBALL - frozen
BallHandlers::ModifyCatchRate.add(:FROSTBALL,proc{|ball,catchRate,battle,battler|
   battler.status = :FROZEN
   next catchRate
})
#SPARKBALL  - paralizé
BallHandlers::ModifyCatchRate.add(:SPARKBALL,proc{|ball,catchRate,battle,battler|
   battler.status = :PARALYSIS
   next catchRate
})
#PUREBALL  - marche mieux quand pas de status
BallHandlers::ModifyCatchRate.add(:PUREBALL,proc{|ball,catchRate,battle,battler|
   catchRate=(catchRate*7/2).floor if battler.status ==0   
   next catchRate
})
#STATUSBALL - marche mieux quand any status
BallHandlers::ModifyCatchRate.add(:STATUSBALL,proc{|ball,catchRate,battle,battler|
   catchRate=(catchRate*5/2).floor if battler.status !=0   
   next catchRate
})

#FUSIONBALL - marche mieux quand fusedr
BallHandlers::ModifyCatchRate.add(:FUSIONBALL,proc{|ball,catchRate,battle,battler|
   catchRate*=3 if GameData::Species.get(battler.species).id_number > Settings::NB_POKEMON
   next catchRate
})

#CANDY BALL  - +5 level
#catchrate: 80% pokeball
BallHandlers::ModifyCatchRate.add(:CANDYBALL,proc{|ball,catchRate,battle,pokemon|
  catchRate=(catchRate*0.8).floor  
next catchRate
})
BallHandlers::OnCatch.add(:CANDYBALL,proc{|ball,battle,pokemon|
  pokemon.level = pokemon.level+5
})
#FIRECRACKER
BallHandlers::ModifyCatchRate.add(:FIRECRACKER,proc{|ball,catchRate,battle,battler|
   battler.hp -= 10  
   next 0
})
