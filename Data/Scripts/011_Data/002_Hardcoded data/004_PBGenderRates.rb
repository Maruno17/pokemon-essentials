module PBGenderRates
  Genderless         = 0
  AlwaysMale         = 1
  FemaleOneEighth    = 2
  Female25Percent    = 3
  Female50Percent    = 4
  Female75Percent    = 5
  FemaleSevenEighths = 6
  AlwaysFemale       = 7

  def self.maxValue; return 7; end

  def self.genderByte(gender)
    case gender
    when AlwaysMale         then return 0
    when FemaleOneEighth    then return 32
    when Female25Percent    then return 64
    when Female50Percent    then return 128
    when Female75Percent    then return 192
    when FemaleSevenEighths then return 224
    when AlwaysFemale       then return 254
    when Genderless         then return 255
    end
    return 255   # Default value (genderless)
  end
end
