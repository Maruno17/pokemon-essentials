#===============================================================================
# Phone data
#===============================================================================
class PhoneDatabase
  attr_accessor :generics
  attr_accessor :greetings
  attr_accessor :greetingsMorning
  attr_accessor :greetingsEvening
  attr_accessor :bodies1
  attr_accessor :bodies2
  attr_accessor :battleRequests
  attr_accessor :trainers

  def initialize
    @generics         = []
    @greetings        = []
    @greetingsMorning = []
    @greetingsEvening = []
    @bodies1          = []
    @bodies2          = []
    @battleRequests   = []
    @trainers         = []
  end
end



module PhoneMsgType
  Generic       = 0
  Greeting      = 1
  Body          = 2
  BattleRequest = 3
end



#===============================================================================
# Global and map metadata
#===============================================================================
MetadataHome             = 1
MetadataWildBattleBGM    = 2
MetadataTrainerBattleBGM = 3
MetadataWildVictoryME    = 4
MetadataTrainerVictoryME = 5
MetadataWildCaptureME    = 6
MetadataSurfBGM          = 7
MetadataBicycleBGM       = 8
MetadataPlayerA          = 9
MetadataPlayerB          = 10
MetadataPlayerC          = 11
MetadataPlayerD          = 12
MetadataPlayerE          = 13
MetadataPlayerF          = 14
MetadataPlayerG          = 15
MetadataPlayerH          = 16

MetadataOutdoor             = 1
MetadataShowArea            = 2
MetadataBicycle             = 3
MetadataBicycleAlways       = 4
MetadataHealingSpot         = 5
MetadataWeather             = 6
MetadataMapPosition         = 7
MetadataDiveMap             = 8
MetadataDarkMap             = 9
MetadataSafariMap           = 10
MetadataSnapEdges           = 11
MetadataDungeon             = 12
MetadataBattleBack          = 13
MetadataMapWildBattleBGM    = 14
MetadataMapTrainerBattleBGM = 15
MetadataMapWildVictoryME    = 16
MetadataMapTrainerVictoryME = 17
MetadataMapWildCaptureME    = 18
MetadataMapSize             = 19
MetadataEnvironment         = 20



module PokemonMetadata
  GlobalTypes = {
     "Home"             => [MetadataHome,             "uuuu"],
     "WildBattleBGM"    => [MetadataWildBattleBGM,    "s"],
     "TrainerBattleBGM" => [MetadataTrainerBattleBGM, "s"],
     "WildVictoryME"    => [MetadataWildVictoryME,    "s"],
     "TrainerVictoryME" => [MetadataTrainerVictoryME, "s"],
     "WildCaptureME"    => [MetadataWildCaptureME,    "s"],
     "SurfBGM"          => [MetadataSurfBGM,          "s"],
     "BicycleBGM"       => [MetadataBicycleBGM,       "s"],
     "PlayerA"          => [MetadataPlayerA,          "esssssss",:PBTrainers],
     "PlayerB"          => [MetadataPlayerB,          "esssssss",:PBTrainers],
     "PlayerC"          => [MetadataPlayerC,          "esssssss",:PBTrainers],
     "PlayerD"          => [MetadataPlayerD,          "esssssss",:PBTrainers],
     "PlayerE"          => [MetadataPlayerE,          "esssssss",:PBTrainers],
     "PlayerF"          => [MetadataPlayerF,          "esssssss",:PBTrainers],
     "PlayerG"          => [MetadataPlayerG,          "esssssss",:PBTrainers],
     "PlayerH"          => [MetadataPlayerH,          "esssssss",:PBTrainers]
  }
  NonGlobalTypes = {
     "Outdoor"          => [MetadataOutdoor,             "b"],
     "ShowArea"         => [MetadataShowArea,            "b"],
     "Bicycle"          => [MetadataBicycle,             "b"],
     "BicycleAlways"    => [MetadataBicycleAlways,       "b"],
     "HealingSpot"      => [MetadataHealingSpot,         "uuu"],
     "Weather"          => [MetadataWeather,             "eu",:PBFieldWeather],
     "MapPosition"      => [MetadataMapPosition,         "uuu"],
     "DiveMap"          => [MetadataDiveMap,             "u"],
     "DarkMap"          => [MetadataDarkMap,             "b"],
     "SafariMap"        => [MetadataSafariMap,           "b"],
     "SnapEdges"        => [MetadataSnapEdges,           "b"],
     "Dungeon"          => [MetadataDungeon,             "b"],
     "BattleBack"       => [MetadataBattleBack,          "s"],
     "WildBattleBGM"    => [MetadataMapWildBattleBGM,    "s"],
     "TrainerBattleBGM" => [MetadataMapTrainerBattleBGM, "s"],
     "WildVictoryME"    => [MetadataMapWildVictoryME,    "s"],
     "TrainerVictoryME" => [MetadataMapTrainerVictoryME, "s"],
     "WildCaptureME"    => [MetadataMapWildCaptureME,    "s"],
     "MapSize"          => [MetadataMapSize,             "us"],
     "Environment"      => [MetadataEnvironment,         "e",:PBEnvironment]
  }
