=begin
*** Wonder Trade Script by Black Eternity ***
This script is to mimic Wonder Trade from an offline perspective.
THERE IS NO ONLINE CAPABILITIES OF THIS SCRIPT,
ALL CALCULATIONS ARE DONE INTERNALLY.

To call the script like normal and have ALL Pokemon trade-able, use the following.
    pbWondertrade(1,[],[])

Black listed Pokemon are to be added to the Exceptions arrays.
  Except is the list of pokemon the player is forbidden to trade.
    Here the player cannot trade any of the following.
      pbWonderTrade(1,[:PIKACHU,:SQUIRTLE,:CHARMANDER,;BULBASAUR],[])

  Except2 is the list of pokemon the player is forbidden to receive.
    Here the player cannot receive any of the following.
      pbWonderTrade(1,[],[:MEWTWO,;MEW,;DEOXYS])



The first parameter is the minimum allowed Level of the Pokemon to be traded.
For example, you can not trade a Pokemon through Wonder Trade unless its level
is greater than or equal to specified level.

    pbWonderTrade(40,[:SQUIRTLE,:CHARMANDER,:BULBASAUR],[:MEWTWO,:MEW,:DEOXYS])
    *** Only pokemon over level 40 can be traded, you cannot trade starters.
    *** You cannot receive these legendaries.

The fourth parameter, which has recently replaced mej71's "hardobtain"
is called "rare", this parameter developed also by mej71, will use
the Pokemon's rareness and filter the results depending on its values.

** Rareness is turned on by default, if you wish to disable it, call the
    function accordingly.

    pbWonderTrade(10,[:SQUIRTLE],[:CHARMANDER,:BULBASAUR],false)
    ** Only Pokemon over level 10, cannot trade Squirtle, cannot
    ** recieve Charmander or Bulbasaur, Rareness disabled.

It is up to you to use it how you wish, credits will be appreciated.
=end

# List of Randomly selected Trainer Names
# These are just names taken from a generator, add custom or change to
# whatever you desire.


def pbWonderTrade(lvl, except = [], except2 = [], premiumWonderTrade = true)
  # for i in 0...except.length # Gets ID of pokemon in exception array
  #   except[i]=getID(PBSpecies,except[i]) if !except[i].is_a?(Integer)
  # end
  # for i in 0...except2.length # Gets ID of pokemon in exception array
  #   except2[i]=getID(PBSpecies,except2[i]) if !except2[i].is_a?(Integer)
  # end
  # ignoreExcept = rand(100) == 0 #tiny chance to include legendaries
  #
  # except+=[]
  rare = premiumWonderTrade
  chosen = pbChoosePokemon(1, 2, # Choose eligable pokemon
                           proc {
                             |poke| !poke.egg? && !(poke.isShadow?) && # No Eggs, No Shadow Pokemon
                               (poke.level >= lvl) && !(except.include?(poke.species)) # None under "lvl", no exceptions.
                           })
  poke = $Trainer.party[pbGet(1)]
  if !pbConfirmMessage(_INTL("Trade {1} away?",poke.name))
    return
  end

    $PokemonBag.pbStoreItem(poke.item, 1) if poke.item != nil
  myPoke = poke.species
  chosenBST = calcBaseStatsSum(myPoke)
  # The following excecption fields are for hardcoding the blacklisted pokemon
  # without adding them in the events.
  #except+=[]
  except2 += [:ARCEUS, :MEW, :CELEBI, :LUGIA, :HOOH, :MEWTWO]
  if pbGet(1) >= 0
    species = 0
    luck = rand(5) + 1
    rarecap = (rand(155 + poke.level) / (1 + rand(5))) / luck
    bonus = 0
    while (species == 0) # Loop Start
      bonus += 5 #+ de chance de pogner un bon poke a chaque loop (permet d'eviter infinite loop)

      species = rand(PBSpecies.maxValue) + 1
      bst = calcBaseStatsSum(species)
      # Redo the loop if pokemon is too evolved for its level
      #species=0 if lvl < pbGetMinimumLevel(species)# && pbGetPreviousForm(species) != species # && pbGetPreviousForm(species)!=species
      # Redo the loop if the species is an exception.
      species = 0 if checkifBlacklisted(species, except2) && !ignoreExcept #except2.include?(species)
      #Redo loop if above BST
      bstLimit = chosenBST + bonus# + $game_variables[120]
      if !premiumWonderTrade
        bstLimit-=50
      end
      species = 0 if bst > bstLimit
      if species > 0 && premiumWonderTrade
        species = 0 if !customSpriteExists(species)
      end
      if species > 0
        skipLegendaryCheck = premiumWonderTrade && rand(100) < luck
        species = 0 if pokemonIsPartLegendary(species) && !$game_switches[SWITCH_BEAT_THE_LEAGUE] && !skipLegendaryCheck
      end
      #Redo loop if below BST - 200
      species = 0 if bst < (chosenBST - 200)

      # raise _INTL("{1}'s bst ist {2}, new ist {3}",myPoke,chosenBST,bst)

      # species=0 if (except.include?(species) && except2.include?(species))
      # use this above line instead if you wish to neither receive pokemon that YOU
      # cannot trade.
      if rare == true #turn on rareness
        if species > 0
          rareness = GameData::Species.get(species).catch_rate
          species = 0 if rarecap >= rareness
        end
      end
    end
    randTrainerNames = RandTrainerNames_male + RandTrainerNames_female + RandTrainerNames_others
    tname = randTrainerNames[rand(randTrainerNames.size)] # Randomizes Trainer Names
    pname = RandPokeNick[rand(RandPokeNick.size)] # Randomizes Pokemon Nicknames

    #num of Wondertrade - 1
    if premiumWonderTrade
      $game_variables[VAR_PREMIUM_WONDERTRADE_LEFT] -= 1
    else
      $game_variables[VAR_STANDARD_WONDERTRADE_LEFT] -= 1
    end

    newpoke = pbStartTrade(pbGet(1), species, pname, tname, 0, true) # Starts the trade
    #lower level by 1 to prevent abuse
    if poke.level > 25
      newpoke.level = poke.level - 1
    end
  else
    return -1
  end
