module PBEvolution
  # NOTE: If you're adding new evolution methods, don't skip any numbers.
  #       Remember to update def self.maxValue just below the constants list.
  None              = 0
  Level             = 1
  LevelMale         = 2
  LevelFemale       = 3
  LevelDay          = 4
  LevelNight        = 5
  LevelMorning      = 6
  LevelAfternoon    = 7
  LevelEvening      = 8
  LevelNoWeather    = 9
  LevelSun          = 10
  LevelRain         = 11
  LevelSnow         = 12
  LevelSandstorm    = 13
  LevelCycling      = 14
  LevelSurfing      = 15
  LevelDiving       = 16
  LevelDarkness     = 17
  LevelDarkInParty  = 18
  AttackGreater     = 19
  AtkDefEqual       = 20
  DefenseGreater    = 21
  Silcoon           = 22
  Cascoon           = 23
  Ninjask           = 24
  Shedinja          = 25
  Happiness         = 26
  HappinessMale     = 27
  HappinessFemale   = 28
  HappinessDay      = 29
  HappinessNight    = 30
  HappinessMove     = 31
  HappinessMoveType = 32
  HappinessHoldItem = 33
  MaxHappiness      = 34
  Beauty            = 35
  HoldItem          = 36
  HoldItemMale      = 37
  HoldItemFemale    = 38
  DayHoldItem       = 39
  NightHoldItem     = 40
  HoldItemHappiness = 41
  HasMove           = 42
  HasMoveType       = 43
  HasInParty        = 44
  Location          = 45
  Region            = 46
  Item              = 47
  ItemMale          = 48
  ItemFemale        = 49
  ItemDay           = 50
  ItemNight         = 51
  ItemHappiness     = 52
  Trade             = 53
  TradeMale         = 54
  TradeFemale       = 55
  TradeDay          = 56
  TradeNight        = 57
  TradeItem         = 58
  TradeSpecies      = 59

  def self.maxValue; return 59; end

  @@evolution_methods = HandlerHash.new(:PBEvolution)

  def self.copy(sym, *syms)
    @@evolution_methods.copy(sym, *syms)
  end

  def self.register(sym, hash)
    @@evolution_methods.add(sym, hash)
  end

  def self.registerIf(cond, hash)
    @@evolution_methods.addIf(cond, hash)
  end

  def self.hasFunction?(method, function)
    method = (method.is_a?(Numeric)) ? method : getConst(PBEvolution, method)
    method_hash = @@evolution_methods[method]
    return method_hash && method_hash.keys.include?(function)
  end

  def self.getFunction(method, function)
    method = (method.is_a?(Numeric)) ? method : getConst(PBEvolution, method)
    method_hash = @@evolution_methods[method]
    return (method_hash && method_hash[function]) ? method_hash[function] : nil
  end

  def self.call(function, method, *args)
    method = (method.is_a?(Numeric)) ? method : getConst(PBEvolution, method)
    method_hash = @@evolution_methods[method]
    return nil if !method_hash || !method_hash[function]
    return method_hash[function].call(*args)
  end
end

#===============================================================================
# Evolutions data cache
#===============================================================================
class PokemonTemp
  attr_accessor :evolutionsData
end

def pbLoadEvolutionsData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.evolutionsData
    $PokemonTemp.evolutionsData = load_data("Data/species_evolutions.dat") || []
  end
  return $PokemonTemp.evolutionsData
end

def pbGetEvolutionData(species)
  species = getID(PBSpecies,species)
  evosData = pbLoadEvolutionsData
  return evosData[species] || nil
end

alias __evolutionsData__pbClearData pbClearData
def pbClearData
  $PokemonTemp.evolutionsData = nil if $PokemonTemp
  __evolutionsData__pbClearData
end

