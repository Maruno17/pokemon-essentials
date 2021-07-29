module GameData
  class Ribbon
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :real_description

    DATA = {}
    DATA_FILENAME = "ribbons.dat"

    extend ClassMethods
    include InstanceMethods

    def initialize(hash)
      @id               = hash[:id]
      @id_number        = hash[:id_number]   || -1
      @real_name        = hash[:name]        || "Unnamed"
      @real_description = hash[:description] || "???"
    end

    # @return [String] the translated name of this ribbon
    def name
      return pbGetMessage(MessageTypes::RibbonNames, @id_number)
    end

    # @return [String] the translated description of this ribbon
    def description
      return pbGetMessage(MessageTypes::RibbonDescriptions, @id_number)
    end
  end
end