end

def pbGRS(minBST, chosenBST, luck, rare, except2)
  #pbGenerateRandomSpecies (le nom doit etre short pour etre callé dans events)
  # The following excecption fields are for hardcoding the blacklisted pokemon
  # without adding them in the events.
  #except+=[]
  except2 += []
  species = 0
  #luck = rand(5)+1
  rarecap = (rand(rare) / (1 + rand(5))) / luck
  bonus = 0
  while (species == 0) # Loop Start
    bonus += 5 #+ de chance de pogner un bon poke a chaque loop (permet d'eviter infinite loop)

    species = rand(PBSpecies.maxValue) + 1
    bst = calcBaseStatsSum(species)
    # Redo the loop if pokemon is too evolved for its level
    #species=0 if lvl < pbGetMinimumLevel(species)# && pbGetPreviousForm(species) != species # && pbGetPreviousForm(species)!=species
    # Redo the loop if the species is an exception.
    species = 0 if checkifBlacklisted(species, except2) #except2.include?(species)
    #Redo loop if above BST
    species = 0 if bst > chosenBST + $game_variables[120] + bonus

    #Redo loop if below BST - 200
    species = 0 if bst < (chosenBST - 200)

    # raise _INTL("{1}'s bst ist {2}, new ist {3}",myPoke,chosenBST,bst)

    # species=0 if (except.include?(species) && except2.include?(species))
    # use this above line instead if you wish to neither receive pokemon that YOU
    # cannot trade.
    if rare == true #turn on rareness
      rareness = GameData::Species.get(species).catch_rate
      species = 0 if rarecap >= rareness
    end
  end
  return species
end

#utilisé dans des events - ne pas renommer
def calcBaseStats(species)
  return calcBaseStatsSum(species)
end


def calcBaseStatsSum(species)
  stats = GameData::Species.get(species).base_stats
  sum = 0
  sum += stats[:HP]
  sum += stats[:ATTACK]
  sum += stats[:DEFENSE]
  sum += stats[:SPECIAL_ATTACK]
  sum += stats[:SPECIAL_DEFENSE]
  sum += stats[:SPEED]
  return sum
  #
  # basestatsum = $pkmn_dex[species][5][0] # HP
  # basestatsum +=$pkmn_dex[species][5][1] # Attack
  # basestatsum +=$pkmn_dex[species][5][2] # Defense
  # basestatsum +=$pkmn_dex[species][5][3] # Speed
  # basestatsum +=$pkmn_dex[species][5][4] # Special Attack
  # basestatsum +=$pkmn_dex[species][5][5]  # Special Defense
  # return basestatsum
end

def checkifBlacklisted(species, blacklist)
  return true if blacklist.include?(getBasePokemonID(species, true))
  return true if blacklist.include?(getBasePokemonID(species, false))
  return false
end