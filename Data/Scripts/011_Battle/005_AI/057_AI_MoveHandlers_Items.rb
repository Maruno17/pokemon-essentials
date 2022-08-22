#===============================================================================
#
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

Battle::AI::Handlers::MoveEffectScore.add("TargetTakesUserItem",
  proc { |score, move, user, target, ai, battle|
    if !user.item || target.item
      score -= 90
    elsif user.has_active_item?([:FLAMEORB, :TOXICORB, :STICKYBARB, :IRONBALL,
                                 :CHOICEBAND, :CHOICESCARF, :CHOICESPECS])
      score += 50
    else
      score -= 80
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserTargetSwapItems",
  proc { |score, move, user, target, ai, battle|
    if !user.item && !target.item
      score -= 90
    elsif target.has_active_ability?(:STICKYHOLD)
      score -= 90
    elsif user.has_active_item?([:FLAMEORB, :TOXICORB, :STICKYBARB, :IRONBALL,
                                 :CHOICEBAND, :CHOICESCARF, :CHOICESPECS])
      score += 50
    elsif !user.item && target.item
      score -= 30 if user.battler.lastMoveUsed &&
                     GameData::Move.get(user.battler.lastMoveUsed).function_code == "UserTargetSwapItems"
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RestoreUserConsumedItem",
  proc { |score, move, user, target, ai, battle|
    if !user.battler.recycleItem || user.item
      score -= 80
    elsif user.battler.recycleItem
      score += 30
    end
    next score
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

Battle::AI::Handlers::MoveEffectScore.add("DestroyTargetBerryOrGem",
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::Substitute] == 0
      if ai.trainer.high_skill? && target.item && target.item.is_berry?
        score += 30
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CorrodeTargetItem",
  proc { |score, move, user, target, ai, battle|
    if battle.corrosiveGas[target.side][target.party_index]
      score -= 100
    elsif !target.item || !target.item_active? || target.battler.unlosableItem?(target.item) ||
          target.has_active_ability?(:STICKYHOLD)
      score -= 90
    elsif target.effects[PBEffects::Substitute] > 0
      score -= 90
    else
      score += 50
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartTargetCannotUseItem",
  proc { |score, move, user, target, ai, battle|
    next 0 if target.effects[PBEffects::Embargo] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartNegateHeldItems",
  proc { |score, move, user, target, ai, battle|
    next 0 if battle.field.effects[PBEffects::MagicRoom] > 0
    next score + 30 if !user.item && target.item
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserConsumeBerryRaiseDefense2",
  proc { |score, move, user, target, ai, battle|
    if !user.item || !user.item.is_berry? || !user.item_active?
      score -= 100
    else
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
    end
    next score
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
      if !b.item || !b.item.is_berry? || !b.itemActive?
        score -= 100 / battle.pbSideSize(user.index)
      else
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

Battle::AI::Handlers::MoveEffectScore.add("ThrowUserItemAtTarget",
  proc { |score, move, user, target, ai, battle|
    next 0 if !user.item || !user.item_active? ||
              user.battler.unlosableItem?(user.item) || user.item.is_poke_ball?
  }
)
