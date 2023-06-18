#===============================================================================
#
#===============================================================================
module Battle::ItemEffects
  SpeedCalc                       = ItemHandlerHash.new
  WeightCalc                      = ItemHandlerHash.new   # Float Stone
  # Battler's HP/stat changed
  HPHeal                          = ItemHandlerHash.new
  OnStatLoss                      = ItemHandlerHash.new
  # Battler's status problem
  StatusCure                      = ItemHandlerHash.new
  # Priority and turn order
  PriorityBracketChange           = ItemHandlerHash.new
  PriorityBracketUse              = ItemHandlerHash.new
  # Move usage failures
  OnMissingTarget                 = ItemHandlerHash.new   # Blunder Policy
  # Accuracy calculation
  AccuracyCalcFromUser            = ItemHandlerHash.new
  AccuracyCalcFromTarget          = ItemHandlerHash.new
  # Damage calculation
  DamageCalcFromUser              = ItemHandlerHash.new
  DamageCalcFromTarget            = ItemHandlerHash.new
  CriticalCalcFromUser            = ItemHandlerHash.new
  CriticalCalcFromTarget          = ItemHandlerHash.new   # None!
  # Upon a move hitting a target
  OnBeingHit                      = ItemHandlerHash.new
  OnBeingHitPositiveBerry         = ItemHandlerHash.new
  # Items that trigger at the end of using a move
  AfterMoveUseFromTarget          = ItemHandlerHash.new
  AfterMoveUseFromUser            = ItemHandlerHash.new
  OnEndOfUsingMove                = ItemHandlerHash.new   # Leppa Berry
  OnEndOfUsingMoveStatRestore     = ItemHandlerHash.new   # White Herb
  # Experience and EV gain
  ExpGainModifier                 = ItemHandlerHash.new   # Lucky Egg
  EVGainModifier                  = ItemHandlerHash.new
  # Weather and terrin
  WeatherExtender                 = ItemHandlerHash.new
  TerrainExtender                 = ItemHandlerHash.new   # Terrain Extender
  TerrainStatBoost                = ItemHandlerHash.new
  # End Of Round
  EndOfRoundHealing               = ItemHandlerHash.new
  EndOfRoundEffect                = ItemHandlerHash.new
  # Switching and fainting
  CertainSwitching                = ItemHandlerHash.new   # Shed Shell
  TrappingByTarget                = ItemHandlerHash.new   # None!
  OnSwitchIn                      = ItemHandlerHash.new   # Air Balloon
  OnIntimidated                   = ItemHandlerHash.new   # Adrenaline Orb
  # Running from battle
  CertainEscapeFromBattle         = ItemHandlerHash.new   # Smoke Ball

  #=============================================================================

  def self.trigger(hash, *args, ret: false)
    new_ret = hash.trigger(*args)
    return (!new_ret.nil?) ? new_ret : ret
  end

  #=============================================================================

  def self.triggerSpeedCalc(item, battler, mult)
    return trigger(SpeedCalc, item, battler, mult, ret: mult)
  end

  def self.triggerWeightCalc(item, battler, w)
    return trigger(WeightCalc, item, battler, w, ret: w)
  end

  #=============================================================================

  def self.triggerHPHeal(item, battler, battle, forced)
    return trigger(HPHeal, item, battler, battle, forced)
  end

  def self.triggerOnStatLoss(item, user, move_user, battle)
    return trigger(OnStatLoss, item, user, move_user, battle)
  end

  #=============================================================================

  def self.triggerStatusCure(item, battler, battle, forced)
    return trigger(StatusCure, item, battler, battle, forced)
  end

  #=============================================================================

  def self.triggerPriorityBracketChange(item, battler, battle)
    return trigger(PriorityBracketChange, item, battler, battle, ret: 0)
  end

  def self.triggerPriorityBracketUse(item, battler, battle)
    PriorityBracketUse.trigger(item, battler, battle)
  end

  #=============================================================================

  def self.triggerOnMissingTarget(item, user, target, move, hit_num, battle)
    OnMissingTarget.trigger(item, user, target, move, hit_num, battle)
  end

  #=============================================================================

  def self.triggerAccuracyCalcFromUser(item, mods, user, target, move, type)
    AccuracyCalcFromUser.trigger(item, mods, user, target, move, type)
  end

  def self.triggerAccuracyCalcFromTarget(item, mods, user, target, move, type)
    AccuracyCalcFromTarget.trigger(item, mods, user, target, move, type)
  end

  #=============================================================================

  def self.triggerDamageCalcFromUser(item, user, target, move, mults, power, type)
    DamageCalcFromUser.trigger(item, user, target, move, mults, power, type)
  end

  def self.triggerDamageCalcFromTarget(item, user, target, move, mults, power, type)
    DamageCalcFromTarget.trigger(item, user, target, move, mults, power, type)
  end

  def self.triggerCriticalCalcFromUser(item, user, target, crit_stage)
    return trigger(CriticalCalcFromUser, item, user, target, crit_stage, ret: crit_stage)
  end

  def self.triggerCriticalCalcFromTarget(item, user, target, crit_stage)
    return trigger(CriticalCalcFromTarget, item, user, target, crit_stage, ret: crit_stage)
  end

  #=============================================================================

  def self.triggerOnBeingHit(item, user, target, move, battle)
    OnBeingHit.trigger(item, user, target, move, battle)
  end

  def self.triggerOnBeingHitPositiveBerry(item, battler, battle, forced)
    return trigger(OnBeingHitPositiveBerry, item, battler, battle, forced)
  end

  #=============================================================================

  def self.triggerAfterMoveUseFromTarget(item, battler, user, move, switched_battlers, battle)
    AfterMoveUseFromTarget.trigger(item, battler, user, move, switched_battlers, battle)
  end

  def self.triggerAfterMoveUseFromUser(item, user, targets, move, num_hits, battle)
    AfterMoveUseFromUser.trigger(item, user, targets, move, num_hits, battle)
  end

  def self.triggerOnEndOfUsingMove(item, battler, battle, forced)
    return trigger(OnEndOfUsingMove, item, battler, battle, forced)
  end

  def self.triggerOnEndOfUsingMoveStatRestore(item, battler, battle, forced)
    return trigger(OnEndOfUsingMoveStatRestore, item, battler, battle, forced)
  end

  #=============================================================================

  def self.triggerExpGainModifier(item, battler, exp)
    return trigger(ExpGainModifier, item, battler, exp, ret: -1)
  end

  def self.triggerEVGainModifier(item, battler, ev_array)
    return false if !EVGainModifier[item]
    EVGainModifier.trigger(item, battler, ev_array)
    return true
  end

  #=============================================================================

  def self.triggerWeatherExtender(item, weather, duration, battler, battle)
    return trigger(WeatherExtender, item, weather, duration, battler, battle, ret: duration)
  end

  def self.triggerTerrainExtender(item, terrain, duration, battler, battle)
    return trigger(TerrainExtender, item, terrain, duration, battler, battle, ret: duration)
  end

  def self.triggerTerrainStatBoost(item, battler, battle)
    return trigger(TerrainStatBoost, item, battler, battle)
  end

  #=============================================================================

  def self.triggerEndOfRoundHealing(item, battler, battle)
    EndOfRoundHealing.trigger(item, battler, battle)
  end

  def self.triggerEndOfRoundEffect(item, battler, battle)
    EndOfRoundEffect.trigger(item, battler, battle)
  end

  #=============================================================================

  def self.triggerCertainSwitching(item, switcher, battle)
    return trigger(CertainSwitching, item, switcher, battle)
  end

  def self.triggerTrappingByTarget(item, switcher, bearer, battle)
    return trigger(TrappingByTarget, item, switcher, bearer, battle)
  end

  def self.triggerOnSwitchIn(item, battler, battle)
    OnSwitchIn.trigger(item, battler, battle)
  end

  def self.triggerOnIntimidated(item, battler, battle)
    return trigger(OnIntimidated, item, battler, battle)
  end

  #=============================================================================

  def self.triggerCertainEscapeFromBattle(item, battler)
    return trigger(CertainEscapeFromBattle, item, battler)
  end
