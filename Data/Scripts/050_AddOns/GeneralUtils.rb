def pbAddPokemonID(pokemon, level = nil, seeform = true, dontRandomize = false)
  return if !pokemon || !$Trainer
  dontRandomize = true if $game_switches[3] #when choosing starters

  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end

  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = Pokemon.new(pokemon, level, $Trainer)
  end
  #random species if randomized gift pokemon &  wild poke
  if $game_switches[780] && $game_switches[778] && !dontRandomize
    oldSpecies = pokemon.species
    pokemon.species = $PokemonGlobal.psuedoBSTHash[oldSpecies]
  end

  speciesname = PBSpecies.getName(pokemon.species)
  Kernel.pbMessage(_INTL("{1} obtained {2}!\\se[itemlevel]\1", $Trainer.name, speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  return true
end

def pbAddPokemonID(pokemon_id, level = 1, see_form = true, skip_randomize = false)
  return false if !pokemon_id
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  if pokemon_id.is_a?(Integer) && level.is_a?(Integer)
    pokemon = Pokemon.new(pokemon_id, level)
    species_name = pokemon.speciesName
  end

  #random species if randomized gift pokemon &  wild poke
  if $game_switches[780] && $game_switches[778] && !skip_randomize
    oldSpecies = pokemon.species
    pokemon.species = $PokemonGlobal.psuedoBSTHash[oldSpecies]
  end

  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $Trainer.name, species_name))
  pbNicknameAndStore(pokemon)
  $Trainer.pokedex.register(pokemon) if see_form
  return true
end

def pbHasSpecies?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    id = getID(PBSpecies, species)
  elsif species.is_a?(Pokemon)
    id = species.dexNum
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.dexNum == id
  end
  return false
end


#ancienne methode qui est encore callée un peu partout dans les vieux scripts
def getID(pbspecies_unused,species)
  if species.is_a?(String)
    return nil
  elsif species.is_a?(Symbol)
    return GameData::Species.get(species).id_number
  elsif species.is_a?(Pokemon)
    id = species.dexNum
  end
end
#Check if the Pokemon can learn a TM
def CanLearnMove(pokemon, move)
  species = getID(PBSpecies, pokemon)
  return false if species <= 0
  data = load_data("Data/tm.dat")
  return false if !data[move]
  return data[move].any? { |item| item == species }
end

def pbPokemonIconFile(pokemon)
  bitmapFileName = pbCheckPokemonIconFiles(pokemon.species, pokemon.isEgg?)
  return bitmapFileName
end

def pbCheckPokemonIconFiles(speciesNum, egg = false, dna = false)
  if egg
    bitmapFileName = sprintf("Graphics/Icons/iconEgg")
    return pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName = sprintf("Graphics/Icons/icon%03d", speciesNum)
    ret = pbResolveBitmap(bitmapFileName)
    return ret if ret
  end
  ret = pbResolveBitmap("Graphics/Icons/iconDNA.png")
  return ret if ret
  return pbResolveBitmap("Graphics/Icons/iconDNA.png")
end

def getDexNumberForSpecies(species)
  return species if species.is_a?(Integer)
  if species.is_a?(Symbol)
    dexNum = GameData::Species.get(species).id_number
  elsif species.is_a?(Pokemon)
    dexNum = GameData::Species.get(species.species).id_number
  elsif species.is_a?(GameData::Species)
    return species.id_number
  else
    dexNum = species
  end
  return dexNum
end

def getPokemon(dexNum)
  return GameData::Species.get(dexNum)
end

#shortcut for using in game events because of script characters limit
def dexNum(species)
  return getDexNumberForSpecies(species)
end

def getRandomCustomFusion(returnRandomPokemonIfNoneFound = true, customPokeList = [], maxPoke = -1, recursionLimit = 3)
  if customPokeList.length == 0
    customPokeList = getCustomSpeciesList()
  end
  randPoke = []
  if customPokeList.length >= 5000
    chosen = false
    i = 0 #loop pas plus que 3 fois pour pas lag
    while chosen == false
      fusedPoke = customPokeList[rand(customPokeList.length)]
      poke1 = getBasePokemonID(fusedPoke, false)
      poke2 = getBasePokemonID(fusedPoke, true)

      if ((poke1 <= maxPoke && poke2 <= maxPoke) || i >= recursionLimit) || maxPoke == -1
        randPoke << getBasePokemonID(fusedPoke, false)
        randPoke << getBasePokemonID(fusedPoke, true)
        chosen = true
      end
    end
  else
    if returnRandomPokemonIfNoneFound
      randPoke << rand(maxPoke) + 1
      randPoke << rand(maxPoke) + 1
    end
  end

  return randPoke
end

def getBodyID(species)
  dexNum = getDexNumberForSpecies(species)
  return (dexNum / NB_POKEMON).round
end

def getHeadID(species, bodyId = nil)
  if bodyId == nil
    bodyId = getBodyID(species)
  end
  head_dexNum = getDexNumberForSpecies(species)
  body_dexNum = getDexNumberForSpecies(bodyId)
  calculated_number = (head_dexNum - (body_dexNum * NB_POKEMON)).round
  return calculated_number == 0 ? 420 : calculated_number
