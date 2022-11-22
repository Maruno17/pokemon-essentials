module GameData
  class BerryPlant
    attr_reader :id
    attr_reader :hours_per_stage
    attr_reader :drying_per_hour
    attr_reader :yield
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "berry_plants.dat"
    PBS_BASE_FILENAME = "berry_plants"

    SCHEMA = {
      "SectionName"   => [:id,              "m"],
      "HoursPerStage" => [:hours_per_stage, "v"],
      "DryingPerHour" => [:drying_per_hour, "u"],
      "Yield"         => [:yield,           "uv"]
    }

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
      @yield           = hash[:yield]           || [2, 5]
      @yield.reverse! if @yield[1] < @yield[0]
      @pbs_file_suffix = hash[:pbs_file_suffix] || ""
    end

    def minimum_yield
      return @yield[0]
    end

    def maximum_yield
      return @yield[1]
    end
  end
end
