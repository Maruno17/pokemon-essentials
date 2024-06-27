#===============================================================================
# NOTE: The order these shapes are registered are the order they are listed in
#       the Pokédex search screen.
#       "Graphics/UI/Pokedex/icon_shapes.png" contains icons for these
#       shapes.
#===============================================================================
module GameData
  class BodyShape
    attr_reader :id
    attr_reader :real_name
    attr_reader :icon_position   # Where this shape's icon is within icon_shapes.png

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    #---------------------------------------------------------------------------

    def initialize(hash)
      @id            = hash[:id]
      @real_name     = hash[:name]          || "Unnamed"
      @icon_position = hash[:icon_position] || 0
    end

    # @return [String] the translated name of this body shape
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================
#
#===============================================================================

GameData::BodyShape.register({
  :id            => :Head,
  :name          => _INTL("Head"),
  :icon_position => 0
})

GameData::BodyShape.register({
  :id            => :Serpentine,
  :name          => _INTL("Serpentine"),
  :icon_position => 1
})

GameData::BodyShape.register({
  :id            => :Finned,
  :name          => _INTL("Finned"),
  :icon_position => 2
})

GameData::BodyShape.register({
  :id            => :HeadArms,
  :name          => _INTL("Head and arms"),
  :icon_position => 3
})

GameData::BodyShape.register({
  :id            => :HeadBase,
  :name          => _INTL("Head and base"),
  :icon_position => 4
})

GameData::BodyShape.register({
  :id            => :BipedalTail,
  :name          => _INTL("Bipedal with tail"),
  :icon_position => 5
})

GameData::BodyShape.register({
  :id            => :HeadLegs,
  :name          => _INTL("Head and legs"),
  :icon_position => 6
})

GameData::BodyShape.register({
  :id            => :Quadruped,
  :name          => _INTL("Quadruped"),
  :icon_position => 7
})

GameData::BodyShape.register({
  :id            => :Winged,
  :name          => _INTL("Winged"),
  :icon_position => 8
})

GameData::BodyShape.register({
  :id            => :Multiped,
  :name          => _INTL("Multiped"),
  :icon_position => 9
})

GameData::BodyShape.register({
  :id            => :MultiBody,
  :name          => _INTL("Multi Body"),
  :icon_position => 10
})

GameData::BodyShape.register({
  :id            => :Bipedal,
  :name          => _INTL("Bipedal"),
  :icon_position => 11
})

GameData::BodyShape.register({
  :id            => :MultiWinged,
  :name          => _INTL("Multi Winged"),
  :icon_position => 12
})

GameData::BodyShape.register({
  :id            => :Insectoid,
  :name          => _INTL("Insectoid"),
  :icon_position => 13
})
