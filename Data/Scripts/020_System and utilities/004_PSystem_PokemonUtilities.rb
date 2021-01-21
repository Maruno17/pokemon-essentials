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
  pkmn.pbRecordFirstMoves
  if $Trainer.party_full?
    oldcurbox = $PokemonStorage.currentBox
    storedbox = $PokemonStorage.pbStoreCaught(pkmn)
    curboxname = $PokemonStorage[oldcurbox].name
    boxname = $PokemonStorage[storedbox].name
    creator = nil
    creator = pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
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
  $Trainer.seen[pkmn.species]  = true
  $Trainer.owned[pkmn.species] = true
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
  pbSeenForm(pkmn) if see_form
  return true
end

def pbAddPokemonSilent(pkmn, level = 1, see_form = true)
  return false if !pkmn || pbBoxesFull?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  $Trainer.seen[pkmn.species]  = true
  $Trainer.owned[pkmn.species] = true
  pbSeenForm(pkmn) if see_form
  pkmn.pbRecordFirstMoves
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
  pbSeenForm(pkmn) if see_form
  return true
end

def pbAddToPartySilent(pkmn, level = nil, see_form = true)
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  $Trainer.seen[pkmn.species]  = true
  $Trainer.owned[pkmn.species] = true
  pbSeenForm(pkmn) if see_form
  pkmn.pbRecordFirstMoves
  $Trainer.party[$Trainer.party.length] = pkmn
  return true
end

def pbAddForeignPokemon(pkmn, level = 1, owner_name = nil, nickname = nil, owner_gender = 0, see_form = true)
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  # Set original trainer to a foreign one
  pkmn.owner = Pokemon::Owner.new_foreign(owner_name || "", owner_gender)
  # Set nickname
  pkmn.name = nickname[0, Pokemon::MAX_NAME_SIZE]
  # Recalculate stats
  pkmn.calcStats
  if owner_name
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon from {2}.\1", $Trainer.name, owner_name))
  else
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon.\1", $Trainer.name))
  end
  pbStorePokemon(pkmn)
  $Trainer.seen[pkmn.species]  = true
  $Trainer.owned[pkmn.species] = true
  pbSeenForm(pkmn) if see_form
  return true
end

def pbGenerateEgg(pkmn, text = "")
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, EGG_LEVEL) if !pkmn.is_a?(Pokemon)
  # Set egg's details
  pkmn.name       = _INTL("Egg")
  pkmn.eggsteps   = pkmn.species_data.hatch_steps
  pkmn.obtainText = text
  pkmn.calcStats
  # Add egg to party
  $Trainer.party[$Trainer.party.length] = pkmn
  return true
end
alias pbAddEgg pbGenerateEgg
alias pbGenEgg pbGenerateEgg

#===============================================================================
# Removing Pokémon from the party (fails if trying to remove last able Pokémon)
#===============================================================================
def pbRemovePokemonAt(index)
  return false if index < 0 || index >= $Trainer.party.length
  have_able = false
  $Trainer.party.each_with_index do |pkmn, i|
    have_able = true if i != index && !pkmn.egg? && pkmn.hp > 0
    break if have_able
  end
  return false if !have_able
  $Trainer.party.delete_at(index)
  return true
end

#===============================================================================
# Recording Pokémon forms as seen
#===============================================================================
def pbSeenForm(species, gender = 0, form = 0)
  $Trainer.formseen     = {} if !$Trainer.formseen
  $Trainer.formlastseen = {} if !$Trainer.formlastseen
  if species.is_a?(Pokemon)
    species_data = species.species_data
    gender = species.gender
  else
    species_data = GameData::Species.get_species_form(species, form)
  end
  return if !species_data
  species = species_data.species
  gender = 0 if gender >= 2
  form = species_data.form
  if form != species_data.pokedex_form
    species_data = GameData::Species.get_species_form(species, species_data.pokedex_form)
    form = species_data.form
  end
  form = 0 if species_data.form_name.nil? || species_data.form_name.empty?
  $Trainer.formseen[species] = [[], []] if !$Trainer.formseen[species]
  $Trainer.formseen[species][gender][form] = true
  $Trainer.formlastseen[species] = [] if !$Trainer.formlastseen[species]
  $Trainer.formlastseen[species] = [gender, form] if $Trainer.formlastseen[species] == []