end



#===============================================================================
# Pokémon data
#===============================================================================
SpeciesType1            = 0
SpeciesType2            = 1
SpeciesBaseStats        = 2
SpeciesGenderRate       = 3
SpeciesGrowthRate       = 4
SpeciesBaseExp          = 5
SpeciesEffortPoints     = 6
SpeciesRareness         = 7
SpeciesHappiness        = 8
SpeciesAbilities        = 9
SpeciesHiddenAbility    = 10
SpeciesCompatibility    = 11
SpeciesStepsToHatch     = 12
SpeciesHeight           = 13
SpeciesWeight           = 14
SpeciesColor            = 15
SpeciesShape            = 16
SpeciesHabitat          = 17
SpeciesWildItemCommon   = 18
SpeciesWildItemUncommon = 19
SpeciesWildItemRare     = 20
SpeciesIncense          = 21
SpeciesPokedexForm      = 22   # For alternate forms
SpeciesMegaStone        = 23   # For alternate forms
SpeciesMegaMove         = 24   # For alternate forms
SpeciesUnmegaForm       = 25   # For alternate forms
SpeciesMegaMessage      = 26   # For alternate forms

MetricBattlerPlayerX    = 0
MetricBattlerPlayerY    = 1
MetricBattlerEnemyX     = 2
MetricBattlerEnemyY     = 3
MetricBattlerAltitude   = 4
MetricBattlerShadowX    = 5
MetricBattlerShadowSize = 6



module PokemonSpeciesData
  def self.requiredValues(compilingForms=false)
    ret = {
      "Type1"            => [SpeciesType1,         "e",:PBTypes],
      "BaseStats"        => [SpeciesBaseStats,     "vvvvvv"],
      "BaseEXP"          => [SpeciesBaseExp,       "v"],
      "EffortPoints"     => [SpeciesEffortPoints,  "uuuuuu"],
      "Rareness"         => [SpeciesRareness,      "u"],
      "Happiness"        => [SpeciesHappiness,     "u"],
      "Compatibility"    => [SpeciesCompatibility, "eE",:PBEggGroups,:PBEggGroups],
      "StepsToHatch"     => [SpeciesStepsToHatch,  "v"],
      "Height"           => [SpeciesHeight,        "f"],
      "Weight"           => [SpeciesWeight,        "f"],
      "Color"            => [SpeciesColor,         "e",:PBColors],
      "Shape"            => [SpeciesShape,         "u"],
      "Moves"            => [0,                    "*ue",nil,:PBMoves],
      "Kind"             => [0,                    "s"],
      "Pokedex"          => [0,                    "q"]
    }
    if !compilingForms
      ret["GenderRate"]   = [SpeciesGenderRate,    "e",:PBGenderRates]
      ret["GrowthRate"]   = [SpeciesGrowthRate,    "e",:PBGrowthRates]
      ret["Name"]         = [0,                    "s"]
      ret["InternalName"] = [0,                    "n"]
    end
    return ret
  end

  def self.optionalValues(compilingForms=false)
    ret = {
      "Type2"               => [SpeciesType2,            "e",:PBTypes],
      "Abilities"           => [SpeciesAbilities,        "eE",:PBAbilities,:PBAbilities],
      "HiddenAbility"       => [SpeciesHiddenAbility,    "eEEE",:PBAbilities,:PBAbilities,
                                                              :PBAbilities,:PBAbilities],
      "Habitat"             => [SpeciesHabitat,          "e",:PBHabitats],
      "WildItemCommon"      => [SpeciesWildItemCommon,   "e",:PBItems],
      "WildItemUncommon"    => [SpeciesWildItemUncommon, "e",:PBItems],
      "WildItemRare"        => [SpeciesWildItemRare,     "e",:PBItems],
      "BattlerPlayerX"      => [MetricBattlerPlayerX,    "i"],
      "BattlerPlayerY"      => [MetricBattlerPlayerY,    "i"],
      "BattlerEnemyX"       => [MetricBattlerEnemyX,     "i"],
      "BattlerEnemyY"       => [MetricBattlerEnemyY,     "i"],
      "BattlerAltitude"     => [MetricBattlerAltitude,   "i"],
      "BattlerShadowX"      => [MetricBattlerShadowX,    "i"],
      "BattlerShadowSize"   => [MetricBattlerShadowSize, "u"],
      "EggMoves"            => [0,                       "*e",:PBMoves],
      "FormName"            => [0,                       "q"],
      "Evolutions"          => [0,                       "*ses",nil,:PBEvolution,nil]
    }
    if compilingForms
      ret["PokedexForm"]     = [SpeciesPokedexForm,      "u"]
      ret["MegaStone"]       = [SpeciesMegaStone,        "e",:PBItems]
      ret["MegaMove"]        = [SpeciesMegaMove,         "e",:PBMoves]
      ret["UnmegaForm"]      = [SpeciesUnmegaForm,       "u"]
      ret["MegaMessage"]     = [SpeciesMegaMessage,      "u"]
    else
      ret["Incense"]         = [SpeciesIncense,          "e",:PBItems]
      ret["RegionalNumbers"] = [0,                       "*u"]
    end
    return ret
  end