#===============================================================================
# Evolution helper functions
#===============================================================================
def pbGetEvolvedFormData(species,ignoreNone=false)
  ret = []
  evoData = pbGetEvolutionData(species)
  return ret if !evoData || evoData.length==0
  evoData.each do |evo|
    next if evo[3]   # Is the prevolution
    next if evo[1]==PBEvolution::None && ignoreNone
    ret.push([evo[1],evo[2],evo[0]])   # [Method, parameter, species]
  end
  return ret
end

def pbGetPreviousForm(species)   # Unused
  evoData = pbGetEvolutionData(species)
  return species if !evoData || evoData.length==0
  evoData.each do |evo|
    return evo[0] if evo[3]   # Is the prevolution
  end
  return species
end

def pbGetBabySpecies(species, check_items = false, item1 = nil, item2 = nil)
  ret = species
  evoData = pbGetEvolutionData(species)
  return ret if !evoData || evoData.length == 0
  evoData.each do |evo|
    next if !evo[3]   # Not the prevolution
    if check_items
      incense = pbGetSpeciesData(evo[0], 0, SpeciesData::INCENSE)
      ret = evo[0] if !incense || item1 == incense || item2 == incense
    else
      ret = evo[0]   # Species of prevolution
    end
    break
  end
  ret = pbGetBabySpecies(ret, item1, item2) if ret != species
  return ret
end

def pbGetMinimumLevel(species)
  evoData = pbGetEvolutionData(species)
  return 1 if !evoData || evoData.length == 0
  ret = -1
  evoData.each do |evo|
    next if !evo[3]   # Is the prevolution
    if PBEvolution.hasFunction?(evo[1], "levelUpCheck")
      min_level = PBEvolution.getFunction(evo[1], "minimumLevel")
      ret = evo[2] if !min_level || min_level != 1
    end
    break   # Because only one prevolution method can be defined
  end
  return (ret == -1) ? 1 : ret
end

def pbGetEvolutionFamilyData(species)
  evos = pbGetEvolvedFormData(species,true)
  return nil if evos.length==0
  ret = []
  for i in 0...evos.length
    ret.push([species].concat(evos[i]))
    evoData = pbGetEvolutionFamilyData(evos[i][2])
    ret.concat(evoData) if evoData && evoData.length>0
  end
  return ret
end

def pbCheckEvolutionFamilyForMethod(species, method, param = -1)
  species = pbGetBabySpecies(species)
  evos = pbGetEvolutionFamilyData(species)
  return false if !evos || evos.length == 0
  for evo in evos
    if method.is_a?(Array)
      next if !method.include?(evo[1])
    elsif method >= 0
      next if evo[1] != method
    end
    next if param >= 0 && evo[2] != param
    return true
  end
  return false
end

# Used by the Moon Ball when checking if a Pokémon's evolution family includes
# an evolution that uses the Moon Stone.
def pbCheckEvolutionFamilyForItemMethodItem(species, param = nil)
  species = pbGetBabySpecies(species)
  evos = pbGetEvolutionFamilyData(species)
  return false if !evos || evos.length == 0
  for evo in evos
    next if !PBEvolution.hasFunction?(evo[1], "itemCheck")
    next if param && evo[2] != param
    return true
  end
  return false
end

def pbEvoDebug   # Unused
  evosData = pbLoadEvolutionsData
  for species in 1..PBSpecies.maxValueF
    echo PBSpecies.getName(pbGetSpeciesFromFSpecies(species)[0])+"\n"
    next if !evosData[species] || evosData[species].length==0
    for evo in evosData[species]
      echo sprintf("name=%s, type=%s (%02X), level=%d, evo/prevo=%s",
         PBSpecies.getName(evo[0]),getConstantName(PBEvolution,evo[1]),evo[1],evo[2],
         (evo[3]) ? "prevolution" : "evolution")+"\n"
    end
  end
  echo "end\n"
end

#===============================================================================
# Evolution checks
#===============================================================================
def pbMiniCheckEvolution(pkmn, method, parameter, new_species)
  success = PBEvolution.call("levelUpCheck", method, pkmn, parameter)
  return (success) ? new_species : -1
end

