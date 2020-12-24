module GameData
  class Species
    attr_reader :id
    attr_reader :id_number
    attr_reader :species
    attr_reader :form
    attr_reader :real_name
    attr_reader :real_form_name
    attr_reader :real_category
    attr_reader :real_pokedex_entry
    attr_reader :pokedex_form
    attr_reader :type1
    attr_reader :type2
    attr_reader :base_stats
    attr_reader :evs
    attr_reader :base_exp
    attr_reader :growth_rate
    attr_reader :gender_rate
    attr_reader :catch_rate
    attr_reader :happiness
    attr_reader :moves
    attr_reader :tutor_moves
    attr_reader :egg_moves
    attr_reader :abilities
    attr_reader :hidden_abilities
    attr_reader :wild_item_common
    attr_reader :wild_item_uncommon
    attr_reader :wild_item_rare
    attr_reader :egg_groups
    attr_reader :hatch_steps
    attr_reader :incense
    attr_reader :evolutions
    attr_reader :height
    attr_reader :weight
    attr_reader :color
    attr_reader :shape
    attr_reader :habitat
    attr_reader :generation
    attr_reader :mega_stone
    attr_reader :mega_move
    attr_reader :unmega_form
    attr_reader :mega_message
    attr_accessor :back_sprite_x
    attr_accessor :back_sprite_y
    attr_accessor :front_sprite_x
    attr_accessor :front_sprite_y
    attr_accessor :front_sprite_altitude
    attr_accessor :shadow_x
    attr_accessor :shadow_size

    DATA = {}
    DATA_FILENAME = "species.dat"

    extend ClassMethods
    include InstanceMethods

    # @param species [Symbol, self, String, Integer]
    # @param form [Integer]
    # @return [self, nil]
    def self.get_species_form(species, form)
      return nil if !species || !form
      validate species => [Symbol, self, String, Integer]
      validate form => Integer