end

#===============================================================================
# SpeedCalc handlers
#===============================================================================

Battle::ItemEffects::SpeedCalc.add(:CHOICESCARF,
  proc { |item, battler, mult|
    next mult * 1.5
  }
)

Battle::ItemEffects::SpeedCalc.add(:IRONBALL,
  proc { |item, battler, mult|
    next mult / 2
  }
)

Battle::ItemEffects::SpeedCalc.add(:MACHOBRACE,
  proc { |item, battler, mult|
    next mult / 2
  }
)

Battle::ItemEffects::SpeedCalc.copy(:MACHOBRACE, :POWERANKLET, :POWERBAND,
                                                 :POWERBELT, :POWERBRACER,
                                                 :POWERLENS, :POWERWEIGHT)

Battle::ItemEffects::SpeedCalc.add(:QUICKPOWDER,
  proc { |item, battler, mult|
    next mult * 2 if battler.isSpecies?(:DITTO) && !battler.effects[PBEffects::Transform]
  }
)

#===============================================================================
# WeightCalc handlers
#===============================================================================

Battle::ItemEffects::WeightCalc.add(:FLOATSTONE,
  proc { |item, battler, w|
    next [w / 2, 1].max
  }
)

#===============================================================================
# HPHeal handlers
#===============================================================================

Battle::ItemEffects::HPHeal.add(:AGUAVBERRY,
  proc { |item, battler, battle, forced|
    next battler.pbConfusionBerry(item, forced, :SPECIAL_DEFENSE,
       _INTL("For {1}, the {2} was too bitter!", battler.pbThis(true), GameData::Item.get(item).name)
    )
  }
)

Battle::ItemEffects::HPHeal.add(:APICOTBERRY,
  proc { |item, battler, battle, forced|
    next battler.pbStatIncreasingBerry(item, forced, :SPECIAL_DEFENSE)
  }
)

Battle::ItemEffects::HPHeal.add(:BERRYJUICE,
  proc { |item, battler, battle, forced|
    next false if !battler.canHeal?
    next false if !forced && battler.hp > battler.totalhp / 2
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] Forced consuming of #{itemName}") if forced
    battle.pbCommonAnimation("UseItem", battler) if !forced
    battler.pbRecoverHP(20)
    if forced
      battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!", battler.pbThis, itemName))
    end
    next true
  }
)

Battle::ItemEffects::HPHeal.add(:FIGYBERRY,
  proc { |item, battler, battle, forced|
    next battler.pbConfusionBerry(item, forced, :ATTACK,
       _INTL("For {1}, the {2} was too spicy!", battler.pbThis(true), GameData::Item.get(item).name)
    )
  }
)

Battle::ItemEffects::HPHeal.add(:GANLONBERRY,
  proc { |item, battler, battle, forced|
    next battler.pbStatIncreasingBerry(item, forced, :DEFENSE)
  }
)

Battle::ItemEffects::HPHeal.add(:IAPAPABERRY,
  proc { |item, battler, battle, forced|
    next battler.pbConfusionBerry(item, forced, :DEFENSE,
       _INTL("For {1}, the {2} was too sour!", battler.pbThis(true), GameData::Item.get(item).name)
    )
  }
)

Battle::ItemEffects::HPHeal.add(:LANSATBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumePinchBerry?
    next false if battler.effects[PBEffects::FocusEnergy] >= 2
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battler.effects[PBEffects::FocusEnergy] = 2
    itemName = GameData::Item.get(item).name
    if forced
      battle.pbDisplay(_INTL("{1} got pumped from the {2}!", battler.pbThis, itemName))
    else
      battle.pbDisplay(_INTL("{1} used its {2} to get pumped!", battler.pbThis, itemName))
    end
    next true
  }
)

Battle::ItemEffects::HPHeal.add(:LIECHIBERRY,
  proc { |item, battler, battle, forced|
    next battler.pbStatIncreasingBerry(item, forced, :ATTACK)
  }
)

Battle::ItemEffects::HPHeal.add(:MAGOBERRY,
  proc { |item, battler, battle, forced|
    next battler.pbConfusionBerry(item, forced, :SPEED,
       _INTL("For {1}, the {2} was too sweet!", battler.pbThis(true), GameData::Item.get(item).name)
    )
  }
)

Battle::ItemEffects::HPHeal.add(:MICLEBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumePinchBerry?
    next false if !battler.effects[PBEffects::MicleBerry]
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battler.effects[PBEffects::MicleBerry] = true
    itemName = GameData::Item.get(item).name
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1} boosted the accuracy of its next move!", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} boosted the accuracy of its next move using its {2}!",
         battler.pbThis, itemName))
    end
    next true
  }
)

Battle::ItemEffects::HPHeal.add(:ORANBERRY,
  proc { |item, battler, battle, forced|
    next false if !battler.canHeal?
    next false if !forced && !battler.canConsumePinchBerry?(false)
    amt = 10
    ripening = false
    if battler.hasActiveAbility?(:RIPEN)
      battle.pbShowAbilitySplash(battler, forced)
      amt *= 2
      ripening = true
    end
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battle.pbHideAbilitySplash(battler) if ripening
    battler.pbRecoverHP(amt)
    itemName = GameData::Item.get(item).name
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!", battler.pbThis, itemName))
    end
    next true
  }
)

Battle::ItemEffects::HPHeal.add(:PETAYABERRY,
  proc { |item, battler, battle, forced|
    next battler.pbStatIncreasingBerry(item, forced, :SPECIAL_ATTACK)
  }
)

Battle::ItemEffects::HPHeal.add(:SALACBERRY,
  proc { |item, battler, battle, forced|
    next battler.pbStatIncreasingBerry(item, forced, :SPEED)
  }
)

Battle::ItemEffects::HPHeal.add(:SITRUSBERRY,
  proc { |item, battler, battle, forced|
    next false if !battler.canHeal?
    next false if !forced && !battler.canConsumePinchBerry?(false)
    amt = battler.totalhp / 4
    ripening = false
    if battler.hasActiveAbility?(:RIPEN)
      battle.pbShowAbilitySplash(battler, forced)
      amt *= 2
      ripening = true
    end
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battle.pbHideAbilitySplash(battler) if ripening
    battler.pbRecoverHP(amt)
    itemName = GameData::Item.get(item).name
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!", battler.pbThis, itemName))
    end
    next true
  }
)

