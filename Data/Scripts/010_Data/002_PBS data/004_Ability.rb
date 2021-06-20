module GameData
  class Ability
    attr_reader :id
    attr_reader :real_name
    attr_reader :real_description

    DATA = {}
    DATA_FILENAME = "abilities.dat"

    extend ClassMethodsSymbols
    include InstanceMethods

    SCHEMA = {
      "Name"         => [:name,        "s"],
      "Description"  => [:description, "q"]
    }

    def initialize(hash)
      @id               = hash[:id]
      @real_name        = hash[:name]        || "Unnamed"
      @real_description = hash[:description] || "???"
    end

    # @return [String] the translated name of this ability
    def name
      return pbGetMessageFromHash(MessageTypes::Abilities, @real_name)
    end

    # @return [String] the translated description of this ability
    def description
      return pbGetMessageFromHash(MessageTypes::AbilityDescs, @real_description)
    end
  end
end
