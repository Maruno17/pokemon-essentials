class Data

  class Ability
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :real_description

    DATA = {}

    def initialize(hash)
      validate hash => Hash, hash[:id] => Symbol
      @id               = hash[:id]
      @id_number        = hash[:id_number]   || -1
      @real_name        = hash[:name]        || "Unnamed"
      @real_description = hash[:description] || "???"
    end

    # @return [String] the translated name of this ability
    def name
      return pbGetMessage(MessageTypes::Abilities, @id_number)
    end

    # @return [String] the translated description of this ability
    def description
      return pbGetMessage(MessageTypes::AbilityDescs, @id_number)
    end

    # @param other [Symbol, Ability, Integer]
    # @return [Boolean] whether other is the same as this ability
    def ==(other)
      return false if other.nil?
      validate other => [Symbol, Ability, Integer]
      if other.is_a?(Symbol)
        return @id == other
      elsif other.is_a?(Ability)
        return @id == other.id
      elsif other.is_a?(Integer)
        return @id_number == other
      end
      return false
    end

    # @param ability_id [Symbol, Ability, Integer]
    # @return [Boolean] whether the given ability_id is defined as an Ability
    def self.exists?(ability_id)
      return false if ability_id.nil?
      validate ability_id => [Symbol, Ability, Integer]
      ability_id = ability_id.id if ability_id.is_a?(Ability)
      return !DATA[ability_id].nil?
    end

    # @param ability_id [Symbol, Ability, Integer]
    # @return [Ability]
    def self.get(ability_id)
      validate ability_id => [Symbol, Ability, Integer]
      return ability_id if ability_id.is_a?(Ability)
#      if ability_id.is_a?(Integer)
#        p "Please switch to symbols, thanks."
#      end
      raise "Unknown ability ID #{ability_id}." unless DATA.has_key?(ability_id)
      return DATA[ability_id]
    end

    def self.try_get(ability_id)
      return nil if ability_id.nil?
      validate ability_id => [Symbol, Ability, Integer]
      return ability_id if ability_id.is_a?(Ability)
#      if ability_id.is_a?(Integer)
#        p "Please switch to symbols, thanks."
#      end
      return (DATA.has_key?(ability_id)) ? DATA[ability_id] : nil
    end

    def self.each
      keys = DATA.keys
      keys.sort! { |a, b| a.to_s <=> b.to_s }
      keys.each do |key|
        yield DATA[key] if key.is_a?(Symbol)
      end
    end

    def self.load
      const_set(:DATA, load_data("Data/abilities.dat"))
    end

    def self.save
      save_data(DATA, "Data/abilities.dat")
    end
  end

end