end

def getAllNonLegendaryPokemon()
  list = []
  for i in 1..143
    list.push(i)
  end
  for i in 147..149
    list.push(i)
  end
  for i in 152..242
    list.push(i)
  end
  list.push(246)
  list.push(247)
  list.push(248)
  for i in 252..314
    list.push(i)
  end
  for i in 316..339
    list.push(i)
  end
  for i in 352..377
    list.push(i)
  end
  for i in 382..420
    list.push(i)
  end
  return list
end

def getPokemonEggGroups(species)
  return GameData::Species.get(species).egg_groups
end

def generateEggGroupTeam(eggGroup)
  teamComplete = false
  generatedTeam = []
  while !teamComplete
    species = rand(PBSpecies.maxValue)
    if getPokemonEggGroups(species).include?(eggGroup)
      generatedTeam << species
    end
    teamComplete = generatedTeam.length == 3
  end
  return generatedTeam
end

def pbGetSelfSwitch(eventId, switch)
  return $game_self_switches[[@map_id, eventId, switch]]
end

def obtainBadgeMessage(badgeName)
  Kernel.pbMessage(_INTL("\\me[Badge get]{1} obtained the {2}!", $Trainer.name, badgeName))
end

def getAllNonLegendaryPokemon()
  list = []
  for i in 1..143
    list.push(i)
  end
  for i in 147..149
    list.push(i)
  end
  for i in 152..242
    list.push(i)
  end
  list.push(246)
  list.push(247)
  list.push(248)
  for i in 252..314
    list.push(i)
  end
  for i in 316..339
    list.push(i)
  end
  for i in 352..377
    list.push(i)
  end
  for i in 382..420
    list.push(i)
  end
  return list
end

def generateSimpleTrainerParty(teamSpecies, level)
  team = []
  for species in teamSpecies
    poke = Pokemon.new(species, level)
    team << poke
  end
  return team
end

def isSinnohPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  list =
    [254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265,
     266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 288, 294,
     295, 296, 297, 298, 299, 305, 306, 307, 308, 315, 316, 317,
     318, 319, 320, 321, 322, 323, 324, 326, 332, 343, 344, 345,
     346, 347, 352, 353, 354, 358, 383, 384, 388, 389, 400, 402, 403]
  return list.include?(dexNum)
end

def isHoennPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  list = [252, 253, 276, 277, 278, 279, 280, 281, 282, 283, 284,
          285, 286, 287, 289, 290, 291, 292, 293, 300, 301, 302, 303,
          304, 309, 310, 311, 312, 313, 314, 333, 334, 335, 336, 340,
          341, 342, 355, 356, 357, 378, 379, 380, 381, 382, 385, 386, 387, 390,
          391, 392, 393, 394, 395, 396, 401, 404, 405]
  return list.include?(dexNum)
end

def pbBitmap(path)
  if !pbResolveBitmap(path).nil?
    bmp = RPG::Cache.load_bitmap_path(path)
    bmp.storedPath = path
  else
    p "Image located at '#{path}' was not found!" if $DEBUG
    bmp = Bitmap.new(1, 1)
  end
  return bmp
end

def Kernel.setRocketPassword(variableNum)
  abilityIndex = rand(233)
  speciesIndex = rand(PBSpecies.maxValue - 1)

  word1 = PBSpecies.getName(speciesIndex)
  word2 = GameData::Ability.get(abilityIndex).name
  password = _INTL("{1}'s {2}", word1, word2)
  pbSet(variableNum, password)
end

def getGenericPokemonCryText(pokemonSpecies)
  case pokemonSpecies
  when 25
    return "Pika!"
  when 16, 17, 18, 21, 22, 144, 145, 146, 227, 417, 418, 372 #birds
    return "Squawk!"
  when 163, 164
    return "Hoot!" #owl
  else
    return "Guaugh!"
  end
end

def obtainPokemonSpritePath(id, includeCustoms = true)
  head = getBasePokemonID(param.to_i, false)
  body = getBasePokemonID(param.to_i, true)
  return obtainPokemonSpritePath(body, head, includeCustoms)
end

def obtainPokemonSpritePath(bodyId, headId, include_customs = true)
  picturePath = _INTL("Graphics/Battlers/{1}/{1}.{2}.png", headId, bodyId)

  if include_customs
    pathCustom = getCustomSpritePath(bodyId,headId)
    if (pbResolveBitmap(pathCustom))
      picturePath = pathCustom
    end
  end
  return picturePath
end

def getCustomSpritePath(body,head)
  return _INTL("Graphics/CustomBattlers/{1}.{2}.png", head, body)
end

def customSpriteExists(species)
  head = getBasePokemonID(species, false)
  body = getBasePokemonID(species, true)
  pathCustom = getCustomSpritePath(body,head)
  return pbResolveBitmap(pathCustom) != nil
end

