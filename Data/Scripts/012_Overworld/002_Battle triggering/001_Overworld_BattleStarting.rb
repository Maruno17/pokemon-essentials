#===============================================================================
# Battle preparation
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :nextBattleBGM
  attr_accessor :nextBattleVictoryBGM
  attr_accessor :nextBattleCaptureME
  attr_accessor :nextBattleBack
end

#===============================================================================
#
#===============================================================================
class Game_Temp
  attr_accessor :encounter_triggered
  attr_accessor :encounter_type
  attr_accessor :party_levels_before_battle
  attr_accessor :party_critical_hits_dealt
  attr_accessor :party_direct_damage_taken

  def battle_rules
    @battle_rules = {} if !@battle_rules
    return @battle_rules
  end

  def clear_battle_rules
    self.battle_rules.clear
  end

  def add_battle_rule(rule, var = nil)
    rules = self.battle_rules
    case rule.to_s.downcase
    when "single", "1v1", "1v2", "2v1", "1v3", "3v1",
         "double", "2v2", "2v3", "3v2", "triple", "3v3"
      rules["size"] = rule.to_s.downcase
    when "canlose"                then rules["canLose"]             = true
    when "cannotlose"             then rules["canLose"]             = false
    when "canrun"                 then rules["canRun"]              = true
    when "cannotrun"              then rules["canRun"]              = false
    when "roamerflees"            then rules["roamerFlees"]         = true
    when "canswitch"              then rules["canSwitch"]           = true
    when "cannotswitch"           then rules["canSwitch"]           = false
    when "noexp"                  then rules["expGain"]             = false
    when "nomoney"                then rules["moneyGain"]           = false
    when "disablepokeballs"       then rules["disablePokeBalls"]    = true
    when "forcecatchintoparty"    then rules["forceCatchIntoParty"] = true
    when "switchstyle"            then rules["switchStyle"]         = true
    when "setstyle"               then rules["switchStyle"]         = false
    when "anims"                  then rules["battleAnims"]         = true
    when "noanims"                then rules["battleAnims"]         = false
    when "terrain"
      rules["defaultTerrain"] = GameData::BattleTerrain.try_get(var)&.id
    when "weather"
      rules["defaultWeather"] = GameData::BattleWeather.try_get(var)&.id
    when "environment", "environ"
      rules["environment"] = GameData::Environment.try_get(var)&.id
    when "backdrop", "battleback" then rules["backdrop"]            = var
    when "base"                   then rules["base"]                = var
    when "outcome", "outcomevar"  then rules["outcomeVar"]          = var
    when "nopartner"              then rules["noPartner"]           = true
    else
      raise _INTL("Battle rule \"{1}\" does not exist.", rule)
    end
  end
end

#===============================================================================
#
#===============================================================================
def setBattleRule(*args)
  r = nil
  args.each do |arg|
    if r
      $game_temp.add_battle_rule(r, arg)
      r = nil
    else
      case arg.downcase
      when "terrain", "weather", "environment", "environ", "backdrop",
           "battleback", "base", "outcome", "outcomevar"
        r = arg
        next
      end
      $game_temp.add_battle_rule(arg)
    end
  end
  raise _INTL("Argument {1} expected a variable after it but didn't have one.", r) if r
end

# Used to determine the environment in battle, and also the form of Burmy/
# Wormadam.
def pbGetEnvironment
  ret = :None
  map_env = $game_map.metadata&.battle_environment
  ret = map_env if map_env
  if $game_temp.encounter_type &&
     GameData::EncounterType.get($game_temp.encounter_type).type == :fishing
    terrainTag = $game_player.pbFacingTerrainTag
  else
    terrainTag = $game_player.terrain_tag
  end
  tile_environment = terrainTag.battle_environment
  if ret == :Forest && [:Grass, :TallGrass].include?(tile_environment)
    ret = :ForestGrass
  elsif tile_environment
    ret = tile_environment
  end
  return ret
end

