################################################################################
# Randomized Pokemon Script
# By Umbreon
################################################################################
# Used for a randomized pokemon challenge mainly.
# 
# By randomized, I mean EVERY pokemon will be random, even interacted pokemon
#   like legendaries. (You may easily disable the randomizer for certain
#    situations like legendary battles and starter selecting.)
#
# To use: simply activate Switch Number X
#  (X = the number listed After "Switch = ", default is switch number 36.)
#
# If you want certain pokemon to NEVER appear, add them inside the black list.
#  (This does not take into effect if the switch stated above is off.)
#
# If you want ONLY certain pokemon to appear, add them to the whitelist. This
#   is only recommended when the amount of random pokemon available is around
#   32 or less.(This does not take into effect if the switch stated above is off.)
#
################################################################################

########################## You may edit any settings below this freely.
# module RandomizedChallenge
#   Switch = 36 # switch ID to randomize a pokemon, if it's on then ALL
#   # pokemon will be randomized. No exceptions.
#
#   BlackListedPokemon = [] #[PBSpecies::MEW, PBSpecies::ARCEUS]
#   # Pokemon to Black List. Any pokemon in here will NEVER appear.
#
#   WhiteListedPokemon = []
#   # Leave this empty if all pokemon are allowed, otherwise only pokemon listed
#   # above will be selected.
# end
#
# ######################### Do not edit anything below here.
# class PokeBattle_Pokemon
#
#   alias randomized_init initialize
#
#   def initialize(species, level, player = nil, withMoves = true)
#
#     if $game_switches && $game_switches[RandomizedChallenge::Switch]
#       if $game_switches[991]
#         species = rand(PBSpecies.maxValue - 1) + 1
#         basestatsum = $pkmn_dex[species][5][0] # HP
#         basestatsum += $pkmn_dex[species][5][1] # Attack
#         basestatsum += $pkmn_dex[species][5][2] # Defense
#         basestatsum += $pkmn_dex[species][5][3] # Speed
#         basestatsum += $pkmn_dex[species][5][4] # Special Attack
#         basestatsum += $pkmn_dex[species][5][5] # Special Defense
#
#         while basestatsum > $game_variables[53] || basestatsum < $game_variables[87]
#           species = rand(PBSpecies.maxValue - 1) + 1
#           basestatsum = $pkmn_dex[species][5][0] # HP
#           basestatsum += $pkmn_dex[species][5][1] # Attack
#           basestatsum += $pkmn_dex[species][5][2] # Defense
#           basestatsum += $pkmn_dex[species][5][3] # Speed
#           basestatsum += $pkmn_dex[species][5][4] # Special Attack
#           basestatsum += $pkmn_dex[species][5][5] # Special Defense
#         end
#         #Kernel.pbMessage(_INTL("total = {1}, {2}",basestatsum, PBSpecies.getName(species)))
#       else
#         if $game_switches[841]
#           species = getRandomCustomSprite()
#         else
#           species = rand(PBSpecies.maxValue - 1) + 1
#         end
#       end
#     end
#
#     randomized_init(species, level, player, withMoves)
#   end
# end
#
#
# def getRandomCustomSprite()
#   filesList = Dir["./Graphics/CustomBattlers/*"]
#   i = rand(filesList.length - 1)
#   path = filesList[i]
#   file = File.basename(path, ".*")
#   splitPoke = file.split(".")
#   head = splitPoke[0].to_i
#   body = splitPoke[1].to_i
#   return (body * NB_POKEMON) + head
# end

=begin

##########################
#   Trainer house shit
#########################
#Battleformat : 0 = single
#               1 = double
def Kernel.pbTrainerHouse(bstMin,bstMax,level,battleformat)
  return false if !validateLevel()
  #activate random Pokemon
  $game_switches[991] = true
  
  #Set game variables
  $game_variables[87]=bstMin
  $game_variabes[53]=bstMax
  
  #initialize variables
  trainerHouse=true
  currentStreak=0
  backupTeamLevels()
  doubleBattle = battleformat == 1 ? true : false
  
  
  while trainerHouse
    currentStreak += 1
    TrainerHouseVictory(currentStreak) if TrainerHouseBattle(level)
  end