Battle::ItemEffects::HPHeal.add(:STARFBERRY,
  proc { |item, battler, battle, forced|
    stats = []
    GameData::Stat.each_main_battle { |s| stats.push(s.id) if battler.pbCanRaiseStatStage?(s.id, battler) }
    next false if stats.length == 0
    stat = stats[battle.pbRandom(stats.length)]
    next battler.pbStatIncreasingBerry(item, forced, stat, 2)
  }
)

Battle::ItemEffects::HPHeal.add(:WIKIBERRY,
  proc { |item, battler, battle, forced|
    next battler.pbConfusionBerry(item, forced, :SPECIAL_ATTACK,
       _INTL("For {1}, the {2} was too dry!", battler.pbThis(true), GameData::Item.get(item).name)
    )
  }
)

#===============================================================================
# OnStatLoss handlers
#===============================================================================
Battle::ItemEffects::OnStatLoss.add(:EJECTPACK,
  proc { |item, battler, move_user, battle|
    next false if battler.effects[PBEffects::SkyDrop] >= 0 ||
                  battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSkyTargetCannotAct")   # Sky Drop
    next false if battle.pbAllFainted?(battler.idxOpposingSide)
    next false if battler.wild?   # Wild Pokémon can't eject
    next false if !battle.pbCanSwitchOut?(battler.index)   # Battler can't switch out
    next false if !battle.pbCanChooseNonActive?(battler.index)   # No Pokémon can switch in
    battle.pbCommonAnimation("UseItem", battler)
    battle.pbDisplay(_INTL("{1} is switched out by the {2}!", battler.pbThis, battler.itemName))
    battler.pbConsumeItem(true, false)
    if battle.endOfRound   # Just switch out
      battle.scene.pbRecall(battler.index) if !battler.fainted?
      battler.pbAbilitiesOnSwitchOut   # Inc. primordial weather check
      next true
    end
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next false if newPkmn < 0   # Shouldn't ever do this
    battle.pbRecallAndReplace(battler.index, newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    battle.moldBreaker = false if move_user && battler.index == move_user.index
    battle.pbOnBattlerEnteringBattle(battler.index)
    next true
  }
)

#===============================================================================
# StatusCure handlers
#===============================================================================

Battle::ItemEffects::StatusCure.add(:ASPEARBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.status != :FROZEN
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battler.pbCureStatus(forced)
    battle.pbDisplay(_INTL("{1}'s {2} defrosted it!", battler.pbThis, itemName)) if !forced
    next true
  }
)

Battle::ItemEffects::StatusCure.add(:CHERIBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.status != :PARALYSIS
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battler.pbCureStatus(forced)
    battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!", battler.pbThis, itemName)) if !forced
    next true
  }
)

Battle::ItemEffects::StatusCure.add(:CHESTOBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.status != :SLEEP
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battler.pbCureStatus(forced)
    battle.pbDisplay(_INTL("{1}'s {2} woke it up!", battler.pbThis, itemName)) if !forced
    next true
  }
)

Battle::ItemEffects::StatusCure.add(:LUMBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.status == :NONE &&
                  battler.effects[PBEffects::Confusion] == 0
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    oldStatus = battler.status
    oldConfusion = (battler.effects[PBEffects::Confusion] > 0)
    battler.pbCureStatus(forced)
    battler.pbCureConfusion
    if forced
      battle.pbDisplay(_INTL("{1} snapped out of its confusion.", battler.pbThis)) if oldConfusion
    else
      case oldStatus
      when :SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!", battler.pbThis, itemName))
      when :POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!", battler.pbThis, itemName))
      when :BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!", battler.pbThis, itemName))
      when :PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!", battler.pbThis, itemName))
      when :FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!", battler.pbThis, itemName))
      end
      if oldConfusion
        battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!", battler.pbThis, itemName))
      end
    end
    next true
  }
)

Battle::ItemEffects::StatusCure.add(:MENTALHERB,
  proc { |item, battler, battle, forced|
    next false if battler.effects[PBEffects::Attract] == -1 &&
                  battler.effects[PBEffects::Taunt] == 0 &&
                  battler.effects[PBEffects::Encore] == 0 &&
                  !battler.effects[PBEffects::Torment] &&
                  battler.effects[PBEffects::Disable] == 0 &&
                  battler.effects[PBEffects::HealBlock] == 0
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
    battle.pbCommonAnimation("UseItem", battler) if !forced
    if battler.effects[PBEffects::Attract] >= 0
      if forced
        battle.pbDisplay(_INTL("{1} got over its infatuation.", battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} cured its infatuation status using its {2}!",
           battler.pbThis, itemName))
      end
      battler.pbCureAttract
    end
    battle.pbDisplay(_INTL("{1}'s taunt wore off!", battler.pbThis)) if battler.effects[PBEffects::Taunt] > 0
    battler.effects[PBEffects::Taunt] = 0
    battle.pbDisplay(_INTL("{1}'s encore ended!", battler.pbThis)) if battler.effects[PBEffects::Encore] > 0
    battler.effects[PBEffects::Encore]     = 0
    battler.effects[PBEffects::EncoreMove] = nil
    battle.pbDisplay(_INTL("{1}'s torment wore off!", battler.pbThis)) if battler.effects[PBEffects::Torment]
    battler.effects[PBEffects::Torment] = false
    battle.pbDisplay(_INTL("{1} is no longer disabled!", battler.pbThis)) if battler.effects[PBEffects::Disable] > 0
    battler.effects[PBEffects::Disable] = 0
    battle.pbDisplay(_INTL("{1}'s Heal Block wore off!", battler.pbThis)) if battler.effects[PBEffects::HealBlock] > 0
    battler.effects[PBEffects::HealBlock] = 0
    next true
  }
)

Battle::ItemEffects::StatusCure.add(:PECHABERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.status != :POISON
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battler.pbCureStatus(forced)
    battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!", battler.pbThis, itemName)) if !forced
    next true
  }
)

Battle::ItemEffects::StatusCure.add(:PERSIMBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.effects[PBEffects::Confusion] == 0
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battler.pbCureConfusion
    if forced
      battle.pbDisplay(_INTL("{1} snapped out of its confusion.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!", battler.pbThis,
         itemName))
    end
    next true
  }
)

Battle::ItemEffects::StatusCure.add(:RAWSTBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.status != :BURN
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battler.pbCureStatus(forced)
    battle.pbDisplay(_INTL("{1}'s {2} healed its burn!", battler.pbThis, itemName)) if !forced
    next true
  }
)

#===============================================================================
# PriorityBracketChange handlers
#===============================================================================

Battle::ItemEffects::PriorityBracketChange.add(:CUSTAPBERRY,
  proc { |item, battler, battle|
    next 1 if battler.canConsumePinchBerry?
  }
)

Battle::ItemEffects::PriorityBracketChange.add(:LAGGINGTAIL,
  proc { |item, battler, battle|
    next -1
  }
)

Battle::ItemEffects::PriorityBracketChange.copy(:LAGGINGTAIL, :FULLINCENSE)

