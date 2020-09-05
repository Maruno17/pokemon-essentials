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
      when Sun;         return "Sun"
      when Rain;        return "Rain"
      when Sandstorm;   return "Sandstorm"
      when Hail;        return "Hail"
      when HarshSun;    return "HarshSun"
      when HeavyRain;   return "HeavyRain"
      when StrongWinds; return "StrongWinds"
      when ShadowSky;   return "ShadowSky"
      end
      return nil
    end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end
