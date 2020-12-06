module GameData
  class TrainerType
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :base_money
    attr_reader :battle_BGM
    attr_reader :victory_ME
    attr_reader :intro_ME
    attr_reader :gender
    attr_reader :skill_level
    attr_reader :skill_code

    DATA = {}
    DATA_FILENAME = "trainer_types.dat"

    extend ClassMethods
    include InstanceMethods

    def initialize(hash)
      @id          = hash[:id]
      @id_number   = hash[:id_number]   || -1
      @real_name   = hash[:name]        || "Unnamed"
      @base_money  = hash[:base_money]  || 30
      @battle_BGM  = hash[:battle_BGM]
      @victory_ME  = hash[:victory_ME]
      @intro_ME    = hash[:intro_ME]
      @gender      = hash[:gender]      || 2
      @skill_level = hash[:skill_level] || @base_money
      @skill_code  = hash[:skill_code]
    end

    # @return [String] the translated name of this trainer type
    def name
      return pbGetMessage(MessageTypes::TrainerTypes, @id_number)
    end

    def male?;   return @gender == 0; end
    def female?; return @gender == 1; end
  end
end

#===============================================================================
# Deprecated methods
#===============================================================================
def pbGetTrainerTypeData(trainer_type)
  Deprecation.warn_method('pbGetTrainerTypeData', 'v20', 'GameData::TrainerType.get(trainer_type)')
  return GameData::TrainerType.get(trainer_type)
end
