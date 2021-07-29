
##############################################

#PokemonEncounters

module EncounterTypes
  Land = 0
  Cave = 1
  Water = 2
  RockSmash = 3
  OldRod = 4
  GoodRod = 5
  SuperRod = 6
  HeadbuttLow = 7
  HeadbuttHigh = 8
  LandMorning = 9
  LandDay = 10
  LandNight = 11
  BugContest = 12
  Names = [
      "Land",
      "Cave",
      "Water",
      "RockSmash",
      "OldRod",
      "GoodRod",
      "SuperRod",
      "HeadbuttLow",
      "HeadbuttHigh",
      "LandMorning",
      "LandDay",
      "LandNight",
      "BugContest"
  ]
  EnctypeChances = [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  ]
  EnctypeDensities = [25, 10, 10, 0, 0, 0, 0, 0, 0, 25, 25, 25, 25]
  EnctypeCompileDens = [1, 2, 3, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1]
end


class PokemonEncounters
  def initialize
    @enctypes = []
    @density = nil
  end

  def stepcount
    return @stepcount
  end

  def clearStepCount
    @stepcount = 0
  end

  def hasEncounter?(enc)
    return false if @density == nil || enc < 0
    return @enctypes[enc] ? true : false
  end

  def isCave?
    return false if @density == nil
    return @enctypes[EncounterTypes::Cave] ? true : false
  end

  def isGrass?
    return false if @density == nil
    return (@enctypes[EncounterTypes::Land] ||
        @enctypes[EncounterTypes::LandMorning] ||
        @enctypes[EncounterTypes::LandDay] ||
        @enctypes[EncounterTypes::LandNight] ||
        @enctypes[EncounterTypes::BugContest]) ? true : false
  end

  def isRegularGrass?
    return false if @density == nil
    return (@enctypes[EncounterTypes::Land] ||
        @enctypes[EncounterTypes::LandMorning] ||
        @enctypes[EncounterTypes::LandDay] ||
        @enctypes[EncounterTypes::LandNight]) ? true : false
  end

  def isWater?
    return false if @density == nil
    return @enctypes[EncounterTypes::Water] ? true : false
  end

  def pbEncounterType
    if $PokemonGlobal && $PokemonGlobal.surfing
      return EncounterTypes::Water
    elsif self.isCave?
      return EncounterTypes::Cave
    elsif self.isGrass?
      time = pbGetTimeNow
      enctype = EncounterTypes::Land
      enctype = EncounterTypes::LandNight if self.hasEncounter?(EncounterTypes::LandNight) && PBDayNight.isNight?(time)
      enctype = EncounterTypes::LandDay if self.hasEncounter?(EncounterTypes::LandDay) && PBDayNight.isDay?(time)
      enctype = EncounterTypes::LandMorning if self.hasEncounter?(EncounterTypes::LandMorning) && PBDayNight.isMorning?(time)
      if pbInBugContest? && self.hasEncounter?(EncounterTypes::BugContest)
        enctype = EncounterTypes::BugContest
      end
      return enctype
    end
    return -1
  end


  def isEncounterPossibleHere?
    if $PokemonGlobal.surfing
      return true
    elsif PBTerrain.isIce?(pbGetTerrainTag($game_player))
      return false
    elsif PBTerrain.isWaterCurrent?(pbGetTerrainTag($game_player))
      return false
    elsif self.isCave?
      return true
    elsif self.isGrass?
      return PBTerrain.isGrass?($game_map.terrain_tag($game_player.x,$game_player.y))
    end
    return false
  end


  def setup(mapID)
    @density = nil
    @stepcount = 0
    @enctypes = []
    begin
      data = load_data("Data/encounters.dat")
      if data.is_a?(Hash) && data[mapID]
        @density = data[mapID][0]
        @enctypes = data[mapID][1]
      else
        @density = nil
        @enctypes = []
      end
    rescue
      @density = nil
      @enctypes = []
    end
  end

  def pbMapHasEncounter?(mapID, enctype)
    data = load_data("Data/encounters.dat")
    if data.is_a?(Hash) && data[mapID]
      enctypes = data[mapID][1]
      density = data[mapID][0]
    else
      return false
    end
    return false if density == nil || enctype < 0
    return enctypes[enctype] ? true : false
  end

  def pbMapEncounter(mapID, enctype)
    if enctype < 0 || enctype > EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    data = load_data("Data/encounters.dat")
    if data.is_a?(Hash) && data[mapID]
      enctypes = data[mapID][1]
    else
      return nil
    end
    return nil if enctypes[enctype] == nil
    chances = EncounterTypes::EnctypeChances[enctype]
    chancetotal = 0
    chances.each { |a| chancetotal += a }
    rnd = rand(chancetotal)
    chosenpkmn = 0
    chance = 0
    for i in 0...chances.length
      chance += chances[i]
      if rnd < chance
        chosenpkmn = i
        break
      end
    end
    encounter = enctypes[enctype][chosenpkmn]
    level = encounter[1] + rand(1 + encounter[2] - encounter[1])
    return [encounter[0], level]
  end

  def pbEncounteredPokemon(enctype, tries = 1)
    if enctype < 0 || enctype > EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @enctypes[enctype] == nil
    chances = EncounterTypes::EnctypeChances[enctype]
    chancetotal = 0
    chances.each { |a| chancetotal += a }
    rnd = 0
    tries.times do
      r = rand(chancetotal)
      rnd = r if rnd < r
    end
    chosenpkmn = 0
    chance = 0
    for i in 0...chances.length
      chance += chances[i]
      if rnd < chance
        chosenpkmn = i
        break
      end
    end

    encounter = @enctypes[enctype][chosenpkmn]

    return nil if !encounter
    level = encounter[1] + rand(1 + encounter[2] - encounter[1])

    #regular mode
    return [encounter[0], level]
  end


  def pbGenerateEncounter(enctype)
    if enctype < 0 || enctype > EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @density == nil
    return nil if @density[enctype] == 0 || !@density[enctype]
    return nil if @enctypes[enctype] == nil
    @stepcount += 1
    return nil if @stepcount <= 3 # Check three steps after battle ends
    encount = @density[enctype] * 16
    if $PokemonGlobal.bicycle
      encount = (encount * 4 / 5)
    end
    if $PokemonMap.blackFluteUsed
      encount /= 2
    end
    if $PokemonMap.whiteFluteUsed
      encount = (encount * 3 / 2)
    end
    if $Trainer.party.length > 0 && !$Trainer.party[0].isEgg?
      if isConst?($Trainer.party[0].item, PBItems, :CLEANSETAG)
        encount = (encount * 2 / 3)
      elsif isConst?($Trainer.party[0].item, PBItems, :PUREINCENSE)
        encount = (encount * 2 / 3)
      else
        # Ignore ability effects if an item effect applies
        if isConst?($Trainer.party[0].ability, PBAbilities, :STENCH)
          encount = (encount / 2)
        elsif isConst?($Trainer.party[0].ability, PBAbilities, :WHITESMOKE)
          encount = (encount / 2)
        elsif isConst?($Trainer.party[0].ability, PBAbilities, :QUICKFEET)
          encount = (encount / 2)
        elsif isConst?($Trainer.party[0].ability, PBAbilities, :SNOWCLOAK) &&
            $game_screen.weather_type == 3
          encount = (encount / 2)
        elsif isConst?($Trainer.party[0].ability, PBAbilities, :SANDVEIL) &&
            $game_screen.weather_type == 4
          encount = (encount / 2)
        elsif isConst?($Trainer.party[0].ability, PBAbilities, :SWARM)
          encount = (encount * 3 / 2)
        elsif isConst?($Trainer.party[0].ability, PBAbilities, :ILLUMINATE)
          encount = (encount * 2)
        elsif isConst?($Trainer.party[0].ability, PBAbilities, :ARENATRAP)
          encount = (encount * 2)
        elsif isConst?($Trainer.party[0].ability, PBAbilities, :NOGUARD)
          encount = (encount * 2)
        end
      end
    end
    return nil if rand(180 * 16) >= encount
    encpoke = pbEncounteredPokemon(enctype)

    if $Trainer.party.length > 0 && !$Trainer.party[0].isEgg?
      if encpoke && isConst?($Trainer.party[0].ability, PBAbilities, :INTIMIDATE) &&
          encpoke[1] <= $Trainer.party[0].level - 5 && rand(2) == 0
        encpoke = nil
      end
      if encpoke && isConst?($Trainer.party[0].ability, PBAbilities, :KEENEYE) &&
          encpoke[1] <= $Trainer.party[0].level - 5 && rand(2) == 0
        encpoke = nil
      end
    end
    return encpoke
  end
