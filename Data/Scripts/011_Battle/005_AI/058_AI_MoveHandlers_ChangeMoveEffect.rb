#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("RedirectAllMovesToUser",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.battler.allAllies.length == 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RedirectAllMovesToTarget",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.battler.allAllies.length == 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CannotBeRedirected",
  proc { |score, move, user, target, ai, battle|
    redirection = false
    user.battler.allOpposing.each do |b|
      next if b.index == target.index
      if b.effects[PBEffects::RagePowder] ||
         b.effects[PBEffects::Spotlight] > 0 ||
         b.effects[PBEffects::FollowMe] > 0 ||
         (b.hasActiveAbility?(:LIGHTNINGROD) && move.pbCalcType == :ELECTRIC) ||
         (b.hasActiveAbility?(:STORMDRAIN) && move.pbCalcType == :WATER)
        redirection = true
        break
      end
    end
    score += 50 if redirection && ai.trainer.medium_skill?
    next score
  }
)

# RandomlyDamageOrHealTarget

Battle::AI::Handlers::MoveEffectScore.add("HealAllyOrDamageFoe",
  proc { |score, move, user, target, ai, battle|
    if !target.opposes?(user)
      if target.hp == target.totalhp || (ai.trainer.medium_skill? && !target.battler.canHeal?)
        score -= 90
      else
        score += 50
        score -= target.hp * 100 / target.totalhp
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
  proc { |score, move, user, target, ai, battle|
    if user.has_type?(:GHOST)
      if target.effects[PBEffects::Curse]
        score -= 90
      elsif user.hp <= user.totalhp / 2
        if battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
          score -= 90
        else
          score -= 50
          score -= 30 if battle.switchStyle
        end
      end
    else
      avg  = user.stages[:SPEED] * 10
      avg -= user.stages[:ATTACK] * 10
      avg -= user.stages[:DEFENSE] * 10
      score += avg / 3
    end
    next score
  }
)

# EffectDependsOnEnvironment

Battle::AI::Handlers::MoveEffectScore.add("HitsAllFoesAndPowersUpInPsychicTerrain",
  proc { |score, move, user, target, ai, battle|
    next score + 40 if battle.field.terrain == :Psychic && user.battler.affectedByTerrain?
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TargetNextFireMoveDamagesTarget",
  proc { |score, move, user, target, ai, battle|
    aspeed = user.rough_stat(:SPEED)
    ospeed = target.rough_stat(:SPEED)
    if aspeed > ospeed
      score -= 90
    elsif target.battler.pbHasMoveType?(:FIRE)
      score += 30
    end
    next score
  }
)

# DoublePowerAfterFusionFlare

# DoublePowerAfterFusionBolt

Battle::AI::Handlers::MoveEffectScore.add("PowerUpAllyMove",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.battler.allAllies.empty?
    next score + 30
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CounterPhysicalDamage",
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::HyperBeam] > 0
      score -= 90
    else
      attack = user.rough_stat(:ATTACK)
      spatk  = user.rough_stat(:SPECIAL_ATTACK)
      if attack * 1.5 < spatk
        score -= 60
      elsif ai.trainer.medium_skill? && target.battler.lastMoveUsed
        moveData = GameData::Move.get(target.battler.lastMoveUsed)
        score += 60 if moveData.physical?
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CounterSpecialDamage",
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::HyperBeam] > 0
      score -= 90
    else
      attack = user.rough_stat(:ATTACK)
      spatk  = user.rough_stat(:SPECIAL_ATTACK)
      if attack > spatk * 1.5
        score -= 60
      elsif ai.trainer.medium_skill? && target.battler.lastMoveUsed
        moveData = GameData::Move.get(target.battler.lastMoveUsed)
        score += 60 if moveData.special?
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CounterDamagePlusHalf",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if target.effects[PBEffects::HyperBeam] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserAddStockpileRaiseDefSpDef1",
  proc { |score, move, user, target, ai, battle|
    avg = 0
    avg -= user.stages[:DEFENSE] * 10
    avg -= user.stages[:SPECIAL_DEFENSE] * 10
    score += avg / 2
    if user.effects[PBEffects::Stockpile] >= 3
      score -= 80
    elsif user.battler.pbHasMoveFunction?("PowerDependsOnUserStockpile",
                                          "HealUserDependingOnUserStockpile")   # Spit Up, Swallow
      score += 20   # More preferable if user also has Spit Up/Swallow
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("PowerDependsOnUserStockpile",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.effects[PBEffects::Stockpile] == 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("HealUserDependingOnUserStockpile",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.effects[PBEffects::Stockpile] == 0
    next 0 if user.hp == user.totalhp
    mult = [0, 25, 50, 100][user.effects[PBEffects::Stockpile]]
    score += mult
    score -= user.hp * mult * 2 / user.totalhp
    next score
  }
)

# GrassPledge

# FirePledge

# WaterPledge

# UseLastMoveUsed

Battle::AI::Handlers::MoveEffectScore.add("UseLastMoveUsedByTarget",
  proc { |score, move, user, target, ai, battle|
    score -= 40
    if ai.trainer.high_skill?
      score -= 100 if !target.battler.lastRegularMoveUsed ||
                      GameData::Move.get(target.battler.lastRegularMoveUsed).flags.none? { |f| f[/^CanMirrorMove$/i] }
    end
    next score
  }
)

# UseMoveTargetIsAboutToUse

# UseMoveDependingOnEnvironment

# UseRandomMove

# UseRandomMoveFromUserParty

Battle::AI::Handlers::MoveEffectScore.add("UseRandomUserMoveIfAsleep",
  proc { |score, move, user, target, ai, battle|
    if user.battler.asleep?
      score += 100   # Because it can only be used while asleep
    else
      score -= 90
    end
    next score
  }
)

# BounceBackProblemCausingStatusMoves

# StealAndUseBeneficialStatusMove

Battle::AI::Handlers::MoveEffectScore.add("ReplaceMoveThisBattleWithTargetLastMoveUsed",
  proc { |score, move, user, target, ai, battle|
    moveBlacklist = [
      "Struggle",   # Struggle
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",   # Sketch
      "UseRandomMove"   # Metronome
    ]
    if user.effects[PBEffects::Transform] || !target.battler.lastRegularMoveUsed
      score -= 90
    else
      lastMoveData = GameData::Move.get(target.battler.lastRegularMoveUsed)
      if moveBlacklist.include?(lastMoveData.function_code) ||
         lastMoveData.type == :SHADOW
        score -= 90
      end
      user.battler.eachMove do |m|
        next if m != target.battler.lastRegularMoveUsed
        score -= 90
        break
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ReplaceMoveWithTargetLastMoveUsed",
  proc { |score, move, user, target, ai, battle|
    moveBlacklist = [
      "Struggle",   # Struggle
      "ReplaceMoveWithTargetLastMoveUsed"   # Sketch
    ]
    if user.effects[PBEffects::Transform] || !target.battler.lastRegularMoveUsed
      score -= 90
    else
      lastMoveData = GameData::Move.get(target.battler.lastRegularMoveUsed)
      if moveBlacklist.include?(lastMoveData.function_code) ||
         lastMoveData.type == :SHADOW
        score -= 90
      end
      user.battler.eachMove do |m|
        next if m != target.battler.lastRegularMoveUsed
        score -= 90   # User already knows the move that will be Sketched
        break
      end
    end
    next score
  }
)
