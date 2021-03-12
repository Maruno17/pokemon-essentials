# NOTE: The id_number is only used to determine the order that body colors are
#       listed in the Pokédex search screen.
module GameData
  class BodyColor
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name

    DATA = {}

    extend ClassMethods
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id        = hash[:id]
      @id_number = hash[:id_number] || -1
      @real_name = hash[:name]      || "Unnamed"
    end

    # @return [String] the translated name of this body color
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::BodyColor.register({
  :id        => :Red,
  :id_number => 0,
  :name      => _INTL("Red")
})

GameData::BodyColor.register({
  :id        => :Blue,
  :id_number => 1,
  :name      => _INTL("Blue")
})

GameData::BodyColor.register({
  :id        => :Yellow,
  :id_number => 2,
  :name      => _INTL("Yellow")
})

GameData::BodyColor.register({
  :id        => :Green,
  :id_number => 3,
  :name      => _INTL("Green")
})

GameData::BodyColor.register({
  :id        => :Black,
  :id_number => 4,
  :name      => _INTL("Black")
})

GameData::BodyColor.register({
  :id        => :Brown,
  :id_number => 5,
  :name      => _INTL("Brown")
})

GameData::BodyColor.register({
  :id        => :Purple,
  :id_number => 6,
  :name      => _INTL("Purple")
})

GameData::BodyColor.register({
  :id        => :Gray,
  :id_number => 7,
  :name      => _INTL("Gray")
})

GameData::BodyColor.register({
  :id        => :White,
  :id_number => 8,
  :name      => _INTL("White")
})

GameData::BodyColor.register({
  :id        => :Pink,
  :id_number => 9,
  :name      => _INTL("Pink")
})
