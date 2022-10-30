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
    score += (user_item_preference - user_no_item_preference) * 5
    score += (target_item_preference - target_no_item_preference) * 5
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
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TargetTakesUserItem",
  proc { |score, move, user, target, ai, battle|
    user_item_preference = ai.battler_wants_item?(user, user.item_id)
    user_no_item_preference = ai.battler_wants_item?(user, :NONE)
    target_item_preference = ai.battler_wants_item?(target, user.item_id)
    target_no_item_preference = ai.battler_wants_item?(target, :NONE)
    score -= (user_item_preference - user_no_item_preference) * 5
    score -= (target_item_preference - target_no_item_preference) * 5
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
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserTargetSwapItems",
  proc { |score, move, user, target, ai, battle|
    user_new_item_preference = ai.battler_wants_item?(user, target.item_id)
    user_old_item_preference = ai.battler_wants_item?(user, user.item_id)
    target_new_item_preference = ai.battler_wants_item?(target, user.item_id)
    target_old_item_preference = ai.battler_wants_item?(target, target.item_id)
    score += (user_new_item_preference - user_old_item_preference) * 5
    score -= (target_new_item_preference - target_old_item_preference) * 5
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
    next true if !user.battler.recycleItem || user.item
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RestoreUserConsumedItem",
  proc { |score, move, user, ai, battle|
    user_new_item_preference = ai.battler_wants_item?(user, user.battler.recycleItem)
    user_old_item_preference = ai.battler_wants_item?(user, user.item_id)
    score += (user_new_item_preference - user_old_item_preference) * 8
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
    score += (target_item_preference - target_no_item_preference) * 5
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
    score += (target_item_preference - target_no_item_preference) * 8
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("CorrodeTargetItem",
  proc { |move, user, target, ai, battle|
    next true if !target.item || target.unlosableItem?(target.item) ||
                 target.effects[PBEffects::Substitute] > 0
    next true if target.has_active_ability?(:STICKYHOLD)
    next true if battle.corrosiveGas[target.index % 2][target.party_index]
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("CorrodeTargetItem",
  proc { |score, move, user, target, ai, battle|
    if target.item_active?
      score += 30
    else
      score -= 50
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("StartTargetCannotUseItem",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Embargo] > 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("StartNegateHeldItems",
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if battle.field.effects[PBEffects::MagicRoom] > 0
    next score + 30 if !user.item   # && target.item
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserConsumeBerryRaiseDefense2",
  proc { |move, user, ai, battle|
    item = user.item
    next true if !item || !item.is_berry? || !user.item_active?
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserConsumeBerryRaiseDefense2",
  proc { |score, move, user, ai, battle|
    if ai.trainer.high_skill?
      useful_berries = [
        :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
        :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
        :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
        :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY, :RAWSTBERRY,
        :SALACBERRY, :STARFBERRY, :WIKIBERRY
      ]
      score += 30 if useful_berries.include?(user.item_id)
    end
    if ai.trainer.medium_skill?
      score += 20 if user.battler.canHeal? && user.hp < user.totalhp / 3 &&
                     user.has_active_ability?(:CHEEKPOUCH)
      score += 20 if user.has_active_ability?([:HARVEST, :RIPEN]) ||
                     user.battler.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
      score += 20 if !user.battler.canConsumeBerry?
    end
    score -= user.stages[:DEFENSE] * 20
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code should be for a single battler (each is checked in turn).
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("AllBattlersConsumeBerry",
  proc { |move, user, target, ai, battle|
    next true if !target.item || !target.item.is_berry? || target.battler.semiInvulnerable?
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("AllBattlersConsumeBerry",
  proc { |score, move, user, target, ai, battle|
    useful_berries = [
      :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
      :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
      :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
      :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY,
      :RAWSTBERRY, :SALACBERRY, :STARFBERRY, :WIKIBERRY
    ]
    battle.allSameSideBattlers(user.index).each do |b|
      if ai.trainer.high_skill?
        amt = 30 / battle.pbSideSize(user.index)
        score += amt if useful_berries.include?(b.item_id)
      end
      if ai.trainer.medium_skill?
        amt = 20 / battle.pbSideSize(user.index)
        score += amt if b.canHeal? && b.hp < b.totalhp / 3 && b.hasActiveAbility?(:CHEEKPOUCH)
        score += amt if b.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                        b.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
        score += amt if !b.canConsumeBerry?
      end
    end
    if ai.trainer.high_skill?
      battle.allOtherSideBattlers(user.index).each do |b|
        amt = 10 / battle.pbSideSize(target.index)
        score -= amt if b.hasActiveItem?(useful_berries)
        score -= amt if b.canHeal? && b.hp < b.totalhp / 3 && b.hasActiveAbility?(:CHEEKPOUCH)
        score -= amt if b.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                        b.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
        score -= amt if !b.canConsumeBerry?
      end
    end
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
    # User can consume the target's berry; score it
    target_item_preference = ai.battler_wants_item?(target, target.item_id)
    target_no_item_preference = ai.battler_wants_item?(target, :NONE)
    score += (target_item_preference - target_no_item_preference) * 8
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("ThrowUserItemAtTarget",
  proc { |move, user, ai, battle|
    item = user.item
    next true if !item || !user.item_active? || user.battler.unlosableItem?(item)
    next true if item.is_berry? && !user.battler.canConsumeBerry?
    next true if item.flags.none? { |f| f[/^Fling_/i] }
  }
)
Battle::AI::Handlers::MoveBasePower.add("ThrowUserItemAtTarget",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)
