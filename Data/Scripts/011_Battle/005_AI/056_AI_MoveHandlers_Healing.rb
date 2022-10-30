#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HealUserFullyAndFallAsleep",
  proc { |move, user, ai, battle|
    next true if !user.battler.canHeal?
    next true if user.battler.asleep?
    next true if !user.battler.pbCanSleep?(user.battler, false, move.move, true)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserFullyAndFallAsleep",
  proc { |score, move, user, ai, battle|
    # Consider how much HP will be restored
    if user.hp >= user.totalhp * 0.5
      score -= 10
    else
      score += 20 * (user.totalhp - user.hp) / user.totalhp
    end
    # Check whether an existing status problem will be removed
    score += 10 if user.status != :NONE
    # Check if user will be able to act while asleep
    if ai.trainer.medium_skill?
      if user.check_for_move { |m| m.usableWhenAsleep? }
        score += 10
      else
        score -= 10
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HealUserHalfOfTotalHP",
  proc { |move, user, ai, battle|
    next true if !user.battler.canHeal?
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserHalfOfTotalHP",
  proc { |score, move, user, ai, battle|
    # Consider how much HP will be restored
    if user.hp >= user.totalhp * 0.5
      score -= 10
    else
      score += 20 * (user.totalhp - user.hp) / user.totalhp
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("HealUserHalfOfTotalHP",
                                            "HealUserDependingOnWeather")
Battle::AI::Handlers::MoveEffectScore.add("HealUserDependingOnWeather",
  proc { |score, move, user, ai, battle|
    # Consider how much HP will be restored
    if user.hp >= user.totalhp * 0.5
      score -= 10
    else
      case user.battler.effectiveWeather
      when :Sun, :HarshSun
        score += 5
      when :None, :StrongWinds
      else
        score -= 10
      end
      score += 20 * (user.totalhp - user.hp) / user.totalhp
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("HealUserHalfOfTotalHP",
                                            "HealUserDependingOnSandstorm")
Battle::AI::Handlers::MoveEffectScore.add("HealUserDependingOnSandstorm",
  proc { |score, move, user, ai, battle|
    # Consider how much HP will be restored
    if user.hp >= user.totalhp * 0.5
      score -= 10
    else
      score += 5 if user.battler.effectiveWeather == :Sandstorm
      score += 20 * (user.totalhp - user.hp) / user.totalhp
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("HealUserHalfOfTotalHP",
                                            "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn")
Battle::AI::Handlers::MoveEffectScore.add("HealUserHalfOfTotalHPLoseFlyingTypeThisTurn",
  proc { |score, move, user, ai, battle|
    # Consider how much HP will be restored
    if user.hp >= user.totalhp * 0.5
      score -= 10
    else
      score += 20 * (user.totalhp - user.hp) / user.totalhp
    end
    if user.has_type?(:FLYING)
      # TODO: Decide whether losing the Flying type is good or bad. Look at
      #       type effectiveness changes against the user, and for foes' Ground
      #       moves. Anything else?
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("CureTargetStatusHealUserHalfOfTotalHP",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.canHeal?
    next true if target.status == :NONE
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("CureTargetStatusHealUserHalfOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    # TODO: Add high level checks for whether the target wants to lose their
    #       status problem, and change the score accordingly.
    if target.opposes?(user)
      score -= 10
    else
      score += 15
    end
    # Consider how much HP will be restored
    if user.hp >= user.totalhp * 0.5
      score -= 10
    else
      score += 20 * (user.totalhp - user.hp) / user.totalhp
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("HealUserByTargetAttackLowerTargetAttack1",
  proc { |move, user, target, ai, battle|
    if !battle.moldBreaker && target.has_active_ability?(:CONTRARY)
      next true if target.statStageAtMax?(:ATTACK)
    else
      next true if target.statStageAtMin?(:ATTACK)
    end
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealUserByTargetAttackLowerTargetAttack1",
  proc { |score, move, user, target, ai, battle|
    # Check whether lowering the target's Attack will have any impact
    if ai.trainer.medium_skill?
      if target.battler.pbCanLowerStatStage?(:ATTACK, user.battler, move.move) &&
         target.check_for_move { |m| m.physicalMove?(m.type) }
        score += target.stages[:ATTACK] * 10
      end
    end
    # Consider how much HP will be restored
    heal_amt = target.rough_stat(:ATTACK)
    if heal_amt > user.totalhp * 0.3   # Only modify the score if it'll heal a decent amount
      # Things that affect healing caused by draining
      if target.has_active_ability?(:LIQUIDOOZE)
        score -= 20
      elsif user.battler.canHeal?
        if user.hp >= user.totalhp * 0.5
          score -= 10
        else
          heal_amt *= 1.3 if user.has_active_item?(:BIGROOT)
          heal_fraction = [user.totalhp - user.hp, heal_amt].min.to_f / user.totalhp
          score += 40 * heal_fraction * (user.totalhp - user.hp) / user.totalhp
        end
      end
    else
      score -= 10 if target.has_active_ability?(:LIQUIDOOZE)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealUserByHalfOfDamageDone",
  proc { |score, move, user, target, ai, battle|
    # Consider how much HP will be restored
    heal_amt = move.rough_damage / 2
    if heal_amt > user.totalhp * 0.3   # Only modify the score if it'll heal a decent amount
      # Things that affect healing caused by draining
      if target.has_active_ability?(:LIQUIDOOZE)
        score -= 20
      elsif user.battler.canHeal?
        heal_amt *= 1.3 if user.has_active_item?(:BIGROOT)
        heal_fraction = [user.totalhp - user.hp, heal_amt].min.to_f / user.totalhp
        score += 40 * heal_fraction * (user.totalhp - user.hp) / user.totalhp
      end
    else
      score -= 10 if target.has_active_ability?(:LIQUIDOOZE)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("HealUserByHalfOfDamageDoneIfTargetAsleep",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.asleep?
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("HealUserByHalfOfDamageDone",
                                                        "HealUserByHalfOfDamageDoneIfTargetAsleep")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealUserByThreeQuartersOfDamageDone",
  proc { |score, move, user, target, ai, battle|
    # Consider how much HP will be restored
    heal_amt = move.rough_damage * 0.75
    if heal_amt > user.totalhp * 0.3   # Only modify the score if it'll heal a decent amount
      # Things that affect healing caused by draining
      if target.has_active_ability?(:LIQUIDOOZE)
        score -= 20
      elsif user.battler.canHeal?
        heal_amt *= 1.3 if user.has_active_item?(:BIGROOT)
        heal_fraction = [user.totalhp - user.hp, heal_amt].min.to_f / user.totalhp
        score += 40 * heal_fraction * (user.totalhp - user.hp) / user.totalhp
      end
    else
      score -= 10 if target.has_active_ability?(:LIQUIDOOZE)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("HealUserAndAlliesQuarterOfTotalHP",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.canHeal?
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealUserAndAlliesQuarterOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    # Consider how much HP will be restored
    if target.hp >= target.totalhp * 0.75
      score -= 5
    else
      score += 15 * (target.totalhp - target.hp) / target.totalhp
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("HealUserAndAlliesQuarterOfTotalHPCureStatus",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.canHeal? && target.status == :NONE
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealUserAndAlliesQuarterOfTotalHPCureStatus",
  proc { |score, move, user, target, ai, battle|
    # Consider how much HP will be restored
    if target.hp >= target.totalhp * 0.75
      score -= 5
    else
      score += 15 * (target.totalhp - target.hp) / target.totalhp
    end
    # Check whether an existing status problem will be removed
    score += 10 if target.status != :NONE
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("HealTargetHalfOfTotalHP",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.canHeal?
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealTargetHalfOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.opposes?(user)
    # Consider how much HP will be restored
    heal_amt = target.totalhp / 2
    heal_amt = target.totalhp * 0.75 if move.move.pulseMove? &&
                                        user.has_active_ability?(:MEGALAUNCHER)
    if target.hp >= target.totalhp * 0.5
      score -= 10
    else
      heal_fraction = [target.totalhp - target.hp, heal_amt].min.to_f / target.totalhp
      score += 40 * heal_fraction * (target.totalhp - target.hp) / target.totalhp
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("HealTargetHalfOfTotalHP",
                                                         "HealTargetDependingOnGrassyTerrain")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealTargetDependingOnGrassyTerrain",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if user.opposes?(target)
    # Consider how much HP will be restored
    heal_amt = target.totalhp / 2
    heal_amt = (target.totalhp * 2 / 3.0).round if battle.field.terrain == :Grassy
    if target.hp >= target.totalhp * 0.5
      score -= 10
    else
      heal_fraction = [target.totalhp - target.hp, heal_amt].min.to_f / target.totalhp
      score += 40 * heal_fraction * (target.totalhp - target.hp) / target.totalhp
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HealUserPositionNextTurn",
  proc { |move, user, ai, battle|
    next true if battle.positions[user.index].effects[PBEffects::Wish] > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserPositionNextTurn",
  proc { |score, move, user, ai, battle|
    # Consider how much HP will be restored
    if user.hp >= user.totalhp * 0.5
      score -= 10
    else
      score += 15 * (user.totalhp - user.hp) / user.totalhp
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartHealUserEachTurn",
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::AquaRing]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartHealUserEachTurn",
  proc { |score, move, user, ai, battle|
    score += 10
    score += 10 if user.has_active_item?(:BIGROOT)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartHealUserEachTurnTrapUserInBattle",
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::Ingrain]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartHealUserEachTurnTrapUserInBattle",
  proc { |score, move, user, ai, battle|
    score += 5
    score += 10 if user.turnCount < 2
    score += 10 if user.has_active_item?(:BIGROOT)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("StartDamageTargetEachTurnIfTargetAsleep",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.asleep? || target.effects[PBEffects::Nightmare]
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("StartDamageTargetEachTurnIfTargetAsleep",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.statusCount <= 1
    next score + 10 * target.statusCount
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("StartLeechSeedTarget",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::LeechSeed] >= 0
    next true if target.has_type?(:GRASS)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("StartLeechSeedTarget",
  proc { |score, move, user, target, ai, battle|
    score += 10 if user.turnCount < 2
    if ai.trainer.medium_skill?
      if !user.check_for_move { |m| m.damagingMove? }
        score += 20
      end
      score -= 20 if target.has_active_ability?([:LIQUIDOOZE]) || !target.battler.takesIndirectDamage?
    end
    if ai.trainer.high_skill?
      if user.check_for_move { |m| m.is_a?(Battle::Move::ProtectMove) }
        score += 15
      end
      if target.check_for_move { |m| m.is_a?(Battle::Move::RemoveUserBindingAndEntryHazards) }
        score -= 15
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserLosesHalfOfTotalHP",
  proc { |score, move, user, ai, battle|
    score -= 15   # User will lose 50% HP, don't prefer this move
    if ai.trainer.medium_skill?
      score += 10 if user.hp >= user.totalhp * 0.75   # User at 75% HP or more
      score += 10 if user.hp <= user.totalhp * 0.25   # User at 25% HP or less
    end
    if ai.trainer.high_skill?
      reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if reserves == 0   # AI is down to its last Pokémon
        score += 30      # => Go out with a bang
      elsif foes == 0    # Foe is down to their last Pokémon, AI has reserves
        score += 20      # => Go for the kill
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserLosesHalfOfTotalHPExplosive",
  proc { |move, user, ai, battle|
    next true if !battle.moldBreaker && battle.pbCheckGlobalAbility(:DAMP)
  }
)
Battle::AI::Handlers::MoveEffectScore.copy("UserLosesHalfOfTotalHP",
                                           "UserLosesHalfOfTotalHPExplosive")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("UserLosesHalfOfTotalHPExplosive",
                                            "UserFaintsExplosive")
Battle::AI::Handlers::MoveEffectScore.add("UserFaintsExplosive",
  proc { |score, move, user, ai, battle|
    score -= 25   # User will faint, don't prefer this move
    if ai.trainer.medium_skill?
      score -= 10 if user.hp >= user.totalhp * 0.5    # User at 50% HP or more
      score += 10 if user.hp <= user.totalhp * 0.25   # User at 25% HP or less
    end
    if ai.trainer.high_skill?
      reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if reserves == 0   # AI is down to its last Pokémon
        score += 30      # => Go out with a bang
      elsif foes == 0    # Foe is down to their last Pokémon, AI has reserves
        score += 20      # => Go for the kill
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("UserFaintsExplosive",
                                            "UserFaintsPowersUpInMistyTerrainExplosive")
Battle::AI::Handlers::MoveBasePower.add("UserFaintsPowersUpInMistyTerrainExplosive",
  proc { |power, move, user, target, ai, battle|
    next power * 3 / 2 if battle.field.terrain == :Misty
  }
)
Battle::AI::Handlers::MoveEffectScore.copy("UserFaintsExplosive",
                                           "UserFaintsPowersUpInMistyTerrainExplosive")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("UserFaintsFixedDamageUserHP",
  proc { |power, move, user, target, ai, battle|
    next user.hp
  }
)
Battle::AI::Handlers::MoveEffectScore.copy("UserFaintsExplosive",
                                           "UserFaintsFixedDamageUserHP")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserFaintsLowerTargetAtkSpAtk2",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if !target.battler.pbCanLowerStatStage?(:ATTACK, user.battler) &&
                                           !target.battler.pbCanLowerStatStage?(:SPECIAL_ATTACK, user.battler)
    score -= 25   # User will faint, don't prefer this move
    # Check the impact of lowering the target's stats
    if target.stages[:ATTACK] < 0 && target.stages[:SPECIAL_ATTACK] < 0
      score -= 20
    elsif target.stages[:ATTACK] > 0 || target.stages[:SPECIAL_ATTACK] > 0
      score += 10
    end
    if ai.trainer.medium_skill?
      score -= 10 if user.hp >= user.totalhp * 0.5    # User at 50% HP or more
      score += 10 if user.hp <= user.totalhp * 0.25   # User at 25% HP or less
    end
    if ai.trainer.high_skill?
      reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if reserves > 0 && foes == 0    # Foe is down to their last Pokémon, AI has reserves
        score += 20                   # => Can afford to lose this Pokémon
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserFaintsHealAndCureReplacement",
  proc { |move, user, ai, battle|
    next true if !battle.pbCanChooseNonActive?(user.index)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserFaintsHealAndCureReplacement",
  proc { |score, move, user, ai, battle|
    score -= 25   # User will faint, don't prefer this move
    # Check whether the replacement user needs healing, and don't make the below
    # calculations if not
    if ai.trainer.medium_skill?
      need_healing = false
      battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, party_index|
        next if pkmn.hp >= pkmn.totalhp * 0.75 && pkmn.status == :NONE
        need_healing = true
        break
      end
      next Battle::AI::MOVE_USELESS_SCORE if !need_healing
    end
    if ai.trainer.medium_skill?
      score -= 10 if user.hp >= user.totalhp * 0.5    # User at 50% HP or more
      score += 10 if user.hp <= user.totalhp * 0.25   # User at 25% HP or less
    end
    if ai.trainer.high_skill?
      reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if reserves > 0 && foes == 0    # Foe is down to their last Pokémon, AI has reserves
        score += 20                   # => Can afford to lose this Pokémon
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("UserFaintsHealAndCureReplacement",
                                            "UserFaintsHealAndCureReplacementRestorePP")
Battle::AI::Handlers::MoveEffectScore.copy("UserFaintsHealAndCureReplacement",
                                           "UserFaintsHealAndCureReplacementRestorePP")

#===============================================================================
# TODO: This code should be for a single battler (each is checked in turn).
#       Should have a MoveEffectAgainstTargetScore instead.
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("StartPerishCountsForAllBattlers",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::PerishSong] > 0
    next true if Battle::AbilityEffects.triggerMoveImmunity(target.ability, user.battler, target.battler,
                                                            move.move, move.rough_type, battle, false)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartPerishCountsForAllBattlers",
  proc { |score, move, user, ai, battle|
    score -= 15
    # Check which battlers will be affected by this move
    if ai.trainer.medium_skill?
      allies_affected = 0
      foes_affected = 0
      foes_with_high_hp = 0
      battle.allBattlers.each do |b|
        next if b.effects[PBEffects::PerishSong] > 0
        next if Battle::AbilityEffects.triggerMoveImmunity(b.ability, user.battler, b,
                                                           move.move, move.rough_type, battle, false)
        if b.opposes?(user.index)
          foes_affected += 1
          foes_with_high_hp += 1 if b.hp >= b.totalhp * 0.75
        else
          allies_affected += 1
        end
      end
      next Battle::AI::MOVE_USELESS_SCORE if foes_affected == 0
      score += 15 if allies_affected == 0   # No downside for user; cancel out inherent negative score
      score += 15 * (foes_affected - allies_affected)
      score += 5 * foes_with_high_hp
    end
    if ai.trainer.high_skill?
      reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if foes == 0          # Foe is down to their last Pokémon, can't lose Perish count
        score += 30         # => Want to auto-win in 3 turns
      elsif reserves == 0   # AI is down to its last Pokémon, can't lose Perish count
        score -= 20         # => Don't want to auto-lose in 3 turns
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AttackerFaintsIfUserFaints",
  proc { |move, user, ai, battle|
    next Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::DestinyBondPrevious]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AttackerFaintsIfUserFaints",
  proc { |score, move, user, ai, battle|
    score -= 25
    # Check whether user is faster than its foe(s) and could use this move
    user_faster_count = 0
    ai.battlers.each_with_index do |b, i|
      next if !user.opposes?(b) || b.battler.fainted?
      user_faster_count += 1 if user.faster_than?(b)
    end
    next score if user_faster_count == 0   # Move will almost certainly have no effect
    score += 5 * user_faster_count
    # Prefer this move at lower user HP
    if ai.trainer.medium_skill?
      score += 20 if user.hp <= user.totalhp * 0.4
      score += 10 if user.hp <= user.totalhp * 0.25
      score += 15 if user.hp <= user.totalhp * 0.1
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("SetAttackerMovePPTo0IfUserFaints",
  proc { |score, move, user, ai, battle|
    score -= 25
    # Check whether user is faster than its foe(s) and could use this move
    user_faster_count = 0
    ai.battlers.each_with_index do |b, i|
      next if !user.opposes?(b) || b.battler.fainted?
      user_faster_count += 1 if user.faster_than?(b)
    end
    next score if user_faster_count == 0   # Move will almost certainly have no effect
    score += 5 * user_faster_count
    # Prefer this move at lower user HP (not as preferred as Destiny Bond, though)
    if ai.trainer.medium_skill?
      score += 15 if user.hp <= user.totalhp * 0.4
      score += 10 if user.hp <= user.totalhp * 0.25
      score += 10 if user.hp <= user.totalhp * 0.1
    end
    next score
  }
)
