#===============================================================================
#
#===============================================================================

# HitTwoTimes

Battle::AI::Handlers::MoveEffectScore.add("HitTwoTimesPoisonTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !target.pbCanPoison?(user, false)
    score += 30
    if ai.skill_check(Battle::AI::AILevel.medium)
      score += 30 if target.hp <= target.totalhp / 4
      score += 50 if target.hp <= target.totalhp / 8
      score -= 40 if target.effects[PBEffects::Yawn] > 0
    end
    if ai.skill_check(Battle::AI::AILevel.high)
      score += 10 if pbRoughStat(target, :DEFENSE) > 100
      score += 10 if pbRoughStat(target, :SPECIAL_DEFENSE) > 100
      score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :TOXICBOOST])
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HitTwoTimesFlinchTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 30 if target.effects[PBEffects::Minimize]
  }
)

# HitTwoTimesTargetThenTargetAlly

# HitThreeTimesPowersUpWithEachHit

Battle::AI::Handlers::MoveEffectScore.add("HitThreeTimesAlwaysCriticalHit",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.high)
      stat = (move.physicalMove?) ? :DEFENSE : :SPECIAL_DEFENSE
      next score + 50 if targets.stages[stat] > 1
    end
  }
)

# HitTwoToFiveTimes

# HitTwoToFiveTimesOrThreeForAshGreninja

Battle::AI::Handlers::MoveEffectScore.add("HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1",
  proc { |score, move, user, target, skill, ai, battle|
    aspeed = pbRoughStat(user, :SPEED)
    ospeed = pbRoughStat(target, :SPEED)
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
  proc { |score, move, user, target, skill, ai, battle|
    if target.pbCanParalyze?(user, false) &&
       !(ai.skill_check(Battle::AI::AILevel.medium) &&
       move.id == :THUNDERWAVE &&
       Effectiveness.ineffective?(pbCalcTypeMod(move.type, user, target)))
      score += 30
      if ai.skill_check(Battle::AI::AILevel.medium)
        aspeed = pbRoughStat(user, :SPEED)
        ospeed = pbRoughStat(target, :SPEED)
        if aspeed < ospeed
          score += 30
        elsif aspeed > ospeed
          score -= 40
        end
      end
      if ai.skill_check(Battle::AI::AILevel.high)
        score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET])
      end
    elsif ai.skill_check(Battle::AI::AILevel.medium)
      score -= 90 if move.statusMove?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackBurnTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !target.pbCanBurn?(user, false)
    score += 30
    if ai.skill_check(Battle::AI::AILevel.high)
      score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackFlinchTarget",
  proc { |score, move, user, target, skill, ai, battle|
    score += 20 if user.effects[PBEffects::FocusEnergy] > 0
    if ai.skill_check(Battle::AI::AILevel.high)
      score += 20 if !target.hasActiveAbility?(:INNERFOCUS) &&
                     target.effects[PBEffects::Substitute] == 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackRaiseUserSpAtkSpDefSpd2",
  proc { |score, move, user, target, skill, ai, battle|
    if user.statStageAtMax?(:SPECIAL_ATTACK) &&
       user.statStageAtMax?(:SPECIAL_DEFENSE) &&
       user.statStageAtMax?(:SPEED)
      score -= 90
    else
      score -= user.stages[:SPECIAL_ATTACK] * 10   # Only *10 instead of *20
      score -= user.stages[:SPECIAL_DEFENSE] * 10   # because two-turn attack
      score -= user.stages[:SPEED] * 10
      if ai.skill_check(Battle::AI::AILevel.medium)
        hasSpecialAttack = false
        user.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecialAttack = true
          break
        end
        if hasSpecialAttack
          score += 20
        elsif ai.skill_check(Battle::AI::AILevel.high)
          score -= 90
        end
      end
      if ai.skill_check(Battle::AI::AILevel.high)
        aspeed = pbRoughStat(user, :SPEED)
        ospeed = pbRoughStat(target, :SPEED)
        score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TwoTurnAttackChargeRaiseUserDefense1",
  proc { |score, move, user, target, skill, ai, battle|
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
  proc { |score, move, user, target, skill, ai, battle|
    aspeed = pbRoughStat(user, :SPEED)
    ospeed = pbRoughStat(target, :SPEED)
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
  proc { |score, move, user, target, skill, ai, battle|
    if user.hp <= user.totalhp / 4
      score -= 90
    elsif user.hp <= user.totalhp / 2
      score -= 50
    end
    next score
  }
)