# Record current levels of Pokémon in party, to see if they gain a level during
# battle and may need to evolve afterwards
EventHandlers.add(:on_start_battle, :record_party_status,
  proc {
    $game_temp.party_levels_before_battle = []
    $game_temp.party_critical_hits_dealt = []
    $game_temp.party_direct_damage_taken = []
    $player.party.each_with_index do |pkmn, i|
      $game_temp.party_levels_before_battle[i] = pkmn.level
      $game_temp.party_critical_hits_dealt[i] = 0
      $game_temp.party_direct_damage_taken[i] = 0
    end
  }
)

def pbCanDoubleBattle?
  return true if $player.able_pokemon_count >= 2
  return $PokemonGlobal.partner && $player.able_pokemon_count >= 1
end

def pbCanTripleBattle?
  return true if $player.able_pokemon_count >= 3
  return $PokemonGlobal.partner && $player.able_pokemon_count >= 2
end

#===============================================================================
# Helper methods for setting up and closing down battles
#===============================================================================
module BattleCreationHelperMethods
  module_function

  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  def skip_battle?
    return true if $player.able_pokemon_count == 0
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false
  end

  def skip_battle(outcome_variable, trainer_battle = false)
    pbMessage(_INTL("SKIPPING BATTLE...")) if !trainer_battle && $player.pokemon_count > 0
    pbMessage(_INTL("SKIPPING BATTLE...")) if trainer_battle && $DEBUG
    pbMessage(_INTL("AFTER WINNING...")) if trainer_battle && $player.able_pokemon_count > 0
    $game_temp.clear_battle_rules
    if $game_temp.memorized_bgm && $game_system.is_a?(Game_System)
      $game_system.bgm_pause
      $game_system.bgm_position = $game_temp.memorized_bgm_position
      $game_system.bgm_resume($game_temp.memorized_bgm)
    end
    $game_temp.memorized_bgm            = nil
    $game_temp.memorized_bgm_position   = 0
    $PokemonGlobal.nextBattleBGM        = nil
    $PokemonGlobal.nextBattleVictoryBGM = nil
    $PokemonGlobal.nextBattleCaptureME  = nil
    $PokemonGlobal.nextBattleBack       = nil
    $PokemonEncounters.reset_step_count
    outcome = 1   # Win
    outcome = 0 if trainer_battle && $player.able_pokemon_count == 0   # Undecided
    pbSet(outcome_variable, outcome)
    return outcome
  end

  def partner_can_participate?(foe_party)
    return false if !$PokemonGlobal.partner || $game_temp.battle_rules["noPartner"]
    return true if foe_party.length > 1
    if $game_temp.battle_rules["size"]
      return false if $game_temp.battle_rules["size"] == "single" ||
                      $game_temp.battle_rules["size"][/^1v/i]   # "1v1", "1v2", "1v3", etc.
      return true
    end
    return false
  end

  # Generate information for the player and partner trainer(s)
  def set_up_player_trainers(foe_party)
    trainer_array = [$player]
    ally_items    = []
    pokemon_array = $player.party
    party_starts  = [0]
    if partner_can_participate?(foe_party)
      ally = NPCTrainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
      ally.id    = $PokemonGlobal.partner[2]
      ally.party = $PokemonGlobal.partner[3]
      ally_items[1] = ally.items.clone
      trainer_array.push(ally)
      pokemon_array = []
      $player.party.each { |pkmn| pokemon_array.push(pkmn) }
      party_starts.push(pokemon_array.length)
      ally.party.each { |pkmn| pokemon_array.push(pkmn) }
      setBattleRule("double") if $game_temp.battle_rules["size"].nil?
    end
    return trainer_array, ally_items, pokemon_array, party_starts
  end

  def create_battle_scene
    return Battle::Scene.new
  end

  # Sets up various battle parameters and applies special rules.
  def prepare_battle(battle)
    battleRules = $game_temp.battle_rules
    # The size of the battle, i.e. how many Pokémon on each side (default: "single")
    battle.setBattleMode(battleRules["size"]) if !battleRules["size"].nil?
    # Whether the game won't black out even if the player loses (default: false)
    battle.canLose = battleRules["canLose"] if !battleRules["canLose"].nil?
    # Whether the player can choose to run from the battle (default: true)
    battle.canRun = battleRules["canRun"] if !battleRules["canRun"].nil?
    # Whether the player can manually choose to switch out Pokémon (default: true)
    battle.canSwitch = battleRules["canSwitch"] if !battleRules["canSwitch"].nil?
    # Whether wild Pokémon always try to run from battle (default: nil)
    battle.rules["alwaysflee"] = battleRules["roamerFlees"]
    # Whether Pokémon gain Exp/EVs from defeating/catching a Pokémon (default: true)
    battle.expGain = battleRules["expGain"] if !battleRules["expGain"].nil?
    # Whether the player gains/loses money at the end of the battle (default: true)
    battle.moneyGain = battleRules["moneyGain"] if !battleRules["moneyGain"].nil?
    # Whether Poké Balls cannot be thrown at all
    battle.disablePokeBalls = battleRules["disablePokeBalls"] if !battleRules["disablePokeBalls"].nil?
    # Whether the player is asked what to do with a new Pokémon when their party is full
    battle.sendToBoxes = $PokemonSystem.sendtoboxes if Settings::NEW_CAPTURE_CAN_REPLACE_PARTY_MEMBER
    battle.sendToBoxes = 2 if battleRules["forceCatchIntoParty"]
    # Whether the player is able to switch when an opponent's Pokémon faints
    battle.switchStyle = ($PokemonSystem.battlestyle == 0)
    battle.switchStyle = battleRules["switchStyle"] if !battleRules["switchStyle"].nil?
    # Whether battle animations are shown
    battle.showAnims = ($PokemonSystem.battlescene == 0)
    battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
    # Terrain
    if battleRules["defaultTerrain"].nil?
      if Settings::OVERWORLD_WEATHER_SETS_BATTLE_TERRAIN
        case $game_screen.weather_type
        when :Storm
          battle.defaultTerrain = :Electric
        when :Fog
          battle.defaultTerrain = :Misty
        end
      end
    else
      battle.defaultTerrain = battleRules["defaultTerrain"]
    end
    # Weather
    if battleRules["defaultWeather"].nil?
      case GameData::Weather.get($game_screen.weather_type).category
      when :Rain, :Storm
        battle.defaultWeather = :Rain
      when :Hail
        battle.defaultWeather = :Hail
      when :Sandstorm
        battle.defaultWeather = :Sandstorm
      when :Sun
        battle.defaultWeather = :Sun
      end
    else
      battle.defaultWeather = battleRules["defaultWeather"]
    end
    # Environment
    if battleRules["environment"].nil?
      battle.environment = pbGetEnvironment
    else
      battle.environment = battleRules["environment"]
    end
    # Backdrop graphic filename
    if !battleRules["backdrop"].nil?
      backdrop = battleRules["backdrop"]
    elsif $PokemonGlobal.nextBattleBack
      backdrop = $PokemonGlobal.nextBattleBack
    elsif $PokemonGlobal.surfing
      backdrop = "water"   # This applies wherever you are, including in caves
    elsif $game_map.metadata
      back = $game_map.metadata.battle_background
      backdrop = back if back && back != ""
    end
    backdrop = "indoor1" if !backdrop
    battle.backdrop = backdrop
    # Choose a name for bases depending on environment
    if battleRules["base"].nil?
      environment_data = GameData::Environment.try_get(battle.environment)
      base = environment_data.battle_base if environment_data
    else
      base = battleRules["base"]
    end
    battle.backdropBase = base if base
    # Time of day
    if $game_map.metadata&.battle_environment == :Cave
      battle.time = 2   # This makes Dusk Balls work properly in caves
    elsif Settings::TIME_SHADING
      timeNow = pbGetTimeNow
      if PBDayNight.isNight?(timeNow)
        battle.time = 2
      elsif PBDayNight.isEvening?(timeNow)
        battle.time = 1
      else
        battle.time = 0
      end
    end
  end

  def after_battle(outcome, can_lose)
    $player.party.each do |pkmn|
      pkmn.statusCount = 0 if pkmn.status == :POISON   # Bad poison becomes regular
      pkmn.makeUnmega
      pkmn.makeUnprimal
    end
    if $PokemonGlobal.partner
      $player.heal_party
      $PokemonGlobal.partner[3].each do |pkmn|
        pkmn.heal
        pkmn.makeUnmega
        pkmn.makeUnprimal
      end
    end
    if [2, 5].include?(outcome) && can_lose   # if loss or draw
      $player.party.each { |pkmn| pkmn.heal }
      timer_start = System.uptime
      until System.uptime - timer_start >= 0.25
        Graphics.update
      end
    end
    EventHandlers.trigger(:on_end_battle, outcome, can_lose)
    $game_player.straighten
  end

  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    4 - Wild Pokémon was caught
  #    5 - Draw
  def set_outcome(outcome, outcome_variable = 1, trainer_battle = false)
    case outcome
    when 1, 4   # Won, caught
      $stats.wild_battles_won += 1 if !trainer_battle
      $stats.trainer_battles_won += 1 if trainer_battle
    when 2, 3, 5   # Lost, fled, draw
      $stats.wild_battles_lost += 1 if !trainer_battle
      $stats.trainer_battles_lost += 1 if trainer_battle
    end
    pbSet(outcome_variable, outcome)
  end
