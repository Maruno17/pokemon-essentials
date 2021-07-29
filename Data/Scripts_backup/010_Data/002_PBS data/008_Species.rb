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
    attr_reader :gender_ratio
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
        "Compatibility"     => [0, "*e", :EggGroup],
        "StepsToHatch"      => [0, "v"],
        "Height"            => [0, "f"],
        "Weight"            => [0, "f"],
        "Color"             => [0, "e", :BodyColor],
        "Shape"             => [0, "y", :BodyShape],
        "Habitat"           => [0, "e", :Habitat],
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
        ret["Evolutions"]   = [0, "*ees", :Species, :Evolution, nil]
        ret["MegaStone"]    = [0, "e", :Item]
        ret["MegaMove"]     = [0, "e", :Move]
        ret["UnmegaForm"]   = [0, "u"]
        ret["MegaMessage"]  = [0, "u"]
      else
        ret["InternalName"] = [0, "n"]
        ret["Name"]         = [0, "s"]
        ret["GrowthRate"]   = [0, "e", :GrowthRate]
        ret["GenderRate"]   = [0, "e", :GenderRatio]
        ret["Incense"]      = [0, "e", :Item]
        ret["Evolutions"]   = [0, "*ses", nil, :Evolution, nil]
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
      @base_stats            = hash[:base_stats]            || {}
      @evs                   = hash[:evs]                   || {}
      GameData::Stat.each_main do |s|
        @base_stats[s.id] = 1 if !@base_stats[s.id] || @base_stats[s.id] <= 0
        @evs[s.id]        = 0 if !@evs[s.id] || @evs[s.id] < 0
      end
      @base_exp              = hash[:base_exp]              || 100
      @growth_rate           = hash[:growth_rate]           || :Medium
      @gender_ratio          = hash[:gender_ratio]          || :Female50Percent
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
      @egg_groups            = hash[:egg_groups]            || [:Undiscovered]
      @hatch_steps           = hash[:hatch_steps]           || 1
      @incense               = hash[:incense]
      @evolutions            = hash[:evolutions]            || []
      @height                = hash[:height]                || 1
      @weight                = hash[:weight]                || 1
      @color                 = hash[:color]                 || :Red
      @shape                 = hash[:shape]                 || :Head
      @habitat               = hash[:habitat]               || :None
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
#      return @front_sprite_altitude > 0
    end

    def get_evolutions(exclude_invalid = false)
      ret = []
      @evolutions.each do |evo|
        next if evo[3]   # Is the prevolution
        next if evo[1] == :None && exclude_invalid
        ret.push([evo[0], evo[1], evo[2]])   # [Species, method, parameter]
      end
      return ret
    end

    def get_family_evolutions(exclude_invalid = true)
      evos = self.get_evolutions(exclude_invalid)
      evos = evos.sort { |a, b| GameData::Species.get(a[0]).id_number <=> GameData::Species.get(b[0]).id_number }
      ret = []
      evos.each do |evo|
        ret.push([@species].concat(evo))   # [Prevo species, evo species, method, parameter]
        evo_array = GameData::Species.get(evo[0]).get_family_evolutions(exclude_invalid)
        ret.concat(evo_array) if evo_array && evo_array.length > 0
      end
      return ret
    end

    def get_previous_species
      return @species if @evolutions.length == 0
      @evolutions.each { |evo| return evo[0] if evo[3] }   # Is the prevolution
      return @species
    end

    def get_baby_species(check_items = false, item1 = nil, item2 = nil)
      ret = @species
      return ret if @evolutions.length == 0
      @evolutions.each do |evo|
        next if !evo[3]   # Not the prevolution
        if check_items
          incense = GameData::Species.get(evo[0]).incense
          ret = evo[0] if !incense || item1 == incense || item2 == incense
        else
          ret = evo[0]   # Species of prevolution
        end
        break
      end
      ret = GameData::Species.get(ret).get_baby_species(check_items, item1, item2) if ret != @species
      return ret
    end

    def get_related_species
      sp = self.get_baby_species
      evos = GameData::Species.get(sp).get_family_evolutions(false)
      return [sp] if evos.length == 0
      return [sp].concat(evos.map { |e| e[1] }).uniq
    end

    def family_evolutions_have_method?(check_method, check_param = nil)
      sp = self.get_baby_species
      evos = GameData::Species.get(sp).get_family_evolutions
      return false if evos.length == 0
      evos.each do |evo|
        if check_method.is_a?(Array)
          next if !check_method.include?(evo[2])
        else
          next if evo[2] != check_method
        end
        return true if check_param.nil? || evo[3] == check_param
      end
      return false
    end

    # Used by the Moon Ball when checking if a Pokémon's evolution family
    # includes an evolution that uses the Moon Stone.
    def family_item_evolutions_use_item?(check_item = nil)
      sp = self.get_baby_species
      evos = GameData::Species.get(sp).get_family_evolutions
      return false if !evos || evos.length == 0
      evos.each do |evo|
        next if GameData::Evolution.get(evo[2]).use_item_proc.nil?
        return true if check_item.nil? || evo[3] == check_item
      end
      return false
    end

    def minimum_level
      return 1 if @evolutions.length == 0
      @evolutions.each do |evo|
        next if !evo[3]   # Not the prevolution
        evo_method_data = GameData::Evolution.get(evo[1])
        next if evo_method_data.level_up_proc.nil?
        min_level = evo_method_data.minimum_level
        return (min_level == 0) ? evo[2] : min_level + 1
      end
      return 1
    end
  end
