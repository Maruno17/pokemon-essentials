#===============================================================================
#
#===============================================================================
module GameData
  class Move
    attr_reader :id
    attr_reader :real_name
    attr_reader :type
    attr_reader :category
    attr_reader :power
    attr_reader :accuracy
    attr_reader :total_pp
    attr_reader :target
    attr_reader :priority
    attr_reader :function_code
    attr_reader :flags
    attr_reader :effect_chance
    attr_reader :real_description
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "moves.dat"
    PBS_BASE_FILENAME = "moves"
    SCHEMA = {
      "SectionName"  => [:id,               "m"],
      "Name"         => [:real_name,        "s"],
      "Type"         => [:type,             "e", :Type],
      "Category"     => [:category,         "e", ["Physical", "Special", "Status"]],
      "Power"        => [:power,            "u"],
      "Accuracy"     => [:accuracy,         "u"],
      "TotalPP"      => [:total_pp,         "u"],
      "Target"       => [:target,           "e", :Target],
      "Priority"     => [:priority,         "i"],
      "FunctionCode" => [:function_code,    "s"],
      "Flags"        => [:flags,            "*s"],
      "EffectChance" => [:effect_chance,    "u"],
      "Description"  => [:real_description, "q"]
    }
    CATEGORY_ICON_SIZE = [64, 28]

    extend ClassMethodsSymbols
    include InstanceMethods

    #---------------------------------------------------------------------------

    def initialize(hash)
      @id               = hash[:id]
      @real_name        = hash[:real_name]        || "Unnamed"
      @type             = hash[:type]             || :NONE
      @category         = hash[:category]         || 2
      @power            = hash[:power]            || 0
      @accuracy         = hash[:accuracy]         || 100
      @total_pp         = hash[:total_pp]         || 5
      @target           = hash[:target]           || :None
      @priority         = hash[:priority]         || 0
      @function_code    = hash[:function_code]    || "None"
      @flags            = hash[:flags]            || []
      @flags            = [@flags] if !@flags.is_a?(Array)
      @effect_chance    = hash[:effect_chance]    || 0
      @real_description = hash[:real_description] || "???"
      @pbs_file_suffix  = hash[:pbs_file_suffix]  || ""
    end

    # @return [String] the translated name of this move
    def name
      return pbGetMessageFromHash(MessageTypes::MOVE_NAMES, @real_name)
    end

    # @return [String] the translated description of this move
    def description
      return pbGetMessageFromHash(MessageTypes::MOVE_DESCRIPTIONS, @real_description)
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    def physical?
      return false if @power == 0
      return @category == 0 if Settings::MOVE_CATEGORY_PER_MOVE
      return GameData::Type.get(@type).physical?
    end

    def special?
      return false if @power == 0
      return @category == 1 if Settings::MOVE_CATEGORY_PER_MOVE
      return GameData::Type.get(@type).special?
    end

    def damaging?
      return @category != 2
    end

    def status?
      return @category == 2
    end

    def hidden_move?
      GameData::Item.each do |i|
        return true if i.is_HM? && i.move == @id
      end
      return false
    end

    # TODO: Make the below depend on a Setting rather than quoting it out.
    def display_type(pkmn, move = nil)
