#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FleeFromBattle",
  proc { |move, user, ai, battle|
    next !battle.pbCanRun?(user.index)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("FleeFromBattle",
  proc { |score, move, user, ai, battle|
    # Generally don't prefer (don't want to end the battle too easily)
    next score - 15
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("SwitchOutUserStatusMove",
  proc { |move, user, ai, battle|
    next !battle.pbCanRun?(user.index) if user.wild?
    next !battle.pbCanChooseNonActive?(user.index)
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
        score += 75 if !user.check_for_move { |m| m.damagingMove? }
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
    next score
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
    next !battle.pbCanChooseNonActive?(user.index)
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
        score += 75 if !user.check_for_move { |m| m.damagingMove? }
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
        next if !battle.pbCanSwitchIn?(target.index, i)
        will_fail = false
        break
      end
      next will_fail
    end
    next false
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
      if target.has_move_with_function?("RemoveUserBindingAndEntryHazards")
        score -= 8
      end
    end
    next score
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
    next false if move.damagingMove?
    next true if target.effects[PBEffects::MeanLook] >= 0
    next true if Settings::MORE_TYPE_EFFECTS && target.has_type?(:GHOST)
    next false
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("TrapTargetInBattleLowerTargetDefSpDef1EachTurn",
  proc { |move, user, target, ai, battle|
    next false if move.damagingMove?
    next true if target.effects[PBEffects::Octolock] >= 0
    next true if Settings::MORE_TYPE_EFFECTS && target.has_type?(:GHOST)
    next false
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
    next battle.field.effects[PBEffects::FairyLock] > 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# PursueSwitchingFoe

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UsedAfterUserTakesPhysicalDamage",
  proc { |move, user, ai, battle|
    found_physical_move = false
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.physicalMove?(m.type) }
      found_physical_move = true
      break
    end
    next !found_physical_move
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UsedAfterUserTakesPhysicalDamage",
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if user.effects[PBEffects::Substitute] > 0
    # Prefer if foes don't know any special moves
    found_special_move = false
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.specialMove?(m.type) }
      found_special_move = true
      break
    end
    score += 10 if !found_special_move
    # Generally not worth using
    next score - 10
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UsedAfterAllyRoundWithDoublePower",
  proc { |score, move, user, ai, battle|
    # No score change if no allies know this move
    ally_has_move = false
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.has_move_with_function?(move.function)
      ally_has_move = true
      break
    end
    next score if !ally_has_move
    # Prefer for the sake of doubling in power
    score += 5
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TargetActsNext",
  proc { |score, move, user, target, ai, battle|
    # Useless if the target is a foe
    next Battle::AI::MOVE_USELESS_SCORE if target.opposes?(user)
    # Compare the speeds of all battlers
    speeds = []
    ai.each_battler { |b, i| speeds.push([i, b.rough_stat(:SPEED)]) }
    if battle.field.effects[PBEffects::TrickRoom] > 0
      speeds.sort! { |a, b| a[1] <=> b[1] }
    else
      speeds.sort! { |a, b| b[1] <=> a[1] }
    end
    idx_user = speeds.index { |ele| ele[0] == user.index }
    idx_target = speeds.index { |ele| ele[0] == target.index }
    # Useless if the target is faster than the user
    next Battle::AI::MOVE_USELESS_SCORE if idx_target < idx_user
    # Useless if the target will move next anyway
    next Battle::AI::MOVE_USELESS_SCORE if idx_target - idx_user <= 1
    # Generally not worth using
    # NOTE: Because this move can be used against a foe but is being used on an
    #       ally (since we're here in this code), this move's score will be
    #       inverted later. A higher score here means this move will be less
    #       preferred, which is the result we want.
    next score + 10
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("TargetActsLast",
  proc { |score, move, user, ai, battle|
    # Useless if the target is an ally
    next Battle::AI::MOVE_USELESS_SCORE if !target.opposes?(user)
    # Useless if the user has no ally (the point of this move is to let the ally
    # get in a hit before the foe)
    has_ally = false
    ai.each_ally(user.index) { |b, i| has_ally = true if b.can_attack? }
    next Battle::AI::MOVE_USELESS_SCORE if !has_ally
    # Compare the speeds of all battlers
    speeds = []
    ai.each_battler { |b, i| speeds.push([i, b.rough_stat(:SPEED)]) }
    if battle.field.effects[PBEffects::TrickRoom] > 0
      speeds.sort! { |a, b| a[1] <=> b[1] }
    else
      speeds.sort! { |a, b| b[1] <=> a[1] }
    end
    idx_user = speeds.index { |ele| ele[0] == user.index }
    idx_target = speeds.index { |ele| ele[0] == target.index }
    idx_slowest_ally = -1
    speeds.each_with_index { |ele, i| idx_slowest_ally = i if user.index.even? == ele[0].even? }
    # Useless if the target is faster than the user
    next Battle::AI::MOVE_USELESS_SCORE if idx_target < idx_user
    # Useless if the target will move last anyway
    next Battle::AI::MOVE_USELESS_SCORE if idx_target == speeds.length - 1
    # Useless if the slowest ally is faster than the target
    next Battle::AI::MOVE_USELESS_SCORE if idx_slowest_ally < idx_target
    # Generally not worth using
    next score - 10
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("TargetUsesItsLastUsedMoveAgain",
  proc { |move, user, target, ai, battle|
    next target.battler.usingMultiTurnAttack?
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TargetUsesItsLastUsedMoveAgain",
  proc { |score, move, user, target, ai, battle|
    # We don't ever want to make a foe act again
    next Battle::AI::MOVE_USELESS_SCORE if target.opposes?(user)
    # Useless if target will act before the user, as we don't know what move
    # will be instructed
    next Battle::AI::MOVE_USELESS_SCORE if target.faster_than?(user)
    next Battle::AI::MOVE_USELESS_SCORE if !target.battler.lastRegularMoveUsed
    mov = nil
    target.battler.eachMove do |m|
      mov = m if m.id == target.battler.lastRegularMoveUsed
      break if mov
    end
    next Battle::AI::MOVE_USELESS_SCORE if mov.nil? || (mov.pp == 0 && mov.total_pp > 0)
    next Battle::AI::MOVE_USELESS_SCORE if move.move.moveBlacklist.include?(mov.function)
    # Without lots of code here to determine good/bad moves, using this move is
    # likely to just be a waste of a turn
    # NOTE: Because this move can be used against a foe but is being used on an
    #       ally (since we're here in this code), this move's score will be
    #       inverted later. A higher score here means this move will be less
    #       preferred, which is the result we want.
    score += 20
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("StartSlowerBattlersActFirst",
  proc { |score, move, user, ai, battle|
    # Get the speeds of all battlers
    ally_speeds = []
    foe_speeds = []
    ai.each_battler do |b, i|
      if b.opposes?(user)
        foe_speeds.push(rough_stat(:SPEED))
        foe_speeds.last *= 2 if user.pbOpposingSide.effects[PBEffects::Tailwind] > 1
        foe_speeds.last /= 2 if user.pbOpposingSide.effects[PBEffects::Swamp] > 1
      else
        ally_speeds.push(rough_stat(:SPEED))
        ally_speeds.last *= 2 if user.pbOwnSide.effects[PBEffects::Tailwind] > 1
        ally_speeds.last /= 2 if user.pbOwnSide.effects[PBEffects::Swamp] > 1
      end
    end
    # Just in case a side has no battlers
    next Battle::AI::MOVE_USELESS_SCORE if ally_speeds.length == 0 || foe_speeds.length == 0
    # Invert the speeds if Trick Room applies (and will last longer than this round)
    if battle.field.effects[PBEffects::TrickRoom] > 1
      foe_speeds.map! { |val| 100_000 - val }    # 100_000 is higher than speed can
      ally_speeds.map! { |val| 100_000 - val }   # possibly be; only order matters
    end
    # Score based on the relative speeds
    next Battle::AI::MOVE_USELESS_SCORE if ally_speeds.min > foe_speeds.max
    if foe_speeds.min > ally_speeds.max
      score += 20
    elsif ally_speeds.sum / ally_speeds.length < foe_speeds.sum / foe_speeds.length
      score += 10
    else
      score -= 10
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
# HigherPriorityInGrassyTerrain

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
    next !target.check_for_move { |m| m.id == target.battler.lastRegularMoveUsed }
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
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("DisableTargetLastMoveUsed",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Disable] > 0 || !target.battler.lastRegularMoveUsed
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    next !target.check_for_move { |m| m.id == target.battler.lastRegularMoveUsed }
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetUsingSameMoveConsecutively",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.has_active_item?(:MENTALHERB)
    # Prefer if the target is locked into using a single move, or will be
    if target.effects[PBEffects::ChoiceBand] ||
       target.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
       target.has_active_ability?(:GORILLATACTICS)
      score += 8
    end
    # PRefer disabling a damaging move
    score += 5 if GameData::Move.try_get(target.battler.lastRegularMoveUsed)&.damaging?
    # Inherent preference
    score += 8
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("DisableTargetUsingSameMoveConsecutively",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Torment]
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    next false
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetUsingSameMoveConsecutively",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.has_active_item?(:MENTALHERB)
    # Prefer if the target is locked into using a single move, or will be
    if target.effects[PBEffects::ChoiceBand] ||
       target.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
       target.has_active_ability?(:GORILLATACTICS)
      score += 8
    end
    # Inherent preference
    score += 8
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("DisableTargetUsingDifferentMove",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Encore] > 0
    next true if !target.battler.lastRegularMoveUsed ||
                 move.move.moveBlacklist.include?(GameData::Move.get(target.battler.lastRegularMoveUsed).function_code)
    next true if target.effects[PBEffects::ShellTrap]
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    will_fail = true
    next !target.check_for_move { |m| m.id == target.battler.lastRegularMoveUsed }
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetUsingDifferentMove",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.has_active_item?(:MENTALHERB)
    if user.faster_than?(target)
      # We know which move is going to be encored (assuming the target doesn't
      # use a high priority move)
      move_data = GameData::Move.get(target.battler.lastRegularMoveUsed)
      if move_data.status?
        # Prefer encoring status moves
        if [:User, :BothSides].include?(move_data.target)
          # TODO: This target distinction was in the old code. Is it appropriate?
          score += 10
        else
          score += 8
        end
      elsif move_data.damaging? && move_data.target == :NearOther
        # Prefer encoring damaging moves depending on their type effectiveness
        # against the user
        eff = user.effectiveness_of_type_against_battler(move_data.type, target)
        if Effectiveness.ineffective?(eff)
          score += 15
        elsif Effectiveness.not_very_effective?(eff)
          score += 10
        elsif Effectiveness.super_effective?(eff)
          score -= 5
        else
          score += 5
        end
      end
    else
      # We don't know which move is going to be encored; just prefer limiting
      # the target's options
      score += 8
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("DisableTargetStatusMoves",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Taunt] > 0
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    next true if Settings::MECHANICS_GENERATION >= 6 &&
                 !battle.moldBreaker && target.has_active_ability?(:OBLIVIOUS)
    next false
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetStatusMoves",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if !target.check_for_move { |m| m.statusMove? }
    # Not worth using on a sleeping target that won't imminently wake up
    if target.status == :SLEEP && target.statusCount > ((target.faster_than?(user)) ? 2 : 1)
      if !target.check_for_move { |m| m.statusMove? && m.usableWhenAsleep? }
        next Battle::AI::MOVE_USELESS_SCORE
      end
    end
    # Move is likely useless if the target will lock themselves into a move,
    # because they'll likely lock themselves into a damaging move anyway
    if !target.effects[PBEffects::ChoiceBand]
      if target.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
         target.has_active_ability?(:GORILLATACTICS)
        next Battle::AI::MOVE_USELESS_SCORE
      end
    end
    # Prefer if the target has a protection move
    protection_moves = [
      "ProtectUser",                                       # Detect, Protect
      "ProtectUserSideFromPriorityMoves",                  # Quick Guard
      "ProtectUserSideFromMultiTargetDamagingMoves",       # Wide Guard
      "UserEnduresFaintingThisTurn",                       # Endure
      "ProtectUserSideFromDamagingMovesIfUserFirstTurn",   # Mat Block
      "ProtectUserSideFromStatusMoves",                    # Crafty Shield
      "ProtectUserFromDamagingMovesKingsShield",           # King's Shield
      "ProtectUserFromDamagingMovesObstruct",              # Obstruct
      "ProtectUserFromTargetingMovesSpikyShield",          # Spiky Shield
      "ProtectUserBanefulBunker"                           # Baneful Bunker
    ]
    if target.check_for_move { |m| m.statusMove? && protection_moves.include?(m.function) }
      score += 6
    end
    # Inherent preference
    score += 8
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("DisableTargetHealingMoves",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::HealBlock] > 0
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    next false
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetHealingMoves",
  proc { |score, move, user, target, ai, battle|
    # Useless if the foe can't heal themselves with a move or some held items
    if !target.check_for_move { |m| m.healingMove? }
      if !target.has_active_item?(:LEFTOVERS) &&
         !(target.has_active_item?(:BLACKSLUDGE) && target.has_type?(:POISON))
        next Battle::AI::MOVE_USELESS_SCORE
      end
    end
    # Inherent preference
    score += 8
    next score
  }
)

#===============================================================================
#.
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetSoundMoves",
  proc { |score, move, user, target, ai, battle|
    next score if target.effects[PBEffects::ThroatChop] > 1
    next score if !target.check_for_move { |m| m.soundMove? }
    # Inherent preference
    score += 8
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("DisableTargetMovesKnownByUser",
  proc { |move, user, ai, battle|
    next user.effects[PBEffects::Imprison]
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetMovesKnownByUser",
  proc { |score, move, user, target, ai, battle|
    # Useless if the foes have no moves that the user also knows
    shared_move = false
    user_moves = user.battler.moves.map { |m| m.id }
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| user_moves.include?(m.id) }
      shared_move = true
      break
    end
    next Battle::AI::MOVE_USELESS_SCORE if !shared_move
    # Inherent preference
    score += 6
    next score
  }
)
