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
    next 0 if ai.trainer.high_skill?
    next score - 95
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
Battle::AI::Handlers::MoveEffectScore.copy("DoesNothingCongratulations",
                                           "DoubleMoneyGainedFromBattle")

#===============================================================================
#
#===============================================================================
# AddMoneyGainedFromBattle

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FailsIfNotUserFirstTurn",
  proc { |move, user, target, ai, battle|
    next true if user.turnCount > 0
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
Battle::AI::Handlers::MoveEffectScore.add("FailsIfTargetHasNoItem",
  proc { |score, move, user, target, ai, battle|
    next score + 50 if ai.trainer.medium_skill?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("FailsUnlessTargetSharesTypeWithUser",
  proc { |move, user, target, ai, battle|
    user_types = user.battler.pbTypes(true)
    target_types = target.battler.pbTypes(true)
    next true if (user_types & target_types).empty?
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("FailsIfUserDamagedThisTurn",
  proc { |score, move, user, target, ai, battle|
    score += 50 if target.effects[PBEffects::HyperBeam] > 0
    score -= 35 if target.hp <= target.totalhp / 2   # If target is weak, no
    score -= 70 if target.hp <= target.totalhp / 4   # need to risk this move
    next score
  }
)

#===============================================================================
#
#===============================================================================
# FailsIfTargetActed

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("CrashDamageIfFailsUnusableInGravity",
  proc { |score, move, user, target, ai, battle|
    next score + 10 * (user.stages[:ACCURACY] - target.stages[:EVASION])
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
    if battle.pbCheckGlobalAbility(:AIRLOCK) ||
       battle.pbCheckGlobalAbility(:CLOUDNINE)
      next score - 50
    else
      user.battler.eachMove do |m|
        next if !m.damagingMove? || m.type != :FIRE
        score += 20
      end
      next score
    end
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("StartSunWeather",
                                            "StartRainWeather")
Battle::AI::Handlers::MoveEffectScore.add("StartRainWeather",
  proc { |score, move, user, target, ai, battle|
    if battle.pbCheckGlobalAbility(:AIRLOCK) ||
       battle.pbCheckGlobalAbility(:CLOUDNINE)
      next score - 50
    else
      user.battler.eachMove do |m|
        next if !m.damagingMove? || m.type != :WATER
        score += 20
      end
      next score
    end
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("StartSunWeather",
                                            "StartSandstormWeather")
Battle::AI::Handlers::MoveEffectScore.add("StartSandstormWeather",
  proc { |score, move, user, target, ai, battle|
    if battle.pbCheckGlobalAbility(:AIRLOCK) ||
       battle.pbCheckGlobalAbility(:CLOUDNINE)
      next score - 50
    end
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.copy("StartSunWeather",
                                            "StartHailWeather")
Battle::AI::Handlers::MoveEffectScore.add("StartHailWeather",
  proc { |score, move, user, target, ai, battle|
    if battle.pbCheckGlobalAbility(:AIRLOCK) ||
       battle.pbCheckGlobalAbility(:CLOUDNINE)
      next score - 50
    end
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartElectricTerrain",
  proc { |move, user, target, ai, battle|
    next true if battle.field.terrain == :Electric
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartGrassyTerrain",
  proc { |move, user, target, ai, battle|
    next true if battle.field.terrain == :Grassy
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartMistyTerrain",
  proc { |move, user, target, ai, battle|
    next true if battle.field.terrain == :Misty
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartPsychicTerrain",
  proc { |move, user, target, ai, battle|
    next true if battle.field.terrain == :Psychic
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("RemoveTerrain",
  proc { |move, user, target, ai, battle|
    next true if battle.field.terrain == :None
  }
)

#===============================================================================
#
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
#
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
#
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
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("AddStickyWebToFoeSide",
  proc { |move, user, target, ai, battle|
    next true if user.pbOpposingSide.effects[PBEffects::StickyWeb]
  }
)

#===============================================================================
#
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
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("UserMakeSubstitute",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::Substitute] > 0
    next true if user.hp <= [user.totalhp / 4, 1].max
  }
)

#===============================================================================
#
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
#
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
#
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
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("BurnAttackerBeforeUserActs",
  proc { |score, move, user, target, ai, battle|
    next score + 20   # Because of possible burning
  }
)