end

#===============================================================================
# Wild battles
#===============================================================================
class WildBattle
  # Used when walking in tall grass, hence the additional code.
  def self.start(*args, can_override: false)
    foe_party = WildBattle.generate_foes(*args)
    # Potentially call a different WildBattle.start-type method instead (for
    # roaming Pokémon, Safari battles, Bug Contest battles)
    if foe_party.length == 1 && can_override
      handled = [nil]
      EventHandlers.trigger(:on_calling_wild_battle, foe_party[0], handled)
      return handled[0] if !handled[0].nil?
    end
    # Perform the battle
    outcome = WildBattle.start_core(*foe_party)
    # Used by the Poké Radar to update/break the chain
    if foe_party.length == 1 && can_override
      EventHandlers.trigger(:on_wild_battle_end, foe_party[0].species, foe_party[0].level, outcome)
    end
    # Return false if the player lost or drew the battle, and true if any other result
    return outcome != 2 && outcome != 5
  end

  def self.start_core(*args)
    outcome_variable = $game_temp.battle_rules["outcomeVar"] || 1
    can_lose         = $game_temp.battle_rules["canLose"] || false
    # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
    if BattleCreationHelperMethods.skip_battle?
      return BattleCreationHelperMethods.skip_battle(outcome_variable)
    end
    # Record information about party Pokémon to be used at the end of battle
    # (e.g. comparing levels for an evolution check)
    EventHandlers.trigger(:on_start_battle)
    # Generate array of foes
    foe_party = WildBattle.generate_foes(*args)
    # Generate information for the player and partner trainer(s)
    player_trainers, ally_items, player_party, player_party_starts = BattleCreationHelperMethods.set_up_player_trainers(foe_party)
    # Create the battle scene (the visual side of it)
    scene = BattleCreationHelperMethods.create_battle_scene
    # Create the battle class (the mechanics side of it)
    battle = Battle.new(scene, player_party, foe_party, player_trainers, nil)
    battle.party1starts = player_party_starts
    battle.ally_items   = ally_items
    # Set various other properties in the battle class
    setBattleRule("#{foe_party.length}v#{foe_party.length}") if $game_temp.battle_rules["size"].nil?
    BattleCreationHelperMethods.prepare_battle(battle)
    $game_temp.clear_battle_rules
    # Perform the battle itself
    outcome = 0
    pbBattleAnimation(pbGetWildBattleBGM(foe_party), (foe_party.length == 1) ? 0 : 2, foe_party) do
      pbSceneStandby { outcome = battle.pbStartBattle }
      BattleCreationHelperMethods.after_battle(outcome, can_lose)
    end
    Input.update
    # Save the result of the battle in a Game Variable (1 by default)
    BattleCreationHelperMethods.set_outcome(outcome, outcome_variable)
    return outcome
  end

  def self.generate_foes(*args)
    ret = []
    species_id = nil
    args.each do |arg|
      case arg
      when Pokemon
        raise _INTL("Species {1} was given but not a level.", species_id) if species_id
        ret.push(arg)
      when Array
        raise _INTL("Species {1} was given but not a level.", species_id) if species_id
        species = GameData::Species.get(arg[0]).id
        pkmn = pbGenerateWildPokemon(species, arg[1])
        ret.push(pkmn)
      else
        if species_id   # Expecting level
          if !arg.is_a?(Integer) || !(1..GameData::GrowthRate.max_level).include?(arg)
            raise _INTL("Expected a level (1..{1}) but {2} is not a number or not a valid level.", GameData::GrowthRate.max_level, arg)
          end
          ret.push(pbGenerateWildPokemon(species_id, arg))
          species_id = nil
        else   # Expecting species ID
          if !GameData::Species.exists?(arg)
            raise _INTL("Species {1} does not exist.", arg)
          end
          species_id = arg
        end
      end
    end
    raise _INTL("Species {1} was given but not a level.", species_id) if species_id
    return ret
  end
