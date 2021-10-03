module GameData
  class BerryPlant
    attr_reader :id
    attr_reader :hours_per_stage
    attr_reader :drying_per_hour
    attr_reader :minimum_yield
    attr_reader :maximum_yield

    DATA = {}
    DATA_FILENAME = "berry_plants.dat"

    NUMBER_OF_REPLANTS           = 9
    NUMBER_OF_GROWTH_STAGES      = 4
    NUMBER_OF_FULLY_GROWN_STAGES = 4
    WATERING_CANS                = [:SPRAYDUCK, :SQUIRTBOTTLE, :WAILMERPAIL, :SPRINKLOTAD]

    extend ClassMethodsSymbols
    include InstanceMethods

    def initialize(hash)
      @id              = hash[:id]
      @hours_per_stage = hash[:hours_per_stage] || 3
      @drying_per_hour = hash[:drying_per_hour] || 15
      @minimum_yield   = hash[:minimum_yield]   || 2
      @maximum_yield   = hash[:maximum_yield]   || 5
    end
  end
end