def getArceusPlateType(heldItem)
  return :NORMAL if heldItem == nil
  case heldItem
  when :FISTPLATE
    return :FIGHTING
  when :SKYPLATE
    return :FLYING
  when :TOXICPLATE
    return :POISON
  when :EARTHPLATE
    return :GROUND
  when :STONEPLATE
    return :ROCK
  when :INSECTPLATE
    return :BUG
  when :SPOOKYPLATE
    return :GHOST
  when :IRONPLATE
    return :STEEL
  when :FLAMEPLATE
    return :FIRE
  when :SPLASHPLATE
    return :WATER
  when :MEADOWPLATE
    return :GRASS
  when :ZAPPLATE
    return :ELECTRIC
  when :MINDPLATE
    return :PSYCHIC
  when :ICICLEPLATE
    return :ICE
  when :DRACOPLATE
    return :DRAGON
  when :DREADPLATE
    return :DARK
  when :PIXIEPLATE
    return :FAIRY
  else
    return :NORMAL
  end
end

def reverseFusionSpecies(species)
  dexId = getDexNumberForSpecies(species)
  return species if dexId <= NB_POKEMON
  return species if dexId > (NB_POKEMON * NB_POKEMON) + NB_POKEMON
  body = getBasePokemonID(dexId, true)
  head = getBasePokemonID(dexId, false)
  newspecies = (head) * NB_POKEMON + body
  return getPokemon(newspecies)
end

def Kernel.getRoamingMap(roamingArrayPos)
  curmap=$PokemonGlobal.roamPosition[roamingArrayPos]
  mapinfos=$RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
  text= mapinfos[curmap].name#,(curmap==$game_map.map_id) ? _INTL("(this map)") : "")
  return text
end

def Kernel.listPlatesInBag()
  list = []
  list << PBItems::FISTPLATE if $PokemonBag.pbQuantity(:FISTPLATE)>=1
  list << PBItems::SKYPLATE if $PokemonBag.pbQuantity(:SKYPLATE)>=1
  list << PBItems::TOXICPLATE if $PokemonBag.pbQuantity(:TOXICPLATE)>=1
  list << PBItems::EARTHPLATE if $PokemonBag.pbQuantity(:EARTHPLATE)>=1
  list << PBItems::STONEPLATE if $PokemonBag.pbQuantity(:STONEPLATE)>=1
  list << PBItems::INSECTPLATE if $PokemonBag.pbQuantity(:INSECTPLATE)>=1
  list << PBItems::SPOOKYPLATE if $PokemonBag.pbQuantity(:SPOOKYPLATE)>=1
  list << PBItems::IRONPLATE if $PokemonBag.pbQuantity(:IRONPLATE)>=1
  list << PBItems::FLAMEPLATE if $PokemonBag.pbQuantity(:FLAMEPLATE)>=1
  list << PBItems::SPLASHPLATE if $PokemonBag.pbQuantity(:SPLASHPLATE)>=1
  list << PBItems::MEADOWPLATE if $PokemonBag.pbQuantity(:MEADOWPLATE)>=1
  list << PBItems::ZAPPLATE if $PokemonBag.pbQuantity(:ZAPPLATE)>=1
  list << PBItems::MINDPLATE if $PokemonBag.pbQuantity(:MINDPLATE)>=1
  list << PBItems::ICICLEPLATE if $PokemonBag.pbQuantity(:ICICLEPLATE)>=1
  list << PBItems::DRACOPLATE if $PokemonBag.pbQuantity(:DRACOPLATE)>=1
  list << PBItems::DREADPLATE if $PokemonBag.pbQuantity(:DREADPLATE)>=1
  list << PBItems::PIXIEPLATE if $PokemonBag.pbQuantity(:PIXIEPLATE)>=1
  return list
end

def Kernel.getItemNamesAsString(list)
  strList = ""
  for i in 0..list.length-1
    id = list[i]
    name =PBItems.getName(id)
    strList += name
    if i != list.length-1 && list.length > 1
      strList += ","
    end
  end
  return strList
end



def Kernel.getPlateType(item)
  return :FIGHTING if item == PBItems::FISTPLATE
  return :FLYING if item == PBItems::SKYPLATE
  return :POISON if item == PBItems::TOXICPLATE
  return :GROUND if item == PBItems::EARTHPLATE
  return :ROCK if item == PBItems::STONEPLATE
  return :BUG if item == PBItems::INSECTPLATE
  return :GHOST if item == PBItems::SPOOKYPLATE
  return :STEEL if item == PBItems::IRONPLATE
  return :FIRE if item == PBItems::FLAMEPLATE
  return :WATER if item == PBItems::SPLASHPLATE
  return :GRASS if item == PBItems::MEADOWPLATE
  return :ELECTRIC if item == PBItems::ZAPPLATE
  return :PSYCHIC if item == PBItems::MINDPLATE
  return :ICE if item == PBItems::ICICLEPLATE
  return :DRAGON if item == PBItems::DRACOPLATE
  return :DARK if item == PBItems::DREADPLATE
  return :FAIRY if item == PBItems::PIXIEPLATE
  return -1
end