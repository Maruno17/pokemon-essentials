#===============================================================================
# TODO: This code can be called with a single target and with no targets. Make
#       sure it doesn't assume that there is a target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseUserAttack1",
  proc { |move, user, ai, battle|
    next move.statusMove? &&
         !user.battler.pbCanRaiseStatStage?(move.move.statUp[0], user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAttack1",
  proc { |score, move, user, ai, battle|
    next ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAttack1",
                                            "RaiseUserAttack2")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAttack1",
                                           "RaiseUserAttack2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaiseUserAttack2IfTargetFaints",
  proc { |score, move, user, target, ai, battle|
    if move.rough_damage >= target.hp * 0.9
      next ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAttack2",
                                            "RaiseUserAttack3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAttack2",
                                           "RaiseUserAttack3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("RaiseUserAttack2IfTargetFaints",
                                                        "RaiseUserAttack3IfTargetFaints")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("MaxUserAttackLoseHalfOfTotalHP",
  proc { |move, user, ai, battle|
    next true if user.hp <= [user.totalhp / 2, 1].max
    next !user.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("MaxUserAttackLoseHalfOfTotalHP",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    # Don't prefer the lower the user's HP is
    score -= 80 * (1 - (user.hp.to_f / user.totalhp))   # 0 to -40
    next score
  }
)

#===============================================================================
# TODO: This code can be called with a single target and with no targets. Make
#       sure it doesn't assume that there is a target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAttack1",
                                            "RaiseUserDefense1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAttack1",
                                           "RaiseUserDefense1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserDefense1",
                                            "RaiseUserDefense1CurlUpUser")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserDefense1CurlUpUser",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    if !user.effects[PBEffects::DefenseCurl] &&
       user.has_move_with_function?("MultiTurnAttackPowersUpEachTurn")
      score += 10
    end
    next score
  }
)

