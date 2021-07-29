#===============================================================================
#
#===============================================================================
class BattleRule
  def setRule(battle); end
end

#===============================================================================
#
#===============================================================================
class DoubleBattle < BattleRule
  def setRule(battle); battle.setBattleMode("double"); end
end

#===============================================================================
#
#===============================================================================
class SingleBattle < BattleRule
  def setRule(battle); battle.setBattleMode("single"); end
end

#===============================================================================
#
#===============================================================================
class SoulDewBattleClause < BattleRule
  def setRule(battle); battle.rules["souldewclause"] = true; end
end

#===============================================================================
#
#===============================================================================
class SleepClause < BattleRule
  def setRule(battle); battle.rules["sleepclause"] = true; end
end

#===============================================================================
#
#===============================================================================
class FreezeClause < BattleRule
  def setRule(battle); battle.rules["freezeclause"] = true; end
end

#===============================================================================
#
#===============================================================================
class EvasionClause < BattleRule
  def setRule(battle); battle.rules["evasionclause"] = true; end
end

#===============================================================================
#
#===============================================================================
class OHKOClause < BattleRule
  def setRule(battle); battle.rules["ohkoclause"] = true; end
end

#===============================================================================
#
#===============================================================================
class PerishSongClause < BattleRule
  def setRule(battle); battle.rules["perishsong"] = true; end
end

#===============================================================================
#
#===============================================================================
class SelfKOClause < BattleRule
  def setRule(battle); battle.rules["selfkoclause"] = true; end
end

#===============================================================================
#
#===============================================================================
class SelfdestructClause < BattleRule
  def setRule(battle); battle.rules["selfdestructclause"] = true; end
end

#===============================================================================
#
#===============================================================================
class SonicBoomClause < BattleRule
  def setRule(battle); battle.rules["sonicboomclause"] = true; end
end

#===============================================================================
#
#===============================================================================
class ModifiedSleepClause < BattleRule
  def setRule(battle); battle.rules["modifiedsleepclause"] = true; end
end

#===============================================================================
#
#===============================================================================
class SkillSwapClause < BattleRule
  def setRule(battle); battle.rules["skillswapclause"] = true; end
end
