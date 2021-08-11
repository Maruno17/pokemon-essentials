module GameData
  class Type
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :special_type
    attr_reader :pseudo_type
    attr_reader :weaknesses
    attr_reader :resistances
    attr_reader :immunities

    DATA = {}
    DATA_FILENAME = "types.dat"

    SCHEMA = {
      "Name"          => [1, "s"],
      "InternalName"  => [2, "s"],
      "IsPseudoType"  => [3, "b"],
      "IsSpecialType" => [4, "b"],
      "Weaknesses"    => [5, "*s"],
      "Resistances"   => [6, "*s"],
      "Immunities"    => [7, "*s"]
    }

    extend ClassMethods
    include InstanceMethods

    def initialize(hash)
      @id           = hash[:id]
      @id_number    = hash[:id_number]    || -1
      @real_name    = hash[:name]         || "Unnamed"
      @pseudo_type  = hash[:pseudo_type]  || false
      @special_type = hash[:special_type] || false
      @weaknesses   = hash[:weaknesses]   || []
      @weaknesses   = [@weaknesses] if !@weaknesses.is_a?(Array)
      @resistances  = hash[:resistances]  || []
      @resistances  = [@resistances] if !@resistances.is_a?(Array)
      @immunities   = hash[:immunities]   || []
      @immunities   = [@immunities] if !@immunities.is_a?(Array)
    end

    # @return [String] the translated name of this item
    def name
      return pbGetMessage(MessageTypes::Types, @id_number)
    end

    def physical?; return !@special_type; end
    def special?;  return @special_type; end

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
  NORMAL_EFFECTIVE       = NORMAL_EFFECTIVE_ONE ** 3

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
    mod1 = calculate_one(attack_type, defend_type1)
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