end


################################################################
############ PokemonField
###SCRIPTEDIT1

#####################################################

def pbWildBattle(species, level, outcomeVar=1, canRun=true, canLose=false)
  species = ($game_switches[955] && species <= NB_POKEMON) ? $PokemonGlobal.psuedoBSTHash[species] : species
  # Potentially call a different pbWildBattle-type method instead (for roaming
  # Pokémon, Safari battles, Bug Contest battles)
  handled = [nil]
  Events.onWildBattleOverride.trigger(nil,species,level,handled)
  return handled[0] if handled[0]!=nil
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  battle.rules["alwaysflee"] if $game_switches[866]

  # Perform the battle
  decision = pbWildBattleCore(species, level)
  # Used by the Poké Radar to update/break the chain
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end

def pbWildBattleId(species, level, outcomeVar=1, canRun=true, canLose=false)
  handled = [nil]
  Events.onWildBattleOverride.trigger(nil,species,level,handled)
  return handled[0] if handled[0]!=nil
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  battle.rules["alwaysflee"] if $game_switches[866]

  # Perform the battle
  decision = pbWildBattleCore(species, level)
  # Used by the Poké Radar to update/break the chain
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end


def pbDoubleWildBattle(species1, level1, species2, level2, variable = nil, canescape = true, canlose = false)
  if (Input.press?(Input::CTRL) && $DEBUG) || $Trainer.pokemonCount == 0
    if $Trainer.pokemonCount > 0
      Kernel.pbMessage(_INTL("SKIPPING BATTLE..."))
    end
    pbSet(variable, 1)
    $PokemonGlobal.nextBattleBGM = nil
    $PokemonGlobal.nextBattleME = nil
    $PokemonGlobal.nextBattleBack = nil
    return true
  end
  if species1.is_a?(String) || species1.is_a?(Symbol)
    species1 = getID(PBSpecies, species1)
  end
  if species2.is_a?(String) || species2.is_a?(Symbol)
    species2 = getID(PBSpecies, species2)
  end
  currentlevels = []
  for i in $Trainer.party
    currentlevels.push(i.level)
  end
  genwildpoke = pbGenerateWildPokemon(species1, level1)
  genwildpoke2 = pbGenerateWildPokemon(species2, level2)
  Events.onStartBattle.trigger(nil, genwildpoke)
  scene = pbNewBattleScene
  if $PokemonGlobal.partner
    othertrainer = PokeBattle_Trainer.new(
        $PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
    othertrainer.id = $PokemonGlobal.partner[2]
    othertrainer.party = $PokemonGlobal.partner[3]
    combinedParty = []
    for i in 0...$Trainer.party.length
      combinedParty[i] = $Trainer.party[i]
    end
    for i in 0...othertrainer.party.length
      combinedParty[6 + i] = othertrainer.party[i]
    end
    battle = PokeBattle_Battle.new(scene, combinedParty, [genwildpoke, genwildpoke2],
                                   [$Trainer, othertrainer], nil)
    battle.fullparty1 = true
  else
    battle = PokeBattle_Battle.new(scene, $Trainer.party, [genwildpoke, genwildpoke2],
                                   $Trainer, nil)
  end
  battle.internalbattle = true
  battle.doublebattle = battle.pbDoubleBattleAllowed?()
  battle.cantescape = !canescape
  pbPrepareBattle(battle)
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(species1)) {
    pbSceneStandby {
      decision = battle.pbStartBattle(canlose)
    }
    for i in $Trainer.party;
      (i.makeUnmega rescue nil);
    end
    if $PokemonGlobal.partner
      pbHealAll
      for i in $PokemonGlobal.partner[3]
        i.heal
        i.makeUnmega rescue nil
      end
    end
    if decision == 2 || decision == 5
      if canlose
        for i in $Trainer.party;
          i.heal;
        end
        for i in 0...10
          Graphics.update
        end
      else
        $game_system.bgm_unpause
        $game_system.bgs_unpause
        Kernel.pbStartOver
      end
    end
    Events.onEndBattle.trigger(nil, decision)
  }
  Input.update
  pbSet(variable, decision)
  return (decision != 2 && decision != 5)
