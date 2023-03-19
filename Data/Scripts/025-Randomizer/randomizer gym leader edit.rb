#A l'entrée d'un gym: mettre $game_variables[113] = au numéro du gym
#pewter = 0, ceruean = 1 etc.
#Le remettre a -1 à la sortie du gym
#Le mettre a -1 au début du jeu
#
#Aussi des trucs modifiés dans le dude qui donne les freshwater au début
#Faudrait aussi s'assurer que il dise pas n'importe quoi en pas randomized
#
#Voir cerulean gym pour implantation
#
#
#
#
#initialiser la RANDOM_TYPE_ARRAY au début du jeu en runnant Kernel.initRandomTypeArray(8)
#
#
#
#
#
#
##################################################################
#   TODO:
#
#
#
###
###############################################################
#

#GYM_TYPES_ARRAY = [0,5,11,13,12,3,14,10,4,1,0,6,2,16,7,15,1,8,15,1,7,16,18,17,7,16]
GYM_TYPES_CLASSIC = [:NORMAL, :ROCK, :WATER, :ELECTRIC, :GRASS, :POISON, :PSYCHIC, :FIRE, :GROUND, :FIGHTING, :NORMAL, :BUG, :FLYING, :DRAGON, :GHOST, :ICE, :FIGHTING, :STEEL, :ICE, :FIGHTING, :GHOST, :DRAGON, :FAIRY, :DARK, :GHOST, :DRAGON]
GYM_TYPES_MODERN = [:NORMAL, :STEEL, :ICE, :FIGHTING, :BUG, :DARK, :FAIRY, :PSYCHIC, :NORMAL, :FIGHTING, :FAIRY, :GRASS, :BUG, :DRAGON, :FIRE, :GHOST, :GROUND, :ELECTRIC, :WATER, :ROCK, :POISON, :FLYING, :FAIRY, :DARK, :GHOST, :DRAGON]
GYM_TYPES_ARRAY = ($game_switches && $game_switches[SWITCH_MODERN_MODE]) ? GYM_TYPES_MODERN : GYM_TYPES_CLASSIC

#$randomTrainersArray = []

#[fighting dojo est 9eme (1), 0 au debut pour pasavoir a faire -1]

def Kernel.initRandomTypeArray()
  typesArray = GYM_TYPES_ARRAY.shuffle #ne pas remettre 10 (QMARKS)
  $game_variables[VAR_GYM_TYPES_ARRAY] = $game_switches[SWITCH_RANDOMIZED_GYM_TYPES] ? typesArray : GYM_TYPES_ARRAY
end

def setRivalStarter(starter1, starter2, starter3, choice)
  starters = [starter1, starter2, starter3]
  starters.delete_at(choice)
  if starters[0] > NB_POKEMON || starters[1] > NB_POKEMON
    rivalStarter = starters[0]
  else
    rivalStarter = starters[0] * NB_POKEMON + starters[1]
  end
  pbSet(VAR_RIVAL_STARTER, rivalStarter)
  $game_switches[SWITCH_DEFINED_RIVAL_STARTER] = true
end

def setRivalStarterSpecific(rivalStarter)
  pbSet(VAR_RIVAL_STARTER, rivalStarter)
  $game_switches[SWITCH_DEFINED_RIVAL_STARTER] = true
end

class PokeBattle_Battle
  CONST_BST_RANGE = 25 #unused. $game_variables[197] a la place
  def randomize_opponent_party(party)
    for pokemon in party
      next if !pokemon
      newspecies = rand(PBSpecies.maxValue - 1) + 1
      while !gymLeaderOk(newspecies) || bstOk(newspecies, pokemon.species, $game_variables[VAR_RANDOMIZER_WILD_POKE_BST])
        newspecies = rand(PBSpecies.maxValue - 1) + 1
      end
      pokemon.species = newspecies
      pokemon.name = PBSpecies.getName(newspecies)
      pokemon.resetMoves
      pokemon.calcStats
    end

    return party
  end

  def randomizedRivalFirstBattle(party)
    return party if $game_switches[953] #full random
    starter1 = $PokemonGlobal.psuedoBSTHash[1]
    starter2 = $PokemonGlobal.psuedoBSTHash[4]
    starter3 = $PokemonGlobal.psuedoBSTHash[7]
    playerChoice = $game_variables[7]

    for m in party
      next if !m
      case playerChoice
      when 0 then
        newspecies = starter2 * NB_POKEMON + starter3
      when 1 then
        newspecies = starter1 * NB_POKEMON + starter3
      when 2 then
        newspecies = starter1 * NB_POKEMON + starter2
      else
      end
      m.species = newspecies
      m.name = PBSpecies.getName(newspecies)
      m.resetMoves
      m.calcStats
    end
    return party
  end
