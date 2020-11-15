# Colors must begin at 0 and have no missing numbers
module PBColors
  Red    = 0
  Blue   = 1
  Yellow = 2
  Green  = 3
  Black  = 4
  Brown  = 5
  Purple = 6
  Gray   = 7
  White  = 8
  Pink   = 9

  def self.maxValue;  9; end
  def self.getCount; 10; end

  def self.getName(id)
    id = getID(PBColors,id)
    names = [
      _INTL("Red"),
      _INTL("Blue"),
      _INTL("Yellow"),
      _INTL("Green"),
      _INTL("Black"),
      _INTL("Brown"),
      _INTL("Purple"),
      _INTL("Gray"),
      _INTL("White"),
      _INTL("Pink")
    ]
    return names[id]
  end
end
