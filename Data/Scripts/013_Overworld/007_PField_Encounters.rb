module EncounterTypes
  Land         = 0
  Cave         = 1
  Water        = 2
  RockSmash    = 3
  OldRod       = 4
  GoodRod      = 5
  SuperRod     = 6
  HeadbuttLow  = 7
  HeadbuttHigh = 8
  LandMorning  = 9
  LandDay      = 10
  LandNight    = 11
  BugContest   = 12
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
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [60,30,5,4,1],
     [60,30,5,4,1],
     [70,30],
     [60,20,20],
     [40,40,15,4,1],
     [30,25,20,10,5,5,4,1],
     [30,25,20,10,5,5,4,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1],
     [20,20,10,10,10,10,5,5,4,4,1,1]
  ]
  EnctypeDensities   = [25, 10, 10, 0, 0, 0, 0, 0, 0, 25, 25, 25, 25]
  EnctypeCompileDens = [ 1,  2,  3, 0, 0, 0, 0, 0, 0,  1,  1,  1,  1]
end



#===============================================================================
#
#===============================================================================
class PokemonEncounters
  attr_reader :stepcount

  def initialize
    @enctypes = []
    @density = nil
  end

  def setup(mapID)
    @stepcount = 0
    @density   = nil
    @enctypes  = []
    begin
      data = pbLoadEncountersData
      if data.is_a?(Hash) && data[mapID]
        @density  = data[mapID][0]
        @enctypes = data[mapID][1]
      else
        @density  = nil
        @enctypes = []
      end
    rescue
      @density  = nil
      @enctypes = []
    end
  end

  def clearStepCount; @stepcount = 0; end

  # Returns whether encounters for the given encounter type have been defined
  # for the current map.
  def hasEncounter?(enc)
    return false if @density==nil || enc<0
    return @enctypes[enc] ? true : false
  end

  # Returns whether encounters for the given encounter type have been defined
  # for the given map. Only called by Bug Catching Contest to see if it can use
  # the map's BugContest encounter type to generate caught Pokémon for the other
  # contestants.
  def pbMapHasEncounter?(mapID,enctype)
    data = pbLoadEncountersData
    if data.is_a?(Hash) && data[mapID]
      density  = data[mapID][0]
      enctypes = data[mapID][1]
    else
      return false
    end
    return false if density==nil || enctype<0
    return enctypes[enctype] ? true : false
  end

  # Returns whether cave-like encounters have been defined for the current map.
  # Applies only to encounters triggered by moving around.
  def isCave?
    return false if @density==nil
    return @enctypes[EncounterTypes::Cave] ? true : false
  end

  # Returns whether grass-like encounters have been defined for the current map.
  # Applies only to encounters triggered by moving around.
  def isGrass?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight] ||
            @enctypes[EncounterTypes::BugContest]) ? true : false
  end

  # Returns whether grass-like encounters have been defined for the current map
  # (ignoring the Bug Catching Contest one).
  # Applies only to encounters triggered by moving around.
  def isRegularGrass?
    return false if @density==nil
    return (@enctypes[EncounterTypes::Land] ||
            @enctypes[EncounterTypes::LandMorning] ||
            @enctypes[EncounterTypes::LandDay] ||
            @enctypes[EncounterTypes::LandNight]) ? true : false
  end

  # Returns whether water-like encounters have been defined for the current map.
  # Applies only to encounters triggered by moving around (i.e. not fishing).
  def isWater?
    return false if @density==nil
    return @enctypes[EncounterTypes::Water] ? true : false
  end

  # Returns whether it is theoretically possible to have an encounter in the
  # player's current location.
  def isEncounterPossibleHere?
    if $PokemonGlobal.surfing
      return true
    elsif PBTerrain.isIce?(pbGetTerrainTag($game_player))
      return false
    elsif self.isCave?
      return true
    elsif self.isGrass?
      return PBTerrain.isGrass?($game_map.terrain_tag($game_player.x,$game_player.y))
    end
    return false
  end

  # Returns the encounter method that the current encounter should be generated
  # from, depending on the player's current location.
  def pbEncounterType
    if $PokemonGlobal.surfing
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

  # Returns all the encounter tables for the given map.
  # You can alias this method and modify the returned array's contents if you
  # want to change the encounter table for some reason. Note that each sub-array
  # should contain the right number of entries for that encounter type.
  # Each encounter table element is an array: [species, minLevel, maxLevel]
  def pbGetEncounterTables(mapID=-1)
    if mapID>0
      data = pbLoadEncountersData
      return nil if !data.is_a?(Hash) || !data[mapID]
      return data[mapID][1]
    else   # Current map
      return Marshal.load(Marshal.dump(@enctypes))
    end
  end

  # Returns an array of the encounter table for the given map/encounter type.
  def pbGetEncounterTable(encType,mapID=-1)
    ret = pbGetEncounterTables(mapID)
    return ret[encType]
  end

  # Only called by Bug Catching Contest, when determining what the other
  # contestants caught.
  def pbMapEncounter(mapID,encType)
    if encType<0 || encType>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    # Get the encounter table
    encList = pbGetEncounterTable(encType,mapID)
    return nil if encList==nil
    # Calculate the total probability value
    chances = EncounterTypes::EnctypeChances[encType]
    chanceTotal = 0
    chances.each { |a| chanceTotal += a }
    # Choose a random entry in the encounter table based on entry weights
    rnd = rand(chanceTotal)
    chance = 0
    chosenPkmn = 0   # Index of the chosen entry
    for i in 0...chances.length
      chance += chances[i]
      if rnd<chance
        chosenPkmn = i
        break
      end
    end
    # Return the chosen species and level
    encounter = encList[chosenPkmn]
    level     = encounter[1]+rand(1+encounter[2]-encounter[1])
    return [encounter[0],level]
  end

  # Determines the species and level of the Pokémon to be encountered on the
  # current map, given the encounter type. May return nil if the given encounter
  # type has no encounters defined for it for the current map.
  def pbEncounteredPokemon(enctype,tries=1)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    # Get the encounter table
    encList = pbGetEncounterTable(enctype)
    return nil if encList==nil
    chances = EncounterTypes::EnctypeChances[enctype]
    # Static/Magnet Pull prefer wild encounters of certain types, if possible.
    # If they activate, they remove all Pokémon from the encounter table that do
    # not have the type they favor. If none have that type, nothing is changed.
    firstPkmn = $Trainer.firstPokemon
    if firstPkmn && rand(100)<50   # 50% chance of happening
      favoredType = -1
      if isConst?(firstPkmn.ability,PBAbilities,:STATIC) && hasConst?(PBTypes,:ELECTRIC)
        favoredType = getConst(PBTypes,:ELECTRIC)
      elsif isConst?(firstPkmn.ability,PBAbilities,:MAGNETPULL) && hasConst?(PBTypes,:STEEL)
        favoredType = getConst(PBTypes,:STEEL)
      end
      if favoredType>=0
        newEncList = []
        newChances = []
        speciesData = pbLoadSpeciesData
        for i in 0...encList.length
          t1 = speciesData[encList[i][0]][SpeciesType1]
          t2 = speciesData[encList[i][0]][SpeciesType2]
          next if t1!=favoredType && (!t2 || t2!=favoredType)
          newEncList.push(encList[i])
          newChances.push(chances[i])
        end
        if newEncList.length>0
          encList = newEncList
          chances = newChances
        end
      end
    end
    # Calculate the total probability value
    chanceTotal = 0
    chances.each { |a| chanceTotal += a }
    # Choose a random entry in the encounter table based on entry weights
    rnd = 0
    tries.times do
      r = rand(chanceTotal)
      rnd = r if rnd<r
    end
    chance = 0
    chosenPkmn = 0   # Index of the chosen entry
    for i in 0...chances.length
      chance += chances[i]
      if rnd<chance
        chosenPkmn = i
        break
      end
    end
    # Get the chosen species and level
    encounter = encList[chosenPkmn]
    return nil if !encounter
    level = encounter[1]+rand(1+encounter[2]-encounter[1])
    # Some abilities alter the level of the wild Pokémon
    if firstPkmn && rand(100)<50   # 50% chance of happening
      if isConst?(firstPkmn.ability,PBAbilities,:HUSTLE) ||
         isConst?(firstPkmn.ability,PBAbilities,:VITALSPIRIT) ||
         isConst?(firstPkmn.ability,PBAbilities,:PRESSURE)
        level2 = encounter[1]+rand(1+encounter[2]-encounter[1])
        level = level2 if level2>level   # Higher level is more likely
      end
    end
    # Black Flute and White Flute alter the level of the wild Pokémon
    if NEWEST_BATTLE_MECHANICS
      if $PokemonMap.blackFluteUsed
        level = [level+1+rand(3),PBExperience.maxLevel].min
      elsif $PokemonMap.whiteFluteUsed
        level = [level-1-rand(3),1].max
      end
    end
    # Return [species, level]
    return [encounter[0],level]
  end

  # Returns the encountered Pokémon's species/level, taking into account factors
  # that alter the probability of an encounter (cycling, Flutes, lead party
  # Pokémon's item/ability).
  def pbGenerateEncounter(enctype)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    # Check if an encounter table is defined
    return nil if @density==nil
    return nil if @density[enctype]==0 || !@density[enctype]
    return nil if @enctypes[enctype]==nil
    # Wild encounters cannot happen for the first 3 steps after a previous wild
    # encounter
    @stepcount += 1
    return nil if @stepcount<=3
    # Determine the encounter density (probability of a wild encounter
    # happening). The actual probability is the written encounter density, with
    # modifiers applied, divided by 180 (numbers are multiplied by 16 below to
    # increase precision).
    encount = @density[enctype]*16
    encount = encount*0.8 if $PokemonGlobal.bicycle
    if !NEWEST_BATTLE_MECHANICS
      if $PokemonMap.blackFluteUsed
        encount = encount/2
      elsif $PokemonMap.whiteFluteUsed
        encount = encount*1.5
      end
    end
    firstPkmn = $Trainer.firstPokemon
    if firstPkmn
      if firstPkmn.hasItem?(:CLEANSETAG)
        encount = encount*2/3
      elsif firstPkmn.hasItem?(:PUREINCENSE)
        encount = encount*2/3
      else   # Ignore ability effects if an item effect applies
        if isConst?(firstPkmn.ability,PBAbilities,:STENCH)
          encount = encount/2
        elsif isConst?(firstPkmn.ability,PBAbilities,:WHITESMOKE)
          encount = encount/2
        elsif isConst?(firstPkmn.ability,PBAbilities,:QUICKFEET)
          encount = encount/2
        elsif isConst?(firstPkmn.ability,PBAbilities,:SNOWCLOAK)
          encount = encount/2 if $game_screen.weather_type==PBFieldWeather::Snow ||
                                 $game_screen.weather_type==PBFieldWeather::Blizzard
        elsif isConst?(firstPkmn.ability,PBAbilities,:SANDVEIL)
          encount = encount/2 if $game_screen.weather_type==PBFieldWeather::Sandstorm
        elsif isConst?(firstPkmn.ability,PBAbilities,:SWARM)
          encount = encount*1.5
        elsif isConst?(firstPkmn.ability,PBAbilities,:ILLUMINATE)
          encount = encount*2
        elsif isConst?(firstPkmn.ability,PBAbilities,:ARENATRAP)
          encount = encount*2
        elsif isConst?(firstPkmn.ability,PBAbilities,:NOGUARD)
          encount = encount*2
        end
      end
    end
    # Decide whether the wild encounter should actually happen
    return nil if rand(180*16)>=encount
    # A wild encounter will happen; choose a species and level for it
    encPkmn = pbEncounteredPokemon(enctype)
    return nil if !encPkmn
    # Some abilities make wild encounters less likely if the wild Pokémon is
    # sufficiently weaker than the Pokémon with the ability
    if firstPkmn && rand(100)<50   # 50% chance of happening
      if isConst?(firstPkmn.ability,PBAbilities,:INTIMIDATE) ||
         isConst?(firstPkmn.ability,PBAbilities,:KEENEYE)
        return nil if encPkmn[1]<=firstPkmn.level-5   # 5 or more levels weaker
      end
    end
    return encPkmn
  end

  # Returns whether it is possible to have an encounter, based on some factors
  # that would prevent it (holding Ctrl in Debug mode, Repels).
  def pbCanEncounter?(encounter,repel)
    return false if $game_system.encounter_disabled
    return false if !encounter || !$Trainer
    return false if $DEBUG && Input.press?(Input::CTRL)
    if !pbPokeRadarOnShakingGrass
      if $PokemonGlobal.repel>0 || repel
        firstPkmn = (NEWEST_BATTLE_MECHANICS) ? $Trainer.firstPokemon : $Trainer.firstAblePokemon
        return false if firstPkmn && encounter[1]<firstPkmn.level
      end
    end
    return true
  end