end


def pbEvolutionCheck(currentlevels)
  # Check conditions for evolution
  for i in 0...currentlevels.length
    pokemon = $Trainer.party[i]
    if pokemon && (!currentlevels[i] || pokemon.level != currentlevels[i])
      newspecies = Kernel.pbCheckEvolution(pokemon)
      if newspecies > 0
        # Start evolution scene
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pokemon, newspecies)
        evo.pbEvolution
        evo.pbEndScreen
      end
    end
  end
end



def Kernel.getRoamingMap(roamingArrayPos)
  curmap = $PokemonGlobal.roamPosition[roamingArrayPos]
  mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
  text = mapinfos[curmap].name #,(curmap==$game_map.map_id) ? _INTL("(this map)") : "")
  return text
end


##EDITED HERE
#Retourne le pokemon de base
#param1 = int
#param2 = true pour body, false pour head
#return int du pokemon de base
def Kernel.getBasePokemonID(pokemon, body = true)
  cname = getConstantName(PBSpecies, pokemon) rescue nil
  return pokemon if pokemon <= NB_POKEMON
  return pokemon if cname == nil

  arr = cname.split(/[B,H]/)

  bod = arr[1]
  head = arr[2]

  return bod.to_i if body
  return head.to_i
end

def Kernel.setRocketPassword(variableNum)
  abilityIndex = rand(PBAbilities.maxValue - 1)
  speciesIndex = rand(PBSpecies.maxValue - 1)

  word1 = PBSpecies.getName(speciesIndex)
  word2 = PBAbilities.getName(abilityIndex)
  password = _INTL("{1}'s {2}", word1, word2)
  pbSet(variableNum, password)
end


class PokemonTemp
  attr_accessor :encounterType
  attr_accessor :evolutionLevels
end


def pbEncounter(enctype)
  if $PokemonGlobal.partner
    encounter1 = $PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter1
    encounter2 = $PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter2
    $PokemonTemp.encounterType = enctype
    pbDoubleWildBattle(encounter1[0], encounter1[1], encounter2[0], encounter2[1])
    $PokemonTemp.encounterType = -1
    return true
  else
    encounter = $PokemonEncounters.pbEncounteredPokemon(enctype)
    return false if !encounter
    $PokemonTemp.encounterType = enctype
    pbWildBattle(encounter[0], encounter[1])
    $PokemonTemp.encounterType = -1
    return true
  end
end

Events.onStartBattle += proc { |sender, e|
  $PokemonTemp.evolutionLevels = []
  for i in 0...$Trainer.party.length
    $PokemonTemp.evolutionLevels[i] = $Trainer.party[i].level
  end
}

Events.onEndBattle += proc { |sender, e|
  decision = e[0]
  if decision != 2 && decision != 5 # not a loss or a draw
    if $PokemonTemp.evolutionLevels
      pbEvolutionCheck($PokemonTemp.evolutionLevels)
      $PokemonTemp.evolutionLevels = nil
    end
  end
  if decision == 1
    for pkmn in $Trainer.party
      Kernel.pbPickup(pkmn)
      if isConst?(pkmn.ability, PBAbilities, :HONEYGATHER) && !pkmn.isEgg? && !pkmn.hasItem?
        if hasConst?(PBItems, :HONEY)
          chance = 5 + ((pkmn.level - 1) / 10) * 5
          pkmn.setItem(:HONEY) if rand(100) < chance
        end
      end
    end
  end
}


################################################################################
# Field movement
################################################################################


