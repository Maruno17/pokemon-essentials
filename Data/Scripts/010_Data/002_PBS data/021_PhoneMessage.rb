#===============================================================================
#
#===============================================================================
module GameData
  class PhoneMessage
    attr_reader :id
    attr_reader :trainer_type, :real_name, :version
    attr_reader :intro, :intro_morning, :intro_afternoon, :intro_evening
    attr_reader :body, :body1, :body2
    attr_reader :battle_request, :battle_remind
    attr_reader :end
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "phone.dat"
    PBS_BASE_FILENAME = "phone"
    SCHEMA = {
      "SectionName"    => [:id,              "q"],
      "Intro"          => [:intro,           "^q"],
      "IntroMorning"   => [:intro_morning,   "^q"],
      "IntroAfternoon" => [:intro_afternoon, "^q"],
      "IntroEvening"   => [:intro_evening,   "^q"],
      "Body"           => [:body,            "^q"],
      "Body1"          => [:body1,           "^q"],
      "Body2"          => [:body2,           "^q"],
      "BattleRequest"  => [:battle_request,  "^q"],
      "BattleRemind"   => [:battle_remind,   "^q"],
      "End"            => [:end,             "^q"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    # @param tr_type [Symbol, String]
    # @param tr_name [String, nil] only nil for the default message set
    # @param tr_version [Integer, nil]
    # @return [Boolean] whether the given other is defined as a self
    def self.exists?(tr_type, tr_name = nil, tr_version = 0)
      if tr_type.is_a?(Array)
        tr_name = tr_type[1]
        tr_version = tr_type[2]
        tr_type = tr_type[0]
      end
      validate tr_type => [Symbol, String]
      validate tr_name => [String, NilClass]
      key = [tr_type.to_sym, tr_name, tr_version]
      key = key[0] if key[1].nil?
      return !self::DATA[key].nil?
    end

    # @param tr_type [Symbol, String]
    # @param tr_name [String]
    # @param tr_version [Integer, nil]
    # @return [self]
    def self.get(tr_type, tr_name, tr_version = 0)
      validate tr_type => [Symbol, String]
      validate tr_name => [String]
      key = [tr_type.to_sym, tr_name, tr_version]
      raise "Phone messages not found for #{tr_type} #{tr_name} #{tr_version}." unless self::DATA.has_key?(key)
      return self::DATA[key]
    end

    # @param tr_type [Symbol, String]
    # @param tr_name [String]
    # @param tr_version [Integer, nil]
    # @return [self, nil]
    def self.try_get(tr_type, tr_name, tr_version = 0)
      validate tr_type => [Symbol, String]
      validate tr_name => [String]
      key = [tr_type.to_sym, tr_name, tr_version]
      return (self::DATA.has_key?(key)) ? self::DATA[key] : nil
    end

    #---------------------------------------------------------------------------

    def initialize(hash)
      @id              = hash[:id]
      @trainer_type    = hash[:trainer_type]
      @real_name       = hash[:real_name]
      @version         = hash[:version]         || 0
      @intro           = hash[:intro]
      @intro_morning   = hash[:intro_morning]
      @intro_afternoon = hash[:intro_afternoon]
      @intro_evening   = hash[:intro_evening]
      @body            = hash[:body]
      @body1           = hash[:body1]
      @body2           = hash[:body2]
      @battle_request  = hash[:battle_request]
      @battle_remind   = hash[:battle_remind]
      @end             = hash[:end]
      @pbs_file_suffix = hash[:pbs_file_suffix] || ""
    end

    alias __orig__get_property_for_PBS get_property_for_PBS unless method_defined?(:__orig__get_property_for_PBS)
    def get_property_for_PBS(key)
      if key == "SectionName"
        return "Default" if @id == "default"
        ret = [@trainer_type, @real_name, (@version > 0) ? @version : nil]
        return ret.compact.join(",")
      end
      return __orig__get_property_for_PBS(key)
    end
  end
end
