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
# Evolution helper functions
#===============================================================================
module EvolutionHelper
  module_function

  def evolutions(species, ignore_none = false)
    ret = []
    evoData =  GameData::Species.get(species).evolutions
    return ret if !evoData || evoData.length == 0
    evoData.each do |evo|
      next if evo[3]   # Is the prevolution
      next if evo[1] == PBEvolution::None && ignore_none
      ret.push([evo[1], evo[2], evo[0]])   # [Method, parameter, species]
    end
    return ret
  end

  def family_evolutions(species, ignore_none = true)
    evos = self.evolutions(species, ignore_none)
    return nil if evos.length == 0
    evos.sort! { |a, b| GameData::Species.get(a[2]).id_number <=> GameData::Species.get(b[2]).id_number }
    ret = []
    for i in 0...evos.length
      ret.push([species].concat(evos[i]))
      evo_array = self.family_evolutions(evos[i][2])
      ret.concat(evo_array) if evo_array && evo_array.length > 0
    end
    return ret
  end

  def all_related_species(species)
    species = self.baby_species(species)
    evos = self.family_evolutions(species, false)
    return [species] if !evos || evos.length == 0
    return [species].concat(evos.map { |e| e[3] }).uniq
  end

  def previous_species(species)
    evoData =  GameData::Species.get(species).evolutions
    return species if !evoData || evoData.length == 0
    evoData.each do |evo|
      return evo[0] if evo[3]   # Is the prevolution
    end
    return species
  end

  def baby_species(species, check_items = false, item1 = nil, item2 = nil)
    ret = species
    evoData =  GameData::Species.get(species).evolutions
    return ret if !evoData || evoData.length == 0
    evoData.each do |evo|
      next if !evo[3]   # Not the prevolution
      if check_items
        incense = GameData::Species.get(evo[0]).incense
        ret = evo[0] if !incense || item1 == incense || item2 == incense
      else
        ret = evo[0]   # Species of prevolution
      end
      break
    end
    ret = self.baby_species(ret, item1, item2) if ret != species
    return ret
  end

  def minimum_level(species)
    evoData =  GameData::Species.get(species).evolutions
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

  def check_family_for_method(species, method, param = nil)
    species = self.baby_species(species)
    evos = self.family_evolutions(species)
    return false if !evos || evos.length == 0
    for evo in evos
      if method.is_a?(Array)
        next if !method.include?(evo[1])
      elsif method >= 0
        next if evo[1] != method
      end
      next if param && evo[2] != param
      return true
    end
    return false
  end

  def check_family_for_method_item(species, param = nil)
    species = self.baby_species(species)
    evos = self.family_evolutions(species)
    return false if !evos || evos.length == 0
    for evo in evos
      next if !PBEvolution.hasFunction?(evo[1], "itemCheck")
      next if param && evo[2] != param
      return true
    end
    return false
  end
end



def pbGetEvolvedFormData(species, ignore_none = false)
  Deprecation.warn_method('pbGetEvolvedFormData', 'v20', 'EvolutionHelper.evolutions(species)')
  return EvolutionHelper.evolutions(species, ignore_none)
end

def pbGetEvolutionFamilyData(species)   # Unused
  Deprecation.warn_method('pbGetEvolutionFamilyData', 'v20', 'EvolutionHelper.family_evolutions(species)')
  return EvolutionHelper.family_evolutions(species, ignore_none)
end

def pbGetPreviousForm(species)   # Unused
  Deprecation.warn_method('pbGetPreviousForm', 'v20', 'EvolutionHelper.previous_species(species)')
  return EvolutionHelper.previous_species(species)
end

def pbGetBabySpecies(species, check_items = false, item1 = nil, item2 = nil)
  Deprecation.warn_method('pbGetBabySpecies', 'v20', 'EvolutionHelper.baby_species(species)')
  return EvolutionHelper.baby_species(species, check_items, item1, item2)
end

def pbGetMinimumLevel(species)
  Deprecation.warn_method('pbGetMinimumLevel', 'v20', 'EvolutionHelper.minimum_level(species)')
  return EvolutionHelper.minimum_level(species)
