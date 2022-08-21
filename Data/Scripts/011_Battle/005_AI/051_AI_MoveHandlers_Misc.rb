#===============================================================================
#
#===============================================================================
# Struggle

# None

Battle::AI::Handlers::MoveEffectScore.add("DoesNothingCongratulations",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if ai.skill_check(Battle::AI::AILevel.high)
    next score - 95
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("DoesNothingCongratulations",
                                           "DoesNothingFailsIfNoAlly",
                                           "DoesNothingUnusableInGravity",
                                           "DoubleMoneyGainedFromBattle")

# AddMoneyGainedFromBattle

Battle::AI::Handlers::MoveEffectScore.add("FailsIfNotUserFirstTurn",
  proc { |score, move, user, target, skill, ai, battle|
    next score - 90 if user.turnCount > 0
  }
)

# FailsIfUserHasUnusedMove

Battle::AI::Handlers::MoveEffectScore.add("FailsIfUserNotConsumedBerry",
  proc { |score, move, user, target, skill, ai, battle|
    next score - 90 if !user.belched?
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FailsIfTargetHasNoItem",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.medium)
      next score - 90 if !target.item || !target.itemActive?
      next score + 50
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FailsUnlessTargetSharesTypeWithUser",
  proc { |score, move, user, target, skill, ai, battle|
    if !(user.types[0] && target.pbHasType?(user.types[0])) &&
       !(user.types[1] && target.pbHasType?(user.types[1]))
      next score - 90
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FailsIfUserDamagedThisTurn",
  proc { |score, move, user, target, skill, ai, battle|
    score += 50 if target.effects[PBEffects::HyperBeam] > 0
    score -= 35 if target.hp <= target.totalhp / 2   # If target is weak, no
    score -= 70 if target.hp <= target.totalhp / 4   # need to risk this move
    next score
  }
)

# FailsIfTargetActed

Battle::AI::Handlers::MoveEffectScore.add("CrashDamageIfFailsUnusableInGravity",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 10 * (user.stages[:ACCURACY] - target.stages[:EVASION])
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartSunWeather",
  proc { |score, move, user, target, skill, ai, battle|
    if battle.pbCheckGlobalAbility(:AIRLOCK) ||
       battle.pbCheckGlobalAbility(:CLOUDNINE)
      next score - 90
    elsif battle.field.weather == :Sun
      next score - 90
    else
      user.eachMove do |m|
        next if !m.damagingMove? || m.type != :FIRE
        score += 20
      end
      next score
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartRainWeather",
  proc { |score, move, user, target, skill, ai, battle|
    if battle.pbCheckGlobalAbility(:AIRLOCK) ||
       battle.pbCheckGlobalAbility(:CLOUDNINE)
      next score - 90
    elsif battle.field.weather == :Rain
      next score - 90
    else
      user.eachMove do |m|
        next if !m.damagingMove? || m.type != :WATER
        score += 20
      end
      next score
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartSandstormWeather",
  proc { |score, move, user, target, skill, ai, battle|
    if battle.pbCheckGlobalAbility(:AIRLOCK) ||
       battle.pbCheckGlobalAbility(:CLOUDNINE)
      next score - 90
    elsif battle.field.weather == :Rain
      next score - 90
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartHailWeather",
  proc { |score, move, user, target, skill, ai, battle|
    if battle.pbCheckGlobalAbility(:AIRLOCK) ||
       battle.pbCheckGlobalAbility(:CLOUDNINE)
      next score - 90
    elsif battle.field.weather == :Hail
      next score - 90
    end
  }
)

# StartElectricTerrain

# StartGrassyTerrain

# StartMistyTerrain

# StartPsychicTerrain

Battle::AI::Handlers::MoveEffectScore.add("RemoveTerrain",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if battle.field.terrain == :None
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AddSpikesToFoeSide",
  proc { |score, move, user, target, skill, ai, battle|
    if user.pbOpposingSide.effects[PBEffects::Spikes] >= 3
      next score - 90
    elsif user.allOpposing.none? { |b| battle.pbCanChooseNonActive?(b.index) }
      next score - 90   # Opponent can't switch in any Pokemon
    else
      score += 10 * battle.pbAbleNonActiveCount(user.idxOpposingSide)
      score += [40, 26, 13][user.pbOpposingSide.effects[PBEffects::Spikes]]
      next score
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AddToxicSpikesToFoeSide",
  proc { |score, move, user, target, skill, ai, battle|
    if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2
      next score - 90
    elsif user.allOpposing.none? { |b| battle.pbCanChooseNonActive?(b.index) }
      next score - 90   # Opponent can't switch in any Pokemon
    else
      score += 8 * battle.pbAbleNonActiveCount(user.idxOpposingSide)
      score += [26, 13][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
      next score
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AddStealthRocksToFoeSide",
  proc { |score, move, user, target, skill, ai, battle|
    if user.pbOpposingSide.effects[PBEffects::StealthRock]
      next score - 90
    elsif user.allOpposing.none? { |b| battle.pbCanChooseNonActive?(b.index) }
      next score - 90   # Opponent can't switch in any Pokemon
    else
      next score + 10 * battle.pbAbleNonActiveCount(user.idxOpposingSide)
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("AddStickyWebToFoeSide",
  proc { |score, move, user, target, skill, ai, battle|
    next score - 95 if user.pbOpposingSide.effects[PBEffects::StickyWeb]
  }
)

Battle::AI::Handlers::MoveEffectScore.add("SwapSideEffects",
  proc { |score, move, user, target, skill, ai, battle|
    if ai.skill_check(Battle::AI::AILevel.medium)
      good_effects = [:Reflect, :LightScreen, :AuroraVeil, :SeaOfFire,
                      :Swamp, :Rainbow, :Mist, :Safeguard,
                      :Tailwind].map! { |e| PBEffects.const_get(e) }
      bad_effects = [:Spikes, :StickyWeb, :ToxicSpikes, :StealthRock].map! { |e| PBEffects.const_get(e) }
      bad_effects.each do |e|
        score += 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
        score -= 10 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
      end
      if ai.skill_check(Battle::AI::AILevel.high)
        good_effects.each do |e|
          score += 10 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
          score -= 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
        end
      end
      next score
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserMakeSubstitute",
  proc { |score, move, user, target, skill, ai, battle|
    if user.effects[PBEffects::Substitute] > 0
      next score - 90
    elsif user.hp <= user.totalhp / 4
      next score - 90
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RemoveUserBindingAndEntryHazards",
  proc { |score, move, user, target, skill, ai, battle|
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

Battle::AI::Handlers::MoveEffectScore.add("AttackTwoTurnsLater",
  proc { |score, move, user, target, skill, ai, battle|
    if battle.positions[target.index].effects[PBEffects::FutureSightCounter] > 0
      next 0
    elsif battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
      # Future Sight tends to be wasteful if down to last Pokemon
      next score - 70
    end
  }
)

# UserSwapsPositionsWithAlly

Battle::AI::Handlers::MoveEffectScore.add("BurnAttackerBeforeUserActs",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 20   # Because of possible burning
  }
)