Battle::ItemEffects::PriorityBracketChange.add(:QUICKCLAW,
  proc { |item, battler, battle|
    next 1 if battle.pbRandom(100) < 20
  }
)

#===============================================================================
# PriorityBracketUse handlers
#===============================================================================

Battle::ItemEffects::PriorityBracketUse.add(:CUSTAPBERRY,
  proc { |item, battler, battle|
    battle.pbCommonAnimation("EatBerry", battler)
    battle.pbDisplay(_INTL("{1}'s {2} let it move first!", battler.pbThis, battler.itemName))
    battler.pbConsumeItem
  }
)

Battle::ItemEffects::PriorityBracketUse.add(:QUICKCLAW,
  proc { |item, battler, battle|
    battle.pbCommonAnimation("UseItem", battler)
    battle.pbDisplay(_INTL("{1}'s {2} let it move first!", battler.pbThis, battler.itemName))
  }
)

#===============================================================================
# OnMissingTarget handlers
#===============================================================================

Battle::ItemEffects::OnMissingTarget.add(:BLUNDERPOLICY,
  proc { |item, user, target, move, hit_num, battle|
    next if hit_num > 0 || target.damageState.invulnerable
    next if ["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(move.function_code)
    next if !user.pbCanRaiseStatStage?(:SPEED, user)
    battle.pbCommonAnimation("UseItem", user)
    user.pbRaiseStatStageByCause(:SPEED, 2, user, user.itemName)
    battle.pbDisplay(_INTL("The {1} was used up...", user.itemName))
    user.pbHeldItemTriggered(item)
  }
)

#===============================================================================
# AccuracyCalcFromUser handlers
#===============================================================================

Battle::ItemEffects::AccuracyCalcFromUser.add(:WIDELENS,
  proc { |item, mods, user, target, move, type|
    mods[:accuracy_multiplier] *= 1.1
  }
)

Battle::ItemEffects::AccuracyCalcFromUser.add(:ZOOMLENS,
  proc { |item, mods, user, target, move, type|
    if (target.battle.choices[target.index][0] != :UseMove &&
       target.battle.choices[target.index][0] != :Shift) ||
       target.movedThisRound?
      mods[:accuracy_multiplier] *= 1.2
    end
  }
)

#===============================================================================
# AccuracyCalcFromTarget handlers
#===============================================================================

Battle::ItemEffects::AccuracyCalcFromTarget.add(:BRIGHTPOWDER,
  proc { |item, mods, user, target, move, type|
    mods[:accuracy_multiplier] *= 0.9
  }
)

Battle::ItemEffects::AccuracyCalcFromTarget.copy(:BRIGHTPOWDER, :LAXINCENSE)

#===============================================================================
# DamageCalcFromUser handlers
#===============================================================================

Battle::ItemEffects::DamageCalcFromUser.add(:ADAMANTORB,
  proc { |item, user, target, move, mults, power, type|
    if user.isSpecies?(:DIALGA) && [:DRAGON, :STEEL].include?(type)
      mults[:power_multiplier] *= 1.2
    end
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:BLACKBELT,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :FIGHTING
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:BLACKBELT, :FISTPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:BLACKGLASSES,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :DARK
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:BLACKGLASSES, :DREADPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:BUGGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:BUG, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:CHARCOAL,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :FIRE
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:CHARCOAL, :FLAMEPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:CHOICEBAND,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.5 if move.physicalMove?
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:CHOICESPECS,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.5 if move.specialMove?
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:DARKGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:DARK, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:DEEPSEATOOTH,
  proc { |item, user, target, move, mults, power, type|
    if user.isSpecies?(:CLAMPERL) && move.specialMove?
      mults[:attack_multiplier] *= 2
    end
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:DRAGONFANG,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :DRAGON
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:DRAGONFANG, :DRACOPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:DRAGONGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:DRAGON, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:ELECTRICGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:ELECTRIC, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:EXPERTBELT,
  proc { |item, user, target, move, mults, power, type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 1.2
    end
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:FAIRYGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FAIRY, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:FIGHTINGGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FIGHTING, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:FIREGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FIRE, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:FLYINGGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FLYING, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GHOSTGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:GHOST, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GRASSGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:GRASS, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GRISEOUSORB,
  proc { |item, user, target, move, mults, power, type|
    if user.isSpecies?(:GIRATINA) && [:DRAGON, :GHOST].include?(type)
      mults[:power_multiplier] *= 1.2
    end
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GROUNDGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:GROUND, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:HARDSTONE,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :ROCK
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:HARDSTONE, :STONEPLATE, :ROCKINCENSE)

Battle::ItemEffects::DamageCalcFromUser.add(:ICEGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:ICE, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:LIFEORB,
  proc { |item, user, target, move, mults, power, type|
    if !move.is_a?(Battle::Move::Confusion)
      mults[:final_damage_multiplier] *= 1.3
    end
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:LIGHTBALL,
  proc { |item, user, target, move, mults, power, type|
    mults[:attack_multiplier] *= 2 if user.isSpecies?(:PIKACHU)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:LUSTROUSORB,
  proc { |item, user, target, move, mults, power, type|
    if user.isSpecies?(:PALKIA) && [:DRAGON, :WATER].include?(type)
      mults[:power_multiplier] *= 1.2
    end
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:MAGNET,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :ELECTRIC
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:MAGNET, :ZAPPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:METALCOAT,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :STEEL
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:METALCOAT, :IRONPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:METRONOME,
  proc { |item, user, target, move, mults, power, type|
    met = 1 + (0.2 * [user.effects[PBEffects::Metronome], 5].min)
    mults[:final_damage_multiplier] *= met
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:MIRACLESEED,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :GRASS
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:MIRACLESEED, :MEADOWPLATE, :ROSEINCENSE)

Battle::ItemEffects::DamageCalcFromUser.add(:MUSCLEBAND,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.1 if move.physicalMove?
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:MYSTICWATER,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :WATER
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:MYSTICWATER, :SPLASHPLATE, :SEAINCENSE, :WAVEINCENSE)

Battle::ItemEffects::DamageCalcFromUser.add(:NEVERMELTICE,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :ICE
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:NEVERMELTICE, :ICICLEPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:NORMALGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:NORMAL, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:PIXIEPLATE,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :FAIRY
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:POISONBARB,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :POISON
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:POISONBARB, :TOXICPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:POISONGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:POISON, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:PSYCHICGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:PSYCHIC, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:ROCKGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:ROCK, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:SHARPBEAK,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :FLYING
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:SHARPBEAK, :SKYPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:SILKSCARF,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :NORMAL
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:SILVERPOWDER,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :BUG
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:SILVERPOWDER, :INSECTPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:SOFTSAND,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :GROUND
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:SOFTSAND, :EARTHPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:SOULDEW,
  proc { |item, user, target, move, mults, power, type|
    next if !user.isSpecies?(:LATIAS) && !user.isSpecies?(:LATIOS)
    if Settings::SOUL_DEW_POWERS_UP_TYPES
      mults[:final_damage_multiplier] *= 1.2 if [:DRAGON, :PSYCHIC].include?(type)
    elsif move.specialMove? && !user.battle.rules["souldewclause"]
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:SPELLTAG,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :GHOST
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:SPELLTAG, :SPOOKYPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:STEELGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:STEEL, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:THICKCLUB,
  proc { |item, user, target, move, mults, power, type|
    if (user.isSpecies?(:CUBONE) || user.isSpecies?(:MAROWAK)) && move.physicalMove?
      mults[:attack_multiplier] *= 2
    end
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:TWISTEDSPOON,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :PSYCHIC
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:TWISTEDSPOON, :MINDPLATE, :ODDINCENSE)

Battle::ItemEffects::DamageCalcFromUser.add(:WATERGEM,
  proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:WATER, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:WISEGLASSES,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.1 if move.specialMove?
  }
)

#===============================================================================
# DamageCalcFromTarget handlers
# NOTE: Species-specific held items consider the original species, not the
#       transformed species, and still work while transformed. The exceptions
#       are Metal/Quick Powder, which don't work if the holder is transformed.
#===============================================================================

Battle::ItemEffects::DamageCalcFromTarget.add(:ASSAULTVEST,
  proc { |item, user, target, move, mults, power, type|
    mults[:defense_multiplier] *= 1.5 if move.specialMove?
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:BABIRIBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:STEEL, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:CHARTIBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:ROCK, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:CHILANBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:NORMAL, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:CHOPLEBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:FIGHTING, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:COBABERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:FLYING, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:COLBURBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:DARK, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:DEEPSEASCALE,
  proc { |item, user, target, move, mults, power, type|
    if target.isSpecies?(:CLAMPERL) && move.specialMove?
      mults[:defense_multiplier] *= 2
    end
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:EVIOLITE,
  proc { |item, user, target, move, mults, power, type|
    # NOTE: Eviolite cares about whether the Pokémon itself can evolve, which
    #       means it also cares about the Pokémon's form. Some forms cannot
    #       evolve even if the species generally can, and such forms are not
    #       affected by Eviolite.
    if target.pokemon.species_data.get_evolutions(true).length > 0
      mults[:defense_multiplier] *= 1.5
    end
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:HABANBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:DRAGON, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:KASIBBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:GHOST, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:KEBIABERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:POISON, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:METALPOWDER,
  proc { |item, user, target, move, mults, power, type|
    if target.isSpecies?(:DITTO) && !target.effects[PBEffects::Transform]
      mults[:defense_multiplier] *= 1.5
    end
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:OCCABERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:FIRE, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:PASSHOBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:WATER, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:PAYAPABERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:PSYCHIC, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:RINDOBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:GRASS, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ROSELIBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:FAIRY, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:SHUCABERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:GROUND, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:SOULDEW,
  proc { |item, user, target, move, mults, power, type|
    next if Settings::SOUL_DEW_POWERS_UP_TYPES
    next if !target.isSpecies?(:LATIAS) && !target.isSpecies?(:LATIOS)
    if move.specialMove? && !user.battle.rules["souldewclause"]
      mults[:defense_multiplier] *= 1.5
    end
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:TANGABERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:BUG, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:WACANBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:ELECTRIC, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:YACHEBERRY,
  proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:ICE, type, mults)
  }
)

#===============================================================================
# CriticalCalcFromUser handlers
#===============================================================================

Battle::ItemEffects::CriticalCalcFromUser.add(:LUCKYPUNCH,
  proc { |item, user, target, c|
    next c + 2 if user.isSpecies?(:CHANSEY)
  }
)

Battle::ItemEffects::CriticalCalcFromUser.add(:RAZORCLAW,
  proc { |item, user, target, c|
    next c + 1
  }
)

Battle::ItemEffects::CriticalCalcFromUser.copy(:RAZORCLAW, :SCOPELENS)

Battle::ItemEffects::CriticalCalcFromUser.add(:LEEK,
  proc { |item, user, target, c|
    next c + 2 if user.isSpecies?(:FARFETCHD) || user.isSpecies?(:SIRFETCHD)
  }
)

Battle::ItemEffects::CriticalCalcFromUser.copy(:LEEK, :STICK)

#===============================================================================
# CriticalCalcFromTarget handlers
#===============================================================================

# There aren't any!

#===============================================================================
# OnBeingHit handlers
#===============================================================================

Battle::ItemEffects::OnBeingHit.add(:ABSORBBULB,
  proc { |item, user, target, move, battle|
    next if move.calcType != :WATER
    next if !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK, target)
    battle.pbCommonAnimation("UseItem", target)
    target.pbRaiseStatStageByCause(:SPECIAL_ATTACK, 1, target, target.itemName)
    target.pbHeldItemTriggered(item)
  }
)

Battle::ItemEffects::OnBeingHit.add(:AIRBALLOON,
  proc { |item, user, target, move, battle|
    battle.pbDisplay(_INTL("{1}'s {2} popped!", target.pbThis, target.itemName))
    target.pbConsumeItem(false, true)
    target.pbSymbiosis
  }
)

Battle::ItemEffects::OnBeingHit.add(:CELLBATTERY,
  proc { |item, user, target, move, battle|
    next if move.calcType != :ELECTRIC
    next if !target.pbCanRaiseStatStage?(:ATTACK, target)
    battle.pbCommonAnimation("UseItem", target)
    target.pbRaiseStatStageByCause(:ATTACK, 1, target, target.itemName)
    target.pbHeldItemTriggered(item)
  }
)

Battle::ItemEffects::OnBeingHit.add(:ENIGMABERRY,
  proc { |item, user, target, move, battle|
    next if target.damageState.substitute ||
            target.damageState.disguise || target.damageState.iceFace
    next if !Effectiveness.super_effective?(target.damageState.typeMod)
    if Battle::ItemEffects.triggerOnBeingHitPositiveBerry(item, target, battle, false)
      target.pbHeldItemTriggered(item)
    end
  }
)

Battle::ItemEffects::OnBeingHit.add(:JABOCABERRY,
  proc { |item, user, target, move, battle|
    next if !target.canConsumeBerry?
    next if !move.physicalMove?
    next if !user.takesIndirectDamage?
    amt = user.totalhp / 8
    ripening = false
    if target.hasActiveAbility?(:RIPEN)
      battle.pbShowAbilitySplash(target)
      amt *= 2
      ripening = true
    end
    battle.pbCommonAnimation("EatBerry", target)
    battle.pbHideAbilitySplash(target) if ripening
    battle.scene.pbDamageAnimation(user)
    user.pbReduceHP(amt, false)
    battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!", target.pbThis,
       target.itemName, user.pbThis(true)))
    target.pbHeldItemTriggered(item)
  }
)

# NOTE: Kee Berry supposedly shouldn't trigger if the user has Sheer Force, but
#       I'm ignoring this. Weakness Policy has the same kind of effect and
#       nowhere says it should be stopped by Sheer Force. I suspect this
#       stoppage is either a false report that no one ever corrected, or an
#       effect that later changed and wasn't noticed.
Battle::ItemEffects::OnBeingHit.add(:KEEBERRY,
  proc { |item, user, target, move, battle|
    next if !move.physicalMove?
    if Battle::ItemEffects.triggerOnBeingHitPositiveBerry(item, target, battle, false)
      target.pbHeldItemTriggered(item)
    end
  }
)

Battle::ItemEffects::OnBeingHit.add(:LUMINOUSMOSS,
  proc { |item, user, target, move, battle|
    next if move.calcType != :WATER
    next if !target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, target)
    battle.pbCommonAnimation("UseItem", target)
    target.pbRaiseStatStageByCause(:SPECIAL_DEFENSE, 1, target, target.itemName)
    target.pbHeldItemTriggered(item)
  }
)

# NOTE: Maranga Berry supposedly shouldn't trigger if the user has Sheer Force,
#       but I'm ignoring this. Weakness Policy has the same kind of effect and
#       nowhere says it should be stopped by Sheer Force. I suspect this
#       stoppage is either a false report that no one ever corrected, or an
#       effect that later changed and wasn't noticed.
Battle::ItemEffects::OnBeingHit.add(:MARANGABERRY,
  proc { |item, user, target, move, battle|
    next if !move.specialMove?
    if Battle::ItemEffects.triggerOnBeingHitPositiveBerry(item, target, battle, false)
      target.pbHeldItemTriggered(item)
    end
  }
)

Battle::ItemEffects::OnBeingHit.add(:ROCKYHELMET,
  proc { |item, user, target, move, battle|
    next if !move.pbContactMove?(user) || !user.affectedByContactEffect?
    next if !user.takesIndirectDamage?
    battle.scene.pbDamageAnimation(user)
    user.pbReduceHP(user.totalhp / 6, false)
    battle.pbDisplay(_INTL("{1} was hurt by the {2}!", user.pbThis, target.itemName))
  }
)

Battle::ItemEffects::OnBeingHit.add(:ROWAPBERRY,
  proc { |item, user, target, move, battle|
    next if !target.canConsumeBerry?
    next if !move.specialMove?
    next if !user.takesIndirectDamage?
    amt = user.totalhp / 8
    ripening = false
    if target.hasActiveAbility?(:RIPEN)
      battle.pbShowAbilitySplash(target)
      amt *= 2
      ripening = true
    end
    battle.pbCommonAnimation("EatBerry", target)
    battle.pbHideAbilitySplash(target) if ripening
    battle.scene.pbDamageAnimation(user)
    user.pbReduceHP(amt, false)
    battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!", target.pbThis,
       target.itemName, user.pbThis(true)))
    target.pbHeldItemTriggered(item)
  }
)

Battle::ItemEffects::OnBeingHit.add(:SNOWBALL,
  proc { |item, user, target, move, battle|
    next if move.calcType != :ICE
    next if !target.pbCanRaiseStatStage?(:ATTACK, target)
    battle.pbCommonAnimation("UseItem", target)
    target.pbRaiseStatStageByCause(:ATTACK, 1, target, target.itemName)
    target.pbHeldItemTriggered(item)
  }
)

Battle::ItemEffects::OnBeingHit.add(:STICKYBARB,
  proc { |item, user, target, move, battle|
    next if !move.pbContactMove?(user) || !user.affectedByContactEffect?
    next if user.fainted? || user.item
    user.item = target.item
    target.item = nil
    target.effects[PBEffects::Unburden] = true if target.hasActiveAbility?(:UNBURDEN)
    if battle.wildBattle? && !user.opposes? &&
       !user.initialItem && user.item == target.initialItem
      user.setInitialItem(user.item)
      target.setInitialItem(nil)
    end
    battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
       target.pbThis, user.itemName, user.pbThis(true)))
  }
)

Battle::ItemEffects::OnBeingHit.add(:WEAKNESSPOLICY,
  proc { |item, user, target, move, battle|
    next if target.damageState.disguise || target.damageState.iceFace
    next if !Effectiveness.super_effective?(target.damageState.typeMod)
    next if !target.pbCanRaiseStatStage?(:ATTACK, target) &&
            !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK, target)
    battle.pbCommonAnimation("UseItem", target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:ATTACK, target)
      target.pbRaiseStatStageByCause(:ATTACK, 2, target, target.itemName, showAnim)
      showAnim = false
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK, target)
      target.pbRaiseStatStageByCause(:SPECIAL_ATTACK, 2, target, target.itemName, showAnim)
    end
    battle.pbDisplay(_INTL("The {1} was used up...", target.itemName))
    target.pbHeldItemTriggered(item)
  }
)

#===============================================================================
# OnBeingHitPositiveBerry handlers
# NOTE: This is for berries that have an effect when Pluck/Bug Bite/Fling
#       forces their use.
#===============================================================================

Battle::ItemEffects::OnBeingHitPositiveBerry.add(:ENIGMABERRY,
  proc { |item, battler, battle, forced|
    next false if !battler.canHeal?
    next false if !forced && !battler.canConsumeBerry?
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    amt = battler.totalhp / 4
    ripening = false
    if battler.hasActiveAbility?(:RIPEN)
      battle.pbShowAbilitySplash(battler, forced)
      amt *= 2
      ripening = true
    end
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battle.pbHideAbilitySplash(battler) if ripening
    battler.pbRecoverHP(amt)
    if forced
      battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!", battler.pbThis, itemName))
    end
    next true
  }
)

Battle::ItemEffects::OnBeingHitPositiveBerry.add(:KEEBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.pbCanRaiseStatStage?(:DEFENSE, battler)
    itemName = GameData::Item.get(item).name
    amt = 1
    ripening = false
    if battler.hasActiveAbility?(:RIPEN)
      battle.pbShowAbilitySplash(battler, forced)
      amt *= 2
      ripening = true
    end
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battle.pbHideAbilitySplash(battler) if ripening
    next battler.pbRaiseStatStageByCause(:DEFENSE, amt, battler, itemName) if !forced
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
    next battler.pbRaiseStatStage(:DEFENSE, amt, battler)
  }
)

Battle::ItemEffects::OnBeingHitPositiveBerry.add(:MARANGABERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
    itemName = GameData::Item.get(item).name
    amt = 1
    ripening = false
    if battler.hasActiveAbility?(:RIPEN)
      battle.pbShowAbilitySplash(battler, forced)
      amt *= 2
      ripening = true
    end
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battle.pbHideAbilitySplash(battler) if ripening
    next battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE, amt, battler, itemName) if !forced
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
    next battler.pbRaiseStatStage(:SPECIAL_DEFENSE, amt, battler)
  }
)

