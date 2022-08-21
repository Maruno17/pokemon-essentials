#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("FleeFromBattle",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if battle.trainerBattle?
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SwitchOutUserStatusMove",
  proc { |score, move, user, target, skill, ai, battle|
    if !battle.pbCanChooseNonActive?(user.index) ||
       battle.pbTeamAbleNonActiveCount(user.index) > 1   # Don't switch in ace
      score -= 100
    else
      score += 40 if user.effects[PBEffects::Confusion] > 0
      total = 0
      GameData::Stat.each_battle { |s| total += user.stages[s.id] }
      if total <= 0 || user.turnCount == 0
        score += 60
      else
        score -= total * 10
        # special case: user has no damaging moves
        hasDamagingMove = false
        user.eachMove do |m|
          next if !m.damagingMove?
          hasDamagingMove = true
          break
        end
        score += 75 if !hasDamagingMove
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SwitchOutUserDamagingMove",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !battle.pbCanChooseNonActive?(user.index) ||
              battle.pbTeamAbleNonActiveCount(user.index) > 1   # Don't switch in ace
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAtkSpAtk1SwitchOutUser",
  proc { |score, move, user, target, skill, ai, battle|
    avg  = target.stages[:ATTACK] * 10
    avg += target.stages[:SPECIAL_ATTACK] * 10
    score += avg / 2
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SwitchOutUserPassOnEffects",
  proc { |score, move, user, target, skill, ai, battle|
    if battle.pbCanChooseNonActive?(user.index)
      score -= 40 if user.effects[PBEffects::Confusion] > 0
      total = 0
      GameData::Stat.each_battle { |s| total += user.stages[s.id] }
      if total <= 0 || user.turnCount == 0
        score -= 60
      else
        score += total * 10
        # special case: user has no damaging moves
        hasDamagingMove = false
        user.eachMove do |m|
          next if !m.damagingMove?
          hasDamagingMove = true
          break
        end
        score += 75 if !hasDamagingMove
      end
    else
      score -= 100
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SwitchOutTargetStatusMove",
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::Ingrain] ||
       (ai.skill_check(Battle::AI::AILevel.high) && target.hasActiveAbility?(:SUCTIONCUPS))
      score -= 90
    else
      ch = 0
      battle.pbParty(target.index).each_with_index do |pkmn, i|
        ch += 1 if battle.pbCanSwitchLax?(target.index, i)
      end
      score -= 90 if ch == 0
    end
    if score > 20
      score += 50 if target.pbOwnSide.effects[PBEffects::Spikes] > 0
      score += 50 if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
      score += 50 if target.pbOwnSide.effects[PBEffects::StealthRock]
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SwitchOutTargetDamagingMove",
  proc { |score, move, user, target, skill, ai, battle|
    if !target.effects[PBEffects::Ingrain] &&
       !(ai.skill_check(Battle::AI::AILevel.high) && target.hasActiveAbility?(:SUCTIONCUPS))
      score += 40 if target.pbOwnSide.effects[PBEffects::Spikes] > 0
      score += 40 if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
      score += 40 if target.pbOwnSide.effects[PBEffects::StealthRock]
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("BindTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 40 if target.effects[PBEffects::Trapping] == 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("BindTargetDoublePowerIfTargetUnderwater",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 40 if target.effects[PBEffects::Trapping] == 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TrapTargetInBattle",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::MeanLook] >= 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TrapTargetInBattleLowerTargetDefSpDef1EachTurn",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::Octolock] >= 0
    score += 30 if !target.trappedInBattle?
    score -= 100 if !target.pbCanLowerStatStage?(:DEFENSE, user, move) &&
                    !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user, move)
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TrapUserAndTargetInBattle",
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::JawLock] < 0
      score += 40 if !user.trappedInBattle? && !target.trappedInBattle?
    end
    next score
  }
)

# TrapAllBattlersInBattleForOneTurn

# PursueSwitchingFoe

Battle::AI::Handlers::MoveEffectScore.add("UsedAfterUserTakesPhysicalDamage",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.medium)
      hasPhysicalAttack = false
      target.eachMove do |m|
        next if !m.physicalMove?(m.type)
        hasPhysicalAttack = true
        break
      end
      score -= 80 if !hasPhysicalAttack
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UsedAfterAllyRoundWithDoublePower",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.medium)
      user.allAllies.each do |b|
        next if !b.pbHasMove?(move.id)
        score += 20
      end
    end
    next score
  }
)

