#===============================================================================
#
#===============================================================================
# Struggle

#===============================================================================
#
#===============================================================================
# None

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("DoesNothingCongratulations",
  proc { |score, move, user, target, ai, battle|
    next score - 60
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("DoesNothingFailsIfNoAlly",
  proc { |move, user, target, ai, battle|
    next true if user.battler.allAllies.length == 0
  }
)
Battle::AI::Handlers::MoveEffectScore.copy("DoesNothingCongratulations",
                                           "DoesNothingFailsIfNoAlly")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("DoesNothingCongratulations",
                                           "DoesNothingUnusableInGravity")

#===============================================================================
#
#===============================================================================
# AddMoneyGainedFromBattle

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.copy("DoesNothingCongratulations",
                                           "DoubleMoneyGainedFromBattle")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FailsIfNotUserFirstTurn",
  proc { |move, user, target, ai, battle|
    next true if user.turnCount > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("FailsIfNotUserFirstTurn",
  proc { |score, move, user, target, ai, battle|
    next score + 25   # Use it or lose it
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FailsIfUserHasUnusedMove",
  proc { |move, user, target, ai, battle|
    has_another_move = false
    has_unused_move = false
    user.battler.eachMove do |m|
      next if m.id == move.id
      has_another_move = true
      next if user.battler.movesUsed.include?(m.id)
      has_unused_move = true
      break
    end
    next true if !has_another_move || has_unused_move
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FailsIfUserNotConsumedBerry",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.belched?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FailsIfTargetHasNoItem",
  proc { |move, user, target, ai, battle|
    next true if !target.item || !target.item_active?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FailsUnlessTargetSharesTypeWithUser",
  proc { |move, user, target, ai, battle|
    user_types = user.pbTypes(true)
    target_types = target.pbTypes(true)
    next true if (user_types & target_types).empty?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("FailsIfUserDamagedThisTurn",
  proc { |score, move, user, target, ai, battle|
    # Check whether user is faster than its foe(s) and could use this move
    user_faster_count = 0
    foe_faster_count = 0
    ai.battlers.each_with_index do |b, i|
      next if !user.opposes?(b) || b.battler.fainted?
      if user.faster_than?(b)
        user_faster_count += 1
      else
        foe_faster_count += 1
      end
    end
    next score - 40 if user_faster_count == 0
    score += 10 if foe_faster_count == 0
    # Effects that make the target unlikely to act before the user
    if ai.trainer.high_skill?
      if target.effects[PBEffects::HyperBeam] > 0 ||
         target.effects[PBEffects::Truant] ||
         (target.battler.asleep? && target.statusCount > 1) ||
         target.frozen?
        score += 20
      elsif target.effects[PBEffects::Confusion] > 1 ||
            target.effects[PBEffects::Attract] == user.index
        score += 10
      elsif target.paralyzed?
        score += 5
      end
    end
    # Don't risk using this move if target is weak
    score -= 10 if target.hp <= target.totalhp / 2
    score -= 10 if target.hp <= target.totalhp / 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("FailsIfTargetActed",
  proc { |score, move, user, target, ai, battle|
    # Check whether user is faster than its foe(s) and could use this move
    next score - 40 if target.faster_than?(user)
    score += 10
    # TODO: Predict the target switching/using an item.
    # TODO: Predict the target using a damaging move or Me First.
    # Don't risk using this move if target is weak
    score -= 10 if target.hp <= target.totalhp / 2
    score -= 10 if target.hp <= target.totalhp / 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("CrashDamageIfFailsUnusableInGravity",
  proc { |score, move, user, target, ai, battle|
    next score - (100 - move.rough_accuracy) if user.takesIndirectDamage?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartSunWeather",
  proc { |move, user, target, ai, battle|
    next true if [:HarshSun, :HeavyRain, :StrongWinds,
                  move.move.weatherType].include?(battle.field.weather)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartSunWeather",
  proc { |score, move, user, target, ai, battle|
    next score - 40 if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                       battle.pbCheckGlobalAbility(:CLOUDNINE)
    score += 10 if battle.field.weather != :None   # Prefer replacing another weather
    score += 15 if user.has_active_item?(:HEATROCK)
    score -= 10 if user.hp < user.totalhp / 2   # Not worth it at lower HP
    # Check for Fire/Water moves
    ai.battlers.each do |b|
      next if !b || b.battler.fainted?
      if b.check_for_move { |move| move.type == :FIRE && move.damagingMove? }
        score += (b.opposes?(user)) ? -15 : 15
      end
      if b.check_for_move { |move| move.type == :WATER && move.damagingMove? }
        score += (b.opposes?(user)) ? 15 : -15
      end
    end
    # TODO: Check for freezing moves.
    # Check for abilities/other moves affected by sun
    # TODO: Check other battlers for these as well?
    if ai.trainer.medium_skill? && !user.has_active_item?(:UTILITYUMBRELLA)
      if user.has_active_ability?([:CHLOROPHYLL, :FLOWERGIFT, :FORECAST, :HARVEST, :LEAFGUARD, :SOLARPOWER])
        score += 15
      elsif user.has_active_ability?(:DRYSKIN)
        score -= 10
      end
      if user.check_for_move { |move| ["HealUserDependingOnWeather",
                                       "RaiseUserAtkSpAtk1Or2InSun",
                                       "TwoTurnAttackOneTurnInSun",
                                       "TypeAndPowerDependOnWeather"].include?(move.function) }
        score += 10
      end
      if user.check_for_move { |move| ["ConfuseTargetAlwaysHitsInRainHitsTargetInSky",
                                       "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky"].include?(move.function) }
        score -= 10
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("StartSunWeather",
                                            "StartRainWeather")
Battle::AI::Handlers::MoveEffectScore.add("StartRainWeather",
  proc { |score, move, user, target, ai, battle|
    next score - 40 if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                       battle.pbCheckGlobalAbility(:CLOUDNINE)
    score += 10 if battle.field.weather != :None   # Prefer replacing another weather
    score += 15 if user.has_active_item?(:DAMPROCK)
    score -= 10 if user.hp < user.totalhp / 2   # Not worth it at lower HP
    # Check for Fire/Water moves
    ai.battlers.each do |b|
      next if !b || b.battler.fainted?
      if b.check_for_move { |move| move.type == :WATER && move.damagingMove? }
        score += (b.opposes?(user)) ? -15 : 15
      end
      if b.check_for_move { |move| move.type == :FIRE && move.damagingMove? }
        score += (b.opposes?(user)) ? 15 : -15
      end
    end
    # Check for abilities/other moves affected by rain
    # TODO: Check other battlers for these as well?
    if ai.trainer.medium_skill? && !user.has_active_item?(:UTILITYUMBRELLA)
      if user.has_active_ability?([:DRYSKIN, :FORECAST, :HYDRATION, :RAINDISH, :SWIFTSWIM])
        score += 15
      end
      if user.check_for_move { |move| ["ConfuseTargetAlwaysHitsInRainHitsTargetInSky",
                                       "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky",
                                       "TypeAndPowerDependOnWeather"].include?(move.function) }
        score += 10
      end
      if user.check_for_move { |move| ["HealUserDependingOnWeather",
                                       "TwoTurnAttackOneTurnInSun"].include?(move.function) }
        score -= 10
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("StartSunWeather",
                                            "StartSandstormWeather")
Battle::AI::Handlers::MoveEffectScore.add("StartSandstormWeather",
  proc { |score, move, user, target, ai, battle|
    next score - 40 if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                       battle.pbCheckGlobalAbility(:CLOUDNINE)
    score += 10 if battle.field.weather != :None   # Prefer replacing another weather
    score += 15 if user.has_active_item?(:SMOOTHROCK)
    score -= 10 if user.hp < user.totalhp / 2   # Not worth it at lower HP
    # Check for battlers affected by sandstorm's effects
    ai.battlers.each do |b|
      next if !b || b.battler.fainted?
      if b.battler.takesSandstormDamage?   # End of round damage
        score += (b.opposes?(user)) ? 15 : -15
      end
      if b.has_type?(:ROCK)   # +SpDef for Rock types
        score += (b.opposes?(user)) ? -15 : 15
      end
    end
    # Check for abilities/moves affected by sandstorm
    # TODO: Check other battlers for these as well?
    if ai.trainer.medium_skill? && !user.has_active_item?(:UTILITYUMBRELLA)
      if user.has_active_ability?([:SANDFORCE, :SANDRUSH, :SANDVEIL])
        score += 15
      end
      if user.check_for_move { |move| ["HealUserDependingOnSandstorm",
                                       "TypeAndPowerDependOnWeather"].include?(move.function) }
        score += 10
      end
      if user.check_for_move { |move| ["HealUserDependingOnWeather",
                                       "TwoTurnAttackOneTurnInSun"].include?(move.function) }
        score -= 10
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("StartSunWeather",
                                            "StartHailWeather")
Battle::AI::Handlers::MoveEffectScore.add("StartHailWeather",
  proc { |score, move, user, target, ai, battle|
    next score - 40 if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                       battle.pbCheckGlobalAbility(:CLOUDNINE)
    score += 10 if battle.field.weather != :None   # Prefer replacing another weather
    score += 15 if user.has_active_item?(:ICYROCK)
    score -= 10 if user.hp < user.totalhp / 2   # Not worth it at lower HP
    # Check for battlers affected by hail's effects
    ai.battlers.each do |b|
      next if !b || b.battler.fainted?
      if b.battler.takesHailDamage?   # End of round damage
        score += (b.opposes?(user)) ? 15 : -15
      end
    end
    # Check for abilities/moves affected by hail
    # TODO: Check other battlers for these as well?
    if ai.trainer.medium_skill? && !user.has_active_item?(:UTILITYUMBRELLA)
      if user.has_active_ability?([:FORECAST, :ICEBODY, :SLUSHRUSH, :SNOWCLOAK])
        score += 15
      elsif user.ability == :ICEFACE
        score += 15
      end
      if user.check_for_move { |move| ["FreezeTargetAlwaysHitsInHail",
                                       "StartWeakenDamageAgainstUserSideIfHail",
                                       "TypeAndPowerDependOnWeather"].include?(move.function) }
        score += 10
      end
      if user.check_for_move { |move| ["HealUserDependingOnWeather",
                                       "TwoTurnAttackOneTurnInSun"].include?(move.function) }
        score -= 10
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartElectricTerrain",
  proc { |move, user, target, ai, battle|
    next true if battle.field.terrain == :Electric
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartGrassyTerrain",
  proc { |move, user, target, ai, battle|
    next true if battle.field.terrain == :Grassy
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartMistyTerrain",
  proc { |move, user, target, ai, battle|
    next true if battle.field.terrain == :Misty
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartPsychicTerrain",
  proc { |move, user, target, ai, battle|
    next true if battle.field.terrain == :Psychic
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RemoveTerrain",
  proc { |move, user, target, ai, battle|
    next true if battle.field.terrain == :None
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddSpikesToFoeSide",
  proc { |move, user, target, ai, battle|
    next true if user.pbOpposingSide.effects[PBEffects::Spikes] >= 3
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AddSpikesToFoeSide",
  proc { |score, move, user, target, ai, battle|
    if user.battler.allOpposing.none? { |b| battle.pbCanChooseNonActive?(b.index) }
      next score - 90   # Opponent can't switch in any Pokemon
    else
      score += 10 * battle.pbAbleNonActiveCount(user.idxOpposingSide)
      score += [40, 26, 13][user.pbOpposingSide.effects[PBEffects::Spikes]]
      next score
    end
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddToxicSpikesToFoeSide",
  proc { |move, user, target, ai, battle|
    next true if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AddToxicSpikesToFoeSide",
  proc { |score, move, user, target, ai, battle|
    if user.battler.allOpposing.none? { |b| battle.pbCanChooseNonActive?(b.index) }
      next score - 90   # Opponent can't switch in any Pokemon
    else
      score += 8 * battle.pbAbleNonActiveCount(user.idxOpposingSide)
      score += [26, 13][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
      next score
    end
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddStealthRocksToFoeSide",
  proc { |move, user, target, ai, battle|
    next true if user.pbOpposingSide.effects[PBEffects::StealthRock]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AddStealthRocksToFoeSide",
  proc { |score, move, user, target, ai, battle|
    if user.battler.allOpposing.none? { |b| battle.pbCanChooseNonActive?(b.index) }
      next score - 90   # Opponent can't switch in any Pokemon
    else
      next score + 10 * battle.pbAbleNonActiveCount(user.idxOpposingSide)
    end
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddStickyWebToFoeSide",
  proc { |move, user, target, ai, battle|
    next true if user.pbOpposingSide.effects[PBEffects::StickyWeb]
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("SwapSideEffects",
  proc { |move, user, target, ai, battle|
    has_effect = false
    2.times do |side|
      effects = battle.sides[side].effects
      move.move.number_effects.each do |e|
        next if effects[e] == 0
        has_effect = true
        break
      end
      break if has_effect
      move.move.boolean_effects.each do |e|
        next if !effects[e]
        has_effect = true
        break
      end
      break if has_effect
    end
    next !has_effect
  }
)
Battle::AI::Handlers::MoveEffectScore.add("SwapSideEffects",
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill?
      good_effects = [:Reflect, :LightScreen, :AuroraVeil, :SeaOfFire,
                      :Swamp, :Rainbow, :Mist, :Safeguard,
                      :Tailwind].map! { |e| PBEffects.const_get(e) }
      bad_effects = [:Spikes, :StickyWeb, :ToxicSpikes, :StealthRock].map! { |e| PBEffects.const_get(e) }
      bad_effects.each do |e|
        score += 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
        score -= 10 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
      end
      if ai.trainer.high_skill?
        good_effects.each do |e|
          score += 10 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
          score -= 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
        end
      end
      next score
    end
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserMakeSubstitute",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::Substitute] > 0
    next true if user.hp <= [user.totalhp / 4, 1].max
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("RemoveUserBindingAndEntryHazards",
  proc { |score, move, user, target, ai, battle|
    score += 30 if user.effects[PBEffects::Trapping] > 0
    score += 30 if user.effects[PBEffects::LeechSeed] >= 0
    if battle.pbAbleNonActiveCount(user.idxOwnSide) > 0
      score += 80 if user.pbOwnSide.effects[PBEffects::Spikes] > 0
      score += 80 if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
      score += 80 if user.pbOwnSide.effects[PBEffects::StealthRock]
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AttackTwoTurnsLater",
  proc { |move, user, target, ai, battle|
    next true if battle.positions[target.index].effects[PBEffects::FutureSightCounter] > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AttackTwoTurnsLater",
  proc { |score, move, user, target, ai, battle|
    if battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
      # Future Sight tends to be wasteful if down to last Pokemon
      next score - 70
    end
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserSwapsPositionsWithAlly",
  proc { |move, user, target, ai, battle|
    num_targets = 0
    idxUserOwner = battle.pbGetOwnerIndexFromBattlerIndex(user.index)
    user.battler.allAllies.each do |b|
      next if battle.pbGetOwnerIndexFromBattlerIndex(b.index) != idxUserOwner
      next if !b.near?(user)
      num_targets += 1
    end
    next num_targets != 1
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("BurnAttackerBeforeUserActs",
  proc { |score, move, user, target, ai, battle|
    next score + 20   # Because of possible burning
  }
)
