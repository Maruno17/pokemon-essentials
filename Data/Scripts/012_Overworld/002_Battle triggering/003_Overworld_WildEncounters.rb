#===============================================================================
#
#===============================================================================
class PokemonEncounters
  attr_reader :step_count

  def initialize
    @step_chances       = {}
    @encounter_tables   = {}
    @chance_accumulator = 0
  end

  def setup(map_ID)
    @step_count       = 0
    @step_chances     = {}
    @encounter_tables = {}
    encounter_data = GameData::Encounter.get(map_ID, $PokemonGlobal.encounter_version)
    if encounter_data
      encounter_data.step_chances.each { |type, value| @step_chances[type] = value }
      @encounter_tables = Marshal.load(Marshal.dump(encounter_data.types))
    end
  end

  def reset_step_count
    @step_count = 0
    @chance_accumulator = 0
  end

  #-----------------------------------------------------------------------------

  # Returns whether encounters for the given encounter type have been defined
  # for the current map.
  def has_encounter_type?(enc_type)
    return false if !enc_type
    return @encounter_tables[enc_type] && @encounter_tables[enc_type].length > 0
  end

  # Returns whether encounters for the given encounter type have been defined
  # for the given map. Only called by Bug-Catching Contest to see if it can use
  # the map's BugContest encounter type to generate caught Pokémon for the other
  # contestants.
  def map_has_encounter_type?(map_ID, enc_type)
    return false if !enc_type
    encounter_data = GameData::Encounter.get(map_ID, $PokemonGlobal.encounter_version)
    return false if !encounter_data
    return encounter_data.types[enc_type] && encounter_data.types[enc_type].length > 0
  end

  # Returns whether land-like encounters have been defined for the current map.
  # Applies only to encounters triggered by moving around.
  def has_land_encounters?
    GameData::EncounterType.each do |enc_type|
      next if ![:land, :contest].include?(enc_type.type)
      return true if has_encounter_type?(enc_type.id)
    end
    return false
  end

  # Returns whether land-like encounters have been defined for the current map
  # (ignoring the Bug-Catching Contest one).
  # Applies only to encounters triggered by moving around.
  def has_normal_land_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :land && has_encounter_type?(enc_type.id)
    end
    return false
  end

  # Returns whether cave-like encounters have been defined for the current map.
  # Applies only to encounters triggered by moving around.
  def has_cave_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :cave && has_encounter_type?(enc_type.id)
    end
    return false
  end

  # Returns whether water-like encounters have been defined for the current map.
  # Applies only to encounters triggered by moving around (i.e. not fishing).
  def has_water_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :water && has_encounter_type?(enc_type.id)
    end
    return false
  end

  #-----------------------------------------------------------------------------

  # Returns whether the player's current location allows wild encounters to
  # trigger upon taking a step.
  def encounter_possible_here?
    return true if $PokemonGlobal.surfing
    terrain_tag = $game_map.terrain_tag($game_player.x, $game_player.y)
    return false if terrain_tag.ice
    return true if has_cave_encounters?   # i.e. this map is a cave
    return true if has_land_encounters? && terrain_tag.land_wild_encounters
    return false
  end

  # Returns whether a wild encounter should happen, based on its encounter
  # chance. Called when taking a step and by Rock Smash.
  def encounter_triggered?(enc_type, repel_active = false, triggered_by_step = true)
    if !enc_type || !GameData::EncounterType.exists?(enc_type)
      raise ArgumentError.new(_INTL("Encounter type {1} does not exist", enc_type))
    end
    return false if $game_system.encounter_disabled
    return false if !$player
    return false if $DEBUG && Input.press?(Input::CTRL)
    # Check if enc_type has a defined step chance/encounter table
    return false if !@step_chances[enc_type] || @step_chances[enc_type] == 0
    return false if !has_encounter_type?(enc_type)
    # Poké Radar encounters always happen, ignoring the minimum step period and
    # trigger probabilities
    return true if pbPokeRadarOnShakingGrass
    # Get base encounter chance and minimum steps grace period
    encounter_chance = @step_chances[enc_type].to_f
    min_steps_needed = (8 - (encounter_chance / 10)).clamp(0, 8).to_f
    # Apply modifiers to the encounter chance and the minimum steps amount
    if triggered_by_step
      encounter_chance += @chance_accumulator / 200
      encounter_chance *= 0.8 if $PokemonGlobal.bicycle
    end
    if $PokemonMap.lower_encounter_rate
      encounter_chance /= 2
      min_steps_needed *= 2
    elsif $PokemonMap.higher_encounter_rate
      encounter_chance *= 1.5
      min_steps_needed /= 2
    end
    first_pkmn = $player.first_pokemon
    if first_pkmn
      case first_pkmn.item_id
      when :CLEANSETAG
        encounter_chance *= 2.0 / 3
        min_steps_needed *= 4 / 3.0
      when :PUREINCENSE
        encounter_chance *= 2.0 / 3
        min_steps_needed *= 4 / 3.0
      else   # Ignore ability effects if an item effect applies
        case first_pkmn.ability_id
        when :STENCH, :WHITESMOKE, :QUICKFEET
          encounter_chance /= 2
          min_steps_needed *= 2
        when :INFILTRATOR
          if Settings::MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS
            encounter_chance /= 2
            min_steps_needed *= 2
          end
        when :SNOWCLOAK
          if GameData::Weather.get($game_screen.weather_type).category == :Hail
            encounter_chance /= 2
            min_steps_needed *= 2
          end
        when :SANDVEIL
          if GameData::Weather.get($game_screen.weather_type).category == :Sandstorm
            encounter_chance /= 2
            min_steps_needed *= 2
          end
        when :SWARM
          encounter_chance *= 1.5
          min_steps_needed /= 2
        when :ILLUMINATE, :ARENATRAP, :NOGUARD
          encounter_chance *= 2
          min_steps_needed /= 2
        end
      end
    end
    # Wild encounters are much less likely to happen for the first few steps
    # after a previous wild encounter
    if triggered_by_step && @step_count < min_steps_needed
      @step_count += 1
      return false if rand(100) >= encounter_chance * 5 / (@step_chances[enc_type] + (@chance_accumulator / 200))
    end
    # Decide whether the wild encounter should actually happen
    return true if rand(100) < encounter_chance
    # If encounter didn't happen, make the next step more likely to produce one
    if triggered_by_step
      @chance_accumulator += @step_chances[enc_type]
      @chance_accumulator = 0 if repel_active
    end
    return false
  end

  # Returns whether an encounter with the given Pokémon should be allowed after
  # taking into account Repels and ability effects.
  def allow_encounter?(enc_data, repel_active = false)
    return false if !enc_data
    return true if pbPokeRadarOnShakingGrass
    # Repel
    if repel_active
      first_pkmn = (Settings::REPEL_COUNTS_FAINTED_POKEMON) ? $player.first_pokemon : $player.first_able_pokemon
      if first_pkmn && enc_data[1] < first_pkmn.level
        @chance_accumulator = 0
        return false
      end
    end
    # Some abilities make wild encounters less likely if the wild Pokémon is
    # sufficiently weaker than the Pokémon with the ability
    first_pkmn = $player.first_pokemon
    if first_pkmn
      case first_pkmn.ability_id
      when :INTIMIDATE, :KEENEYE
        return false if enc_data[1] <= first_pkmn.level - 5 && rand(100) < 50
      end
    end
    return true
  end

  # Returns whether a wild encounter should be turned into a double wild
  # encounter.
  def have_double_wild_battle?
    return false if $game_temp.force_single_battle
    return false if pbInSafari?
    return true if $PokemonGlobal.partner
    return false if $player.able_pokemon_count <= 1
    return true if $game_player.pbTerrainTag.double_wild_encounters && rand(100) < 30
    return false
  end

  # Checks the defined encounters for the current map and returns the encounter
  # type that the given time should produce. Only returns an encounter type if
  # it has been defined for the current map.
  def find_valid_encounter_type_for_time(base_type, time)
    ret = nil
    if PBDayNight.isDay?(time)
      try_type = nil
      if PBDayNight.isMorning?(time)
        try_type = (base_type.to_s + "Morning").to_sym
      elsif PBDayNight.isAfternoon?(time)
        try_type = (base_type.to_s + "Afternoon").to_sym
      elsif PBDayNight.isEvening?(time)
        try_type = (base_type.to_s + "Evening").to_sym
      end
      ret = try_type if try_type && has_encounter_type?(try_type)
      if !ret
        try_type = (base_type.to_s + "Day").to_sym
        ret = try_type if has_encounter_type?(try_type)
      end
    else
      try_type = (base_type.to_s + "Night").to_sym
      ret = try_type if has_encounter_type?(try_type)
    end
    return ret if ret
    return (has_encounter_type?(base_type)) ? base_type : nil
  end

  # Returns the encounter method that the current encounter should be generated
  # from, depending on the player's current location.
  def encounter_type
    time = pbGetTimeNow
    ret = nil
    if $PokemonGlobal.surfing
      ret = find_valid_encounter_type_for_time(:Water, time)
    else   # Land/Cave (can have both in the same map)
      if has_land_encounters? && $game_map.terrain_tag($game_player.x, $game_player.y).land_wild_encounters
        ret = :BugContest if pbInBugContest? && has_encounter_type?(:BugContest)
        ret = find_valid_encounter_type_for_time(:Land, time) if !ret
      end
      if !ret && has_cave_encounters?
        ret = find_valid_encounter_type_for_time(:Cave, time)
      end
    end
    return ret
  end

  #-----------------------------------------------------------------------------

  # For the current map, randomly chooses a species and level from the encounter
  # list for the given encounter type. Returns nil if there are none defined.
  # A higher chance_rolls makes this method prefer rarer encounter slots.
  def choose_wild_pokemon(enc_type, chance_rolls = 1)
    if !enc_type || !GameData::EncounterType.exists?(enc_type)
      raise ArgumentError.new(_INTL("Encounter type {1} does not exist", enc_type))
    end
    enc_list = @encounter_tables[enc_type]
    return nil if !enc_list || enc_list.length == 0
    # Static/Magnet Pull prefer wild encounters of certain types, if possible.
    # If they activate, they remove all Pokémon from the encounter table that do
    # not have the type they favor. If none have that type, nothing is changed.
    first_pkmn = $player.first_pokemon
    if first_pkmn
      favored_type = nil
      case first_pkmn.ability_id
      when :FLASHFIRE
        favored_type = :FIRE if Settings::MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS &&
                                GameData::Type.exists?(:FIRE) && rand(100) < 50
      when :HARVEST
        favored_type = :GRASS if Settings::MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS &&
                                 GameData::Type.exists?(:GRASS) && rand(100) < 50
      when :LIGHTNINGROD
        favored_type = :ELECTRIC if Settings::MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS &&
                                    GameData::Type.exists?(:ELECTRIC) && rand(100) < 50
      when :MAGNETPULL
        favored_type = :STEEL if GameData::Type.exists?(:STEEL) && rand(100) < 50
      when :STATIC
        favored_type = :ELECTRIC if GameData::Type.exists?(:ELECTRIC) && rand(100) < 50
      when :STORMDRAIN
        favored_type = :WATER if Settings::MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS &&
                                 GameData::Type.exists?(:WATER) && rand(100) < 50
      end
      if favored_type
        new_enc_list = []
        enc_list.each do |enc|
          species_data = GameData::Species.get(enc[1])
          new_enc_list.push(enc) if species_data.types.include?(favored_type)
        end
        enc_list = new_enc_list if new_enc_list.length > 0
      end
    end
    enc_list.sort! { |a, b| b[0] <=> a[0] }   # Highest probability first
    # Calculate the total probability value
    chance_total = 0
    enc_list.each { |a| chance_total += a[0] }
    # Choose a random entry in the encounter table based on entry probabilities
    rnd = 0
    chance_rolls.times do
      r = rand(chance_total)
      rnd = r if r > rnd   # Prefer rarer entries if rolling repeatedly
    end
    encounter = nil
    enc_list.each do |enc|
      rnd -= enc[0]
      next if rnd >= 0
      encounter = enc
      break
    end
    # Get the chosen species and level
    level = rand(encounter[2]..encounter[3])
    # Some abilities alter the level of the wild Pokémon
    if first_pkmn
      case first_pkmn.ability_id
      when :HUSTLE, :PRESSURE, :VITALSPIRIT
        level = encounter[3] if rand(100) < 50   # Highest possible level
      end
    end
    # Black Flute and White Flute alter the level of the wild Pokémon
    if $PokemonMap.lower_level_wild_pokemon
      level = [level - rand(1..4), 1].max
    elsif $PokemonMap.higher_level_wild_pokemon
      level = [level + rand(1..4), GameData::GrowthRate.max_level].min
    end
    # Return [species, level]
    return [encounter[1], level]
  end

  # For the given map, randomly chooses a species and level from the encounter
  # list for the given encounter type. Returns nil if there are none defined.
  # Used by the Bug-Catching Contest to choose what the other participants
  # caught.
  def choose_wild_pokemon_for_map(map_ID, enc_type)
    if !enc_type || !GameData::EncounterType.exists?(enc_type)
      raise ArgumentError.new(_INTL("Encounter type {1} does not exist", enc_type))
    end
    # Get the encounter table
    encounter_data = GameData::Encounter.get(map_ID, $PokemonGlobal.encounter_version)
    return nil if !encounter_data
    enc_list = encounter_data.types[enc_type]
    return nil if !enc_list || enc_list.length == 0
    # Calculate the total probability value
    chance_total = 0
    enc_list.each { |a| chance_total += a[0] }
    # Choose a random entry in the encounter table based on entry probabilities
    rnd = rand(chance_total)
    encounter = nil
    enc_list.each do |enc|
      rnd -= enc[0]
      next if rnd >= 0
      encounter = enc
      break
    end
    # Return [species, level]
    level = rand(encounter[2]..encounter[3])
    return [encounter[1], level]
  end
