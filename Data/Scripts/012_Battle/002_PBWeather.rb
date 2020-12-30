begin
  module PBWeather
    None        = 0
    Sun         = 1
    Rain        = 2
    Sandstorm   = 3
    Hail        = 4
    HarshSun    = 5
    HeavyRain   = 6
    StrongWinds = 7
    ShadowSky   = 8

    def self.animationName(weather)
      case weather
      when Sun         then return "Sun"
      when Rain        then return "Rain"
      when Sandstorm   then return "Sandstorm"
      when Hail        then return "Hail"
      when HarshSun    then return "HarshSun"
      when HeavyRain   then return "HeavyRain"
      when StrongWinds then return "StrongWinds"
      when ShadowSky   then return "ShadowSky"
      end
      return nil
    end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end
