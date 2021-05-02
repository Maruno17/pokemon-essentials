#===============================================================================
# Nicknaming and storing Pokémon
#===============================================================================
def pbBoxesFull?
  return ($Trainer.party_full? && $PokemonStorage.full?)
end

def pbNickname(pkmn)
  species_name = pkmn.speciesName
  if pbConfirmMessage(_INTL("Would you like to give a nickname to {1}?", species_name))
    pkmn.name = pbEnterPokemonName(_INTL("{1}'s nickname?", species_name),
                                   0, Pokemon::MAX_NAME_SIZE, "", pkmn)
  end
end

def pbStorePokemon(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pkmn.record_first_moves
  if $Trainer.party_full?
    oldcurbox = $PokemonStorage.currentBox
    storedbox = $PokemonStorage.pbStoreCaught(pkmn)
    curboxname = $PokemonStorage[oldcurbox].name
    boxname = $PokemonStorage[storedbox].name
    creator = nil
    creator = pbGetStorageCreator if $Trainer.seen_storage_creator
    if storedbox != oldcurbox
      if creator
        pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1", curboxname, creator))
      else
        pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1", curboxname))
      end
      pbMessage(_INTL("{1} was transferred to box \"{2}.\"", pkmn.name, boxname))
    else
      if creator
        pbMessage(_INTL("{1} was transferred to {2}'s PC.\1", pkmn.name, creator))
      else
        pbMessage(_INTL("{1} was transferred to someone's PC.\1", pkmn.name))
      end
      pbMessage(_INTL("It was stored in box \"{1}.\"", boxname))
    end
  else
    $Trainer.party[$Trainer.party.length] = pkmn
  end
end

def pbNicknameAndStore(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  $Trainer.pokedex.set_seen(pkmn.species)
  $Trainer.pokedex.set_owned(pkmn.species)
  pbNickname(pkmn)
  pbStorePokemon(pkmn)
end

#===============================================================================
# Giving Pokémon to the player (will send to storage if party is full)
#===============================================================================
def pbAddPokemon(pkmn, level = 1, see_form = true)
  return false if !pkmn
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  species_name = pkmn.speciesName
  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $Trainer.name, species_name))
  pbNicknameAndStore(pkmn)
  $Trainer.pokedex.register(pkmn) if see_form
  return true
end

def pbAddPokemonSilent(pkmn, level = 1, see_form = true)
  return false if !pkmn || pbBoxesFull?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  $Trainer.pokedex.register(pkmn) if see_form
  $Trainer.pokedex.set_owned(pkmn.species)
  pkmn.record_first_moves
  if $Trainer.party_full?
    $PokemonStorage.pbStoreCaught(pkmn)
  else
    $Trainer.party[$Trainer.party.length] = pkmn
  end
  return true
end

#===============================================================================
# Giving Pokémon/eggs to the player (can only add to party)
#===============================================================================
def pbAddToParty(pkmn, level = 1, see_form = true)
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  species_name = pkmn.speciesName
  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $Trainer.name, species_name))
  pbNicknameAndStore(pkmn)
  $Trainer.pokedex.register(pkmn) if see_form
  return true
end

def pbAddToPartySilent(pkmn, level = nil, see_form = true)
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  $Trainer.pokedex.register(pkmn) if see_form
  $Trainer.pokedex.set_owned(pkmn.species)
  pkmn.record_first_moves
  $Trainer.party[$Trainer.party.length] = pkmn
  return true
end

def pbAddForeignPokemon(pkmn, level = 1, owner_name = nil, nickname = nil, owner_gender = 0, see_form = true)
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  # Set original trainer to a foreign one
  pkmn.owner = Pokemon::Owner.new_foreign(owner_name || "", owner_gender)
  # Set nickname
  pkmn.name = nickname[0, Pokemon::MAX_NAME_SIZE] if !nil_or_empty?(nickname)
  # Recalculate stats
  pkmn.calc_stats
  if owner_name
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon from {2}.\1", $Trainer.name, owner_name))
  else
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon.\1", $Trainer.name))
  end
  pbStorePokemon(pkmn)
  $Trainer.pokedex.register(pkmn) if see_form
  $Trainer.pokedex.set_owned(pkmn.species)
  return true
end

def pbGenerateEgg(pkmn, text = "")
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, Settings::EGG_LEVEL) if !pkmn.is_a?(Pokemon)
  # Set egg's details
  pkmn.name           = _INTL("Egg")
  pkmn.steps_to_hatch = pkmn.species_data.hatch_steps
  pkmn.obtain_text    = text
  pkmn.calc_stats
  # Add egg to party
  $Trainer.party[$Trainer.party.length] = pkmn
  return true
end
alias pbAddEgg pbGenerateEgg
alias pbGenEgg pbGenerateEgg