#===============================================================================
# AfterMoveUseFromTarget handlers
#===============================================================================

Battle::ItemEffects::AfterMoveUseFromTarget.add(:EJECTBUTTON,
  proc { |item, battler, user, move, switched_battlers, battle|
    next if !switched_battlers.empty?
    next if battle.pbAllFainted?(battler.idxOpposingSide)
    next if !battle.pbCanChooseNonActive?(battler.index)
    battle.pbCommonAnimation("UseItem", battler)
    battle.pbDisplay(_INTL("{1} is switched out with the {2}!", battler.pbThis, battler.itemName))
    battler.pbConsumeItem(true, false)
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next if newPkmn < 0
    battle.pbRecallAndReplace(battler.index, newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    switched_battlers.push(battler.index)
    battle.moldBreaker = false if battler.index == user.index
    battle.pbOnBattlerEnteringBattle(battler.index)
  }
)

Battle::ItemEffects::AfterMoveUseFromTarget.add(:REDCARD,
  proc { |item, battler, user, move, switched_battlers, battle|
    next if !switched_battlers.empty? || user.fainted?
    newPkmn = battle.pbGetReplacementPokemonIndex(user.index, true)   # Random
    next if newPkmn < 0
    battle.pbCommonAnimation("UseItem", battler)
    battle.pbDisplay(_INTL("{1} held up its {2} against {3}!",
       battler.pbThis, battler.itemName, user.pbThis(true)))
    battler.pbConsumeItem
    if user.hasActiveAbility?(:SUCTIONCUPS) && !battle.moldBreaker
      battle.pbShowAbilitySplash(user)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} anchors itself!", user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} anchors itself with {2}!", user.pbThis, user.abilityName))
      end
      battle.pbHideAbilitySplash(user)
      next
    end
    if user.effects[PBEffects::Ingrain]
      battle.pbDisplay(_INTL("{1} anchored itself with its roots!", user.pbThis))
      next
    end
    battle.pbRecallAndReplace(user.index, newPkmn, true)
    battle.pbDisplay(_INTL("{1} was dragged out!", user.pbThis))
    battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
    switched_battlers.push(user.index)
    battle.moldBreaker = false
    battle.pbOnBattlerEnteringBattle(user.index)
  }
)