=begin
      case @function_code
      when "TypeDependsOnUserIVs"
        return pbHiddenPower(pkmn)[0]
      when "TypeAndPowerDependOnUserBerry"
        item_data = pkmn.item
        if item_data
          item_data.flags.each do |flag|
            next if !flag[/^NaturalGift_(\w+)_(?:\d+)$/i]
            typ = $~[1].to_sym
            ret = typ if GameData::Type.exists?(typ)
            break
          end
        end
        return :NORMAL
      when "TypeDependsOnUserPlate"
        item_types = {
          :FISTPLATE   => :FIGHTING,
          :SKYPLATE    => :FLYING,
          :TOXICPLATE  => :POISON,
          :EARTHPLATE  => :GROUND,
          :STONEPLATE  => :ROCK,
          :INSECTPLATE => :BUG,
          :SPOOKYPLATE => :GHOST,
          :IRONPLATE   => :STEEL,
          :FLAMEPLATE  => :FIRE,
          :SPLASHPLATE => :WATER,
          :MEADOWPLATE => :GRASS,
          :ZAPPLATE    => :ELECTRIC,
          :MINDPLATE   => :PSYCHIC,
          :ICICLEPLATE => :ICE,
          :DRACOPLATE  => :DRAGON,
          :DREADPLATE  => :DARK,
          :PIXIEPLATE  => :FAIRY
        }
        if pkmn.hasItem?
          item_types.each do |item, item_type|
            return item_type if pkmn.item_id == item && GameData::Type.exists?(item_type)
          end
        end
      when "TypeDependsOnUserMemory"
        item_types = {
          :FIGHTINGMEMORY => :FIGHTING,
          :FLYINGMEMORY   => :FLYING,
          :POISONMEMORY   => :POISON,
          :GROUNDMEMORY   => :GROUND,
          :ROCKMEMORY     => :ROCK,
          :BUGMEMORY      => :BUG,
          :GHOSTMEMORY    => :GHOST,
          :STEELMEMORY    => :STEEL,
          :FIREMEMORY     => :FIRE,
          :WATERMEMORY    => :WATER,
          :GRASSMEMORY    => :GRASS,
          :ELECTRICMEMORY => :ELECTRIC,
          :PSYCHICMEMORY  => :PSYCHIC,
          :ICEMEMORY      => :ICE,
          :DRAGONMEMORY   => :DRAGON,
          :DARKMEMORY     => :DARK,
          :FAIRYMEMORY    => :FAIRY
        }
        if pkmn.hasItem?
          item_types.each do |item, item_type|
            return item_type if pkmn.item_id == item && GameData::Type.exists?(item_type)
          end
        end
      when "TypeDependsOnUserDrive"
        item_types = {
          :SHOCKDRIVE => :ELECTRIC,
          :BURNDRIVE  => :FIRE,
          :CHILLDRIVE => :ICE,
          :DOUSEDRIVE => :WATER
        }
        if pkmn.hasItem?
          item_types.each do |item, item_type|
            return item_type if pkmn.item_id == item && GameData::Type.exists?(item_type)
          end
        end
      when "TypeIsUserFirstType"
        return pkmn.types[0]
      end
=end
      return @type
    end

    # TODO: Make the below depend on a Setting rather than quoting it out.
    def display_damage(pkmn, move = nil)
=begin
      case @function_code
      when "TypeDependsOnUserIVs"
        return pbHiddenPower(pkmn)[1]
      when "TypeAndPowerDependOnUserBerry"
        item_data = pkmn.item
        if item_data
          item_data.flags.each do |flag|
            return [$~[1].to_i, 10].max if flag[/^NaturalGift_(?:\w+)_(\d+)$/i]
          end
        end
        return 1
      when "ThrowUserItemAtTarget"
        item_data = pkmn.item
        if item_data
          item_data.flags.each do |flag|
            return [$~[1].to_i, 10].max if flag[/^Fling_(\d+)$/i]
          end
          return 10
        end
        return 0
      when "PowerHigherWithUserHP"
        return [150 * pkmn.hp / pkmn.totalhp, 1].max
      when "PowerLowerWithUserHP"
        n = 48 * pkmn.hp / pkmn.totalhp
        return 200 if n < 2
        return 150 if n < 5
        return 100 if n < 10
        return 80 if n < 17
        return 40 if n < 33
        return 20
      when "PowerHigherWithUserHappiness"
        return [(pkmn.happiness * 2 / 5).floor, 1].max
      when "PowerLowerWithUserHappiness"
        return [((255 - pkmn.happiness) * 2 / 5).floor, 1].max
      when "PowerHigherWithLessPP"
        dmgs = [200, 80, 60, 50, 40]
        ppLeft = [[(move&.pp || @total_pp) - 1, 0].max, dmgs.length - 1].min
        return dmgs[ppLeft]
      end
=end
      return @power
    end

    def display_category(pkmn, move = nil); return @category; end
    def display_accuracy(pkmn, move = nil); return @accuracy; end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key)
      ret = __orig__get_property_for_PBS(key)
      ret = nil if ["Power", "Priority", "EffectChance"].include?(key) && ret == 0
      return ret
    end
  end
end