end



#===============================================================================
# Manipulation methods for metadata, phone data and Pokémon species data
#===============================================================================
class PokemonTemp
  attr_accessor :metadata
  attr_accessor :townMapData
  attr_accessor :encountersData
  attr_accessor :phoneData
  attr_accessor :regionalDexes
  attr_accessor :speciesData
  attr_accessor :speciesEggMoves
  attr_accessor :speciesMetrics
  attr_accessor :speciesMovesets
  attr_accessor :speciesTMData
  attr_accessor :speciesShadowMovesets
  attr_accessor :pokemonFormToSpecies
  attr_accessor :trainerTypesData
  attr_accessor :trainersData
  attr_accessor :moveToAnim
  attr_accessor :battleAnims
end



def pbLoadMetadata
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.metadata
    $PokemonTemp.metadata = load_data("Data/metadata.dat") || []
  end
  return $PokemonTemp.metadata
end

def pbGetMetadata(mapid,metadataType)
  meta = pbLoadMetadata
  return meta[mapid][metadataType] if meta[mapid]
  return nil
end

def pbLoadTownMapData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.townMapData
    $PokemonTemp.townMapData = load_data("Data/town_map.dat")
  end
  return $PokemonTemp.townMapData
end

def pbLoadEncountersData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.encountersData
    if pbRgssExists?("Data/encounters.dat")
      $PokemonTemp.encountersData = load_data("Data/encounters.dat")
    end
  end
  return $PokemonTemp.encountersData
end

def pbLoadPhoneData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.phoneData
    if pbRgssExists?("Data/phone.dat")
      $PokemonTemp.phoneData = load_data("Data/phone.dat")
    end
  end
  return $PokemonTemp.phoneData
end

def pbLoadRegionalDexes
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.regionalDexes
    $PokemonTemp.regionalDexes = load_data("Data/regional_dexes.dat")
  end
  return $PokemonTemp.regionalDexes
end

def pbLoadSpeciesData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesData
    $PokemonTemp.speciesData = load_data("Data/species.dat") || []
  end
  return $PokemonTemp.speciesData
end

def pbGetSpeciesData(species,form=0,speciesDataType=-1)
  species = getID(PBSpecies,species)
  s = pbGetFSpeciesFromForm(species,form)
  speciesData = pbLoadSpeciesData
  if speciesDataType<0
    return speciesData[s] || []
  end
  return speciesData[s][speciesDataType] if speciesData[s] && speciesData[s][speciesDataType]
  case speciesDataType
  when SpeciesType2;                                      return nil
  when SpeciesBaseStats;                                  return [1,1,1,1,1,1]
  when SpeciesEffortPoints;                               return [0,0,0,0,0,0]
  when SpeciesStepsToHatch, SpeciesHeight, SpeciesWeight; return 1
  end
  return 0
end

def pbLoadEggMovesData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesEggMoves
    $PokemonTemp.speciesEggMoves = load_data("Data/species_eggmoves.dat") || []
  end
  return $PokemonTemp.speciesEggMoves