#===============================================================================
# AfterMoveUseFromUser handlers
#===============================================================================

Battle::ItemEffects::AfterMoveUseFromUser.add(:LIFEORB,
  proc { |item, user, targets, move, numHits, battle|
    next if !user.takesIndirectDamage?
    next if !move.pbDamagingMove? || numHits == 0
    hitBattler = false
    targets.each do |b|
      hitBattler = true if !b.damageState.unaffected && !b.damageState.substitute
      break if hitBattler
    end
    next if !hitBattler
    PBDebug.log("[Item triggered] #{user.pbThis}'s #{user.itemName} (recoil)")
    user.pbReduceHP(user.totalhp / 10)
    battle.pbDisplay(_INTL("{1} lost some of its HP!", user.pbThis))
    user.pbItemHPHealCheck
    user.pbFaint if user.fainted?
  }
)

# NOTE: In the official games, Shell Bell does not prevent Emergency Exit/Wimp
#       Out triggering even if Shell Bell heals the holder back to 50% HP or
#       more. Essentials ignores this exception.
Battle::ItemEffects::AfterMoveUseFromUser.add(:SHELLBELL,
  proc { |item, user, targets, move, numHits, battle|
    next if !user.canHeal?
    totalDamage = 0
    targets.each { |b| totalDamage += b.damageState.totalHPLost }
    next if totalDamage <= 0
    user.pbRecoverHP(totalDamage / 8)
    battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",
       user.pbThis, user.itemName))
  }
)

