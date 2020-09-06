# These are in-battle terrain effects caused by moves like Electric Terrain.
begin
  module PBBattleTerrains
    None     = 0
    Electric = 1
    Grassy   = 2
    Misty    = 3
    Psychic  = 4

    def self.animationName(terrain)
      case terrain
      when Electric; return "ElectricTerrain"
      when Grassy;   return "GrassyTerrain"
      when Misty;    return "MistyTerrain"
      when Psychic;  return "PsychicTerrain"
      end
      return nil
    end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end
