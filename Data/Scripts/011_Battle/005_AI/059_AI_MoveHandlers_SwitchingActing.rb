#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FleeFromBattle",
  proc { |move, user, target, ai, battle|
    next true if !battle.pbCanRun?(user.index)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("SwitchOutUserStatusMove",
  proc { |move, user, target, ai, battle|
    if user.wild?
      next true if !battle.pbCanRun?(user.index)
    else
      next true if !battle.pbCanChooseNonActive?(user.index)
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("SwitchOutUserStatusMove",
  proc { |score, move, user, target, ai, battle|
    next score + 10 if user.wild?
    if battle.pbTeamAbleNonActiveCount(user.index) > 1   # Don't switch in ace
      score -= 60
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
        user.battler.eachMove do |m|
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

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("SwitchOutUserDamagingMove",
  proc { |score, move, user, target, ai, battle|
    next 0 if !battle.pbCanChooseNonActive?(user.index) ||
              battle.pbTeamAbleNonActiveCount(user.index) > 1   # Don't switch in ace
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("LowerTargetAtkSpAtk1SwitchOutUser",
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
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetAtkSpAtk1SwitchOutUser",
  proc { |score, move, user, target, ai, battle|
    avg  = target.stages[:ATTACK] * 10
    avg += target.stages[:SPECIAL_ATTACK] * 10
    score += avg / 2
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("SwitchOutUserPassOnEffects",
  proc { |move, user, target, ai, battle|
    next true if !battle.pbCanChooseNonActive?(user.index)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("SwitchOutUserPassOnEffects",
  proc { |score, move, user, target, ai, battle|
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
        user.battler.eachMove do |m|
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

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("SwitchOutTargetStatusMove",
  proc { |move, user, target, ai, battle|
    next true if (!battle.moldBreaker && target.has_active_ability?(:SUCTIONCUPS)) ||
                 target.effects[PBEffects::Ingrain]
    next true if !battle.canRun
    next true if battle.wildBattle? && target.level > user.level
    if battle.trainerBattle?
      will_fail = true
      battle.eachInTeamFromBattlerIndex(target.index) do |_pkmn, i|
        next if !battle.pbCanSwitchLax?(target.index, i)
        will_fail = false
        break
      end
      next will_fail
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("SwitchOutTargetStatusMove",
  proc { |score, move, user, target, ai, battle|
    score += 20 if target.pbOwnSide.effects[PBEffects::Spikes] > 0
    score += 20 if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
    score += 20 if target.pbOwnSide.effects[PBEffects::StealthRock]
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("SwitchOutTargetDamagingMove",
  proc { |score, move, user, target, ai, battle|
    if (battle.moldBreaker || !target.has_active_ability?(:SUCTIONCUPS)) &&
       !target.effects[PBEffects::Ingrain]
      score += 20 if target.pbOwnSide.effects[PBEffects::Spikes] > 0
      score += 20 if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
      score += 20 if target.pbOwnSide.effects[PBEffects::StealthRock]
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("BindTarget",
  proc { |score, move, user, target, ai, battle|
    next score + 40 if target.effects[PBEffects::Trapping] == 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("BindTargetDoublePowerIfTargetUnderwater",
  proc { |power, move, user, target, ai, battle|
    next move.pbModifyDamage(power, user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("BindTargetDoublePowerIfTargetUnderwater",
  proc { |score, move, user, target, ai, battle|
    next score + 40 if target.effects[PBEffects::Trapping] == 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("TrapTargetInBattle",
  proc { |move, user, target, ai, battle|
    if move.statusMove?
      next true if target.effects[PBEffects::MeanLook] >= 0
      next true if Settings::MORE_TYPE_EFFECTS && target.has_type?(:GHOST)
    end
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("TrapTargetInBattle",
  proc { |move, user, target, ai, battle|
    if move.statusMove?
      next true if target.effects[PBEffects::Octolock] >= 0
      next true if Settings::MORE_TYPE_EFFECTS && target.has_type?(:GHOST)
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("TrapTargetInBattleLowerTargetDefSpDef1EachTurn",
  proc { |score, move, user, target, ai, battle|
    score += 30 if !target.battler.trappedInBattle?
    score -= 50 if !target.battler.pbCanLowerStatStage?(:DEFENSE, user.battler, move.move) &&
                   !target.battler.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user.battler, move.move)
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TrapUserAndTargetInBattle",
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::JawLock] < 0
      score += 40 if !user.battler.trappedInBattle? && !target.battler.trappedInBattle?
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("TrapAllBattlersInBattleForOneTurn",
  proc { |move, user, target, ai, battle|
    next true if battle.field.effects[PBEffects::FairyLock] > 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# PursueSwitchingFoe

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UsedAfterUserTakesPhysicalDamage",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      hasPhysicalAttack = false
      target.battler.eachMove do |m|
        next if !m.physicalMove?(m.type)
        hasPhysicalAttack = true
        break
      end
      score -= 50 if !hasPhysicalAttack
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UsedAfterAllyRoundWithDoublePower",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      user.battler.allAllies.each do |b|
        next if !b.pbHasMove?(move.id)
        score += 20
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TargetActsNext

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# TargetActsLast

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("TargetUsesItsLastUsedMoveAgain",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.lastRegularMoveUsed ||
                 !target.battler.pbHasMove?(target.battler.lastRegularMoveUsed)
    next true if target.usingMultiTurnAttack?
    next true if move.move.moveBlacklist.include?(GameData::Move.get(target.battler.lastRegularMoveUsed).function_code)
    idxMove = -1
    target.battler.eachMoveWithIndex do |m, i|
      idxMove = i if m.id == target.battler.lastRegularMoveUsed
    end
    next true if target.battler.moves[idxMove].pp == 0 && target.battler.moves[idxMove].total_pp > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("TargetUsesItsLastUsedMoveAgain",
  proc { |score, move, user, target, ai, battle|
    # Without lots of code here to determine good/bad moves and relative
    # speeds, using this move is likely to just be a waste of a turn
    next score - 50
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
# StartSlowerBattlersActFirst

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("HigherPriorityInGrassyTerrain",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && @battle.field.terrain == :Grassy
      score += 40 if target.faster_than?(user)
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("LowerPPOfTargetLastMoveBy3",
  proc { |score, move, user, target, ai, battle|
    last_move = target.battler.pbGetMoveWithID(target.battler.lastRegularMoveUsed)
    if last_move && last_move.total_pp > 0 && last_move.pp <= 3
      score += 50
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("LowerPPOfTargetLastMoveBy4",
  proc { |move, user, target, ai, battle|
    last_move = target.battler.pbGetMoveWithID(target.battler.lastRegularMoveUsed)
    next true if !last_move || last_move.pp == 0 || last_move.total_pp <= 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("LowerPPOfTargetLastMoveBy4",
  proc { |score, move, user, target, ai, battle|
    next score - 40
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("DisableTargetLastMoveUsed",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Disable] > 0 || !target.battler.lastRegularMoveUsed
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    will_fail = true
    target.battler.eachMove do |m|
      next if m.id != target.battler.lastRegularMoveUsed
      next if m.pp == 0 && m.total_pp > 0
      will_fail = false
      break
    end
    next will_fail
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("DisableTargetUsingSameMoveConsecutively",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Torment]
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("DisableTargetUsingSameMoveConsecutively",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.effects[PBEffects::Torment]
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("DisableTargetUsingDifferentMove",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Encore] > 0
    next true if !target.battler.lastRegularMoveUsed ||
                 move.move.moveBlacklist.include?(GameData::Move.get(target.battler.lastRegularMoveUsed).function_code)
    next true if target.effects[PBEffects::ShellTrap]
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    will_fail = true
    target.battler.eachMove do |m|
      next if m.id != target.battler.lastRegularMoveUsed
      next if m.pp == 0 && m.total_pp > 0
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("DisableTargetUsingDifferentMove",
  proc { |score, move, user, target, ai, battle|
    if user.faster_than?(target)
      moveData = GameData::Move.get(target.battler.lastRegularMoveUsed)
      if moveData.category == 2 &&   # Status move
         [:User, :BothSides].include?(moveData.target)
        score += 60
      elsif moveData.category != 2 &&   # Damaging move
            moveData.target == :NearOther &&
            Effectiveness.ineffective?(user.effectiveness_of_type_against_battler(moveData.type, target))
        score += 60
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("DisableTargetStatusMoves",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Taunt] > 0
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    next true if Settings::MECHANICS_GENERATION >= 6 &&
                 !battle.moldBreaker && target.has_active_ability?(:OBLIVIOUS)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("DisableTargetHealingMoves",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::HealBlock] > 0
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("DisableTargetSoundMoves",
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::ThroatChop] == 0 && ai.trainer.high_skill?
      hasSoundMove = false
      user.battler.eachMove do |m|
        next if !m.soundMove?
        hasSoundMove = true
        break
      end
      score += 40 if hasSoundMove
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("DisableTargetMovesKnownByUser",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::Imprison]
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AllBattlersLoseHalfHPUserSkipsNextTurn",
  proc { |move, user, target, ai, battle|
    next true if battle.allBattlers.none? { |b| b.hp > 1 }
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AllBattlersLoseHalfHPUserSkipsNextTurn",
  proc { |score, move, user, target, ai, battle|
    score += 20   # Shadow moves are more preferable
    score += 20 if target.hp >= target.totalhp / 2
    score -= 20 if user.hp < user.hp / 2
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserLosesHalfHP",
  proc { |score, move, user, target, ai, battle|
    score += 20   # Shadow moves are more preferable
    score -= 40
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("StartSunWeather",
                                            "StartShadowSkyWeather")
Battle::AI::Handlers::MoveEffectScore.add("StartShadowSkyWeather",
  proc { |score, move, user, target, ai, battle|
    score += 20   # Shadow moves are more preferable
    next score - 40 if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                       battle.pbCheckGlobalAbility(:CLOUDNINE)
    score += 10 if battle.field.weather != :None   # Prefer replacing another weather
    score -= 10 if user.hp < user.totalhp / 2   # Not worth it at lower HP
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RemoveAllScreens",
  proc { |move, user, target, ai, battle|
    will_fail = true
    battle.sides.each do |side|
      will_fail = false if side.effects[PBEffects::AuroraVeil] > 0 ||
                           side.effects[PBEffects::Reflect] > 0 ||
                           side.effects[PBEffects::LightScreen] > 0 ||
                           side.effects[PBEffects::Safeguard] > 0
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RemoveAllScreens",
  proc { |score, move, user, target, ai, battle|
    score += 20   # Shadow moves are more preferable
    if user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0 ||
       user.pbOpposingSide.effects[PBEffects::Reflect] > 0 ||
       user.pbOpposingSide.effects[PBEffects::LightScreen] > 0 ||
       user.pbOpposingSide.effects[PBEffects::Safeguard] > 0
      score += 30
    end
    if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 ||
       user.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
       user.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
       user.pbOwnSide.effects[PBEffects::Safeguard] > 0
      score -= 70
    end
    next score
  }
)
