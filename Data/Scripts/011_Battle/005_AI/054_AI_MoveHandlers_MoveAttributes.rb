#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("FixedDamage20",
  proc { |score, move, user, target, skill, ai, battle|
    if target.hp <= 20
      score += 80
    elsif target.level >= 25
      score -= 60   # Not useful against high-level Pokemon
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FixedDamage40",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 80 if target.hp <= 40
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FixedDamageHalfTargetHP",
  proc { |score, move, user, target, skill, ai, battle|
    score -= 50
    next score + target.hp * 100 / target.totalhp
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FixedDamageUserLevel",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 80 if target.hp <= user.level
  }
)

Battle::AI::Handlers::MoveEffectScore.add("FixedDamageUserLevelRandom",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 30 if target.hp <= user.level
  }
)

Battle::AI::Handlers::MoveEffectScore.add("LowerTargetHPToUserHP",
  proc { |score, move, user, target, skill, ai, battle|
    if user.hp >= target.hp
      score -= 90
    elsif user.hp < target.hp / 2
      score += 50
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("OHKO",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.hasActiveAbility?(:STURDY)
    next 0 if target.level > user.level
  }
)

Battle::AI::Handlers::MoveEffectScore.copy("OHKO",
                                           "OHKOIce",
                                           "OHKOHitsUndergroundTarget")

Battle::AI::Handlers::MoveEffectScore.add("DamageTargetAlly",
  proc { |score, move, user, target, skill, ai, battle|
    target.allAllies.each do |b|
      next if !b.near?(target)
      score += 10
    end
    next score
  }
)

# PowerHigherWithUserHP

# PowerLowerWithUserHP

# PowerHigherWithTargetHP

# PowerHigherWithUserHappiness

# PowerLowerWithUserHappiness

# PowerHigherWithUserPositiveStatStages

# PowerHigherWithTargetPositiveStatStages

# PowerHigherWithUserFasterThanTarget

# PowerHigherWithTargetFasterThanUser

# PowerHigherWithLessPP

# PowerHigherWithTargetWeight

# PowerHigherWithUserHeavierThanTarget

# PowerHigherWithConsecutiveUse

# PowerHigherWithConsecutiveUseOnUserSide

# RandomPowerDoublePowerIfTargetUnderground

# DoublePowerIfTargetHPLessThanHalf

# DoublePowerIfUserPoisonedBurnedParalyzed

Battle::AI::Handlers::MoveEffectScore.add("DoublePowerIfTargetAsleepCureTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next score - 20 if target.status == :SLEEP &&   # Will cure status
                       target.statusCount > 1
  }
)

# DoublePowerIfTargetPoisoned

Battle::AI::Handlers::MoveEffectScore.add("DoublePowerIfTargetParalyzedCureTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next score - 20 if target.status == :PARALYSIS   # Will cure status
  }
)

# DoublePowerIfTargetStatusProblem

# DoublePowerIfUserHasNoItem

# DoublePowerIfTargetUnderwater

# DoublePowerIfTargetUnderground

# DoublePowerIfTargetInSky

Battle::AI::Handlers::MoveEffectScore.add("DoublePowerInElectricTerrain",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 40 if battle.field.terrain == :Electric && target.affectedByTerrain?
  }
)

# DoublePowerIfUserLastMoveFailed

# DoublePowerIfAllyFaintedLastTurn

Battle::AI::Handlers::MoveEffectScore.add("DoublePowerIfUserLostHPThisTurn",
  proc { |score, move, user, target, skill, ai, battle|
    attspeed = pbRoughStat(user, :SPEED)
    oppspeed = pbRoughStat(target, :SPEED)
    next score + 30 if oppspeed > attspeed
  }
)

Battle::AI::Handlers::MoveEffectScore.add("DoublePowerIfTargetLostHPThisTurn",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 20 if battle.pbOpposingBattlerCount(user) > 1
  }
)

# DoublePowerIfUserStatsLoweredThisTurn