#      if other.is_a?(Integer)
#        p "Please switch to symbols, thanks."
#      end
      species = species.species if species.is_a?(self)
      species = DATA[species].species if species.is_a?(Integer)
      species = species.to_sym if species.is_a?(String)
      trial = sprintf("%s_%d", species, form).to_sym
      species_form = (DATA[trial].nil?) ? species : trial
      return (DATA.has_key?(species_form)) ? DATA[species_form] : nil
    end

    # TODO: Needs tidying up.
    def self.schema(compiling_forms = false)
      ret = {
        "FormName"          => [0, "q"],
        "Kind"              => [0, "s"],
        "Pokedex"           => [0, "q"],
        "Type1"             => [0, "e", :Type],
        "Type2"             => [0, "e", :Type],
        "BaseStats"         => [0, "vvvvvv"],
        "EffortPoints"      => [0, "uuuuuu"],
        "BaseEXP"           => [0, "v"],
        "Rareness"          => [0, "u"],
        "Happiness"         => [0, "u"],
        "Moves"             => [0, "*ue", nil, :Move],
        "TutorMoves"        => [0, "*e", :Move],
        "EggMoves"          => [0, "*e", :Move],
        "Abilities"         => [0, "*e", :Ability],
        "HiddenAbility"     => [0, "*e", :Ability],
        "WildItemCommon"    => [0, "e", :Item],
        "WildItemUncommon"  => [0, "e", :Item],
        "WildItemRare"      => [0, "e", :Item],
        "Compatibility"     => [0, "*e", :PBEggGroups],
        "StepsToHatch"      => [0, "v"],
        "Height"            => [0, "f"],
        "Weight"            => [0, "f"],
        "Color"             => [0, "e", :PBColors],
        "Shape"             => [0, "u"],
        "Habitat"           => [0, "e", :PBHabitats],
        "Generation"        => [0, "i"],
        "BattlerPlayerX"    => [0, "i"],
        "BattlerPlayerY"    => [0, "i"],
        "BattlerEnemyX"     => [0, "i"],
        "BattlerEnemyY"     => [0, "i"],
        "BattlerAltitude"   => [0, "i"],
        "BattlerShadowX"    => [0, "i"],
        "BattlerShadowSize" => [0, "u"]
      }
      if compiling_forms
        ret["PokedexForm"]  = [0, "u"]
        ret["Evolutions"]   = [0, "*ees", :Species, :PBEvolution, nil]
        ret["MegaStone"]    = [0, "e", :Item]
        ret["MegaMove"]     = [0, "e", :Move]
        ret["UnmegaForm"]   = [0, "u"]
        ret["MegaMessage"]  = [0, "u"]
      else
        ret["InternalName"] = [0, "n"]
        ret["Name"]         = [0, "s"]
        ret["GrowthRate"]   = [0, "e", :PBGrowthRates]
        ret["GenderRate"]   = [0, "e", :PBGenderRates]
        ret["Incense"]      = [0, "e", :Item]
        ret["Evolutions"]   = [0, "*ses", nil, :PBEvolution, nil]
      end
      return ret
    end

    def initialize(hash)
      @id                    = hash[:id]
      @id_number             = hash[:id_number]             || -1
      @species               = hash[:species]               || @id
      @form                  = hash[:form]                  || 0
      @real_name             = hash[:name]                  || "Unnamed"
      @real_form_name        = hash[:form_name]
      @real_category         = hash[:category]              || "???"
      @real_pokedex_entry    = hash[:pokedex_entry]         || "???"
      @pokedex_form          = hash[:pokedex_form]          || @form
      @type1                 = hash[:type1]                 || :NORMAL
      @type2                 = hash[:type2]                 || @type1
      @base_stats            = hash[:base_stats]            || [1, 1, 1, 1, 1, 1]
      @evs                   = hash[:evs]                   || [0, 0, 0, 0, 0, 0]
      @base_exp              = hash[:base_exp]              || 100
      @growth_rate           = hash[:growth_rate]           || PBGrowthRates::Medium
      @gender_rate           = hash[:gender_rate]           || PBGenderRates::Female50Percent
      @catch_rate            = hash[:catch_rate]            || 255
      @happiness             = hash[:happiness]             || 70
      @moves                 = hash[:moves]                 || []
      @tutor_moves           = hash[:tutor_moves]           || []
      @egg_moves             = hash[:egg_moves]             || []
      @abilities             = hash[:abilities]             || []
      @hidden_abilities      = hash[:hidden_abilities]      || []
      @wild_item_common      = hash[:wild_item_common]
      @wild_item_uncommon    = hash[:wild_item_uncommon]
      @wild_item_rare        = hash[:wild_item_rare]
      @egg_groups            = hash[:egg_groups]            || [PBEggGroups::Undiscovered]
      @hatch_steps           = hash[:hatch_steps]           || 1
      @incense               = hash[:incense]
      @evolutions            = hash[:evolutions]            || []
      @height                = hash[:height]                || 1
      @weight                = hash[:weight]                || 1
      @color                 = hash[:color]                 || PBColors::Red
      @shape                 = hash[:shape]                 || 1
      @habitat               = hash[:habitat]               || PBHabitats::None
      @generation            = hash[:generation]            || 0
      @mega_stone            = hash[:mega_stone]
      @mega_move             = hash[:mega_move]
      @unmega_form           = hash[:unmega_form]           || 0
      @mega_message          = hash[:mega_message]          || 0
      @back_sprite_x         = hash[:back_sprite_x]         || 0
      @back_sprite_y         = hash[:back_sprite_y]         || 0
      @front_sprite_x        = hash[:front_sprite_x]        || 0
      @front_sprite_y        = hash[:front_sprite_y]        || 0
      @front_sprite_altitude = hash[:front_sprite_altitude] || 0
      @shadow_x              = hash[:shadow_x]              || 0
      @shadow_size           = hash[:shadow_size]           || 2
    end

    # @return [String] the translated name of this species
    def name
      return pbGetMessage(MessageTypes::Species, @id_number)
    end

    # @return [String] the translated name of this form of this species
    def form_name
      return pbGetMessage(MessageTypes::FormNames, @id_number)
    end

    # @return [String] the translated Pokédex category of this species
    def category
      return pbGetMessage(MessageTypes::Kinds, @id_number)
    end

    # @return [String] the translated Pokédex entry of this species
    def pokedex_entry
      return pbGetMessage(MessageTypes::Entries, @id_number)
    end
  end

  def apply_metrics_to_sprite(sprite, index, shadow = false)
    if shadow
      if (index & 1) == 1   # Foe Pokémon
        sprite.x += @shadow_x * 2
      end
    else
      if (index & 1) == 0   # Player's Pokémon
        sprite.x += @back_sprite_x * 2
        sprite.y += @back_sprite_y * 2
      else                  # Foe Pokémon
        sprite.x += @front_sprite_x * 2
        sprite.y += @front_sprite_y * 2
        sprite.y -= @front_sprite_altitude * 2
      end
    end
  end

  def shows_shadow?
    return true
#    return @front_sprite_altitude > 0
  end
end

#===============================================================================
# Deprecated methods
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
  METRIC_PLAYER_X    = 27
  METRIC_PLAYER_Y    = 28
  METRIC_ENEMY_X     = 29
  METRIC_ENEMY_Y     = 30
  METRIC_ALTITUDE    = 31
  METRIC_SHADOW_X    = 32
  METRIC_SHADOW_SIZE = 33
