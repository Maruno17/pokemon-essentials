#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HealUserFullyAndFallAsleep",
  proc { |move, user, ai, battle|
    next true if !user.battler.canHeal?
    next true if user.battler.asleep?
    next true if !user.battler.pbCanSleep?(user.battler, false, move.move, true)
    next false
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserFullyAndFallAsleep",
  proc { |score, move, user, ai, battle|
    # Consider how much HP will be restored
    if ai.trainer.has_skill_flag?("HPAware")
      if user.hp >= user.totalhp * 0.5
        score -= 10
      else
        score += 30 * (user.totalhp - user.hp) / user.totalhp   # +15 to +30
      end
    end
    # Check whether an existing status problem will be removed
    if user.status != :NONE
      score += (user.wants_status_problem?(user.status)) ? -10 : 8
    end
    # Check if user is happy to be asleep, e.g. can use moves while asleep
    if ai.trainer.medium_skill?
      score += (user.wants_status_problem?(:SLEEP)) ? 10 : -8
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HealUserHalfOfTotalHP",
  proc { |move, user, ai, battle|
    next !user.battler.canHeal?
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserHalfOfTotalHP",
  proc { |score, move, user, ai, battle|
    # Consider how much HP will be restored
    if ai.trainer.has_skill_flag?("HPAware")
      next score - 10 if user.hp >= user.totalhp * 0.5
      score += 30 * (user.totalhp - user.hp) / user.totalhp   # +15 to +30
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
    score = Battle::AI::Handlers.apply_move_effect_score("HealUserHalfOfTotalHP",
       score, move, user, ai, battle)
    case user.battler.effectiveWeather
    when :Sun, :HarshSun
      score += 5
    when :None, :StrongWinds
    else
      score -= 10
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
    score = Battle::AI::Handlers.apply_move_effect_score("HealUserHalfOfTotalHP",
       score, move, user, ai, battle)
    score += 5 if user.battler.effectiveWeather == :Sandstorm
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
    score = Battle::AI::Handlers.apply_move_effect_score("HealUserHalfOfTotalHP",
       score, move, user, ai, battle)
    # User loses the Flying type this round
    # NOTE: Not worth considering and scoring for.
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("CureTargetStatusHealUserHalfOfTotalHP",
  proc { |move, user, target, ai, battle|
    next !user.battler.canHeal? || target.status == :NONE
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("CureTargetStatusHealUserHalfOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    # Consider how much HP will be restored
    score = Battle::AI::Handlers.apply_move_effect_score("HealUserHalfOfTotalHP",
       score, move, user, ai, battle)
    # Will cure target's status
    score += (target.wants_status_problem?(target.status)) ? 10 : -8
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("HealUserByTargetAttackLowerTargetAttack1",
  proc { |move, user, target, ai, battle|
    if !battle.moldBreaker && target.has_active_ability?(:CONTRARY)
      next target.statStageAtMax?(:ATTACK)
    end
    next target.statStageAtMin?(:ATTACK)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealUserByTargetAttackLowerTargetAttack1",
  proc { |score, move, user, target, ai, battle|
    # Check whether lowering the target's Attack will have any impact
    if ai.trainer.medium_skill?
      score = ai.get_score_for_target_stat_drop(score, target, move.move.statDown)
    end
    # Healing the user
    if target.has_active_ability?(:LIQUIDOOZE)
      score -= 20
    elsif user.battler.canHeal?
      score += 5 if user.has_active_item?(:BIGROOT)
      if ai.trainer.has_skill_flag?("HPAware")
        # Consider how much HP will be restored
        heal_amt = target.rough_stat(:ATTACK)
        heal_amt *= 1.3 if user.has_active_item?(:BIGROOT)
        heal_amt = [heal_amt, user.totalhp - user.hp].min
        if heal_amt > user.totalhp * 0.3   # Only modify the score if it'll heal a decent amount
          if user.hp < user.totalhp * 0.5
            score += 20 * (user.totalhp - user.hp) / user.totalhp   # +10 to +20
          end
          score += 20 * heal_amt / user.totalhp   # +6 to +20
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealUserByHalfOfDamageDone",
  proc { |score, move, user, target, ai, battle|
    rough_dmg = move.rough_damage
    if target.has_active_ability?(:LIQUIDOOZE)
      score -= 20 if rough_dmg < target.hp
    elsif user.battler.canHeal?
      score += 5 if user.has_active_item?(:BIGROOT)
      if ai.trainer.has_skill_flag?("HPAware")
        # Consider how much HP will be restored
        heal_amt = rough_dmg / 2
        heal_amt *= 1.3 if user.has_active_item?(:BIGROOT)
        heal_amt = [heal_amt, user.totalhp - user.hp].min
        if heal_amt > user.totalhp * 0.3   # Only modify the score if it'll heal a decent amount
          if user.hp < user.totalhp * 0.5
            score += 20 * (user.totalhp - user.hp) / user.totalhp   # +10 to +20
          end
          score += 20 * heal_amt / user.totalhp   # +6 to +20
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("HealUserByHalfOfDamageDoneIfTargetAsleep",
  proc { |move, user, target, ai, battle|
    next !target.battler.asleep?
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("HealUserByHalfOfDamageDone",
                                                        "HealUserByHalfOfDamageDoneIfTargetAsleep")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealUserByThreeQuartersOfDamageDone",
  proc { |score, move, user, target, ai, battle|
    rough_dmg = move.rough_damage
    if target.has_active_ability?(:LIQUIDOOZE)
      score -= 20 if rough_dmg < target.hp
    elsif user.battler.canHeal?
      score += 5 if user.has_active_item?(:BIGROOT)
      if ai.trainer.has_skill_flag?("HPAware")
        # Consider how much HP will be restored
        heal_amt = rough_dmg * 0.75
        heal_amt *= 1.3 if user.has_active_item?(:BIGROOT)
        heal_amt = [heal_amt, user.totalhp - user.hp].min
        if heal_amt > user.totalhp * 0.3   # Only modify the score if it'll heal a decent amount
          if user.hp < user.totalhp * 0.5
            score += 20 * (user.totalhp - user.hp) / user.totalhp   # +10 to +20
          end
          score += 20 * heal_amt / user.totalhp   # +6 to +20
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("HealUserAndAlliesQuarterOfTotalHP",
  proc { |move, user, target, ai, battle|
    next !target.battler.canHeal?
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealUserAndAlliesQuarterOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    next score if !target.battler.canHeal?
    # Consider how much HP will be restored
    if ai.trainer.has_skill_flag?("HPAware")
      if target.hp >= target.totalhp * 0.75
        score -= 5
      else
        score += 15 * (target.totalhp - target.hp) / target.totalhp   # +3 to +15
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("HealUserAndAlliesQuarterOfTotalHPCureStatus",
  proc { |move, user, target, ai, battle|
    next !target.battler.canHeal? && target.status == :NONE
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealUserAndAlliesQuarterOfTotalHPCureStatus",
  proc { |score, move, user, target, ai, battle|
    # Consider how much HP will be restored
    score = Battle::AI::Handlers.apply_move_effect_score("HealUserAndAlliesQuarterOfTotalHP",
       score, move, user, ai, battle)
    # Check whether an existing status problem will be removed
    if target.status != :NONE
      score += (target.wants_status_problem?(target.status)) ? -10 : 10
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("HealTargetHalfOfTotalHP",
  proc { |move, user, target, ai, battle|
    next !target.battler.canHeal?
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HealTargetHalfOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.opposes?(user)
    # Consider how much HP will be restored
    if ai.trainer.has_skill_flag?("HPAware")
      if target.hp >= target.totalhp * 0.5
        score -= 10
      else
        heal_amt = target.totalhp * 0.5
        heal_amt = target.totalhp * 0.75 if move.move.pulseMove? &&
                                            user.has_active_ability?(:MEGALAUNCHER)
        heal_amt = [heal_amt, target.totalhp - target.hp].min
        score += 20 * (target.totalhp - target.hp) / target.totalhp   # +10 to +20
        score += 20 * heal_amt / target.totalhp   # +10 or +15
      end
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
    if ai.trainer.has_skill_flag?("HPAware")
      if target.hp >= target.totalhp * 0.5
        score -= 10
      else
        heal_amt = target.totalhp * 0.5
        heal_amt = (target.totalhp * 2 / 3.0).round if battle.field.terrain == :Grassy
        heal_amt = [heal_amt, target.totalhp - target.hp].min
        score += 20 * (target.totalhp - target.hp) / target.totalhp   # +10 to +20
        score += 20 * heal_amt / target.totalhp   # +10 or +13
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HealUserPositionNextTurn",
  proc { |move, user, ai, battle|
    next battle.positions[user.index].effects[PBEffects::Wish] > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserPositionNextTurn",
  proc { |score, move, user, ai, battle|
    # Consider how much HP will be restored
    if ai.trainer.has_skill_flag?("HPAware")
      if user.hp >= user.totalhp * 0.5
        score -= 10
      else
        score += 20 * (user.totalhp - user.hp) / user.totalhp   # +10 to +20
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartHealUserEachTurn",
  proc { |move, user, ai, battle|
    next user.effects[PBEffects::AquaRing]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartHealUserEachTurn",
  proc { |score, move, user, ai, battle|
    score += 15
    score += 5 if user.has_active_item?(:BIGROOT)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartHealUserEachTurnTrapUserInBattle",
  proc { |move, user, ai, battle|
    next user.effects[PBEffects::Ingrain]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartHealUserEachTurnTrapUserInBattle",
  proc { |score, move, user, ai, battle|
    score += 8
    score += 15 if user.turnCount < 2
    score += 5 if user.has_active_item?(:BIGROOT)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("StartDamageTargetEachTurnIfTargetAsleep",
  proc { |move, user, target, ai, battle|
    next !target.battler.asleep? || target.effects[PBEffects::Nightmare]
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("StartDamageTargetEachTurnIfTargetAsleep",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.statusCount <= 1
    next score + (8 * target.statusCount)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("StartLeechSeedTarget",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::LeechSeed] >= 0
    next true if target.has_type?(:GRASS) || !target.battler.takesIndirectDamage?
    next false
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("StartLeechSeedTarget",
  proc { |score, move, user, target, ai, battle|
    score += 15
    # Prefer early on
    score += 10 if user.turnCount < 2
    if ai.trainer.medium_skill?
      # Prefer if the user has no damaging moves
      score += 10 if !user.check_for_move { |m| m.damagingMove? }
      # Prefer if the target can't switch out to remove its seeding
      score += 8 if !battle.pbCanChooseNonActive?(target.index)
      # Don't prefer if the leeched HP will hurt the user
      score -= 20 if target.has_active_ability?([:LIQUIDOOZE])
    end
    if ai.trainer.high_skill?
      # Prefer if user can stall while damage is dealt
      if user.check_for_move { |m| m.is_a?(Battle::Move::ProtectMove) }
        score += 10
      end
      # Don't prefer if target can remove the seed
      if target.has_move_with_function?("RemoveUserBindingAndEntryHazards")
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
    if ai.trainer.has_skill_flag?("HPAware")
      score += 15 if user.hp >= user.totalhp * 0.75   # User has HP to spare
      score += 15 if user.hp <= user.totalhp * 0.25   # User is near fainting anyway; suicide
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
    next !battle.moldBreaker && battle.pbCheckGlobalAbility(:DAMP)
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
    score -= 20   # User will faint, don't prefer this move
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp >= user.totalhp * 0.5
      score += 20 if user.hp <= user.totalhp * 0.25   # User is near fainting anyway; suicide
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
    power = power * 3 / 2 if battle.field.terrain == :Misty
    next power
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
    score -= 20   # User will faint, don't prefer this move
    # Check the impact of lowering the target's stats
    score = ai.get_score_for_target_stat_drop(score, target, move.move.statDown)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for the user fainting
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp >= user.totalhp * 0.5
      score += 20 if user.hp <= user.totalhp * 0.25   # User is near fainting anyway; suicide
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
    next !battle.pbCanChooseNonActive?(user.index)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserFaintsHealAndCureReplacement",
  proc { |score, move, user, ai, battle|
    score -= 20   # User will faint, don't prefer this move
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
      score += 10
    end
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp >= user.totalhp * 0.5
      score += 20 if user.hp <= user.totalhp * 0.25   # User is near fainting anyway; suicide
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
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("StartPerishCountsForAllBattlers",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::PerishSong] > 0
    next false if !target.ability_active?
    next Battle::AbilityEffects.triggerMoveImmunity(target.ability, user.battler, target.battler,
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
      ai.each_battler do |b|
        next if Battle::AI::Handlers.move_will_fail_against_target?("StartPerishCountsForAllBattlers",
                                                                    move, user, b, ai, battle)
        if b.opposes?(user)
          foes_affected += 1
          foes_with_high_hp += 1 if b.hp >= b.totalhp * 0.75
        else
          allies_affected += 1
        end
      end
      next Battle::AI::MOVE_USELESS_SCORE if foes_affected == 0
      score += 15 if allies_affected == 0   # No downside for user; cancel out inherent negative score
      score -= 15 * allies_affected
      score += 20 * foes_affected
      score += 10 * foes_with_high_hp if ai.trainer.has_skill_flag?("HPAware")
    end
    if ai.trainer.high_skill?
      reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if foes == 0          # Foe is down to their last Pokémon, can't lose Perish count
        score += 25         # => Want to auto-win in 3 turns
      elsif reserves == 0   # AI is down to its last Pokémon, can't lose Perish count
        score -= 15         # => Don't want to auto-lose in 3 turns
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
    ai.each_foe_battler(user.side) do |b, i|
      user_faster_count += 1 if user.faster_than?(b)
    end
    next score if user_faster_count == 0   # Move will almost certainly have no effect
    score += 7 * user_faster_count
    # Prefer this move at lower user HP
    if ai.trainer.has_skill_flag?("HPAware")
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
    ai.each_foe_battler(user.side) do |b, i|
      user_faster_count += 1 if user.faster_than?(b)
    end
    next score if user_faster_count == 0   # Move will almost certainly have no effect
    score += 7 * user_faster_count
    # Prefer this move at lower user HP (not as preferred as Destiny Bond, though)
    if ai.trainer.has_skill_flag?("HPAware")
      score += 20 if user.hp <= user.totalhp * 0.4
      score += 10 if user.hp <= user.totalhp * 0.25
      score += 15 if user.hp <= user.totalhp * 0.1
    end
    next score
  }
)
