#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseUserAttack1",
  proc { |move, user, target, ai, battle|
    next true if move.statusMove? &&
                 !user.battler.pbCanRaiseStatStage?(move.move.statUp[0], user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAttack1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score -= user.stages[:ATTACK] * 20
      if ai.trainer.medium_skill?
        hasPhysicalAttack = false
        user.battler.eachMove do |m|
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
    else
      score += 20 if user.stages[:ATTACK] < 0
      if ai.trainer.medium_skill?
        hasPhysicalAttack = false
        user.battler.eachMove do |m|
          next if !m.physicalMove?(m.type)
          hasPhysicalAttack = true
          break
        end
        score += 20 if hasPhysicalAttack
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAttack1",
                                            "RaiseUserAttack2")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAttack2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next score - 90 if user.statStageAtMax?(:ATTACK)
      score += 40 if user.turnCount == 0
      score -= user.stages[:ATTACK] * 20
      if ai.trainer.medium_skill?
        hasPhysicalAttack = false
        user.battler.eachMove do |m|
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
    else
      score += 10 if user.turnCount == 0
      score += 20 if user.stages[:ATTACK] < 0
      if ai.trainer.medium_skill?
        hasPhysicalAttack = false
        user.battler.eachMove do |m|
          next if !m.physicalMove?(m.type)
          hasPhysicalAttack = true
          break
        end
        score += 20 if hasPhysicalAttack
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAttack2",
                                           "RaiseUserAttack2IfTargetFaints")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAttack2",
                                            "RaiseUserAttack3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAttack2",
                                           "RaiseUserAttack3")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAttack2IfTargetFaints",
                                           "RaiseUserAttack3IfTargetFaints")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("MaxUserAttackLoseHalfOfTotalHP",
  proc { |move, user, target, ai, battle|
    next true if user.hp <= [user.totalhp / 2, 1].max
    next true if !user.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("MaxUserAttackLoseHalfOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    score += (6 - user.stages[:ATTACK]) * 10
    if ai.trainer.medium_skill?
      hasPhysicalAttack = false
      user.battler.eachMove do |m|
        next if !m.physicalMove?(m.type)
        hasPhysicalAttack = true
        break
      end
      if hasPhysicalAttack
        score += 40
      elsif ai.trainer.high_skill?
        score -= 90
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAttack1",
                                            "RaiseUserDefense1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserDefense1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next score - user.stages[:DEFENSE] * 20
    elsif user.stages[:DEFENSE] < 0
      next score + 20
    end
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserDefense1",
                                            "RaiseUserDefense1CurlUpUser")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserDefense1",
                                           "RaiseUserDefense1CurlUpUser")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserDefense1",
                                            "RaiseUserDefense2")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserDefense2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 40 if user.turnCount == 0
      score -= user.stages[:DEFENSE] * 20
    else
      score += 10 if user.turnCount == 0
      score += 20 if user.stages[:DEFENSE] < 0
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserDefense1",
                                            "RaiseUserDefense3")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserDefense3",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 40 if user.turnCount == 0
      score -= user.stages[:DEFENSE] * 30
    else
      score += 10 if user.turnCount == 0
      score += 30 if user.stages[:DEFENSE] < 0
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAttack1",
                                            "RaiseUserSpAtk1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpAtk1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score -= user.stages[:SPECIAL_ATTACK] * 20
      if ai.trainer.medium_skill?
        hasSpecicalAttack = false
        user.battler.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecicalAttack = true
          break
        end
        if hasSpecicalAttack
          score += 20
        elsif ai.trainer.high_skill?
          score -= 90
        end
      end
    else
      score += 20 if user.stages[:SPECIAL_ATTACK] < 0
      if ai.trainer.medium_skill?
        hasSpecicalAttack = false
        user.battler.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecicalAttack = true
          break
        end
        score += 20 if hasSpecicalAttack
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpAtk1",
                                            "RaiseUserSpAtk2")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpAtk2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 40 if user.turnCount == 0
      score -= user.stages[:SPECIAL_ATTACK] * 20
      if ai.trainer.medium_skill?
        hasSpecicalAttack = false
        user.battler.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecicalAttack = true
          break
        end
        if hasSpecicalAttack
          score += 20
        elsif ai.trainer.high_skill?
          score -= 90
        end
      end
    else
      score += 10 if user.turnCount == 0
      score += 20 if user.stages[:SPECIAL_ATTACK] < 0
      if ai.trainer.medium_skill?
        hasSpecicalAttack = false
        user.battler.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecicalAttack = true
          break
        end
        score += 20 if hasSpecicalAttack
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpAtk1",
                                            "RaiseUserSpAtk3")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpAtk3",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 40 if user.turnCount == 0
      score -= user.stages[:SPECIAL_ATTACK] * 30
      if ai.trainer.medium_skill?
        hasSpecicalAttack = false
        user.battler.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecicalAttack = true
          break
        end
        if hasSpecicalAttack
          score += 30
        elsif ai.trainer.high_skill?
          score -= 90
        end
      end
    else
      score += 10 if user.turnCount == 0
      score += 30 if user.stages[:SPECIAL_ATTACK] < 0
      if ai.trainer.medium_skill?
        hasSpecicalAttack = false
        user.battler.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecicalAttack = true
          break
        end
        score += 30 if hasSpecicalAttack
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserDefense1",
                                            "RaiseUserSpDef1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpDef1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 40 if user.turnCount == 0
      score -= user.stages[:SPECIAL_DEFENSE] * 20
    else
      score += 10 if user.turnCount == 0
      score += 20 if user.stages[:SPECIAL_DEFENSE] < 0
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpDef1",
                                            "RaiseUserSpDef1PowerUpElectricMove")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpDef1PowerUpElectricMove",
  proc { |score, move, user, target, ai, battle|
    foundMove = false
    user.battler.eachMove do |m|
      next if m.type != :ELECTRIC || !m.damagingMove?
      foundMove = true
      break
    end
    score += 20 if foundMove
    if move.statusMove?
      score -= user.stages[:SPECIAL_DEFENSE] * 20
    elsif user.stages[:SPECIAL_DEFENSE] < 0
      score += 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpDef1",
                                            "RaiseUserSpDef2")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpDef1",
                                           "RaiseUserSpDef2")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpDef1",
                                            "RaiseUserSpDef3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpDef1",
                                           "RaiseUserSpDef3")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpDef1",
                                            "RaiseUserSpeed1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpeed1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score -= user.stages[:SPEED] * 10
      if ai.trainer.high_skill?
        aspeed = user.rough_stat(:SPEED)
        ospeed = target.rough_stat(:SPEED)
        score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
      end
    elsif user.stages[:SPEED] < 0
      score += 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpeed1",
                                            "RaiseUserSpeed2")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpeed2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 20 if user.turnCount == 0
      score -= user.stages[:SPEED] * 10
      if ai.trainer.high_skill?
        aspeed = user.rough_stat(:SPEED)
        ospeed = target.rough_stat(:SPEED)
        score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
      end
    else
      score += 10 if user.turnCount == 0
      score += 20 if user.stages[:SPEED] < 0
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpeed2",
                                            "RaiseUserSpeed2LowerUserWeight")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpeed2",
                                           "RaiseUserSpeed2LowerUserWeight")

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpeed2",
                                            "RaiseUserSpeed3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpeed2",
                                           "RaiseUserSpeed3")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserSpeed1",
                                            "RaiseUserAccuracy1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAccuracy1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 40 if user.turnCount == 0
      score -= user.stages[:ACCURACY] * 20
    else
      score += 10 if user.turnCount == 0
      score += 20 if user.stages[:ACCURACY] < 0
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAccuracy1",
                                            "RaiseUserAccuracy2")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAccuracy1",
                                           "RaiseUserAccuracy2")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAccuracy1",
                                            "RaiseUserAccuracy3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAccuracy1",
                                           "RaiseUserAccuracy3")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAccuracy1",
                                            "RaiseUserEvasion1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserEvasion1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score -= user.stages[:EVASION] * 10
    elsif user.stages[:EVASION] < 0
      score += 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserEvasion1",
                                            "RaiseUserEvasion2")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserEvasion2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 40 if user.turnCount == 0
      score -= user.stages[:EVASION] * 10
    else
      score += 10 if user.turnCount == 0
      score += 20 if user.stages[:EVASION] < 0
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserEvasion2",
                                            "RaiseUserEvasion2MinimizeUser")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserEvasion2",
                                           "RaiseUserEvasion2MinimizeUser")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserEvasion2",
                                            "RaiseUserEvasion3")
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserEvasion2",
                                           "RaiseUserEvasion3")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseUserCriticalHitRate2",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::FocusEnergy] >= 2
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserCriticalHitRate2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove? || user.effects[PBEffects::FocusEnergy] < 2
      next score + 30
    end
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseUserAtkDef1",
  proc { |move, user, target, ai, battle|
    if move.statusMove?
      will_fail = true
      (move.move.statUp.length / 2).times do |i|
        next if !user.battler.pbCanRaiseStatStage?(move.move.statUp[i * 2], user.battler, move.move)
        will_fail = false
        break
      end
      next will_fail
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkDef1",
  proc { |score, move, user, target, ai, battle|
    score -= user.stages[:ATTACK] * 10
    score -= user.stages[:DEFENSE] * 10
    if ai.trainer.medium_skill?
      hasPhysicalAttack = false
      user.battler.eachMove do |m|
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
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkDef1",
                                            "RaiseUserAtkDefAcc1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkDefAcc1",
  proc { |score, move, user, target, ai, battle|
    score -= user.stages[:ATTACK] * 10
    score -= user.stages[:DEFENSE] * 10
    score -= user.stages[:ACCURACY] * 10
    if ai.trainer.medium_skill?
      hasPhysicalAttack = false
      user.battler.eachMove do |m|
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
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkDef1",
                                            "RaiseUserAtkSpAtk1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkSpAtk1",
  proc { |score, move, user, target, ai, battle|
    score -= user.stages[:ATTACK] * 10
    score -= user.stages[:SPECIAL_ATTACK] * 10
    if ai.trainer.medium_skill?
      hasDamagingAttack = false
      user.battler.eachMove do |m|
        next if !m.damagingMove?
        hasDamagingAttack = true
        break
      end
      if hasDamagingAttack
        score += 20
      elsif ai.trainer.high_skill?
        score -= 90
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserAtkSpAtk1Or2InSun")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkSpAtk1Or2InSun",
  proc { |score, move, user, target, ai, battle|
    score -= user.stages[:ATTACK] * 10
    score -= user.stages[:SPECIAL_ATTACK] * 10
    if ai.trainer.medium_skill?
      hasDamagingAttack = false
      user.battler.eachMove do |m|
        next if !m.damagingMove?
        hasDamagingAttack = true
        break
      end
      if hasDamagingAttack
        score += 20
      elsif ai.trainer.high_skill?
        score -= 90
      end
    end
    score += 20 if [:Sun, :HarshSun].include?(user.battler.effectiveWeather)
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2",
  proc { |move, user, target, ai, battle|
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
  proc { |score, move, user, target, ai, battle|
    score -= user.stages[:ATTACK] * 20
    score -= user.stages[:SPEED] * 20
    score -= user.stages[:SPECIAL_ATTACK] * 20
    score += user.stages[:DEFENSE] * 10
    score += user.stages[:SPECIAL_DEFENSE] * 10
    if ai.trainer.medium_skill?
      hasDamagingAttack = false
      user.battler.eachMove do |m|
        next if !m.damagingMove?
        hasDamagingAttack = true
        break
      end
      score += 20 if hasDamagingAttack
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserAtkSpd1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkSpd1",
  proc { |score, move, user, target, ai, battle|
    score += 40 if user.turnCount == 0   # Dragon Dance tends to be popular
    score -= user.stages[:ATTACK] * 10
    score -= user.stages[:SPEED] * 10
    if ai.trainer.medium_skill?
      hasPhysicalAttack = false
      user.battler.eachMove do |m|
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
    if ai.trainer.high_skill?
      aspeed = user.rough_stat(:SPEED)
      ospeed = target.rough_stat(:SPEED)
      score += 20 if aspeed < ospeed && aspeed * 2 > ospeed
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserAtk1Spd2")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtk1Spd2",
  proc { |score, move, user, target, ai, battle|
    score -= user.stages[:ATTACK] * 10
    score -= user.stages[:SPEED] * 10
    if ai.trainer.medium_skill?
      hasPhysicalAttack = false
      user.battler.eachMove do |m|
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
    if ai.trainer.high_skill?
      aspeed = user.rough_stat(:SPEED)
      ospeed = target.rough_stat(:SPEED)
      score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserAtkAcc1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkAcc1",
  proc { |score, move, user, target, ai, battle|
    score -= user.stages[:ATTACK] * 10
    score -= user.stages[:ACCURACY] * 10
    if ai.trainer.medium_skill?
      hasPhysicalAttack = false
      user.battler.eachMove do |m|
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
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserDefSpDef1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserDefSpDef1",
  proc { |score, move, user, target, ai, battle|
    score -= user.stages[:DEFENSE] * 10
    score -= user.stages[:SPECIAL_DEFENSE] * 10
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserSpAtkSpDef1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpAtkSpDef1",
  proc { |score, move, user, target, ai, battle|
    score += 40 if user.turnCount == 0   # Calm Mind tends to be popular
    score -= user.stages[:SPECIAL_ATTACK] * 10
    score -= user.stages[:SPECIAL_DEFENSE] * 10
    if ai.trainer.medium_skill?
      hasSpecicalAttack = false
      user.battler.eachMove do |m|
        next if !m.specialMove?(m.type)
        hasSpecicalAttack = true
        break
      end
      if hasSpecicalAttack
        score += 20
      elsif ai.trainer.high_skill?
        score -= 90
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserSpAtkSpDefSpd1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpAtkSpDefSpd1",
  proc { |score, move, user, target, ai, battle|
    score += 40 if user.turnCount == 0   # Calm Mind tends to be popular
    score -= user.stages[:SPECIAL_ATTACK] * 10
    score -= user.stages[:SPECIAL_DEFENSE] * 10
    score -= user.stages[:SPEED] * 10
    if ai.trainer.medium_skill?
      hasSpecicalAttack = false
      user.battler.eachMove do |m|
        next if !m.specialMove?(m.type)
        hasSpecicalAttack = true
        break
      end
      if hasSpecicalAttack
        score += 20
      elsif ai.trainer.high_skill?
        score -= 90
      end
    end
    if ai.trainer.high_skill?
      aspeed = user.rough_stat(:SPEED)
      ospeed = target.rough_stat(:SPEED)
      score += 20 if aspeed < ospeed && aspeed * 2 > ospeed
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("RaiseUserAtkSpAtk1",
                                            "RaiseUserMainStats1")
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserMainStats1",
  proc { |score, move, user, target, ai, battle|
    GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] < 0 }
    if ai.trainer.medium_skill?
      hasDamagingAttack = false
      user.battler.eachMove do |m|
        next if !m.damagingMove?
        hasDamagingAttack = true
        break
      end
      score += 20 if hasDamagingAttack
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseUserMainStats1LoseThirdOfTotalHP",
  proc { |move, user, target, ai, battle|
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
  proc { |score, move, user, target, ai, battle|
    next 0 if !battle.moldBreaker && user.has_active_ability?(:CONTRARY)
    score += 30 if ai.trainer.high_skill? && user.hp >= user.totalhp * 0.75
    GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] <= 0 }
    if ai.trainer.medium_skill?
      hasDamagingAttack = user.battler.moves.any? { |m| next m&.damagingMove? }
      score += 20 if hasDamagingAttack
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseUserMainStats1TrapUserInBattle",
  proc { |move, user, target, ai, battle|
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
  proc { |score, move, user, target, ai, battle|
    next 0 if !battle.moldBreaker && user.has_active_ability?(:CONTRARY)
    if ai.trainer.high_skill?
      score -= 50 if user.hp <= user.totalhp / 2
      score += 30 if user.battler.trappedInBattle?
    end
    GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] <= 0 }
    if ai.trainer.medium_skill?
      hasDamagingAttack = user.battler.moves.any? { |m| next m&.damagingMove? }
      score += 20 if hasDamagingAttack
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("StartRaiseUserAtk1WhenDamaged",
  proc { |score, move, user, target, ai, battle|
    next score + 25 if user.effects[PBEffects::Rage]
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("LowerUserAttack1",
  proc { |score, move, user, target, ai, battle|
    next score + user.stages[:ATTACK] * 10
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserAttack1",
                                           "LowerUserAttack2")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("LowerUserDefense1",
  proc { |score, move, user, target, ai, battle|
    next score + user.stages[:DEFENSE] * 10
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserDefense1",
                                           "LowerUserDefense2")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("LowerUserSpAtk1",
  proc { |score, move, user, target, ai, battle|
    next score + user.stages[:SPECIAL_ATTACK] * 10
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserSpAtk1",
                                           "LowerUserSpAtk2")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("LowerUserSpDef1",
  proc { |score, move, user, target, ai, battle|
    next score + user.stages[:SPECIAL_DEFENSE] * 10
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserSpDef1",
                                           "LowerUserSpDef2")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("LowerUserSpeed1",
  proc { |score, move, user, target, ai, battle|
    next score + user.stages[:SPECIAL_DEFENSE] * 10
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("LowerUserSpeed1",
                                           "LowerUserSpeed2")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("LowerUserAtkDef1",
  proc { |score, move, user, target, ai, battle|
    avg =  user.stages[:ATTACK] * 10
    avg += user.stages[:DEFENSE] * 10
    next score + avg / 2
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("LowerUserDefSpDef1",
  proc { |score, move, user, target, ai, battle|
    avg =  user.stages[:DEFENSE] * 10
    avg += user.stages[:SPECIAL_DEFENSE] * 10
    next score + avg / 2
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("LowerUserDefSpDefSpd1",
  proc { |score, move, user, target, ai, battle|
    avg =  user.stages[:DEFENSE] * 10
    avg += user.stages[:SPEED] * 10
    avg += user.stages[:SPECIAL_DEFENSE] * 10
    next score + (avg / 3).floor
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseTargetAttack1",
  proc { |move, user, target, ai, battle|
    next true if move.statusMove? &&
                 !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseTargetAttack2ConfuseTarget",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
                 !target.battler.pbCanConfuse?(user.battler, false, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseTargetAttack2ConfuseTarget",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if !target.battler.pbCanConfuse?(user.battler, false)
    next score + 30 if target.stages[:ATTACK] < 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseTargetSpAtk1ConfuseTarget",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move) &&
                 !target.battler.pbCanConfuse?(user.battler, false, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseTargetSpAtk1ConfuseTarget",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if !target.battler.pbCanConfuse?(user.battler, false)
    next score + 30 if target.stages[:SPECIAL_ATTACK] < 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseTargetSpDef1",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseTargetSpDef1",
  proc { |score, move, user, target, ai, battle|
    next score - target.stages[:SPECIAL_DEFENSE] * 10
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseTargetRandomStat2",
  proc { |move, user, target, ai, battle|
    will_fail = true
    GameData::Stat.each_battle do |s|
      next if !target.battler.pbCanRaiseStatStage?(s.id, user.battler, move.move)
      will_fail = false
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseTargetRandomStat2",
  proc { |score, move, user, target, ai, battle|
    avgStat = 0
    GameData::Stat.each_battle do |s|
      avgStat -= target.stages[s.id] if !target.statStageAtMax?(s.id)
    end
    avgStat = avgStat / 2 if avgStat < 0   # More chance of getting even better
    next + avgStat * 10
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseTargetAtkSpAtk2",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
                 !target.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseTargetAtkSpAtk2",
  proc { |score, move, user, target, ai, battle|
    next score - 50 if target.opposes?(user)
    next score - 40 if !battle.moldBreaker && target.has_active_ability?(:CONTRARY)
    score -= target.stages[:ATTACK] * 10
    score -= target.stages[:SPECIAL_ATTACK] * 10
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("LowerTargetAttack1",
  proc { |move, user, target, ai, battle|
    next true if move.statusMove? &&
                 !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAttack1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
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
    else
      score += 20 if target.stages[:ATTACK] > 0
      if ai.trainer.medium_skill?
        hasPhysicalAttack = false
        target.battler.eachMove do |m|
          next if !m.physicalMove?(m.type)
          hasPhysicalAttack = true
          break
        end
        score += 20 if hasPhysicalAttack
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetAttack1",
                                            "LowerTargetAttack1BypassSubstitute")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAttack1BypassSubstitute",
  proc { |score, move, user, target, ai, battle|
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
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetAttack1",
                                            "LowerTargetAttack2")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAttack2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 40 if user.turnCount == 0
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
    else
      score += 10 if user.turnCount == 0
      score += 20 if target.stages[:ATTACK] > 0
      if ai.trainer.medium_skill?
        hasPhysicalAttack = false
        target.battler.eachMove do |m|
          next if !m.physicalMove?(m.type)
          hasPhysicalAttack = true
          break
        end
        score += 20 if hasPhysicalAttack
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetAttack2",
                                            "LowerTargetAttack3")
Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetAttack2",
                                           "LowerTargetAttack3")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetAttack1",
                                            "LowerTargetDefense1")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetDefense1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += target.stages[:DEFENSE] * 20
    elsif target.stages[:DEFENSE] > 0
      score += 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetDefense1",
                                            "LowerTargetDefense1PowersUpInGravity")
Battle::AI::Handlers::MoveBasePower.add("LowerTargetDefense1PowersUpInGravity",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetDefense1PowersUpInGravity",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += target.stages[:DEFENSE] * 20
    elsif target.stages[:DEFENSE] > 0
      score += 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetDefense1",
                                            "LowerTargetDefense2")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetDefense2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 40 if user.turnCount == 0
      score += target.stages[:DEFENSE] * 20
    else
      score += 10 if user.turnCount == 0
      score += 20 if target.stages[:DEFENSE] > 0
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetDefense2",
                                            "LowerTargetDefense3")
Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetDefense2",
                                           "LowerTargetDefense3")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetAttack1",
                                            "LowerTargetSpAtk1")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpAtk1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += user.stages[:SPECIAL_ATTACK] * 20
      if ai.trainer.medium_skill?
        hasSpecicalAttack = false
        target.battler.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecicalAttack = true
          break
        end
        if hasSpecicalAttack
          score += 20
        elsif ai.trainer.high_skill?
          score -= 90
        end
      end
    else
      score += 20 if user.stages[:SPECIAL_ATTACK] > 0
      if ai.trainer.medium_skill?
        hasSpecicalAttack = false
        target.battler.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecicalAttack = true
          break
        end
        score += 20 if hasSpecicalAttack
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetSpAtk1",
                                            "LowerTargetSpAtk2")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpAtk2",
  proc { |score, move, user, target, ai, battle|
    score += 40 if user.turnCount == 0
    score += target.stages[:SPECIAL_ATTACK] * 20
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("LowerTargetSpAtk2IfCanAttract",
  proc { |move, user, target, ai, battle|
    next true if move.statusMove? &&
                 !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
    next true if user.gender == 2 || target.gender == 2 || user.gender == target.gender
    next true if !battle.moldBreaker && target.has_active_ability?(:OBLIVIOUS)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpAtk2IfCanAttract",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 40 if user.turnCount == 0
      score += target.stages[:SPECIAL_ATTACK] * 20
      if ai.trainer.medium_skill?
        hasSpecicalAttack = false
        target.battler.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecicalAttack = true
          break
        end
        if hasSpecicalAttack
          score += 20
        elsif ai.trainer.high_skill?
          score -= 90
        end
      end
    else
      score += 10 if user.turnCount == 0
      score += 20 if target.stages[:SPECIAL_ATTACK] > 0
      if ai.trainer.medium_skill?
        hasSpecicalAttack = false
        target.battler.eachMove do |m|
          next if !m.specialMove?(m.type)
          hasSpecicalAttack = true
          break
        end
        score += 30 if hasSpecicalAttack
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetSpAtk1",
                                            "LowerTargetSpAtk3")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpAtk3",
  proc { |score, move, user, target, ai, battle|
    score += 40 if user.turnCount == 0
    score += target.stages[:SPECIAL_ATTACK] * 20
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetDefense1",
                                            "LowerTargetSpDef1")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpDef1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += target.stages[:SPECIAL_DEFENSE] * 20
    elsif target.stages[:SPECIAL_DEFENSE] > 0
      score += 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetSpDef1",
                                            "LowerTargetSpDef2")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpDef2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 40 if user.turnCount == 0
      score += target.stages[:SPECIAL_DEFENSE] * 20
    else
      score += 10 if user.turnCount == 0
      score += 20 if target.stages[:SPECIAL_DEFENSE] > 0
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetSpDef2",
                                            "LowerTargetSpDef3")
Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetSpDef2",
                                           "LowerTargetSpDef3")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetSpDef1",
                                            "LowerTargetSpeed1")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpeed1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += target.stages[:SPEED] * 10
      if ai.trainer.high_skill?
        aspeed = user.rough_stat(:SPEED)
        ospeed = target.rough_stat(:SPEED)
        score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
      end
    elsif user.stages[:SPEED] > 0
      score += 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetSpeed1",
                                            "LowerTargetSpeed1WeakerInGrassyTerrain")
Battle::AI::Handlers::MoveBasePower.add("LowerTargetSpeed1WeakerInGrassyTerrain",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetSpeed1",
                                           "LowerTargetSpeed1WeakerInGrassyTerrain")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("LowerTargetSpeed1MakeTargetWeakerToFire",
  proc { |move, user, target, ai, battle|
    next false if !target.effects[PBEffects::TarShot]
    next true if move.statusMove? &&
                 !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpeed1MakeTargetWeakerToFire",
  proc { |score, move, user, target, ai, battle|
    score += target.stages[:SPEED] * 10
    if ai.trainer.high_skill?
      aspeed = user.rough_stat(:SPEED)
      ospeed = target.rough_stat(:SPEED)
      score += 50 if aspeed < ospeed && aspeed * 2 > ospeed
    end
    score += 20 if user.battler.moves.any? { |m| m.damagingMove? && m.pbCalcType(user.battler) == :FIRE }
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetSpeed1",
                                            "LowerTargetSpeed2")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpeed2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += 20 if user.turnCount == 0
      score += target.stages[:SPEED] * 20
      if ai.trainer.high_skill?
        aspeed = user.rough_stat(:SPEED)
        ospeed = target.rough_stat(:SPEED)
        score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
      end
    else
      score += 10 if user.turnCount == 0
      score += 30 if target.stages[:SPEED] > 0
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetSpeed2",
                                            "LowerTargetSpeed3")
Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetSpeed2",
                                           "LowerTargetSpeed3")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetSpeed1",
                                            "LowerTargetAccuracy1")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAccuracy1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += target.stages[:ACCURACY] * 10
    elsif target.stages[:ACCURACY] > 0
      score += 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetAccuracy1",
                                            "LowerTargetAccuracy2")
Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetAccuracy1",
                                           "LowerTargetAccuracy2")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetAccuracy1",
                                            "LowerTargetAccuracy3")
Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetAccuracy1",
                                           "LowerTargetAccuracy3")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetAccuracy1",
                                            "LowerTargetEvasion1")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetEvasion1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += target.stages[:EVASION] * 10
    elsif target.stages[:EVASION] > 0
      score += 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("LowerTargetEvasion1RemoveSideEffects",
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
    next true if move.statusMove? &&
                 !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetEvasion1RemoveSideEffects",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += target.stages[:EVASION] * 10
    elsif target.stages[:EVASION] > 0
      score += 20
    end
    score += 30 if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 ||
                   target.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
                   target.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
                   target.pbOwnSide.effects[PBEffects::Mist] > 0 ||
                   target.pbOwnSide.effects[PBEffects::Safeguard] > 0
    score -= 30 if target.pbOwnSide.effects[PBEffects::Spikes] > 0 ||
                   target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0 ||
                   target.pbOwnSide.effects[PBEffects::StealthRock]
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetEvasion1",
                                            "LowerTargetEvasion2")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetEvasion2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      score += target.stages[:EVASION] * 10
    elsif target.stages[:EVASION] > 0
      score += 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetEvasion2",
                                            "LowerTargetEvasion3")
Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetEvasion2",
                                           "LowerTargetEvasion3")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("LowerTargetAtkDef1",
  proc { |move, user, target, ai, battle|
    will_fail = true
    (move.move.statDown.length / 2).times do |i|
      next if !target.battler.pbCanLowerStatStage?(move.move.statDown[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAtkDef1",
  proc { |score, move, user, target, ai, battle|
    avg =  target.stages[:ATTACK] * 10
    avg += target.stages[:DEFENSE] * 10
    next score + avg / 2
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("LowerTargetAtkDef1",
                                            "LowerTargetAtkSpAtk1")
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAtkSpAtk1",
  proc { |score, move, user, target, ai, battle|
    avg =  target.stages[:ATTACK] * 10
    avg += target.stages[:SPECIAL_ATTACK] * 10
    next score + avg / 2
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("LowerPoisonedTargetAtkSpAtkSpd1",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.poisoned?
    next true if !target.battler.pbCanLowerStatStage?(:ATTACK, user.battler, move.move) &&
                 !target.battler.pbCanLowerStatStage?(:SPECIAL_ATTACK, user.battler, move.move) &&
                 !target.battler.pbCanLowerStatStage?(:SPEED, user.battler, move.move)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("LowerPoisonedTargetAtkSpAtkSpd1",
  proc { |score, move, user, target, ai, battle|
    if target.opposes?(user)
      score += target.stages[:ATTACK] * 10
      score += target.stages[:SPECIAL_ATTACK] * 10
      score += target.stages[:SPEED] * 10
    else
      score -= 20
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseAlliesAtkDef1",
  proc { |move, user, target, ai, battle|
    will_fail = true
    battle.allSameSideBattlers(user.battler).each do |b|
      next if b.index == user.index
      next if !b.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
              !b.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseAlliesAtkDef1",
  proc { |score, move, user, target, ai, battle|
    user.battler.allAllies.each do |b|
      if !battle.moldBreaker && b.hasActiveAbility?(:CONTRARY)
        score -= 40
      else
        score += 10
        score -= b.stages[:ATTACK] * 10
        score -= b.stages[:SPECIAL_ATTACK] * 10
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaisePlusMinusUserAndAlliesAtkSpAtk1",
  proc { |move, user, target, ai, battle|
    will_fail = true
    battle.allSameSideBattlers(user.battler).each do |b|
      next if !b.hasActiveAbility?([:MINUS, :PLUS])
      next if !b.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaisePlusMinusUserAndAlliesAtkSpAtk1",
  proc { |score, move, user, target, ai, battle|
    user.battler.allAllies.each do |b|
      next if b.statStageAtMax?(:ATTACK) && b.statStageAtMax?(:SPECIAL_ATTACK)
      score -= b.stages[:ATTACK] * 10
      score -= b.stages[:SPECIAL_ATTACK] * 10
    end
    score -= user.stages[:ATTACK] * 10
    score -= user.stages[:SPECIAL_ATTACK] * 10
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaisePlusMinusUserAndAlliesAtkSpAtk1",
  proc { |move, user, target, ai, battle|
    will_fail = true
    battle.allSameSideBattlers(user.battler).each do |b|
      next if !b.hasActiveAbility?([:MINUS, :PLUS])
      next if !b.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaisePlusMinusUserAndAlliesDefSpDef1",
  proc { |score, move, user, target, ai, battle|
    user.battler.allAllies.each do |b|
      next if b.statStageAtMax?(:DEFENSE) && b.statStageAtMax?(:SPECIAL_DEFENSE)
      score -= b.stages[:DEFENSE] * 10
      score -= b.stages[:SPECIAL_DEFENSE] * 10
    end
    score -= user.stages[:DEFENSE] * 10
    score -= user.stages[:SPECIAL_DEFENSE] * 10
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseGroundedGrassBattlersAtkSpAtk1",
  proc { |move, user, target, ai, battle|
    will_fail = true
    battle.allBattlers.each do |b|
      next if !b.pbHasType?(:GRASS) || b.airborne? || b.semiInvulnerable?
      next if !b.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
              !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseGroundedGrassBattlersAtkSpAtk1",
  proc { |score, move, user, target, ai, battle|
    battle.allBattlers.each do |b|
      if user.battler.opposes?(b)
        score -= 20
      else
        score -= user.stages[:ATTACK] * 10
        score -= user.stages[:SPECIAL_ATTACK] * 10
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RaiseGrassBattlersDef1",
  proc { |move, user, target, ai, battle|
    will_fail = true
    battle.allBattlers.each do |b|
      next if !b.pbHasType?(:GRASS) || b.semiInvulnerable?
      next if !b.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RaiseGrassBattlersDef1",
  proc { |score, move, user, target, ai, battle|
    battle.allBattlers.each do |b|
      if user.battler.opposes?(b)
        score -= 20
      else
        score -= user.stages[:DEFENSE] * 10
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserTargetSwapAtkSpAtkStages",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      aatk = user.stages[:ATTACK]
      aspa = user.stages[:SPECIAL_ATTACK]
      oatk = target.stages[:ATTACK]
      ospa = target.stages[:SPECIAL_ATTACK]
      if aatk >= oatk && aspa >= ospa
        score -= 80
      else
        score += (oatk - aatk) * 10
        score += (ospa - aspa) * 10
      end
    else
      score -= 50
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserTargetSwapDefSpDefStages",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      adef = user.stages[:DEFENSE]
      aspd = user.stages[:SPECIAL_DEFENSE]
      odef = target.stages[:DEFENSE]
      ospd = target.stages[:SPECIAL_DEFENSE]
      if adef >= odef && aspd >= ospd
        score -= 80
      else
        score += (odef - adef) * 10
        score += (ospd - aspd) * 10
      end
    else
      score -= 50
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserTargetSwapStatStages",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      userStages = 0
      targetStages = 0
      GameData::Stat.each_battle do |s|
        userStages   += user.stages[s.id]
        targetStages += target.stages[s.id]
      end
      score += (targetStages - userStages) * 10
    else
      score -= 50
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserCopyTargetStatStages",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      equal = true
      GameData::Stat.each_battle do |s|
        stagediff = target.stages[s.id] - user.stages[s.id]
        score += stagediff * 10
        equal = false if stagediff != 0
      end
      score -= 80 if equal
    else
      score -= 50
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: Account for stat theft before damage calculation.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserStealTargetPositiveStatStages",
  proc { |score, move, user, target, ai, battle|
    numStages = 0
    GameData::Stat.each_battle do |s|
      next if target.stages[s.id] <= 0
      numStages += target.stages[s.id]
    end
    next score + numStages * 20
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("InvertTargetStatStages",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.hasAlteredStatStages?
  }
)
Battle::AI::Handlers::MoveEffectScore.add("InvertTargetStatStages",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.effects[PBEffects::Substitute] > 0
    numpos = 0
    numneg = 0
    GameData::Stat.each_battle do |s|
      numpos += target.stages[s.id] if target.stages[s.id] > 0
      numneg += target.stages[s.id] if target.stages[s.id] < 0
    end
    next score + (numpos - numneg) * 10
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("ResetTargetStatStages",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.effects[PBEffects::Substitute] > 0
    avg = 0
    anyChange = false
    GameData::Stat.each_battle do |s|
      next if target.stages[s.id] == 0
      avg += target.stages[s.id]
      anyChange = true
    end
    next 0 if !anyChange
    next score + avg * 10
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("ResetAllBattlersStatStages",
  proc { |move, user, target, ai, battle|
    next true if battle.allBattlers.none? { |b| b.hasAlteredStatStages? }
  }
)
Battle::AI::Handlers::MoveEffectScore.add("ResetAllBattlersStatStages",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      stages = 0
      battle.allBattlers.each do |b|
        totalStages = 0
        GameData::Stat.each_battle { |s| totalStages += b.stages[s.id] }
        if b.opposes?(user.battler)
          stages += totalStages
        else
          stages -= totalStages
        end
      end
      next score + stages * 10
    end
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartUserSideImmunityToStatStageLowering",
  proc { |move, user, target, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::Mist] > 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserSwapBaseAtkDef",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      aatk = user.rough_stat(:ATTACK)
      adef = user.rough_stat(:DEFENSE)
      if aatk == adef ||
         user.effects[PBEffects::PowerTrick]   # No flip-flopping
        score -= 90
      elsif adef > aatk   # Prefer a higher Attack
        score += 30
      else
        score -= 30
      end
    else
      score -= 30
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserTargetSwapBaseSpeed",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      if user.speed > target.speed
        score += 50
      else
        score -= 70
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserTargetAverageBaseAtkSpAtk",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      aatk   = user.rough_stat(:ATTACK)
      aspatk = user.rough_stat(:SPECIAL_ATTACK)
      oatk   = target.rough_stat(:ATTACK)
      ospatk = target.rough_stat(:SPECIAL_ATTACK)
      if aatk < oatk && aspatk < ospatk
        score += 50
      elsif aatk + aspatk < oatk + ospatk
        score += 30
      else
        score -= 50
      end
    else
      score -= 30
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserTargetAverageBaseDefSpDef",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      adef   = user.rough_stat(:DEFENSE)
      aspdef = user.rough_stat(:SPECIAL_DEFENSE)
      odef   = target.rough_stat(:DEFENSE)
      ospdef = target.rough_stat(:SPECIAL_DEFENSE)
      if adef < odef && aspdef < ospdef
        score += 50
      elsif adef + aspdef < odef + ospdef
        score += 30
      else
        score -= 50
      end
    else
      score -= 30
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserTargetAverageHP",
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::Substitute] > 0
      score -= 90
    elsif user.hp >= (user.hp + target.hp) / 2
      score -= 90
    else
      score += 40
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartUserSideDoubleSpeed",
  proc { |move, user, target, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::Tailwind] > 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
# StartSwapAllBattlersBaseDefensiveStats
