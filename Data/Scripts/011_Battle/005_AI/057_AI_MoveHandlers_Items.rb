#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserTakesTargetItem",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.high_skill?
      if !user.item && target.item
        score += 40
      else
        score -= 90
      end
    else
      score -= 80
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("TargetTakesUserItem",
  proc { |move, user, target, ai, battle|
    next true if !user.item || user.battler.unlosableItem?(user.item)
    next true if target.item || target.battler.unlosableItem?(user.item)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("TargetTakesUserItem",
  proc { |score, move, user, target, ai, battle|
    if user.has_active_item?([:FLAMEORB, :TOXICORB, :STICKYBARB, :IRONBALL,
                              :CHOICEBAND, :CHOICESCARF, :CHOICESPECS])
      score += 50
    else
      score -= 80
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserTargetSwapItems",
  proc { |move, user, target, ai, battle|
    next true if user.wild?
    next true if !user.item && !target.item
    next true if user.battler.unlosableItem?(user.item) || user.battler.unlosableItem?(target.item)
    next true if target.battler.unlosableItem?(target.item) || target.battler.unlosableItem?(user.item)
    next true if target.has_active_ability?(:STICKYHOLD)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserTargetSwapItems",
  proc { |score, move, user, target, ai, battle|
    if user.has_active_item?([:FLAMEORB, :TOXICORB, :STICKYBARB, :IRONBALL,
                                 :CHOICEBAND, :CHOICESCARF, :CHOICESPECS])
      score += 50
    elsif !user.item && target.item
      score -= 30 if user.battler.lastMoveUsed &&
                     GameData::Move.get(user.battler.lastMoveUsed).function_code == "UserTargetSwapItems"
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RestoreUserConsumedItem",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.recycleItem || user.item
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RestoreUserConsumedItem",
  proc { |score, move, user, target, ai, battle|
    score += 30
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("RemoveTargetItem",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RemoveTargetItem",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.high_skill?
      score += 20 if target.item
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("DestroyTargetBerryOrGem",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.high_skill?
      if target.item && target.item.is_berry? && target.effects[PBEffects::Substitute] == 0
        score += 30
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("CorrodeTargetItem",
  proc { |move, user, target, ai, battle|
    next true if !target.item || target.unlosableItem?(target.item) ||
                 target.effects[PBEffects::Substitute] > 0
    next true if target.has_active_ability?(:STICKYHOLD)
    next true if battle.corrosiveGas[target.index % 2][target.party_index]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("CorrodeTargetItem",
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
Battle::AI::Handlers::MoveFailureCheck.add("StartTargetCannotUseItem",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Embargo] > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartTargetCannotUseItem",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.effects[PBEffects::Embargo] > 0
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("StartNegateHeldItems",
  proc { |score, move, user, target, ai, battle|
    next 0 if battle.field.effects[PBEffects::MagicRoom] > 0
    next score + 30 if !user.item && target.item
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserConsumeBerryRaiseDefense2",
  proc { |move, user, target, ai, battle|
    item = user.item
    next true if !item || !item.is_berry? || !user.item_active?
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserConsumeBerryRaiseDefense2",
  proc { |score, move, user, target, ai, battle|
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
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AllBattlersConsumeBerry",
  proc { |move, user, target, ai, battle|
    next true if !target.item || !target.item.is_berry? || target.battler.semiInvulnerable?
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AllBattlersConsumeBerry",
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
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserConsumeTargetBerry",
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::Substitute] == 0
      if ai.trainer.high_skill? && target.item && target.item.is_berry?
        score += 30
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("ThrowUserItemAtTarget",
  proc { |move, user, target, ai, battle|
    item = user.item
    next true if !item || !user.item_active? || user.battler.unlosableItem?(item)
    next true if item.is_berry? && !user.battler.canConsumeBerry?
    next true if item.flags.none? { |f| f[/^Fling_/i] }
  }
)
Battle::AI::Handlers::MoveBasePower.add("ThrowUserItemAtTarget",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)
