#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserTakesTargetItem",
  proc { |score, move, user, target, ai, battle|
    next score if user.wild? || user.item
    next score if !target.item || target.battler.unlosableItem?(target.item)
    next score if user.battler.unlosableItem?(target.item)
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
    # User can steal the target's item; score it
    user_item_preference = ai.battler_wants_item?(user, target.item_id)
    user_no_item_preference = ai.battler_wants_item?(user, :NONE)
    target_item_preference = ai.battler_wants_item?(target, target.item_id)
    target_no_item_preference = ai.battler_wants_item?(target, :NONE)
    score += (user_item_preference - user_no_item_preference) * 3
    score += (target_item_preference - target_no_item_preference) * 3
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("TargetTakesUserItem",
  proc { |move, user, target, ai, battle|
    next true if !user.item || user.battler.unlosableItem?(user.item)
    next true if target.item || target.battler.unlosableItem?(user.item)
    next false
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TargetTakesUserItem",
  proc { |score, move, user, target, ai, battle|
    user_item_preference = ai.battler_wants_item?(user, user.item_id)
    user_no_item_preference = ai.battler_wants_item?(user, :NONE)
    target_item_preference = ai.battler_wants_item?(target, user.item_id)
    target_no_item_preference = ai.battler_wants_item?(target, :NONE)
    score -= (user_item_preference - user_no_item_preference) * 3
    score -= (target_item_preference - target_no_item_preference) * 3
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("UserTargetSwapItems",
  proc { |move, user, target, ai, battle|
    next true if user.wild?
    next true if !user.item && !target.item
    next true if user.battler.unlosableItem?(user.item) || user.battler.unlosableItem?(target.item)
    next true if target.battler.unlosableItem?(target.item) || target.battler.unlosableItem?(user.item)
    next true if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
    next false
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserTargetSwapItems",
  proc { |score, move, user, target, ai, battle|
    user_new_item_preference = ai.battler_wants_item?(user, target.item_id)
    user_old_item_preference = ai.battler_wants_item?(user, user.item_id)
    target_new_item_preference = ai.battler_wants_item?(target, user.item_id)
    target_old_item_preference = ai.battler_wants_item?(target, target.item_id)
    score += (user_new_item_preference - user_old_item_preference) * 3
    score -= (target_new_item_preference - target_old_item_preference) * 3
    # Don't prefer if user used this move in the last round
    score -= 15 if user.battler.lastMoveUsed &&
                   GameData::Move.get(user.battler.lastMoveUsed).function_code == "UserTargetSwapItems"
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RestoreUserConsumedItem",
  proc { |move, user, ai, battle|
    next !user.battler.recycleItem || user.item
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RestoreUserConsumedItem",
  proc { |score, move, user, ai, battle|
    user_new_item_preference = ai.battler_wants_item?(user, user.battler.recycleItem)
    user_old_item_preference = ai.battler_wants_item?(user, user.item_id)
    score += (user_new_item_preference - user_old_item_preference) * 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("RemoveTargetItem",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RemoveTargetItem",
  proc { |score, move, user, target, ai, battle|
    next score if user.wild?
    next score if !target.item || target.battler.unlosableItem?(target.item)
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
    # User can knock off the target's item; score it
    target_item_preference = ai.battler_wants_item?(target, target.item_id)
    target_no_item_preference = ai.battler_wants_item?(target, :NONE)
    score += (target_item_preference - target_no_item_preference) * 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DestroyTargetBerryOrGem",
  proc { |score, move, user, target, ai, battle|
    next score if !target.item || (!target.item.is_berry? &&
                  !(Settings::MECHANICS_GENERATION >= 6 && target.item.is_gem?))
    next score if user.battler.unlosableItem?(target.item)
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
    # User can incinerate the target's item; score it
    target_item_preference = ai.battler_wants_item?(target, target.item_id)
    target_no_item_preference = ai.battler_wants_item?(target, :NONE)
    score += (target_item_preference - target_no_item_preference) * 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("CorrodeTargetItem",
  proc { |move, user, target, ai, battle|
    next true if !target.item || target.unlosableItem?(target.item) ||
                 target.effects[PBEffects::Substitute] > 0
    next true if target.has_active_ability?(:STICKYHOLD)
    next true if battle.corrosiveGas[target.index % 2][target.party_index]
    next false
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("CorrodeTargetItem",
  proc { |score, move, user, target, ai, battle|
    target_item_preference = ai.battler_wants_item?(target, target.item_id)
    target_no_item_preference = ai.battler_wants_item?(target, :NONE)
    score += (target_item_preference - target_no_item_preference) * 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("StartTargetCannotUseItem",
  proc { |move, user, target, ai, battle|
    next target.effects[PBEffects::Embargo] > 0
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("StartTargetCannotUseItem",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if !target.item || !target.item_active?
    item_score = ai.battler_wants_item?(target, target.item_id)
    score += item_score * 5
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("StartNegateHeldItems",
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if battle.field.effects[PBEffects::MagicRoom] > 0
    score += 30 if !user.item   # && target.item
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserConsumeBerryRaiseDefense2",
  proc { |move, user, ai, battle|
    item = user.item
    next !item || !item.is_berry? || !user.item_active?
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserConsumeBerryRaiseDefense2",
  proc { |score, move, user, ai, battle|
    # Score for raising the user's stat
    score = Battle::AI::Handlers.apply_move_effect_score("RaiseUserDefense2",
       score, move, user, ai, battle)
    # Score for the consumed berry's effect
    score += ai.get_score_change_for_consuming_item(user, user.item_id)
    # Score for other results of consuming the berry
    if ai.trainer.medium_skill?
      # Prefer if user will heal itself with Cheek Pouch
      score += 5 if user.battler.canHeal? && user.hp < user.totalhp / 2 &&
                    user.has_active_ability?(:CHEEKPOUCH)
      # Prefer if target can recover the consumed berry
      score += 8 if user.has_active_ability?(:HARVEST) ||
                    user.has_move_with_function?("RestoreUserConsumedItem")
      # Prefer if user couldn't normally consume the berry
      score += 4 if !user.battler.canConsumeBerry?
      #Prefer if user will newly be able to use Belch
      score += 4 if !user.battler.belched? && user.has_move_with_function?("FailsIfUserNotConsumedBerry")
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("AllBattlersConsumeBerry",
  proc { |move, user, target, ai, battle|
    next !target.item || !target.item.is_berry? || target.battler.semiInvulnerable?
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("AllBattlersConsumeBerry",
  proc { |score, move, user, target, ai, battle|
    # Score for the consumed berry's effect
    score_change = ai.get_score_change_for_consuming_item(target, target.item_id)
    # Score for other results of consuming the berry
    if ai.trainer.medium_skill?
      # Prefer if target will heal itself with Cheek Pouch
      score_change += 5 if target.battler.canHeal? && target.hp < target.totalhp / 2 &&
                           target.has_active_ability?(:CHEEKPOUCH)
      # Prefer if target can recover the consumed berry
      score_change += 8 if target.has_active_ability?(:HARVEST) ||
                           target.has_move_with_function?("RestoreUserConsumedItem")
      # Prefer if target couldn't normally consume the berry
      score_change += 4 if !target.battler.canConsumeBerry?
      #Prefer if user or ally will newly be able to use Belch
      ai.each_same_side_battler(user.side) do |b, i|
        score += 4 if !b.battler.belched? && b.has_move_with_function?("FailsIfUserNotConsumedBerry")
      end
    end
    score += (target.opposes?(user)) ? -score_change : score_change
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserConsumeTargetBerry",
  proc { |score, move, user, target, ai, battle|
    next score if !target.item || !target.item.is_berry?
    next score if user.battler.unlosableItem?(target.item)
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
    # Score the user gaining the item's effect
    score += ai.get_score_change_for_consuming_item(user, target.item_id)
    # Score for other results of consuming the berry
    if ai.trainer.medium_skill?
      # Prefer if user will heal itself with Cheek Pouch
      score += 5 if user.battler.canHeal? && user.hp < user.totalhp / 2 &&
                    user.has_active_ability?(:CHEEKPOUCH)
      #Prefer if user will newly be able to use Belch
      score += 4 if !user.battler.belched? && user.has_move_with_function?("FailsIfUserNotConsumedBerry")
    end
    # Score the target no longer having the item
    target_item_preference = ai.battler_wants_item?(target, target.item_id)
    target_no_item_preference = ai.battler_wants_item?(target, :NONE)
    score += (target_item_preference - target_no_item_preference) * 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("ThrowUserItemAtTarget",
  proc { |move, user, ai, battle|
    item = user.item
    next true if !item || !user.item_active? || user.battler.unlosableItem?(item)
    next true if item.is_berry? && !user.battler.canConsumeBerry?
    next true if item.flags.none? { |f| f[/^Fling_/i] }
    next false
  }
)
Battle::AI::Handlers::MoveBasePower.add("ThrowUserItemAtTarget",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("ThrowUserItemAtTarget",
  proc { |score, move, user, target, ai, battle|
    case user.item_id
    when :POISONBARB, :TOXICORB
      score = Battle::AI::Handlers.apply_move_effect_against_target_score("PoisonTarget",
         score, move, user, target, ai, battle)
    when :FLAMEORB
      score = Battle::AI::Handlers.apply_move_effect_against_target_score("BurnTarget",
         score, move, user, target, ai, battle)
    when :LIGHTBALL
      score = Battle::AI::Handlers.apply_move_effect_against_target_score("ParalyzeTarget",
         score, move, user, target, ai, battle)
    when :KINGSROCK, :RAZORFANG
      score = Battle::AI::Handlers.apply_move_effect_against_target_score("FlinchTarget",
         score, move, user, target, ai, battle)
    else
      score -= ai.get_score_change_for_consuming_item(target, user.item_id)
    end
    # Prefer if the user doesn't want its held item/don't prefer if it wants to
    # keep its held item
    user_item_preference = ai.battler_wants_item?(user, user.item_id)
    user_no_item_preference = ai.battler_wants_item?(user, :NONE)
    score += (user_item_preference - user_no_item_preference) * 4
    # Prefer if user will benefit from not having an item
    score += 5 if user.has_active_ability?(:UNBURDEN)
    next score
  }
)
