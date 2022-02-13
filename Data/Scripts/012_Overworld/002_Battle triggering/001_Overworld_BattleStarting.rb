#===============================================================================
# Battle preparation
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :nextBattleBGM
  attr_accessor :nextBattleME
  attr_accessor :nextBattleCaptureME
  attr_accessor :nextBattleBack
end



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
    when "canlose"                then rules["canLose"]        = true
    when "cannotlose"             then rules["canLose"]        = false
    when "canrun"                 then rules["canRun"]         = true
    when "cannotrun"              then rules["canRun"]         = false
    when "roamerflees"            then rules["roamerFlees"]    = true
    when "noexp"                  then rules["expGain"]        = false
    when "nomoney"                then rules["moneyGain"]      = false
    when "switchstyle"            then rules["switchStyle"]    = true
    when "setstyle"               then rules["switchStyle"]    = false
    when "anims"                  then rules["battleAnims"]    = true
    when "noanims"                then rules["battleAnims"]    = false
    when "terrain"
      terrain_data = GameData::BattleTerrain.try_get(var)
      rules["defaultTerrain"] = (terrain_data) ? terrain_data.id : nil
    when "weather"
      weather_data = GameData::BattleWeather.try_get(var)
      rules["defaultWeather"] = (weather_data) ? weather_data.id : nil
    when "environment", "environ"
      environment_data = GameData::Environment.try_get(var)
      rules["environment"] = (environment_data) ? environment_data.id : nil
    when "backdrop", "battleback" then rules["backdrop"]       = var
    when "base"                   then rules["base"]           = var
    when "outcome", "outcomevar"  then rules["outcomeVar"]     = var
    when "nopartner"              then rules["noPartner"]      = true
    else
      raise _INTL("Battle rule \"{1}\" does not exist.", rule)
    end
  end
end



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

def pbNewBattleScene
  return Battle::Scene.new
end

# Sets up various battle parameters and applies special rules.
def pbPrepareBattle(battle)
  battleRules = $game_temp.battle_rules
  # The size of the battle, i.e. how many Pokémon on each side (default: "single")
  battle.setBattleMode(battleRules["size"]) if !battleRules["size"].nil?
  # Whether the game won't black out even if the player loses (default: false)
  battle.canLose = battleRules["canLose"] if !battleRules["canLose"].nil?
  # Whether the player can choose to run from the battle (default: true)
  battle.canRun = battleRules["canRun"] if !battleRules["canRun"].nil?
  # Whether wild Pokémon always try to run from battle (default: nil)
  battle.rules["alwaysflee"] = battleRules["roamerFlees"]
  # Whether Pokémon gain Exp/EVs from defeating/catching a Pokémon (default: true)
  battle.expGain = battleRules["expGain"] if !battleRules["expGain"].nil?
  # Whether the player gains/loses money at the end of the battle (default: true)
  battle.moneyGain = battleRules["moneyGain"] if !battleRules["moneyGain"].nil?
  # Whether the player is able to switch when an opponent's Pokémon faints
  battle.switchStyle = ($PokemonSystem.battlestyle == 0)
  battle.switchStyle = battleRules["switchStyle"] if !battleRules["switchStyle"].nil?
  # Whether battle animations are shown
  battle.showAnims = ($PokemonSystem.battlescene == 0)
  battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
  # Terrain
  if battleRules["defaultTerrain"].nil? && Settings::OVERWORLD_WEATHER_SETS_BATTLE_TERRAIN
    case $game_screen.weather_type
    when :Storm
      battle.defaultTerrain = :Electric
    when :Fog
      battle.defaultTerrain = :Misty
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
  return $PokemonGlobal.partner || $player.able_pokemon_count >= 2
end

def pbCanTripleBattle?
  return true if $player.able_pokemon_count >= 3
  return $PokemonGlobal.partner && $player.able_pokemon_count >= 2
end

