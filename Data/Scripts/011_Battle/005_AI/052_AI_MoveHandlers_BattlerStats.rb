#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAttack1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next score - 90 if user.statStageAtMax?(:ATTACK)
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

Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAttack2",
                                           "RaiseUserAttack2IfTargetFaints",
                                           "RaiseUserAttack3",
                                           "RaiseUserAttack3IfTargetFaints")

Battle::AI::Handlers::MoveEffectScore.add("MaxUserAttackLoseHalfOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.statStageAtMax?(:ATTACK) || user.hp <= user.totalhp / 2
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserDefense1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:DEFENSE)
      next score - user.stages[:DEFENSE] * 20
    elsif user.stages[:DEFENSE] < 0
      next score + 20
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserDefense1",
                                           "RaiseUserDefense1CurlUpUser")

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserDefense2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:DEFENSE)
      score += 40 if user.turnCount == 0
      score -= user.stages[:DEFENSE] * 20
    else
      score += 10 if user.turnCount == 0
      score += 20 if user.stages[:DEFENSE] < 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserDefense3",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:DEFENSE)
      score += 40 if user.turnCount == 0
      score -= user.stages[:DEFENSE] * 30
    else
      score += 10 if user.turnCount == 0
      score += 30 if user.stages[:DEFENSE] < 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpAtk1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:SPECIAL_ATTACK)
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpAtk2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:SPECIAL_ATTACK)
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpAtk3",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:SPECIAL_ATTACK)
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpDef1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:SPECIAL_DEFENSE)
      score += 40 if user.turnCount == 0
      score -= user.stages[:SPECIAL_DEFENSE] * 20
    else
      score += 10 if user.turnCount == 0
      score += 20 if user.stages[:SPECIAL_DEFENSE] < 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpDef1",
                                           "RaiseUserSpDef2",
                                           "RaiseUserSpDef3")

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
      if user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= user.stages[:SPECIAL_DEFENSE] * 20
      end
    elsif user.stages[:SPECIAL_DEFENSE] < 0
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpeed1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:SPEED)
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpeed2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:SPEED)
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

Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpeed2",
                                           "RaiseUserSpeed2LowerUserWeight",
                                           "RaiseUserSpeed3")

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAccuracy1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:ACCURACY)
      score += 40 if user.turnCount == 0
      score -= user.stages[:ACCURACY] * 20
    else
      score += 10 if user.turnCount == 0
      score += 20 if user.stages[:ACCURACY] < 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAccuracy1",
                                           "RaiseUserAccuracy2",
                                           "RaiseUserAccuracy3")

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserEvasion1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:EVASION)
      score -= user.stages[:EVASION] * 10
    elsif user.stages[:EVASION] < 0
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserEvasion2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.statStageAtMax?(:EVASION)
      score += 40 if user.turnCount == 0
      score -= user.stages[:EVASION] * 10
    else
      score += 10 if user.turnCount == 0
      score += 20 if user.stages[:EVASION] < 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserEvasion2",
                                           "RaiseUserEvasion2MinimizeUser",
                                           "RaiseUserEvasion3")

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserCriticalHitRate2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if user.effects[PBEffects::FocusEnergy] >= 2
      next score + 30
    elsif user.effects[PBEffects::FocusEnergy] < 2
      next score + 30
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkDef1",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if user.statStageAtMax?(:ATTACK) &&
                       user.statStageAtMax?(:DEFENSE)
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkDefAcc1",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if user.statStageAtMax?(:ATTACK) &&
                       user.statStageAtMax?(:DEFENSE) &&
                       user.statStageAtMax?(:ACCURACY)
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkDefAcc1",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if user.statStageAtMax?(:ATTACK) &&
                       user.statStageAtMax?(:SPECIAL_ATTACK)
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
    if move.function == "RaiseUserAtkSpAtk1Or2InSun"   # Growth
      score += 20 if [:Sun, :HarshSun].include?(user.battler.effectiveWeather)
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserAtkSpAtk1",
                                           "RaiseUserAtkSpAtk1Or2InSun")

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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkSpd1",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if user.statStageAtMax?(:ATTACK) &&
                       user.statStageAtMax?(:SPEED)
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtk1Spd2",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if user.statStageAtMax?(:ATTACK) &&
                       user.statStageAtMax?(:SPEED)
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAtkAcc1",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if user.statStageAtMax?(:ATTACK) &&
                       user.statStageAtMax?(:ACCURACY)
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserDefSpDef1",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if user.statStageAtMax?(:DEFENSE) &&
                       user.statStageAtMax?(:SPECIAL_DEFENSE)
    score -= user.stages[:DEFENSE] * 10
    score -= user.stages[:SPECIAL_DEFENSE] * 10
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpAtkSpDef1",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if user.statStageAtMax?(:SPECIAL_ATTACK) &&
                       user.statStageAtMax?(:SPECIAL_DEFENSE)
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpAtkSpDefSpd1",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if user.statStageAtMax?(:SPECIAL_ATTACK) &&
                       user.statStageAtMax?(:SPECIAL_DEFENSE) &&
                       user.statStageAtMax?(:SPEED)
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

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserMainStats1LoseThirdOfTotalHP",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.hp <= user.totalhp / 2
    next 0 if user.has_active_ability?(:CONTRARY)
    stats_maxed = true
    GameData::Stat.each_main_battle do |s|
      next if user.statStageAtMax?(s.id)
      stats_maxed = false
      break
    end
    next 0 if stats_maxed
    score += 30 if ai.trainer.high_skill? && user.hp >= user.totalhp * 0.75
    GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] <= 0 }
    if ai.trainer.medium_skill?
      hasDamagingAttack = user.battler.moves.any? { |m| next m&.damagingMove? }
      score += 20 if hasDamagingAttack
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserMainStats1TrapUserInBattle",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.effects[PBEffects::NoRetreat]
    next 0 if user.has_active_ability?(:CONTRARY)
    stats_maxed = true
    GameData::Stat.each_main_battle do |s|
      next if user.statStageAtMax?(s.id)
      stats_maxed = false
      break
    end
    next 0 if stats_maxed
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

