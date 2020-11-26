module GameData
  class Ability
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :real_description

    DATA = {}
    DATA_FILENAME = "abilities.dat"

    extend ClassMethods
    include InstanceMethods

    def initialize(hash)
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
  end
end