#===============================================================================
# Analyse Pokémon in the party
#===============================================================================
# Returns the first unfainted, non-egg Pokémon in the player's party.
def pbFirstAblePokemon(variable_ID)
  $Trainer.party.each_with_index do |pkmn, i|
    next if !pkmn.able?
    pbSet(variable_ID, i)
    return pkmn
  end
  pbSet(variable_ID, -1)
  return nil
end

#===============================================================================
# Return a level value based on Pokémon in a party
#===============================================================================
def pbBalancedLevel(party)
  return 1 if party.length == 0
  # Calculate the mean of all levels
  sum = 0
  party.each { |p| sum += p.level }
  return 1 if sum == 0
  mLevel = GameData::GrowthRate.max_level
  average = sum.to_f / party.length.to_f
  # Calculate the standard deviation
  varianceTimesN = 0
  party.each do |pkmn|
    deviation = pkmn.level - average
    varianceTimesN += deviation * deviation
  end
  # NOTE: This is the "population" standard deviation calculation, since no
  # sample is being taken.
  stdev = Math.sqrt(varianceTimesN / party.length)
  mean = 0
  weights = []
  # Skew weights according to standard deviation
  party.each do |pkmn|
    weight = pkmn.level.to_f / sum.to_f
    if weight < 0.5
      weight -= (stdev / mLevel.to_f)
      weight = 0.001 if weight <= 0.001
    else
      weight += (stdev / mLevel.to_f)
      weight = 0.999 if weight >= 0.999
    end
    weights.push(weight)
  end
  weightSum = 0
  weights.each { |w| weightSum += w }
  # Calculate the weighted mean, assigning each weight to each level's
  # contribution to the sum
  party.each_with_index { |pkmn, i| mean += pkmn.level * weights[i] }
  mean /= weightSum
  mean = mean.round
  mean = 1 if mean < 1
  # Add 2 to the mean to challenge the player
  mean += 2
  # Adjust level to maximum
  mean = mLevel if mean > mLevel
  return mean
end

#===============================================================================
# Calculates a Pokémon's size (in millimeters)
#===============================================================================
def pbSize(pkmn)
  baseheight = pkmn.height
  hpiv = pkmn.iv[:HP] & 15
  ativ = pkmn.iv[:ATTACK] & 15
  dfiv = pkmn.iv[:DEFENSE] & 15
  saiv = pkmn.iv[:SPECIAL_ATTACK] & 15
  sdiv = pkmn.iv[:SPECIAL_DEFENSE] & 15
  spiv = pkmn.iv[:SPEED] & 15
  m = pkmn.personalID & 0xFF
  n = (pkmn.personalID >> 8) & 0xFF
  s = (((ativ ^ dfiv) * hpiv) ^ m) * 256 + (((saiv ^ sdiv) * spiv) ^ n)
  xyz = []
  if s < 10;       xyz = [ 290,   1,     0]
  elsif s < 110;   xyz = [ 300,   1,    10]
  elsif s < 310;   xyz = [ 400,   2,   110]
  elsif s < 710;   xyz = [ 500,   4,   310]
  elsif s < 2710;  xyz = [ 600,  20,   710]
  elsif s < 7710;  xyz = [ 700,  50,  2710]
  elsif s < 17710; xyz = [ 800, 100,  7710]
  elsif s < 32710; xyz = [ 900, 150, 17710]
  elsif s < 47710; xyz = [1000, 150, 32710]
  elsif s < 57710; xyz = [1100, 100, 47710]
  elsif s < 62710; xyz = [1200,  50, 57710]
  elsif s < 64710; xyz = [1300,  20, 62710]
  elsif s < 65210; xyz = [1400,   5, 64710]
  elsif s < 65410; xyz = [1500,   2, 65210]
  else;            xyz = [1700,   1, 65510]
  end
  return (((s - xyz[2]) / xyz[1] + xyz[0]).floor * baseheight / 10).floor
end

#===============================================================================
# Returns true if the given species can be legitimately obtained as an egg
#===============================================================================
def pbHasEgg?(species)
  species_data = GameData::Species.try_get(species)
  return false if !species_data
  species = species_data.species
  # species may be unbreedable, so check its evolution's compatibilities
  evoSpecies = species_data.get_evolutions(true)
  compatSpecies = (evoSpecies && evoSpecies[0]) ? evoSpecies[0][0] : species
  species_data = GameData::Species.try_get(compatSpecies)
  compat = species_data.egg_groups
  return false if compat.include?(:Undiscovered) || compat.include?(:Ditto)
  baby = GameData::Species.get(species).get_baby_species
  return true if species == baby   # Is a basic species
  baby = GameData::Species.get(species).get_baby_species(true)
  return true if species == baby   # Is an egg species without incense
  return false
end