end

#===============================================================================
# Trainer battles
#===============================================================================
class TrainerBattle
  # Used by most trainer events, which can be positioned in such a way that
  # multiple trainer events spot the player at once. The extra code in this
  # method deals with that case and can cause a double trainer battle instead.
  def self.start(*args)
    # If there is another NPC trainer who spotted the player at the same time,
    # and it is possible to have a double battle (the player has 2+ able Pokémon
    # or has a partner trainer), then record this first NPC trainer into
    # $game_temp.waiting_trainer and end this method. That second NPC event will
    # then trigger and cause the battle to happen against this first trainer and
    # themselves.
    if !$game_temp.waiting_trainer && pbMapInterpreterRunning? && pbCanDoubleBattle?
      thisEvent = pbMapInterpreter.get_self
      # Find all other triggered trainer events
      triggeredEvents = $game_player.pbTriggeredTrainerEvents([2], false, true)
      otherEvent = []
      triggeredEvents.each do |i|
        next if i.id == thisEvent.id
        next if $game_self_switches[[$game_map.map_id, i.id, "A"]]
        otherEvent.push(i)
      end
      # If there is exactly 1 other triggered trainer event, this trainer can be
      # stored up to battle with that one
      if otherEvent.length == 1
        trainers, _items, _end_speeches, _party, _party_starts = TrainerBattle.generate_foes(*args)
        # If this is just 1 trainer with 6 or fewer Pokémon, it can be stored up
        # to battle alongside the other trainer
        if trainers.length == 1 && trainers[0].party.length <= Settings::MAX_PARTY_SIZE
          $game_temp.waiting_trainer = [trainers[0], thisEvent.id]
          return false
        end
      end
    end
    # Perform the battle
    if $game_temp.waiting_trainer
      new_args = args + [$game_temp.waiting_trainer[0]]
      outcome = TrainerBattle.start_core(*new_args)
      pbMapInterpreter.pbSetSelfSwitch($game_temp.waiting_trainer[1], "A", true) if outcome == 1
      $game_temp.waiting_trainer = nil
    else
      outcome = TrainerBattle.start_core(*args)
    end
    # Return true if the player won the battle, and false if any other result
    return outcome == 1
  end

  def self.start_core(*args)
    outcome_variable = $game_temp.battle_rules["outcomeVar"] || 1
    can_lose         = $game_temp.battle_rules["canLose"] || false
    # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
    if BattleCreationHelperMethods.skip_battle?
      return BattleCreationHelperMethods.skip_battle(outcome_variable, true)
    end
    # Record information about party Pokémon to be used at the end of battle (e.g.
    # comparing levels for an evolution check)
    EventHandlers.trigger(:on_start_battle)
    # Generate information for the foes
    foe_trainers, foe_items, foe_party, foe_party_starts = TrainerBattle.generate_foes(*args)
    # Generate information for the player and partner trainer(s)
    player_trainers, ally_items, player_party, player_party_starts = BattleCreationHelperMethods.set_up_player_trainers(foe_party)
    # Create the battle scene (the visual side of it)
    scene = BattleCreationHelperMethods.create_battle_scene
    # Create the battle class (the mechanics side of it)
    battle = Battle.new(scene, player_party, foe_party, player_trainers, foe_trainers)
    battle.party1starts = player_party_starts
    battle.party2starts = foe_party_starts
    battle.ally_items   = ally_items
    battle.items        = foe_items
    # Set various other properties in the battle class
    setBattleRule("#{foe_trainers.length}v#{foe_trainers.length}") if $game_temp.battle_rules["size"].nil?
    BattleCreationHelperMethods.prepare_battle(battle)
    $game_temp.clear_battle_rules
    # Perform the battle itself
    outcome = 0
    pbBattleAnimation(pbGetTrainerBattleBGM(foe_trainers), (battle.singleBattle?) ? 1 : 3, foe_trainers) do
      pbSceneStandby { outcome = battle.pbStartBattle }
      BattleCreationHelperMethods.after_battle(outcome, can_lose)
    end
    Input.update
    # Save the result of the battle in a Game Variable (1 by default)
    BattleCreationHelperMethods.set_outcome(outcome, outcome_variable, true)
    return outcome
  end

  def self.generate_foes(*args)
    trainer_array = []
    foe_items     = []
    pokemon_array = []
    party_starts  = []
    trainer_type = nil
    trainer_name = nil
    args.each_with_index do |arg, i|
      case arg
      when NPCTrainer
        raise _INTL("Trainer type {1} was given but not a trainer name.", trainer_type) if trainer_type
        trainer_array.push(arg)
        foe_items.push(arg.items)
        party_starts.push(pokemon_array.length)
        arg.party.each { |pkmn| pokemon_array.push(pkmn) }
      when Array   # [trainer type, trainer name, version number, speech (optional)]
        raise _INTL("Trainer type {1} was given but not a trainer name.", trainer_type) if trainer_type
        trainer = pbLoadTrainer(arg[0], arg[1], arg[2])
        pbMissingTrainer(arg[0], arg[1], arg[2]) if !trainer
        trainer = pbLoadTrainer(arg[0], arg[1], arg[2]) if !trainer   # Try again
        raise _INTL("Trainer for data '{1}' is not defined.", arg) if !trainer
        EventHandlers.trigger(:on_trainer_load, trainer)
        trainer.lose_text = arg[3] if arg[3] && !arg[3].empty?
        trainer_array.push(trainer)
        foe_items.push(trainer.items)
        party_starts.push(pokemon_array.length)
        trainer.party.each { |pkmn| pokemon_array.push(pkmn) }
      else
        if trainer_name   # Expecting version number
          if !arg.is_a?(Integer) || arg < 0
            raise _INTL("Expected a trainer version number (0 or higher) but {1} is not a number or not a valid value.", arg)
          end
          trainer = pbLoadTrainer(trainer_type, trainer_name, arg)
          pbMissingTrainer(trainer_type, trainer_name, arg) if !trainer
          trainer = pbLoadTrainer(trainer_type, trainer_name, arg) if !trainer   # Try again
          raise _INTL("Trainer for data '{1}, {2}, {3}' is not defined.", trainer_type, trainer_name, arg) if !trainer
          EventHandlers.trigger(:on_trainer_load, trainer)
          trainer_array.push(trainer)
          foe_items.push(trainer.items)
          party_starts.push(pokemon_array.length)
          trainer.party.each { |pkmn| pokemon_array.push(pkmn) }
          trainer_type = nil
          trainer_name = nil
        elsif trainer_type   # Expecting trainer name
          if !arg.is_a?(String) || arg.strip.empty?
            raise _INTL("Expected a trainer name but '{1}' is not a valid name.", arg)
          end
          if args[i + 1].is_a?(Integer)   # Version number is next
            trainer_name = arg.strip
          else
            trainer = pbLoadTrainer(trainer_type, arg)
            pbMissingTrainer(trainer_type, arg, 0) if !trainer
            trainer = pbLoadTrainer(trainer_type, arg) if !trainer   # Try again
            raise _INTL("Trainer for data '{1}, {2}' is not defined.", trainer_type, arg) if !trainer
            EventHandlers.trigger(:on_trainer_load, trainer)
            trainer_array.push(trainer)
            foe_items.push(trainer.items)
            party_starts.push(pokemon_array.length)
            trainer.party.each { |pkmn| pokemon_array.push(pkmn) }
            trainer_type = nil
          end
        else   # Expecting trainer type
          if !GameData::TrainerType.exists?(arg)
            raise _INTL("Trainer type {1} does not exist.", arg)
          end
          trainer_type = arg
        end
      end
    end
    raise _INTL("Trainer type {1} was given but not a trainer name.", trainer_type) if trainer_type
    return trainer_array, foe_items, pokemon_array, party_starts
  end
