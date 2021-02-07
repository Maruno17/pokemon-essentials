module GameData
  class BerryPlant
    attr_reader :id
    attr_reader :id_number
    attr_reader :hours_per_stage
    attr_reader :drying_per_hour
    attr_reader :minimum_yield
    attr_reader :maximum_yield

    DATA = {}
    DATA_FILENAME = "berry_plants.dat"

    NUMBER_OF_REPLANTS = 9

    extend ClassMethods
    include InstanceMethods

    def initialize(hash)
      @id              = hash[:id]
      @id_number       = hash[:id_number]   || -1
      @hours_per_stage = hash[:hours_per_stage] || 3
      @drying_per_hour = hash[:drying_per_hour] || 15
      @minimum_yield   = hash[:minimum_yield] || 2
      @maximum_yield   = hash[:maximum_yield] || 5
    end
  end
end

#===============================================================================
# Deprecated methods
#===============================================================================
# @deprecated This alias is slated to be removed in v20.
def pbGetBerryPlantData(item)
  Deprecation.warn_method('pbGetBerryPlantData', 'v20', 'GameData::BerryPlant.get(item)')
  return GameData::BerryPlant.get(item)
end
