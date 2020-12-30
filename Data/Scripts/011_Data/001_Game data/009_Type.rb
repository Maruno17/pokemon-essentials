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
      return PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if !other_type
      return PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if @weaknesses.include?(other_type)
      return PBTypeEffectiveness::NOT_EFFECTIVE_ONE if @resistances.include?(other_type)
      return PBTypeEffectiveness::INEFFECTIVE if @immunities.include?(other_type)
      return PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE
    end
  end
end