end

#===============================================================================
# Deprecated methods
#===============================================================================
# @deprecated This alias is slated to be removed in v20.
def pbGetSpeciesData(species, form = 0, species_data_type = -1)
  Deprecation.warn_method('pbGetSpeciesData', 'v20', 'GameData::Species.get_species_form(species, form).something')
  return GameData::Species.get_species_form(species, form)
end

# @deprecated This alias is slated to be removed in v20.
def pbGetSpeciesEggMoves(species, form = 0)
  Deprecation.warn_method('pbGetSpeciesEggMoves', 'v20', 'GameData::Species.get_species_form(species, form).egg_moves')
  return GameData::Species.get_species_form(species, form).egg_moves
end

# @deprecated This alias is slated to be removed in v20.
def pbGetSpeciesMoveset(species, form = 0)
  Deprecation.warn_method('pbGetSpeciesMoveset', 'v20', 'GameData::Species.get_species_form(species, form).moves')
  return GameData::Species.get_species_form(species, form).moves
end

# @deprecated This alias is slated to be removed in v20.
def pbGetEvolutionData(species)
  Deprecation.warn_method('pbGetEvolutionData', 'v20', 'GameData::Species.get(species).evolutions')
  return GameData::Species.get(species).evolutions
end

# @deprecated This alias is slated to be removed in v20.
def pbApplyBattlerMetricsToSprite(sprite, index, species_data, shadow = false, metrics = nil)
  Deprecation.warn_method('pbApplyBattlerMetricsToSprite', 'v20', 'GameData::Species.get(species).apply_metrics_to_sprite')
  GameData::Species.get(species).apply_metrics_to_sprite(sprite, index, shadow)
end

# @deprecated This alias is slated to be removed in v20.
def showShadow?(species)
  Deprecation.warn_method('showShadow?', 'v20', 'GameData::Species.get(species).shows_shadow?')
  return GameData::Species.get(species).shows_shadow?
end

# @deprecated Use {GameData#Species#get_evolutions} instead. This alias is slated to be removed in v20.
def pbGetEvolvedFormData(species, exclude_invalid = false)
  Deprecation.warn_method('pbGetEvolvedFormData', 'v20', 'GameData::Species.get(species).get_evolutions')
  return GameData::Species.get(species).get_evolutions(exclude_invalid)
end

# @deprecated Use {GameData#Species#get_family_evolutions} instead. This alias is slated to be removed in v20.
def pbGetEvolutionFamilyData(species)   # Unused
  Deprecation.warn_method('pbGetEvolutionFamilyData', 'v20', 'GameData::Species.get(species).get_family_evolutions')
  return GameData::Species.get(species).get_family_evolutions
end

# @deprecated Use {GameData#Species#get_previous_species} instead. This alias is slated to be removed in v20.
def pbGetPreviousForm(species)   # Unused
  Deprecation.warn_method('pbGetPreviousForm', 'v20', 'GameData::Species.get(species).get_previous_species')
  return GameData::Species.get(species).get_previous_species
end

# @deprecated Use {GameData#Species#get_baby_species} instead. This alias is slated to be removed in v20.
def pbGetBabySpecies(species, check_items = false, item1 = nil, item2 = nil)
  Deprecation.warn_method('pbGetBabySpecies', 'v20', 'GameData::Species.get(species).get_baby_species')
  return GameData::Species.get(species).get_baby_species(check_items, item1, item2)
end

# @deprecated Use {GameData#Species#family_evolutions_have_method?} instead. This alias is slated to be removed in v20.
def pbCheckEvolutionFamilyForMethod(species, method, param = nil)   # Unused
  Deprecation.warn_method('pbCheckEvolutionFamilyForMethod', 'v20', 'GameData::Species.get(species).family_evolutions_have_method?(method)')
  return GameData::Species.get(species).family_evolutions_have_method?(method, param)
end

# @deprecated Use {GameData#Species#family_item_evolutions_use_item?} instead. This alias is slated to be removed in v20.
def pbCheckEvolutionFamilyForItemMethodItem(species, param = nil)
  Deprecation.warn_method('pbCheckEvolutionFamilyForItemMethodItem', 'v20', 'GameData::Species.get(species).family_item_evolutions_use_item?(item)')
  return GameData::Species.get(species).family_item_evolutions_use_item?(param)
end

# @deprecated Use {GameData#Species#minimum_level} instead. This alias is slated to be removed in v20.
def pbGetMinimumLevel(species)
  Deprecation.warn_method('pbGetMinimumLevel', 'v20', 'GameData::Species.get(species).minimum_level')
  return GameData::Species.get(species).minimum_level
end