end

def pbUpdateLastSeenForm(pkmn)
  $Trainer.formlastseen = {} if !$Trainer.formlastseen
  species_data = pkmn.species_data
  form = species_data.pokedex_form
  form = 0 if species_data.form_name.nil? || species_data.form_name.empty?
  $Trainer.formlastseen[pkmn.species] = [pkmn.gender, form]
end

#===============================================================================
# Analyse Pokémon in the party
#===============================================================================
# Returns the first unfainted, non-egg Pokémon in the player's party.
def pbFirstAblePokemon(variableNumber)
  $Trainer.party.each_with_index do |pkmn, i|
    next if pkmn.egg? || pkmn.hp == 0
    pbSet(variableNumber, i)
    return pkmn
  end
  pbSet(variableNumber, -1)
  return nil
end

# Checks whether the player would still have an unfainted Pokémon if the
# Pokémon given by _index_ were removed from the party.
def pbCheckAble(index)
  $Trainer.party.each_with_index do |pkmn, i|
    return true if i != index && !pkmn.egg? && pkmn.hp > 0
  end
  return false
end

# Returns true if there are no usable Pokémon in the player's party.
def pbAllFainted
  return $Trainer.ablePokemonCount == 0
end

# Returns true if there is a Pokémon of the given species in the player's party.
# You may also specify a particular form it should be.
def pbHasSpecies?(species, form = -1)
  $Trainer.pokemonParty.each do |pkmn|
    return true if pkmn.isSpecies?(species) && (form < 0 || pkmn.form == form)
  end
  return false
end

# Returns true if there is a fatefully met Pokémon of the given species in the
# player's party.
def pbHasFatefulSpecies?(species)
  $Trainer.pokemonParty.each do |pkmn|
    return true if pkmn.isSpecies?(species) && pkmn.obtain_method == 4
  end
  return false
end

# Returns true if there is a Pokémon with the given type in the player's party.
def pbHasType?(type)
  type = GameData::Type.get(type).id
  $Trainer.pokemonParty.each { |pkmn| return true if pkmn.hasType?(type) }
  return false
end

# Checks whether any Pokémon in the party knows the given move, and returns
# the first Pokémon it finds with that move, or nil if no Pokémon has that move.
def pbCheckMove(move)
  $Trainer.pokemonParty.each { |pkmn| return pkmn if pkmn.hasMove?(move) }
  return nil
end

#===============================================================================
# Fully heal all Pokémon in the party
#===============================================================================
def pbHealAll
  $Trainer.party.each { |pkmn| pkmn.heal }
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
  mLevel = PBExperience.maxLevel
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
  hpiv = pkmn.iv[0] & 15
  ativ = pkmn.iv[1] & 15
  dfiv = pkmn.iv[2] & 15
  spiv = pkmn.iv[3] & 15
  saiv = pkmn.iv[4] & 15
  sdiv = pkmn.iv[5] & 15
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
  evoSpecies = EvolutionHelper.evolutions(species, true)
  compatSpecies = (evoSpecies && evoSpecies[0]) ? evoSpecies[0][2] : species
  species_data = GameData::Species.try_get(compatSpecies)
  compat = species_data.egg_groups
  return false if compat.include?(PBEggGroups::Undiscovered)
  return false if compat.include?(PBEggGroups::Ditto)
  baby = EvolutionHelper.baby_species(species)
  return true if species == baby   # Is a basic species
  baby = EvolutionHelper.baby_species(species, true)
  return true if species == baby   # Is an egg species without incense
  return false
end