end

#===============================================================================
# After battles
#===============================================================================
EventHandlers.add(:on_end_battle, :evolve_and_black_out,
  proc { |decision, canLose|
    # Check for evolutions
    pbEvolutionCheck if Settings::CHECK_EVOLUTION_AFTER_ALL_BATTLES ||
                        (decision != 2 && decision != 5)   # not a loss or a draw
    $game_temp.party_levels_before_battle = nil
    $game_temp.party_critical_hits_dealt = nil
    $game_temp.party_direct_damage_taken = nil
    # Check for blacking out or gaining Pickup/Huney Gather items
    case decision
    when 1, 4   # Win, capture
      $player.pokemon_party.each do |pkmn|
        pbPickup(pkmn)
        pbHoneyGather(pkmn)
      end
    when 2, 5   # Lose, draw
      if !canLose
        $game_system.bgm_unpause
        $game_system.bgs_unpause
        pbStartOver
      end
    end
  }
)

def pbEvolutionCheck
  $player.party.each_with_index do |pkmn, i|
    next if !pkmn || pkmn.egg?
    next if pkmn.fainted? && !Settings::CHECK_EVOLUTION_FOR_FAINTED_POKEMON
    # Find an evolution
    new_species = nil
    if new_species.nil? && $game_temp.party_levels_before_battle &&
       $game_temp.party_levels_before_battle[i] &&
       $game_temp.party_levels_before_battle[i] < pkmn.level
      new_species = pkmn.check_evolution_on_level_up
    end
    new_species = pkmn.check_evolution_after_battle(i) if new_species.nil?
    next if new_species.nil?
    # Evolve Pokémon if possible
    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pkmn, new_species)
    evo.pbEvolution
    evo.pbEndScreen
  end