# TargetActsNext

# TargetActsLast

Battle::AI::Handlers::MoveEffectScore.add("TargetUsesItsLastUsedMoveAgain",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.medium)
      if !target.lastRegularMoveUsed ||
         !target.pbHasMove?(target.lastRegularMoveUsed) ||
         target.usingMultiTurnAttack?
        score -= 90
      else
        # Without lots of code here to determine good/bad moves and relative
        # speeds, using this move is likely to just be a waste of a turn
        score -= 50
      end
    end
    next score
  }
)

# StartSlowerBattlersActFirst

Battle::AI::Handlers::MoveEffectScore.add("HigherPriorityInGrassyTerrain",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.medium) && @battle.field.terrain == :Grassy
      aspeed = pbRoughStat(user, :SPEED)
      ospeed = pbRoughStat(target, :SPEED)
      score += 40 if aspeed < ospeed
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerPPOfTargetLastMoveBy3",
  proc { |score, move, user, target, skill, ai, battle|
    last_move = target.pbGetMoveWithID(target.lastRegularMoveUsed)
    if last_move && last_move.total_pp > 0 && last_move.pp <= 3
      score += 50
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerPPOfTargetLastMoveBy4",
  proc { |score, move, user, target, skill, ai, battle|
    next score - 40
  }
)

Battle::AI::Handlers::MoveEffectScore.add("DisableTargetLastMoveUsed",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::Disable] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("DisableTargetUsingSameMoveConsecutively",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::Torment]
  }
)

Battle::AI::Handlers::MoveEffectScore.add("DisableTargetUsingDifferentMove",
  proc { |score, move, user, target, skill, ai, battle|
    aspeed = pbRoughStat(user, :SPEED)
    ospeed = pbRoughStat(target, :SPEED)
    if target.effects[PBEffects::Encore] > 0
      score -= 90
    elsif aspeed > ospeed
      if target.lastRegularMoveUsed
        moveData = GameData::Move.get(target.lastRegularMoveUsed)
        if moveData.category == 2 &&   # Status move
           [:User, :BothSides].include?(moveData.target)
          score += 60
        elsif moveData.category != 2 &&   # Damaging move
              moveData.target == :NearOther &&
              Effectiveness.ineffective?(pbCalcTypeMod(moveData.type, target, user))
          score += 60
        end
      else
        score -= 90
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("DisableTargetStatusMoves",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::Taunt] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("DisableTargetHealingMoves",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::HealBlock] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("DisableTargetSoundMoves",
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::ThroatChop] == 0 && ai.skill_check(Battle::AI::AILevel.high)
      hasSoundMove = false
      user.eachMove do |m|
        next if !m.soundMove?
        hasSoundMove = true
        break
      end
      score += 40 if hasSoundMove
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("DisableTargetMovesKnownByUser",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::Imprison]
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AllBattlersLoseHalfHPUserSkipsNextTurn",
  proc { |score, move, user, target, skill, ai, battle|
    score += 20   # Shadow moves are more preferable
    score += 20 if target.hp >= target.totalhp / 2
    score -= 20 if user.hp < user.hp / 2
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AllBattlersLoseHalfHPUserSkipsNextTurn",
  proc { |score, move, user, target, skill, ai, battle|
    score += 20   # Shadow moves are more preferable
    score -= 40
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartShadowSkyWeather",
  proc { |score, move, user, target, skill, ai, battle|
    score += 20   # Shadow moves are more preferable
    if battle.pbCheckGlobalAbility(:AIRLOCK) ||
       battle.pbCheckGlobalAbility(:CLOUDNINE)
      score -= 90
    elsif battle.field.weather == :ShadowSky
      score -= 90
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RemoveAllScreens",
  proc { |score, move, user, target, skill, ai, battle|
    score += 20   # Shadow moves are more preferable
    if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 ||
       target.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
       target.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
       target.pbOwnSide.effects[PBEffects::Safeguard] > 0
      score += 30
      score -= 90 if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 ||
                     user.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
                     user.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
                     user.pbOwnSide.effects[PBEffects::Safeguard] > 0
    else
      next 0
    end
    next score
  }
)