end

#######
# end of class
######

####methodes utilitaires

# def getBaseStats(species)
#         basestatsum = $pkmn_dex[species][5][0] # HP
#         basestatsum +=$pkmn_dex[species][5][1] # Attack
#         basestatsum +=$pkmn_dex[species][5][2] # Defense
#         basestatsum +=$pkmn_dex[species][5][3] # Speed
#         basestatsum +=$pkmn_dex[species][5][4] # Special Attack
#         basestatsum +=$pkmn_dex[species][5][5]  # Special Defense
#      return basestatsum
# end
#

def bstOk(newspecies, oldPokemonSpecies, bst_range = 50)
  newBST = calcBaseStatsSum(newspecies)
  originalBST = calcBaseStatsSum(oldPokemonSpecies)
  return newBST < originalBST - bst_range || newBST > originalBST + bst_range
end

def gymLeaderOk(newspecies)
  return true if $game_variables[152] == -1 #not in a gym
  leaderType = getLeaderType()
  if leaderType == nil
    return true
  else
    return true if SpeciesHasType?(leaderType, newspecies)
  end
  return false
end

def getLeaderType()
  currentGym = $game_variables[152]
  if currentGym > $game_variables[151].length
    return nil
  else
    typeIndex = $game_variables[151][currentGym]
    type = PBTypes.getName(typeIndex)
  end
  return typeIndex
end

##Version alternatives de fonctions pour fonctionner avec numero de species
def SpeciesHasType?(type, species)
  if type.is_a?(String) || type.is_a?(Symbol)
    return isConst?(getSpeciesType1(species), PBTypes, type) || isConst?(getSpeciesType2(species), PBTypes, type)
  else
    return getSpeciesType1(species) == type || getSpeciesType2(species) == type
  end
end

# Returns this Pokémon's first type.
def getSpeciesType1(species)
  return $pkmn_dex[species][3]
end

# Returns this Pokémon's second type.
def getSpeciesType2(species)
  return $pkmn_dex[species][4]
end

############

#summarize random options
def Kernel.sumRandomOptions()
  answer = $game_switches[954] ? "On" : "Off"
  stringOptions = "\nStarters: " << answer

  answer = $game_switches[778] ? "On" : "Off"
  stringOptions << "\nWild Pokémon: " << answer << " "
  if $game_switches[777]
    stringOptions << "(Area)"
  else
    stringOptions << "(Global)"
  end

  answer = $game_switches[987] ? "On" : "Off"
  stringOptions << "\nTrainers: " << answer

  answer = $game_switches[955] ? "On" : "Off"
  stringOptions << "\nStatic encounters: " << answer

  answer = $game_switches[780] ? "On" : "Off"
  stringOptions << "\nGift Pokémon: " << answer

  answer = $game_switches[958] ? "On" : "Off"
  stringOptions << "\nItems: " << answer

  answer = $game_switches[959] ? "On" : "Off"
  stringOptions << "\nTMs: " << answer

  return stringOptions
end

def countVisitedMaps
  count = 0
  for i in 0..$PokemonGlobal.visitedMaps.length
    count += 1 if $PokemonGlobal.visitedMaps[i]
  end
  return count
end

