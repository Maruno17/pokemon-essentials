module EncounterTypes
  Land           = 0
  LandDay        = 1
  LandNight      = 2
  LandMorning    = 3
  LandAfternoon  = 4
  LandEvening    = 5
  Cave           = 6
  CaveDay        = 7
  CaveNight      = 8
  CaveMorning    = 9
  CaveAfternoon  = 10
  CaveEvening    = 11
  Water          = 12
  WaterDay       = 13
  WaterNight     = 14
  WaterMorning   = 15
  WaterAfternoon = 16
  WaterEvening   = 17
  OldRod         = 18
  GoodRod        = 19
  SuperRod       = 20
  RockSmash      = 21
  HeadbuttLow    = 22
  HeadbuttHigh   = 23
  BugContest     = 24

  Names = [
    "Land", "LandDay", "LandNight", "LandMorning", "LandAfternoon", "LandEvening",
    "Cave", "CaveDay", "CaveNight", "CaveMorning", "CaveAfternoon", "CaveEvening",
    "Water", "WaterDay", "WaterNight", "WaterMorning", "WaterAfternoon", "WaterEvening",
    "OldRod", "GoodRod", "SuperRod", "RockSmash", "HeadbuttLow", "HeadbuttHigh",
    "BugContest"
  ]
  Probabilities = [
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1],
    [60, 30, 5, 4, 1],
    [60, 30, 5, 4, 1],
    [60, 30, 5, 4, 1],
    [60, 30, 5, 4, 1],
    [60, 30, 5, 4, 1],
    [60, 30, 5, 4, 1],
    [70, 30],
    [60, 20, 20],
    [40, 40, 15, 4, 1],
    [60, 30, 5, 4, 1],
    [30, 25, 20, 10, 5, 5, 4, 1],
    [30, 25, 20, 10, 5, 5, 4, 1],
    [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
  ]
  Chances_Per_Step = [
    25, 25, 25, 25, 25, 25,   # Lands
    10, 10, 10, 10, 10, 10,   # Caves
    10, 10, 10, 10, 10, 10,   # Waters
    0, 0, 0, 0, 0, 0, 25
  ]
  Kinds = [
    1, 1, 1, 1, 1, 1,   # Lands
    2, 2, 2, 2, 2, 2,   # Caves
    3, 3, 3, 3, 3, 3,   # Waters
    0, 0, 0, 0, 0, 0, 1
  ]

  def self.is_land_type?(enc_type)
    return self.is_normal_land_type?(enc_type) || enc_type == BugContest
  end

  def self.is_normal_land_type?(enc_type)
    return [Land, LandDay, LandNight, LandMorning, LandAfternoon, LandEvening].include?(enc_type)
  end

  def self.is_cave_type?(enc_type)
    return [Cave, CaveDay, CaveNight, CaveMorning, CaveAfternoon, CaveEvening].include?(enc_type)
  end

  def self.is_water_type?(enc_type)
    return [Water, WaterDay, WaterNight, WaterMorning, WaterAfternoon, WaterEvening].include?(enc_type)
  end

  def self.is_fishing_type?(enc_type)
    return [OldRod, GoodRod, SuperRod].include?(enc_type)
  end
end
