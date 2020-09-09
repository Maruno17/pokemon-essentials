#===============================================================================
# Battle preparation
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :nextBattleBGM
  attr_accessor :nextBattleME
  attr_accessor :nextBattleCaptureME
  attr_accessor :nextBattleBack
end



class PokemonTemp
  attr_accessor :encounterType
  attr_accessor :evolutionLevels

  def battleRules
    @battleRules = {} if !@battleRules
    return @battleRules
  end

  def clearBattleRules
    self.battleRules.clear
  end

  def recordBattleRule(rule,var=nil)
    rules = self.battleRules
    case rule.to_s.downcase
    when "single", "1v1", "1v2", "2v1", "1v3", "3v1",
         "double", "2v2", "2v3", "3v2", "triple", "3v3"
      rules["size"] = rule.to_s.downcase
    when "canlose";                rules["canLose"]        = true
    when "cannotlose";             rules["canLose"]        = false
    when "canrun";                 rules["canRun"]         = true
    when "cannotrun";              rules["canRun"]         = false
    when "roamerflees";            rules["roamerFlees"]    = true
    when "noExp";                  rules["expGain"]        = false
    when "noMoney";                rules["moneyGain"]      = false
    when "switchstyle";            rules["switchStyle"]    = true
    when "setstyle";               rules["switchStyle"]    = false
    when "anims";                  rules["battleAnims"]    = true
    when "noanims";                rules["battleAnims"]    = false
    when "terrain";                rules["defaultTerrain"] = getID(PBBattleTerrains,var)
    when "weather";                rules["defaultWeather"] = getID(PBWeather,var)
    when "environment", "environ"; rules["environment"]    = getID(PBEnvironment,var)
    when "backdrop", "battleback"; rules["backdrop"]       = var
    when "base";                   rules["base"]           = var
    when "outcomevar", "outcome";  rules["outcomeVar"]     = var
    when "nopartner";              rules["noPartner"]      = true
    else
      raise _INTL("Battle rule \"{1}\" does not exist.",rule)
    end
  end
end



def setBattleRule(*args)
  r = nil
  for arg in args
    if r
      $PokemonTemp.recordBattleRule(r,arg)
      r = nil
    else
      case arg.downcase
      when "terrain", "weather", "environment", "environ", "backdrop",
           "battleback", "base", "outcomevar", "outcome"
        r = arg
        next
      end
      $PokemonTemp.recordBattleRule(arg)
    end
  end
  raise _INTL("Argument {1} expected a variable after it but didn't have one.",r) if r
end

def pbNewBattleScene
  return PokeBattle_Scene.new
end

# Sets up various battle parameters and applies special rules.
def pbPrepareBattle(battle)
  battleRules = $PokemonTemp.battleRules
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
  battle.switchStyle = ($PokemonSystem.battlestyle==0)
  battle.switchStyle = battleRules["switchStyle"] if !battleRules["switchStyle"].nil?
  # Whether battle animations are shown
  battle.showAnims = ($PokemonSystem.battlescene==0)
  battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
  # Terrain
  battle.defaultTerrain = battleRules["defaultTerrain"] if !battleRules["defaultTerrain"].nil?
  # Weather
  if battleRules["defaultWeather"].nil?
    case $game_screen.weather_type
    when PBFieldWeather::Rain, PBFieldWeather::HeavyRain, PBFieldWeather::Storm
      battle.defaultWeather = PBWeather::Rain
    when PBFieldWeather::Snow, PBFieldWeather::Blizzard
      battle.defaultWeather = PBWeather::Hail
    when PBFieldWeather::Sandstorm
      battle.defaultWeather = PBWeather::Sandstorm
    when PBFieldWeather::Sun
      battle.defaultWeather = PBWeather::Sun
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
  else
    back = pbGetMetadata($game_map.map_id,MetadataBattleBack)
    backdrop = back if back && back!=""
  end
  backdrop = "indoor1" if !backdrop
  battle.backdrop = backdrop
  # Choose a name for bases depending on environment
  if battleRules["base"].nil?
    case battle.environment
    when PBEnvironment::Grass, PBEnvironment::TallGrass,
         PBEnvironment::ForestGrass;                            base = "grass"