end

def pbDynamicItemList(*args)
  ret = []
  args.each { |arg| ret.push(arg) if GameData::Item.exists?(arg) }
  return ret
end

# Common items to find via Pickup. Items from this list are added to the pool in
# order, starting from a point dependng on the Pokémon's level. The number of
# items added is how many probabilities are in the PICKUP_COMMON_ITEM_CHANCES
# array below.
# There must be 9 + PICKUP_COMMON_ITEM_CHANCES.length number of items in this
# array (18 by default). The 9 is actually (100 / num_rarity_levels) - 1, where
# num_rarity_levels is in def pbPickup below.
PICKUP_COMMON_ITEMS = [
  :POTION,        # Levels 1-10
  :ANTIDOTE,      # Levels 1-10, 11-20
  :SUPERPOTION,   # Levels 1-10, 11-20, 21-30
  :GREATBALL,     # Levels 1-10, 11-20, 21-30, 31-40
  :REPEL,         # Levels 1-10, 11-20, 21-30, 31-40, 41-50
  :ESCAPEROPE,    # Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60
  :FULLHEAL,      # Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60, 61-70
  :HYPERPOTION,   # Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60, 61-70, 71-80
  :ULTRABALL,     # Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60, 61-70, 71-80, 81-90
  :REVIVE,        # Levels       11-20, 21-30, 31-40, 41-50, 51-60, 61-70, 71-80, 81-90, 91-100
  :RARECANDY,     # Levels              21-30, 31-40, 41-50, 51-60, 61-70, 71-80, 81-90, 91-100
  :SUNSTONE,      # Levels                     31-40, 41-50, 51-60, 61-70, 71-80, 81-90, 91-100
  :MOONSTONE,     # Levels                            41-50, 51-60, 61-70, 71-80, 81-90, 91-100
  :HEARTSCALE,    # Levels                                   51-60, 61-70, 71-80, 81-90, 91-100
  :FULLRESTORE,   # Levels                                          61-70, 71-80, 81-90, 91-100
  :MAXREVIVE,     # Levels                                                 71-80, 81-90, 91-100
  :PPUP,          # Levels                                                        81-90, 91-100
  :MAXELIXIR      # Levels                                                               91-100
]
# Chances to get each item added to the pool from the array above.
PICKUP_COMMON_ITEM_CHANCES = [30, 10, 10, 10, 10, 10, 10, 4, 4]
# Rare items to find via Pickup. Items from this list are added to the pool in
# order, starting from a point dependng on the Pokémon's level. The number of
# items added is how many probabilities are in the PICKUP_RARE_ITEM_CHANCES
# array below.
# There must be 9 + PICKUP_RARE_ITEM_CHANCES.length number of items in this
# array (11 by default). The 9 is actually (100 / num_rarity_levels) - 1, where
# num_rarity_levels is in def pbPickup below.
PICKUP_RARE_ITEMS = [
  :HYPERPOTION,   # Levels 1-10
  :NUGGET,        # Levels 1-10, 11-20
  :KINGSROCK,     # Levels       11-20, 21-30
  :FULLRESTORE,   # Levels              21-30, 31-40
  :ETHER,         # Levels                     31-40, 41-50
  :IRONBALL,      # Levels                            41-50, 51-60
  :DESTINYKNOT,   # Levels                                   51-60, 61-70
  :ELIXIR,        # Levels                                          61-70, 71-80
  :DESTINYKNOT,   # Levels                                                 71-80, 81-90
  :LEFTOVERS,     # Levels                                                        81-90, 91-100
  :DESTINYKNOT    # Levels                                                               91-100
]
# Chances to get each item added to the pool from the array above.
PICKUP_RARE_ITEM_CHANCES = [1, 1]

