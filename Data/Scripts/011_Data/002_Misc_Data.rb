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
# Pokémon data
#===============================================================================
module SpeciesData
  TYPE1              = 0
  TYPE2              = 1
  BASE_STATS         = 2
  GENDER_RATE        = 3
  GROWTH_RATE        = 4
  BASE_EXP           = 5
  EFFORT_POINTS      = 6
  RARENESS           = 7
  HAPPINESS          = 8
  ABILITIES          = 9
  HIDDEN_ABILITY     = 10
  COMPATIBILITY      = 11
  STEPS_TO_HATCH     = 12
  HEIGHT             = 13
  WEIGHT             = 14
  COLOR              = 15
  SHAPE              = 16
  HABITAT            = 17
  WILD_ITEM_COMMON   = 18
  WILD_ITEM_UNCOMMON = 19
  WILD_ITEM_RARE     = 20
  INCENSE            = 21
  POKEDEX_FORM       = 22   # For alternate forms
  MEGA_STONE         = 23   # For alternate forms
  MEGA_MOVE          = 24   # For alternate forms
  UNMEGA_FORM        = 25   # For alternate forms
  MEGA_MESSAGE       = 26   # For alternate forms

  METRIC_PLAYER_X    = 0
  METRIC_PLAYER_Y    = 1
  METRIC_ENEMY_X     = 2
  METRIC_ENEMY_Y     = 3
  METRIC_ALTITUDE    = 4
  METRIC_SHADOW_X    = 5
  METRIC_SHADOW_SIZE = 6

  def self.requiredValues(compilingForms = false)
    ret = {
      "Type1"            => [TYPE1,          "e", :PBTypes],
      "BaseStats"        => [BASE_STATS,     "vvvvvv"],
      "BaseEXP"          => [BASE_EXP,       "v"],
      "EffortPoints"     => [EFFORT_POINTS,  "uuuuuu"],
      "Rareness"         => [RARENESS,       "u"],
      "Happiness"        => [HAPPINESS,      "u"],
      "Compatibility"    => [COMPATIBILITY,  "eE", :PBEggGroups, :PBEggGroups],
      "StepsToHatch"     => [STEPS_TO_HATCH, "v"],
      "Height"           => [HEIGHT,         "f"],
      "Weight"           => [WEIGHT,         "f"],
      "Color"            => [COLOR,          "e", :PBColors],
      "Shape"            => [SHAPE,          "u"],
      "Moves"            => [0,              "*ue", nil, :PBMoves],
      "Kind"             => [0,              "s"],
      "Pokedex"          => [0,              "q"]
    }
    if !compilingForms
      ret["GenderRate"]   = [GENDER_RATE,    "e", :PBGenderRates]
      ret["GrowthRate"]   = [GROWTH_RATE,    "e", :PBGrowthRates]
      ret["Name"]         = [0,              "s"]
      ret["InternalName"] = [0,              "n"]
    end
    return ret
  end

  def self.optionalValues(compilingForms = false)
    ret = {
      "Type2"               => [TYPE2,              "e", :PBTypes],
      "Abilities"           => [ABILITIES,          "eE", :Ability, :Ability],
      "HiddenAbility"       => [HIDDEN_ABILITY,     "eEEE", :Ability, :Ability,
                                                            :Ability, :Ability],
      "Habitat"             => [HABITAT,            "e", :PBHabitats],
      "WildItemCommon"      => [WILD_ITEM_COMMON,   "e", :Item],
      "WildItemUncommon"    => [WILD_ITEM_UNCOMMON, "e", :Item],
      "WildItemRare"        => [WILD_ITEM_RARE,     "e", :Item],
      "BattlerPlayerX"      => [METRIC_PLAYER_X,    "i"],
      "BattlerPlayerY"      => [METRIC_PLAYER_Y,    "i"],
      "BattlerEnemyX"       => [METRIC_ENEMY_X,     "i"],
      "BattlerEnemyY"       => [METRIC_ENEMY_Y,     "i"],
      "BattlerAltitude"     => [METRIC_ALTITUDE,    "i"],
      "BattlerShadowX"      => [METRIC_SHADOW_X,    "i"],
      "BattlerShadowSize"   => [METRIC_SHADOW_SIZE, "u"],
      "EggMoves"            => [0,                  "*e", :PBMoves],
      "FormName"            => [0,                  "q"],
      "Evolutions"          => [0,                  "*ses", nil, :PBEvolution, nil]
    }
    if compilingForms
      ret["PokedexForm"]     = [POKEDEX_FORM,       "u"]
      ret["MegaStone"]       = [MEGA_STONE,         "e", :Item]
      ret["MegaMove"]        = [MEGA_MOVE,          "e", :PBMoves]
      ret["UnmegaForm"]      = [UNMEGA_FORM,        "u"]
      ret["MegaMessage"]     = [MEGA_MESSAGE,       "u"]
    else
      ret["Incense"]         = [INCENSE,            "e", :Item]
      ret["RegionalNumbers"] = [0,                  "*u"]
    end
    return ret
  end
end
