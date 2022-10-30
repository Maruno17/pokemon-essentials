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
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE
  }
)

#===============================================================================
#
#===============================================================================
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
  proc { |move, user, ai, battle|
    next true if user.turnCount > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("FailsIfNotUserFirstTurn",
  proc { |score, move, user, ai, battle|
    next score + 25   # Use it or lose it
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FailsIfUserHasUnusedMove",
  proc { |move, user, ai, battle|
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
  proc { |move, user, ai, battle|
    next true if !user.battler.belched?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("FailsIfTargetHasNoItem",
  proc { |move, user, target, ai, battle|
    next true if !target.item || !target.item_active?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("FailsUnlessTargetSharesTypeWithUser",
  proc { |move, user, target, ai, battle|
    user_types = user.pbTypes(true)
    target_types = target.pbTypes(true)
    next true if (user_types & target_types).empty?
  }
)

#===============================================================================
# TODO: Split some of this into a MoveEffectScore?
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("FailsIfUserDamagedThisTurn",
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
    next Battle::AI::MOVE_USELESS_SCORE if user_faster_count == 0
    score += 10 if foe_faster_count == 0
    # Effects that make the target unlikely to act before the user
    if ai.trainer.high_skill?
      if target.effects[PBEffects::HyperBeam] > 0 ||
         target.effects[PBEffects::Truant] ||
         (target.battler.asleep? && target.statusCount > 1) ||
         target.battler.frozen?
        score += 20
      elsif target.effects[PBEffects::Confusion] > 1 ||
            target.effects[PBEffects::Attract] == user.index
        score += 10
      elsif target.battler.paralyzed?
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("FailsIfTargetActed",
  proc { |score, move, user, target, ai, battle|
    # Check whether user is faster than its foe(s) and could use this move
    next Battle::AI::MOVE_USELESS_SCORE if target.faster_than?(user)
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
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("CrashDamageIfFailsUnusableInGravity",
  proc { |score, move, user, target, ai, battle|
    next score - (100 - move.rough_accuracy) if user.battler.takesIndirectDamage?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartSunWeather",
  proc { |move, user, ai, battle|
    next true if [:HarshSun, :HeavyRain, :StrongWinds,
                  move.move.weatherType].include?(battle.field.weather)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartSunWeather",
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                                           battle.pbCheckGlobalAbility(:CLOUDNINE)
    score += 10 if battle.field.weather != :None   # Prefer replacing another weather
    score += 15 if user.has_active_item?(:HEATROCK)
    score -= 10 if user.hp < user.totalhp / 2   # Not worth it at lower HP
    # Check for Fire/Water moves
    ai.battlers.each do |b|
      next if !b || b.battler.fainted?
      if b.check_for_move { |m| m.type == :FIRE && m.damagingMove? }
        score += (b.opposes?(user)) ? -15 : 15
      end
      if b.check_for_move { |m| m.type == :WATER && m.damagingMove? }
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
      if user.check_for_move { |m| ["HealUserDependingOnWeather",
                                    "RaiseUserAtkSpAtk1Or2InSun",
                                    "TwoTurnAttackOneTurnInSun",
                                    "TypeAndPowerDependOnWeather"].include?(m.function) }
        score += 10
      end
      if user.check_for_move { |m| ["ConfuseTargetAlwaysHitsInRainHitsTargetInSky",
                                    "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky"].include?(m.function) }
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
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                                           battle.pbCheckGlobalAbility(:CLOUDNINE)
    score += 10 if battle.field.weather != :None   # Prefer replacing another weather
    score += 15 if user.has_active_item?(:DAMPROCK)
    score -= 10 if user.hp < user.totalhp / 2   # Not worth it at lower HP
    # Check for Fire/Water moves
    ai.battlers.each do |b|
      next if !b || b.battler.fainted?
      if b.check_for_move { |m| m.type == :WATER && m.damagingMove? }
        score += (b.opposes?(user)) ? -15 : 15
      end
      if b.check_for_move { |m| m.type == :FIRE && m.damagingMove? }
        score += (b.opposes?(user)) ? 15 : -15
      end
    end
    # Check for abilities/other moves affected by rain
    # TODO: Check other battlers for these as well?
    if ai.trainer.medium_skill? && !user.has_active_item?(:UTILITYUMBRELLA)
      if user.has_active_ability?([:DRYSKIN, :FORECAST, :HYDRATION, :RAINDISH, :SWIFTSWIM])
        score += 15
      end
      if user.check_for_move { |m| ["ConfuseTargetAlwaysHitsInRainHitsTargetInSky",
                                    "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky",
                                    "TypeAndPowerDependOnWeather"].include?(m.function) }
        score += 10
      end
      if user.check_for_move { |m| ["HealUserDependingOnWeather",
                                    "TwoTurnAttackOneTurnInSun"].include?(m.function) }
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
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if battle.pbCheckGlobalAbility(:AIRLOCK) ||
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
      if user.check_for_move { |m| ["HealUserDependingOnSandstorm",
                                    "TypeAndPowerDependOnWeather"].include?(m.function) }
        score += 10
      end
      if user.check_for_move { |m| ["HealUserDependingOnWeather",
                                    "TwoTurnAttackOneTurnInSun"].include?(m.function) }
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
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if battle.pbCheckGlobalAbility(:AIRLOCK) ||
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
      if user.check_for_move { |m| ["FreezeTargetAlwaysHitsInHail",
                                    "StartWeakenDamageAgainstUserSideIfHail",
                                    "TypeAndPowerDependOnWeather"].include?(m.function) }
        score += 10
      end
      if user.check_for_move { |m| ["HealUserDependingOnWeather",
                                    "TwoTurnAttackOneTurnInSun"].include?(m.function) }
        score -= 10
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartElectricTerrain",
  proc { |move, user, ai, battle|
    next true if battle.field.terrain == :Electric
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartElectricTerrain",
  proc { |score, move, user, ai, battle|
    score -= 10 if user.hp < user.totalhp / 2   # Not worth it at lower HP
    if battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Electric, user)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartGrassyTerrain",
  proc { |move, user, ai, battle|
    next true if battle.field.terrain == :Grassy
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartGrassyTerrain",
  proc { |score, move, user, ai, battle|
    score -= 10 if user.hp < user.totalhp / 2   # Not worth it at lower HP
    if battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Grassy, user)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartMistyTerrain",
  proc { |move, user, ai, battle|
    next true if battle.field.terrain == :Misty
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartMistyTerrain",
  proc { |score, move, user, ai, battle|
    score -= 10 if user.hp < user.totalhp / 2   # Not worth it at lower HP
    if battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Misty, user)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartPsychicTerrain",
  proc { |move, user, ai, battle|
    next true if battle.field.terrain == :Psychic
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartPsychicTerrain",
  proc { |score, move, user, ai, battle|
    score -= 10 if user.hp < user.totalhp / 2   # Not worth it at lower HP
    if battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Psychic, user)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RemoveTerrain",
  proc { |move, user, ai, battle|
    next true if battle.field.terrain == :None
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RemoveTerrain",
  proc { |score, move, user, ai, battle|
    next score - ai.get_score_for_terrain(battle.field.terrain, user)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddSpikesToFoeSide",
  proc { |move, user, ai, battle|
    next true if user.pbOpposingSide.effects[PBEffects::Spikes] >= 3
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AddSpikesToFoeSide",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        # Check affected by entry hazard
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        # Check can take indirect damage
        next if pkmn.hasAbility?(:MAGICGUARD)
        # Check airborne
        if !pkmn.hasItem?(:IRONBALL) &&
           battle.field.effects[PBEffects::Gravity] == 0
          next if pkmn.hasType?(:FLYING)
          next if pkmn.hasAbility?(:LEVITATE)
          next if pkmn.hasItem?(:AIRBALLOON)
        end
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Spikes
    end
    next Battle::AI::MOVE_USELESS_SCORE if foe_reserves.empty?
    multiplier = [8, 5, 3][user.pbOpposingSide.effects[PBEffects::Spikes]]
    score += multiplier * foe_reserves.length
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddToxicSpikesToFoeSide",
  proc { |move, user, ai, battle|
    next true if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AddToxicSpikesToFoeSide",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        # Check affected by entry hazard
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        # TODO: Check pkmn's immunity to being poisoned.
        next if battle.field.terrain == :Misty
        next if pkmn.hasType?(:POISON)
        next if pkmn.hasType?(:STEEL)
        # Check airborne
        if !pkmn.hasItem?(:IRONBALL) &&
           battle.field.effects[PBEffects::Gravity] == 0
          next if pkmn.hasType?(:FLYING)
          next if pkmn.hasAbility?(:LEVITATE)
          next if pkmn.hasItem?(:AIRBALLOON)
        end
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Toxic Spikes
    end
    next Battle::AI::MOVE_USELESS_SCORE if foe_reserves.empty?
    multiplier = [6, 4][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
    score += multiplier * foe_reserves.length
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddStealthRocksToFoeSide",
  proc { |move, user, ai, battle|
    next true if user.pbOpposingSide.effects[PBEffects::StealthRock]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AddStealthRocksToFoeSide",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        # Check affected by entry hazard
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        # Check can take indirect damage
        next if pkmn.hasAbility?(:MAGICGUARD)
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Stealth Rock
    end
    next Battle::AI::MOVE_USELESS_SCORE if foe_reserves.empty?
    next score + 8 * foe_reserves.length
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddStickyWebToFoeSide",
  proc { |move, user, ai, battle|
    next true if user.pbOpposingSide.effects[PBEffects::StickyWeb]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AddStickyWebToFoeSide",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        # Check affected by entry hazard
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        # Check airborne
        if !pkmn.hasItem?(:IRONBALL) &&
           battle.field.effects[PBEffects::Gravity] == 0
          next if pkmn.hasType?(:FLYING)
          next if pkmn.hasAbility?(:LEVITATE)
          next if pkmn.hasItem?(:AIRBALLOON)
        end
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Sticky Web
    end
    next Battle::AI::MOVE_USELESS_SCORE if foe_reserves.empty?
    next score + 7 * foe_reserves.length
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("SwapSideEffects",
  proc { |move, user, ai, battle|
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
  proc { |score, move, user, ai, battle|
    if ai.trainer.medium_skill?
      good_effects = [:AuroraVeil, :LightScreen, :Mist, :Rainbow, :Reflect,
                      :Safeguard, :SeaOfFire, :Swamp, :Tailwind].map! { |e| PBEffects.const_get(e) }
      bad_effects = [:Spikes, :StealthRock, :StickyWeb, :ToxicSpikes].map! { |e| PBEffects.const_get(e) }
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
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::Substitute] > 0
    next true if user.hp <= [user.totalhp / 4, 1].max
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("RemoveUserBindingAndEntryHazards",
  proc { |score, move, user, ai, battle|
    score += 10 if user.effects[PBEffects::Trapping] > 0
    score += 15 if user.effects[PBEffects::LeechSeed] >= 0
    if battle.pbAbleNonActiveCount(user.idxOwnSide) > 0
      score += 15 if user.pbOwnSide.effects[PBEffects::Spikes] > 0
      score += 15 if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
      score += 20 if user.pbOwnSide.effects[PBEffects::StealthRock]
      score += 15 if user.pbOwnSide.effects[PBEffects::StickyWeb]
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("AttackTwoTurnsLater",
  proc { |move, user, target, ai, battle|
    next true if battle.positions[target.index].effects[PBEffects::FutureSightCounter] > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AttackTwoTurnsLater",
  proc { |score, move, user, ai, battle|
    # Future Sight tends to be wasteful if down to last Pokémon
    next score - 20 if battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserSwapsPositionsWithAlly",
  proc { |move, user, ai, battle|
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
Battle::AI::Handlers::MoveEffectScore.add("UserSwapsPositionsWithAlly",
  proc { |score, move, user, ai, battle|
    next score - 30   # Usually no point in using this
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("BurnAttackerBeforeUserActs",
  proc { |score, move, user, ai, battle|
    ai.battlers.each do |b|
      next if !b || !b.opposes?(user)
      next if !b.battler.affectedByContactEffect?
      next if !b.battler.pbCanBurn?(user.battler, false, move.move)
      if ai.trainer.high_skill?
        next if !b.check_for_move { |m| m.pbContactMove?(b.battler) }
      end
      score += 10   # Possible to burn
    end
    next score
  }
)
