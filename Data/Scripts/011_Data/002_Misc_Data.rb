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
module Metadata
  HOME               = 1
  WILD_BATTLE_BGM    = 2
  TRAINER_BATTLE_BGM = 3
  WILD_VICTORY_ME    = 4
  TRAINER_VICTORY_ME = 5
  WILD_CAPTURE_ME    = 6
  SURF_BGM           = 7
  BICYCLE_BGM        = 8
  PLAYER_A           = 9
  PLAYER_B           = 10
  PLAYER_C           = 11
  PLAYER_D           = 12
  PLAYER_E           = 13
  PLAYER_F           = 14
  PLAYER_G           = 15
  PLAYER_H           = 16

  SCHEMA = {
    "Home"             => [HOME,               "uuuu"],
    "WildBattleBGM"    => [WILD_BATTLE_BGM,    "s"],
    "TrainerBattleBGM" => [TRAINER_BATTLE_BGM, "s"],
    "WildVictoryME"    => [WILD_VICTORY_ME,    "s"],
    "TrainerVictoryME" => [TRAINER_VICTORY_ME, "s"],
    "WildCaptureME"    => [WILD_CAPTURE_ME,    "s"],
    "SurfBGM"          => [SURF_BGM,           "s"],
    "BicycleBGM"       => [BICYCLE_BGM,        "s"],
    "PlayerA"          => [PLAYER_A,           "esssssss", :PBTrainers],
    "PlayerB"          => [PLAYER_B,           "esssssss", :PBTrainers],
    "PlayerC"          => [PLAYER_C,           "esssssss", :PBTrainers],
    "PlayerD"          => [PLAYER_D,           "esssssss", :PBTrainers],
    "PlayerE"          => [PLAYER_E,           "esssssss", :PBTrainers],
    "PlayerF"          => [PLAYER_F,           "esssssss", :PBTrainers],
    "PlayerG"          => [PLAYER_G,           "esssssss", :PBTrainers],
    "PlayerH"          => [PLAYER_H,           "esssssss", :PBTrainers]
  }
end

#===============================================================================
# Map-specific metadata
#===============================================================================
module MapMetadata
  OUTDOOR            = 1
  SHOW_AREA          = 2
  BICYCLE            = 3
  BICYCLE_ALWAYS     = 4
  HEALING_SPOT       = 5
  WEATHER            = 6
  MAP_POSITION       = 7
  DIVE_MAP           = 8
  DARK_MAP           = 9
  SAFARI_MAP         = 10
  SNAP_EDGES         = 11
  DUNGEON            = 12
  BATTLE_BACK        = 13
  WILD_BATTLE_BGM    = 14
  TRAINER_BATTLE_BGM = 15
  WILD_VICTORY_ME    = 16
  TRAINER_VICTORY_ME = 17
  WILD_CAPTURE_ME    = 18
  MAP_SIZE           = 19
  ENVIRONMENT        = 20

  SCHEMA = {
     "Outdoor"          => [OUTDOOR,            "b"],
     "ShowArea"         => [SHOW_AREA,          "b"],
     "Bicycle"          => [BICYCLE,            "b"],
     "BicycleAlways"    => [BICYCLE_ALWAYS,     "b"],
     "HealingSpot"      => [HEALING_SPOT,       "uuu"],
     "Weather"          => [WEATHER,            "eu", :PBFieldWeather],
     "MapPosition"      => [MAP_POSITION,       "uuu"],
     "DiveMap"          => [DIVE_MAP,           "u"],
     "DarkMap"          => [DARK_MAP,           "b"],
     "SafariMap"        => [SAFARI_MAP,         "b"],
     "SnapEdges"        => [SNAP_EDGES,         "b"],
     "Dungeon"          => [DUNGEON,            "b"],
     "BattleBack"       => [BATTLE_BACK,        "s"],
     "WildBattleBGM"    => [WILD_BATTLE_BGM,    "s"],
     "TrainerBattleBGM" => [TRAINER_BATTLE_BGM, "s"],
     "WildVictoryME"    => [WILD_VICTORY_ME,    "s"],
     "TrainerVictoryME" => [TRAINER_VICTORY_ME, "s"],
     "WildCaptureME"    => [WILD_CAPTURE_ME,    "s"],
     "MapSize"          => [MAP_SIZE,           "us"],
     "Environment"      => [ENVIRONMENT,        "e", :PBEnvironment]
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
