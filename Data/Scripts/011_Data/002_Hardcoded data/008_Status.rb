module GameData
  class Status
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name

    DATA = {}

    extend ClassMethods
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id               = hash[:id]
      @id_number        = hash[:id_number]
      @real_name        = hash[:name] || "Unnamed"
    end

    # @return [String] the translated name of this status condition
    def name
      return _INTL(@real_name)
    end
  end
end

GameData::Status.register({
  :id          => :NONE,
  :id_number   => 0,
  :name        => _INTL("None")
})

GameData::Status.register({
  :id          => :SLEEP,
  :id_number   => 1,
  :name        => _INTL("Sleep")
})

GameData::Status.register({
  :id          => :POISON,
  :id_number   => 2,
  :name        => _INTL("Poison")
})

GameData::Status.register({
  :id          => :BURN,
  :id_number   => 3,
  :name        => _INTL("Burn")
})

GameData::Status.register({
  :id          => :PARALYSIS,
  :id_number   => 4,
  :name        => _INTL("Paralysis")
})

GameData::Status.register({
  :id          => :FROZEN,
  :id_number   => 5,
  :name        => _INTL("Frozen")
})
