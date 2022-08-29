#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitTwoTimes",
  proc { |power, move, user, target, ai, battle|
    next power * move.pbNumHits(user.battler, [target.battler])
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("HitTwoTimes",
                                         "HitTwoTimesPoisonTarget")
Battle::AI::Handlers::MoveEffectScore.add("HitTwoTimesPoisonTarget",
  proc { |score, move, user, target, ai, battle|
    next 0 if !target.battler.pbCanPoison?(user.battler, false)
    score += 30
    if ai.trainer.medium_skill?
      score += 30 if target.hp <= target.totalhp / 4
      score += 50 if target.hp <= target.totalhp / 8
      score -= 40 if target.effects[PBEffects::Yawn] > 0
    end
    if ai.trainer.high_skill?
      score += 10 if target.rough_stat(:DEFENSE) > 100
      score += 10 if target.rough_stat(:SPECIAL_DEFENSE) > 100
    end
    score -= 40 if target.has_active_ability?([:GUTS, :MARVELSCALE, :TOXICBOOST])
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("HitTwoTimes",
                                         "HitTwoTimesFlinchTarget")
Battle::AI::Handlers::MoveEffectScore.add("HitTwoTimesFlinchTarget",
  proc { |score, move, user, target, ai, battle|
    next score + 30 if target.effects[PBEffects::Minimize]
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitTwoTimesTargetThenTargetAlly",
  proc { |power, move, user, target, ai, battle|
    next power * 2
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitThreeTimesPowersUpWithEachHit",
  proc { |power, move, user, target, ai, battle|
    next power * 6   # Hits do x1, x2, x3 ret in turn, for x6 in total
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitThreeTimesAlwaysCriticalHit",
  proc { |power, move, user, target, ai, battle|
    next power * move.pbNumHits(user.battler, [target.battler])
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HitThreeTimesAlwaysCriticalHit",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.high_skill?
      stat = (move.physicalMove?) ? :DEFENSE : :SPECIAL_DEFENSE
      next score + 50 if target.stages[stat] > 1
    end
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitTwoToFiveTimes",
  proc { |power, move, user, target, ai, battle|
    next power * 5 if user.has_active_ability?(:SKILLLINK)
    next power * 31 / 10   # Average damage dealt
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitTwoToFiveTimesOrThreeForAshGreninja",
  proc { |power, move, user, target, ai, battle|
    if user.battler.isSpecies?(:GRENINJA) && user.battler.form == 2
      next move.pbBaseDamage(power, user.battler, target.battler) * move.pbNumHits(user.battler, [target.battler])
    end
    next power * 5 if user.has_active_ability?(:SKILLLINK)
    next power * 31 / 10   # Average damage dealt
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1",
  proc { |power, move, user, target, ai, battle|
    next power * 5 if user.has_active_ability?(:SKILLLINK)
    next power * 31 / 10   # Average damage dealt
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1",
  proc { |score, move, user, target, ai, battle|
    aspeed = user.rough_stat(:SPEED)
    ospeed = target.rough_stat(:SPEED)
    if aspeed > ospeed && aspeed * 2 / 3 < ospeed
      score -= 50
    elsif aspeed < ospeed && aspeed * 1.5 > ospeed
      score += 50
    end
    score += user.stages[:DEFENSE] * 30
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HitOncePerUserTeamMember",
  proc { |move, user, target, ai, battle|
    will_fail = true
    battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, i|
      next if !pkmn.able? || pkmn.status != :NONE
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveBasePower.add("HitOncePerUserTeamMember",
  proc { |power, move, user, target, ai, battle|
    ret = 0
    ai.battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, _i|
      ret += 5 + (pkmn.baseStats[:ATTACK] / 10)
    end
    next ret
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# AttackAndSkipNextTurn

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TwoTurnAttack

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("TwoTurnAttackOneTurnInSun",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamageMultiplier(power, user.battler, target.battler)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackParalyzeTarget",
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanParalyze?(user.battler, false)
      score += 30
      if ai.trainer.medium_skill?
        aspeed = user.rough_stat(:SPEED)
        ospeed = target.rough_stat(:SPEED)
        if aspeed < ospeed
          score += 30
        elsif aspeed > ospeed
          score -= 40
        end
      end
      score -= 40 if target.has_active_ability?([:GUTS, :MARVELSCALE, :QUICKFEET])
    elsif ai.trainer.medium_skill?
      score -= 90 if move.statusMove?
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackBurnTarget",
  proc { |score, move, user, target, ai, battle|
    next 0 if !target.battler.pbCanBurn?(user.battler, false)
    score += 30
    score -= 40 if target.has_active_ability?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackFlinchTarget",
  proc { |score, move, user, target, ai, battle|
    score += 20 if user.effects[PBEffects::FocusEnergy] > 0
    score += 20 if (battle.moldBreaker || !target.has_active_ability?(:INNERFOCUS)) &&
                   target.effects[PBEffects::Substitute] == 0
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("TwoTurnAttackRaiseUserSpAtkSpDefSpd2",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move) &&
                 !user.battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user.battler, move.move) &&
                 !user.battler.pbCanRaiseStatStage?(:SPEED, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackRaiseUserSpAtkSpDefSpd2",
  proc { |score, move, user, target, ai, battle|
    if user.statStageAtMax?(:SPECIAL_ATTACK) &&
       user.statStageAtMax?(:SPECIAL_DEFENSE) &&
       user.statStageAtMax?(:SPEED)
      score -= 90
    else
      score -= user.stages[:SPECIAL_ATTACK] * 10   # Only *10 instead of *20
      score -= user.stages[:SPECIAL_DEFENSE] * 10   # because two-turn attack
      score -= user.stages[:SPEED] * 10
      if ai.trainer.medium_skill?
        hasSpecialAttack = false
        user.battler.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecialAttack = true
          break
        end
        if hasSpecialAttack
          score += 20
        elsif ai.trainer.high_skill?
          score -= 90
        end
      end
      if ai.trainer.high_skill?
        aspeed = user.rough_stat(:SPEED)
        ospeed = target.rough_stat(:SPEED)
        score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackChargeRaiseUserDefense1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      if user.statStageAtMax?(:DEFENSE)
        score -= 90
      else
        score -= user.stages[:DEFENSE] * 20
      end
    elsif user.stages[:DEFENSE] < 0
      score += 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackChargeRaiseUserSpAtk1",
  proc { |score, move, user, target, ai, battle|
    aspeed = user.rough_stat(:SPEED)
    ospeed = target.rough_stat(:SPEED)
    if (aspeed > ospeed && user.hp > user.totalhp / 3) || user.hp > user.totalhp / 2
      score += 60
    else
      score -= 90
    end
    score += user.stages[:SPECIAL_ATTACK] * 20
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TwoTurnAttackInvulnerableUnderground

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TwoTurnAttackInvulnerableUnderwater

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TwoTurnAttackInvulnerableInSky

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TwoTurnAttackInvulnerableInSkyParalyzeTarget

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("TwoTurnAttackInvulnerableInSkyTargetCannotAct",
  proc { |move, user, target, ai, battle|
    next true if !target.opposes?(user)
    next true if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
    next true if Settings::MECHANICS_GENERATION >= 6 && target.battler.pbWeight >= 2000   # 200.0kg
    next true if target.battler.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TwoTurnAttackInvulnerableRemoveProtections

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# MultiTurnAttackPreventSleeping

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# MultiTurnAttackConfuseUserAtEnd

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("MultiTurnAttackPowersUpEachTurn",
  proc { |power, move, user, target, ai, battle|
    next power * 2 if user.effects[PBEffects::DefenseCurl]
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("MultiTurnAttackBideThenReturnDoubleDamage",
  proc { |power, move, user, target, ai, battle|
    next 40   # Representative value
  }
)
Battle::AI::Handlers::MoveEffectScore.add("MultiTurnAttackBideThenReturnDoubleDamage",
  proc { |score, move, user, target, ai, battle|
    if user.hp <= user.totalhp / 4
      score -= 90
    elsif user.hp <= user.totalhp / 2
      score -= 50
    end
    next score
  }
)