# juste utilisé dans les Fusion Encounters
# on return pas plus que 6 pq ca fait trop de fusion sinon
def getNbBadges
  nb_badges = 0
  if $game_switches[11]
    nb_badges = 6
  elsif $game_switches[10]
    nb_badges = 6
  elsif $game_switches[9]
    nb_badges = 6
  elsif $game_switches[8]
    nb_badges = 5
  elsif $game_switches[7]
    nb_badges = 4
  elsif $game_switches[6]
    nb_badges = 3
  elsif $game_switches[5]
    nb_badges = 2
  elsif $game_switches[4]
    nb_badges = 1
  end
  return nb_badges
end

def pbBattleOnStepTaken(repel = false)
  return if $Trainer.ablePokemonCount == 0
  encounterType = $PokemonEncounters.pbEncounterType
  return if encounterType < 0
  return if !$PokemonEncounters.isEncounterPossibleHere?
  $PokemonTemp.encounterType = encounterType
  encounter = $PokemonEncounters.pbGenerateEncounter(encounterType)
  encounter2 = $PokemonEncounters.pbEncounteredPokemon(encounterType)
  encounter3 = $PokemonEncounters.pbEncounteredPokemon(encounterType)
  encounter4 = $PokemonEncounters.pbEncounteredPokemon(encounterType)

  ###############
  #randomized mode edit
  if $game_switches[778] #wild poke random activated
    if $game_switches[956] && encounter != nil
      encounter = [$PokemonGlobal.psuedoBSTHash[encounter[0]], encounter[1]]
      encounter2 = [$PokemonGlobal.psuedoBSTHash[encounter2[0]], encounter2[1]]
      encounter3 = [$PokemonGlobal.psuedoBSTHash[encounter3[0]], encounter3[1]]
      encounter4 = [$PokemonGlobal.psuedoBSTHash[encounter4[0]], encounter4[1]]
    end
  end

  encounter = EncounterModifier.trigger(encounter)
  if $PokemonEncounters.pbCanEncounter?(encounter, repel)
    if !$PokemonTemp.forceSingleBattle && !pbInSafari? && ($PokemonGlobal.partner ||
        ($Trainer.ablePokemonCount > 1 && PBTerrain.isDoubleWildBattle?(pbGetTerrainTag) && rand(100) < 30))
      encounter2 = $PokemonEncounters.pbEncounteredPokemon(encounterType)
      encounter2 = EncounterModifier.trigger(encounter2)
      pbDoubleWildBattle(encounter[0], encounter[1], encounter2[0], encounter2[1])
    else
      if $game_switches[113] #Cyberspace map
        poryfuse = rand(251) * NB_POKEMON + 137
        pbWildBattle(poryfuse, 20)
      else
        if isFusedEncounter() ##fused
          if encounter2[0] == encounter[0]
            pbWildBattle(encounter[0], encounter[1])
          else
            fusedID = (encounter[0] * NB_POKEMON) + encounter2[0]
            pbWildBattle(fusedID, encounter[1])
          end
          $game_switches[37] = false
        else
          #unfused
          pbWildBattle(encounter[0], encounter[1])
        end
      end
    end
    $PokemonTemp.encounterType = -1
    $PokemonTemp.encounterTriggered = true
  end
  $PokemonTemp.forceSingleBattle = false
  EncounterModifier.triggerEncounterEnd
end


def isFusedEncounter()
  return false if $game_switches[953]
  return true if isFusionForced?()
  chance = pbGet(210) == 0 ? 5 : pbGet(210)
  return ($game_switches[35] && rand(chance) == 0)
end

def isFusionForced?()
  return false if $game_switches[953] #wild poke to fusions
  return $game_switches[37] || $game_switches[828]
end

#def isFusedEncounter()
#chance = 10-nb_badges)/2
#return $game_switches[35] && rand((10-nb_badges)/2)==0) || $game_switches[37]
#return ($game_switches[35] && rand(chance)==0) || $game_switches[37]
#end


################################################################################
# Fishing
################################################################################
def pbItemFishing()
  #ITEM
  items = [PBItems::PEARL,
           PBItems::OLDBOOT,
           PBItems::OLDBOOT,
           PBItems::OLDBOOT,
           PBItems::OLDBOOT,
           PBItems::WATERGEM,
           PBItems::OLDBOOT,
           PBItems::WATERGEM
  ]
  Kernel.pbItemBall(items[rand(items.size)], 1, nil, false)
  Kernel.pbDisposeMessageWindow(msgwindow)
end