Battle::AI::Handlers::MoveEffectScore.add("StartRaiseUserAtk1WhenDamaged",
  proc { |score, move, user, target, ai, battle|
    next score + 25 if user.effects[PBEffects::Rage]
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerUserAttack1",
  proc { |score, move, user, target, ai, battle|
    next score + user.stages[:ATTACK] * 10
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("LowerUserAttack1",
                                           "LowerUserAttack2")

Battle::AI::Handlers::MoveEffectScore.add("LowerUserDefense1",
  proc { |score, move, user, target, ai, battle|
    next score + user.stages[:DEFENSE] * 10
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("LowerUserDefense1",
                                           "LowerUserDefense2")

Battle::AI::Handlers::MoveEffectScore.add("LowerUserSpAtk1",
  proc { |score, move, user, target, ai, battle|
    next score + user.stages[:SPECIAL_ATTACK] * 10
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("LowerUserSpAtk1",
                                           "LowerUserSpAtk2")

Battle::AI::Handlers::MoveEffectScore.add("LowerUserSpDef1",
  proc { |score, move, user, target, ai, battle|
    next score + user.stages[:SPECIAL_DEFENSE] * 10
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("LowerUserSpDef1",
                                           "LowerUserSpDef2")

Battle::AI::Handlers::MoveEffectScore.add("LowerUserSpeed1",
  proc { |score, move, user, target, ai, battle|
    next score + user.stages[:SPECIAL_DEFENSE] * 10
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("LowerUserSpeed1",
                                           "LowerUserSpeed2")

Battle::AI::Handlers::MoveEffectScore.add("LowerUserAtkDef1",
  proc { |score, move, user, target, ai, battle|
    avg =  user.stages[:ATTACK] * 10
    avg += user.stages[:DEFENSE] * 10
    next score + avg / 2
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerUserDefSpDef1",
  proc { |score, move, user, target, ai, battle|
    avg =  user.stages[:DEFENSE] * 10
    avg += user.stages[:SPECIAL_DEFENSE] * 10
    next score + avg / 2
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerUserDefSpDefSpd1",
  proc { |score, move, user, target, ai, battle|
    avg =  user.stages[:DEFENSE] * 10
    avg += user.stages[:SPEED] * 10
    avg += user.stages[:SPECIAL_DEFENSE] * 10
    next score + (avg / 3).floor
  }
)

# RaiseTargetAttack1

Battle::AI::Handlers::MoveEffectScore.add("RaiseTargetAttack2ConfuseTarget",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if !target.battler.pbCanConfuse?(user.battler, false)
    next score + 30 if target.stages[:ATTACK] < 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseTargetSpAtk1ConfuseTarget",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if !target.battler.pbCanConfuse?(user.battler, false)
    next score + 30 if target.stages[:SPECIAL_ATTACK] < 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseTargetSpDef1",
  proc { |score, move, user, target, ai, battle|
    next score + 30 if target.statStageAtMax?(:SPECIAL_DEFENSE)
    next score - target.stages[:SPECIAL_DEFENSE] * 10
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseTargetRandomStat2",
  proc { |score, move, user, target, ai, battle|
    avgStat = 0
    canChangeStat = false
    GameData::Stat.each_battle do |s|
      next if target.statStageAtMax?(s.id)
      avgStat -= target.stages[s.id]
      canChangeStat = true
    end
    if canChangeStat
      avgStat = avgStat / 2 if avgStat < 0   # More chance of getting even better
      next + avgStat * 10
    else
      next score - 90
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseTargetAtkSpAtk2",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.opposes?(user)
    next score - 90 if target.has_active_ability?(:CONTRARY)
    score -= target.stages[:ATTACK] * 20
    score -= target.stages[:SPECIAL_ATTACK] * 20
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAttack1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:ATTACK, user.battler)
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

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAttack1BypassSubstitute",
  proc { |score, move, user, target, ai, battle|
    next 0 if !target.battler.pbCanLowerStatStage?(:ATTACK, user.battler)
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

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAttack2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:ATTACK, user.battler)
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

Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetAttack2",
                                           "LowerTargetAttack3")

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetDefense1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:DEFENSE, user.battler)
      score += target.stages[:DEFENSE] * 20
    elsif target.stages[:DEFENSE] > 0
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveBasePower.add("LowerTargetDefense1PowersUpInGravity",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
}
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetDefense1PowersUpInGravity",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:DEFENSE, user.battler)
      score += target.stages[:DEFENSE] * 20
    elsif target.stages[:DEFENSE] > 0
      score += 20
    end
    score += 30 if battle.field.effects[PBEffects::Gravity] > 0
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetDefense2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:DEFENSE, user.battler)
      score += 40 if user.turnCount == 0
      score += target.stages[:DEFENSE] * 20
    else
      score += 10 if user.turnCount == 0
      score += 20 if target.stages[:DEFENSE] > 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetDefense2",
                                           "LowerTargetDefense3")

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpAtk1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:SPECIAL_ATTACK, user.battler)
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

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpAtk2",
  proc { |score, move, user, target, ai, battle|
    next 0 if !target.battler.pbCanLowerStatStage?(:SPECIAL_ATTACK, user.battler)
    score += 40 if user.turnCount == 0
    score += target.stages[:SPECIAL_ATTACK] * 20
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpAtk2IfCanAttract",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.gender == 2 || target.gender == 2 ||
              user.gender == target.gender || target.has_active_ability?(:OBLIVIOUS)
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:SPECIAL_ATTACK, user.battler)
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

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpAtk2",
  proc { |score, move, user, target, ai, battle|
    next 0 if !target.battler.pbCanLowerStatStage?(:SPECIAL_ATTACK, user.battler)
    score += 40 if user.turnCount == 0
    score += target.stages[:SPECIAL_ATTACK] * 20
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpDef1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user.battler)
      score += target.stages[:SPECIAL_DEFENSE] * 20
    elsif target.stages[:SPECIAL_DEFENSE] > 0
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpDef2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user.battler)
      score += 40 if user.turnCount == 0
      score += target.stages[:SPECIAL_DEFENSE] * 20
    else
      score += 10 if user.turnCount == 0
      score += 20 if target.stages[:SPECIAL_DEFENSE] > 0
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetSpDef2",
                                           "LowerTargetSpDef3")

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpeed1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:SPEED, user.battler)
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

Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetSpeed1",
                                           "LowerTargetSpeed1WeakerInGrassyTerrain")

Battle::AI::Handlers::MoveBasePower.add("LowerTargetSpeed1WeakerInGrassyTerrain",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
}

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpeed1MakeTargetWeakerToFire",
  proc { |score, move, user, target, ai, battle|
    next 0 if !target.battler.pbCanLowerStatStage?(:SPEED, user.battler) &&
              target.effects[PBEffects::TarShot]
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

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetSpeed2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:SPEED, user.battler)
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

Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetSpeed2",
                                           "LowerTargetSpeed3")

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAccuracy1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      return 0 if !target.battler.pbCanLowerStatStage?(:ACCURACY, user.battler)
      score += target.stages[:ACCURACY] * 10
    elsif target.stages[:ACCURACY] > 0
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetAccuracy1",
                                           "LowerTargetAccuracy2",
                                           "LowerTargetAccuracy3")

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetEvasion1",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      return 0 if !target.battler.pbCanLowerStatStage?(:EVASION, user.battler)
      score += target.stages[:EVASION] * 10
    elsif target.stages[:EVASION] > 0
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetEvasion1RemoveSideEffects",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      next 0 if !target.battler.pbCanLowerStatStage?(:EVASION, user.battler)
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

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetEvasion2",
  proc { |score, move, user, target, ai, battle|
    if move.statusMove?
      return 0 if !target.battler.pbCanLowerStatStage?(:EVASION, user.battler)
      score += target.stages[:EVASION] * 10
    elsif target.stages[:EVASION] > 0
      score += 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("LowerTargetEvasion2",
                                           "LowerTargetEvasion3")

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAtkDef1",
  proc { |score, move, user, target, ai, battle|
    avg =  target.stages[:ATTACK] * 10
    avg += target.stages[:DEFENSE] * 10
    next score + avg / 2
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAtkSpAtk1",
  proc { |score, move, user, target, ai, battle|
    avg =  target.stages[:ATTACK] * 10
    avg += target.stages[:SPECIAL_ATTACK] * 10
    next score + avg / 2
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerPoisonedTargetAtkSpAtkSpd1",
  proc { |score, move, user, target, ai, battle|
    count = 0
    battle.allBattlers.each do |b|
      if b.poisoned? &&
         (!b.statStageAtMin?(:ATTACK) ||
         !b.statStageAtMin?(:SPECIAL_ATTACK) ||
         !b.statStageAtMin?(:SPEED))
        count += 1
        if user.battler.opposes?(b)
          score += user.stages[:ATTACK] * 10
          score += user.stages[:SPECIAL_ATTACK] * 10
          score += user.stages[:SPEED] * 10
        else
          score -= 20
        end
      end
    end
    next 0 if count == 0
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserAndAlliesAtkDef1",
  proc { |score, move, user, target, ai, battle|
    has_ally = false
    user.battler.allAllies.each do |b|
      next if !b.pbCanLowerStatStage?(:ATTACK, user.battler) &&
              !b.pbCanLowerStatStage?(:SPECIAL_ATTACK, user.battler)
      has_ally = true
      if b.hasActiveAbility?(:CONTRARY)
        score -= 90
      else
        score += 40
        score -= b.stages[:ATTACK] * 20
        score -= b.stages[:SPECIAL_ATTACK] * 20
      end
    end
    next 0 if !has_ally
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaisePlusMinusUserAndAlliesAtkSpAtk1",
  proc { |score, move, user, target, ai, battle|
    hasEffect = user.statStageAtMax?(:ATTACK) &&
                user.statStageAtMax?(:SPECIAL_ATTACK)
    user.battler.allAllies.each do |b|
      next if b.statStageAtMax?(:ATTACK) && b.statStageAtMax?(:SPECIAL_ATTACK)
      hasEffect = true
      score -= b.stages[:ATTACK] * 10
      score -= b.stages[:SPECIAL_ATTACK] * 10
    end
    next 0 if !hasEffect
    score -= user.stages[:ATTACK] * 10
    score -= user.stages[:SPECIAL_ATTACK] * 10
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaisePlusMinusUserAndAlliesDefSpDef1",
  proc { |score, move, user, target, ai, battle|
    hasEffect = user.statStageAtMax?(:DEFENSE) &&
                user.statStageAtMax?(:SPECIAL_DEFENSE)
    user.battler.allAllies.each do |b|
      next if b.statStageAtMax?(:DEFENSE) && b.statStageAtMax?(:SPECIAL_DEFENSE)
      hasEffect = true
      score -= b.stages[:DEFENSE] * 10
      score -= b.stages[:SPECIAL_DEFENSE] * 10
    end
    next 0 if !hasEffect
    score -= user.stages[:DEFENSE] * 10
    score -= user.stages[:SPECIAL_DEFENSE] * 10
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseGroundedGrassBattlersAtkSpAtk1",
  proc { |score, move, user, target, ai, battle|
    count = 0
    battle.allBattlers.each do |b|
      next if !b.pbHasType?(:GRASS)
      next if b.airborne?
      next if b.statStageAtMax?(:ATTACK) && b.statStageAtMax?(:SPECIAL_ATTACK)
      count += 1
      if user.battler.opposes?(b)
        score -= 20
      else
        score -= user.stages[:ATTACK] * 10
        score -= user.stages[:SPECIAL_ATTACK] * 10
      end
    end
    next 0 if count == 0
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseGrassBattlersDef1",
  proc { |score, move, user, target, ai, battle|
    count = 0
    battle.allBattlers.each do |b|
      if b.pbHasType?(:GRASS) && !b.statStageAtMax?(:DEFENSE)
        count += 1
        if user.battler.opposes?(b)
          score -= 20
        else
          score -= user.stages[:DEFENSE] * 10
        end
      end
    end
    next 0 if count == 0
    next score
  }
)

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

# TODO: Account for stat theft before damage calculation.
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

Battle::AI::Handlers::MoveEffectScore.add("InvertTargetStatStages",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.effects[PBEffects::Substitute] > 0
    numpos = 0
    numneg = 0
    GameData::Stat.each_battle do |s|
      numpos += target.stages[s.id] if target.stages[s.id] > 0
      numneg += target.stages[s.id] if target.stages[s.id] < 0
    end
    next 0 if numpos == 0 && numneg == 0
    next score + (numpos - numneg) * 10
  }
)

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

Battle::AI::Handlers::MoveEffectScore.add("StartUserSideImmunityToStatStageLowering",
  proc { |score, move, user, target, ai, battle|
    next score - 80 if user.pbOwnSide.effects[PBEffects::Mist] > 0
  }
)

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

Battle::AI::Handlers::MoveEffectScore.add("StartUserSideDoubleSpeed",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if user.pbOwnSide.effects[PBEffects::Tailwind] > 0
  }
)

# StartSwapAllBattlersBaseDefensiveStats
