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
     "PlayerA"          => [MetadataPlayerA,          "esssssss", :PBTrainers],
     "PlayerB"          => [MetadataPlayerB,          "esssssss", :PBTrainers],
     "PlayerC"          => [MetadataPlayerC,          "esssssss", :PBTrainers],
     "PlayerD"          => [MetadataPlayerD,          "esssssss", :PBTrainers],
     "PlayerE"          => [MetadataPlayerE,          "esssssss", :PBTrainers],
     "PlayerF"          => [MetadataPlayerF,          "esssssss", :PBTrainers],
     "PlayerG"          => [MetadataPlayerG,          "esssssss", :PBTrainers],
     "PlayerH"          => [MetadataPlayerH,          "esssssss", :PBTrainers]
  }
  NonGlobalTypes = {
     "Outdoor"          => [MetadataOutdoor,             "b"],
     "ShowArea"         => [MetadataShowArea,            "b"],
     "Bicycle"          => [MetadataBicycle,             "b"],
     "BicycleAlways"    => [MetadataBicycleAlways,       "b"],
     "HealingSpot"      => [MetadataHealingSpot,         "uuu"],
     "Weather"          => [MetadataWeather,             "eu", :PBFieldWeather],
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
     "Environment"      => [MetadataEnvironment,         "e", :PBEnvironment]
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
      "Type1"            => [SpeciesType1,         "e", :PBTypes],
      "BaseStats"        => [SpeciesBaseStats,     "vvvvvv"],
      "BaseEXP"          => [SpeciesBaseExp,       "v"],
      "EffortPoints"     => [SpeciesEffortPoints,  "uuuuuu"],
      "Rareness"         => [SpeciesRareness,      "u"],
      "Happiness"        => [SpeciesHappiness,     "u"],
      "Compatibility"    => [SpeciesCompatibility, "eE", :PBEggGroups, :PBEggGroups],
      "StepsToHatch"     => [SpeciesStepsToHatch,  "v"],
      "Height"           => [SpeciesHeight,        "f"],
      "Weight"           => [SpeciesWeight,        "f"],
      "Color"            => [SpeciesColor,         "e", :PBColors],
      "Shape"            => [SpeciesShape,         "u"],
      "Moves"            => [0,                    "*ue", nil, :PBMoves],
      "Kind"             => [0,                    "s"],
      "Pokedex"          => [0,                    "q"]
    }
    if !compilingForms
      ret["GenderRate"]   = [SpeciesGenderRate,    "e", :PBGenderRates]
      ret["GrowthRate"]   = [SpeciesGrowthRate,    "e", :PBGrowthRates]
      ret["Name"]         = [0,                    "s"]
      ret["InternalName"] = [0,                    "n"]
    end
    return ret
  end

  def self.optionalValues(compilingForms = false)
    ret = {
      "Type2"               => [SpeciesType2,            "e", :PBTypes],
      "Abilities"           => [SpeciesAbilities,        "eE", :PBAbilities, :PBAbilities],
      "HiddenAbility"       => [SpeciesHiddenAbility,    "eEEE", :PBAbilities, :PBAbilities,
                                                                 :PBAbilities, :PBAbilities],
      "Habitat"             => [SpeciesHabitat,          "e", :PBHabitats],
      "WildItemCommon"      => [SpeciesWildItemCommon,   "e", :PBItems],
      "WildItemUncommon"    => [SpeciesWildItemUncommon, "e", :PBItems],
      "WildItemRare"        => [SpeciesWildItemRare,     "e", :PBItems],
      "BattlerPlayerX"      => [MetricBattlerPlayerX,    "i"],
      "BattlerPlayerY"      => [MetricBattlerPlayerY,    "i"],
      "BattlerEnemyX"       => [MetricBattlerEnemyX,     "i"],
      "BattlerEnemyY"       => [MetricBattlerEnemyY,     "i"],
      "BattlerAltitude"     => [MetricBattlerAltitude,   "i"],
      "BattlerShadowX"      => [MetricBattlerShadowX,    "i"],
      "BattlerShadowSize"   => [MetricBattlerShadowSize, "u"],
      "EggMoves"            => [0,                       "*e", :PBMoves],
      "FormName"            => [0,                       "q"],
      "Evolutions"          => [0,                       "*ses", nil, :PBEvolution, nil]
    }
    if compilingForms
      ret["PokedexForm"]     = [SpeciesPokedexForm,      "u"]
      ret["MegaStone"]       = [SpeciesMegaStone,        "e", :PBItems]
      ret["MegaMove"]        = [SpeciesMegaMove,         "e", :PBMoves]
      ret["UnmegaForm"]      = [SpeciesUnmegaForm,       "u"]
      ret["MegaMessage"]     = [SpeciesMegaMessage,      "u"]
    else
      ret["Incense"]         = [SpeciesIncense,          "e", :PBItems]
      ret["RegionalNumbers"] = [0,                       "*u"]
    end
    return ret
  end
end