def Kernel.sumGameStats()
  stringStats = ""

  stringStats << "Seen " << $Trainer.pokedexSeen.to_s << " Pokémon"
  stringStats << "\nCaught " << $Trainer.pokedexOwned.to_s << " Pokémon"

  stringStats << "\nBeaten the Elite Four " << $game_variables[174].to_s << " times"
  stringStats << "\nFused " << $game_variables[126].to_s << " Pokémon"

  stringStats << "\nRematched " << $game_variables[162].to_s << " Gym Leaders"
  stringStats << "\nTook " << $PokemonGlobal.stepcount.to_s << " steps"
  stringStats << "\nVisited " << countVisitedMaps.to_s << " different areas"

  if $game_switches[910]
    stringStats << "\nMade " << $game_variables[164].to_s << " Wonder Trades"
  end

  stringStats << "\nTipped $" << $game_variables[100].to_s << " to clowns"
  stringStats << "\nDestroyed " << $game_variables[163].to_s << " sandcastles"

  if $game_variables[43] > 0 || $game_variables[44] > 0
    stringStats << "\nWon $" << $game_variables[43].to_s << " against gamblers"
    stringStats << "\nLost $" << $game_variables[44].to_s << " against gamblers"
  end
  stringStats << "\nSpent $" << $game_variables[225].to_s << " at hotels"

  stringStats << "\nAccepted " << $game_variables[96].to_s << " quests"
  stringStats << "\nCompleted " << $game_variables[98].to_s << " quests"
  stringStats << "\nDiscovered " << $game_variables[193].to_s << " secrets"

  if $game_switches[912]
    stringStats << "\nDied " << $game_variables[191].to_s << " times in Pikachu's adventure"
    if $game_variables[193] >= 1
      stringStats << "\nCollected " << $game_variables[194].to_s << " coins with Pikachu"
    end
  end
  return stringStats
end

def Kernel.pbRandomizeTM()
  tmList = []
  for item in $itemData
    #machine=$ItemData[item][ITEMMACHINE]
    #movename=PBMoves.getName(machine)
    #Kernel.pbMessage(_INTL("It contained {1}.\1",item))

    tmList << item if pbIsHiddenMachine?(item)
  end
end

def getNewSpecies(oldSpecies, bst_range = 50, ignoreRivalPlaceholder = false, maxDexNumber = PBSpecies.maxValue)
  oldSpecies_dex = dexNum(oldSpecies)
  return oldSpecies_dex if (oldSpecies_dex == Settings::RIVAL_STARTER_PLACEHOLDER_SPECIES && !ignoreRivalPlaceholder)
  return oldSpecies_dex if oldSpecies_dex >= Settings::ZAPMOLCUNO_NB
  newspecies_dex = rand(maxDexNumber - 1) + 1
  i = 0
  while bstOk(newspecies_dex, oldSpecies_dex, bst_range)
    newspecies_dex = rand(maxDexNumber - 1) + 1
    i += 1
    if i % 10 == 0
      bst_range += 5
    end
  end
  return newspecies_dex
end

def getNewCustomSpecies(oldSpecies, customSpeciesList, bst_range = 50, ignoreRivalPlaceholder = false)
  oldSpecies_dex = dexNum(oldSpecies)
  return oldSpecies_dex if (oldSpecies_dex == Settings::RIVAL_STARTER_PLACEHOLDER_SPECIES && !ignoreRivalPlaceholder)
  return oldSpecies_dex if oldSpecies_dex >= Settings::ZAPMOLCUNO_NB
  i = rand(customSpeciesList.length - 1) + 1
  n = 0
  newspecies_dex = customSpeciesList[i]
  while bstOk(newspecies_dex, oldSpecies_dex, bst_range)
    i = rand(customSpeciesList.length - 1) #+1
    newspecies_dex = customSpeciesList[i]
    n += 1
    if n % 10 == 0
      bst_range += 5
    end
  end
  return newspecies_dex
end

def playShuffleSE(i)
  if i % 40 == 0 || i == 0
    pbSEPlay("Charm", 60)
  end
end

def getTrainersDataMode
  mode = GameData::Trainer
  if $game_switches && $game_switches[SWITCH_MODERN_MODE]
    mode = GameData::TrainerModern
  end
  return mode
end