#    when PBEnvironment::Rock;                                   base = "rock"
    when PBEnvironment::Sand;                                   base = "sand"
    when PBEnvironment::MovingWater, PBEnvironment::StillWater; base = "water"
    when PBEnvironment::Puddle;                                 base = "puddle"
    when PBEnvironment::Ice;                                    base = "ice"
    end
  else
    base = battleRules["base"]
  end
  battle.backdropBase = base if base
  # Time of day
  if pbGetMetadata($game_map.map_id,MetadataEnvironment)==PBEnvironment::Cave
    battle.time = 2   # This makes Dusk Balls work properly in caves
  elsif TIME_SHADING
    timeNow = pbGetTimeNow
    if PBDayNight.isNight?(timeNow);      battle.time = 2
    elsif PBDayNight.isEvening?(timeNow); battle.time = 1
    else;                                 battle.time = 0
    end
  end
end

# Used to determine the environment in battle, and also the form of Burmy/
# Wormadam.
def pbGetEnvironment
  ret = pbGetMetadata($game_map.map_id,MetadataEnvironment)
  ret = PBEnvironment::None if !ret
  if $PokemonTemp.encounterType==EncounterTypes::OldRod ||
     $PokemonTemp.encounterType==EncounterTypes::GoodRod ||
     $PokemonTemp.encounterType==EncounterTypes::SuperRod
    terrainTag = pbFacingTerrainTag
  else
    terrainTag = $game_player.terrain_tag
  end
  case terrainTag
  when PBTerrain::Grass, PBTerrain::SootGrass
    ret = (ret==PBEnvironment::Forest) ? PBEnvironment::ForestGrass : PBEnvironment::Grass
  when PBTerrain::TallGrass
    ret = (ret==PBEnvironment::Forest) ? PBEnvironment::ForestGrass : PBEnvironment::TallGrass
  when PBTerrain::Rock;                        ret = PBEnvironment::Rock
  when PBTerrain::Sand;                        ret = PBEnvironment::Sand
  when PBTerrain::DeepWater, PBTerrain::Water; ret = PBEnvironment::MovingWater
  when PBTerrain::StillWater;                  ret = PBEnvironment::StillWater
  when PBTerrain::Puddle;                      ret = PBEnvironment::Puddle
  when PBTerrain::Ice;                         ret = PBEnvironment::Ice
  end
  return ret
end

Events.onStartBattle += proc { |_sender|
  # Record current levels of Pokémon in party, to see if they gain a level
  # during battle and may need to evolve afterwards
  $PokemonTemp.evolutionLevels = []
  for i in 0...$Trainer.party.length
    $PokemonTemp.evolutionLevels[i] = $Trainer.party[i].level
  end
}

def pbCanDoubleBattle?
  return $PokemonGlobal.partner || $Trainer.ablePokemonCount>=2
end

def pbCanTripleBattle?
  return true if $Trainer.ablePokemonCount>=3
  return $PokemonGlobal.partner && $Trainer.ablePokemonCount>=2
end

#===============================================================================
# Start a wild battle
#===============================================================================
def pbWildBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.ablePokemonCount==0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $Trainer.pokemonCount>0
    pbSet(outcomeVar,1)   # Treat it as a win
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
    return 1   # Treat it as a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate wild Pokémon based on the species and level
  foeParty = []
  sp = nil
  for arg in args
    if arg.is_a?(PokeBattle_Pokemon)
      foeParty.push(arg)
    elsif arg.is_a?(Array)
      species = getID(PBSpecies,arg[0])
      pkmn = pbGenerateWildPokemon(species,arg[1])
      foeParty.push(pkmn)
    elsif sp
      species = getID(PBSpecies,sp)
      pkmn = pbGenerateWildPokemon(species,arg)
      foeParty.push(pkmn)
      sp = nil
    else
      sp = arg
    end
  end
  raise _INTL("Expected a level after being given {1}, but one wasn't found.",sp) if sp
  # Calculate who the trainers and their party are
  playerTrainers    = [$Trainer]
  playerParty       = $Trainer.party
  playerPartyStarts = [0]
  if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && foeParty.length>1
    ally = PokeBattle_Trainer.new($PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    ally.id    = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    playerTrainers.push(ally)
    playerParty = []
    $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,nil)
  battle.party1starts = playerPartyStarts
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $PokemonTemp.clearBattleRules
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty),(foeParty.length==1) ? 0 : 2,foeParty) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision,canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    4 - Wild Pokémon was caught
  #    5 - Draw
  pbSet(outcomeVar,decision)
  return decision
