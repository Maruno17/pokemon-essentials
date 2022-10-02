module GameData
  class PhoneMessage
    attr_reader :id
    attr_reader :trainer_type, :real_name, :version
    attr_reader :intro, :intro_morning, :intro_afternoon, :intro_evening
    attr_reader :body, :body1, :body2
    attr_reader :battle_request, :battle_remind
    attr_reader :end

    DATA = {}
    DATA_FILENAME = "phone.dat"

    SCHEMA = {
      "Intro"          => [:intro, "q"],
      "IntroMorning"   => [:intro_morning, "q"],
      "IntroAfternoon" => [:intro_afternoon, "q"],
      "IntroEvening"   => [:intro_evening, "q"],
      "Body"           => [:body, "q"],
      "Body1"          => [:body1, "q"],
      "Body2"          => [:body2, "q"],
      "BattleRequest"  => [:battle_request, "q"],
      "BattleRemind"   => [:battle_remind, "q"],
      "End"            => [:end, "q"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    # @param tr_type [Symbol, String]
    # @param tr_name [String]
    # @param tr_version [Integer, nil]
    # @return [Boolean] whether the given other is defined as a self
    def self.exists?(tr_type, tr_name, tr_version = 0)
      validate tr_type => [Symbol, String]
      validate tr_name => [String]
      key = [tr_type.to_sym, tr_name, tr_version]
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

    def initialize(hash)
      @id              = hash[:id]
      @trainer_type    = hash[:trainer_type]
      @real_name       = hash[:name]
      @version         = hash[:version] || 0
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
    end

    def property_from_string(str)
      case str
      when "Intro"          then return @intro
      when "IntroMorning"   then return @intro_morning
      when "IntroAfternoon" then return @intro_afternoon
      when "IntroEvening"   then return @intro_evening
      when "Body"           then return @body
      when "Body1"          then return @body1
      when "Body2"          then return @body2
      when "BattleRequest"  then return @battle_request
      when "BattleRemind"   then return @battle_remind
      when "End"            then return @end
      end
      return nil
    end
  end
end