Battle::ItemEffects::AfterMoveUseFromUser.add(:THROATSPRAY,
  proc { |item, user, targets, move, numHits, battle|
    next if battle.pbAllFainted?(user.idxOwnSide) ||
            battle.pbAllFainted?(user.idxOpposingSide)
    next if !move.soundMove? || numHits == 0
    next if !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user)
    battle.pbCommonAnimation("UseItem", user)
    user.pbRaiseStatStage(:SPECIAL_ATTACK, 1, user)
    user.pbConsumeItem
  }
)

#===============================================================================
# OnEndOfUsingMove handlers
#===============================================================================

Battle::ItemEffects::OnEndOfUsingMove.add(:LEPPABERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    found_empty_moves = []
    found_partial_moves = []
    battler.pokemon.moves.each_with_index do |move, i|
      next if move.total_pp <= 0 || move.pp == move.total_pp
      (move.pp == 0) ? found_empty_moves.push(i) : found_partial_moves.push(i)
    end
    next false if found_empty_moves.empty? && (!forced || found_partial_moves.empty?)
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    amt = 10
    ripening = false
    if battler.hasActiveAbility?(:RIPEN)
      battle.pbShowAbilitySplash(battler, forced)
      amt *= 2
      ripening = true
    end
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battle.pbHideAbilitySplash(battler) if ripening
    choice = found_empty_moves.first
    choice = found_partial_moves.first if forced && choice.nil?
    pkmnMove = battler.pokemon.moves[choice]
    pkmnMove.pp += amt
    pkmnMove.pp = pkmnMove.total_pp if pkmnMove.pp > pkmnMove.total_pp
    battler.moves[choice].pp = pkmnMove.pp
    moveName = pkmnMove.name
    if forced
      battle.pbDisplay(_INTL("{1} restored its {2}'s PP.", battler.pbThis, moveName))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its {3}'s PP!", battler.pbThis, itemName, moveName))
    end
    next true
  }
)

#===============================================================================
# OnEndOfUsingMoveStatRestore handlers
#===============================================================================

Battle::ItemEffects::OnEndOfUsingMoveStatRestore.add(:WHITEHERB,
  proc { |item, battler, battle, forced|
    reducedStats = false
    GameData::Stat.each_battle do |s|
      next if battler.stages[s.id] >= 0
      battler.stages[s.id] = 0
      battler.statsRaisedThisRound = true
      reducedStats = true
    end
    next false if !reducedStats
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("UseItem", battler) if !forced
    if forced
      battle.pbDisplay(_INTL("{1}'s status returned to normal!", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} returned its status to normal using its {2}!",
         battler.pbThis, itemName))
    end
    next true
  }
)

#===============================================================================
# ExpGainModifier handlers
#===============================================================================

Battle::ItemEffects::ExpGainModifier.add(:LUCKYEGG,
  proc { |item, battler, exp|
    next exp * 3 / 2
  }
)

#===============================================================================
# EVGainModifier handlers
#===============================================================================

Battle::ItemEffects::EVGainModifier.add(:MACHOBRACE,
  proc { |item, battler, evYield|
    evYield.each_key { |stat| evYield[stat] *= 2 }
  }
)

Battle::ItemEffects::EVGainModifier.add(:POWERANKLET,
  proc { |item, battler, evYield|
    evYield[:SPEED] += (Settings::MORE_EVS_FROM_POWER_ITEMS) ? 8 : 4
  }
)

Battle::ItemEffects::EVGainModifier.add(:POWERBAND,
  proc { |item, battler, evYield|
    evYield[:SPECIAL_DEFENSE] += (Settings::MORE_EVS_FROM_POWER_ITEMS) ? 8 : 4
  }
)

Battle::ItemEffects::EVGainModifier.add(:POWERBELT,
  proc { |item, battler, evYield|
    evYield[:DEFENSE] += (Settings::MORE_EVS_FROM_POWER_ITEMS) ? 8 : 4
  }
)

Battle::ItemEffects::EVGainModifier.add(:POWERBRACER,
  proc { |item, battler, evYield|
    evYield[:ATTACK] += (Settings::MORE_EVS_FROM_POWER_ITEMS) ? 8 : 4
  }
)