end

#===============================================================================
# Standard methods that start a wild battle of various sizes
#===============================================================================
# Used when walking in tall grass, hence the additional code.
def pbWildBattle(species, level, outcomeVar=1, canRun=true, canLose=false)
  species = getID(PBSpecies,species)
  # Potentially call a different pbWildBattle-type method instead (for roaming
  # Pokémon, Safari battles, Bug Contest battles)
  handled = [nil]
  Events.onWildBattleOverride.trigger(nil,species,level,handled)
  return handled[0] if handled[0]!=nil
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  # Perform the battle
  decision = pbWildBattleCore(species, level)
  # Used by the Poké Radar to update/break the chain
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end

def pbDoubleWildBattle(species1, level1, species2, level2,
                       outcomeVar=1, canRun=true, canLose=false)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  setBattleRule("double")
  # Perform the battle
  decision = pbWildBattleCore(species1, level1, species2, level2)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end

def pbTripleWildBattle(species1, level1, species2, level2, species3, level3,
                       outcomeVar=1, canRun=true, canLose=false)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  setBattleRule("triple")
  # Perform the battle
  decision = pbWildBattleCore(species1, level1, species2, level2, species3, level3)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end

#===============================================================================
# Start a trainer battle
#===============================================================================
def pbTrainerBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.ablePokemonCount==0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    pbMessage(_INTL("AFTER WINNING...")) if $DEBUG && $Trainer.ablePokemonCount>0
    pbSet(outcomeVar,($Trainer.ablePokemonCount==0) ? 0 : 1)   # Treat it as undecided/a win
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
    return ($Trainer.ablePokemonCount==0) ? 0 : 1   # Treat it as undecided/a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate trainers and their parties based on the arguments given
  foeTrainers    = []
  foeItems       = []
  foeEndSpeeches = []
  foeParty       = []
  foePartyStarts = []
  for arg in args
    raise _INTL("Expected an array of trainer data, got {1}.",arg) if !arg.is_a?(Array)
    if arg[0].is_a?(PokeBattle_Trainer)
      # [trainer object, party, end speech, items]
      foeTrainers.push(arg[0])
      foePartyStarts.push(foeParty.length)
      arg[1].each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg[2])
      foeItems.push(arg[3])
    else
      # [trainer type, trainer name, ID, speech (optional)]
      trainer = pbLoadTrainer(arg[0],arg[1],arg[2])
      pbMissingTrainer(arg[0],arg[1],arg[2]) if !trainer
      return 0 if !trainer
      Events.onTrainerPartyLoad.trigger(nil,trainer)
      foeTrainers.push(trainer[0])
      foePartyStarts.push(foeParty.length)
      trainer[2].each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg[3] || trainer[3])
      foeItems.push(trainer[1])
    end
  end
  # Calculate who the player trainer(s) and their party are
  playerTrainers    = [$Trainer]
  playerParty       = $Trainer.party
  playerPartyStarts = [0]
  if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && foeParty.length>1
    ally = PokeBattle_Trainer.new($PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    ally.id    = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    playerTrainers.push(ally)
    playerParty = []
    $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,foeTrainers)
  battle.party1starts = playerPartyStarts
  battle.party2starts = foePartyStarts
  battle.items        = foeItems
  battle.endSpeeches  = foeEndSpeeches
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $PokemonTemp.clearBattleRules
  # End the trainer intro music
  Audio.me_stop
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetTrainerBattleBGM(foeTrainers),(battle.singleBattle?) ? 1 : 3,foeTrainers) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision,canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    5 - Draw
  pbSet(outcomeVar,decision)
  return decision