def Kernel.pbShuffleTrainers(bst_range = 50, customsOnly = false, customsList = nil)
  bst_range = pbGet(VAR_RANDOMIZER_TRAINER_BST)

  if customsOnly && customsList == nil
    customsOnly = false
  end
  randomTrainersHash = Hash.new
  trainers_data = GameData::Trainer.list_all
  trainers_data.each do |key, value|
    trainer = trainers_data[key]
    i = 0
    new_party = []
    for poke in trainer.pokemon
      old_poke = GameData::Species.get(poke[:species]).id_number
      new_poke = customsOnly ? getNewCustomSpecies(old_poke, customsList, bst_range) : getNewSpecies(old_poke, bst_range)
      new_party << new_poke
    end
    randomTrainersHash[trainer.id] = new_party
    playShuffleSE(i)
    i += 1
    if i % 2 == 0
      n = (i.to_f / trainers.length) * 100
      Kernel.pbMessageNoSound(_INTL("\\ts[]Shuffling trainers...\\n {1}%\\^", sprintf('%.2f', n), PBSpecies.maxValue))
    end
  end
  $PokemonGlobal.randomTrainersHash = randomTrainersHash
end

# def Kernel.pbShuffleTrainers(bst_range = 50)
#   randomTrainersHash = Hash.new
#
#   trainers=load_data("Data/trainers.dat")
#   i=0
#   for trainer in trainers
#     for poke in trainer[3]
#       poke[TPSPECIES]=getNewSpecies(poke[TPSPECIES])
#     end
#     randomTrainersHash[i] = (trainer)
#     playShuffleSE(i)
#     i += 1
#     if i % 2 == 0
#       n = (i.to_f/trainers.length)*100
#       Kernel.pbMessageNoSound(_INTL("\\ts[]Shuffling trainers...\\n {1}%\\^",sprintf('%.2f', n),PBSpecies.maxValue))
#     end
#     #Kernel.pbMessage(_INTL("pushing trainer {1}: {2} ",i,trainer))
#   end
#   $PokemonGlobal.randomTrainersHash = randomTrainersHash
# end

def Kernel.pbShuffleTrainersCustom(bst_range = 50)
  randomTrainersHash = Hash.new
  bst_range = pbGet(VAR_RANDOMIZER_TRAINER_BST)

  Kernel.pbMessage(_INTL("Parsing custom sprites folder"))
  customsList = getCustomSpeciesList()
  Kernel.pbMessage(_INTL("{1} sprites found", customsList.length.to_s))

  if customsList.length == 0
    Kernel.pbMessage(_INTL("To use custom sprites, please place correctly named sprites in the /CustomBattlers folder. See readMe.txt for more information"))
    Kernel.pbMessage(_INTL("Trainer Pokémon will include auto-generated sprites."))
    return Kernel.pbShuffleTrainers(bst_range)
  elsif customsList.length < 200
    if Kernel.pbConfirmMessage(_INTL("Too few custom sprites were found. This will result in a very low Pokémon variety for trainers. Continue anyway?"))
      bst_range = 999
    else
      Kernel.pbMessage(_INTL("Trainer Pokémon will include auto-generated sprites."))
      return Kernel.pbShuffleTrainers(bst_range) ##use regular shuffle if not enough sprites
    end
  end
  Kernel.pbShuffleTrainers(bst_range, true, customsList)
end


# trainers=load_data("Data/trainers.dat")
# i=0
# for trainer in trainers
#   for poke in trainer[3]
#     poke[TPSPECIES]=getNewCustomSpecies(poke[TPSPECIES],customsList)
#   end
#   randomTrainersHash[i] = (trainer)
#   playShuffleSE(i)
#   i += 1
#   if i % 2 == 0
#     n = (i.to_f/trainers.length)*100
#     Kernel.pbMessageNoSound(_INTL("\\ts[]Shuffling trainers (custom sprites only)...\\n {1}%\\^",sprintf('%.2f', n),PBSpecies.maxValue))
#   end
#   #Kernel.pbMessage(_INTL("pushing trainer {1}: {2} ",i,trainer))
# end
# $PokemonGlobal.randomTrainersHash = randomTrainersHash