end

#===============================================================================
#
#===============================================================================
# Creates and returns a Pokémon based on the given species and level.
# Applies wild Pokémon modifiers (wild held item, shiny chance modifiers,
# Pokérus, gender/nature forcing because of player's lead Pokémon).
def pbGenerateWildPokemon(species, level, isRoamer = false)
  genwildpoke = Pokemon.new(species, level)
  # Give the wild Pokémon a held item
  items = genwildpoke.wildHoldItems
  first_pkmn = $player.first_pokemon
  chances = [50, 5, 1]
  if first_pkmn
    case first_pkmn.ability_id
    when :COMPOUNDEYES
      chances = [60, 20, 5]
    when :SUPERLUCK
      chances = [60, 20, 5] if Settings::MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS
    end
  end
  itemrnd = rand(100)
  if (items[0] == items[1] && items[1] == items[2]) || itemrnd < chances[0]
    genwildpoke.item = items[0].sample
  elsif itemrnd < (chances[0] + chances[1])
    genwildpoke.item = items[1].sample
  elsif itemrnd < (chances[0] + chances[1] + chances[2])
    genwildpoke.item = items[2].sample
  end
  # Improve chances of shiny Pokémon with Shiny Charm and battling more of the
  # same species
  shiny_retries = 0
  shiny_retries += 2 if $bag.has?(:SHINYCHARM)
  if Settings::HIGHER_SHINY_CHANCES_WITH_NUMBER_BATTLED
    values = [0, 0]
    case $player.pokedex.battled_count(species)
    when 0...50    then values = [0, 0]
    when 50...100  then values = [1, 15]
    when 100...200 then values = [2, 20]
    when 200...300 then values = [3, 25]
    when 300...500 then values = [4, 30]
    else                values = [5, 30]
    end
    shiny_retries += values[0] if values[1] > 0 && rand(1000) < values[1]
  end
  if shiny_retries > 0
    shiny_retries.times do
      break if genwildpoke.shiny?
      genwildpoke.shiny = nil   # Make it recalculate shininess
      genwildpoke.personalID = rand(2**16) | (rand(2**16) << 16)
    end
  end
  # Give Pokérus
  genwildpoke.givePokerus if rand(65_536) < Settings::POKERUS_CHANCE
  # Change wild Pokémon's gender/nature depending on the lead party Pokémon's
  # ability
  if first_pkmn
    if first_pkmn.hasAbility?(:CUTECHARM) && !genwildpoke.singleGendered?
      if first_pkmn.male?
        (rand(3) < 2) ? genwildpoke.makeFemale : genwildpoke.makeMale
      elsif first_pkmn.female?
        (rand(3) < 2) ? genwildpoke.makeMale : genwildpoke.makeFemale
      end
    elsif first_pkmn.hasAbility?(:SYNCHRONIZE)
      if !isRoamer && (Settings::MORE_ABILITIES_AFFECT_WILD_ENCOUNTERS || (rand(100) < 50))
        genwildpoke.nature = first_pkmn.nature
      end
    end
  end
  # Trigger events that may alter the generated Pokémon further
  EventHandlers.trigger(:on_wild_pokemon_created, genwildpoke)
  return genwildpoke
end

# Used by fishing rods and Headbutt/Rock Smash/Sweet Scent to generate a wild
# Pokémon (or two if it's Sweet Scent) for a triggered wild encounter.
def pbEncounter(enc_type, only_single = true)
  $game_temp.encounter_type = enc_type
  encounter1 = $PokemonEncounters.choose_wild_pokemon(enc_type)
  EventHandlers.trigger(:on_wild_species_chosen, encounter1)
  return false if !encounter1
  if !only_single && $PokemonEncounters.have_double_wild_battle?
    encounter2 = $PokemonEncounters.choose_wild_pokemon(enc_type)
    EventHandlers.trigger(:on_wild_species_chosen, encounter2)
    return false if !encounter2
    WildBattle.start(encounter1, encounter2, can_override: true)
  else
    WildBattle.start(encounter1, can_override: true)
  end
  $game_temp.encounter_type = nil
  $game_temp.force_single_battle = false
  return true
end