# Try to gain an item after a battle if a Pokemon has the ability Pickup.
def pbPickup(pkmn)
  return if pkmn.egg? || !pkmn.hasAbility?(:PICKUP)
  return if pkmn.hasItem?
  return unless rand(100) < 10   # 10% chance for Pickup to trigger
  num_rarity_levels = 10
  # Ensure common and rare item lists contain defined items
  common_items = pbDynamicItemList(*PICKUP_COMMON_ITEMS)
  rare_items = pbDynamicItemList(*PICKUP_RARE_ITEMS)
  return if common_items.length < num_rarity_levels - 1 + PICKUP_COMMON_ITEM_CHANCES.length
  return if rare_items.length < num_rarity_levels - 1 + PICKUP_RARE_ITEM_CHANCES.length
  # Determine the starting point for adding items from the above arrays into the
  # pool
  start_index = [([100, pkmn.level].min - 1) * num_rarity_levels / 100, 0].max
  # Generate a pool of items depending on the Pokémon's level
  items = []
  PICKUP_COMMON_ITEM_CHANCES.length.times { |i| items.push(common_items[start_index + i]) }
  PICKUP_RARE_ITEM_CHANCES.length.times { |i| items.push(rare_items[start_index + i]) }
  # Randomly choose an item from the pool to give to the Pokémon
  all_chances = PICKUP_COMMON_ITEM_CHANCES + PICKUP_RARE_ITEM_CHANCES
  rnd = rand(all_chances.sum)
  cumul = 0
  all_chances.each_with_index do |c, i|
    cumul += c
    next if rnd >= cumul
    pkmn.item = items[i]
    break
  end
end

# Try to gain a Honey item after a battle if a Pokemon has the ability Honey Gather.
def pbHoneyGather(pkmn)
  return if !GameData::Item.exists?(:HONEY)
  return if pkmn.egg? || !pkmn.hasAbility?(:HONEYGATHER) || pkmn.hasItem?
  chance = 5 + (((pkmn.level - 1) / 10) * 5)
  return unless rand(100) < chance
  pkmn.item = :HONEY
end