#def getRandomCustomSprite()
#    filesList = Dir["./Graphics/CustomBattlers/*"]
#    i = rand(filesList.length-1)
#    path = filesList[i]
#    file  = File.basename(path, ".*")
#    splitPoke = file.split(".")
#    head = splitPoke[0].to_i
#    body = splitPoke[1].to_i
#    return (body*NB_POKEMON)+head
#end


def getCustomSpeciesList(allowOnline=true)
  speciesList = []

  for num in 1..NB_POKEMON
    path = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED + num.to_s + "/*"
    filesList = Dir[path]
    maxDexNumber = (NB_POKEMON * NB_POKEMON) + NB_POKEMON
    maxVal = filesList.length - 1
    for i in 0..maxVal
      path = filesList[i]
      file = File.basename(path, ".*")
      fused = getDexNumFromFilename(file)
      if fused <= maxDexNumber && fused > 0
        speciesList << fused
      end

    end
  end


  if speciesList.length <= 200 && allowOnline
    #try to get list from github
    online_list = list_online_custom_sprites
    return nil if !online_list
    species_id_list = []
    for file in online_list
      species_id_list << getDexNumFromFilename(file)
    end
    return species_id_list
  end


  return speciesList
end

#input: ex: 10.10.png
def getDexNumFromFilename(filename)
  splitPoke = filename.split(".")
  head = splitPoke[0].to_i
  body = splitPoke[1].to_i
  return (body * NB_POKEMON) + head
end

# def getCustomSpeciesList()
#   filesList = Dir["./Graphics/CustomBattlers/*"]
#   maxDexNumber = (NB_POKEMON * NB_POKEMON) + NB_POKEMON
#   maxVal = filesList.length - 1
#   for i in 0..maxVal
#     path = filesList[i]
#     file = File.basename(path, ".*")
#     splitPoke = file.split(".")
#     head = splitPoke[0].to_i
#     body = splitPoke[1].to_i
#     fused = (body * NB_POKEMON) + head
#     if fused <= maxDexNumber && fused > 0
#       speciesList << fused
#     end
#
#   end
# end


def Kernel.getBaseStats(species)
  if $pkmn_dex[species] == nil
    print species
  end

  basestatsum = $pkmn_dex[species][5][0] # HP
  basestatsum += $pkmn_dex[species][5][1] # Attack
  basestatsum += $pkmn_dex[species][5][2] # Defense
  basestatsum += $pkmn_dex[species][5][3] # Speed
  basestatsum += $pkmn_dex[species][5][4] # Special Attack
  basestatsum += $pkmn_dex[species][5][5] # Special Defense
  return basestatsum
end

def Kernel.gymLeaderRematchHint()
  hints = [
    "I heard that Brock has a huge interest in Pokémon fossils. He donated a lot of fossils he excavated to the Pewter City Museum.",
    "Misty is a pro at swimming. I heard she trains every single morning.",
    "Did you know that Lt. Surge used the magnetic fields generated by his Pokémon to navigate his plane back when he was in the army. He still loves a good magnetic field.",
    "Erika is a lover of nature. She loves going to parks to relax during the day.",
    "Koga has been seen leaving Fuschia city in the evenings. The rumors say he's preparing for a new job somewhere else...",
    "People say that Sabrina never sleeps. I wonder where she goes when she leaves her gym at night.",
    "The hot-headed Blaine is a man of extremes. He likes to explore around his hometown during the day.",
    "Giovanni is a mysterious man. I wonder where he goes in the evening. Probably somewhere as remote as possible to meditate in peace...",
    "I heard that Whitney went to school in one of the towns near Goldenrod before becoming a Gym Leader. She kept in touch with her old teacher and she goes to visit sometimes in the evening.",
    "Kurt is always on the lookout for Bug-type Pokémon. He goes hunting early in the morning.",
    "Falkner rises up early in the morning. You can usually find him in high places.",
    "Clair is a member of a famous clan of dragon masters. She goes to a special place to pray at night.",
    "Chuck is a martial arts pro. I've seen him train with Saffron City's dojo master back in the days.",
    "Morty is a mysterious man. He's been known to be one of the few people who dare enter Pokémon Tower at night.",
    "Pryce is an ice-type expert who has been around for a long time. He used to train in the Ice Tunnel between Mahogany Town and Blackthorn City before it froze over.",
    "Jasmine is on vacation in the Sevii Islands. She likes to rise up early to explore around the islands when no one's around."
  ]
  arr = []
  n = 0
  for i in 426..437
    if !$game_switches[i]
      arr.push(n)
    end
    n += 1
  end
  arr.push(508); arr.push(509); arr.push(510); arr.push(511);
  n += 4

  if arr.length > 0
    return hints[arr[rand(arr.length)]]
  end
  return "You got every Gym Leader to come here. This place is more popular than ever!\nNow go and battle them!"
