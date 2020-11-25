module PBHabitats
  None         = 0
  Grassland    = 1
  Forest       = 2
  WatersEdge   = 3
  Sea          = 4
  Cave         = 5
  Mountain     = 6
  RoughTerrain = 7
  Urban        = 8
  Rare         = 9

  def self.maxValue;  9; end
  def self.getCount; 10; end

  def self.getName(id)
    id = getID(PBHabitats,id)
    names = [
      _INTL("None"),
      _INTL("Grassland"),
      _INTL("Forest"),
      _INTL("Water's Edge"),
      _INTL("Sea"),
      _INTL("Cave"),
      _INTL("Mountain"),
      _INTL("Rough Terrain"),
      _INTL("Urban"),
      _INTL("Rare")
    ]
    return names[id]
  end
end