def pbMiniCheckEvolutionItem(pkmn, method, parameter, new_species, item)
  success = PBEvolution.call("itemCheck", method, pkmn, parameter, item)
  return (success) ? new_species : -1
end

# Checks whether a Pokemon can evolve now. If a block is given, calls the block
# with the following parameters:
#   Pokemon to check; evolution type; level or other parameter; ID of the new species
def pbCheckEvolutionEx(pokemon)
  return -1 if pokemon.species<=0 || pokemon.egg? || pokemon.shadowPokemon?
  return -1 if pokemon.hasItem?(:EVERSTONE)
  return -1 if pokemon.hasAbility?(:BATTLEBOND)
  ret = -1
  for form in pbGetEvolvedFormData(pbGetFSpeciesFromForm(pokemon.species,pokemon.form),true)
    ret = yield pokemon,form[0],form[1],form[2]
    break if ret>0
  end
  return ret
end

# Checks whether a Pokemon can evolve now. If an item is used on the Pokémon,
# checks whether the Pokemon can evolve with the given item.
def pbCheckEvolution(pokemon,item=nil)
  if item
    return pbCheckEvolutionEx(pokemon) { |pokemon,evonib,level,poke|
      next pbMiniCheckEvolutionItem(pokemon,evonib,level,poke,item)
    }
  else
    return pbCheckEvolutionEx(pokemon) { |pokemon,evonib,level,poke|
      next pbMiniCheckEvolution(pokemon,evonib,level,poke)
    }
  end
end

#===============================================================================
# Evolution methods that trigger when levelling up
#===============================================================================
PBEvolution.register(:Level, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter
  }
})

PBEvolution.register(:LevelMale, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && pkmn.male?
  }
})

PBEvolution.register(:LevelFemale, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && pkmn.female?
  }
})

PBEvolution.register(:LevelDay, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && PBDayNight.isDay?
  }
})

PBEvolution.register(:LevelNight, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && PBDayNight.isNight?
  }
})

PBEvolution.register(:LevelMorning, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && PBDayNight.isMorning?
  }
})

PBEvolution.register(:LevelAfternoon, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && PBDayNight.isAfternoon?
  }
})

PBEvolution.register(:LevelEvening, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && PBDayNight.isEvening?
  }
})

PBEvolution.register(:LevelNoWeather, {
  "levelUpCheck" => proc { |pkmn, parameter|
    if pkmn.level >= parameter && $game_screen
      next $game_screen.weather_type == PBFieldWeather::None
    end
  }
})

PBEvolution.register(:LevelSun, {
  "levelUpCheck" => proc { |pkmn, parameter|
    if pkmn.level >= parameter && $game_screen
      next $game_screen.weather_type == PBFieldWeather::Sun
    end
  }
})

PBEvolution.register(:LevelRain, {
  "levelUpCheck" => proc { |pkmn, parameter|
    if pkmn.level >= parameter && $game_screen
      next [PBFieldWeather::Rain, PBFieldWeather::HeavyRain,
            PBFieldWeather::Storm].include?($game_screen.weather_type)
    end
  }
})

PBEvolution.register(:LevelSnow, {
  "levelUpCheck" => proc { |pkmn, parameter|
    if pkmn.level >= parameter && $game_screen
      next [PBFieldWeather::Snow, PBFieldWeather::Blizzard].include?($game_screen.weather_type)
    end
  }
})

PBEvolution.register(:LevelSandstorm, {
  "levelUpCheck" => proc { |pkmn, parameter|
    if pkmn.level >= parameter && $game_screen
      next $game_screen.weather_type == PBFieldWeather::Sandstorm
    end
  }
})

PBEvolution.register(:LevelCycling, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $PokemonGlobal && $PokemonGlobal.bicycle
  }
})

PBEvolution.register(:LevelSurfing, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $PokemonGlobal && $PokemonGlobal.surfing
  }
})

PBEvolution.register(:LevelDiving, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $PokemonGlobal && $PokemonGlobal.diving
  }
})