end

def getTrainerParty(trainer)
  if $game_switches[47]
    for poke in trainer[3]
      inverseFusion(poke)
    end
  end
  return trainer[3]
end

def inverseFusion(pokemon)
  species = pokemon[TPSPECIES]
  return pokemon if species <= CONST_NB_POKE
  return pokemon if species > (CONST_NB_POKE * CONST_NB_POKE) + CONST_NB_POKE
  body = getBasePokemonID(species, true)
  head = getBasePokemonID(species, false)
  newspecies = (head) * CONST_NB_POKE + body
  pokemon[TPSPECIES] = newspecies
  return pokemon
end

def addRandomHeldItems(trainerParty)
  for poke in trainerParty
    if poke.item == nil
      poke.item = PBItems::ORANBERRY #PBItems.sample
    end
  end
end

def addHealingItem(items)
  if $Trainer.numbadges < 1
    items << PBItems::ORANBERRY
  elsif $Trainer.numbadges <= 2
    items << PBItems::POTION
  elsif $Trainer.numbadges <= 4
    items << PBItems::SUPERPOTION
  elsif $Trainer.numbadges <= 6
    items << PBItems::FULLHEAL
    items << PBItems::SUPERPOTION
  elsif $Trainer.numbadges <= 8
    items << PBItems::FULLHEAL
    items << PBItems::HYPERPOTION
  elsif $Trainer.numbadges >= 9
    items << PBItems::FULLRESTORE
  end

  return items
end