Battle::AI::Handlers::MoveEffectScore.add("DoublePowerIfTargetActed",
  proc { |score, move, user, target, skill, ai, battle|
    attspeed = pbRoughStat(user, :SPEED)
    oppspeed = pbRoughStat(target, :SPEED)
    next score + 30 if oppspeed > attspeed
  }
)

# DoublePowerIfTargetNotActed

# AlwaysCriticalHit

Battle::AI::Handlers::MoveEffectScore.add("EnsureNextCriticalHit",
  proc { |score, move, user, target, skill, ai, battle|
    if user.effects[PBEffects::LaserFocus] > 0
      score -= 90
    else
      score += 40
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("EnsureNextCriticalHit",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.pbOwnSide.effects[PBEffects::LuckyChant] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CannotMakeTargetFaint",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.hp == 1
    if target.hp <= target.totalhp / 8
      score -= 60
    elsif target.hp <= target.totalhp / 4
      score -= 30
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("UserEnduresFaintingThisTurn",
  proc { |score, move, user, target, skill, ai, battle|
    score -= 25 if user.hp > user.totalhp / 2
    if ai.skill_check(Battle::AI::AILevel.medium)
      score -= 90 if user.effects[PBEffects::ProtectRate] > 1
      score -= 90 if target.effects[PBEffects::HyperBeam] > 0
    else
      score -= user.effects[PBEffects::ProtectRate] * 40
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartWeakenElectricMoves",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.effects[PBEffects::MudSport]
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartWeakenFireMoves",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.effects[PBEffects::WaterSport]
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartWeakenPhysicalDamageAgainstUserSide",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.pbOwnSide.effects[PBEffects::Reflect] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartWeakenSpecialDamageAgainstUserSide",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.pbOwnSide.effects[PBEffects::LightScreen] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartWeakenDamageAgainstUserSideIfHail",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 || user.effectiveWeather != :Hail
    next score + 40
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RemoveScreens",
  proc { |score, move, user, target, skill, ai, battle|
    score += 20 if user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
    score += 20 if user.pbOpposingSide.effects[PBEffects::Reflect] > 0
    score += 20 if user.pbOpposingSide.effects[PBEffects::LightScreen] > 0
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ProtectUser",
  proc { |score, move, user, target, skill, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1 ||
       target.effects[PBEffects::HyperBeam] > 0
      score -= 90
    else
      if ai.skill_check(Battle::AI::AILevel.medium)
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ProtectUserBanefulBunker",
  proc { |score, move, user, target, skill, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1 ||
       target.effects[PBEffects::HyperBeam] > 0
      score -= 90
    else
      if ai.skill_check(Battle::AI::AILevel.medium)
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
      score += 30 if target.effects[PBEffects::TwoTurnAttack]
      score += 20   # Because of possible poisoning
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ProtectUserFromDamagingMovesKingsShield",
  proc { |score, move, user, target, skill, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1 ||
       target.effects[PBEffects::HyperBeam] > 0
      score -= 90
    else
      if ai.skill_check(Battle::AI::AILevel.medium)
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ProtectUserFromDamagingMovesObstruct",
  proc { |score, move, user, target, skill, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1 ||
       target.effects[PBEffects::HyperBeam] > 0
      score -= 90
    else
      if ai.skill_check(Battle::AI::AILevel.medium)
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ProtectUserFromTargetingMovesSpikyShield",
  proc { |score, move, user, target, skill, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1 ||
       target.effects[PBEffects::HyperBeam] > 0
      score -= 90
    else
      if ai.skill_check(Battle::AI::AILevel.medium)
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ProtectUserSideFromDamagingMovesIfUserFirstTurn",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if user.turnCount != 0
    next score + 30
  }
)

# ProtectUserSideFromStatusMoves

# ProtectUserSideFromPriorityMoves

# ProtectUserSideFromMultiTargetDamagingMoves

# RemoveProtections

# RemoveProtectionsBypassSubstitute

Battle::AI::Handlers::MoveEffectScore.add("HoopaRemoveProtectionsBypassSubstituteLowerUserDef1",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !user.isSpecies?(:HOOPA) || user.form != 1
    next score + 20 if target.stages[:DEFENSE] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RecoilQuarterOfDamageDealt",
  proc { |score, move, user, target, skill, ai, battle|
    next score - 25
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RecoilThirdOfDamageDealtParalyzeTarget",
  proc { |score, move, user, target, skill, ai, battle|
    score -= 30
    if target.pbCanParalyze?(user, false)
      score += 30
      if ai.skill_check(Battle::AI::AILevel.medium)
        aspeed = pbRoughStat(user, :SPEED)
        ospeed = pbRoughStat(target, :SPEED)
        if aspeed < ospeed
          score += 30
        elsif aspeed > ospeed
          score -= 40
        end
      end
      if ai.skill_check(Battle::AI::AILevel.high)
        score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET])
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RecoilThirdOfDamageDealtBurnTarget",
  proc { |score, move, user, target, skill, ai, battle|
    score -= 30
    if target.pbCanBurn?(user, false)
      score += 30
      if ai.skill_check(Battle::AI::AILevel.high)
        score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RecoilHalfOfDamageDealt",
  proc { |score, move, user, target, skill, ai, battle|
    next score - 40
  }
)

# EffectivenessIncludesFlyingType

Battle::AI::Handlers::MoveEffectScore.add("CategoryDependsOnHigherDamagePoisonTarget",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 5 if target.pbCanPoison?(user, false)
  }
)

# CategoryDependsOnHigherDamageIgnoreTargetAbility

# UseUserBaseDefenseInsteadOfUserBaseAttack

# UseTargetAttackInsteadOfUserAttack

# UseTargetDefenseInsteadOfTargetSpDef

Battle::AI::Handlers::MoveEffectScore.add("EnsureNextMoveAlwaysHits",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if target.effects[PBEffects::Substitute] > 0
    next 0 if user.effects[PBEffects::LockOn] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartNegateTargetEvasionStatStageAndGhostImmunity",
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::Foresight]
      score -= 90
    elsif target.pbHasType?(:GHOST)
      score += 70
    elsif target.stages[:EVASION] <= 0
      score -= 60
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartNegateTargetEvasionStatStageAndDarkImmunity",
  proc { |score, move, user, target, skill, ai, battle|
    if target.effects[PBEffects::MiracleEye]
      score -= 90
    elsif target.pbHasType?(:DARK)
      score += 70
    elsif target.stages[:EVASION] <= 0
      score -= 60
    end
    next score
  }
)

# IgnoreTargetDefSpDefEvaStatStages

# TypeIsUserFirstType

# TypeDependsOnUserIVs

Battle::AI::Handlers::MoveEffectScore.add("TypeAndPowerDependOnUserBerry",
  proc { |score, move, user, target, skill, ai, battle|
    next 0 if !user.item || !user.item.is_berry? || !user.itemActive?
  }
)

# TypeDependsOnUserPlate

# TypeDependsOnUserMemory

# TypeDependsOnUserDrive

Battle::AI::Handlers::MoveEffectScore.add("TypeDependsOnUserMorpekoFormRaiseUserSpeed1",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 20 if user.stages[:SPEED] <= 0
  }
)

# TypeAndPowerDependOnWeather

Battle::AI::Handlers::MoveEffectScore.add("TypeAndPowerDependOnTerrain",
  proc { |score, move, user, target, skill, ai, battle|
    next score + 40 if battle.field.terrain != :None
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TargetMovesBecomeElectric",
  proc { |score, move, user, target, skill, ai, battle|
    aspeed = pbRoughStat(user, :SPEED)
    ospeed = pbRoughStat(target, :SPEED)
    next 0 if aspeed > ospeed
  }
)

# NormalMovesBecomeElectric
