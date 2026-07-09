#===============================================================================
#
#===============================================================================
module GameData
  class Type
    attr_reader :id
    attr_reader :real_name
    attr_reader :icon_position   # Where this type's icon is within types.png
    attr_reader :special_type
    attr_reader :pseudo_type
    attr_reader :weaknesses
    attr_reader :resistances
    attr_reader :immunities
    attr_reader :flags
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "types.dat"
    PBS_BASE_FILENAME = "types"
    SCHEMA = {
      "SectionName"   => [:id,            "m"],
      "Name"          => [:real_name,     "s"],
      "IconPosition"  => [:icon_position, "u"],
      "IsSpecialType" => [:special_type,  "b"],
      "IsPseudoType"  => [:pseudo_type,   "b"],
      "Weaknesses"    => [:weaknesses,    "*m"],
      "Resistances"   => [:resistances,   "*m"],
      "Immunities"    => [:immunities,    "*m"],
      "Flags"         => [:flags,         "*s"]
    }
    ICON_SIZE = [64, 28]

    extend ClassMethodsSymbols
    include InstanceMethods

    #---------------------------------------------------------------------------

    def initialize(hash)
      @id              = hash[:id]
      @real_name       = hash[:real_name]       || "Unnamed"
      @icon_position   = hash[:icon_position]   || 0
      @special_type    = hash[:special_type]    || false
      @pseudo_type     = hash[:pseudo_type]     || false
      @weaknesses      = hash[:weaknesses]      || []
      @weaknesses      = [@weaknesses] if !@weaknesses.is_a?(Array)
      @resistances     = hash[:resistances]     || []
      @resistances     = [@resistances] if !@resistances.is_a?(Array)
      @immunities      = hash[:immunities]      || []
      @immunities      = [@immunities] if !@immunities.is_a?(Array)
      @flags           = hash[:flags]           || []
      @pbs_file_suffix = hash[:pbs_file_suffix] || ""
    end

    # @return [String] the translated name of this item
    def name
      return pbGetMessageFromHash(MessageTypes::TYPE_NAMES, @real_name)
    end

    def physical?; return !@special_type; end
    def special?;  return @special_type; end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end

    def effectiveness(other_type)
      return Effectiveness::NORMAL_EFFECTIVE if !other_type
      return Effectiveness::SUPER_EFFECTIVE if @weaknesses.include?(other_type)
      return Effectiveness::NOT_VERY_EFFECTIVE if @resistances.include?(other_type)
      return Effectiveness::INEFFECTIVE if @immunities.include?(other_type)
      return Effectiveness::NORMAL_EFFECTIVE
    end
  end
end

#===============================================================================
#
#===============================================================================
module Effectiveness
  INEFFECTIVE                   = 0
  NOT_VERY_EFFECTIVE            = 1
  NORMAL_EFFECTIVE              = 2
  SUPER_EFFECTIVE               = 4
  INEFFECTIVE_MULTIPLIER        = INEFFECTIVE.to_f / NORMAL_EFFECTIVE
  NOT_VERY_EFFECTIVE_MULTIPLIER = NOT_VERY_EFFECTIVE.to_f / NORMAL_EFFECTIVE
  NORMAL_EFFECTIVE_MULTIPLIER   = 1.0
  SUPER_EFFECTIVE_MULTIPLIER    = SUPER_EFFECTIVE.to_f / NORMAL_EFFECTIVE

  module_function

  def ineffective?(value)
    return value == INEFFECTIVE_MULTIPLIER
  end

  def not_very_effective?(value)
    return value > INEFFECTIVE_MULTIPLIER && value < NORMAL_EFFECTIVE_MULTIPLIER
  end

  def resistant?(value)
    return value < NORMAL_EFFECTIVE_MULTIPLIER
  end

  def normal?(value)
    return value == NORMAL_EFFECTIVE_MULTIPLIER
  end

  def super_effective?(value)
    return value > NORMAL_EFFECTIVE_MULTIPLIER
  end

  def ineffective_type?(attack_type, *defend_types)
    value = calculate(attack_type, *defend_types)
    return ineffective?(value)
  end

  def not_very_effective_type?(attack_type, *defend_types)
    value = calculate(attack_type, *defend_types)
    return not_very_effective?(value)
  end

  def resistant_type?(attack_type, *defend_types)
    value = calculate(attack_type, *defend_types)
    return resistant?(value)
  end

  def normal_type?(attack_type, *defend_types)
    value = calculate(attack_type, *defend_types)
    return normal?(value)
  end

  def super_effective_type?(attack_type, *defend_types)
    value = calculate(attack_type, *defend_types)
    return super_effective?(value)
  end

  def get_type_effectiveness(attack_type, defend_type)
    return GameData::Type.get(defend_type).effectiveness(attack_type)
  end

  def calculate(attack_type, *defend_types)
    ret = NORMAL_EFFECTIVE_MULTIPLIER
    defend_types.each do |type|
      ret *= get_type_effectiveness(attack_type, type) / NORMAL_EFFECTIVE.to_f
    end
    return ret
  end
end
