module PBGenderRates
  Genderless         = 0
  AlwaysMale         = 1
  FemaleOneEighth    = 2
  Female25Percent    = 3
  Female50Percent    = 4
  Female75Percent    = 5
  FemaleSevenEighths = 6
  AlwaysFemale       = 7

  def self.genderByte(gender)
    case gender
    when AlwaysMale;         return 0
    when FemaleOneEighth;    return 32
    when Female25Percent;    return 64
    when Female50Percent;    return 128
    when Female75Percent;    return 192
    when FemaleSevenEighths; return 224
    when AlwaysFemale;       return 254
    when Genderless;         return 255
    end
    return 255   # Default value (genderless)
  end
end