def pbFishing(hasencounter, rodtype = 1)
  bitechance = 20 + (25 * rodtype) # 45, 70, 95
  if $Trainer.party.length > 0 && !$Trainer.party[0].isEgg?
    bitechance *= 2 if isConst?($Trainer.party[0].ability, PBAbilities, :STICKYHOLD)
    bitechance *= 2 if isConst?($Trainer.party[0].ability, PBAbilities, :SUCTIONCUPS)
  end
  hookchance = 100
  oldpattern = $game_player.fullPattern
  pbFishingBegin
  msgwindow = Kernel.pbCreateMessageWindow
  loop do
    time = 2 + rand(10)
    message = ""
    time.times do
      message += ".  "
    end
    if pbWaitMessage(msgwindow, time)
      pbFishingEnd
      $game_player.setDefaultCharName(nil, oldpattern)
      Kernel.pbMessageDisplay(msgwindow, _INTL("Not even a nibble..."))
      Kernel.pbDisposeMessageWindow(msgwindow)
      pbFishingEnd
      $game_player.setDefaultCharName(nil, oldpattern)
      return false
    end

    if rand(100) < bitechance && hasencounter
      frames = rand(21) + 20
      if !pbWaitForInput(msgwindow, message + _INTL("\r\nOh!  A bite!"), frames)
        pbFishingEnd
        $game_player.setDefaultCharName(nil, oldpattern)
        Kernel.pbMessageDisplay(msgwindow, _INTL("The Pokémon got away..."))
        Kernel.pbDisposeMessageWindow(msgwindow)
        return false
      end

      if rand((rodtype) * 4) < 1
        #ITEM
        items = [PBItems::PEARL,
                 PBItems::OLDBOOT,
                 PBItems::OLDBOOT,
                 PBItems::OLDBOOT,
                 PBItems::OLDBOOT,
                 PBItems::WATERGEM,
                 PBItems::PEARL,
                 PBItems::WATERGEM
        ]
        Kernel.pbItemBall(items[rand(items.size)], 1, nil, false)
        Kernel.pbDisposeMessageWindow(msgwindow)
        pbFishingEnd
        $game_player.setDefaultCharName(nil, oldpattern)
        return false
      end
      if rand(100) < hookchance || FISHINGAUTOHOOK
        Kernel.pbMessageDisplay(msgwindow, _INTL("A Pokémon is on the hook!"))
        Kernel.pbDisposeMessageWindow(msgwindow)
        pbFishingEnd
        $game_player.setDefaultCharName(nil, oldpattern)
        return true
      end
      #      bitechance+=15
      #      hookchance+=15
    else
      pbFishingEnd
      $game_player.setDefaultCharName(nil, oldpattern)
      Kernel.pbMessageDisplay(msgwindow, _INTL("Not even a nibble..."))
      Kernel.pbDisposeMessageWindow(msgwindow)
      return false
    end

  end
  Kernel.pbDisposeMessageWindow(msgwindow)
  return false
end


def Kernel.pbConvertDexPokemon(species)
  pokeArray = []
  convertedArray = []
  for i in 1..PBSpecies.maxValue - 6
    pokeArray.push(i)
  end
  name = PBSpecies.getName(species)
  i = 0
  for poke in pokeArray
    i += 1

    if i % 2 == 0
      n = (i.to_f / PBSpecies.maxValue) * 100
      Kernel.pbMessage(_INTL("\\ts[]Converting Pokémon to {1}...\\n {2}/{3}\\^", name, poke, PBSpecies.maxValue))
    end

    body = (poke / NB_POKEMON).round
    # p2 = pf - (NB_POKEMON*p1)

    head = species
    newSpecies = (body * NB_POKEMON) + head
    convertedArray.push(newSpecies)
  end
  $PokemonGlobal.psuedoBSTHash = convertedArray
end


################################################################################
# Gaining items
################################################################################
def Kernel.pbItemBall(item, quantity = 1, plural = nil, canRandom = true)
  if item.is_a?(String) || item.is_a?(Symbol)
    item = getID(PBItems, item)
  end
  item = pbGetRandomItem(item) if canRandom #fait rien si pas activé


  return false if !item || item <= 0 || quantity < 1
  itemname = PBItems.getName(item)
  pocket = pbGetPocket(item)
  if $PokemonBag.pbStoreItem(item, quantity) # If item can be picked up
    if $ItemData[item][ITEMUSE] == 3 || $ItemData[item][ITEMUSE] == 4
      Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found \\c[1]{2}\\c[0]!\\nIt contained \\c[1]{3}\\c[0].\\wtnp[30]",
                             $Trainer.name, itemname, PBMoves.getName($ItemData[item][ITEMMACHINE])))
      Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
                             $Trainer.name, itemname, PokemonBag.pocketNames()[pocket]))
    elsif isConst?(item, PBItems, :LEFTOVERS)
      Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found some \\c[1]{2}\\c[0]!\\wtnp[30]",
                             $Trainer.name, itemname))
      Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
                             $Trainer.name, itemname, PokemonBag.pocketNames()[pocket]))
    else
      if quantity > 1
        if plural
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found {2} \\c[1]{3}\\c[0]!\\wtnp[30]",
                                 $Trainer.name, quantity, plural))
          Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
                                 $Trainer.name, plural, PokemonBag.pocketNames()[pocket]))
        else
          Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found {2} \\c[1]{3}s\\c[0]!\\wtnp[30]",
                                 $Trainer.name, quantity, itemname))
          Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}s\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
                                 $Trainer.name, itemname, PokemonBag.pocketNames()[pocket]))
        end
      else
        Kernel.pbMessage(_INTL("\\se[itemlevel]{1} found one \\c[1]{2}\\c[0]!\\wtnp[30]",
                               $Trainer.name, itemname))
        Kernel.pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0]\r\nin the <icon=bagPocket#{pocket}>\\c[1]{3}\\c[0] Pocket.",
                               $Trainer.name, itemname, PokemonBag.pocketNames()[pocket]))
      end
    end
    return true
  else
    # Can't add the item
    if $ItemData[item][ITEMUSE] == 3 || $ItemData[item][ITEMUSE] == 4
      Kernel.pbMessage(_INTL("{1} found \\c[1]{2}\\c[0]!\\wtnp[20]",
                             $Trainer.name, itemname))
    elsif isConst?(item, PBItems, :LEFTOVERS)
      Kernel.pbMessage(_INTL("{1} found some \\c[1]{2}\\c[0]!\\wtnp[20]",
                             $Trainer.name, itemname))
    else
      if quantity > 1
        if plural
          Kernel.pbMessage(_INTL("{1} found {2} \\c[1]{3}\\c[0]!\\wtnp[20]",
                                 $Trainer.name, quantity, plural))
        else
          Kernel.pbMessage(_INTL("{1} found {2} \\c[1]{3}s\\c[0]!\\wtnp[20]",
                                 $Trainer.name, quantity, itemname))
        end
      else
        Kernel.pbMessage(_INTL("{1} found one \\c[1]{2}\\c[0]!\\wtnp[20]",
                               $Trainer.name, itemname))
      end
    end
    Kernel.pbMessage(_INTL("Too bad... The Bag is full..."))
    return false
  end
