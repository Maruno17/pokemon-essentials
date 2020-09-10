module PBEvolution
  None              = 0
  Happiness         = 1
  HappinessDay      = 2
  HappinessNight    = 3
  Level             = 4
  Trade             = 5
  TradeItem         = 6
  Item              = 7
  AttackGreater     = 8
  AtkDefEqual       = 9
  DefenseGreater    = 10
  Silcoon           = 11
  Cascoon           = 12
  Ninjask           = 13
  Shedinja          = 14
  Beauty            = 15
  ItemMale          = 16
  ItemFemale        = 17
  DayHoldItem       = 18
  NightHoldItem     = 19
  HasMove           = 20
  HasInParty        = 21
  LevelMale         = 22
  LevelFemale       = 23
  Location          = 24
  TradeSpecies      = 25
  LevelDay          = 26
  LevelNight        = 27
  LevelDarkInParty  = 28
  LevelRain         = 29
  HappinessMoveType = 30
  LevelEvening      = 31

  EVONAMES = ["None",
     "Happiness",    "HappinessDay", "HappinessNight",   "Level",         "Trade",
     "TradeItem",    "Item",         "AttackGreater",    "AtkDefEqual",   "DefenseGreater",
     "Silcoon",      "Cascoon",      "Ninjask",          "Shedinja",      "Beauty",
     "ItemMale",     "ItemFemale",   "DayHoldItem",      "NightHoldItem", "HasMove",
     "HasInParty",   "LevelMale",    "LevelFemale",      "Location",      "TradeSpecies",
     "LevelDay",     "LevelNight",   "LevelDarkInParty", "LevelRain",     "HappinessMoveType",
     "LevelEvening"
  ]

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
    return method_hash && method_hash[function]
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

def pbGetBabySpecies(species,item1=-1,item2=-1)
  ret = species
  evoData = pbGetEvolutionData(species)
  return ret if !evoData || evoData.length==0
  evoData.each do |evo|
    next if !evo[3]
    if item1>=0 && item2>=0
      incense = pbGetSpeciesData(evo[0],0,SpeciesIncense)
      ret = evo[0] if item1==incense || item2==incense
    else
      ret = evo[0]   # Species of prevolution
    end
    break
  end
  ret = pbGetBabySpecies(ret) if ret!=species
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

# Used by the Moon Ball when checking if a Pokémon's evolution family includes
# an evolution that uses the Moon Stone.
def pbCheckEvolutionFamilyForMethod(species, method, param = -1)
  species = pbGetBabySpecies(species)
  evos = pbGetEvolutionFamilyData(species)
  return false if !evos || evos.length == 0
  for evo in evos
    if method.is_a?(Array)
      next if !method.include?(evo[1])
    elsif method>=0
      next if evo[1] != method
    end
    next if param >= 0 && evo[2] != param
    return true
  end
  return false
end

# Used by the Moon Ball when checking if a Pokémon's evolution family includes
# an evolution that uses the Moon Stone.
def pbCheckEvolutionFamilyForItemMethodItem(species, param = -1)
  species = pbGetBabySpecies(species)
  evos = pbGetEvolutionFamilyData(species)
  return false if !evos || evos.length == 0
  for evo in evos
    next if !PBEvolution.hasFunction?(evo[1], "itemCheck")
    next if param >= 0 && evo[2] != param
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
  return -1 if isConst?(pokemon.ability,PBAbilities,:BATTLEBOND)
  ret = -1
  for form in pbGetEvolvedFormData(pbGetFSpeciesFromForm(pokemon.species,pokemon.form),true)
    ret = yield pokemon,form[0],form[1],form[2]
    break if ret>0
  end
  return ret
end

