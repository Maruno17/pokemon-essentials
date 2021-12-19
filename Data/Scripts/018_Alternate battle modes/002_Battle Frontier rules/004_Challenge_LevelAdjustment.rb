#===============================================================================
#
#===============================================================================
class LevelAdjustment
  BothTeams          = 0
  EnemyTeam          = 1
  MyTeam             = 2
  BothTeamsDifferent = 3

  def initialize(adjustment)
    @adjustment = adjustment
  end

  def type
    @adjustment
  end

  def self.getNullAdjustment(thisTeam, _otherTeam)
    ret = []
    thisTeam.each_with_index { |pkmn, i| ret[i] = pkmn.level }
    return ret
  end

  def getAdjustment(thisTeam, otherTeam)
    return self.getNullAdjustment(thisTeam, otherTeam)
  end

  def getOldExp(team1, _team2)
    ret = []
    team1.each_with_index { |pkmn, i| ret[i] = pkmn.exp }
    return ret
  end

  def unadjustLevels(team1, team2, adjustments)
    team1.each_with_index do |pkmn, i|
      next if !adjustments[0][i] || pkmn.exp == adjustments[0][i]
      pkmn.exp = adjustments[0][i]
      pkmn.calc_stats
    end
    team2.each_with_index do |pkmn, i|
      next if !adjustments[1][i] || pkmn.exp == adjustments[1][i]
      pkmn.exp = adjustments[1][i]
      pkmn.calc_stats
    end
  end

  def adjustLevels(team1, team2)
    adj1 = nil
    adj2 = nil
    ret = [getOldExp(team1, team2), getOldExp(team2, team1)]
    if @adjustment == BothTeams || @adjustment == MyTeam
      adj1 = getAdjustment(team1, team2)
    elsif @adjustment == BothTeamsDifferent
      adj1 = getMyAdjustment(team1, team2)
    end
    if @adjustment == BothTeams || @adjustment == EnemyTeam
      adj2 = getAdjustment(team2, team1)
    elsif @adjustment == BothTeamsDifferent
      adj2 = getTheirAdjustment(team2, team1)
    end
    if adj1
      team1.each_with_index do |pkmn, i|
        next if pkmn.level == adj1[i]
        pkmn.level = adj1[i]
        pkmn.calc_stats
      end
    end
    if adj2
      team2.each_with_index do |pkmn, i|
        next if pkmn.level == adj2[i]
        pkmn.level = adj2[i]
        pkmn.calc_stats
      end
    end
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class FixedLevelAdjustment < LevelAdjustment
  def initialize(level)
    super(LevelAdjustment::BothTeams)
    @level = level.clamp(1, GameData::GrowthRate.max_level)
  end

  def getAdjustment(thisTeam, _otherTeam)
    ret = []
    thisTeam.each_with_index { |pkmn, i| ret[i] = @level }
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class TotalLevelAdjustment < LevelAdjustment
  def initialize(minLevel, maxLevel, totalLevel)
    super(LevelAdjustment::EnemyTeam)
    @minLevel = minLevel.clamp(1, GameData::GrowthRate.max_level)
    @maxLevel = maxLevel.clamp(1, GameData::GrowthRate.max_level)
    @totalLevel = totalLevel
  end

  def getAdjustment(thisTeam, _otherTeam)
    ret = []
    total = 0
    thisTeam.each_with_index do |pkmn, i|
      ret[i] = @minLevel
      total += @minLevel
    end
    loop do
      work = false
      thisTeam.each_with_index do |pkmn, i|
        next if ret[i] >= @maxLevel || total >= @totalLevel
        ret[i] += 1
        total += 1
        work = true
      end
      break if !work
    end
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class CombinedLevelAdjustment < LevelAdjustment
  def initialize(my, their)
    super(LevelAdjustment::BothTeamsDifferent)
    @my    = my
    @their = their
  end

  def getMyAdjustment(myTeam, theirTeam)
    return @my.getAdjustment(myTeam, theirTeam) if @my
    return LevelAdjustment.getNullAdjustment(myTeam, theirTeam)
  end

  def getTheirAdjustment(theirTeam, myTeam)
    return @their.getAdjustment(theirTeam, myTeam) if @their
    return LevelAdjustment.getNullAdjustment(theirTeam, myTeam)
  end
end

#===============================================================================
#
#===============================================================================
class SinglePlayerCappedLevelAdjustment < CombinedLevelAdjustment
  def initialize(level)
    super(CappedLevelAdjustment.new(level), FixedLevelAdjustment.new(level))
  end
end

#===============================================================================
#
#===============================================================================
class CappedLevelAdjustment < LevelAdjustment
  def initialize(level)
    super(LevelAdjustment::BothTeams)
    @level = level.clamp(1, GameData::GrowthRate.max_level)
  end

  def getAdjustment(thisTeam, _otherTeam)
    ret = []
    thisTeam.each_with_index { |pkmn, i| ret[i] = [pkmn.level, @level].min }
    return ret
  end
end

#===============================================================================
# Unused
#===============================================================================
class LevelBalanceAdjustment < LevelAdjustment
  def initialize(minLevel)
    super(LevelAdjustment::BothTeams)
    @minLevel = minLevel
  end

  def getAdjustment(thisTeam, _otherTeam)
    ret = []
    thisTeam.each_with_index do |pkmn, i|
      ret[i] = (113 - (pbBaseStatTotal(pkmn.species) * 0.072)).round
    end
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class EnemyLevelAdjustment < LevelAdjustment
  def initialize(level)
    super(LevelAdjustment::EnemyTeam)
    @level = level.clamp(1, GameData::GrowthRate.max_level)
  end

  def getAdjustment(thisTeam, _otherTeam)
    ret = []
    thisTeam.each_with_index { |pkmn, i| ret[i] = @level }
    return ret
  end
end

#===============================================================================
#
#===============================================================================
class OpenLevelAdjustment < LevelAdjustment
  def initialize(minLevel = 1)
    super(LevelAdjustment::EnemyTeam)
    @minLevel = minLevel
  end

  def getAdjustment(thisTeam, otherTeam)
    maxLevel = 1
    otherTeam.each do |pkmn|
      level = pkmn.level
      maxLevel = level if maxLevel < level
    end
    maxLevel = @minLevel if maxLevel < @minLevel
    ret = []
    thisTeam.each_with_index { |pkmn, i| ret[i] = maxLevel }
    return ret
  end
end
