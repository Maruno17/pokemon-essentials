#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("RedirectAllMovesToUser",
  proc { |score, move, user, ai, battle|
    # Useless if there is no ally to redirect attacks from
    next Battle::AI::MOVE_USELESS_SCORE if user.battler.allAllies.length == 0
    # Prefer if ally is at low HP and user is at high HP
    if user.hp > user.totalhp * 2 / 3
      ai.each_ally(user.index) do |b, i|
        score += 10 if b.hp <= b.totalhp / 3
      end
    end
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RedirectAllMovesToTarget",
  proc { |score, move, user, target, ai, battle|
    if target.opposes?(user)
      # Useless if target is a foe but there is only one foe
      next Battle::AI::MOVE_USELESS_SCORE if target.battler.allAllies.length == 0
      # Useless if there is no ally to attack the spotlighted foe
      next Battle::AI::MOVE_USELESS_SCORE if user.battler.allAllies.length == 0
    end
    # Generaly don't prefer this move, as it's a waste of the user's turn
    next score - 15
  }
)

#===============================================================================
#
#===============================================================================
# CannotBeRedirected

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("RandomlyDamageOrHealTarget",
  proc { |power, move, user, target, ai, battle|
    next 50   # Average power, ish
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RandomlyDamageOrHealTarget",
  proc { |score, move, user, ai, battle|
    # Generaly don't prefer this move, as it may heal the target instead
    next score - 8
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("HealAllyOrDamageFoe",
  proc { |move, user, target, ai, battle|
    next true if !target.opposes?(user) && target.battler.canHeal?
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealAllyOrDamageFoe",
  proc { |score, move, user, target, ai, battle|
    if !target.opposes?(user)
      # Consider how much HP will be restored
      if target.hp >= target.totalhp * 0.5
        score -= 10
      else
        score += 20 * (target.totalhp - target.hp) / target.totalhp
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
  proc { |move, user, ai, battle|
    next false if user.has_type?(:GHOST)
    will_fail = true
    (move.move.statUp.length / 2).times do |i|
      next if !user.battler.pbCanRaiseStatStage?(move.move.statUp[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    (move.move.statDown.length / 2).times do |i|
      next if !user.battler.pbCanLowerStatStage?(move.move.statDown[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
  proc { |move, user, target, ai, battle|
    next false if !user.has_type?(:GHOST)
    next true if target.effects[PBEffects::Curse] || !target.battler.takesIndirectDamage?
    next false
  }
)
Battle::AI::Handlers::MoveEffectScore.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
  proc { |score, move, user, ai, battle|
    next score if user.has_type?(:GHOST)
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    next ai.get_score_for_target_stat_drop(score, user, move.move.statDown, false)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
  proc { |score, move, user, target, ai, battle|
    next score if !user.has_type?(:GHOST)
    # Don't prefer if user will faint because of using this move
    next Battle::AI::MOVE_USELESS_SCORE if user.hp <= user.totalhp / 2
    # Prefer early on
    score += 10 if user.turnCount < 2
    if ai.trainer.medium_skill?
      # Prefer if the user has no damaging moves
      score += 20 if !user.check_for_move { |m| m.damagingMove? }
      # Prefer if the target can't switch out to remove its curse
      score += 10 if !battle.pbCanChooseNonActive?(target.index)
    end
    if ai.trainer.high_skill?
      # Prefer if user can stall while damage is dealt
      if user.check_for_move { |m| m.is_a?(Battle::Move::ProtectMove) }
        score += 8
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# EffectDependsOnEnvironment

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitsAllFoesAndPowersUpInPsychicTerrain",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("TargetNextFireMoveDamagesTarget",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Powder]
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TargetNextFireMoveDamagesTarget",
  proc { |score, move, user, target, ai, battle|
    # Effect wears off at the end of the round
    next Battle::AI::MOVE_USELESS_SCORE if target.faster_than?(user)
    # Prefer if target knows any Fire moves (moreso if that's the only type they know)
    if target.check_for_move { |m| m.pbCalcType(b.battler) == :FIRE }
      score += 10
      score += 10 if !target.check_for_move { |m| m.pbCalcType(b.battler) != :FIRE }
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("DoublePowerAfterFusionFlare",
  proc { |score, move, user, ai, battle|
    # Prefer if an ally knows Fusion Flare
    ai.each_ally(user.index) do |b, i|
      score += 10 if b.check_for_move { |m| m.function == "DoublePowerAfterFusionBolt" }
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("DoublePowerAfterFusionBolt",
  proc { |score, move, user, ai, battle|
    # Prefer if an ally knows Fusion Bolt
    ai.each_ally(user.index) do |b, i|
      score += 10 if b.check_for_move { |m| m.function == "DoublePowerAfterFusionFlare" }
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("PowerUpAllyMove",
  proc { |move, user, target, ai, battle|
    next true if target.fainted? || target.effects[PBEffects::HelpingHand]
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("PowerUpAllyMove",
  proc { |score, move, user, target, ai, battle|
    next score + 15
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("CounterPhysicalDamage",
  proc { |power, move, user, target, ai, battle|
    next 60   # Representative value
  }
)
Battle::AI::Handlers::MoveEffectScore.add("CounterPhysicalDamage",
  proc { |score, move, user, ai, battle|
#    next Battle::AI::MOVE_USELESS_SCORE if target.effects[PBEffects::HyperBeam] > 0
    attack = user.rough_stat(:ATTACK)
    spatk  = user.rough_stat(:SPECIAL_ATTACK)
    if attack * 1.5 < spatk
      score -= 60
#    elsif ai.trainer.medium_skill? && target.battler.lastMoveUsed
#      moveData = GameData::Move.get(target.battler.lastMoveUsed)
#      score += 60 if moveData.physical?
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("CounterSpecialDamage",
  proc { |power, move, user, target, ai, battle|
    next 60   # Representative value
  }
)
Battle::AI::Handlers::MoveEffectScore.add("CounterSpecialDamage",
  proc { |score, move, user, ai, battle|
#    next Battle::AI::MOVE_USELESS_SCORE if target.effects[PBEffects::HyperBeam] > 0
    attack = user.rough_stat(:ATTACK)
    spatk  = user.rough_stat(:SPECIAL_ATTACK)
    if attack > spatk * 1.5
      score -= 60
#    elsif ai.trainer.medium_skill? && target.battler.lastMoveUsed
#      moveData = GameData::Move.get(target.battler.lastMoveUsed)
#      score += 60 if moveData.special?
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("CounterDamagePlusHalf",
  proc { |power, move, user, target, ai, battle|
    next 60   # Representative value
  }
)
Battle::AI::Handlers::MoveEffectScore.add("CounterDamagePlusHalf",
  proc { |score, move, user, ai, battle|
#    next Battle::AI::MOVE_USELESS_SCORE if target.effects[PBEffects::HyperBeam] > 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserAddStockpileRaiseDefSpDef1",
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::Stockpile] >= 3
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserAddStockpileRaiseDefSpDef1",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, [:DEFENSE, 1, :SPECIAL_DEFENSE, 1], false)
    # More preferable if user also has Spit Up/Swallow
    score += 20 if user.battler.pbHasMoveFunction?("PowerDependsOnUserStockpile",
                                                   "HealUserDependingOnUserStockpile")
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("PowerDependsOnUserStockpile",
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::Stockpile] == 0
  }
)
Battle::AI::Handlers::MoveBasePower.add("PowerDependsOnUserStockpile",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HealUserDependingOnUserStockpile",
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::Stockpile] == 0
    next true if !user.battler.canHeal? &&
                 user.effects[PBEffects::StockpileDef] == 0 &&
                 user.effects[PBEffects::StockpileSpDef] == 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserDependingOnUserStockpile",
  proc { |score, move, user, ai, battle|
    mult = [0, 25, 50, 100][user.effects[PBEffects::Stockpile]]
    score += mult
    score -= user.hp * mult * 2 / user.totalhp
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("GrassPledge",
  proc { |score, move, user, ai, battle|
    # Prefer if an ally knows a different Pledge move
    ai.each_ally(user.index) do |b, i|
      score += 10 if b.check_for_move { |m| ["FirePledge", "WaterPledge"].include?(m.function) }
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("FirePledge",
  proc { |score, move, user, ai, battle|
    # Prefer if an ally knows a different Pledge move
    ai.each_ally(user.index) do |b, i|
      score += 10 if b.check_for_move { |m| ["GrassPledge", "WaterPledge"].include?(m.function) }
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("WaterPledge",
  proc { |score, move, user, ai, battle|
    # Prefer if an ally knows a different Pledge move
    ai.each_ally(user.index) do |b, i|
      score += 10 if b.check_for_move { |m| ["GrassPledge", "FirePledge"].include?(m.function) }
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UseLastMoveUsed",
  proc { |move, user, ai, battle|
    next true if !battle.lastMoveUsed
    next true if move.move.moveBlacklist.include?(GameData::Move.get(battle.lastMoveUsed).function_code)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("UseLastMoveUsedByTarget",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.lastRegularMoveUsed
    next true if GameData::Move.get(target.battler.lastRegularMoveUsed).flags.none? { |f| f[/^CanMirrorMove$/i] }
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UseLastMoveUsedByTarget",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# UseMoveTargetIsAboutToUse

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# UseMoveDependingOnEnvironment

#===============================================================================
#
#===============================================================================
# UseRandomMove

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UseRandomMoveFromUserParty",
  proc { |move, user, ai, battle|
    will_fail = true
    battle.pbParty(user.index).each_with_index do |pkmn, i|
      next if !pkmn || i == user.party_index
      next if Settings::MECHANICS_GENERATION >= 6 && pkmn.egg?
      pkmn.moves.each do |pkmn_move|
        next if move.move.moveBlacklist.include?(pkmn_move.function_code)
        next if pkmn_move.type == :SHADOW
        will_fail = false
        break
      end
      break if !will_fail
    end
    next will_fail
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UseRandomUserMoveIfAsleep",
  proc { |move, user, ai, battle|
    will_fail = true
    user.battler.eachMoveWithIndex do |m, i|
      next if move.move.moveBlacklist.include?(m.function)
      next if !battle.pbCanChooseMove?(user.index, i, false, true)
      will_fail = false
      break
    end
    next will_fail
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
# BounceBackProblemCausingStatusMoves

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
# StealAndUseBeneficialStatusMove

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("ReplaceMoveThisBattleWithTargetLastMoveUsed",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::Transform] || !user.battler.pbHasMove?(move.id)
    if user.faster_than?(target)
      last_move_data = GameData::Move.try_get(target.battler.lastRegularMoveUsed)
      next true if !last_move_data ||
                   user.battler.pbHasMove?(target.battler.lastRegularMoveUsed) ||
                   move.move.moveBlacklist.include?(last_move_data.function_code) ||
                   last_move_data.type == :SHADOW
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("ReplaceMoveThisBattleWithTargetLastMoveUsed",
  proc { |score, move, user, ai, battle|
    # Generally don't prefer, as this wastes the user's turn just to gain a move
    # of unknown utility
    score -= 8
    # Slightly prefer if this move will definitely succeed, just for the sake of
    # getting rid of this move
    score += 5 if user.faster_than?(target)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("ReplaceMoveThisBattleWithTargetLastMoveUsed",
                                                         "ReplaceMoveWithTargetLastMoveUsed")
Battle::AI::Handlers::MoveEffectScore.copy("ReplaceMoveThisBattleWithTargetLastMoveUsed",
                                           "ReplaceMoveWithTargetLastMoveUsed")