PBEvolution.register(:LevelDarkness, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && GameData::MapMetadata.get($game_map.map_id).dark_map
  }
})

PBEvolution.register(:LevelDarkInParty, {
  "levelUpCheck" => proc { |pkmn, parameter|
    if pkmn.level >= parameter
      next $Trainer.pokemonParty.any? { |p| p && p.hasType(:DARK) }
    end
  }
})

PBEvolution.register(:AttackGreater, {    # Hitmonlee
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && pkmn.attack > pkmn.defense
  }
})

PBEvolution.register(:AtkDefEqual, {    # Hitmontop
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && pkmn.attack == pkmn.defense
  }
})

PBEvolution.register(:DefenseGreater, {    # Hitmonchan
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && pkmn.attack < pkmn.defense
  }
})

PBEvolution.register(:Silcoon, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && (((pkmn.personalID >> 16) & 0xFFFF) % 10) < 5
  }
})

PBEvolution.register(:Cascoon, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && (((pkmn.personalID >> 16) & 0xFFFF) % 10) >= 5
  }
})

PBEvolution.register(:Ninjask, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter
  }
})

PBEvolution.register(:Shedinja, {
  "parameterType"  => nil,
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if $Trainer.party.length>=6
    next false if !$PokemonBag.pbHasItem?(:POKEBALL)
    PokemonEvolutionScene.pbDuplicatePokemon(pkmn, new_species)
    $PokemonBag.pbDeleteItem(:POKEBALL)
    next true
  }
})

PBEvolution.register(:Happiness, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => nil,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.happiness >= 220
  }
})

PBEvolution.register(:HappinessMale, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => nil,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.happiness >= 220 && pkmn.male?
  }
})

PBEvolution.register(:HappinessFemale, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => nil,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.happiness >= 220 && pkmn.female?
  }
})

PBEvolution.register(:HappinessDay, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => nil,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.happiness >= 220 && PBDayNight.isDay?
  }
})

PBEvolution.register(:HappinessNight, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => nil,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.happiness >= 220 && PBDayNight.isNight?
  }
})

PBEvolution.register(:HappinessMove, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :Move,
  "levelUpCheck"  => proc { |pkmn, parameter|
    if pkmn.happiness >= 220
      next pkmn.moves.any? { |m| m && m.id == parameter }
    end
  }
})

PBEvolution.register(:HappinessMoveType, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :PBTypes,
  "levelUpCheck"  => proc { |pkmn, parameter|
    if pkmn.happiness >= 220
      next pkmn.moves.any? { |m| m && m.id > 0 && m.type == parameter }
    end
  }
})

PBEvolution.register(:HappinessHoldItem, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :Item,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.item == parameter && pkmn.happiness >= 220
  },
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.setItem(nil)   # Item is now consumed
    next true
  }
})

PBEvolution.register(:MaxHappiness, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => nil,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.happiness == 255
  }
})

PBEvolution.register(:Beauty, {   # Feebas
  "minimumLevel" => 1,   # Needs any level up
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.beauty >= parameter
  }
})

PBEvolution.register(:HoldItem, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :Item,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.item == parameter
  },
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.setItem(nil)   # Item is now consumed
    next true
  }
})

PBEvolution.register(:HoldItemMale, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :Item,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.item == parameter && pkmn.male?
  },
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.setItem(nil)   # Item is now consumed
    next true
  }
})

PBEvolution.register(:HoldItemFemale, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :Item,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.item == parameter && pkmn.female?
  },
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.setItem(nil)   # Item is now consumed
    next true
  }
})

PBEvolution.register(:DayHoldItem, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :Item,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.item == parameter && PBDayNight.isDay?
  },
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.setItem(nil)   # Item is now consumed
    next true
  }
})

PBEvolution.register(:NightHoldItem, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :Item,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.item == parameter && PBDayNight.isNight?
  },
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.setItem(nil)   # Item is now consumed
    next true
  }
})

