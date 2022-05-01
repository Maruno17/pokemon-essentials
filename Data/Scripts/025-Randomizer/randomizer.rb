class PokemonGlobalMetadata
  attr_accessor :psuedoHash
  attr_accessor :psuedoBSTHash
  attr_accessor :randomTrainersHash
  attr_accessor :randomGymTrainersHash


  alias random_init initialize
  def initialize
    random_init
    @randomGymTrainersHash=nil
    @psuedoHash=nil
    @psuedoBSTHash=nil
  end
end

##############
# randomizer shuffle
# ##############
def Kernel.pbShuffleDex(range=50,type=0)
  $game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE] = true
  
#type 0: BST
#type 1: full random
  range = 1 if range == 0
  # create hash
  psuedoHash = Hash.new
  psuedoBSTHash = Hash.new
  
  #Create array of all pokemon dex numbers
  pokeArray = []
  
  
  monLimit = type == 1 ? PBSpecies.maxValue : NB_POKEMON-1
  for i in 1..monLimit
    pokeArray.push(i)
  end
  #randomize hash
  pokeArrayRand = pokeArray.dup
  pokeArrayRand.shuffle!
  pokeArray.insert(0,nil)
  ######
  #on remet arceus a la fin
  pokeArray.push(NB_POKEMON)
  
  # fill random hash
  #random hash will have to be accessed by number, not internal name

  for i in 1...pokeArrayRand.length
    psuedoHash[i]=pokeArrayRand[i]
  end
  
  #use pokeArrayRand to fill in the BST hash also
  #loop through the actual dex, and use the first mon in pokeArrayRand with
  #BST in the same 100 range
  
  
  for i in 1..NB_POKEMON-1
    baseStats=getBaseStatsFormattedForRandomizer(i)
    baseStat_target = 0
    for k in 0...baseStats.length
      baseStat_target+=baseStats[k]
    end
    baseStat_target = (baseStat_target/range).floor
    for j in 1...pokeArrayRand.length
      if $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] && $game_switches[SWITCH_RANDOM_WILD_TO_FUSION] && !customSpriteExists(pokeArrayRand[j])
        next
      end
      baseStats=getBaseStatsFormattedForRandomizer(pokeArrayRand[j])
      baseStat_temp = 0
      for l in 0...baseStats.length
        baseStat_temp+=baseStats[l]
      end
      baseStat_temp = (baseStat_temp/range).floor
      
      
      playShuffleSE(i)

      #if a match, add to hash, remove from array, and cycle to next poke in dex
      if (baseStat_temp == baseStat_target)
        psuedoBSTHash[i]=pokeArrayRand[j]
        pokeArrayRand.delete(pokeArrayRand[j])
            if i % 2 == 0 && type == 1
              n = (i.to_f/NB_POKEMON)*100
              Kernel.pbMessageNoSound(_INTL("\\ts[]Shuffling wild Pokémon...\\n {1}%\\^",sprintf('%.2f', n),NB_POKEMON))
            end
        break
      end
    end
  end
  psuedoBSTHash[NB_POKEMON] = NB_POKEMON
  #add hashes to global data
  $PokemonGlobal.psuedoHash = psuedoHash
  $PokemonGlobal.psuedoBSTHash = psuedoBSTHash  
end

def isPartArceus(poke,type=0)
  return true if poke == NB_POKEMON
  if type == 1
    return true if getBasePokemonID(poke,true) == NB_POKEMON
    return true if getBasePokemonID(poke,false) == NB_POKEMON
  end
  return false
end

#ajoute x happiness a tous les party member
def Kernel.raisePartyHappiness(increment)
  return
  #  for poke in $Trainer.party
  #    next if poke.isEgg?
  #    poke.happiness += increment
  #  end

end

#Randomizer code is shit. Too lazy to redo it.
# Here is a cheap workaround lol
def getBaseStatsFormattedForRandomizer(dex_num)
  statsArray=[]
  stats = GameData::Species.get(dex_num).base_stats
  statsArray << stats[:HP]
  statsArray << stats[:ATTACK]
  statsArray << stats[:DEFENSE]
  statsArray << stats[:SPECIAL_ATTACK]
  statsArray << stats[:SPECIAL_DEFENSE]
  statsArray << stats[:SPEED]
  return statsArray
end

# def Kernel.pbShuffleDexTrainers()
#   # create hash
#   psuedoHash = Hash.new
#   psuedoBSTHash = Hash.new
#
#   #Create array of all pokemon dex numbers
#   pokeArray = []
#   for i in 1..PBSpecies.maxValue
#     pokeArray.push(i)
#   end
#   #randomize hash
#   pokeArrayRand = pokeArray.dup
#   pokeArrayRand.shuffle!
#   pokeArray.insert(0,nil)
#   # fill random hash
#   #random hash will have to be accessed by number, not internal name
#   for i in 1...pokeArrayRand.length
#     psuedoHash[i]=pokeArrayRand[i]
#   end
#
#   #use pokeArrayRand to fill in the BST hash also
#   #loop through the actual dex, and use the first mon in pokeArrayRand with
#   #BST in the same 100 range
#   for i in 1..PBSpecies.maxValue
#     if i % 20 == 0
#       n = (i.to_f/PBSpecies.maxValue)*100
#       #Kernel.pbMessage(_INTL("\\ts[]Shuffling...\\n {1}%\\^",sprintf('%.2f', n),PBSpecies.maxValue))
#     end
#
#     baseStats=calcBaseStats(i)
#     baseStat_target = 0
#     for k in 0...baseStats.length
#       baseStat_target+=baseStats[k]
#     end
#     baseStat_target = (baseStat_target/50).floor
#     for j in 1...pokeArrayRand.length
#       baseStats=calcBaseStats([pokeArrayRand[j]])
#       baseStat_temp = 0
#       for l in 0...baseStats.length
#         baseStat_temp+=baseStats[l]
#       end
#       baseStat_temp = (baseStat_temp/50).floor
#       #if a match, add to hash, remove from array, and cycle to next poke in dex
#       if baseStat_temp == baseStat_target
#         psuedoBSTHash[i]=pokeArrayRand[j]
#         pokeArrayRand.delete(pokeArrayRand[j])
#         break
#       end
#     end
#   end
#
#   #add hashes to global data0
#   #$PokemonGlobal.psuedoHash = psuedoHash
#   $PokemonGlobal.pseudoBSTHashTrainers = psuedoBSTHash
# end

def getRandomizedTo(species)
  return species if !$PokemonGlobal.psuedoBSTHash
  return $PokemonGlobal.psuedoBSTHash[dexNum(species)]
  # code here
end

def tryRandomizeGiftPokemon(pokemon,dontRandomize=false)
  if $game_switches[SWITCH_RANDOM_GIFT_POKEMON] && $game_switches[SWITCH_RANDOM_WILD] && !dontRandomize
    oldSpecies = dexNum(pokemon.species)
    pokemon.species = getSpecies($PokemonGlobal.psuedoBSTHash[oldSpecies])
  end
end