#===============================================================================
# Start a wild battle
#===============================================================================
def pbWildBattleCore(*args)
  outcomeVar = $game_temp.battle_rules["outcomeVar"] || 1
  canLose    = $game_temp.battle_rules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $player.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $player.pokemon_count > 0
    pbSet(outcomeVar, 1)   # Treat it as a win
    $game_temp.clear_battle_rules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
    pbMEStop
    return 1   # Treat it as a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  EventHandlers.trigger(:on_start_battle)
  # Generate wild Pokémon based on the species and level
  foeParty = []
  sp = nil
  args.each do |arg|
    if arg.is_a?(Pokemon)
      foeParty.push(arg)
    elsif arg.is_a?(Array)
      species = GameData::Species.get(arg[0]).id
      pkmn = pbGenerateWildPokemon(species, arg[1])
      foeParty.push(pkmn)
    elsif sp
      species = GameData::Species.get(sp).id
      pkmn = pbGenerateWildPokemon(species, arg)
      foeParty.push(pkmn)
      sp = nil
    else
      sp = arg
    end
  end
  raise _INTL("Expected a level after being given {1}, but one wasn't found.", sp) if sp
  # Calculate who the trainers and their party are
  playerTrainers    = [$player]
  playerParty       = $player.party
  playerPartyStarts = [0]
  room_for_partner = (foeParty.length > 1)
  if !room_for_partner && $game_temp.battle_rules["size"] &&
     !["single", "1v1", "1v2", "1v3"].include?($game_temp.battle_rules["size"])
    room_for_partner = true
  end
  if $PokemonGlobal.partner && !$game_temp.battle_rules["noPartner"] && room_for_partner
    ally = NPCTrainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
    ally.id    = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    playerTrainers.push(ally)
    playerParty = []
    $player.party.each { |pkmn| playerParty.push(pkmn) }
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
    setBattleRule("double") if !$game_temp.battle_rules["size"]
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = Battle.new(scene, playerParty, foeParty, playerTrainers, nil)
  battle.party1starts = playerPartyStarts
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $game_temp.clear_battle_rules
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty), (foeParty.length == 1) ? 0 : 2, foeParty) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision, canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    4 - Wild Pokémon was caught
  #    5 - Draw
  case decision
  when 1, 4   # Won, caught
    $stats.wild_battles_won += 1
  when 2, 3, 5   # Lost, fled, draw
    $stats.wild_battles_lost += 1
  end
  pbSet(outcomeVar, decision)
  return decision
end

#===============================================================================
# Standard methods that start a wild battle of various sizes
#===============================================================================
# Used when walking in tall grass, hence the additional code.
def pbWildBattle(species, level, outcomeVar = 1, canRun = true, canLose = false)
  species = GameData::Species.get(species).id
  # Potentially call a different pbWildBattle-type method instead (for roaming
  # Pokémon, Safari battles, Bug Contest battles)
  handled = [nil]
  EventHandlers.trigger(:on_calling_wild_battle, species, level, handled)
  return handled[0] if !handled[0].nil?
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  # Perform the battle
  decision = pbWildBattleCore(species, level)
  # Used by the Poké Radar to update/break the chain
  EventHandlers.trigger(:on_wild_battle_end, species, level, decision)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision != 2 && decision != 5)
end

def pbDoubleWildBattle(species1, level1, species2, level2,
                       outcomeVar = 1, canRun = true, canLose = false)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  setBattleRule("double")
  # Perform the battle
  decision = pbWildBattleCore(species1, level1, species2, level2)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision != 2 && decision != 5)
end

def pbTripleWildBattle(species1, level1, species2, level2, species3, level3,
                       outcomeVar = 1, canRun = true, canLose = false)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  setBattleRule("triple")
  # Perform the battle
  decision = pbWildBattleCore(species1, level1, species2, level2, species3, level3)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision != 2 && decision != 5)
end