end



def pbReceiveItem(item,quantity=1)
  item = getID(PBItems,item)
  isKeyItem = pbIsKeyItemOrHM?(item)
  itemColorId = isKeyItem ? 3 : 1
  return false if !item || item<=0 || quantity<1
  itemname = (quantity>1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
  pocket = pbGetPocket(item)
  meName = (pbIsKeyItem?(item)) ? "Key item get" : "Item get"
  if isConst?(item,PBItems,:LEFTOVERS)
    pbMessage(_INTL("\\me[{1}]You obtained some \\c[{3}]{2}\\c[0]!\\wtnp[30]",meName,itemname,itemColorId))
  elsif pbIsMachine?(item)   # TM or HM
    pbMessage(_INTL("\\me[{1}]You obtained \\c[{4}]{2} {3}\\c[0]!\\wtnp[30]",meName,itemname,PBMoves.getName(pbGetMachine(item)),itemColorId))
  elsif quantity>1
    pbMessage(_INTL("\\me[{1}]You obtained {2} \\c[{3}]{3}\\c[0]!\\wtnp[30]",meName,quantity,itemname,itemColorId))
  elsif itemname.starts_with_vowel?
    pbMessage(_INTL("\\me[{1}]You obtained an \\c[{3}]{2}\\c[0]!\\wtnp[30]",meName,itemname,itemColorId))
  else
    pbMessage(_INTL("\\me[{1}]You obtained a \\c[{3}]{2}\\c[0]!\\wtnp[30]",meName,itemname,itemColorId))
  end
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be added
    pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
                    itemname,pocket,PokemonBag.pocketNames()[pocket]))
    return true
  end
  return false   # Can't add the item
end


def pbGetRandomItem(item)
  #keyItem ou HM -> on randomize pas
  return item if $ItemData[item][ITEMTYPE] == 6 || $ItemData[item][ITEMUSE] == 4
  return item if isConst?(item, PBItems, :CELLBATTERY)
  return item if isConst?(item, PBItems, :MAGNETSTONE)

  #TM
  if ($ItemData[item][ITEMUSE] == 3)
    return $game_switches[959] ? pbGetRandomTM() : item
  end
  #item normal
  return item if !$game_switches[958]
  #berries
  return pbGetRandomBerry() if $ItemData[item][ITEMTYPE] == 5
  newItem = rand(PBItems.maxValue)
  #on veut pas de tm ou keyitem
  while ($ItemData[newItem][ITEMUSE] == 3 || $ItemData[newItem][ITEMUSE] == 4 || $ItemData[newItem][ITEMTYPE] == 6)
    newItem = rand(PBItems.maxValue)
  end
  return newItem
end

def pbGetRandomBerry()
  newItem = rand(PBItems.maxValue)
  while (!($ItemData[newItem][ITEMTYPE] == 5))
    newItem = rand(PBItems.maxValue)
  end
  return newItem
end

def pbGetRandomTM()
  newItem = rand(PBItems.maxValue)
  while (!($ItemData[newItem][ITEMUSE] == 3)) # || $ItemData[newItem][ITEMUSE]==4))
    newItem = rand(PBItems.maxValue)
  end
  return newItem
end


############################
### PokemonItemEffects
###SCRIPTEDIT3

###########################

#===============================================================================
# This script implements items included by default in Pokemon Essentials.
#===============================================================================

#===============================================================================
# UseFromBag handlers
# Return values: 0 = not used
#                1 = used, item not consumed
#                2 = close the Bag to use, item not consumed
#                3 = used, item consumed
#                4 = close the Bag to use, item consumed
#===============================================================================
def pbFRepel(item, steps)
  if $PokemonGlobal.repel > 0
    Kernel.pbMessage(_INTL("But the effects of a another Repel lingered from earlier."))
    return 0
  else
    Kernel.pbMessage(_INTL("{1} used the {2}.", $Trainer.name, PBItems.getName(item)))
    $PokemonGlobal.frepel = steps
    $game_switches[828] = true
    #$game_switches[35]=false
    return 3
  end
end

ItemHandlers::UseFromBag.add(:FUSIONREPEL, proc { |item| pbFRepel(item, 50) })

Events.onStepTaken += proc {
  if $game_player.terrain_tag != PBTerrain::Ice # Shouldn't count down if on ice
    if $PokemonGlobal.frepel > 0
      $PokemonGlobal.frepel -= 1
      if $PokemonGlobal.frepel <= 0
        Kernel.pbMessage(_INTL("Repel's effect wore off..."))
        $game_switches[828] = false
        #if !$game_switches[953] #randomize all to fusions
        #  $game_switches[35]=true
        #end
        ret = pbChooseItemFromList(_INTL("Do you want to use another Repel?"), 1,
                                   :FUSIONREPEL)
        pbUseItem($PokemonBag, ret) if ret > 0
      end
    end
  end
}

