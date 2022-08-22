#===============================================================================
#
#===============================================================================

# HitTwoTimes

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

Battle::AI::Handlers::MoveEffectScore.add("HitTwoTimesFlinchTarget",
  proc { |score, move, user, target, ai, battle|
    next score + 30 if target.effects[PBEffects::Minimize]
  }
)

# HitTwoTimesTargetThenTargetAlly

# HitThreeTimesPowersUpWithEachHit

Battle::AI::Handlers::MoveEffectScore.add("HitThreeTimesAlwaysCriticalHit",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.high_skill?
      stat = (move.physicalMove?) ? :DEFENSE : :SPECIAL_DEFENSE
      next score + 50 if target.stages[stat] > 1
    end
  }
)

# HitTwoToFiveTimes

# HitTwoToFiveTimesOrThreeForAshGreninja

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

# HitOncePerUserTeamMember

# AttackAndSkipNextTurn

# TwoTurnAttack

# TwoTurnAttackOneTurnInSun

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

Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackBurnTarget",
  proc { |score, move, user, target, ai, battle|
    next 0 if !target.battler.pbCanBurn?(user.battler, false)
    score += 30
    score -= 40 if target.has_active_ability?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackFlinchTarget",
  proc { |score, move, user, target, ai, battle|
    score += 20 if user.effects[PBEffects::FocusEnergy] > 0
    score += 20 if !target.has_active_ability?(:INNERFOCUS) &&
                   target.effects[PBEffects::Substitute] == 0
    next score
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

# TwoTurnAttackInvulnerableUnderground

# TwoTurnAttackInvulnerableUnderwater

# TwoTurnAttackInvulnerableInSky

# TwoTurnAttackInvulnerableInSkyParalyzeTarget

# TwoTurnAttackInvulnerableInSkyTargetCannotAct

# TwoTurnAttackInvulnerableRemoveProtections

# MultiTurnAttackPreventSleeping

# MultiTurnAttackConfuseUserAtEnd

# MultiTurnAttackPowersUpEachTurn

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
