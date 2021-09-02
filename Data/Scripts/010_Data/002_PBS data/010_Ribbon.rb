module GameData
  class Ribbon
    attr_reader :id
    attr_reader :real_name
    attr_reader :icon_position   # Where this ribbon's graphic is within ribbons.png
    attr_reader :real_description
    attr_reader :flags

    DATA = {}
    DATA_FILENAME = "ribbons.dat"

    SCHEMA = {
      "Name"         => [:name,          "s"],
      "IconPosition" => [:icon_position, "u"],
      "Description"  => [:description,   "q"],
      "Flags"        => [:flags,         "*s"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    def initialize(hash)
      @id               = hash[:id]
      @real_name        = hash[:name]          || "Unnamed"
      @icon_position    = hash[:icon_position] || 0
      @real_description = hash[:description]   || "???"
      @flags            = hash[:flags]         || []
    end

    # @return [String] the translated name of this ribbon
    def name
      return pbGetMessageFromHash(MessageTypes::RibbonNames, @real_name)
    end

    # @return [String] the translated description of this ribbon
    def description
      return pbGetMessageFromHash(MessageTypes::RibbonDescriptions, @real_description)
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end
  end
end
