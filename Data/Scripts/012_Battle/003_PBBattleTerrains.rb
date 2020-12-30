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
      when Electric then return "ElectricTerrain"
      when Grassy   then return "GrassyTerrain"
      when Misty    then return "MistyTerrain"
      when Psychic  then return "PsychicTerrain"
      end
      return nil
    end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end
