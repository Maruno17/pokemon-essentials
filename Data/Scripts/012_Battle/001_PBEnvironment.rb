begin
  module PBEnvironment
    None        = 0
    Grass       = 1
    TallGrass   = 2
    MovingWater = 3
    StillWater  = 4
    Puddle      = 5
    Underwater  = 6
    Cave        = 7
    Rock        = 8
    Sand        = 9
    Forest      = 10
    ForestGrass = 11
    Snow        = 12
    Ice         = 13
    Volcano     = 14
    Graveyard   = 15
    Sky         = 16
    Space       = 17
    UltraSpace  = 18

    def self.maxValue; return 18; end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end