end

def backupTeamLevels()
      $game_variables[91] = $Trainer.pokemonParty[0].level
      $game_variables[92] = $Trainer.pokemonParty[1].level
      $game_variables[93] = $Trainer.pokemonParty[2].level
end

#choisir le trainer a combattre en fonction du level
def TrainerHouseBattle(level,battleformat)
  victoryMessage = getVictoryMessage()
  getTrainerHouseBattle(rand(1),level,battleformat)
  return 
end 

#initialiser background & musique pour le combat
def setBattleConstants()
  $PokemonGlobal.nextBattleBGM="SubwayTrainerBattle"
  $PokemonGlobal.nextBattleBack="IndoorC"
end

#Ajouter les TP après un victoire
def TrainerHouseVictory(currentStreak)
  tp_won = currentStreak + 1
  $game_variables[49] = tp_won
end

#Valider si le niveau est un challenge possible
def validateLevel(level)
  validLevels=[25,50,100]
  return validLevels.include?(level)
end  

def getVictoryMessage()
  return "You're good!"
end

def getTrainerHouseBattle(IsMale,level,single=true)
  victoryMessage = getVictoryMessage()
  
  LV25MALE_SINGLE      = pbTrainerBattle(PBTrainers::COOLTRAINER_M2,"Matthew",_I(victoryMessage),false,0,true)
  LV25FEMALE_SINGLE    = pbTrainerBattle(PBTrainers::COOLTRAINER_F2,"Jessica",_I(victoryMessage),false,0,true)
  LV25MALE_DOUBLE     = pbTrainerBattle(PBTrainers::COOLTRAINER_M2,"Alex",_I(victoryMessage),false,0,true)
  LV25FEMALE_DOUBLE    = pbTrainerBattle(PBTrainers::COOLTRAINER_F2,"Laurie",_I(victoryMessage),false,0,true)
  
  LV50MALE_SINGLE      = pbTrainerBattle(PBTrainers::COOLTRAINER_M2,"Alberto",_I(victoryMessage),false,0,true)
  LV50FEMALE_SINGLE    = pbTrainerBattle(PBTrainers::COOLTRAINER_F2,"Skyler",_I(victoryMessage),true,0,true)
  LV50MALE_DOUBLE      = pbTrainerBattle(PBTrainers::COOLTRAINER_M2,"Patrick",_I(victoryMessage),false,0,true)
  LV50FEMALE_DOUBLE    = pbTrainerBattle(PBTrainers::COOLTRAINER_F2,"Heather",_I(victoryMessage),true,0,true)

  LV100MALE_SINGLE     = pbTrainerBattle(PBTrainers::COOLTRAINER_M2,"Joe",_I(victoryMessage),false,0,true)
  LV100FEMALE_SINGLE   = pbTrainerBattle(PBTrainers::COOLTRAINER_F2,"Melissa",_I(victoryMessage),true,0,true)
  LV100MALE_DOUBLE     = pbTrainerBattle(PBTrainers::COOLTRAINER_M2,"Stephen",_I(victoryMessage),false,0,true)
  LV100FEMALE_DOUBLE   = pbTrainerBattle(PBTrainers::COOLTRAINER_F2,"Kim",_I(victoryMessage),true,0,true)

  
  
  if single #SINGLE
    if level == 25
      return LV25MALE_SINGLE if IsMale == 1
      return LV25FEMALE_SINGLE
    elsif level == 50
      return LV50MALE_SINGLE if IsMale == 1
      return LV50FEMALE_SINGLE
    else
      return LV100MALE_SINGLE if IsMale == 1
      return LV100FEMALE_SINGLE
    end
  else  #DOUBLE
    if level == 25
      return LV25MALE_DOUBLE if IsMale == 1
      return LV25FEMALE_DOUBLE
    elsif level == 50
      return LV50MALE_DOUBLE if IsMale == 1
      return LV50FEMALE_DOUBLE
    else
      return LV100MALE_DOUBLE if IsMale == 1
      return LV100FEMALE_DOUBLE
    end
  end  
   
end

=end