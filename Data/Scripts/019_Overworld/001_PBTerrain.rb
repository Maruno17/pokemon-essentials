#===============================================================================
# Terrain tags
#===============================================================================
module PBTerrain
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

  def self.isSurfable?(tag)
    return PBTerrain.isWater?(tag)
  end

  def self.isWater?(tag)
    return tag==PBTerrain::Water ||
           tag==PBTerrain::StillWater ||
           tag==PBTerrain::DeepWater ||
           tag==PBTerrain::WaterfallCrest ||
           tag==PBTerrain::Waterfall
  end

  def self.isPassableWater?(tag)
    return tag==PBTerrain::Water ||
           tag==PBTerrain::StillWater ||
           tag==PBTerrain::DeepWater ||
           tag==PBTerrain::WaterfallCrest
  end

  def self.isJustWater?(tag)
    return tag==PBTerrain::Water ||
           tag==PBTerrain::StillWater ||
           tag==PBTerrain::DeepWater
  end

  def self.isDeepWater?(tag)
    return tag==PBTerrain::DeepWater
  end

  def self.isWaterfall?(tag)
    return tag==PBTerrain::WaterfallCrest ||
           tag==PBTerrain::Waterfall
  end

  def self.isGrass?(tag)
    return tag==PBTerrain::Grass ||
           tag==PBTerrain::TallGrass ||
           tag==PBTerrain::UnderwaterGrass ||
           tag==PBTerrain::SootGrass
  end

  def self.isJustGrass?(tag)   # The Poké Radar only works in these tiles
    return tag==PBTerrain::Grass ||
           tag==PBTerrain::SootGrass
  end

  def self.isLedge?(tag)
    return tag==PBTerrain::Ledge
  end

  def self.isIce?(tag)
    return tag==PBTerrain::Ice
  end

  def self.isBridge?(tag)
    return tag==PBTerrain::Bridge
  end

  def self.hasReflections?(tag)
    return tag==PBTerrain::StillWater ||
           tag==PBTerrain::Puddle
  end

  def self.onlyWalk?(tag)
    return tag==PBTerrain::TallGrass ||
           tag==PBTerrain::Ice
  end

  def self.isDoubleWildBattle?(tag)
    return tag==PBTerrain::TallGrass
  end
end
