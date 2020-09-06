module PBEvolution
  None              = 0   # Do not use
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
  Custom1           = 32
  Custom2           = 33
  Custom3           = 34
  Custom4           = 35

  EVONAMES = ["None",
     "Happiness",    "HappinessDay", "HappinessNight",   "Level",         "Trade",
     "TradeItem",    "Item",         "AttackGreater",    "AtkDefEqual",   "DefenseGreater",
     "Silcoon",      "Cascoon",      "Ninjask",          "Shedinja",      "Beauty",
     "ItemMale",     "ItemFemale",   "DayHoldItem",      "NightHoldItem", "HasMove",
     "HasInParty",   "LevelMale",    "LevelFemale",      "Location",      "TradeSpecies",
     "LevelDay",     "LevelNight",   "LevelDarkInParty", "LevelRain",     "HappinessMoveType",
     "LevelEvening", "Custom1",      "Custom2",          "Custom3",       "Custom4",
  ]

  # 0 = no parameter
  # 1 = Positive integer
  # 2 = Item internal name
  # 3 = Move internal name
  # 4 = Species internal name
  # 5 = Type internal name
  # 6 = Ability internal name
  EVOPARAM = [0,   # None (do not use)
     0,0,0,1,0,    # Happiness, HappinessDay, HappinessNight, Level, Trade
     2,2,1,1,1,    # TradeItem, Item, AttackGreater, AtkDefEqual, DefenseGreater
     1,1,1,1,1,    # Silcoon, Cascoon, Ninjask, Shedinja, Beauty
     2,2,2,2,3,    # ItemMale, ItemFemale, DayHoldItem, NightHoldItem, HasMove
     4,1,1,1,4,    # HasInParty, LevelMale, LevelFemale, Location, TradeSpecies
     1,1,1,1,5,    # LevelDay, LevelNight, LevelDarkInParty, LevelRain, HappinessMoveType
     1,1,1,1,1     # LevelEvening, Custom 1-4
  ]
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
  methodsWithMinLevel = [
     PBEvolution::Level, PBEvolution::LevelMale, PBEvolution::LevelFemale,
     PBEvolution::AttackGreater, PBEvolution::AtkDefEqual, PBEvolution::DefenseGreater,
     PBEvolution::Silcoon, PBEvolution::Cascoon,
     PBEvolution::Ninjask, PBEvolution::Shedinja,
     PBEvolution::LevelDay, PBEvolution::LevelNight,
     PBEvolution::LevelDarkInParty, PBEvolution::LevelRain
  ]
  evoData = pbGetEvolutionData(species)
  return 1 if !evoData || evoData.length==0
  ret = -1
  evoData.each do |evo|
    if evo[3] && methodsWithMinLevel.include?(evo[1])   # Is the prevolution
      ret = (ret<0) ? evo[2] : [ret,evo[2]].min
      break
    end
  end
  return (ret==-1) ? 1 : ret
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
def pbCheckEvolutionFamilyForMethod(species,method,param=-1)
  species = pbGetBabySpecies(species)
  evos = pbGetEvolutionFamilyData(species)
  return false if !evos || evos.length==0
  for evo in evos
    if method.is_a?(Array)
      next if !method.include?(evo[1])
    elsif method>=0
      next if evo[1]!=method
    end
    next if param>=0 && evo[2]!=param
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
# Evolution methods
#===============================================================================
def pbMiniCheckEvolution(pokemon,evonib,level,poke)
  case evonib
  when PBEvolution::Happiness
    return poke if pokemon.happiness>=220
  when PBEvolution::HappinessDay
    return poke if pokemon.happiness>=220 && PBDayNight.isDay?
  when PBEvolution::HappinessNight
    return poke if pokemon.happiness>=220 && PBDayNight.isNight?
  when PBEvolution::HappinessMoveType
    if pokemon.happiness>=220
      for m in pokemon.moves
        return poke if m.id>0 && m.type==level
      end
    end
  when PBEvolution::Level
    return poke if pokemon.level>=level
  when PBEvolution::LevelDay
    return poke if pokemon.level>=level && PBDayNight.isDay?
  when PBEvolution::LevelNight
    return poke if pokemon.level>=level && PBDayNight.isNight?
  when PBEvolution::LevelEvening
    return poke if pokemon.level>=level && PBDayNight.isEvening?
  when PBEvolution::LevelMale
    return poke if pokemon.level>=level && pokemon.male?
  when PBEvolution::LevelFemale
    return poke if pokemon.level>=level && pokemon.female?
  when PBEvolution::AttackGreater    # Hitmonlee
    return poke if pokemon.level>=level && pokemon.attack>pokemon.defense
  when PBEvolution::AtkDefEqual      # Hitmontop
    return poke if pokemon.level>=level && pokemon.attack==pokemon.defense
  when PBEvolution::DefenseGreater   # Hitmonchan
    return poke if pokemon.level>=level && pokemon.attack<pokemon.defense
  when PBEvolution::Silcoon
    return poke if pokemon.level>=level && (((pokemon.personalID>>16)&0xFFFF)%10)<5
  when PBEvolution::Cascoon
    return poke if pokemon.level>=level && (((pokemon.personalID>>16)&0xFFFF)%10)>=5
  when PBEvolution::Ninjask
    return poke if pokemon.level>=level
  when PBEvolution::Shedinja
    return -1
  when PBEvolution::DayHoldItem
    return poke if pokemon.item==level && PBDayNight.isDay?
  when PBEvolution::NightHoldItem
    return poke if pokemon.item==level && PBDayNight.isNight?
  when PBEvolution::HasMove
    for m in pokemon.moves
      return poke if m.id==level
    end
  when PBEvolution::HasInParty
    for i in $Trainer.pokemonParty
      return poke if i.species==level
    end
  when PBEvolution::LevelDarkInParty
    if pokemon.level>=level
      for i in $Trainer.pokemonParty
        return poke if i.hasType?(:DARK)
      end
    end
  when PBEvolution::Location
    return poke if $game_map.map_id==level
  when PBEvolution::LevelRain
    if pokemon.level>=level
      if $game_screen && ($game_screen.weather_type==PBFieldWeather::Rain ||
                          $game_screen.weather_type==PBFieldWeather::HeavyRain ||
                          $game_screen.weather_type==PBFieldWeather::Storm)
        return poke
      end
    end
  when PBEvolution::Beauty   # Feebas
    return poke if pokemon.beauty>=level
  when PBEvolution::Trade, PBEvolution::TradeItem, PBEvolution::TradeSpecies
    return -1
  when PBEvolution::Custom1
    # Add code for custom evolution type 1
  when PBEvolution::Custom2
    # Add code for custom evolution type 2
  when PBEvolution::Custom3
    # Add code for custom evolution type 3
  when PBEvolution::Custom4
    # Add code for custom evolution type 4
  end
  return -1
end

def pbMiniCheckEvolutionItem(pokemon,evonib,level,poke,item)
  # Checks for when an item is used on the Pokémon (e.g. an evolution stone)
  case evonib
  when PBEvolution::Item
    return poke if level==item
  when PBEvolution::ItemMale
    return poke if level==item && pokemon.male?
  when PBEvolution::ItemFemale
    return poke if level==item && pokemon.female?
  end
  return -1
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
