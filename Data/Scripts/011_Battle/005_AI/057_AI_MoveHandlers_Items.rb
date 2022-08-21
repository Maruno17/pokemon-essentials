#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserTakesTargetItem",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.high)
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
  proc { |score, move, user, target, skill, ai, battle|
    if !user.item || target.item
      score -= 90
    elsif user.hasActiveItem?([:FLAMEORB, :TOXICORB, :STICKYBARB, :IRONBALL,
                               :CHOICEBAND, :CHOICESCARF, :CHOICESPECS])
      score += 50
    else
      score -= 80
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserTargetSwapItems",
  proc { |score, move, user, target, skill, ai, battle|
    if !user.item && !target.item
      score -= 90
    elsif ai.skill_check(Battle::AI::AILevel.high) && target.hasActiveAbility?(:STICKYHOLD)
      score -= 90
    elsif user.hasActiveItem?([:FLAMEORB, :TOXICORB, :STICKYBARB, :IRONBALL,
                               :CHOICEBAND, :CHOICESCARF, :CHOICESPECS])
      score += 50
    elsif !user.item && target.item
      score -= 30 if user.lastMoveUsed &&
                     GameData::Move.get(user.lastMoveUsed).function_code == "UserTargetSwapItems"
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RestoreUserConsumedItem",
  proc { |score, move, user, target, skill, ai, battle|
    if !user.recycleItem || user.item
      score -= 80
    elsif user.recycleItem
      score += 30
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RemoveTargetItem",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.high)
      score += 20 if target.item
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("DestroyTargetBerryOrGem",
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::Substitute] == 0
      if ai.skill_check(Battle::AI::AILevel.high) && target.item && target.item.is_berry?
        score += 30
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CorrodeTargetItem",
  proc { |score, move, user, target, skill, ai, battle|
    if battle.corrosiveGas[target.index % 2][target.pokemonIndex]
      score -= 100
    elsif !target.item || !target.itemActive? || target.unlosableItem?(target.item) ||
          target.hasActiveAbility?(:STICKYHOLD)
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
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::Embargo] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartNegateHeldItems",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if battle.field.effects[PBEffects::MagicRoom] > 0
    next score + 30 if !user.item && target.item
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserConsumeBerryRaiseDefense2",
  proc { |score, move, user, target, skill, ai, battle|
    if !user.item || !user.item.is_berry? || !user.itemActive?
      score -= 100
    else
      if ai.skill_check(Battle::AI::AILevel.high)
        useful_berries = [
          :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
          :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
          :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
          :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY, :RAWSTBERRY,
          :SALACBERRY, :STARFBERRY, :WIKIBERRY
        ]
        score += 30 if useful_berries.include?(user.item_id)
      end
      if ai.skill_check(Battle::AI::AILevel.medium)
        score += 20 if user.canHeal? && user.hp < user.totalhp / 3 && user.hasActiveAbility?(:CHEEKPOUCH)
        score += 20 if user.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                       user.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
        score += 20 if !user.canConsumeBerry?
      end
      score -= user.stages[:DEFENSE] * 20
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AllBattlersConsumeBerry",
  proc { |score, move, user, target, skill, ai, battle|
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
        if ai.skill_check(Battle::AI::AILevel.high)
          amt = 30 / battle.pbSideSize(user.index)
          score += amt if useful_berries.include?(b.item_id)
        end
        if ai.skill_check(Battle::AI::AILevel.medium)
          amt = 20 / battle.pbSideSize(user.index)
          score += amt if b.canHeal? && b.hp < b.totalhp / 3 && b.hasActiveAbility?(:CHEEKPOUCH)
          score += amt if b.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                          b.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
          score += amt if !b.canConsumeBerry?
        end
      end
    end
    if ai.skill_check(Battle::AI::AILevel.high)
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
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::Substitute] == 0
      if ai.skill_check(Battle::AI::AILevel.high) && target.item && target.item.is_berry?
        score += 30
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ThrowUserItemAtTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !user.item || !user.itemActive? ||
              user.unlosableItem?(user.item) || user.item.is_poke_ball?
  }
)
