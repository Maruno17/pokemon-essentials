# NOTE: The id_number is only used to determine the order of the status icons in
#       the graphics containing them. Number 0 (:NONE) is ignored; they start
#       with status 1.
#       "Graphics/Pictures/statuses.png" also contains icons for being fainted
#       and for having Pokérus, in that order, at the bottom of the graphic.
#       "Graphics/Pictures/Battle/icon_statuses.png" also contains an icon for
#       bad poisoning (toxic), at the bottom of the graphic.
#       Both graphics automatically handle varying numbers of defined statuses.
module GameData
  class Status
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :animation

    DATA = {}

    extend ClassMethods
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id        = hash[:id]
      @id_number = hash[:id_number]
      @real_name = hash[:name] || "Unnamed"
      @animation = hash[:animation]
    end

    # @return [String] the translated name of this status condition
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::Status.register({
  :id        => :NONE,
  :id_number => 0,
  :name      => _INTL("None")
})

GameData::Status.register({
  :id        => :SLEEP,
  :id_number => 1,
  :name      => _INTL("Sleep"),
  :animation => "Sleep"
})

GameData::Status.register({
  :id        => :POISON,
  :id_number => 2,
  :name      => _INTL("Poison"),
  :animation => "Poison"
})

GameData::Status.register({
  :id        => :BURN,
  :id_number => 3,
  :name      => _INTL("Burn"),
  :animation => "Burn"
})

GameData::Status.register({
  :id        => :PARALYSIS,
  :id_number => 4,
  :name      => _INTL("Paralysis"),
  :animation => "Paralysis"
})

GameData::Status.register({
  :id        => :FROZEN,
  :id_number => 5,
  :name      => _INTL("Frozen"),
  :animation => "Frozen"
})
