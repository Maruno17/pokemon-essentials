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
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "species.dat"
    PBS_BASE_FILENAME = ["pokemon", "pokemon_forms"]

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.schema(compiling_forms = false)
      ret = {}
      if compiling_forms
        ret["SectionName"]    = [:id,                 "ev", :Species]
      else
        ret["SectionName"]    = [:id,                 "m"]
        ret["Name"]           = [:real_name,          "s"]
      end
      ret["FormName"]         = [:real_form_name,     "q"]
      if compiling_forms
        ret["PokedexForm"]    = [:pokedex_form,       "u"]
        ret["MegaStone"]      = [:mega_stone,         "e", :Item]
        ret["MegaMove"]       = [:mega_move,          "e", :Move]
        ret["UnmegaForm"]     = [:unmega_form,        "u"]
        ret["MegaMessage"]    = [:mega_message,       "u"]
      end
      ret["Types"]            = [:types,              "*e", :Type]
      ret["BaseStats"]        = [:base_stats,         "vvvvvv"]
      if !compiling_forms
        ret["GenderRatio"]    = [:gender_ratio,       "e", :GenderRatio]
        ret["GrowthRate"]     = [:growth_rate,        "e", :GrowthRate]
      end
      ret["BaseExp"]          = [:base_exp,           "v"]
      ret["EVs"]              = [:evs,                "*ev", :Stat]
      ret["CatchRate"]        = [:catch_rate,         "u"]
      ret["Happiness"]        = [:happiness,          "u"]
      ret["Abilities"]        = [:abilities,          "*e", :Ability]
      ret["HiddenAbilities"]  = [:hidden_abilities,   "*e", :Ability]
      ret["Moves"]            = [:moves,              "*ue", nil, :Move]
      ret["TutorMoves"]       = [:tutor_moves,        "*e", :Move]
      ret["EggMoves"]         = [:egg_moves,          "*e", :Move]
      ret["EggGroups"]        = [:egg_groups,         "*e", :EggGroup]
      ret["HatchSteps"]       = [:hatch_steps,        "v"]
      if compiling_forms
        ret["Offspring"]      = [:offspring,          "*e", :Species]
      else
        ret["Incense"]        = [:incense,            "e", :Item]
        ret["Offspring"]      = [:offspring,          "*s"]
      end
      ret["Height"]           = [:height,             "f"]
      ret["Weight"]           = [:weight,             "f"]
      ret["Color"]            = [:color,              "e", :BodyColor]
      ret["Shape"]            = [:shape,              "e", :BodyShape]
      ret["Habitat"]          = [:habitat,            "e", :Habitat]
      ret["Category"]         = [:real_category,      "s"]
      ret["Pokedex"]          = [:real_pokedex_entry, "q"]
      ret["Generation"]       = [:generation,         "i"]
      ret["Flags"]            = [:flags,              "*s"]
      ret["WildItemCommon"]   = [:wild_item_common,   "*e", :Item]
      ret["WildItemUncommon"] = [:wild_item_uncommon, "*e", :Item]
      ret["WildItemRare"]     = [:wild_item_rare,     "*e", :Item]
      if compiling_forms
        ret["Evolutions"]     = [:evolutions,         "*ees", :Species, :Evolution, nil]
      else
        ret["Evolutions"]     = [:evolutions,         "*ses", nil, :Evolution, nil]
      end
      return ret
    end

    def self.editor_properties
      return [
        ["ID",                ReadOnlyProperty,                   _INTL("The ID of the Pokémon.")],
        ["Name",              LimitStringProperty.new(Pokemon::MAX_NAME_SIZE), _INTL("Name of the Pokémon.")],
        ["FormName",          StringProperty,                     _INTL("Name of this form of the Pokémon.")],
        ["Types",             GameDataPoolProperty.new(:Type, false), _INTL("The Pokémon's type(s).")],
        ["BaseStats",         BaseStatsProperty,                  _INTL("Base stats of the Pokémon.")],
        ["GenderRatio",       GameDataProperty.new(:GenderRatio), _INTL("Proportion of males to females for this species.")],
        ["GrowthRate",        GameDataProperty.new(:GrowthRate),  _INTL("Pokémon's growth rate.")],
        ["BaseExp",           LimitProperty.new(9999),            _INTL("Base experience earned when this species is defeated.")],
        ["EVs",               EffortValuesProperty,               _INTL("Effort Value points earned when this species is defeated.")],
        ["CatchRate",         LimitProperty.new(255),             _INTL("Catch rate of this species (0-255).")],
        ["Happiness",         LimitProperty.new(255),             _INTL("Base happiness of this species (0-255).")],
        ["Abilities",         AbilitiesProperty.new,              _INTL("Abilities which the Pokémon can have (max. 2).")],
        ["HiddenAbilities",   AbilitiesProperty.new,              _INTL("Secret abilities which the Pokémon can have.")],
        ["Moves",             LevelUpMovesProperty,               _INTL("Moves which the Pokémon learns while levelling up.")],
        ["TutorMoves",        EggMovesProperty.new,               _INTL("Moves which the Pokémon can be taught by TM/HM/Move Tutor.")],
        ["EggMoves",          EggMovesProperty.new,               _INTL("Moves which the Pokémon can learn via breeding.")],
        ["EggGroups",         EggGroupsProperty.new,              _INTL("Egg groups that the Pokémon belongs to for breeding purposes.")],
        ["HatchSteps",        LimitProperty.new(99_999),          _INTL("Number of steps until an egg of this species hatches.")],
        ["Incense",           ItemProperty,                       _INTL("Item needed to be held by a parent to produce an egg of this species.")],
        ["Offspring",         GameDataPoolProperty.new(:Species), _INTL("All possible species that an egg can be when breeding for an egg of this species (if blank, the egg can only be this species).")],
        ["Height",            NonzeroLimitProperty.new(999),      _INTL("Height of the Pokémon in 0.1 metres (e.g. 42 = 4.2m).")],
        ["Weight",            NonzeroLimitProperty.new(9999),     _INTL("Weight of the Pokémon in 0.1 kilograms (e.g. 42 = 4.2kg).")],
        ["Color",             GameDataProperty.new(:BodyColor),   _INTL("Pokémon's body color.")],
        ["Shape",             GameDataProperty.new(:BodyShape),   _INTL("Body shape of this species.")],
        ["Habitat",           GameDataProperty.new(:Habitat),     _INTL("The habitat of this species.")],
        ["Category",          StringProperty,                     _INTL("Kind of Pokémon species.")],
        ["Pokedex",           StringProperty,                     _INTL("Description of the Pokémon as displayed in the Pokédex.")],
        ["Generation",        LimitProperty.new(99_999),          _INTL("The number of the generation the Pokémon debuted in.")],
        ["Flags",             StringListProperty,                 _INTL("Words/phrases that distinguish this species from others.")],
        ["WildItemCommon",    GameDataPoolProperty.new(:Item),    _INTL("Item(s) commonly held by wild Pokémon of this species.")],
        ["WildItemUncommon",  GameDataPoolProperty.new(:Item),    _INTL("Item(s) uncommonly held by wild Pokémon of this species.")],
        ["WildItemRare",      GameDataPoolProperty.new(:Item),    _INTL("Item(s) rarely held by wild Pokémon of this species.")],
        ["Evolutions",        EvolutionsProperty.new,             _INTL("Evolution paths of this species.")]
      ]
    end

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

    def initialize(hash)
      @id                 = hash[:id]
      @species            = hash[:species]            || @id
      @form               = hash[:form]               || 0
      @real_name          = hash[:real_name]          || "Unnamed"
      @real_form_name     = hash[:real_form_name]
      @real_category      = hash[:real_category]      || "???"
      @real_pokedex_entry = hash[:real_pokedex_entry] || "???"
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
      @pbs_file_suffix    = hash[:pbs_file_suffix]    || ""
    end

    # @return [String] the translated name of this species
    def name
      return pbGetMessageFromHash(MessageTypes::SPECIES_NAMES, @real_name)
    end

    # @return [String] the translated name of this form of this species
    def form_name
      return pbGetMessageFromHash(MessageTypes::SPECIES_FORM_NAMES, @real_form_name)
    end

    # @return [String] the translated Pokédex category of this species
    def category
      return pbGetMessageFromHash(MessageTypes::SPECIES_CATEGORIES, @real_category)
    end

    # @return [String] the translated Pokédex entry of this species
    def pokedex_entry
      return pbGetMessageFromHash(MessageTypes::POKEDEX_ENTRIES, @real_pokedex_entry)
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
        next if !evo[3]   # Check only the prevolution
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
        next if !evo[3]   # Check only the prevolution
        prevo_data = GameData::Species.get_species_form(evo[0], base_form)
        return 1 if !prevo_data.incense.nil?
        prevo_min_level = prevo_data.minimum_level
        evo_method_data = GameData::Evolution.get(evo[1])
        return prevo_min_level if evo_method_data.level_up_proc.nil? && evo_method_data.id != :Shedinja
        any_level_up = evo_method_data.any_level_up
        return (any_level_up) ? prevo_min_level + 1 : evo[2]
      end
      return 1
    end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key, writing_form = false)
      key = "SectionName" if key == "ID"
      ret = nil
      if self.class.schema(writing_form).include?(key)
        ret = self.send(self.class.schema(writing_form)[key][0])
        ret = nil if ret == false || (ret.is_a?(Array) && ret.length == 0)
      end
      case key
      when "SectionName"
        ret = [@species, @form] if writing_form
      when "FormName"
        ret = nil if nil_or_empty?(ret)
      when "PokedexForm"
        ret = nil if ret == @form
      when "UnmegaForm", "MegaMessage", "Generation"
        ret = nil if ret == 0
      when "BaseStats"
        new_ret = []
        GameData::Stat.each_main do |s|
          new_ret[s.pbs_order] = ret[s.id] if s.pbs_order >= 0
        end
        ret = new_ret
      when "EVs"
        new_ret = []
        GameData::Stat.each_main do |s|
          new_ret.push([s.id, ret[s.id]]) if ret[s.id] > 0 && s.pbs_order >= 0
        end
        ret = new_ret
      when "Height", "Weight"
        ret = ret.to_f / 10
      when "Habitat"
        ret = nil if ret == :None
      when "Evolutions"
        if ret
          ret = ret.reject { |evo| evo[3] }   # Remove prevolutions
          ret.each do |evo|
            param_type = GameData::Evolution.get(evo[1]).parameter
            if !param_type.nil?
              if param_type.is_a?(Symbol) && !GameData.const_defined?(param_type)
                evo[2] = getConstantName(param_type, evo[2])
              else
                evo[2] = evo[2].to_s
              end
            end
          end
          ret.each_with_index { |evo, i| ret[i] = evo[0, 3] }
          ret = nil if ret.length == 0
        end
      end
      if writing_form && !ret.nil?
        base_form = GameData::Species.get(@species)
        if !["WildItemCommon", "WildItemUncommon", "WildItemRare"].include?(key) ||
           (base_form.wild_item_common == @wild_item_common &&
           base_form.wild_item_uncommon == @wild_item_uncommon &&
           base_form.wild_item_rare == @wild_item_rare)
          ret = nil if base_form.get_property_for_PBS(key) == ret
        end
      end
      return ret
    end
  end
end
