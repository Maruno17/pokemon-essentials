#===============================================================================
# NOTE: The order these colors are registered are the order they are listed in
#       the Pokédex search screen.
#===============================================================================
module GameData
  class BodyColor
    attr_reader :id
    attr_reader :real_name

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    #---------------------------------------------------------------------------

    def initialize(hash)
      @id        = hash[:id]
      @real_name = hash[:name] || "Unnamed"
    end

    # @return [String] the translated name of this body color
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================
#
#===============================================================================

GameData::BodyColor.register({
  :id   => :Red,
  :name => _INTL("Red")
})

GameData::BodyColor.register({
  :id   => :Blue,
  :name => _INTL("Blue")
})

GameData::BodyColor.register({
  :id   => :Yellow,
  :name => _INTL("Yellow")
})

GameData::BodyColor.register({
  :id   => :Green,
  :name => _INTL("Green")
})

GameData::BodyColor.register({
  :id   => :Black,
  :name => _INTL("Black")
})

GameData::BodyColor.register({
  :id   => :Brown,
  :name => _INTL("Brown")
})

GameData::BodyColor.register({
  :id   => :Purple,
  :name => _INTL("Purple")
})

GameData::BodyColor.register({
  :id   => :Gray,
  :name => _INTL("Gray")
})

GameData::BodyColor.register({
  :id   => :White,
  :name => _INTL("White")
})

GameData::BodyColor.register({
  :id   => :Pink,
  :name => _INTL("Pink")
})
