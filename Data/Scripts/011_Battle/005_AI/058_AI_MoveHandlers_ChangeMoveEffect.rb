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

Battle::AI::Handlers::MoveBasePower.add("RandomlyDamageOrHealTarget",
  proc { |power, move, user, target, ai, battle|
    next 50   # Average power, ish
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("HealAllyOrDamageFoe",
  proc { |move, user, target, ai, battle|
    next true if !target.opposes?(user) && target.battler.canHeal?
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealAllyOrDamageFoe",
  proc { |score, move, user, target, ai, battle|
    if !target.opposes?(user)
      score += 50
      score -= target.hp * 100 / target.totalhp
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
  proc { |move, user, target, ai, battle|
    if user.has_type?(:GHOST)
      next true if target.effects[PBEffects::Curse]
    else
      next true if !user.battler.pbCanLowerStatStage?(:SPEED, user.battler, move.move) &&
                   !user.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
                   !user.battler.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move)
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
  proc { |score, move, user, target, ai, battle|
    if user.has_type?(:GHOST)
      if user.hp <= user.totalhp / 2
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

Battle::AI::Handlers::MoveBasePower.add("HitsAllFoesAndPowersUpInPsychicTerrain",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HitsAllFoesAndPowersUpInPsychicTerrain",
  proc { |score, move, user, target, ai, battle|
    next score + 40 if battle.field.terrain == :Psychic && user.battler.affectedByTerrain?
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("TargetNextFireMoveDamagesTarget",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Powder]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("TargetNextFireMoveDamagesTarget",
  proc { |score, move, user, target, ai, battle|
    aspeed = user.rough_stat(:SPEED)
    ospeed = target.rough_stat(:SPEED)
    if aspeed > ospeed
      score -= 50
    elsif target.battler.pbHasMoveType?(:FIRE)
      score += 30
    end
    next score
  }
)

# DoublePowerAfterFusionFlare

# DoublePowerAfterFusionBolt

Battle::AI::Handlers::MoveFailureCheck.add("PowerUpAllyMove",
  proc { |move, user, target, ai, battle|
    next true if target.fainted? || target.effects[PBEffects::HelpingHand]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("PowerUpAllyMove",
  proc { |score, move, user, target, ai, battle|
    next score - 60 if user.battler.allAllies.empty?
    next score + 30
  }
)

Battle::AI::Handlers::MoveBasePower.add("CounterPhysicalDamage",
  proc { |power, move, user, target, ai, battle|
    next 60   # Representative value
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

Battle::AI::Handlers::MoveBasePower.add("CounterSpecialDamage",
  proc { |power, move, user, target, ai, battle|
    next 60   # Representative value
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

Battle::AI::Handlers::MoveBasePower.add("CounterDamagePlusHalf",
  proc { |power, move, user, target, ai, battle|
    next 60   # Representative value
  }
)
Battle::AI::Handlers::MoveEffectScore.add("CounterDamagePlusHalf",
  proc { |score, move, user, target, ai, battle|
    next score - 90 if target.effects[PBEffects::HyperBeam] > 0
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("UserAddStockpileRaiseDefSpDef1",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::Stockpile] >= 3
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserAddStockpileRaiseDefSpDef1",
  proc { |score, move, user, target, ai, battle|
    avg = 0
    avg -= user.stages[:DEFENSE] * 10
    avg -= user.stages[:SPECIAL_DEFENSE] * 10
    score += avg / 2
    if user.battler.pbHasMoveFunction?("PowerDependsOnUserStockpile",
                                          "HealUserDependingOnUserStockpile")   # Spit Up, Swallow
      score += 20   # More preferable if user also has Spit Up/Swallow
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("PowerDependsOnUserStockpile",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::Stockpile] == 0
  }
)
Battle::AI::Handlers::MoveBasePower.add("PowerDependsOnUserStockpile",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("HealUserDependingOnUserStockpile",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::Stockpile] == 0
    next true if !user.battler.canHeal? &&
                 user.effects[PBEffects::StockpileDef] == 0 &&
                 user.effects[PBEffects::StockpileSpDef] == 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HealUserDependingOnUserStockpile",
  proc { |score, move, user, target, ai, battle|
    mult = [0, 25, 50, 100][user.effects[PBEffects::Stockpile]]
    score += mult
    score -= user.hp * mult * 2 / user.totalhp
    next score
  }
)

# GrassPledge

# FirePledge

# WaterPledge

Battle::AI::Handlers::MoveFailureCheck.add("UseLastMoveUsed",
  proc { |move, user, target, ai, battle|
    next true if !battle.lastMoveUsed
    next true if move.move.moveBlacklist.include?(GameData::Move.get(battle.lastMoveUsed).function_code)
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("UseLastMoveUsedByTarget",
  proc { |move, user, target, ai, battle|
    next true if !target.battle.lastRegularMoveUsed
    next true if GameData::Move.get(target.battle.lastRegularMoveUsed).flags.none? { |f| f[/^CanMirrorMove$/i] }
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UseLastMoveUsedByTarget",
  proc { |score, move, user, target, ai, battle|
    next score - 40
  }
)

# UseMoveTargetIsAboutToUse

# UseMoveDependingOnEnvironment

# UseRandomMove

Battle::AI::Handlers::MoveFailureCheck.add("UseRandomMoveFromUserParty",
  proc { |move, user, target, ai, battle|
    will_fail = true
    battle.pbParty(user.index).each_with_index do |pkmn, i|
      next if !pkmn || i == user.party_index
      next if Settings::MECHANICS_GENERATION >= 6 && pkmn.egg?
      pkmn.moves.each do |pkmn_move|
        next if move.move.moveBlacklist.include?(pkmn_move.function_code)
        next if pkmn_move.type == :SHADOW
        will_fail = false
        break
      end
      break if !will_fail
    end
    next will_fail
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("UseRandomUserMoveIfAsleep",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.asleep?
    will_fail = true
    user.battler.eachMoveWithIndex do |m, i|
      next if move.move.moveBlacklist.include?(m.function)
      next if !battle.pbCanChooseMove?(user.index, i, false, true)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UseRandomUserMoveIfAsleep",
  proc { |score, move, user, target, ai, battle|
    next score + 50 if user.battler.asleep?   # Because it can only be used while asleep
  }
)

# BounceBackProblemCausingStatusMoves

# StealAndUseBeneficialStatusMove

Battle::AI::Handlers::MoveFailureCheck.add("ReplaceMoveThisBattleWithTargetLastMoveUsed",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::Transform] || user.battler.pbHasMove?(move.id)
    last_move_data = GameData::Move.try_get(target.battler.lastRegularMoveUsed)
    next true if !last_move_data ||
                 user.battler.pbHasMove?(target.battler.lastRegularMoveUsed) ||
                 move.move.moveBlacklist.include?(last_move_data.function_code) ||
                 last_move_data.type == :SHADOW
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("ReplaceMoveWithTargetLastMoveUsed",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::Transform] || !user.battler.pbHasMove?(move.id)
    last_move_data = GameData::Move.try_get(target.battler.lastRegularMoveUsed)
    next true if !last_move_data ||
                 user.battler.pbHasMove?(target.battler.lastRegularMoveUsed) ||
                 move.move.moveBlacklist.include?(last_move_data.function_code) ||
                 last_move_data.type == :SHADOW
  }
)