end

#===============================================================================
# Methods to get Pokémon species data.
#===============================================================================
def pbGetSpeciesData(species, form = 0, species_data_type = -1)
  Deprecation.warn_method('pbGetSpeciesData', 'v20', 'GameData::Species.get_species_form(species, form).something')
  ret = GameData::Species.get_species_form(species, form)
  return ret if species_data_type == -1
  case species_data_type
  when SpeciesData::TYPE1              then return ret.type1
  when SpeciesData::TYPE2              then return ret.type2
  when SpeciesData::BASE_STATS         then return ret.base_stats
  when SpeciesData::GENDER_RATE        then return ret.gender_rate
  when SpeciesData::GROWTH_RATE        then return ret.growth_rate
  when SpeciesData::BASE_EXP           then return ret.base_exp
  when SpeciesData::EFFORT_POINTS      then return ret.evs
  when SpeciesData::RARENESS           then return ret.catch_rate
  when SpeciesData::HAPPINESS          then return ret.happiness
  when SpeciesData::ABILITIES          then return ret.abilities
  when SpeciesData::HIDDEN_ABILITY     then return ret.hidden_abilities
  when SpeciesData::COMPATIBILITY      then return ret.egg_groups
  when SpeciesData::STEPS_TO_HATCH     then return ret.hatch_steps
  when SpeciesData::HEIGHT             then return ret.height
  when SpeciesData::WEIGHT             then return ret.weight
  when SpeciesData::COLOR              then return ret.color
  when SpeciesData::SHAPE              then return ret.shape
  when SpeciesData::HABITAT            then return ret.habitat
  when SpeciesData::WILD_ITEM_COMMON   then return ret.wild_item_common
  when SpeciesData::WILD_ITEM_UNCOMMON then return ret.wild_item_uncommon
  when SpeciesData::WILD_ITEM_RARE     then return ret.wild_item_rare
  when SpeciesData::INCENSE            then return ret.incense
  when SpeciesData::POKEDEX_FORM       then return ret.pokedex_form
  when SpeciesData::MEGA_STONE         then return ret.mega_stone
  when SpeciesData::MEGA_MOVE          then return ret.mega_move
  when SpeciesData::UNMEGA_FORM        then return ret.unmega_form
  when SpeciesData::MEGA_MESSAGE       then return ret.mega_message
  when SpeciesData::METRIC_PLAYER_X    then return ret.back_sprite_x
  when SpeciesData::METRIC_PLAYER_Y    then return ret.back_sprite_y
  when SpeciesData::METRIC_ENEMY_X     then return ret.front_sprite_x
  when SpeciesData::METRIC_ENEMY_Y     then return ret.front_sprite_y
  when SpeciesData::METRIC_ALTITUDE    then return ret.front_sprite_altitude
  when SpeciesData::METRIC_SHADOW_X    then return ret.shadow_x
  when SpeciesData::METRIC_SHADOW_SIZE then return ret.shadow_size
  end
  return 0
end

#===============================================================================
# Methods to get Pokémon moves data.
#===============================================================================
def pbGetSpeciesEggMoves(species, form = 0)
  Deprecation.warn_method('pbGetSpeciesEggMoves', 'v20', 'GameData::Species.get_species_form(species, form).egg_moves')
  return GameData::Species.get_species_form(species, form).egg_moves
end

def pbGetSpeciesMoveset(species, form = 0)
  Deprecation.warn_method('pbGetSpeciesMoveset', 'v20', 'GameData::Species.get_species_form(species, form).moves')
  return GameData::Species.get_species_form(species, form).moves
end

def pbGetEvolutionData(species)
  Deprecation.warn_method('pbGetEvolutionData', 'v20', 'GameData::Species.get(species).evolutions')
  return GameData::Species.get(species).evolutions
end

#===============================================================================
# Method to get Pokémon species metrics (sprite positioning) data.
#===============================================================================
def pbApplyBattlerMetricsToSprite(sprite, index, species_data, shadow = false, metrics = nil)
  Deprecation.warn_method('pbApplyBattlerMetricsToSprite', 'v20', 'GameData::Species.get(species).apply_metrics_to_sprite')
  GameData::Species.get(species).apply_metrics_to_sprite(sprite, index, shadow)
end

def showShadow?(species)
  Deprecation.warn_method('showShadow?', 'v20', 'GameData::Species.get(species).shows_shadow?')
  return GameData::Species.get(species).shows_shadow?
end
