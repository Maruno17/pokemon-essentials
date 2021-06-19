module GameData
  class Ribbon
    attr_reader :id
    attr_reader :real_name
    attr_reader :real_description
    attr_reader :icon_position   # Where this ribbon's graphic is within ribbons.png

    DATA = {}
    DATA_FILENAME = "ribbons.dat"

    extend ClassMethodsSymbols
    include InstanceMethods

    def initialize(hash)
      @id               = hash[:id]
      @real_name        = hash[:name]          || "Unnamed"
      @real_description = hash[:description]   || "???"
      @icon_position    = hash[:icon_position] || -1
    end

    # @return [String] the translated name of this ribbon
    def name
      return pbGetMessageFromHash(MessageTypes::RibbonNames, @real_name)
    end

    # @return [String] the translated description of this ribbon
    def description
      return pbGetMessageFromHash(MessageTypes::RibbonDescriptions, @real_description)
    end
  end
end