PBEvolution.register(:HoldItemHappiness, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :Item,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.item == parameter && pkmn.happiness >= 220
  },
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.setItem(nil)   # Item is now consumed
    next true
  }
})

PBEvolution.register(:HasMove, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :Move,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.moves.any? { |m| m && m.id == parameter }
  }
})

PBEvolution.register(:HasMoveType, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :PBTypes,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.moves.any? { |m| m && m.type == parameter }
  }
})

PBEvolution.register(:HasInParty, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :PBSpecies,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pbHasSpecies?(parameter)
  }
})

PBEvolution.register(:Location, {
  "minimumLevel" => 1,   # Needs any level up
  "levelUpCheck" => proc { |pkmn, parameter|
    next $game_map.map_id == parameter
  }
})

PBEvolution.register(:Region, {
  "minimumLevel" => 1,   # Needs any level up
  "levelUpCheck" => proc { |pkmn, parameter|
    mapPos = GameData::MapMetadata.get($game_map.map_id).town_map_position
    next mapPos && mapPos[0] == parameter
  }
})

#===============================================================================
# Evolution methods that trigger when using an item on the Pokémon
#===============================================================================
PBEvolution.register(:Item, {
  "parameterType" => :Item,
  "itemCheck"     => proc { |pkmn, parameter, item|
    next item == parameter
  }
})

PBEvolution.register(:ItemMale, {
  "parameterType" => :Item,
  "itemCheck"     => proc { |pkmn, parameter, item|
    next item == parameter && pkmn.male?
  }
})

PBEvolution.register(:ItemFemale, {
  "parameterType" => :Item,
  "itemCheck"     => proc { |pkmn, parameter, item|
    next item == parameter && pkmn.female?
  }
})

PBEvolution.register(:ItemDay, {
  "parameterType" => :Item,
  "itemCheck"     => proc { |pkmn, parameter, item|
    next item == parameter && PBDayNight.isDay?
  }
})

PBEvolution.register(:ItemNight, {
  "parameterType" => :Item,
  "itemCheck"     => proc { |pkmn, parameter, item|
    next item == parameter && PBDayNight.isNight?
  }
})

PBEvolution.register(:ItemHappiness, {
  "parameterType" => :Item,
  "levelUpCheck"  => proc { |pkmn, parameter, item|
    next item == parameter && pkmn.happiness >= 220
  }
})

#===============================================================================
# Evolution methods that trigger when the Pokémon is obtained in a trade
#===============================================================================
PBEvolution.register(:Trade, {
  "parameterType" => nil,
  "tradeCheck"    => proc { |pkmn, parameter, other_pkmn|
    next true
  }
})

PBEvolution.register(:TradeMale, {
  "parameterType" => nil,
  "tradeCheck"    => proc { |pkmn, parameter, other_pkmn|
    next pkmn.male?
  }
})

PBEvolution.register(:TradeFemale, {
  "parameterType" => nil,
  "tradeCheck"    => proc { |pkmn, parameter, other_pkmn|
    next pkmn.female?
  }
})

PBEvolution.register(:TradeDay, {
  "parameterType" => nil,
  "tradeCheck"    => proc { |pkmn, parameter, other_pkmn|
    next PBDayNight.isDay?
  }
})

PBEvolution.register(:TradeNight, {
  "parameterType" => nil,
  "tradeCheck"    => proc { |pkmn, parameter, other_pkmn|
    next PBDayNight.isNight?
  }
})

PBEvolution.register(:TradeItem, {
  "parameterType" => :Item,
  "tradeCheck"    => proc { |pkmn, parameter, other_pkmn|
    next pkmn.item == parameter
  },
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.setItem(nil)   # Item is now consumed
    next true
  }
})

PBEvolution.register(:TradeSpecies, {
  "parameterType" => :PBSpecies,
  "tradeCheck"    => proc { |pkmn, parameter, other_pkmn|
    next pkmn.species == parameter && !other_pkmn.hasItem?(:EVERSTONE)
  }
})