end



#===============================================================================
#
#===============================================================================
# Returns a Pokémon generated by a wild encounter, given its species and level.
def pbGenerateWildPokemon(species,level,isRoamer=false)
  genwildpoke = Pokemon.new(species,level)
  # Give the wild Pokémon a held item
  items = genwildpoke.wildHoldItems
  firstPkmn = $Trainer.firstPokemon
  chances = [50,5,1]
  chances = [60,20,5] if firstPkmn && isConst?(firstPkmn.ability,PBAbilities,:COMPOUNDEYES)
  itemrnd = rand(100)
  if (items[0]==items[1] && items[1]==items[2]) || itemrnd<chances[0]
    genwildpoke.setItem(items[0])
  elsif itemrnd<(chances[0]+chances[1])
    genwildpoke.setItem(items[1])
  elsif itemrnd<(chances[0]+chances[1]+chances[2])
    genwildpoke.setItem(items[2])
  end
  # Shiny Charm makes shiny Pokémon more likely to generate
  if hasConst?(PBItems,:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM)
    2.times do   # 3 times as likely
      break if genwildpoke.shiny?
      genwildpoke.personalID = rand(65536)|(rand(65536)<<16)
    end
  end
  # Give Pokérus
  if rand(65536)<POKERUS_CHANCE
    genwildpoke.givePokerus
  end
  # Change wild Pokémon's gender/nature depending on the lead party Pokémon's
  # ability
  if firstPkmn
    if isConst?(firstPkmn.ability,PBAbilities,:CUTECHARM) && !genwildpoke.singleGendered?
      if firstPkmn.male?
        (rand(3)<2) ? genwildpoke.makeFemale : genwildpoke.makeMale
      elsif firstPkmn.female?
        (rand(3)<2) ? genwildpoke.makeMale : genwildpoke.makeFemale
      end
    elsif isConst?(firstPkmn.ability,PBAbilities,:SYNCHRONIZE)
      genwildpoke.setNature(firstPkmn.nature) if !isRoamer && rand(100)<50
    end
  end
  # Trigger events that may alter the generated Pokémon further
  Events.onWildPokemonCreate.trigger(nil,genwildpoke)
  return genwildpoke
end

# Used by fishing rods and Headbutt/Rock Smash/Sweet Scent. Skips the
# probability checks in def pbGenerateEncounter above.
def pbEncounter(enctype)
  $PokemonTemp.encounterType = enctype
  encounter1 = $PokemonEncounters.pbEncounteredPokemon(enctype)
  encounter1 = EncounterModifier.trigger(encounter1)
  return false if !encounter1
  if $PokemonGlobal.partner
    encounter2 = $PokemonEncounters.pbEncounteredPokemon(enctype)
    encounter2 = EncounterModifier.trigger(encounter2)
    return false if !encounter2
    pbDoubleWildBattle(encounter1[0],encounter1[1],encounter2[0],encounter2[1])
  else
    pbWildBattle(encounter1[0],encounter1[1])
  end
	$PokemonTemp.encounterType = -1
  return true
end
