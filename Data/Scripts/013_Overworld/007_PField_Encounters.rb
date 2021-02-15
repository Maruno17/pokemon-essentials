#===============================================================================
#
#===============================================================================
class PokemonEncounters
  attr_reader :step_count

  def initialize
    @step_chances     = nil
    @encounter_tables = []
  end

  def setup(map_ID)
    @step_count       = 0
    @step_chances     = nil
    @encounter_tables = []
    encounter_data = GameData::Encounter.get(map_ID, $PokemonGlobal.encounter_version)
    if encounter_data
      @step_chances     = encounter_data.step_chances.clone
      @encounter_tables = Marshal.load(Marshal.dump(encounter_data.types))
    end
  end

  def reset_step_count
    @step_count = 0
  end

  #=============================================================================

  # Returns whether encounters for the given encounter type have been defined
  # for the current map.
  def has_encounter_type?(enc_type)
    return false if enc_type < 0
    return @encounter_tables[enc_type] && @encounter_tables[enc_type].length > 0
  end

  # Returns whether encounters for the given encounter type have been defined
  # for the given map. Only called by Bug Catching Contest to see if it can use
  # the map's BugContest encounter type to generate caught Pokémon for the other
  # contestants.
  def map_has_encounter_type?(map_ID, enc_type)
    return false if enc_type < 0
    encounter_data = GameData::Encounter.get(map_ID, $PokemonGlobal.encounter_version)
    return false if !encounter_data
    return encounter_data.types[enc_type] && encounter_data.types[enc_type].length > 0
  end

  # Returns whether land-like encounters have been defined for the current map.
  # Applies only to encounters triggered by moving around.
  def has_land_encounters?
    return has_normal_land_encounters? ||
           has_encounter_type?(EncounterTypes::BugContest)
  end

  # Returns whether land-like encounters have been defined for the current map
  # (ignoring the Bug Catching Contest one).
  # Applies only to encounters triggered by moving around.
  def has_normal_land_encounters?
    return has_encounter_type?(EncounterTypes::Land) ||
           has_encounter_type?(EncounterTypes::LandDay) ||
           has_encounter_type?(EncounterTypes::LandNight) ||
           has_encounter_type?(EncounterTypes::LandMorning) ||
           has_encounter_type?(EncounterTypes::LandAfternoon) ||
           has_encounter_type?(EncounterTypes::LandEvening)
  end

  # Returns whether cave-like encounters have been defined for the current map.
  # Applies only to encounters triggered by moving around.
  def has_cave_encounters?
    return has_encounter_type?(EncounterTypes::Cave) ||
           has_encounter_type?(EncounterTypes::CaveDay) ||
           has_encounter_type?(EncounterTypes::CaveNight) ||
           has_encounter_type?(EncounterTypes::CaveMorning) ||
           has_encounter_type?(EncounterTypes::CaveAfternoon) ||
           has_encounter_type?(EncounterTypes::CaveEvening)
  end

  # Returns whether water-like encounters have been defined for the current map.
  # Applies only to encounters triggered by moving around (i.e. not fishing).
  def has_water_encounters?
    return has_encounter_type?(EncounterTypes::Water) ||
           has_encounter_type?(EncounterTypes::WaterDay) ||
           has_encounter_type?(EncounterTypes::WaterNight) ||
           has_encounter_type?(EncounterTypes::WaterMorning) ||
           has_encounter_type?(EncounterTypes::WaterAfternoon) ||
           has_encounter_type?(EncounterTypes::WaterEvening)
  end

  #=============================================================================

  # Returns whether the player's current location allows wild encounters to
  # trigger upon taking a step.
  def encounter_possible_here?
    return true if $PokemonGlobal.surfing
    terrain_tag = $game_map.terrain_tag($game_player.x, $game_player.y)
    return false if PBTerrain.isIce?(terrain_tag)
    return true if has_cave_encounters?   # i.e. this map is a cave
    return true if PBTerrain.isGrass?(terrain_tag) && has_land_encounters?
    return false
  end

  # Returns whether a wild encounter should happen, based on the probability of
  # one triggering upon taking a step.
  def step_triggers_encounter?(enc_type)
    if enc_type < 0 || enc_type > EncounterTypes::Probabilities.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return false if $game_system.encounter_disabled
    return false if !$Trainer
    return false if $DEBUG && Input.press?(Input::CTRL)
    # Wild encounters cannot happen for the first 3 steps after a previous wild
    # encounter
    @step_count += 1
    return false if @step_count <= 3
    # Check if enc_type has a defined step chance/encounter table
    return false if !@step_chances[enc_type] || @step_chances[enc_type] == 0
    return false if !has_encounter_type?(enc_type)
    # Determine the encounter step chance (probability of a wild encounter
    # happening). The actual probability is the written encounter step chance,
    # with modifiers applied, divided by 180.
    encount = @step_chances[enc_type].to_f
    encount *= 0.8 if $PokemonGlobal.bicycle
    if !Settings::FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS
      encount /= 2 if $PokemonMap.blackFluteUsed
      encount *= 1.5 if $PokemonMap.whiteFluteUsed
    end
    first_pkmn = $Trainer.first_pokemon
    if first_pkmn
      case first_pkmn.item_id
      when :CLEANSETAG
        encount *= 2.0 / 3
      when :PUREINCENSE
        encount *= 2.0 / 3
      else   # Ignore ability effects if an item effect applies
        case first_pkmn.ability_id
        when :STENCH, :WHITESMOKE, :QUICKFEET
          encount /= 2
        when :SNOWCLOAK
          encount /= 2 if $game_screen.weather_type == PBFieldWeather::Snow ||
                          $game_screen.weather_type == PBFieldWeather::Blizzard
        when :SANDVEIL
          encount /= 2 if $game_screen.weather_type == PBFieldWeather::Sandstorm
        when :SWARM
          encount *= 1.5
        when :ILLUMINATE, :ARENATRAP, :NOGUARD
          encount *= 2
        end
      end
    end
    # Decide whether the wild encounter should actually happen
    return rand(180) < encount
  end

  # Returns whether an encounter with the given Pokémon should be allowed after
  # taking into account Repels and ability effects.
  def allow_encounter?(enc_data, repel_active = false)
    return false if !enc_data
    # Repel
    if repel_active && !pbPokeRadarOnShakingGrass
      first_pkmn = (Settings::REPEL_COUNTS_FAINTED_POKEMON) ? $Trainer.first_pokemon : $Trainer.first_able_pokemon
      return false if first_pkmn && enc_data[1] < first_pkmn.level
    end
    # Some abilities make wild encounters less likely if the wild Pokémon is
    # sufficiently weaker than the Pokémon with the ability
    first_pkmn = $Trainer.first_pokemon
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
    return false if $PokemonTemp.forceSingleBattle
    return false if pbInSafari?
    return true if $PokemonGlobal.partner
    return false if $Trainer.able_pokemon_count <= 1
    return true if PBTerrain.isDoubleWildBattle?(pbGetTerrainTag) && rand(100) < 30
    return false
  end

  # Returns the encounter method that the current encounter should be generated
  # from, depending on the player's current location.
  def encounter_type
    time = pbGetTimeNow
    ret = -1
    if $PokemonGlobal.surfing
      ret = EncounterTypes::Water if has_encounter_type?(EncounterTypes::Water)
      if PBDayNight.isDay?(time)
        ret = EncounterTypes::WaterDay if has_encounter_type?(EncounterTypes::WaterDay)
        if PBDayNight.isMorning?(time)
          ret = EncounterTypes::WaterMorning if has_encounter_type?(EncounterTypes::WaterMorning)
        elsif PBDayNight.isAfternoon?(time)
          ret = EncounterTypes::WaterAfternoon if has_encounter_type?(EncounterTypes::WaterAfternoon)
        elsif PBDayNight.isEvening?(time)
          ret = EncounterTypes::WaterEvening if has_encounter_type?(EncounterTypes::WaterEvening)
        end
      else
        ret = EncounterTypes::WaterNight if has_encounter_type?(EncounterTypes::WaterNight)
      end
    else
      check_land = false
      if has_cave_encounters?
        check_land = PBTerrain.isGrass?($game_map.terrain_tag($game_player.x, $game_player.y))
        ret = EncounterTypes::Cave if has_encounter_type?(EncounterTypes::Cave)
        if PBDayNight.isDay?(time)
          ret = EncounterTypes::CaveDay if has_encounter_type?(EncounterTypes::CaveDay)
          if PBDayNight.isMorning?(time)
            ret = EncounterTypes::CaveMorning if has_encounter_type?(EncounterTypes::CaveMorning)
          elsif PBDayNight.isAfternoon?(time)
            ret = EncounterTypes::CaveAfternoon if has_encounter_type?(EncounterTypes::CaveAfternoon)
          elsif PBDayNight.isEvening?(time)
            ret = EncounterTypes::CaveEvening if has_encounter_type?(EncounterTypes::CaveEvening)
          end
        else
          ret = EncounterTypes::CaveNight if has_encounter_type?(EncounterTypes::CaveNight)
        end
      end
      # Land
      if has_land_encounters? || check_land
        ret = EncounterTypes::Land if has_encounter_type?(EncounterTypes::Land)
        if PBDayNight.isDay?(time)
          ret = EncounterTypes::LandDay if has_encounter_type?(EncounterTypes::LandDay)
          if PBDayNight.isMorning?(time)
            ret = EncounterTypes::LandMorning if has_encounter_type?(EncounterTypes::LandMorning)
          elsif PBDayNight.isAfternoon?(time)
            ret = EncounterTypes::LandAfternoon if has_encounter_type?(EncounterTypes::LandAfternoon)
          elsif PBDayNight.isEvening?(time)
            ret = EncounterTypes::LandEvening if has_encounter_type?(EncounterTypes::LandEvening)
          end
        else
          ret = EncounterTypes::LandNight if has_encounter_type?(EncounterTypes::LandNight)
        end
        if pbInBugContest? && has_encounter_type?(EncounterTypes::BugContest)
          ret = EncounterTypes::BugContest
        end
      end
    end
    return ret
  end

  #=============================================================================

  # For the current map, randomly chooses a species and level from the encounter
  # list for the given encounter type. Returns nil if there are none defined.
  # A higher chance_rolls makes this method prefer rarer encounter slots.
  def choose_wild_pokemon(enc_type, chance_rolls = 1)
    if enc_type < 0 || enc_type > EncounterTypes::Probabilities.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    enc_list = @encounter_tables[enc_type]
    return nil if !enc_list || enc_list.length == 0
    # Static/Magnet Pull prefer wild encounters of certain types, if possible.
    # If they activate, they remove all Pokémon from the encounter table that do
    # not have the type they favor. If none have that type, nothing is changed.
    first_pkmn = $Trainer.first_pokemon
    if first_pkmn
      favored_type = nil
      case first_pkmn.ability_id
      when :STATIC
        favored_type = :ELECTRIC if GameData::Type.exists?(:ELECTRIC) && rand(100) < 50
      when :MAGNETPULL
        favored_type = :STEEL if GameData::Type.exists?(:STEEL) && rand(100) < 50
      end
      if favored_type
        new_enc_list = []
        enc_list.each do |enc|
          species_data = GameData::Species.get(enc[0])
          t1 = species_data.type1
          t2 = species_data.type2
          new_enc_list.push(enc) if t1 == favored_type || t2 == favored_type
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
    if Settings::FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS
      if $PokemonMap.blackFluteUsed
        level = [level + rand(1..4), PBExperience.maxLevel].min
      elsif $PokemonMap.whiteFluteUsed
        level = [level - rand(1..4), 1].max
      end
    end
    # Return [species, level]
    return [encounter[1], level]
  end

  # For the given map, randomly chooses a species and level from the encounter
  # list for the given encounter type. Returns nil if there are none defined.
  # Used by the Bug Catching Contest to choose what the other participants
  # caught.
  def choose_wild_pokemon_for_map(map_ID, enc_type)
    if enc_type < 0 || enc_type > EncounterTypes::Probabilities.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
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
def pbGenerateWildPokemon(species,level,isRoamer=false)
  genwildpoke = Pokemon.new(species,level)
  # Give the wild Pokémon a held item
  items = genwildpoke.wildHoldItems
  first_pkmn = $Trainer.first_pokemon
  chances = [50,5,1]
  chances = [60,20,5] if first_pkmn && first_pkmn.hasAbility?(:COMPOUNDEYES)
  itemrnd = rand(100)
  if (items[0]==items[1] && items[1]==items[2]) || itemrnd<chances[0]
    genwildpoke.item = items[0]
  elsif itemrnd<(chances[0]+chances[1])
    genwildpoke.item = items[1]
  elsif itemrnd<(chances[0]+chances[1]+chances[2])
    genwildpoke.item = items[2]
  end
  # Shiny Charm makes shiny Pokémon more likely to generate
  if GameData::Item.exists?(:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM)
    2.times do   # 3 times as likely
      break if genwildpoke.shiny?
      genwildpoke.personalID = rand(2**16) | rand(2**16) << 16
    end
  end
  # Give Pokérus
  genwildpoke.givePokerus if rand(65536) < Settings::POKERUS_CHANCE
  # Change wild Pokémon's gender/nature depending on the lead party Pokémon's
  # ability
  if first_pkmn
    if first_pkmn.hasAbility?(:CUTECHARM) && !genwildpoke.singleGendered?
      if first_pkmn.male?
        (rand(3)<2) ? genwildpoke.makeFemale : genwildpoke.makeMale
      elsif first_pkmn.female?
        (rand(3)<2) ? genwildpoke.makeMale : genwildpoke.makeFemale
      end
    elsif first_pkmn.hasAbility?(:SYNCHRONIZE)
      genwildpoke.nature = first_pkmn.nature if !isRoamer && rand(100)<50
    end
  end
  # Trigger events that may alter the generated Pokémon further
  Events.onWildPokemonCreate.trigger(nil,genwildpoke)
  return genwildpoke
end

# Used by fishing rods and Headbutt/Rock Smash/Sweet Scent. Skips the
# probability checks in def step_triggers_encounter? above.
def pbEncounter(enc_type)
  $PokemonTemp.encounterType = enc_type
  encounter1 = $PokemonEncounters.choose_wild_pokemon(enc_type)
  encounter1 = EncounterModifier.trigger(encounter1)
  return false if !encounter1
  if $PokemonEncounters.have_double_wild_battle?
    encounter2 = $PokemonEncounters.choose_wild_pokemon(enc_type)
    encounter2 = EncounterModifier.trigger(encounter2)
    return false if !encounter2
    pbDoubleWildBattle(encounter1[0], encounter1[1], encounter2[0], encounter2[1])
  else
    pbWildBattle(encounter1[0], encounter1[1])
  end
	$PokemonTemp.encounterType = -1
  $PokemonTemp.forceSingleBattle = false
  EncounterModifier.triggerEncounterEnd
  return true
end