# Checks whether a Pokemon can evolve now. If an item is used on the Pokémon,
# checks whether the Pokemon can evolve with the given item.
def pbCheckEvolution(pokemon,item=0)
  if item==0
    return pbCheckEvolutionEx(pokemon) { |pokemon,evonib,level,poke|
      next pbMiniCheckEvolution(pokemon,evonib,level,poke)
    }
  else
    return pbCheckEvolutionEx(pokemon) { |pokemon,evonib,level,poke|
      next pbMiniCheckEvolutionItem(pokemon,evonib,level,poke,item)
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

PBEvolution.register(:LevelEvening, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.level >= parameter && PBDayNight.isEvening?
  }
})

PBEvolution.register(:LevelDarkInParty, {
  "levelUpCheck" => proc { |pkmn, parameter|
    if pkmn.level >= parameter
      next $Trainer.pokemonParty.any? { |p| p && p.hasType(:DARK) }
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
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if $Trainer.party.length>=6
    next false if !$PokemonBag.pbHasItem?(getConst(PBItems,:POKEBALL))
    PokemonEvolutionScene.pbDuplicatePokemon(pkmn, new_species)
    $PokemonBag.pbDeleteItem(getConst(PBItems,:POKEBALL))
    next true
  }
})

PBEvolution.register(:Happiness, {
  "minimumLevel" => 1,   # Needs any level up
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.happiness >= 220
  }
})

PBEvolution.register(:HappinessDay, {
  "minimumLevel" => 1,   # Needs any level up
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.happiness >= 220 && PBDayNight.isDay?
  }
})

PBEvolution.register(:HappinessNight, {
  "minimumLevel" => 1,   # Needs any level up
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.happiness >= 220 && PBDayNight.isDay?
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

PBEvolution.register(:Beauty, {   # Feebas
  "minimumLevel" => 1,   # Needs any level up
  "levelUpCheck" => proc { |pkmn, parameter|
    next pkmn.beauty >= parameter
  }
})

PBEvolution.register(:DayHoldItem, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :PBItems,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.item == parameter && PBDayNight.isDay?
  },
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.setItem(0)   # Item is now consumed
    next true
  }
})

PBEvolution.register(:NightHoldItem, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :PBItems,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.item == parameter && PBDayNight.isNight?
  },
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.setItem(0)   # Item is now consumed
    next true
  }
})

PBEvolution.register(:HasMove, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :PBMoves,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.moves.any? { |m| m && m.id == parameter }
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
  "minimumLevel"  => 1,   # Needs any level up
  "levelUpCheck"  => proc { |pkmn, parameter|
    next $game_map.map_id == parameter
  }
})

#===============================================================================
# Evolution methods that trigger when using an item on the Pokémon
#===============================================================================
PBEvolution.register(:Item, {
  "parameterType" => :PBItems,
  "itemCheck"     => proc { |pkmn, parameter, item|
    next item == parameter
  }
})

PBEvolution.register(:ItemMale, {
  "parameterType" => :PBItems,
  "itemCheck"     => proc { |pkmn, parameter, item|
    next item == parameter && pkmn.male?
  }
})

PBEvolution.register(:ItemFemale, {
  "parameterType" => :PBItems,
  "itemCheck"     => proc { |pkmn, parameter, item|
    next item == parameter && pkmn.female?
  }
})

#===============================================================================
# Evolution methods that trigger when the Pokémon is obtained in a trade
#===============================================================================
PBEvolution.register(:Trade, {
  "tradeCheck" => proc { |pkmn, parameter, other_pkmn|
    next true
  }
})

PBEvolution.register(:TradeItem, {
  "parameterType" => :PBItems,
  "tradeCheck"    => proc { |pkmn, parameter, other_pkmn|
    next pkmn.item == parameter
  },
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || !pkmn.hasItem?(parameter)
    pkmn.setItem(0)   # Item is now consumed
    next true
  }
})

PBEvolution.register(:TradeSpecies, {
  "parameterType" => :PBSpecies,
  "tradeCheck"    => proc { |pkmn, parameter, other_pkmn|
    next pkmn.species == parameter && !other_pkmn.hasItem?(:EVERSTONE)
  }
})