#===============================================================================
# Start a trainer battle
#===============================================================================
def pbTrainerBattleCore(*args)
  outcomeVar = $game_temp.battle_rules["outcomeVar"] || 1
  canLose    = $game_temp.battle_rules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $player.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    pbMessage(_INTL("AFTER WINNING...")) if $DEBUG && $player.able_pokemon_count > 0
    pbSet(outcomeVar, ($player.able_pokemon_count == 0) ? 0 : 1)   # Treat it as undecided/a win
    $game_temp.clear_battle_rules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
    pbMEStop
    return ($player.able_pokemon_count == 0) ? 0 : 1   # Treat it as undecided/a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  EventHandlers.trigger(:on_start_battle)
  # Generate trainers and their parties based on the arguments given
  foeTrainers    = []
  foeItems       = []
  foeEndSpeeches = []
  foeParty       = []
  foePartyStarts = []
  args.each do |arg|
    case arg
    when NPCTrainer
      foeTrainers.push(arg)
      foePartyStarts.push(foeParty.length)
      arg.party.each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg.lose_text)
      foeItems.push(arg.items)
    when Array   # [trainer type, trainer name, ID, speech (optional)]
      trainer = pbLoadTrainer(arg[0], arg[1], arg[2])
      pbMissingTrainer(arg[0], arg[1], arg[2]) if !trainer
      return 0 if !trainer
      EventHandlers.trigger(:on_trainer_load, trainer)
      foeTrainers.push(trainer)
      foePartyStarts.push(foeParty.length)
      trainer.party.each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg[3] || trainer.lose_text)
      foeItems.push(trainer.items)
    else
      raise _INTL("Expected NPCTrainer or array of trainer data, got {1}.", arg)
    end
  end
  # Calculate who the player trainer(s) and their party are
  playerTrainers    = [$player]
  allyItems         = []
  playerParty       = $player.party
  playerPartyStarts = [0]
  room_for_partner = (foeParty.length > 1)
  if !room_for_partner && $game_temp.battle_rules["size"] &&
     !["single", "1v1", "1v2", "1v3"].include?($game_temp.battle_rules["size"])
    room_for_partner = true
  end
  if $PokemonGlobal.partner && !$game_temp.battle_rules["noPartner"] && room_for_partner
    ally = NPCTrainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
    ally.id    = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    allyItems[1] = ally.items.clone
    playerTrainers.push(ally)
    playerParty = []
    $player.party.each { |pkmn| playerParty.push(pkmn) }
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
    setBattleRule("double") if !$game_temp.battle_rules["size"]
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = Battle.new(scene, playerParty, foeParty, playerTrainers, foeTrainers)
  battle.party1starts = playerPartyStarts
  battle.party2starts = foePartyStarts
  battle.items        = foeItems
  battle.ally_items   = allyItems
  battle.endSpeeches  = foeEndSpeeches
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $game_temp.clear_battle_rules
  # End the trainer intro music
  Audio.me_stop
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetTrainerBattleBGM(foeTrainers), (battle.singleBattle?) ? 1 : 3, foeTrainers) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision, canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    5 - Draw
  case decision
  when 1   # Won
    $stats.trainer_battles_won += 1
  when 2, 3, 5   # Lost, fled, draw
    $stats.trainer_battles_lost += 1
  end
  pbSet(outcomeVar, decision)
  return decision
end

#===============================================================================
# Standard methods that start a trainer battle of various sizes
#===============================================================================
# Used by most trainer events, which can be positioned in such a way that
# multiple trainer events spot the player at once. The extra code in this method
# deals with that case and can cause a double trainer battle instead.
def pbTrainerBattle(trainerID, trainerName, endSpeech = nil,
                    doubleBattle = false, trainerPartyID = 0, canLose = false, outcomeVar = 1)
  # If there is another NPC trainer who spotted the player at the same time, and
  # it is possible to have a double battle (the player has 2+ able Pokémon or
  # has a partner trainer), then record this first NPC trainer into
  # $game_temp.waiting_trainer and end this method. That second NPC event will
  # then trigger and cause the battle to happen against this first trainer and
  # themselves.
  if !$game_temp.waiting_trainer && pbMapInterpreterRunning? &&
     ($player.able_pokemon_count > 1 ||
     ($player.able_pokemon_count > 0 && $PokemonGlobal.partner))
    thisEvent = pbMapInterpreter.get_self
    # Find all other triggered trainer events
    triggeredEvents = $game_player.pbTriggeredTrainerEvents([2], false)
    otherEvent = []
    triggeredEvents.each do |i|
      next if i.id == thisEvent.id
      next if $game_self_switches[[$game_map.map_id, i.id, "A"]]
      otherEvent.push(i)
    end
    # Load the trainer's data, and call an event which might modify it
    trainer = pbLoadTrainer(trainerID, trainerName, trainerPartyID)
    pbMissingTrainer(trainerID, trainerName, trainerPartyID) if !trainer
    return false if !trainer
    EventHandlers.trigger(:on_trainer_load, trainer)
    # If there is exactly 1 other triggered trainer event, and this trainer has
    # 6 or fewer Pokémon, record this trainer for a double battle caused by the
    # other triggered trainer event
    if otherEvent.length == 1 && trainer.party.length <= Settings::MAX_PARTY_SIZE
      trainer.lose_text = endSpeech if endSpeech && !endSpeech.empty?
      $game_temp.waiting_trainer = [trainer, thisEvent.id]
      return false
    end
  end
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("canLose") if canLose
  setBattleRule("double") if doubleBattle || $game_temp.waiting_trainer
  # Perform the battle
  if $game_temp.waiting_trainer
    decision = pbTrainerBattleCore($game_temp.waiting_trainer[0],
                                   [trainerID, trainerName, trainerPartyID, endSpeech])
  else
    decision = pbTrainerBattleCore([trainerID, trainerName, trainerPartyID, endSpeech])
  end
  # Finish off the recorded waiting trainer, because they have now been battled
  if decision == 1 && $game_temp.waiting_trainer   # Win
    pbMapInterpreter.pbSetSelfSwitch($game_temp.waiting_trainer[1], "A", true)
  end
  $game_temp.waiting_trainer = nil
  # Return true if the player won the battle, and false if any other result
  return (decision == 1)