end

def pbCheckEvolutionFamilyForMethod(species, method, param = nil)
  Deprecation.warn_method('pbCheckEvolutionFamilyForMethod', 'v20', 'EvolutionHelper.check_family_for_method(species, method)')
  return EvolutionHelper.check_family_for_method(species, method, param)
end

# Used by the Moon Ball when checking if a Pokémon's evolution family includes
# an evolution that uses the Moon Stone.
def pbCheckEvolutionFamilyForItemMethodItem(species, param = nil)
  Deprecation.warn_method('pbCheckEvolutionFamilyForItemMethodItem', 'v20', 'EvolutionHelper.check_family_for_method_item(species, item)')
  return EvolutionHelper.check_family_for_method_item(species, param)
end

#===============================================================================
# Evolution checks
#===============================================================================
def pbMiniCheckEvolution(pkmn, method, parameter, new_species)
  success = PBEvolution.call("levelUpCheck", method, pkmn, parameter)
  return (success) ? new_species : nil
end

def pbMiniCheckEvolutionItem(pkmn, method, parameter, new_species, item)
  success = PBEvolution.call("itemCheck", method, pkmn, parameter, item)
  return (success) ? new_species : nil
end

# Checks whether a Pokemon can evolve now. If a block is given, calls the block
# with the following parameters:
#   Pokemon to check; evolution method; parameter; ID of the new species
def pbCheckEvolutionEx(pkmn)
  return nil if !pkmn.species || pokemon.egg? || pokemon.shadowPokemon?
  return nil if pkmn.hasItem?(:EVERSTONE)
  return nil if pkmn.hasAbility?(:BATTLEBOND)
  ret = nil
  pkmn.species_data.evolutions.each do |evo|
    next if evo[3]   # Prevolution
    ret = yield pkmn, evo[1], evo[2], evo[0]   # pkmn, method, parameter, new_species
    break if ret
  end
  return ret
end

# Checks whether a Pokemon can evolve now. If an item is used on the Pokémon,
# checks whether the Pokemon can evolve with the given item.
def pbCheckEvolution(pkmn, item = nil)
  if item
    return pbCheckEvolutionEx(pkmn) { |pkmn, method, parameter, new_species|
      next pbMiniCheckEvolutionItem(pkmn, method, parameter, new_species, item)
    }
  else
    return pbCheckEvolutionEx(pkmn) { |pkmn, method, parameter, new_species|
      next pbMiniCheckEvolution(pkmn, method, parameter, new_species)
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
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    next pkmn.level >= parameter && map_metadata && map_metadata.dark_map
  }
})

PBEvolution.register(:LevelDarkInParty, {
  "levelUpCheck" => proc { |pkmn, parameter|
    next $Trainer.has_pokemon_of_type?(:DARK) if pkmn.level >= parameter
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
    next false if $Trainer.party_full?
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
  "parameterType" => :Type,
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
    pkmn.item = nil   # Item is now consumed
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
    pkmn.item = nil   # Item is now consumed
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
    pkmn.item = nil   # Item is now consumed
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
    pkmn.item = nil   # Item is now consumed
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
    pkmn.item = nil   # Item is now consumed
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
    pkmn.item = nil   # Item is now consumed
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
    pkmn.item = nil   # Item is now consumed
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
  "parameterType" => :Type,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next pkmn.moves.any? { |m| m && m.type == parameter }
  }
})

PBEvolution.register(:HasInParty, {
  "minimumLevel"  => 1,   # Needs any level up
  "parameterType" => :Species,
  "levelUpCheck"  => proc { |pkmn, parameter|
    next $Trainer.has_species?(parameter)
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
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    next map_metadata && map_metadata.town_map_position &&
         map_metadata.town_map_position[0] == parameter
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
    pkmn.item = nil   # Item is now consumed
    next true
  }
})

PBEvolution.register(:TradeSpecies, {
  "parameterType" => :Species,
  "tradeCheck"    => proc { |pkmn, parameter, other_pkmn|
    next pkmn.species == parameter && !other_pkmn.hasItem?(:EVERSTONE)
  }
})