#===============================================================================
# TODO: This code can be called with multiple targets and with no targets. Make
#       sure it doesn't assume that there is a target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserDefense1",
                                            "RaiseUserDefense2")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserDefense1",
                                           "RaiseUserDefense2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserDefense1",
                                            "RaiseUserDefense3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserDefense1",
                                           "RaiseUserDefense3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAttack1",
                                            "RaiseUserSpAtk1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAttack1",
                                           "RaiseUserSpAtk1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpAtk1",
                                            "RaiseUserSpAtk2")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpAtk1",
                                           "RaiseUserSpAtk2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpAtk1",
                                            "RaiseUserSpAtk3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpAtk1",
                                           "RaiseUserSpAtk3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserDefense1",
                                            "RaiseUserSpDef1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserDefense1",
                                           "RaiseUserSpDef1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpDef1",
                                            "RaiseUserSpDef1PowerUpElectricMove")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpDef1PowerUpElectricMove",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    if user.has_damaging_move_of_type?(:ELECTRIC)
      score += 10
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpDef1",
                                            "RaiseUserSpDef2")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpDef1",
                                           "RaiseUserSpDef2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpDef1",
                                            "RaiseUserSpDef3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpDef1",
                                           "RaiseUserSpDef3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpDef1",
                                            "RaiseUserSpeed1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpDef1",
                                           "RaiseUserSpeed1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpeed1",
                                            "RaiseUserSpeed2")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpeed1",
                                           "RaiseUserSpeed2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpeed2",
                                            "RaiseUserSpeed2LowerUserWeight")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpeed2LowerUserWeight",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    if ai.trainer.medium_skill?
      # TODO: Take into account weight-modifying items/abilities? This "> 1"
      #       line can probably ignore them, but these moves' powers will change
      #       because of those modifiers, and the score changes may need to be
      #       different accordingly.
      if user.battler.pokemon.weight - user.effects[PBEffects::WeightChange] > 1
        if user.has_move_with_function?("PowerHigherWithUserHeavierThanTarget")
          score -= 10
        end
        ai.each_foe_battler(user.side) do |b, i|
          if b.has_move_with_function?("PowerHigherWithUserHeavierThanTarget")
            score -= 10
          end
          if b.has_move_with_function?("PowerHigherWithTargetWeight")
            score += 10
          end
          # TODO: Check foes for Sky Drop and whether the user is too heavy for it
          #       but the weight reduction will make it susceptible.
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpeed1",
                                            "RaiseUserSpeed3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpeed1",
                                           "RaiseUserSpeed3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpeed1",
                                            "RaiseUserAccuracy1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpeed1",
                                           "RaiseUserAccuracy1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAccuracy1",
                                            "RaiseUserAccuracy2")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAccuracy1",
                                           "RaiseUserAccuracy2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAccuracy1",
                                            "RaiseUserAccuracy3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAccuracy1",
                                           "RaiseUserAccuracy3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAccuracy1",
                                            "RaiseUserEvasion1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAccuracy1",
                                           "RaiseUserEvasion1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserEvasion1",
                                            "RaiseUserEvasion2")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserEvasion1",
                                           "RaiseUserEvasion2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserEvasion2",
                                            "RaiseUserEvasion2MinimizeUser")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserEvasion2MinimizeUser",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    if ai.trainer.medium_skill? && !user.effects[PBEffects::Minimize]
      ai.each_foe_battler(user.side) do |b, i|
        # Moves that do double damage and (in Gen 6+) have perfect accuracy
        if b.check_for_move { |m| m.tramplesMinimize? }
          score -= (Settings::MECHANICS_GENERATION >= 6) ? 15 : 10
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserEvasion2",
                                            "RaiseUserEvasion3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserEvasion2",
                                           "RaiseUserEvasion3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseUserCriticalHitRate2",
  proc { |move, user, ai, battle|
    next user.effects[PBEffects::FocusEnergy] >= 2
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserCriticalHitRate2",
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if !user.check_for_move { |m| m.damagingMove? }
    score += 15
    if ai.trainer.medium_skill?
      # Other effects that raise the critical hit rate
      if user.item_active?
        if [:RAZORCLAW, :SCOPELENS].include?(user.item_id) ||
           (user.item_id == :LUCKYPUNCH && user.battler.isSpecies?(:CHANSEY)) ||
           ([:LEEK, :STICK].include?(user.item_id) &&
           (user.battler.isSpecies?(:FARFETCHD) || user.battler.isSpecies?(:SIRFETCHD)))
          score += 10
        end
      end
      # Critical hits do more damage
      score += 10 if user.has_active_ability?(:SNIPER)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseUserAtkDef1",
  proc { |move, user, ai, battle|
    next false if move.damagingMove?
    will_fail = true
    (move.move.statUp.length / 2).times do |i|
      next if !user.battler.pbCanRaiseStatStage?(move.move.statUp[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAttack1",
                                           "RaiseUserAtkDef1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkDef1",
                                            "RaiseUserAtkDefAcc1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAtkDef1",
                                           "RaiseUserAtkDefAcc1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkDef1",
                                            "RaiseUserAtkSpAtk1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAtkDef1",
                                           "RaiseUserAtkSpAtk1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserAtkSpAtk1Or2InSun")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkSpAtk1Or2InSun",
  proc { |score, move, user, ai, battle|
    raises = move.move.statUp.clone
    if [:Sun, :HarshSun].include?(user.battler.effectiveWeather)
      raises[1] = 2
      raises[3] = 2
    end
    next ai.get_score_for_target_stat_raise(score, user, raises)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2",
  proc { |move, user, ai, battle|
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
Battle::AI::Handlers::MoveEffectScore.add("LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    next ai.get_score_for_target_stat_drop(score, user, move.move.statDown, false)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserAtkSpd1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAtkSpAtk1",
                                           "RaiseUserAtkSpd1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserAtk1Spd2")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAtkSpAtk1",
                                           "RaiseUserAtk1Spd2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserAtkAcc1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAtkSpAtk1",
                                           "RaiseUserAtkAcc1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserDefSpDef1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAtkSpAtk1",
                                           "RaiseUserDefSpDef1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserSpAtkSpDef1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAtkSpAtk1",
                                           "RaiseUserSpAtkSpDef1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserSpAtkSpDefSpd1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAtkSpAtk1",
                                           "RaiseUserSpAtkSpDefSpd1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserMainStats1")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAtkSpAtk1",
                                           "RaiseUserMainStats1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseUserMainStats1LoseThirdOfTotalHP",
  proc { |move, user, ai, battle|
    next true if user.hp <= [user.totalhp / 3, 1].max
    will_fail = true
    (move.move.statUp.length / 2).times do |i|
      next if !user.battler.pbCanRaiseStatStage?(move.move.statUp[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserMainStats1LoseThirdOfTotalHP",
  proc { |score, move, user, ai, battle|
    # Score for stat increase
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    # Score for losing HP
    if user.hp <= user.totalhp * 0.75
      score -= 30 * (user.totalhp - user.hp) / user.totalhp
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseUserMainStats1TrapUserInBattle",
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::NoRetreat]
    will_fail = true
    (move.move.statUp.length / 2).times do |i|
      next if !user.battler.pbCanRaiseStatStage?(move.move.statUp[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserMainStats1TrapUserInBattle",
  proc { |score, move, user, ai, battle|
    # Score for stat increase
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    # Score for trapping user in battle
    if ai.trainer.medium_skill? && !user.battler.trappedInBattle?
      score -= 10 if user.hp <= user.totalhp / 2
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("StartRaiseUserAtk1WhenDamaged",
  proc { |score, move, user, ai, battle|
    # Ignore the stat-raising effect if user is at a low HP and likely won't
    # benefit from it
    next score if user.hp < user.totalhp / 3
    # TODO: Check whether any foe has damaging moves that will trigger the stat
    #       raise?
    # Prefer if user benefits from a raised Attack stat
    if user.check_for_move { |m| m.physicalMove?(m.type) &&
                                 m.function != "UseUserDefenseInsteadOfUserAttack" &&
                                 m.function != "UseTargetAttackInsteadOfUserAttack" }
      score += 8
    elsif user.has_move_with_function?("PowerHigherWithUserPositiveStatStages")
      score += 4
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("LowerUserAttack1",
  proc { |score, move, user, ai, battle|
    next ai.get_score_for_target_stat_drop(score, user, move.move.statDown)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserAttack1",
                                           "LowerUserAttack2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserAttack1",
                                           "LowerUserDefense1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserDefense1",
                                           "LowerUserDefense2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserAttack1",
                                           "LowerUserSpAtk1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserSpAtk1",
                                           "LowerUserSpAtk2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserDefense1",
                                           "LowerUserSpDef1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserSpDef1",
                                           "LowerUserSpDef2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserAttack1",
                                           "LowerUserSpeed1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserSpeed1",
                                           "LowerUserSpeed2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserAttack1",
                                           "LowerUserAtkDef1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserAttack1",
                                           "LowerUserDefSpDef1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserAttack1",
                                           "LowerUserDefSpDefSpd1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("RaiseTargetAttack1",
  proc { |move, user, target, ai, battle|
    next move.statusMove? &&
         !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaiseTargetAttack1",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 1])
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("RaiseTargetAttack2ConfuseTarget",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
         !target.battler.pbCanConfuse?(user.battler, false, move.move)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaiseTargetAttack2ConfuseTarget",
  proc { |score, move, user, target, ai, battle|
    if !target.has_active_ability?(:CONTRARY) || @battle.moldBreaker
      next Battle::AI::MOVE_USELESS_SCORE if !target.battler.pbCanConfuse?(user.battler, false, move.move)
    end
    # Score for stat raise
    score = ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 2], false)
    # Score for confusing the target
    next Battle::AI::Handlers.apply_move_effect_against_target_score(
       "ConfuseTarget", score, move, user, target, ai, battle)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("RaiseTargetSpAtk1ConfuseTarget",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move) &&
         !target.battler.pbCanConfuse?(user.battler, false, move.move)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaiseTargetSpAtk1ConfuseTarget",
  proc { |score, move, user, target, ai, battle|
    if !target.has_active_ability?(:CONTRARY) || @battle.moldBreaker
      next Battle::AI::MOVE_USELESS_SCORE if !target.battler.pbCanConfuse?(user.battler, false, move.move)
    end
    # Score for stat raise
    score = ai.get_score_for_target_stat_raise(score, target, [:SPECIAL_ATTACK, 1], false)
    # Score for confusing the target
    next Battle::AI::Handlers.apply_move_effect_against_target_score(
       "ConfuseTarget", score, move, user, target, ai, battle)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("RaiseTargetSpDef1",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaiseTargetSpDef1",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:SPECIAL_DEFENSE, 1])
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("RaiseTargetRandomStat2",
  proc { |move, user, target, ai, battle|
    will_fail = true
    GameData::Stat.each_battle do |s|
      next if !target.battler.pbCanRaiseStatStage?(s.id, user.battler, move.move)
      will_fail = false
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaiseTargetRandomStat2",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if !battle.moldBreaker && target.has_active_ability?(:CONTRARY)
    next Battle::AI::MOVE_USELESS_SCORE if target.rough_end_of_round_damage >= target.hp
    score -= 5 if target.index != user.index   # Less likely to use on ally
    score += 5 if target.has_active_ability?(:SIMPLE)
    # Prefer if target is at high HP, don't prefer if target is at low HP
    if target.hp >= target.totalhp * 0.7
      score += 8
    else
      score += ((100 * target.hp / target.totalhp) - 50) / 4   # +5 to -12
    end
    # Prefer if target has Stored Power
    if target.has_move_with_function?("PowerHigherWithUserPositiveStatStages")
      score += 8
    end
    # Don't prefer if any foe has Punishment
    ai.each_foe_battler(target.side) do |b, i|
      next if !b.has_move_with_function?("PowerHigherWithTargetPositiveStatStages")
      score -= 5
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("RaiseTargetAtkSpAtk2",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
         !target.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaiseTargetAtkSpAtk2",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.opposes?(user)
    next ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 2, :SPECIAL_ATTACK, 2])
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("LowerTargetAttack1",
  proc { |move, user, target, ai, battle|
    next move.statusMove? &&
         !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("LowerTargetAttack1",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_drop(score, target, move.move.statDown)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetAttack1",
                                                         "LowerTargetAttack1BypassSubstitute")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetAttack1",
                                                        "LowerTargetAttack1BypassSubstitute")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetAttack1",
                                                         "LowerTargetAttack2")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetAttack1",
                                                        "LowerTargetAttack2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetAttack2",
                                                         "LowerTargetAttack3")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetAttack2",
                                                        "LowerTargetAttack3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetAttack1",
                                                         "LowerTargetDefense1")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetAttack1",
                                                        "LowerTargetDefense1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetDefense1",
                                                         "LowerTargetDefense1PowersUpInGravity")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetDefense1",
                                                        "LowerTargetDefense1PowersUpInGravity")
Battle::AI::Handlers::MoveBasePower.add("LowerTargetDefense1PowersUpInGravity",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetDefense1",
                                                         "LowerTargetDefense2")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetDefense1",
                                                        "LowerTargetDefense2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetDefense2",
                                                         "LowerTargetDefense3")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetDefense2",
                                                        "LowerTargetDefense3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetAttack1",
                                                         "LowerTargetSpAtk1")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetAttack1",
                                                        "LowerTargetSpAtk1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetSpAtk1",
                                                         "LowerTargetSpAtk2")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetSpAtk1",
                                                        "LowerTargetSpAtk2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("LowerTargetSpAtk2IfCanAttract",
  proc { |move, user, target, ai, battle|
    next true if move.statusMove? &&
                 !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
    next true if user.gender == 2 || target.gender == 2 || user.gender == target.gender
    next true if !battle.moldBreaker && target.has_active_ability?(:OBLIVIOUS)
    next false
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetSpAtk2",
                                                        "LowerTargetSpAtk2IfCanAttract")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetSpAtk2",
                                                         "LowerTargetSpAtk3")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetSpAtk2",
                                                        "LowerTargetSpAtk3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetDefense1",
                                                         "LowerTargetSpDef1")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetDefense1",
                                                        "LowerTargetSpDef1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetSpDef1",
                                                         "LowerTargetSpDef2")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetSpDef1",
                                                        "LowerTargetSpDef2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetSpDef2",
                                                         "LowerTargetSpDef3")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetSpDef2",
                                                        "LowerTargetSpDef3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetSpDef1",
                                                         "LowerTargetSpeed1")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetSpDef1",
                                                        "LowerTargetSpeed1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetSpeed1",
                                                         "LowerTargetSpeed1WeakerInGrassyTerrain")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetSpeed1",
                                                        "LowerTargetSpeed1WeakerInGrassyTerrain")
Battle::AI::Handlers::MoveBasePower.add("LowerTargetSpeed1WeakerInGrassyTerrain",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("LowerTargetSpeed1MakeTargetWeakerToFire",
  proc { |move, user, target, ai, battle|
    next false if !target.effects[PBEffects::TarShot]
    next move.statusMove? &&
         !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("LowerTargetSpeed1MakeTargetWeakerToFire",
  proc { |score, move, user, target, ai, battle|
    # Score for stat drop
    score = ai.get_score_for_target_stat_drop(score, target, move.move.statDown)
    # Score for adding weakness to Fire
    if !target.effects[PBEffects::TarShot]
      eff = target.effectiveness_of_type_against_battler(:FIRE)
      if !Effectiveness.ineffective?(eff)
        score += 8 * eff if user.has_damaging_move_of_type?(:FIRE)
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetSpeed1",
                                                         "LowerTargetSpeed2")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetSpeed1",
                                                        "LowerTargetSpeed2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetSpeed2",
                                                         "LowerTargetSpeed3")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetSpeed2",
                                                        "LowerTargetSpeed3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetSpeed1",
                                                         "LowerTargetAccuracy1")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetSpeed1",
                                                        "LowerTargetAccuracy1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetAccuracy1",
                                                         "LowerTargetAccuracy2")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetAccuracy1",
                                                        "LowerTargetAccuracy2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetAccuracy2",
                                                         "LowerTargetAccuracy3")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetAccuracy2",
                                                        "LowerTargetAccuracy3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetAccuracy1",
                                                         "LowerTargetEvasion1")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetAccuracy1",
                                                        "LowerTargetEvasion1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("LowerTargetEvasion1RemoveSideEffects",
  proc { |move, user, target, ai, battle|
    target_side = target.pbOwnSide
    target_opposing_side = target.pbOpposingSide
    next false if target_side.effects[PBEffects::AuroraVeil] > 0 ||
                  target_side.effects[PBEffects::LightScreen] > 0 ||
                  target_side.effects[PBEffects::Reflect] > 0 ||
                  target_side.effects[PBEffects::Mist] > 0 ||
                  target_side.effects[PBEffects::Safeguard] > 0
    next false if target_side.effects[PBEffects::StealthRock] ||
                  target_side.effects[PBEffects::Spikes] > 0 ||
                  target_side.effects[PBEffects::ToxicSpikes] > 0 ||
                  target_side.effects[PBEffects::StickyWeb]
    next false if Settings::MECHANICS_GENERATION >= 6 &&
                  (target_opposing_side.effects[PBEffects::StealthRock] ||
                  target_opposing_side.effects[PBEffects::Spikes] > 0 ||
                  target_opposing_side.effects[PBEffects::ToxicSpikes] > 0 ||
                  target_opposing_side.effects[PBEffects::StickyWeb])
    next false if Settings::MECHANICS_GENERATION >= 8 && battle.field.terrain != :None
    next move.statusMove? &&
         !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("LowerTargetEvasion1RemoveSideEffects",
  proc { |score, move, user, target, ai, battle|
    # Score for stat drop
    score = ai.get_score_for_target_stat_drop(score, target, move.move.statDown)
    # Score for removing side effects/terrain
    score += 8 if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 1 ||
                  target.pbOwnSide.effects[PBEffects::Reflect] > 1 ||
                  target.pbOwnSide.effects[PBEffects::LightScreen] > 1 ||
                  target.pbOwnSide.effects[PBEffects::Mist] > 1 ||
                  target.pbOwnSide.effects[PBEffects::Safeguard] > 1
    if target.can_switch_lax?
      score -= 10 if target.pbOwnSide.effects[PBEffects::Spikes] > 0 ||
                     target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0 ||
                     target.pbOwnSide.effects[PBEffects::StealthRock] ||
                     target.pbOwnSide.effects[PBEffects::StickyWeb]
    end
    if user.opposes?(target) && user.can_switch_lax? && Settings::MECHANICS_GENERATION >= 6
      score += 10 if target.pbOpposingSide.effects[PBEffects::Spikes] > 0 ||
                     target.pbOpposingSide.effects[PBEffects::ToxicSpikes] > 0 ||
                     target.pbOpposingSide.effects[PBEffects::StealthRock] ||
                     target.pbOpposingSide.effects[PBEffects::StickyWeb]
    end
    if Settings::MECHANICS_GENERATION >= 8 && battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetEvasion1",
                                                         "LowerTargetEvasion2")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetEvasion1",
                                                        "LowerTargetEvasion2")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetEvasion2",
                                                         "LowerTargetEvasion3")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetEvasion2",
                                                        "LowerTargetEvasion3")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("LowerTargetAtkDef1",
  proc { |move, user, target, ai, battle|
    next false if !move.statusMove?
    will_fail = true
    (move.move.statDown.length / 2).times do |i|
      next if !target.battler.pbCanLowerStatStage?(move.move.statDown[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetAttack1",
                                                        "LowerTargetAtkDef1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("LowerTargetAtkDef1",
                                                         "LowerTargetAtkSpAtk1")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetAtkDef1",
                                                        "LowerTargetAtkSpAtk1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("LowerPoisonedTargetAtkSpAtkSpd1",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.poisoned?
    next Battle::AI::Handlers.move_will_fail_against_target?("LowerTargetAtkSpAtk1",
                                                             move, user, target, ai, battle)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("LowerTargetAtkSpAtk1",
                                                        "LowerPoisonedTargetAtkSpAtkSpd1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("RaiseAlliesAtkDef1",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
         !target.battler.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaiseAlliesAtkDef1",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 1, :DEFENSE, 1])
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaisePlusMinusUserAndAlliesAtkSpAtk1",
  proc { |move, user, ai, battle|
    will_fail = true
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.has_active_ability?([:MINUS, :PLUS])
      next if !b.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
              !b.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("RaisePlusMinusUserAndAlliesAtkSpAtk1",
  proc { |move, user, target, ai, battle|
    next true if !target.has_active_ability?([:MINUS, :PLUS])
    next !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
         !target.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaisePlusMinusUserAndAlliesAtkSpAtk1",
  proc { |score, move, user, ai, battle|
    next score if move.pbTarget(user.battler) != :UserSide
    ai.each_same_side_battler(user.side) do |b, i|
      score = ai.get_score_for_target_stat_raise(score, b, [:ATTACK, 1, :SPECIAL_ATTACK, 1], false)
    end
    next score
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaisePlusMinusUserAndAlliesAtkSpAtk1",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 1, :SPECIAL_ATTACK, 1])
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaisePlusMinusUserAndAlliesDefSpDef1",
  proc { |move, user, ai, battle|
    will_fail = true
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.has_active_ability?([:MINUS, :PLUS])
      next if !b.battler.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move) &&
              !b.battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("RaisePlusMinusUserAndAlliesDefSpDef1",
  proc { |move, user, target, ai, battle|
    next true if !target.has_active_ability?([:MINUS, :PLUS])
    next !target.battler.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move) &&
         !target.battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaisePlusMinusUserAndAlliesDefSpDef1",
  proc { |score, move, user, ai, battle|
    next score if move.pbTarget(user.battler) != :UserSide
    ai.each_same_side_battler(user.side) do |b, i|
      score = ai.get_score_for_target_stat_raise(score, b, [:DEFENSE, 1, :SPECIAL_DEFENSE, 1], false)
    end
    next score
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaisePlusMinusUserAndAlliesDefSpDef1",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:DEFENSE, 1, :SPECIAL_DEFENSE, 1])
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("RaiseGroundedGrassBattlersAtkSpAtk1",
  proc { |move, user, target, ai, battle|
    next true if !target.has_type?(:GRASS) || target.battler.airborne? || target.battler.semiInvulnerable?
    next !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
         !target.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaiseGroundedGrassBattlersAtkSpAtk1",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 1, :SPECIAL_ATTACK, 1])
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("RaiseGrassBattlersDef1",
  proc { |move, user, target, ai, battle|
    next true if !target.has_type?(:GRASS) || target.battler.semiInvulnerable?
    next !target.battler.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RaiseGrassBattlersDef1",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:DEFENSE, 1])
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserTargetSwapAtkSpAtkStages",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    [:ATTACK, :SPECIAL_ATTACK].each do |stat|
      stage_diff = target.stages[stat] - user.stages[stat]
      if stage_diff > 0
        raises.push(stat)
        raises.push(stage_diff)
      elsif stage_diff < 0
        drops.push(stat)
        drops.push(stage_diff)
      end
    end
    next Battle::AI::MOVE_USELESS_SCORE if raises.length == 0   # No stat raises
    score = ai.get_score_for_target_stat_raise(score, user, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, target, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, user, drops, false, true) if drops.length > 0
    score = ai.get_score_for_target_stat_raise(score, target, drops, false, true) if drops.length > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserTargetSwapDefSpDefStages",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    [:DEFENSE, :SPECIAL_DEFENSE].each do |stat|
      stage_diff = target.stages[stat] - user.stages[stat]
      if stage_diff > 0
        raises.push(stat)
        raises.push(stage_diff)
      elsif stage_diff < 0
        drops.push(stat)
        drops.push(stage_diff)
      end
    end
    next Battle::AI::MOVE_USELESS_SCORE if raises.length == 0   # No stat raises
    score = ai.get_score_for_target_stat_raise(score, user, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, target, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, user, drops, false, true) if drops.length > 0
    score = ai.get_score_for_target_stat_raise(score, target, drops, false, true) if drops.length > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserTargetSwapStatStages",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    GameData::Stat.each_battle do |s|
      stage_diff = target.stages[s.id] - user.stages[s.id]
      if stage_diff > 0
        raises.push(s.id)
        raises.push(stage_diff)
      elsif stage_diff < 0
        drops.push(s.id)
        drops.push(stage_diff)
      end
    end
    next Battle::AI::MOVE_USELESS_SCORE if raises.length == 0   # No stat raises
    score = ai.get_score_for_target_stat_raise(score, user, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, target, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, user, drops, false, true) if drops.length > 0
    score = ai.get_score_for_target_stat_raise(score, target, drops, false, true) if drops.length > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserCopyTargetStatStages",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    GameData::Stat.each_battle do |s|
      stage_diff = target.stages[s.id] - user.stages[s.id]
      if stage_diff > 0
        raises.push(s.id)
        raises.push(stage_diff)
      elsif stage_diff < 0
        drops.push(s.id)
        drops.push(stage_diff)
      end
    end
    next Battle::AI::MOVE_USELESS_SCORE if raises.length == 0   # No stat raises
    score = ai.get_score_for_target_stat_raise(score, user, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, user, drops, false, true) if drops.length > 0
    if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
      if user.effects[PBEffects::FocusEnergy] > 0 && target.effects[PBEffects::FocusEnergy] == 0
        score -= 4
      elsif user.effects[PBEffects::FocusEnergy] == 0 && target.effects[PBEffects::FocusEnergy] > 0
        score += 4
      end
      if user.effects[PBEffects::LaserFocus] > 0 && target.effects[PBEffects::LaserFocus] == 0
        score -= 3
      elsif user.effects[PBEffects::LaserFocus] == 0 && target.effects[PBEffects::LaserFocus] > 0
        score += 3
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: Account for stat theft before damage calculation. This would be complex,
#       involving pbCanRaiseStatStage? and Contrary and Simple; do I want to
#       account for all that or simplify things?
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserStealTargetPositiveStatStages",
  proc { |score, move, user, target, ai, battle|
    raises = []
    GameData::Stat.each_battle do |s|
      next if target.stages[s.id] <= 0
      raises.push(s.id)
      raises.push(target.stages[s.id])
    end
    if raises.length > 0
      score = ai.get_score_for_target_stat_raise(score, user, raises, false)
      score = ai.get_score_for_target_stat_drop(score, target, raises, false, true)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("InvertTargetStatStages",
  proc { |move, user, target, ai, battle|
    next !target.battler.hasAlteredStatStages?
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("InvertTargetStatStages",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    GameData::Stat.each_battle do |s|
      if target.stages[s.id] > 0
        drops.push(s.id)
        drops.push(target.stages[s.id] * 2)
      elsif target.stages[s.id] < 0
        raises.push(s.id)
        raises.push(target.stages[s.id] * 2)
      end
    end
    next Battle::AI::MOVE_USELESS_SCORE if drops.length == 0   # No stats will drop
    score = ai.get_score_for_target_stat_raise(score, target, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, target, drops, false, true) if drops.length > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("ResetTargetStatStages",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    GameData::Stat.each_battle do |s|
      if target.stages[s.id] > 0
        drops.push(s.id)
        drops.push(target.stages[s.id])
      elsif target.stages[s.id] < 0
        raises.push(s.id)
        raises.push(target.stages[s.id])
      end
    end
    score = ai.get_score_for_target_stat_raise(score, target, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, target, drops, false, true) if drops.length > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("ResetAllBattlersStatStages",
  proc { |move, user, ai, battle|
    next battle.allBattlers.none? { |b| b.hasAlteredStatStages? }
  }
)
Battle::AI::Handlers::MoveEffectScore.add("ResetAllBattlersStatStages",
  proc { |score, move, user, ai, battle|
    ai.each_battler do |b|
      raises = []
      drops = []
      GameData::Stat.each_battle do |s|
        if b.stages[s.id] > 0
          drops.push(s.id)
          drops.push(b.stages[s.id])
        elsif b.stages[s.id] < 0
          raises.push(s.id)
          raises.push(b.stages[s.id])
        end
      end
      score = ai.get_score_for_target_stat_raise(score, b, raises, false, true) if raises.length > 0
      score = ai.get_score_for_target_stat_drop(score, b, drops, false, true) if drops.length > 0
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartUserSideImmunityToStatStageLowering",
  proc { |move, user, ai, battle|
    next user.pbOwnSide.effects[PBEffects::Mist] > 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserSwapBaseAtkDef",
  proc { |score, move, user, ai, battle|
    aatk = user.rough_stat(:ATTACK)
    adef = user.rough_stat(:DEFENSE)
    next Battle::AI::MOVE_USELESS_SCORE if aatk == adef || user.effects[PBEffects::PowerTrick]   # No flip-flopping
    if adef > aatk   # Prefer a higher Attack
      score += 20
    else
      score -= 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: target should probably be treated as an enemy when deciding the score,
#       since the score will be inverted elsewhere due to the target being an
#       ally.
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserTargetSwapBaseSpeed",
  proc { |score, move, user, target, ai, battle|
    if user.speed > target.speed
      score += 25
    else
      score -= 25
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: target should probably be treated as an enemy when deciding the score,
#       since the score will be inverted elsewhere due to the target being an
#       ally.
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserTargetAverageBaseAtkSpAtk",
  proc { |score, move, user, target, ai, battle|
    user_atk     = user.battler.attack
    user_spatk   = user.battler.spatk
    target_atk   = target.battler.attack
    target_spatk = target.battler.spatk
    next Battle::AI::MOVE_USELESS_SCORE if user_atk > target_atk && user_spatk > target_spatk
    if user_atk + user_spatk < target_atk + target_spatk
      score += 20
    else
      score -= 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: target should probably be treated as an enemy when deciding the score,
#       since the score will be inverted elsewhere due to the target being an
#       ally.
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserTargetAverageBaseDefSpDef",
  proc { |score, move, user, target, ai, battle|
    user_def   = user.rough_stat(:DEFENSE)
    user_spdef = user.rough_stat(:SPECIAL_DEFENSE)
    target_def   = target.rough_stat(:DEFENSE)
    target_spdef = target.rough_stat(:SPECIAL_DEFENSE)
    next Battle::AI::MOVE_USELESS_SCORE if user_def > target_def && user_spdef > target_spdef
    if user_def + user_spdef < target_def + target_spdef
      score += 20
    else
      score -= 20
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserTargetAverageHP",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if user.hp >= (user.hp + target.hp) / 2
    mult = (user.hp + target.hp) / (2.0 * user.hp)
    score += 10 * mult if mult >= 1.2
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartUserSideDoubleSpeed",
  proc { |move, user, ai, battle|
    next user.pbOwnSide.effects[PBEffects::Tailwind] > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartUserSideDoubleSpeed",
  proc { |score, move, user, ai, battle|
    # Don't want to make allies faster if Trick Room will make them act later
    next Battle::AI::MOVE_USELESS_SCORE if battle.field.effects[PBEffects::TrickRoom] > 1
    # Get the speeds of all battlers
    ally_speeds = []
    foe_speeds = []
    ai.each_battler do |b|
      spd = b.rough_stat(:SPEED)
      (b.opposes?(user)) ? foe_speeds.push(spd) : ally_speeds.push(spd)
    end
    next Battle::AI::MOVE_USELESS_SCORE if ally_speeds.min > foe_speeds.max
    # Compare speeds of all battlers
    outspeeds = 0
    ally_speeds.each do |ally_speed|
      foe_speeds.each do |foe_speed|
        outspeeds += 1 if foe_speed > ally_speed && foe_speed < ally_speed * 2
      end
    end
    next Battle::AI::MOVE_USELESS_SCORE if outspeeds == 0
    # This move will achieve something
    next score + 10 * outspeeds + 5
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
# StartSwapAllBattlersBaseDefensiveStats