#####Overload de pbLoadTrainer
#
#  def pbLoadTrainer(trainerid,trainername,partyid=0)
#   if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
#     if !hasConst?(PBTrainers,trainerid)
#       raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
#     end
#     trainerid=getID(PBTrainers,trainerid)
#   end
#   success=false
#   items=[]
#   party=[]
#   opponent=nil
#   trainers=load_data("Data/trainers.dat")
#   trainerIndex=-1
#
#   for trainer in trainers
#     trainerIndex+=1
#     name=trainer[1]
#     thistrainerid=trainer[0]
#     thispartyid=trainer[4]
#     next if trainerid!=thistrainerid || name!=trainername || partyid!=thispartyid
#     items=trainer[2].clone
#
#     if $game_switches[666]  #hard mode
#       items = addHealingItem(items)
#     end
#
#
#     name=pbGetMessageFromHash(MessageTypes::TrainerNames,name)
#     for i in RIVALNAMES
#       if isConst?(trainerid,PBTrainers,i[0]) && $game_variables[i[1]]!=0
#         name=$game_variables[i[1]]
#       end
#     end
#     opponent=PokeBattle_Trainer.new(name,thistrainerid)
#     opponent.setForeignID($Trainer) if $Trainer
#
#
#     #use le random Array si randomized starters (et pas 1ere rival battle)
#     isPlayingRandomized =  $game_switches[987] && !$game_switches[46]
#     if isPlayingRandomized && $PokemonGlobal.randomTrainersHash[trainerIndex] == nil
#       Kernel.pbMessage(_INTL("The trainers need to be re-shuffled."))
#       Kernel.pbShuffleTrainers()
#     end
#     trainerParty = isPlayingRandomized ? $PokemonGlobal.randomTrainersHash[trainerIndex][3] : getTrainerParty(trainer)
#
#
#     isRematch = $game_switches[200]
#     rematchId = getRematchId(trainername,trainerid)
#     for poke in trainerParty
#       ##
#       species=poke[TPSPECIES]
#       species = replaceRivalStarterIfNecessary(species)
#
#
#       level= $game_switches[666] ? (poke[TPLEVEL]*1.1).ceil : poke[TPLEVEL]
#
#       if isRematch
#          nbRematch = getNumberRematch(rematchId)
#          level = getRematchLevel(level,nbRematch)
#          species = evolveRematchPokemon(nbRematch,species)
#        end
#
#       pokemon=PokeBattle_Pokemon.new(species,level,opponent)
#       #pokemon.form=poke[TPFORM]
#       pokemon.resetMoves
#
#
#       pokemon.setItem( $game_switches[843] ? rand(PBItems.maxValue) : poke[TPITEM])
#
#       if poke[TPMOVE1]>0 || poke[TPMOVE2]>0 || poke[TPMOVE3]>0 || poke[TPMOVE4]>0
#         k=0
#         for move in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
#           pokemon.moves[k]=PBMove.new(poke[move])
#           k+=1
#         end
#         pokemon.moves.compact!
#       end
#       pokemon.setAbility(poke[TPABILITY])
#       pokemon.setGender(poke[TPGENDER])
#       if poke[TPSHINY]   # if this is a shiny Pokémon
#         pokemon.makeShiny
#       else
#         pokemon.makeNotShiny
#       end
#       pokemon.setNature(poke[TPNATURE])
#       iv=poke[TPIV]
#       for i in 0...6
#         pokemon.iv[i]=iv&0x1F
#         pokemon.ev[i]=[85,level*3/2].min
#       end
#       pokemon.happiness=poke[TPHAPPINESS]
#       pokemon.name=poke[TPNAME] if poke[TPNAME] && poke[TPNAME]!=""
#       if poke[TPSHADOW]   # if this is a Shadow Pokémon
#         pokemon.makeShadow rescue nil
#         pokemon.pbUpdateShadowMoves(true) rescue nil
#         pokemon.makeNotShiny
#       end
#       pokemon.ballused=poke[TPBALL]
#       pokemon.calcStats
#       party.push(pokemon)
#     end
#     success=true
#     break
#   end
#   return success ? [opponent,items,party] : nil
# end

def getRematchId(trainername, trainerid)
  return trainername + trainerid.to_s
end

def replaceRivalStarterIfNecessary(species)
  if species == RIVAL_STARTER_PLACEHOLDER_SPECIES
    if !$game_switches[840] || pbGet(250) == 0 #not DEFINED_RIVAL_STARTER
      fixRivalStarter()
    end
    rivalStarter = pbGet(250)
    if rivalStarter > 0
      species = pbGet(250)
    end
  end
  return species
end

def fixRivalStarter()
  #set starter baseform
  if $PokemonGlobal.psuedoBSTHash == nil
    psuedoHash = Hash.new
    for i in 0..NB_POKEMON
      psuedoHash[i] = i
    end
    $PokemonGlobal.psuedoBSTHash = psuedoHash
  end
  starterChoice = pbGet(7)

  s1 = $PokemonGlobal.psuedoBSTHash[1]
  s2 = $PokemonGlobal.psuedoBSTHash[4]
  s3 = $PokemonGlobal.psuedoBSTHash[7]
  setRivalStarter(s3, s2, s1, starterChoice)

  #evolve en fct des badges
  rivalStarter = pbGet(250)

  if $game_switches[68] #beat blue cerulean
    rivalStarter = evolveBody(rivalStarter)
  end

  if $game_switches[89] #beat blue SS Anne
    rivalStarter = evolveHead(rivalStarter)
  end

  if $game_switches[228] #beat silph co
    rivalStarter = evolveBody(rivalStarter)
  end

  if $game_switches[11] #got badge 8
    rivalStarter = evolveHead(rivalStarter)
  end

  if $game_switches[12] #beat league
    rivalStarter = evolveBody(rivalStarter)
    rivalStarter = evolveHead(rivalStarter)
  end

  #RIVAL_STARTER_IS_DEFINED
  pbSet(250, rivalStarter)
  $game_switches[840] = true
end