=begin
Events.onStepTaken+=proc {
   if $game_player.terrain_tag!=PBTerrain::Ice   # Shouldn't count down if on ice
     if $PokemonGlobal.repel>0
       $PokemonGlobal.repel-=1
       if $PokemonGlobal.repel<=0
         Kernel.pbMessage(_INTL("Repel's effect wore off..."))
         $game_switches[35]=true
         ret=pbChooseItemFromList(_INTL("Do you want to use another Repel?"),1,
            :REPEL,:SUPERREPEL,:MAXREPEL)
         pbUseItem($PokemonBag,ret) if ret>0
       end
     end
   end
}
=end


#===============================================================================
# UseInField handlers
#===============================================================================
ItemHandlers::UseFromBag.add(:DEBUGGER, proc { |item|

  Kernel.pbMessage(_INTL("[{1}]The debugger should ONLY be used if you are stuck somewhere because of a glitch.", GAME_VERSION_NUMBER))
  if Kernel.pbConfirmMessageSerious(_INTL("Innapropriate use of this item can lead to unwanted effects and make the game unplayable. Do you want to continue?"))
    $game_player.cancelMoveRoute()
    Kernel.pbStartOver(false)
    Kernel.pbMessage(_INTL("Please report the glitch on the Pokecommunity thread, on the game's subreddit or in the game's Discord channel."))
  end
})

ItemHandlers::UseFromBag.add(:MAGICBOOTS, proc { |item|
  if $DEBUG
    if Kernel.pbConfirmMessageSerious(_INTL("Take off the Magic Boots?"))
      $DEBUG = false
    end
  else
    if Kernel.pbConfirmMessageSerious(_INTL("Put on the Magic Boots?"))
      Kernel.pbMessage(_INTL("Debug mode is now active."))
      $game_switches[842] = true #got debug mode (for compatibility)
      $DEBUG = true
    end
  end
  next 1
})


ItemHandlers::UseFromBag.add(:DEMHARDMODE, proc { |item|
  if $game_switches[850]
    if Kernel.pbConfirmMessageSerious(_INTL("Take off the badge?"))
      if !$game_switches[313] #if not inside E4
        $game_switches[850] = false
        Kernel.pbMessage(_INTL("\PN took off the badge."))
        Kernel.pbMessage(_INTL("Hard Mode is now deactivated"))
      else
        Kernel.pbMessage(_INTL("You are not allowed to take off the badge while you're on the E4 challenge!"))
      end
    end
  else
    if Kernel.pbConfirmMessageSerious(_INTL("Wear the badge?"))
      Kernel.pbMessage(_INTL("\PN is now wearing the badge."))
      Kernel.pbMessage(_INTL("Gym Leaders, and the Elite 4 will now use their ultimate teams against you."))

      $game_switches[850] = true
    end
  end
  next 1
})

#===============================================================================
# BattleUseOnBattler handlers
#===============================================================================
ItemHandlers::BattleUseOnBattler.add(:SKINNYLATTE, proc { |item, battler, scene|
  playername = battler.battle.pbPlayer.name
  itemname = PBItems.getName(item)
  scene.pbDisplay(_INTL("{1} drank the {2}.", battler.name, itemname))
  if battler.pbCanIncreaseStatStage?(PBStats::SPEED, false) || battler.pbCanIncreaseStatStage?(PBStats::SPATK, false)
    battler.pbIncreaseStat(PBStats::SPEED, 4, true)
    return true
  else
    scene.pbDisplay(_INTL("But it had no effect!"))
    return false
  end
})

ItemHandlers::BattleUseOnBattler.add(:SHOOTER, proc { |item, battler, scene|
  playername = battler.battle.pbPlayer.name
  itemname = PBItems.getName(item)
  if battler.status != 0
    scene.pbDisplay(_INTL("{1} won't drink!", battler.name))
    return false
  end
  scene.pbDisplay(_INTL("{1} drank the {2}.", battler.name, itemname))
  if battler.pbCanIncreaseStatStage?(PBStats::SPEED, false) || battler.pbCanIncreaseStatStage?(PBStats::SPATK, false)
    battler.pbIncreaseStat(PBStats::SPEED, 1, true)
    battler.pbIncreaseStat(PBStats::SPATK, 2, true)
    if battler.effects[PBEffects::Confusion] != 0
      battler.status = PBStatuses::SLEEP
      scene.pbDisplay(_INTL("{1} fell asleep!", battler.name))
    else
      scene.pbDisplay(_INTL("{1} became confused!", battler.name))
      battler.effects[PBEffects::Confusion] = 3
    end
    return true
  else
    scene.pbDisplay(_INTL("But it had no effect!"))
    return false
  end
})

ItemHandlers::BattleUseOnBattler.add(:BEER, proc { |item, battler, scene|
  playername = battler.battle.pbPlayer.name
  itemname = PBItems.getName(item)
  if battler.status != 0
    scene.pbDisplay(_INTL("{1} won't drink!", battler.name))
    return false
  end
  scene.pbDisplay(_INTL("{1} drank the {2}.", battler.name, itemname))
  if battler.pbCanIncreaseStatStage?(PBStats::SPEED, false) || battler.pbCanIncreaseStatStage?(PBStats::SPATK, false)
    battler.pbIncreaseStat(PBStats::SPEED, 1, true)
    battler.pbIncreaseStat(PBStats::ATTACK, 2, true)
    if battler.effects[PBEffects::Confusion] != 0
      battler.status = PBStatuses::SLEEP
      scene.pbDisplay(_INTL("{1} fell asleep!", battler.name))
    else
      scene.pbDisplay(_INTL("{1} became confused!", battler.name))
      battler.effects[PBEffects::Confusion] = 3
    end
    return true
  else
    scene.pbDisplay(_INTL("But it had no effect!"))
    return false
  end
})

