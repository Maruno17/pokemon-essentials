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
    next user.turnCount > 0
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
    next !has_another_move || has_unused_move
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FailsIfUserNotConsumedBerry",
  proc { |move, user, ai, battle|
    next !user.battler.belched?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("FailsIfTargetHasNoItem",
  proc { |move, user, target, ai, battle|
    next !target.item || !target.item_active?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("FailsUnlessTargetSharesTypeWithUser",
  proc { |move, user, target, ai, battle|
    user_types = user.pbTypes(true)
    target_types = target.pbTypes(true)
    next (user_types & target_types).empty?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("FailsIfUserDamagedThisTurn",
  proc { |score, move, user, target, ai, battle|
    # Check whether user is faster than its foe(s) and could use this move
    user_faster_count = 0
    foe_faster_count = 0
    ai.each_foe_battler(user.side) do |b, i|
      if user.faster_than?(b)
        user_faster_count += 1
      else
        foe_faster_count += 1
      end
    end
    next Battle::AI::MOVE_USELESS_SCORE if user_faster_count == 0
    score += 15 if foe_faster_count == 0
    # Effects that make the target unlikely to act before the user
    if ai.trainer.high_skill?
      if !target.can_attack?
        score += 15
      elsif target.effects[PBEffects::Confusion] > 1 ||
            target.effects[PBEffects::Attract] == user.index
        score += 10
      elsif target.battler.paralyzed?
        score += 5
      end
    end
    # Don't risk using this move if target is weak
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if target.hp <= target.totalhp / 2
      score -= 10 if target.hp <= target.totalhp / 4
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("FailsIfTargetActed",
  proc { |score, move, user, target, ai, battle|
    # Check whether user is faster than the target and could use this move
    next Battle::AI::MOVE_USELESS_SCORE if target.faster_than?(user)
    # Check whether the target has any damaging moves it could use
    next Battle::AI::MOVE_USELESS_SCORE if !target.check_for_move { |m| m.damagingMove? }
    # Don't risk using this move if target is weak
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if target.hp <= target.totalhp / 2
      score -= 10 if target.hp <= target.totalhp / 4
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("CrashDamageIfFailsUnusableInGravity",
  proc { |score, move, user, target, ai, battle|
    if user.battler.takesIndirectDamage?
      score -= (0.6 * (100 - move.rough_accuracy)).to_i   # -0 (100%) to -60 (1%)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartSunWeather",
  proc { |move, user, ai, battle|
    next [:HarshSun, :HeavyRain, :StrongWinds, move.move.weatherType].include?(battle.field.weather)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartSunWeather",
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                                           battle.pbCheckGlobalAbility(:CLOUDNINE)
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.weather != :None
      score -= ai.get_score_for_weather(battle.field.weather, user)
    end
    score += ai.get_score_for_weather(:Sun, user, true)
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
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.weather != :None
      score -= ai.get_score_for_weather(battle.field.weather, user)
    end
    score += ai.get_score_for_weather(:Rain, user, true)
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
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.weather != :None
      score -= ai.get_score_for_weather(battle.field.weather, user)
    end
    score += ai.get_score_for_weather(:Sandstorm, user, true)
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
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.weather != :None
      score -= ai.get_score_for_weather(battle.field.weather, user)
    end
    score += ai.get_score_for_weather(:Hail, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartElectricTerrain",
  proc { |move, user, ai, battle|
    next battle.field.terrain == :Electric
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartElectricTerrain",
  proc { |score, move, user, ai, battle|
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Electric, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartGrassyTerrain",
  proc { |move, user, ai, battle|
    next battle.field.terrain == :Grassy
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartGrassyTerrain",
  proc { |score, move, user, ai, battle|
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Grassy, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartMistyTerrain",
  proc { |move, user, ai, battle|
    next battle.field.terrain == :Misty
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartMistyTerrain",
  proc { |score, move, user, ai, battle|
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Misty, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartPsychicTerrain",
  proc { |move, user, ai, battle|
    next battle.field.terrain == :Psychic
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartPsychicTerrain",
  proc { |score, move, user, ai, battle|
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Psychic, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RemoveTerrain",
  proc { |move, user, ai, battle|
    next battle.field.terrain == :None
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
    next user.pbOpposingSide.effects[PBEffects::Spikes] >= 3
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AddSpikesToFoeSide",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        next if ai.pokemon_airborne?(pkmn)
        next if pkmn.hasAbility?(:MAGICGUARD)
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Spikes
    end
    next Battle::AI::MOVE_USELESS_SCORE if foe_reserves.empty?
    multiplier = [10, 7, 5][user.pbOpposingSide.effects[PBEffects::Spikes]]
    score += [multiplier * foe_reserves.length, 30].min
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddToxicSpikesToFoeSide",
  proc { |move, user, ai, battle|
    next user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AddToxicSpikesToFoeSide",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        next if ai.pokemon_airborne?(pkmn)
        next if !ai.pokemon_can_be_poisoned?(pkmn)
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Toxic Spikes
    end
    next Battle::AI::MOVE_USELESS_SCORE if foe_reserves.empty?
    multiplier = [8, 5][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
    score += [multiplier * foe_reserves.length, 30].min
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddStealthRocksToFoeSide",
  proc { |move, user, ai, battle|
    next user.pbOpposingSide.effects[PBEffects::StealthRock]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AddStealthRocksToFoeSide",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        next if pkmn.hasAbility?(:MAGICGUARD)
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Stealth Rock
    end
    next Battle::AI::MOVE_USELESS_SCORE if foe_reserves.empty?
    score += [10 * foe_reserves.length, 30].min
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddStickyWebToFoeSide",
  proc { |move, user, ai, battle|
    next user.pbOpposingSide.effects[PBEffects::StickyWeb]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AddStickyWebToFoeSide",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        next if ai.pokemon_airborne?(pkmn)
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Sticky Web
    end
    next Battle::AI::MOVE_USELESS_SCORE if foe_reserves.empty?
    score += [8 * foe_reserves.length, 30].min
    next score
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
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserMakeSubstitute",
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::Substitute] > 0
    next user.hp <= [user.totalhp / 4, 1].max
  }
)
Battle::AI::Handlers::MoveEffectScore.add("UserMakeSubstitute",
  proc { |score, move, user, ai, battle|
    # Prefer more the higher the user's HP
    if ai.trainer.has_skill_flag?("HPAware")
      score += (10 * user.hp.to_f / user.totalhp).round
    end
    # Prefer if foes don't know any moves that can bypass a substitute
    ai.each_foe_battler(user.side) do |b, i|
      score += 5 if !b.check_for_move { |m| m.ignoresSubstitute?(b.battler) }
    end
    # Prefer if the user lost more than a Substitute's worth of HP from the last
    # attack against it
    score += 7 if user.battler.lastHPLost >= user.totalhp / 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("RemoveUserBindingAndEntryHazards",
  proc { |score, move, user, ai, battle|
    # Score for raising user's Speed
    if Settings::MECHANICS_GENERATION >= 8
      score = Battle::AI::Handlers.apply_move_effect_score("RaiseUserSpeed1",
         score, move, user, ai, battle)
    end
    # Score for removing various effects
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
    next battle.positions[target.index].effects[PBEffects::FutureSightCounter] > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("AttackTwoTurnsLater",
  proc { |score, move, user, ai, battle|
    # Future Sight tends to be wasteful if down to last Pokémon
    score -= 20 if battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserSwapsPositionsWithAlly",
  proc { |move, user, ai, battle|
    num_targets = 0
    idxUserOwner = battle.pbGetOwnerIndexFromBattlerIndex(user.index)
    ai.each_ally(user.side) do |b, i|
      next if battle.pbGetOwnerIndexFromBattlerIndex(b.index) != idxUserOwner
      next if !b.battler.near?(user.battler)
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
    ai.each_foe_battler(user.side) do |b|
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

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("AllBattlersLoseHalfHPUserSkipsNextTurn",
  proc { |score, move, user, ai, battle|
    # HP halving
    foe_hp_lost = 0
    ally_hp_lost = 0
    ai.each_battler do |b, i|
      next if b.hp == 1
      if b.battler.opposes?(user.battler)
        foe_hp_lost += b.hp / 2
      else
        ally_hp_lost += b.hp / 2
      end
    end
    score += 20 * foe_hp_lost / ally_hp_lost
    score -= 20 * ally_hp_lost / foe_hp_lost
    # Recharging
    score = Battle::AI::Handlers.apply_move_effect_score("AttackAndSkipNextTurn",
       score, move, user, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserLosesHalfHP",
  proc { |score, move, user, ai, battle|
    score = Battle::AI::Handlers.apply_move_effect_score("UserLosesHalfOfTotalHP",
       score, move, user, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("StartSunWeather",
                                            "StartShadowSkyWeather")
Battle::AI::Handlers::MoveEffectScore.add("StartShadowSkyWeather",
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                                           battle.pbCheckGlobalAbility(:CLOUDNINE)
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 15 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.weather != :None
      score -= ai.get_score_for_weather(battle.field.weather, user)
    end
    score += ai.get_score_for_weather(:ShadowSky, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RemoveAllScreensAndSafeguard",
  proc { |move, user, ai, battle|
    will_fail = true
    battle.sides.each do |side|
      will_fail = false if side.effects[PBEffects::AuroraVeil] > 0 ||
                           side.effects[PBEffects::LightScreen] > 0 ||
                           side.effects[PBEffects::Reflect] > 0 ||
                           side.effects[PBEffects::Safeguard] > 0
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("RemoveAllScreensAndSafeguard",
  proc { |score, move, user, ai, battle|
    foe_side = user.pbOpposingSide
    # Useless if the foe's side has no screens/Safeguard to remove, or if
    # they'll end this round anyway
    if foe_side.effects[PBEffects::AuroraVeil] <= 1 &&
       foe_side.effects[PBEffects::LightScreen] <= 1 &&
       foe_side.effects[PBEffects::Reflect] <= 1 &&
       foe_side.effects[PBEffects::Safeguard] <= 1
      next Battle::AI::MOVE_USELESS_SCORE
    end
    # Prefer removing opposing screens
    score = Battle::AI::Handlers.apply_move_effect_score("RemoveScreens",
       score, move, user, ai, battle)
    # Don't prefer removing same side screens
    ai.each_foe_battler(user.side) do |b, i|
      score -= Battle::AI::Handlers.apply_move_effect_score("RemoveScreens",
         0, move, b, ai, battle)
      break
    end
    # Safeguard
    score += 10 if foe_side.effects[PBEffects::Safeguard] > 0
    score -= 10 if user.pbOwnSide.effects[PBEffects::Safeguard] > 0
    next score
  }
)
