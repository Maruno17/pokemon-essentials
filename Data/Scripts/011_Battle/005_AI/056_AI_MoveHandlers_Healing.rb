#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("HealUserFullyAndFallAsleep",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.hp == user.totalhp || !user.pbCanSleep?(user, false, nil, true)
    score += 70
    score -= user.hp * 140 / user.totalhp
    score += 30 if user.status != :NONE
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserHalfOfTotalHP",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.hp == user.totalhp || (ai.skill_check(Battle::AI::AILevel.medium) && !user.canHeal?)
    score += 50
    score -= user.hp * 100 / user.totalhp
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserDependingOnWeather",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.hp == user.totalhp || (ai.skill_check(Battle::AI::AILevel.medium) && !user.canHeal?)
    case user.effectiveWeather
    when :Sun, :HarshSun
      score += 30
    when :None
    else
      score -= 30
    end
    score += 50
    score -= user.hp * 100 / user.totalhp
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserDependingOnSandstorm",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.hp == user.totalhp || (ai.skill_check(Battle::AI::AILevel.medium) && !user.canHeal?)
    score += 50
    score -= user.hp * 100 / user.totalhp
    score += 30 if user.effectiveWeather == :Sandstorm
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserHalfOfTotalHPLoseFlyingTypeThisTurn",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.hp == user.totalhp || (ai.skill_check(Battle::AI::AILevel.medium) && !user.canHeal?)
    score += 50
    score -= user.hp * 100 / user.totalhp
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CureTargetStatusHealUserHalfOfTotalHP",
  proc { |score, move, user, target, skill, ai, battle|
    if target.status == :NONE
      score -= 90
    elsif user.hp == user.totalhp && target.opposes?(user)
      score -= 90
    else
      score += (user.totalhp - user.hp) * 50 / user.totalhp
      score -= 30 if target.opposes?(user)
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserByTargetAttackLowerTargetAttack1",
  proc { |score, move, user, target, skill, ai, battle|
    if target.statStageAtMin?(:ATTACK)
      score -= 90
    else
      if target.pbCanLowerStatStage?(:ATTACK, user)
        score += target.stages[:ATTACK] * 20
        if ai.skill_check(Battle::AI::AILevel.medium)
          hasPhysicalAttack = false
          target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif ai.skill_check(Battle::AI::AILevel.high)
            score -= 90
          end
        end
      end
      score += (user.totalhp - user.hp) * 50 / user.totalhp
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserByHalfOfDamageDone",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.high) && target.hasActiveAbility?(:LIQUIDOOZE)
      score -= 70
    elsif user.hp <= user.totalhp / 2
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserByHalfOfDamageDoneIfTargetAsleep",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !target.asleep?
    if ai.skill_check(Battle::AI::AILevel.high) && target.hasActiveAbility?(:LIQUIDOOZE)
      score -= 70
    elsif user.hp <= user.totalhp / 2
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserByThreeQuartersOfDamageDone",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.high) && target.hasActiveAbility?(:LIQUIDOOZE)
      score -= 80
    elsif user.hp <= user.totalhp / 2
      score += 40
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserAndAlliesQuarterOfTotalHP",
  proc { |score, move, user, target, skill, ai, battle|
    ally_amt = 30
    battle.allSameSideBattlers(user.index).each do |b|
      if b.hp == b.totalhp || (ai.skill_check(Battle::AI::AILevel.medium) && !b.canHeal?)
        score -= ally_amt / 2
      elsif b.hp < b.totalhp * 3 / 4
        score += ally_amt
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserAndAlliesQuarterOfTotalHPCureStatus",
  proc { |score, move, user, target, skill, ai, battle|
    ally_amt = 80 / battle.pbSideSize(user.index)
    battle.allSameSideBattlers(user.index).each do |b|
      if b.hp == b.totalhp || (ai.skill_check(Battle::AI::AILevel.medium) && !b.canHeal?)
        score -= ally_amt
      elsif b.hp < b.totalhp * 3 / 4
        score += ally_amt
      end
      score += ally_amt / 2 if b.pbHasAnyStatus?
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealTargetHalfOfTotalHP",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.opposes?(target)
    if target.hp < target.totalhp / 2 && target.effects[PBEffects::Substitute] == 0
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealTargetDependingOnGrassyTerrain",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.hp == user.totalhp || (ai.skill_check(Battle::AI::AILevel.medium) && !user.canHeal?)
    score += 50
    score -= user.hp * 100 / user.totalhp
    if ai.skill_check(Battle::AI::AILevel.medium)
      score += 30 if battle.field.terrain == :Grassy
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserPositionNextTurn",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if battle.positions[user.index].effects[PBEffects::Wish] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartHealUserEachTurn",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.effects[PBEffects::AquaRing]
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartHealUserEachTurnTrapUserInBattle",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.effects[PBEffects::Ingrain]
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartDamageTargetEachTurnIfTargetAsleep",
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::Nightmare] ||
       target.effects[PBEffects::Substitute] > 0
      score -= 90
    elsif !target.asleep?
      score -= 90
    else
      score -= 90 if target.statusCount <= 1
      score += 50 if target.statusCount > 3
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartLeechSeedTarget",
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::LeechSeed] >= 0
      score -= 90
    elsif ai.skill_check(Battle::AI::AILevel.medium) && target.pbHasType?(:GRASS)
      score -= 90
    elsif user.turnCount == 0
      score += 60
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserLosesHalfOfTotalHP",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.hp <= user.totalhp / 2
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserLosesHalfOfTotalHPExplosive",
  proc { |score, move, user, target, skill, ai, battle|
    reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
    foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
    if battle.pbCheckGlobalAbility(:DAMP)
      score -= 100
    elsif ai.skill_check(Battle::AI::AILevel.medium) && reserves == 0 && foes > 0
      score -= 100   # don't want to lose
    elsif ai.skill_check(Battle::AI::AILevel.high) && reserves == 0 && foes == 0
      score += 80   # want to draw
    else
      score -= (user.totalhp - user.hp) * 75 / user.totalhp
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserFaintsExplosive",
  proc { |score, move, user, target, skill, ai, battle|
    reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
    foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
    if battle.pbCheckGlobalAbility(:DAMP)
      score -= 100
    elsif ai.skill_check(Battle::AI::AILevel.medium) && reserves == 0 && foes > 0
      score -= 100   # don't want to lose
    elsif ai.skill_check(Battle::AI::AILevel.high) && reserves == 0 && foes == 0
      score += 80   # want to draw
    else
      score -= user.hp * 100 / user.totalhp
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserFaintsPowersUpInMistyTerrainExplosive",
  proc { |score, move, user, target, skill, ai, battle|
    reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
    foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
    if battle.pbCheckGlobalAbility(:DAMP)
      score -= 100
    elsif ai.skill_check(Battle::AI::AILevel.medium) && reserves == 0 && foes > 0
      score -= 100   # don't want to lose
    elsif ai.skill_check(Battle::AI::AILevel.high) && reserves == 0 && foes == 0
      score += 40   # want to draw
      score += 40 if battle.field.terrain == :Misty
    else
      score -= user.hp * 100 / user.totalhp
      score += 20 if battle.field.terrain == :Misty
    end
    next score
  }
)

# UserFaintsFixedDamageUserHP

Battle::AI::Handlers::MoveEffectScore.add("UserFaintsLowerTargetAtkSpAtk2",
  proc { |score, move, user, target, skill, ai, battle|
    if !target.pbCanLowerStatStage?(:ATTACK, user) &&
       !target.pbCanLowerStatStage?(:SPECIAL_ATTACK, user)
      score -= 100
    elsif battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
      score -= 100
    else
      score += target.stages[:ATTACK] * 10
      score += target.stages[:SPECIAL_ATTACK] * 10
      score -= user.hp * 100 / user.totalhp
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserFaintsHealAndCureReplacement",
  proc { |score, move, user, target, skill, ai, battle|
    next score - 70
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("UserFaintsHealAndCureReplacement",
                                           "UserFaintsHealAndCureReplacementRestorePP")

Battle::AI::Handlers::MoveEffectScore.add("StartPerishCountsForAllBattlers",
  proc { |score, move, user, target, skill, ai, battle|
    if battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
      score -= 90
    elsif target.effects[PBEffects::PerishSong] > 0
      score -= 90
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AttackerFaintsIfUserFaints",
  proc { |score, move, user, target, skill, ai, battle|
    score += 50
    score -= user.hp * 100 / user.totalhp
    score += 30 if user.hp <= user.totalhp / 10
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetAttackerMovePPTo0IfUserFaints",
  proc { |score, move, user, target, skill, ai, battle|
    score += 50
    score -= user.hp * 100 / user.totalhp
    score += 30 if user.hp <= user.totalhp / 10
    next score
  }
)
