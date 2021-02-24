#===============================================================================
# Terrain tags
#===============================================================================
module PBTerrain
  None            = 0
  Ledge           = 1
  Grass           = 2
  Sand            = 3
  Rock            = 4
  DeepWater       = 5
  StillWater      = 6
  Water           = 7
  Waterfall       = 8
  WaterfallCrest  = 9
  TallGrass       = 10
  UnderwaterGrass = 11
  Ice             = 12
  Neutral         = 13
  SootGrass       = 14
  Bridge          = 15
  Puddle          = 16

  module_function

  def isSurfable?(tag)
    return isWater?(tag)
  end

  def isWater?(tag)
    return [Water, StillWater, DeepWater, WaterfallCrest, Waterfall].include?(tag)
  end

  def isPassableWater?(tag)
    return [Water, StillWater, DeepWater, WaterfallCrest].include?(tag)
  end

  def isJustWater?(tag)
    return [Water, StillWater, DeepWater].include?(tag)
  end

  def isDeepWater?(tag)
    return tag == DeepWater
  end

  def isWaterfall?(tag)
    return [WaterfallCrest, Waterfall].include?(tag)
  end

  def isGrass?(tag)
    return [Grass, TallGrass, UnderwaterGrass, SootGrass].include?(tag)
  end

  def isJustGrass?(tag)   # The Poké Radar only works in these tiles
    return [Grass, SootGrass].include?(tag)
  end

  def isLedge?(tag)
    return tag == Ledge
  end

  def isIce?(tag)
    return tag == Ice
  end

  def isBridge?(tag)
    return tag == Bridge
  end

  def hasReflections?(tag)
    return [StillWater, Puddle].include?(tag)
  end

  def onlyWalk?(tag)
    return [TallGrass, Ice].include?(tag)
  end

  def isDoubleWildBattle?(tag)
    return tag == TallGrass
  end
end
