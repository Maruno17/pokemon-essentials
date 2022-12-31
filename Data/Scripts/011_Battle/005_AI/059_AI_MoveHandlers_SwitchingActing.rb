#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FleeFromBattle",
  proc { |move, user, ai, battle|
    next true if !battle.pbCanRun?(user.index)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("SwitchOutUserStatusMove",
  proc { |move, user, ai, battle|
    if user.wild?
      next true if !battle.pbCanRun?(user.index)
    else
      next true if !battle.pbCanChooseNonActive?(user.index)
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("SwitchOutUserStatusMove",
  proc { |score, move, user, ai, battle|
    next score + 10 if user.wild?
    if ai.trainer.has_skill_flag?("ReserveLastPokemon") && battle.pbTeamAbleNonActiveCount(user.index) == 1
      score -= 60   # Don't switch in ace
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
  proc { |score, move, user, ai, battle|
    next 0 if !battle.pbCanChooseNonActive?(user.index)
    next 0 if ai.trainer.has_skill_flag?("ReserveLastPokemon") && battle.pbTeamAbleNonActiveCount(user.index) == 1   # Don't switch in ace
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: Might need both MoveEffectScore and MoveEffectAgainstTargetScore.
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("LowerTargetAtkSpAtk1SwitchOutUser",
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("LowerTargetAtkSpAtk1SwitchOutUser",
  proc { |score, move, user, target, ai, battle|
    score = ai.get_score_for_target_stat_drop(score, target, move.move.statDown, false)
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("SwitchOutUserPassOnEffects",
  proc { |move, user, ai, battle|
    next true if !battle.pbCanChooseNonActive?(user.index)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("SwitchOutUserPassOnEffects",
  proc { |score, move, user, ai, battle|
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
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("SwitchOutTargetStatusMove",
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("SwitchOutTargetStatusMove",
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("SwitchOutTargetDamagingMove",
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
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("BindTarget",
  proc { |score, move, user, target, ai, battle|
    next score if target.effects[PBEffects::Trapping] > 0
    next score if target.effects[PBEffects::Substitute] > 0
    # Prefer if the user has a Binding Band or Grip Claw (because why have it if
    # you don't want to use it?)
    score += 5 if user.has_active_item?([:BINDINGBAND, :GRIPCLAW])
    # Target will take damage at the end of each round from the binding
    score += 8 if target.battler.takesIndirectDamage?
    # Check whether the target will be trapped in battle by the binding
    untrappable = Settings::MORE_TYPE_EFFECTS && target.has_type?(:GHOST)
    if !untrappable && target.ability_active?
      untrappable = Battle::AbilityEffects.triggerCertainSwitching(target.ability, target.battler, battle)
    end
    if !untrappable && target.item_active?
      untrappable = Battle::ItemEffects.triggerCertainSwitching(target.ability, target.battler, battle)
    end
    if !untrappable && !target.battler.trappedInBattle?
      score += 8   # Prefer if the target will become trapped by this move
      eor_damage = target.rough_end_of_round_damage
      if eor_damage > 0
        # Prefer if the target will take damage at the end of each round on top
        # of binding damage
        score += 8
      elsif eor_damage < 0
        # Don't prefer if the target will heal itself at the end of each round
        score -= 8
      end
      # Prefer if the target has been Perish Songed
      score += 10 if target.effects[PBEffects::PerishSong] > 0
    end
    # Don't prefer if the target can remove the binding (and the binding has an
    # effect)
    if (!untrappable && !target.battler.trappedInBattle?) || target.battler.takesIndirectDamage?
      if target.check_for_move { |m| m.function == "RemoveUserBindingAndEntryHazards" }
        score -= 8
      end
    end
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("BindTargetDoublePowerIfTargetUnderwater",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbModifyDamage(power, user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("BindTarget",
                                                        "BindTargetDoublePowerIfTargetUnderwater")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("TrapTargetInBattle",
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
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("TrapTargetInBattleLowerTargetDefSpDef1EachTurn",
  proc { |move, user, target, ai, battle|
    if move.statusMove?
      next true if target.effects[PBEffects::Octolock] >= 0
      next true if Settings::MORE_TYPE_EFFECTS && target.has_type?(:GHOST)
    end
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TrapTargetInBattleLowerTargetDefSpDef1EachTurn",
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TrapUserAndTargetInBattle",
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
  proc { |move, user, ai, battle|
    next true if battle.field.effects[PBEffects::FairyLock] > 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# PursueSwitchingFoe

#===============================================================================
# TODO: Review score modifiers.
# TODO: Consider all foes rather than just target. Can't use "target".
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UsedAfterUserTakesPhysicalDamage",
  proc { |score, move, user, ai, battle|
    if ai.trainer.medium_skill?
      hasPhysicalAttack = false
#      target.battler.eachMove do |m|
#        next if !m.physicalMove?(m.type)
#        hasPhysicalAttack = true
#        break
#      end
      score -= 50 if !hasPhysicalAttack
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UsedAfterAllyRoundWithDoublePower",
  proc { |score, move, user, ai, battle|
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
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("TargetUsesItsLastUsedMoveAgain",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.lastRegularMoveUsed ||
                 !target.battler.pbHasMove?(target.battler.lastRegularMoveUsed)
    next true if target.battler.usingMultiTurnAttack?
    next true if move.move.moveBlacklist.include?(GameData::Move.get(target.battler.lastRegularMoveUsed).function_code)
    idxMove = -1
    target.battler.eachMoveWithIndex do |m, i|
      idxMove = i if m.id == target.battler.lastRegularMoveUsed
    end
    next true if target.battler.moves[idxMove].pp == 0 && target.battler.moves[idxMove].total_pp > 0
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TargetUsesItsLastUsedMoveAgain",
  proc { |score, move, user, target, ai, battle|
    # Without lots of code here to determine good/bad moves and relative
    # speeds, using this move is likely to just be a waste of a turn
    next Battle::AI::MOVE_USELESS_SCORE
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HigherPriorityInGrassyTerrain",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && battle.field.terrain == :Grassy
      score += 15 if target.faster_than?(user)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("LowerPPOfTargetLastMoveBy3",
  proc { |score, move, user, target, ai, battle|
    if user.faster_than?(target)
      last_move = target.battler.pbGetMoveWithID(target.battler.lastRegularMoveUsed)
      if last_move && last_move.total_pp > 0
        next score + 20 if last_move.pp <= 3   # Will fully deplete the move's PP
        next score + 10 if last_move.pp <= 5
        next score - 10 if last_move.pp > 9   # Too much PP left to make a difference
      end
    end
    next score   # Don't know which move it will affect; treat as just a damaging move
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("LowerPPOfTargetLastMoveBy4",
  proc { |move, user, target, ai, battle|
    last_move = target.battler.pbGetMoveWithID(target.battler.lastRegularMoveUsed)
    next true if !last_move || last_move.pp == 0 || last_move.total_pp <= 0
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("LowerPPOfTargetLastMoveBy4",
  proc { |score, move, user, target, ai, battle|
    if user.faster_than?(target)
      last_move = target.battler.pbGetMoveWithID(target.battler.lastRegularMoveUsed)
      next score + 20 if last_move.pp <= 4   # Will fully deplete the move's PP
      next score + 10 if last_move.pp <= 6
      next score - 10 if last_move.pp > 10   # Too much PP left to make a difference
    end
    next score - 10   # Don't know which move it will affect; don't prefer
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("DisableTargetLastMoveUsed",
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
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("DisableTargetUsingSameMoveConsecutively",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Torment]
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetUsingSameMoveConsecutively",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.effects[PBEffects::Torment]
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("DisableTargetUsingDifferentMove",
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetUsingDifferentMove",
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
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("DisableTargetStatusMoves",
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
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("DisableTargetHealingMoves",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::HealBlock] > 0
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetSoundMoves",
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
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::Imprison]
  }
)