end

def pbGetSpeciesEggMoves(species,form=0)
  species = getID(PBSpecies,species)
  s = pbGetFSpeciesFromForm(species,form)
  eggMovesData = pbLoadEggMovesData
  return eggMovesData[s] if eggMovesData[s]
  return []
end

def pbLoadSpeciesMetrics
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesMetrics
    $PokemonTemp.speciesMetrics = load_data("Data/species_metrics.dat") || []
  end
  return $PokemonTemp.speciesMetrics
end

def pbLoadMovesetsData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesMovesets
    $PokemonTemp.speciesMovesets = load_data("Data/species_movesets.dat") || []
  end
  return $PokemonTemp.speciesMovesets
end

def pbGetSpeciesMoveset(species,form=0)
  species = getID(PBSpecies,species)
  s = pbGetFSpeciesFromForm(species,form)
  movesetsData = pbLoadMovesetsData
  return movesetsData[s] if movesetsData[s]
  return []
end

def pbLoadSpeciesTMData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesTMData
    $PokemonTemp.speciesTMData = load_data("Data/tm.dat") || []
  end
  return $PokemonTemp.speciesTMData
end

def pbLoadShadowMovesets
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.speciesShadowMovesets
    $PokemonTemp.speciesShadowMovesets = load_data("Data/shadow_movesets.dat") || []
  end
  return $PokemonTemp.speciesShadowMovesets
end

def pbLoadFormToSpecies
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.pokemonFormToSpecies
    $PokemonTemp.pokemonFormToSpecies = load_data("Data/form2species.dat")
  end
  return $PokemonTemp.pokemonFormToSpecies
end

def pbLoadTrainerTypesData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.trainerTypesData
    $PokemonTemp.trainerTypesData = load_data("Data/trainer_types.dat") || []
  end
  return $PokemonTemp.trainerTypesData
end

def pbGetTrainerTypeData(type)
  data = pbLoadTrainerTypesData
  return data[type] if data
  return nil
end

def pbLoadTrainersData
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.trainersData
    $PokemonTemp.trainersData = load_data("Data/trainers.dat") || []
  end
  return $PokemonTemp.trainersData
end

def pbGetTrainerData(trainerID,trainerName,partyID=0)
  trainersData = pbLoadTrainersData
  ret = nil
  for t in trainersData
    next if t[0]!=trainerID || t[1]!=trainerName || t[4]!=partyID
    ret = t
    break
  end
  return ret
end

def pbLoadMoveToAnim
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.moveToAnim
    $PokemonTemp.moveToAnim = load_data("Data/move2anim.dat") || []
  end
  return $PokemonTemp.moveToAnim
end

def pbLoadBattleAnimations
  $PokemonTemp = PokemonTemp.new if !$PokemonTemp
  if !$PokemonTemp.battleAnims
    if pbRgssExists?("Data/PkmnAnimations.rxdata")
      $PokemonTemp.battleAnims = load_data("Data/PkmnAnimations.rxdata")
    end
  end
  return $PokemonTemp.battleAnims
end

def pbClearData
  if $PokemonTemp
    $PokemonTemp.metadata              = nil
    $PokemonTemp.townMapData           = nil
    $PokemonTemp.encountersData        = nil
    $PokemonTemp.phoneData             = nil
    $PokemonTemp.regionalDexes         = nil
    $PokemonTemp.speciesData           = nil
    $PokemonTemp.speciesEggMoves       = nil
    $PokemonTemp.speciesMetrics        = nil
    $PokemonTemp.speciesMovesets       = nil
    $PokemonTemp.speciesTMData         = nil
    $PokemonTemp.speciesShadowMovesets = nil
    $PokemonTemp.pokemonFormToSpecies  = nil
    $PokemonTemp.trainerTypesData      = nil
    $PokemonTemp.trainersData          = nil
    $PokemonTemp.moveToAnim            = nil
    $PokemonTemp.battleAnims           = nil
  end
  MapFactoryHelper.clear
  $PokemonEncounters.setup($game_map.map_id) if $game_map && $PokemonEncounters
  if pbRgssExists?("Data/Tilesets.rxdata")
    $data_tilesets = load_data("Data/Tilesets.rxdata")
  end
  if pbRgssExists?("Data/Tilesets.rvdata")
    $data_tilesets = load_data("Data/Tilesets.rvdata")
  end
end
