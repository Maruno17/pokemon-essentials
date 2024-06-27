#===============================================================================
#
#===============================================================================
module GameData
  class EggGroup
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

    # @return [String] the translated name of this egg group
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================
#
#===============================================================================

GameData::EggGroup.register({
  :id   => :Undiscovered,
  :name => _INTL("Undiscovered")
})

GameData::EggGroup.register({
  :id   => :Monster,
  :name => _INTL("Monster")
})

GameData::EggGroup.register({
  :id   => :Water1,
  :name => _INTL("Water 1")
})

GameData::EggGroup.register({
  :id   => :Bug,
  :name => _INTL("Bug")
})

GameData::EggGroup.register({
  :id   => :Flying,
  :name => _INTL("Flying")
})

GameData::EggGroup.register({
  :id   => :Field,
  :name => _INTL("Field")
})

GameData::EggGroup.register({
  :id   => :Fairy,
  :name => _INTL("Fairy")
})

GameData::EggGroup.register({
  :id   => :Grass,
  :name => _INTL("Grass")
})

GameData::EggGroup.register({
  :id   => :Humanlike,
  :name => _INTL("Humanlike")
})

GameData::EggGroup.register({
  :id   => :Water3,
  :name => _INTL("Water 3")
})

GameData::EggGroup.register({
  :id   => :Mineral,
  :name => _INTL("Mineral")
})

GameData::EggGroup.register({
  :id   => :Amorphous,
  :name => _INTL("Amorphous")
})

GameData::EggGroup.register({
  :id   => :Water2,
  :name => _INTL("Water 2")
})

GameData::EggGroup.register({
  :id   => :Ditto,
  :name => _INTL("Ditto")
})

GameData::EggGroup.register({
  :id   => :Dragon,
  :name => _INTL("Dragon")
})