end

#===============================================================================
# Standard methods that start a trainer battle of various sizes
#===============================================================================
# Used by most trainer events, which can be positioned in such a way that
# multiple trainer events spot the player at once. The extra code in this method
# deals with that case and can cause a double trainer battle instead.
def pbTrainerBattle(trainerID, trainerName, endSpeech=nil,
                    doubleBattle=false, trainerPartyID=0, canLose=false, outcomeVar=1)
  # If there is another NPC trainer who spotted the player at the same time, and
  # it is possible to have a double battle (the player has 2+ able Pokémon or
  # has a partner trainer), then record this first NPC trainer into
  # $PokemonTemp.waitingTrainer and end this method. That second NPC event will
  # then trigger and cause the battle to happen against this first trainer and
  # themselves.
  if !$PokemonTemp.waitingTrainer && pbMapInterpreterRunning? &&
     ($Trainer.ablePokemonCount>1 ||
     ($Trainer.ablePokemonCount>0 && $PokemonGlobal.partner))
    thisEvent = pbMapInterpreter.get_character(0)
    # Find all other triggered trainer events
    triggeredEvents = $game_player.pbTriggeredTrainerEvents([2],false)
    otherEvent = []
    for i in triggeredEvents
      next if i.id==thisEvent.id
      next if $game_self_switches[[$game_map.map_id,i.id,"A"]]
      otherEvent.push(i)
    end
    # Load the trainer's data, and call an event which might modify it
    trainer = pbLoadTrainer(trainerID,trainerName,trainerPartyID)
    pbMissingTrainer(trainerID,trainerName,trainerPartyID) if !trainer
    return false if !trainer
    Events.onTrainerPartyLoad.trigger(nil,trainer)
    # If there is exactly 1 other triggered trainer event, and this trainer has
    # 6 or fewer Pokémon, record this trainer for a double battle caused by the
    # other triggered trainer event
    if otherEvent.length==1 && trainer[2].length<=6
      $PokemonTemp.waitingTrainer = [trainer,endSpeech || trainer[3],thisEvent.id]
      return false
    end
  end
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  setBattleRule("double") if doubleBattle || $PokemonTemp.waitingTrainer
  # Perform the battle
  if $PokemonTemp.waitingTrainer
    waitingTrainer = $PokemonTemp.waitingTrainer
    decision = pbTrainerBattleCore(
       [waitingTrainer[0][0],waitingTrainer[0][2],waitingTrainer[1],waitingTrainer[0][1]],
       [trainerID,trainerName,trainerPartyID,endSpeech]
    )
  else
    decision = pbTrainerBattleCore([trainerID,trainerName,trainerPartyID,endSpeech])
  end
  # Finish off the recorded waiting trainer, because they have now been battled
  if decision==1 && $PokemonTemp.waitingTrainer   # Win
    pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[2],"A",true)
  end
  $PokemonTemp.waitingTrainer = nil
  # Return true if the player won the battle, and false if any other result
  return (decision==1)
end

def pbDoubleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
                          trainerID2, trainerName2, trainerPartyID2=0, endSpeech2=nil,
                          canLose=false, outcomeVar=1)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  setBattleRule("double")
  # Perform the battle
  decision = pbTrainerBattleCore(
     [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
     [trainerID2,trainerName2,trainerPartyID2,endSpeech2]
  )
  # Return true if the player won the battle, and false if any other result
  return (decision==1)
end

def pbTripleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
                          trainerID2, trainerName2, trainerPartyID2, endSpeech2,
                          trainerID3, trainerName3, trainerPartyID3=0, endSpeech3=nil,
                          canLose=false, outcomeVar=1)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  setBattleRule("triple")
  # Perform the battle
  decision = pbTrainerBattleCore(
     [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
     [trainerID2,trainerName2,trainerPartyID2,endSpeech2],
     [trainerID3,trainerName3,trainerPartyID3,endSpeech3]
  )
  # Return true if the player won the battle, and false if any other result
  return (decision==1)
end

#===============================================================================
# After battles
#===============================================================================
def pbAfterBattle(decision,canLose)
  $Trainer.party.each do |pkmn|
    pkmn.statusCount = 0 if pkmn.status==PBStatuses::POISON   # Bad poison becomes regular
    pkmn.makeUnmega
    pkmn.makeUnprimal
    # Morpeko
    if pkmn.species == isConst?(pkmn.species,PBSpecies,:MORPEKO) || pkmn.form!=0
      pkmn.form = 0
    end
  end
  if $PokemonGlobal.partner
    pbHealAll
    $PokemonGlobal.partner[3].each do |pkmn|
      pkmn.heal
      pkmn.makeUnmega
      pkmn.makeUnprimal
    end
  end
  if decision==2 || decision==5   # if loss or draw
    if canLose
      $Trainer.party.each { |pkmn| pkmn.heal }
      (Graphics.frame_rate/4).times { Graphics.update }
    end
  end
  Events.onEndBattle.trigger(nil,decision,canLose)
end

Events.onEndBattle += proc { |_sender,e|
  decision = e[0]
  canLose  = e[1]
  if NEWEST_BATTLE_MECHANICS || (decision!=2 && decision!=5)   # not a loss or a draw
    if $PokemonTemp.evolutionLevels
      pbEvolutionCheck($PokemonTemp.evolutionLevels)
      $PokemonTemp.evolutionLevels = nil
    end
  end
  case decision
  when 1, 4   # Win, capture
    $Trainer.pokemonParty.each do |pkmn|
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

def pbEvolutionCheck(currentLevels)
  for i in 0...currentLevels.length
    pkmn = $Trainer.party[i]
    next if !pkmn || (pkmn.hp==0 && !NEWEST_BATTLE_MECHANICS)
    next if currentLevels[i] && pkmn.level==currentLevels[i]
    newSpecies = pbCheckEvolution(pkmn)
    next if newSpecies<=0
    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pkmn,newSpecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
end

def pbDynamicItemList(*args)
  ret = []
  for i in 0...args.length
    next if !hasConst?(PBItems,args[i])
    ret.push(getConst(PBItems,args[i].to_sym))
  end
  return ret
end

# Try to gain an item after a battle if a Pokemon has the ability Pickup.
def pbPickup(pkmn)
  return if pkmn.egg? || !pkmn.hasAbility?(:PICKUP)
  return if pkmn.hasItem?
  return unless rand(100)<10   # 10% chance
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
  return if pickupList.length<18
  return if pickupListRare.length<11
  # Generate a pool of items depending on the Pokémon's level
  items = []
  pkmnLevel = [100,pkmn.level].min
  itemStartIndex = (pkmnLevel-1)/10
  itemStartIndex = 0 if itemStartIndex<0
  for i in 0...9
    items.push(pickupList[itemStartIndex+i])
  end
  for i in 0...2
    items.push(pickupListRare[itemStartIndex+i])
  end
  # Probabilities of choosing each item in turn from the pool
  chances = [30,10,10,10,10,10,10,4,4,1,1]   # Needs to be 11 numbers
  chanceSum = 0
  chances.each { |c| chanceSum += c }
  # Randomly choose an item from the pool to give to the Pokémon
  rnd = rand(chanceSum)
  cumul = 0
  chances.each_with_index do |c,i|
    cumul += c
    next if rnd>=cumul
    pkmn.setItem(items[i])
    break
  end
end

# Try to gain a Honey item after a battle if a Pokemon has the ability Honey Gather.
def pbHoneyGather(pkmn)
  return if pkmn.egg? || !pkmn.hasAbility?(:HONEYGATHER)
  return if pkmn.hasItem?
  return if !hasConst?(PBItems,:HONEY)
  chance = 5+((pkmn.level-1)/10)*5
  return unless rand(100)<chance
  pkmn.setItem(:HONEY)
end