end

def pbDoubleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
                          trainerID2, trainerName2, trainerPartyID2 = 0, endSpeech2 = nil,
                          canLose = false, outcomeVar = 1)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("canLose") if canLose
  setBattleRule("double")
  # Perform the battle
  decision = pbTrainerBattleCore(
    [trainerID1, trainerName1, trainerPartyID1, endSpeech1],
    [trainerID2, trainerName2, trainerPartyID2, endSpeech2]
  )
  # Return true if the player won the battle, and false if any other result
  return (decision == 1)
end

def pbTripleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
                          trainerID2, trainerName2, trainerPartyID2, endSpeech2,
                          trainerID3, trainerName3, trainerPartyID3 = 0, endSpeech3 = nil,
                          canLose = false, outcomeVar = 1)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("canLose") if canLose
  setBattleRule("triple")
  # Perform the battle
  decision = pbTrainerBattleCore(
    [trainerID1, trainerName1, trainerPartyID1, endSpeech1],
    [trainerID2, trainerName2, trainerPartyID2, endSpeech2],
    [trainerID3, trainerName3, trainerPartyID3, endSpeech3]
  )
  # Return true if the player won the battle, and false if any other result
  return (decision == 1)
end

#===============================================================================
# After battles
#===============================================================================
def pbAfterBattle(decision, canLose)
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
  if [2, 5].include?(decision) && canLose   # if loss or draw
    $player.party.each { |pkmn| pkmn.heal }
    (Graphics.frame_rate / 4).times { Graphics.update }
  end
  EventHandlers.trigger(:on_end_battle, decision, canLose)
  $game_player.straighten
end

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

# Try to gain an item after a battle if a Pokemon has the ability Pickup.
def pbPickup(pkmn)
  return if pkmn.egg? || !pkmn.hasAbility?(:PICKUP)
  return if pkmn.hasItem?
  return unless rand(100) < 10   # 10% chance
  # Common items to find (9 items from this list are added to the pool)
  pickupList = pbDynamicItemList(
    :POTION,
    :ANTIDOTE,
    :SUPERPOTION,
    :GREATBALL,
    :REPEL,
    :ESCAPEROPE,
    :FULLHEAL,
    :HYPERPOTION,
    :ULTRABALL,
    :REVIVE,
    :RARECANDY,
    :SUNSTONE,
    :MOONSTONE,
    :HEARTSCALE,
    :FULLRESTORE,
    :MAXREVIVE,
    :PPUP,
    :MAXELIXIR
  )
  # Rare items to find (2 items from this list are added to the pool)
  pickupListRare = pbDynamicItemList(
    :HYPERPOTION,
    :NUGGET,
    :KINGSROCK,
    :FULLRESTORE,
    :ETHER,
    :IRONBALL,
    :DESTINYKNOT,
    :ELIXIR,
    :DESTINYKNOT,
    :LEFTOVERS,
    :DESTINYKNOT
  )
  return if pickupList.length < 18
  return if pickupListRare.length < 11
  # Generate a pool of items depending on the Pokémon's level
  items = []
  pkmnLevel = [100, pkmn.level].min
  itemStartIndex = (pkmnLevel - 1) / 10
  itemStartIndex = 0 if itemStartIndex < 0
  9.times do |i|
    items.push(pickupList[itemStartIndex + i])
  end
  2.times do |i|
    items.push(pickupListRare[itemStartIndex + i])
  end
  # Probabilities of choosing each item in turn from the pool
  chances = [30, 10, 10, 10, 10, 10, 10, 4, 4, 1, 1]   # Needs to be 11 numbers
  chanceSum = 0
  chances.each { |c| chanceSum += c }
  # Randomly choose an item from the pool to give to the Pokémon
  rnd = rand(chanceSum)
  cumul = 0
  chances.each_with_index do |c, i|
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
