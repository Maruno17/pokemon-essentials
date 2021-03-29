module GameData
  class BattleWeather
    attr_reader :id
    attr_reader :real_name
    attr_reader :animation

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id        = hash[:id]
      @real_name = hash[:name] || "Unnamed"
      @animation = hash[:animation]
    end

    # @return [String] the translated name of this battle weather
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::BattleWeather.register({
  :id   => :None,
  :name => _INTL("None")
})

GameData::BattleWeather.register({
  :id        => :Sun,
  :name      => _INTL("Sun"),
  :animation => "Sun"
})

GameData::BattleWeather.register({
  :id        => :Rain,
  :name      => _INTL("Rain"),
  :animation => "Rain"
})

GameData::BattleWeather.register({
  :id        => :Sandstorm,
  :name      => _INTL("Sandstorm"),
  :animation => "Sandstorm"
})

GameData::BattleWeather.register({
  :id        => :Hail,
  :name      => _INTL("Hail"),
  :animation => "Hail"
})

GameData::BattleWeather.register({
  :id        => :HarshSun,
  :name      => _INTL("Harsh Sun"),
  :animation => "HarshSun"
})

GameData::BattleWeather.register({
  :id        => :HeavyRain,
  :name      => _INTL("Heavy Rain"),
  :animation => "HeavyRain"
})

GameData::BattleWeather.register({
  :id        => :StrongWinds,
  :name      => _INTL("Strong Winds"),
  :animation => "StrongWinds"
})

GameData::BattleWeather.register({
  :id        => :ShadowSky,
  :name      => _INTL("Shadow Sky"),
  :animation => "ShadowSky"
})
