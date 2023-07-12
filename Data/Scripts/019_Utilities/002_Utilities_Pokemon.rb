#===============================================================================
# Nicknaming and storing Pokémon
#===============================================================================
def pbBoxesFull?
  return ($player.party_full? && $PokemonStorage.full?)
end

def pbNickname(pkmn)
  return if $PokemonSystem.givenicknames != 0
  species_name = pkmn.speciesName
  if pbConfirmMessage(_INTL("Would you like to give a nickname to {1}?", species_name))
    pkmn.name = pbEnterPokemonName(_INTL("{1}'s nickname?", species_name),
                                   0, Pokemon::MAX_NAME_SIZE, "", pkmn)
  end
end

def pbStorePokemon(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!") + "\1")
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pkmn.record_first_moves
  if $player.party_full?
    stored_box = $PokemonStorage.pbStoreCaught(pkmn)
    box_name   = $PokemonStorage[stored_box].name
    pbMessage(_INTL("{1} has been sent to Box \"{2}\"!", pkmn.name, box_name))
  else
    $player.party[$player.party.length] = pkmn
  end
end

def pbNicknameAndStore(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!") + "\1")
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  pbNickname(pkmn)
  pbStorePokemon(pkmn)
end

#===============================================================================
# Giving Pokémon to the player (will send to storage if party is full)
#===============================================================================
def pbAddPokemon(pkmn, level = 1, see_form = true)
  return false if !pkmn
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!") + "\1")
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  species_name = pkmn.speciesName
  pbMessage(_INTL("{1} obtained {2}!", $player.name, species_name) + "\\me[Pkmn get]\\wtnp[80]")
  was_owned = $player.owned?(pkmn.species)
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  $player.pokedex.register(pkmn) if see_form
  # Show Pokédex entry for new species if it hasn't been owned before
  if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && see_form && !was_owned &&
     $player.has_pokedex && $player.pokedex.species_in_unlocked_dex?(pkmn.species)
    pbMessage(_INTL("{1}'s data was added to the Pokédex.", species_name))
    $player.pokedex.register_last_seen(pkmn)
    pbFadeOutIn do
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbDexEntry(pkmn.species)
    end
  end
  # Nickname and add the Pokémon
  pbNicknameAndStore(pkmn)
  return true
end

def pbAddPokemonSilent(pkmn, level = 1, see_form = true)
  return false if !pkmn || pbBoxesFull?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  $player.pokedex.register(pkmn) if see_form
  pkmn.record_first_moves
  if $player.party_full?
    $PokemonStorage.pbStoreCaught(pkmn)
  else
    $player.party[$player.party.length] = pkmn
  end
  return true
end

#===============================================================================
# Giving Pokémon/eggs to the player (can only add to party)
#===============================================================================
def pbAddToParty(pkmn, level = 1, see_form = true)
  return false if !pkmn || $player.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  species_name = pkmn.speciesName
  pbMessage(_INTL("{1} obtained {2}!", $player.name, species_name) + "\\me[Pkmn get]\\wtnp[80]")
  was_owned = $player.owned?(pkmn.species)
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  $player.pokedex.register(pkmn) if see_form
  # Show Pokédex entry for new species if it hasn't been owned before
  if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && see_form && !was_owned &&
     $player.has_pokedex && $player.pokedex.species_in_unlocked_dex?(pkmn.species)
    pbMessage(_INTL("{1}'s data was added to the Pokédex.", species_name))
    $player.pokedex.register_last_seen(pkmn)
    pbFadeOutIn do
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbDexEntry(pkmn.species)
    end
  end
  # Nickname and add the Pokémon
  pbNicknameAndStore(pkmn)
  return true
end

def pbAddToPartySilent(pkmn, level = nil, see_form = true)
  return false if !pkmn || $player.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  $player.pokedex.register(pkmn) if see_form
  $player.pokedex.set_owned(pkmn.species)
  pkmn.record_first_moves
  $player.party[$player.party.length] = pkmn
  return true
end

def pbAddForeignPokemon(pkmn, level = 1, owner_name = nil, nickname = nil, owner_gender = 0, see_form = true)
  return false if !pkmn || $player.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  pkmn.owner = Pokemon::Owner.new_foreign(owner_name || "", owner_gender)
  pkmn.name = nickname[0, Pokemon::MAX_NAME_SIZE] if !nil_or_empty?(nickname)
  pkmn.calc_stats
  if owner_name
    pbMessage(_INTL("{1} received a Pokémon from {2}.", $player.name, owner_name) + "\\me[Pkmn get]\\wtnp[80]")
  else
    pbMessage(_INTL("{1} received a Pokémon.", $player.name) + "\\me[Pkmn get]\\wtnp[80]")
  end
  was_owned = $player.owned?(pkmn.species)
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  $player.pokedex.register(pkmn) if see_form
  # Show Pokédex entry for new species if it hasn't been owned before
  if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && see_form && !was_owned &&
     $player.has_pokedex && $player.pokedex.species_in_unlocked_dex?(pkmn.species)
    pbMessage(_INTL("The Pokémon's data was added to the Pokédex."))
    $player.pokedex.register_last_seen(pkmn)
    pbFadeOutIn do
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbDexEntry(pkmn.species)
    end
  end
  # Add the Pokémon
  pbStorePokemon(pkmn)
  return true
end

def pbGenerateEgg(pkmn, text = "")
  return false if !pkmn || $player.party_full?
  pkmn = Pokemon.new(pkmn, Settings::EGG_LEVEL) if !pkmn.is_a?(Pokemon)
  # Set egg's details
  pkmn.name           = _INTL("Egg")
  pkmn.steps_to_hatch = pkmn.species_data.hatch_steps
  pkmn.obtain_text    = text
  pkmn.calc_stats
  # Add egg to party
  $player.party[$player.party.length] = pkmn
  return true
end
alias pbAddEgg pbGenerateEgg
alias pbGenEgg pbGenerateEgg

#===============================================================================
# Analyse Pokémon in the party
#===============================================================================
# Returns the first unfainted, non-egg Pokémon in the player's party.
def pbFirstAblePokemon(variable_ID)
  $player.party.each_with_index do |pkmn, i|
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
  average = sum.to_f / party.length
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
    weight = pkmn.level.to_f / sum
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
  s = ((((ativ ^ dfiv) * hpiv) ^ m) * 256) + (((saiv ^ sdiv) * spiv) ^ n)
  xyz = [1700, 1, 65_510]
  case s
  when 0...10          then xyz = [ 290,   1,      0]
  when 10...110        then xyz = [ 300,   1,     10]
  when 110...310       then xyz = [ 400,   2,    110]
  when 310...710       then xyz = [ 500,   4,    310]
  when 710...2710      then xyz = [ 600,  20,    710]
  when 2710...7710     then xyz = [ 700,  50,   2710]
  when 7710...17_710   then xyz = [ 800, 100,   7710]
  when 17_710...32_710 then xyz = [ 900, 150, 17_710]
  when 32_710...47_710 then xyz = [1000, 150, 32_710]
  when 47_710...57_710 then xyz = [1100, 100, 47_710]
  when 57_710...62_710 then xyz = [1200,  50, 57_710]
  when 62_710...64_710 then xyz = [1300,  20, 62_710]
  when 64_710...65_210 then xyz = [1400,   5, 64_710]
  when 65_210...65_410 then xyz = [1500,   2, 65_210]
  end
  return ((((s - xyz[2]) / xyz[1]) + xyz[0]).floor * baseheight / 10).floor
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
