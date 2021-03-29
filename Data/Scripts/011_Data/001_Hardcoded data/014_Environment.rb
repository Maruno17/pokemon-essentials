module GameData
  class Environment
    attr_reader :id
    attr_reader :real_name
    attr_reader :battle_base

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id          = hash[:id]
      @real_name   = hash[:name] || "Unnamed"
      @battle_base = hash[:battle_base]
    end

    # @return [String] the translated name of this environment
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::Environment.register({
  :id   => :None,
  :name => _INTL("None")
})

GameData::Environment.register({
  :id          => :Grass,
  :name        => _INTL("Grass"),
  :battle_base => "grass"
})

GameData::Environment.register({
  :id          => :TallGrass,
  :name        => _INTL("Tall grass"),
  :battle_base => "grass"
})

GameData::Environment.register({
  :id          => :MovingWater,
  :name        => _INTL("Moving water"),
  :battle_base => "water"
})

GameData::Environment.register({
  :id          => :StillWater,
  :name        => _INTL("Still water"),
  :battle_base => "water"
})

GameData::Environment.register({
  :id           => :Puddle,
  :name         => _INTL("Puddle"),
  :battle_basec => "puddle"
})

GameData::Environment.register({
  :id   => :Underwater,
  :name => _INTL("Underwater")
})

GameData::Environment.register({
  :id   => :Cave,
  :name => _INTL("Cave")
})

GameData::Environment.register({
  :id   => :Rock,
  :name => _INTL("Rock")
})

GameData::Environment.register({
  :id          => :Sand,
  :name        => _INTL("Sand"),
  :battle_base => "sand"
})

GameData::Environment.register({
  :id   => :Forest,
  :name => _INTL("Forest")
})

GameData::Environment.register({
  :id          => :ForestGrass,
  :name        => _INTL("Forest grass"),
  :battle_base => "grass"
})

GameData::Environment.register({
  :id   => :Snow,
  :name => _INTL("Snow")
})

GameData::Environment.register({
  :id          => :Ice,
  :name        => _INTL("Ice"),
  :battle_base => "ice"
})

GameData::Environment.register({
  :id   => :Volcano,
  :name => _INTL("Volcano")
})

GameData::Environment.register({
  :id   => :Graveyard,
  :name => _INTL("Graveyard")
})

GameData::Environment.register({
  :id   => :Sky,
  :name => _INTL("Sky")
})

GameData::Environment.register({
  :id   => :Space,
  :name => _INTL("Space")
})

GameData::Environment.register({
  :id   => :UltraSpace,
  :name => _INTL("Ultra Space")
})
