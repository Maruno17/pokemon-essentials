module GameData
  class Type
    attr_reader :id
    attr_reader :real_name
    attr_reader :special_type
    attr_reader :pseudo_type
    attr_reader :flags
    attr_reader :weaknesses
    attr_reader :resistances
    attr_reader :immunities
    attr_reader :icon_position   # Where this type's icon is within types.png

    DATA = {}
    DATA_FILENAME = "types.dat"

    SCHEMA = {
      "Name"          => [0, "s"],
      "InternalName"  => [0, "s"],
      "IsSpecialType" => [0, "b"],
      "IsPseudoType"  => [0, "b"],
      "Flags"         => [0, "*s"],
      "Weaknesses"    => [0, "*s"],
      "Resistances"   => [0, "*s"],
      "Immunities"    => [0, "*s"],
      "IconPosition"  => [0, "u"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    def initialize(hash)
      @id            = hash[:id]
      @real_name     = hash[:name]          || "Unnamed"
      @special_type  = hash[:special_type]  || false
      @pseudo_type   = hash[:pseudo_type]   || false
      @flags         = hash[:flags]         || []
      @weaknesses    = hash[:weaknesses]    || []
      @weaknesses    = [@weaknesses] if !@weaknesses.is_a?(Array)
      @resistances   = hash[:resistances]   || []
      @resistances   = [@resistances] if !@resistances.is_a?(Array)
      @immunities    = hash[:immunities]    || []
      @immunities    = [@immunities] if !@immunities.is_a?(Array)
      @icon_position = hash[:icon_position] || 0
    end

    # @return [String] the translated name of this item
    def name
      return pbGetMessageFromHash(MessageTypes::Types, @real_name)
    end

    def physical?; return !@special_type; end
    def special?;  return @special_type; end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    def effectiveness(other_type)
      return Effectiveness::NORMAL_EFFECTIVE_ONE if !other_type
      return Effectiveness::SUPER_EFFECTIVE_ONE if @weaknesses.include?(other_type)
      return Effectiveness::NOT_VERY_EFFECTIVE_ONE if @resistances.include?(other_type)
      return Effectiveness::INEFFECTIVE if @immunities.include?(other_type)
      return Effectiveness::NORMAL_EFFECTIVE_ONE
    end
  end
end

#===============================================================================

module Effectiveness
  INEFFECTIVE            = 0
  NOT_VERY_EFFECTIVE_ONE = 1
  NORMAL_EFFECTIVE_ONE   = 2
  SUPER_EFFECTIVE_ONE    = 4
  NORMAL_EFFECTIVE       = NORMAL_EFFECTIVE_ONE**3

  module_function

  def ineffective?(value)
    return value == INEFFECTIVE
  end

  def not_very_effective?(value)
    return value > INEFFECTIVE && value < NORMAL_EFFECTIVE
  end

  def resistant?(value)
    return value < NORMAL_EFFECTIVE
  end

  def normal?(value)
    return value == NORMAL_EFFECTIVE
  end

  def super_effective?(value)
    return value > NORMAL_EFFECTIVE
  end

  def ineffective_type?(attack_type, defend_type1, defend_type2 = nil, defend_type3 = nil)
    value = calculate(attack_type, defend_type1, defend_type2, defend_type3)
    return ineffective?(value)
  end

  def not_very_effective_type?(attack_type, defend_type1, defend_type2 = nil, defend_type3 = nil)
    value = calculate(attack_type, defend_type1, defend_type2, defend_type3)
    return not_very_effective?(value)
  end

  def resistant_type?(attack_type, defend_type1, defend_type2 = nil, defend_type3 = nil)
    value = calculate(attack_type, defend_type1, defend_type2, defend_type3)
    return resistant?(value)
  end

  def normal_type?(attack_type, defend_type1, defend_type2 = nil, defend_type3 = nil)
    value = calculate(attack_type, defend_type1, defend_type2, defend_type3)
    return normal?(value)
  end

  def super_effective_type?(attack_type, defend_type1, defend_type2 = nil, defend_type3 = nil)
    value = calculate(attack_type, defend_type1, defend_type2, defend_type3)
    return super_effective?(value)
  end

  def calculate_one(attack_type, defend_type)
    return GameData::Type.get(defend_type).effectiveness(attack_type)
  end

  def calculate(attack_type, defend_type1, defend_type2 = nil, defend_type3 = nil)
    mod1 = (defend_type1) ? calculate_one(attack_type, defend_type1) : NORMAL_EFFECTIVE_ONE
    mod2 = NORMAL_EFFECTIVE_ONE
    mod3 = NORMAL_EFFECTIVE_ONE
    if defend_type2 && defend_type1 != defend_type2
      mod2 = calculate_one(attack_type, defend_type2)
    end
    if defend_type3 && defend_type1 != defend_type3 && defend_type2 != defend_type3
      mod3 = calculate_one(attack_type, defend_type3)
    end
    return mod1 * mod2 * mod3
  end
end
