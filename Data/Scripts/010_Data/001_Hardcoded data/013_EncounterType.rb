module GameData
  class EncounterType
    attr_reader :id
    attr_reader :real_name
    attr_reader :type   # :land, :cave, :water, :fishing, :contest, :none
    attr_reader :trigger_chance

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id             = hash[:id]
      @real_name      = hash[:id].to_s        || "Unnamed"
      @type           = hash[:type]           || :none
      @trigger_chance = hash[:trigger_chance] || 0
    end
  end
end

#===============================================================================

GameData::EncounterType.register({
  :id             => :Land,
  :type           => :land,
  :trigger_chance => 21
})

GameData::EncounterType.register({
  :id             => :LandDay,
  :type           => :land,
  :trigger_chance => 21
})

GameData::EncounterType.register({
  :id             => :LandNight,
  :type           => :land,
  :trigger_chance => 21
})

GameData::EncounterType.register({
  :id             => :LandMorning,
  :type           => :land,
  :trigger_chance => 21
})

GameData::EncounterType.register({
  :id             => :LandAfternoon,
  :type           => :land,
  :trigger_chance => 21
})

GameData::EncounterType.register({
  :id             => :LandEvening,
  :type           => :land,
  :trigger_chance => 21
})

GameData::EncounterType.register({
  :id             => :Cave,
  :type           => :cave,
  :trigger_chance => 5
})

GameData::EncounterType.register({
  :id             => :CaveDay,
  :type           => :cave,
  :trigger_chance => 5
})

GameData::EncounterType.register({
  :id             => :CaveNight,
  :type           => :cave,
  :trigger_chance => 5
})

GameData::EncounterType.register({
  :id             => :CaveMorning,
  :type           => :cave,
  :trigger_chance => 5
})

GameData::EncounterType.register({
  :id             => :CaveAfternoon,
  :type           => :cave,
  :trigger_chance => 5
})

GameData::EncounterType.register({
  :id             => :CaveEvening,
  :type           => :cave,
  :trigger_chance => 5
})

GameData::EncounterType.register({
  :id             => :Water,
  :type           => :water,
  :trigger_chance => 2
})

GameData::EncounterType.register({
  :id             => :WaterDay,
  :type           => :water,
  :trigger_chance => 2
})

GameData::EncounterType.register({
  :id             => :WaterNight,
  :type           => :water,
  :trigger_chance => 2
})

GameData::EncounterType.register({
  :id             => :WaterMorning,
  :type           => :water,
  :trigger_chance => 2
})

GameData::EncounterType.register({
  :id             => :WaterAfternoon,
  :type           => :water,
  :trigger_chance => 2
})

GameData::EncounterType.register({
  :id             => :WaterEvening,
  :type           => :water,
  :trigger_chance => 2
})

GameData::EncounterType.register({
  :id             => :OldRod,
  :type           => :fishing
})

GameData::EncounterType.register({
  :id             => :GoodRod,
  :type           => :fishing
})

GameData::EncounterType.register({
  :id             => :SuperRod,
  :type           => :fishing
})

GameData::EncounterType.register({
  :id             => :RockSmash,
  :type           => :none,
  :trigger_chance => 50
})

GameData::EncounterType.register({
  :id             => :HeadbuttLow,
  :type           => :none
})

GameData::EncounterType.register({
  :id             => :HeadbuttHigh,
  :type           => :none
})

GameData::EncounterType.register({
  :id             => :BugContest,
  :type           => :contest,
  :trigger_chance => 21
})
