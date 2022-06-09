module GameData
  class Species
    attr_reader :id
    attr_reader :species
    attr_reader :form
    attr_reader :real_name
    attr_reader :real_form_name
    attr_reader :real_category
    attr_reader :real_pokedex_entry
    attr_reader :pokedex_form
    attr_reader :types
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
    attr_reader :offspring
    attr_reader :evolutions
    attr_reader :height
    attr_reader :weight
    attr_reader :color
    attr_reader :shape
    attr_reader :habitat
    attr_reader :generation
    attr_reader :flags
    attr_reader :mega_stone
    attr_reader :mega_move
    attr_reader :unmega_form
    attr_reader :mega_message

    DATA = {}
    DATA_FILENAME = "species.dat"

    extend ClassMethodsSymbols
    include InstanceMethods

    # @param species [Symbol, self, String]
    # @param form [Integer]
    # @return [self, nil]
    def self.get_species_form(species, form)
      return nil if !species || !form
      validate species => [Symbol, self, String]
      validate form => Integer
      species = species.species if species.is_a?(self)
      species = species.to_sym if species.is_a?(String)
      trial = sprintf("%s_%d", species, form).to_sym
      species_form = (DATA[trial].nil?) ? species : trial
      return (DATA.has_key?(species_form)) ? DATA[species_form] : nil
    end

    def self.each_species
      DATA.each_value { |species| yield species if species.form == 0 }
    end

    def self.species_count
      ret = 0
      self.each_species { |species| ret += 1 }
      return ret
    end

    def self.schema(compiling_forms = false)
      ret = {
        "FormName"          => [0, "q"],
        "Category"          => [0, "s"],
        "Pokedex"           => [0, "q"],
        "Types"             => [0, "eE", :Type, :Type],
        "BaseStats"         => [0, "vvvvvv"],
        "EVs"               => [0, "*ev", :Stat],
        "BaseExp"           => [0, "v"],
        "CatchRate"         => [0, "u"],
        "Happiness"         => [0, "u"],
        "Moves"             => [0, "*ue", nil, :Move],
        "TutorMoves"        => [0, "*e", :Move],
        "EggMoves"          => [0, "*e", :Move],
        "Abilities"         => [0, "*e", :Ability],
        "HiddenAbilities"   => [0, "*e", :Ability],
        "WildItemCommon"    => [0, "*e", :Item],
        "WildItemUncommon"  => [0, "*e", :Item],
        "WildItemRare"      => [0, "*e", :Item],
        "EggGroups"         => [0, "*e", :EggGroup],
        "HatchSteps"        => [0, "v"],
        "Height"            => [0, "f"],
        "Weight"            => [0, "f"],
        "Color"             => [0, "e", :BodyColor],
        "Shape"             => [0, "e", :BodyShape],
        "Habitat"           => [0, "e", :Habitat],
        "Generation"        => [0, "i"],
        "Flags"             => [0, "*s"],
        "BattlerPlayerX"    => [0, "i"],
        "BattlerPlayerY"    => [0, "i"],
        "BattlerEnemyX"     => [0, "i"],
        "BattlerEnemyY"     => [0, "i"],
        "BattlerAltitude"   => [0, "i"],
        "BattlerShadowX"    => [0, "i"],
        "BattlerShadowSize" => [0, "u"],
        # All properties below here are old names for some properties above.
        # They will be removed in v21.
        "Type1"             => [0, "e", :Type],
        "Type2"             => [0, "e", :Type],
        "Rareness"          => [0, "u"],
        "Compatibility"     => [0, "*e", :EggGroup],
        "Kind"              => [0, "s"],
        "BaseEXP"           => [0, "v"],
        "EffortPoints"      => [0, "*ev", :Stat],
        "HiddenAbility"     => [0, "*e", :Ability],
        "StepsToHatch"      => [0, "v"]
      }
      if compiling_forms
        ret["PokedexForm"]  = [0, "u"]
        ret["Offspring"]    = [0, "*e", :Species]
        ret["Evolutions"]   = [0, "*ees", :Species, :Evolution, nil]
        ret["MegaStone"]    = [0, "e", :Item]
        ret["MegaMove"]     = [0, "e", :Move]
        ret["UnmegaForm"]   = [0, "u"]
        ret["MegaMessage"]  = [0, "u"]
      else
        ret["InternalName"] = [0, "n"]
        ret["Name"]         = [0, "s"]
        ret["GrowthRate"]   = [0, "e", :GrowthRate]
        ret["GenderRatio"]  = [0, "e", :GenderRatio]
        ret["Incense"]      = [0, "e", :Item]
        ret["Offspring"]    = [0, "*s"]
        ret["Evolutions"]   = [0, "*ses", nil, :Evolution, nil]
        # All properties below here are old names for some properties above.
        # They will be removed in v21.
        ret["GenderRate"]   = [0, "e", :GenderRatio]
      end
      return ret
    end

    def initialize(hash)
      @id                 = hash[:id]
      @species            = hash[:species]            || @id
      @form               = hash[:form]               || 0
      @real_name          = hash[:name]               || "Unnamed"
      @real_form_name     = hash[:form_name]
      @real_category      = hash[:category]           || "???"
      @real_pokedex_entry = hash[:pokedex_entry]      || "???"
      @pokedex_form       = hash[:pokedex_form]       || @form
      @types              = hash[:types]              || [:NORMAL]
      @base_stats         = hash[:base_stats]         || {}
      @evs                = hash[:evs]                || {}
      GameData::Stat.each_main do |s|
        @base_stats[s.id] = 1 if !@base_stats[s.id] || @base_stats[s.id] <= 0
        @evs[s.id]        = 0 if !@evs[s.id] || @evs[s.id] < 0
      end
      @base_exp           = hash[:base_exp]           || 100
      @growth_rate        = hash[:growth_rate]        || :Medium
      @gender_ratio       = hash[:gender_ratio]       || :Female50Percent
      @catch_rate         = hash[:catch_rate]         || 255
      @happiness          = hash[:happiness]          || 70
      @moves              = hash[:moves]              || []
      @tutor_moves        = hash[:tutor_moves]        || []
      @egg_moves          = hash[:egg_moves]          || []
      @abilities          = hash[:abilities]          || []
      @hidden_abilities   = hash[:hidden_abilities]   || []
      @wild_item_common   = hash[:wild_item_common]   || []
      @wild_item_uncommon = hash[:wild_item_uncommon] || []
      @wild_item_rare     = hash[:wild_item_rare]     || []
      @egg_groups         = hash[:egg_groups]         || [:Undiscovered]
      @hatch_steps        = hash[:hatch_steps]        || 1
      @incense            = hash[:incense]
      @offspring          = hash[:offspring]          || []
      @evolutions         = hash[:evolutions]         || []
      @height             = hash[:height]             || 1
      @weight             = hash[:weight]             || 1
      @color              = hash[:color]              || :Red
      @shape              = hash[:shape]              || :Head
      @habitat            = hash[:habitat]            || :None
      @generation         = hash[:generation]         || 0
      @flags              = hash[:flags]              || []
      @mega_stone         = hash[:mega_stone]
      @mega_move          = hash[:mega_move]
      @unmega_form        = hash[:unmega_form]        || 0
      @mega_message       = hash[:mega_message]       || 0
    end

    # @return [String] the translated name of this species
    def name
      return pbGetMessageFromHash(MessageTypes::Species, @real_name)
    end

    # @return [String] the translated name of this form of this species
    def form_name
      return pbGetMessageFromHash(MessageTypes::FormNames, @real_form_name)
    end

    # @return [String] the translated Pokédex category of this species
    def category
      return pbGetMessageFromHash(MessageTypes::Kinds, @real_category)
    end

    # @return [String] the translated Pokédex entry of this species
    def pokedex_entry
      return pbGetMessageFromHash(MessageTypes::Entries, @real_pokedex_entry)
    end

    def default_form
      @flags.each do |flag|
        return $~[1].to_i if flag[/^DefaultForm_(\d+)$/i]
      end
      return -1
    end

    def base_form
      default = default_form
      return (default >= 0) ? default : @form
    end

    def single_gendered?
      return GameData::GenderRatio.get(@gender_ratio).single_gendered?
    end

    def base_stat_total
      return @base_stats.values.sum
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    def apply_metrics_to_sprite(sprite, index, shadow = false)
      metrics_data = GameData::SpeciesMetrics.get_species_form(@species, @form)
      metrics_data.apply_metrics_to_sprite(sprite, index, shadow)
    end

    def shows_shadow?
      metrics_data = GameData::SpeciesMetrics.get_species_form(@species, @form)
      return metrics_data.shows_shadow?
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
      evos = get_evolutions(exclude_invalid)
      evos = evos.sort { |a, b| GameData::Species.keys.index(a[0]) <=> GameData::Species.keys.index(b[0]) }
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

    # Returns an array of all the species in this species' evolution family.
    def get_family_species
      sp = get_baby_species
      evos = GameData::Species.get(sp).get_family_evolutions(false)
      return [sp] if evos.length == 0
      return [sp].concat(evos.map { |e| e[1] }).uniq
    end

    # This takes into account whether other_species is evolved.
    def breeding_can_produce?(other_species)
      other_family = GameData::Species.get(other_species).get_family_species
      if @offspring.length > 0
        return (other_family & @offspring).length > 0
      end
      return other_family.include?(@species)
    end

    # If this species doesn't have egg moves, looks at prevolutions one at a
    # time and returns theirs instead.
    def get_egg_moves
      return @egg_moves if !@egg_moves.empty?
      prevo = get_previous_species
      return GameData::Species.get_species_form(prevo, @form).get_egg_moves if prevo != @species
      return @egg_moves
    end

    def family_evolutions_have_method?(check_method, check_param = nil)
      sp = get_baby_species
      evos = GameData::Species.get(sp).get_family_evolutions
      return false if evos.length == 0
      evos.each do |evo|
        if check_method.is_a?(Array)
          next if !check_method.include?(evo[2])
        elsif evo[2] != check_method
          next
        end
        return true if check_param.nil? || evo[3] == check_param
      end
      return false
    end

    # Used by the Moon Ball when checking if a Pokémon's evolution family
    # includes an evolution that uses the Moon Stone.
    def family_item_evolutions_use_item?(check_item = nil)
      sp = get_baby_species
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