Battle::ItemEffects::EVGainModifier.add(:POWERLENS,
  proc { |item, battler, evYield|
    evYield[:SPECIAL_ATTACK] += (Settings::MORE_EVS_FROM_POWER_ITEMS) ? 8 : 4
  }
)

Battle::ItemEffects::EVGainModifier.add(:POWERWEIGHT,
  proc { |item, battler, evYield|
    evYield[:HP] += (Settings::MORE_EVS_FROM_POWER_ITEMS) ? 8 : 4
  }
)

#===============================================================================
# WeatherExtender handlers
#===============================================================================

Battle::ItemEffects::WeatherExtender.add(:DAMPROCK,
  proc { |item, weather, duration, battler, battle|
    next 8 if weather == :Rain
  }
)

Battle::ItemEffects::WeatherExtender.add(:HEATROCK,
  proc { |item, weather, duration, battler, battle|
    next 8 if weather == :Sun
  }
)

Battle::ItemEffects::WeatherExtender.add(:ICYROCK,
  proc { |item, weather, duration, battler, battle|
    next 8 if weather == :Hail
  }
)

Battle::ItemEffects::WeatherExtender.add(:SMOOTHROCK,
  proc { |item, weather, duration, battler, battle|
    next 8 if weather == :Sandstorm
  }
)

#===============================================================================
# TerrainExtender handlers
#===============================================================================

Battle::ItemEffects::TerrainExtender.add(:TERRAINEXTENDER,
  proc { |item, terrain, duration, battler, battle|
    next 8
  }
)

#===============================================================================
# TerrainStatBoost handlers
#===============================================================================

Battle::ItemEffects::TerrainStatBoost.add(:ELECTRICSEED,
  proc { |item, battler, battle|
    next false if battle.field.terrain != :Electric
    next false if !battler.pbCanRaiseStatStage?(:DEFENSE, battler)
    itemName = GameData::Item.get(item).name
    battle.pbCommonAnimation("UseItem", battler)
    next battler.pbRaiseStatStageByCause(:DEFENSE, 1, battler, itemName)
  }
)

Battle::ItemEffects::TerrainStatBoost.add(:GRASSYSEED,
  proc { |item, battler, battle|
    next false if battle.field.terrain != :Grassy
    next false if !battler.pbCanRaiseStatStage?(:DEFENSE, battler)
    itemName = GameData::Item.get(item).name
    battle.pbCommonAnimation("UseItem", battler)
    next battler.pbRaiseStatStageByCause(:DEFENSE, 1, battler, itemName)
  }
)

Battle::ItemEffects::TerrainStatBoost.add(:MISTYSEED,
  proc { |item, battler, battle|
    next false if battle.field.terrain != :Misty
    next false if !battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
    itemName = GameData::Item.get(item).name
    battle.pbCommonAnimation("UseItem", battler)
    next battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE, 1, battler, itemName)
  }
)

Battle::ItemEffects::TerrainStatBoost.add(:PSYCHICSEED,
  proc { |item, battler, battle|
    next false if battle.field.terrain != :Psychic
    next false if !battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
    itemName = GameData::Item.get(item).name
    battle.pbCommonAnimation("UseItem", battler)
    next battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE, 1, battler, itemName)
  }
)

#===============================================================================
# EndOfRoundHealing handlers
#===============================================================================

Battle::ItemEffects::EndOfRoundHealing.add(:BLACKSLUDGE,
  proc { |item, battler, battle|
    if battler.pbHasType?(:POISON)
      next if !battler.canHeal?
      battle.pbCommonAnimation("UseItem", battler)
      battler.pbRecoverHP(battler.totalhp / 16)
      battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",
         battler.pbThis, battler.itemName))
    elsif battler.takesIndirectDamage?
      battle.pbCommonAnimation("UseItem", battler)
      battler.pbTakeEffectDamage(battler.totalhp / 8) do |hp_lost|
        battle.pbDisplay(_INTL("{1} is hurt by its {2}!", battler.pbThis, battler.itemName))
      end
    end
  }
)

Battle::ItemEffects::EndOfRoundHealing.add(:LEFTOVERS,
  proc { |item, battler, battle|
    next if !battler.canHeal?
    battle.pbCommonAnimation("UseItem", battler)
    battler.pbRecoverHP(battler.totalhp / 16)
    battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",
       battler.pbThis, battler.itemName))
  }
)

#===============================================================================
# EndOfRoundEffect handlers
#===============================================================================

Battle::ItemEffects::EndOfRoundEffect.add(:FLAMEORB,
  proc { |item, battler, battle|
    next if !battler.pbCanBurn?(battler, false)
    battler.pbBurn(nil, _INTL("{1} was burned by the {2}!", battler.pbThis, battler.itemName))
  }
)

Battle::ItemEffects::EndOfRoundEffect.add(:STICKYBARB,
  proc { |item, battler, battle|
    next if !battler.takesIndirectDamage?
    battle.scene.pbDamageAnimation(battler)
    battler.pbTakeEffectDamage(battler.totalhp / 8, false) do |hp_lost|
      battle.pbDisplay(_INTL("{1} is hurt by its {2}!", battler.pbThis, battler.itemName))
    end
  }
)

Battle::ItemEffects::EndOfRoundEffect.add(:TOXICORB,
  proc { |item, battler, battle|
    next if !battler.pbCanPoison?(battler, false)
    battler.pbPoison(nil, _INTL("{1} was badly poisoned by the {2}!",
       battler.pbThis, battler.itemName), true)
  }
)

#===============================================================================
# CertainSwitching handlers
#===============================================================================

Battle::ItemEffects::CertainSwitching.add(:SHEDSHELL,
  proc { |item, battler, battle|
    next true
  }
)

#===============================================================================
# TrappingByTarget handlers
#===============================================================================

# There aren't any!

#===============================================================================
# OnSwitchIn handlers
#===============================================================================

Battle::ItemEffects::OnSwitchIn.add(:AIRBALLOON,
  proc { |item, battler, battle|
    battle.pbDisplay(_INTL("{1} floats in the air with its {2}!",
       battler.pbThis, battler.itemName))
  }
)

Battle::ItemEffects::OnSwitchIn.add(:ROOMSERVICE,
  proc { |item, battler, battle|
    next if battle.field.effects[PBEffects::TrickRoom] == 0
    next if !battler.pbCanLowerStatStage?(:SPEED)
    battle.pbCommonAnimation("UseItem", battler)
    battler.pbLowerStatStage(:SPEED, 1, nil)
    battler.pbConsumeItem
  }
)

#===============================================================================
# OnIntimidated handlers
#===============================================================================

Battle::ItemEffects::OnIntimidated.add(:ADRENALINEORB,
  proc { |item, battler, battle|
    next false if !battler.pbCanRaiseStatStage?(:SPEED, battler)
    itemName = GameData::Item.get(item).name
    battle.pbCommonAnimation("UseItem", battler)
    next battler.pbRaiseStatStageByCause(:SPEED, 1, battler, itemName)
  }
)

#===============================================================================
# CertainEscapeFromBattle handlers
#===============================================================================

Battle::ItemEffects::CertainEscapeFromBattle.add(:SMOKEBALL,
  proc { |item, battler|
    next true
  }
)
