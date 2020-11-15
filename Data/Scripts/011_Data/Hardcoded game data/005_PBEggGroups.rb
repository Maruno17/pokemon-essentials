module PBEggGroups
  Undiscovered = 0    # NoEggs, None, NA
  Monster      = 1
  Water1       = 2
  Bug          = 3
  Flying       = 4
  Field        = 5    # Ground
  Fairy        = 6
  Grass        = 7    # Plant
  Humanlike    = 8    # Humanoid, Humanshape, Human
  Water3       = 9
  Mineral      = 10
  Amorphous    = 11   # Indeterminate
  Water2       = 12
  Ditto        = 13
  Dragon       = 14

  def self.maxValue; 14; end
  def self.getCount; 15; end

  def self.getName(id)
    id = getID(PBEggGroups,id)
    names = [
      _INTL("Undiscovered"),
      _INTL("Monster"),
      _INTL("Water 1"),
      _INTL("Bug"),
      _INTL("Flying"),
      _INTL("Field"),
      _INTL("Fairy"),
      _INTL("Grass"),
      _INTL("Human-like"),
      _INTL("Water 3"),
      _INTL("Mineral"),
      _INTL("Amorphous"),
      _INTL("Water 2"),
      _INTL("Ditto"),
      _INTL("Dragon")
    ]
    return names[id]
  end
end