ItemHandlers::BattleUseOnPokemon.add(:COFFEE, proc { |item, pokemon, battler, scene|
  if battler.pbCanIncreaseStatStage?(PBStats::SPEED, false)
    battler.pbIncreaseStat(PBStats::SPEED, 1, true)
  end
  next pbBattleHPItem(pokemon, battler, 50, scene)
})

ItemHandlers::UseOnPokemon.add(:COFFEE, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 50, scene)
})
#===============================================================================
# UseInBattle handlers
#===============================================================================

#######################################
####### PokemonUtilities ##############
###SCRIPTEDIT4
####################################
####Speech Bubble ####
def pbCallBub(status = 0, value = 0, dir = false)
  $talkingEvent = get_character(value).id
  $Bubble = status
  $modifDir = dir
end


def pbAddPokemonID(pokemon, level = nil, seeform = true, dontRandomize = false)
  return if !pokemon || !$Trainer
  dontRandomize = true if $game_switches[3] #when choosing starters

  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end

  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = PokeBattle_Pokemon.new(pokemon, level, $Trainer)
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


def pbAddPokemonSilent(pokemon, level = nil, seeform = true)
  return false if !pokemon || pbBoxesFull? || !$Trainer
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon = getID(PBSpecies, pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = PokeBattle_Pokemon.new(pokemon, level, $Trainer)
  end
  $Trainer.seen[pokemon.species] = true
  $Trainer.owned[pokemon.species] = true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length < 6
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
  end
  return true
end


def pbGenerateEgg(pokemon, text = "")
  return false if !pokemon || !$Trainer # || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon = getID(PBSpecies, pokemon)
  end
  if pokemon.is_a?(Integer)
    pokemon = PokeBattle_Pokemon.new(pokemon, EGGINITIALLEVEL, $Trainer)
  end
  # Get egg steps
  eggsteps = $pkmn_dex[pokemon.species][10]
  # Set egg's details
  pokemon.name = _INTL("Egg")
  pokemon.eggsteps = eggsteps
  pokemon.obtainText = text
  pokemon.calcStats
  # Add egg to party
  Kernel.pbMessage(_INTL("Received a Pokémon egg!"))
  if $Trainer.party.length < 6
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
    Kernel.pbMessage(_INTL("The egg was transfered to the PC."))

  end
  #$Trainer.party[$Trainer.party.length]=pokemon
  return true
end




def pbHasSpecies?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    species = getID(PBSpecies, species)
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.species == species
  end
  return false
end


# Checks whether any Pokémon in the party knows the given move, and returns
# the index of that Pokémon, or nil if no Pokémon has that move.
#def pbCheckMove(move)
#move=getID(PBMoves,move)
#return nil if !move || move<=0
#for i in $Trainer.party
#  next if i.isEgg?
#    return i if CanLearnMove(i,move)# j.id==move
#end
# return nil
#end

#Check if the Pokemon can learn a TM
def CanLearnMove(pokemon, move)
  species = getID(PBSpecies, pokemon)
  ret = false
  return false if species <= 0
  data = load_data("Data/tm.dat")
  return false if !data[move]
  return data[move].any? { |item| item == species }
end




# Gets the ID number for the current region based on the player's current
# position.  Returns the value of "defaultRegion" (optional, default is -1) if
# no region was defined in the game's metadata.  The ID numbers returned by
# this function depend on the current map's position metadata.
def pbGetCurrentRegion(defaultRegion = -1)
  return -1
end



################################################################################
# Other utilities
################################################################################


##EDIT
def pbGetWildVictoryME
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  ret = nil
  if !ret && $game_map
    # Check map-specific metadata
    music = pbGetMetadata($game_map.map_id, MetadataMapWildVictoryME)
    if music && music != ""
      ret = pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music = pbGetMetadata(0, MetadataWildVictoryME)
    if music && music != ""
      ret = pbStringToAudioFile(music)
    end
  end
  ret = pbStringToAudioFile("wild-victory") if !ret
  ret.name = "../../Audio/ME/" + ret.name
  return ret
end

def pbGetTrainerVictoryME(trainer)
  # can be a PokeBattle_Trainer or an array of PokeBattle_Trainer
  if $PokemonGlobal.nextBattleME
    return $PokemonGlobal.nextBattleME.clone
  end
  music = nil
  pbRgssOpen("Data/trainertypes.dat", "rb") { |f|
    trainertypes = Marshal.load(f)
    if !trainer.is_a?(Array)
      trainerarray = [trainer]
    else
      trainerarray = trainer
    end
    for i in 0...trainerarray.length
      trainertype = trainerarray[i].trainertype
      if trainertypes[trainertype]
        music = trainertypes[trainertype][5]
      end
    end
  }
  ret = nil
  if music && music != ""
    ret = pbStringToAudioFile(music)
  end
  if !ret && $game_map
    # Check map-specific metadata
    music = pbGetMetadata($game_map.map_id, MetadataMapTrainerVictoryME)
    if music && music != ""
      ret = pbStringToAudioFile(music)
    end
  end
  if !ret
    # Check global metadata
    music = pbGetMetadata(0, MetadataTrainerVictoryME)
    if music && music != ""
      ret = pbStringToAudioFile(music)
    end
  end
  ret = pbStringToAudioFile("trainer-victory") if !ret
  ret.name = "../../Audio/ME/" + ret.name
  return ret
end
