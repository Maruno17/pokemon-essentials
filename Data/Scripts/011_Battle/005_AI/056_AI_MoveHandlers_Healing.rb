#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HealUserFullyAndFallAsleep",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.canHeal?
    next true if user.battler.asleep?
    next true if !user.battler.pbCanSleep?(user.battler, false, move.move, true)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserFullyAndFallAsleep",
  proc { |score, move, user, target, ai, battle|
    score += 70
    score -= user.hp * 140 / user.totalhp
    score += 30 if user.status != :NONE
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("HealUserHalfOfTotalHP",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.canHeal?
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserHalfOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    score += 50
    score -= user.hp * 100 / user.totalhp
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.copy("HealUserHalfOfTotalHP",
                                            "HealUserDependingOnWeather")
Battle::AI::Handlers::MoveEffectScore.add("HealUserDependingOnWeather",
  proc { |score, move, user, target, ai, battle|
    case user.battler.effectiveWeather
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

Battle::AI::Handlers::MoveFailureCheck.copy("HealUserHalfOfTotalHP",
                                            "HealUserDependingOnSandstorm")
Battle::AI::Handlers::MoveEffectScore.add("HealUserDependingOnSandstorm",
  proc { |score, move, user, target, ai, battle|
    score += 50
    score -= user.hp * 100 / user.totalhp
    score += 30 if user.battler.effectiveWeather == :Sandstorm
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.copy("HealUserHalfOfTotalHP",
                                            "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn")
Battle::AI::Handlers::MoveEffectScore.add("HealUserHalfOfTotalHPLoseFlyingTypeThisTurn",
  proc { |score, move, user, target, ai, battle|
    score += 50
    score -= user.hp * 100 / user.totalhp
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("CureTargetStatusHealUserHalfOfTotalHP",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.canHeal?
    next true if target.status == :NONE
  }
)
Battle::AI::Handlers::MoveEffectScore.add("CureTargetStatusHealUserHalfOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    score += (user.totalhp - user.hp) * 50 / user.totalhp
    score -= 30 if target.opposes?(user)
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("HealUserByTargetAttackLowerTargetAttack1",
  proc { |move, user, target, ai, battle|
    if target.has_active_ability?(:CONTRARY)
      next true if target.statStageAtMax?(:ATTACK)
    else
      next true if target.statStageAtMin?(:ATTACK)
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserByTargetAttackLowerTargetAttack1",
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanLowerStatStage?(:ATTACK, user.battler)
      score += target.stages[:ATTACK] * 20
      if ai.trainer.medium_skill?
        hasPhysicalAttack = false
        target.battler.eachMove do |m|
          next if !m.physicalMove?(m.type)
          hasPhysicalAttack = true
          break
        end
        if hasPhysicalAttack
          score += 20
        elsif ai.trainer.high_skill?
          score -= 90
        end
      end
    end
    score += (user.totalhp - user.hp) * 50 / user.totalhp
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserByHalfOfDamageDone",
  proc { |score, move, user, target, ai, battle|
    if target.has_active_ability?(:LIQUIDOOZE)
      score -= 70
    elsif user.hp <= user.totalhp / 2
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("HealUserByHalfOfDamageDoneIfTargetAsleep",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.asleep?
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserByHalfOfDamageDoneIfTargetAsleep",
  proc { |score, move, user, target, ai, battle|
    if target.has_active_ability?(:LIQUIDOOZE)
      score -= 70
    elsif user.hp <= user.totalhp / 2
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserByThreeQuartersOfDamageDone",
  proc { |score, move, user, target, ai, battle|
    if target.has_active_ability?(:LIQUIDOOZE)
      score -= 80
    elsif user.hp <= user.totalhp / 2
      score += 40
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("HealUserAndAlliesQuarterOfTotalHP",
  proc { |move, user, target, ai, battle|
    next true if battle.allSameSideBattlers(user.battler).none? { |b| b.canHeal? }
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserAndAlliesQuarterOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    ally_amt = 30
    battle.allSameSideBattlers(user.index).each do |b|
      if b.hp == b.totalhp || (ai.trainer.medium_skill? && !b.canHeal?)
        score -= ally_amt / 2
      elsif b.hp < b.totalhp * 3 / 4
        score += ally_amt
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("HealUserAndAlliesQuarterOfTotalHPCureStatus",
  proc { |move, user, target, ai, battle|
    next true if battle.allSameSideBattlers(user.battler).none? { |b| b.canHeal? || b.status != :NONE }
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserAndAlliesQuarterOfTotalHPCureStatus",
  proc { |score, move, user, target, ai, battle|
    ally_amt = 80 / battle.pbSideSize(user.index)
    battle.allSameSideBattlers(user.index).each do |b|
      if b.hp == b.totalhp || (ai.trainer.medium_skill? && !b.canHeal?)
        score -= ally_amt
      elsif b.hp < b.totalhp * 3 / 4
        score += ally_amt
      end
      score += ally_amt / 2 if b.pbHasAnyStatus?
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("HealTargetHalfOfTotalHP",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.canHeal?
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealTargetHalfOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.opposes?(target)
    if target.hp < target.totalhp / 2 && target.effects[PBEffects::Substitute] == 0
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.copy("HealTargetHalfOfTotalHP",
                                            "HealTargetDependingOnGrassyTerrain")
Battle::AI::Handlers::MoveEffectScore.add("HealTargetDependingOnGrassyTerrain",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.hp == user.totalhp ||
              (ai.trainer.medium_skill? && !user.battler.canHeal?)
    score += 50
    score -= user.hp * 100 / user.totalhp
    if ai.trainer.medium_skill?
      score += 30 if battle.field.terrain == :Grassy
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("HealUserPositionNextTurn",
  proc { |move, user, target, ai, battle|
    next true if battle.positions[user.index].effects[PBEffects::Wish] > 0
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("StartHealUserEachTurn",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::AquaRing]
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("StartHealUserEachTurnTrapUserInBattle",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::Ingrain]
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("StartDamageTargetEachTurnIfTargetAsleep",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.asleep? || target.effects[PBEffects::Nightmare]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartDamageTargetEachTurnIfTargetAsleep",
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::Substitute] > 0
      score -= 90
    else
      score -= 90 if target.statusCount <= 1
      score += 50 if target.statusCount > 3
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("StartLeechSeedTarget",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::LeechSeed] >= 0
    next true if target.has_type?(:GRASS)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartLeechSeedTarget",
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::LeechSeed] >= 0
      score -= 90
    elsif target.has_type?(:GRASS)
      score -= 90
    elsif user.turnCount == 0
      score += 60
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserLosesHalfOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.hp <= user.totalhp / 2
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("UserLosesHalfOfTotalHPExplosive",
  proc { |move, user, target, ai, battle|
    next true if battle.pbCheckGlobalAbility(:DAMP)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserLosesHalfOfTotalHPExplosive",
  proc { |score, move, user, target, ai, battle|
    reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
    foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
    if ai.trainer.medium_skill? && reserves == 0 && foes > 0
      score -= 60   # don't want to lose
    elsif ai.trainer.high_skill? && reserves == 0 && foes == 0
      score += 80   # want to draw
    else
      score -= (user.totalhp - user.hp) * 75 / user.totalhp
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.copy("UserLosesHalfOfTotalHPExplosive",
                                            "UserFaintsExplosive")
Battle::AI::Handlers::MoveEffectScore.add("UserFaintsExplosive",
  proc { |score, move, user, target, ai, battle|
    reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
    foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
    if ai.trainer.medium_skill? && reserves == 0 && foes > 0
      score -= 60   # don't want to lose
    elsif ai.trainer.high_skill? && reserves == 0 && foes == 0
      score += 80   # want to draw
    else
      score -= user.hp * 100 / user.totalhp
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.copy("UserLosesHalfOfTotalHPExplosive",
                                            "UserFaintsPowersUpInMistyTerrainExplosive")
Battle::AI::Handlers::MoveBasePower.add("UserFaintsPowersUpInMistyTerrainExplosive",
  proc { |power, move, user, target, ai, battle|
    next power * 3 / 2 if battle.field.terrain == :Misty
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserFaintsPowersUpInMistyTerrainExplosive",
  proc { |score, move, user, target, ai, battle|
    reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
    foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
    if ai.trainer.medium_skill? && reserves == 0 && foes > 0
      score -= 60   # don't want to lose
    elsif ai.trainer.high_skill? && reserves == 0 && foes == 0
      score += 40   # want to draw
    else
      score -= user.hp * 100 / user.totalhp
    end
    next score
  }
)

Battle::AI::Handlers::MoveBasePower.add("UserFaintsFixedDamageUserHP",
  proc { |power, move, user, target, ai, battle|
    next user.hp
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserFaintsLowerTargetAtkSpAtk2",
  proc { |score, move, user, target, ai, battle|
    if !target.battler.pbCanLowerStatStage?(:ATTACK, user.battler) &&
       !target.battler.pbCanLowerStatStage?(:SPECIAL_ATTACK, user.battler)
      score -= 60
    elsif battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
      score -= 60
    else
      score += target.stages[:ATTACK] * 10
      score += target.stages[:SPECIAL_ATTACK] * 10
      score -= user.hp * 100 / user.totalhp
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("UserFaintsHealAndCureReplacement",
  proc { |move, user, target, ai, battle|
    next true if !battle.pbCanChooseNonActive?(user.index)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserFaintsHealAndCureReplacement",
  proc { |score, move, user, target, ai, battle|
    next score - 70
  }
)

Battle::AI::Handlers::MoveFailureCheck.copy("UserFaintsHealAndCureReplacement",
                                            "UserFaintsHealAndCureReplacementRestorePP")
Battle::AI::Handlers::MoveEffectScore.copy("UserFaintsHealAndCureReplacement",
                                           "UserFaintsHealAndCureReplacementRestorePP")

Battle::AI::Handlers::MoveFailureCheck.add("StartPerishCountsForAllBattlers",
  proc { |move, user, target, ai, battle|
    next target.effects[PBEffects::PerishSong] > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartPerishCountsForAllBattlers",
  proc { |score, move, user, target, ai, battle|
    if battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
      score -= 60
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("AttackerFaintsIfUserFaints",
  proc { |move, user, target, ai, battle|
    next Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::DestinyBondPrevious]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AttackerFaintsIfUserFaints",
  proc { |score, move, user, target, ai, battle|
    score += 50
    score -= user.hp * 100 / user.totalhp
    score += 30 if user.hp <= user.totalhp / 10
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SetAttackerMovePPTo0IfUserFaints",
  proc { |score, move, user, target, ai, battle|
    score += 50
    score -= user.hp * 100 / user.totalhp
    score += 30 if user.hp <= user.totalhp / 10
    next score
  }
)
