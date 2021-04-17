# NOTE: The id_number is only used to determine the order that body shapes are
#       listed in the Pokédex search screen. Number 0 (:None) is ignored; they
#       start with shape 1.
#       "Graphics/Pictures/Pokedex/icon_shapes.png" contains icons for these
#       shapes.
module GameData
  class BodyShape
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

    # @return [String] the translated name of this body shape
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::BodyShape.register({
  :id        => :Head,
  :id_number => 1,
  :name      => _INTL("Head")
})

GameData::BodyShape.register({
  :id        => :Serpentine,
  :id_number => 2,
  :name      => _INTL("Serpentine")
})

GameData::BodyShape.register({
  :id        => :Finned,
  :id_number => 3,
  :name      => _INTL("Finned")
})

GameData::BodyShape.register({
  :id        => :HeadArms,
  :id_number => 4,
  :name      => _INTL("Head and arms")
})

GameData::BodyShape.register({
  :id        => :HeadBase,
  :id_number => 5,
  :name      => _INTL("Head and base")
})

GameData::BodyShape.register({
  :id        => :BipedalTail,
  :id_number => 6,
  :name      => _INTL("Bipedal with tail")
})

GameData::BodyShape.register({
  :id        => :HeadLegs,
  :id_number => 7,
  :name      => _INTL("Head and legs")
})

GameData::BodyShape.register({
  :id        => :Quadruped,
  :id_number => 8,
  :name      => _INTL("Quadruped")
})

GameData::BodyShape.register({
  :id        => :Winged,
  :id_number => 9,
  :name      => _INTL("Winged")
})

GameData::BodyShape.register({
  :id        => :Multiped,
  :id_number => 10,
  :name      => _INTL("Multiped")
})

GameData::BodyShape.register({
  :id        => :MultiBody,
  :id_number => 11,
  :name      => _INTL("Multi Body")
})

GameData::BodyShape.register({
  :id        => :Bipedal,
  :id_number => 12,
  :name      => _INTL("Bipedal")
})

GameData::BodyShape.register({
  :id        => :MultiWinged,
  :id_number => 13,
  :name      => _INTL("Multi Winged")
})

GameData::BodyShape.register({
  :id        => :Insectoid,
  :id_number => 14,
  :name      => _INTL("Insectoid")
})
