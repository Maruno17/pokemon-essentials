#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("FixedDamage20",
  proc { |power, move, user, target, ai, battle|
    next move.pbFixedDamage(user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("FixedDamage20",
  proc { |score, move, user, target, ai, battle|
    if target.hp <= 20
      score += 80
    elsif target.level >= 25
      score -= 60   # Not useful against high-level Pokemon
    end
    next score
  }
)

Battle::AI::Handlers::MoveBasePower.add("FixedDamage40",
  proc { |power, move, user, target, ai, battle|
    next move.pbFixedDamage(user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("FixedDamage40",
  proc { |score, move, user, target, ai, battle|
    next score + 80 if target.hp <= 40
  }
)

Battle::AI::Handlers::MoveBasePower.add("FixedDamageHalfTargetHP",
  proc { |power, move, user, target, ai, battle|
    next move.pbFixedDamage(user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("FixedDamageHalfTargetHP",
  proc { |score, move, user, target, ai, battle|
    score -= 50
    next score + target.hp * 100 / target.totalhp
  }
)

Battle::AI::Handlers::MoveBasePower.add("FixedDamageUserLevel",
  proc { |power, move, user, target, ai, battle|
    next move.pbFixedDamage(user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("FixedDamageUserLevel",
  proc { |score, move, user, target, ai, battle|
    next score + 80 if target.hp <= user.level
  }
)

Battle::AI::Handlers::MoveBasePower.add("FixedDamageUserLevelRandom",
  proc { |power, move, user, target, ai, battle|
    next user.level   # Average power
  }
)
Battle::AI::Handlers::MoveEffectScore.add("FixedDamageUserLevelRandom",
  proc { |score, move, user, target, ai, battle|
    next score + 30 if target.hp <= user.level
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("LowerTargetHPToUserHP",
  proc { |move, user, target, ai, battle|
    next true if user.hp >= target.hp
  }
)
Battle::AI::Handlers::MoveBasePower.add("LowerTargetHPToUserHP",
  proc { |power, move, user, target, ai, battle|
    next move.pbFixedDamage(user.battler, target.battler)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("LowerTargetHPToUserHP",
  proc { |score, move, user, target, ai, battle|
    if user.hp >= target.hp
      score -= 90
    elsif user.hp < target.hp / 2
      score += 50
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("OHKO",
  proc { |move, user, target, ai, battle|
    next true if target.level > user.level
    next true if target.has_active_ability?(:STURDY)
  }
)
Battle::AI::Handlers::MoveBasePower.add("OHKO",
  proc { |power, move, user, target, ai, battle|
    next 999
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("OHKOIce",
  proc { |move, user, target, ai, battle|
    next true if target.level > user.level
    next true if target.has_active_ability?(:STURDY)
    next true if target.has_type?(:ICE)
  }
)
Battle::AI::Handlers::MoveBasePower.copy("OHKO",
                                         "OHKOIce")
Battle::AI::Handlers::MoveEffectScore.copy("OHKO",
                                           "OHKOIce")

Battle::AI::Handlers::MoveBasePower.copy("OHKO",
                                         "OHKOHitsUndergroundTarget")
Battle::AI::Handlers::MoveEffectScore.copy("OHKO",
                                           "OHKOHitsUndergroundTarget")

Battle::AI::Handlers::MoveEffectScore.add("DamageTargetAlly",
  proc { |score, move, user, target, ai, battle|
    target.battler.allAllies.each do |b|
      next if !b.near?(target.battler)
      score += 10
    end
    next score
  }
)

Battle::AI::Handlers::MoveBasePower.add("PowerHigherWithUserHP",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)

Battle::AI::Handlers::MoveBasePower.copy("PowerHigherWithUserHP",
                                         "PowerLowerWithUserHP",
                                         "PowerHigherWithTargetHP",
                                         "PowerHigherWithUserHappiness",
                                         "PowerLowerWithUserHappiness",
                                         "PowerHigherWithUserPositiveStatStages",
                                         "PowerHigherWithTargetPositiveStatStages",
                                         "PowerHigherWithUserFasterThanTarget",
                                         "PowerHigherWithTargetFasterThanUser")

Battle::AI::Handlers::MoveBasePower.add("PowerHigherWithLessPP",
  proc { |power, move, user, target, ai, battle|
    next 0 if move.move.pp == 0 && move.move.totalpp > 0
    dmgs = [200, 80, 60, 50, 40]
    ppLeft = [move.pp - 1, dmgs.length - 1].min
    next dmgs[ppLeft]
  }
)

Battle::AI::Handlers::MoveBasePower.add("PowerHigherWithTargetWeight",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)

Battle::AI::Handlers::MoveBasePower.copy("PowerHigherWithTargetWeight",
                                         "PowerHigherWithUserHeavierThanTarget")

Battle::AI::Handlers::MoveBasePower.add("PowerHigherWithConsecutiveUse",
  proc { |power, move, user, target, ai, battle|
    next power << user.effects[PBEffects::FuryCutter]
  }
)

Battle::AI::Handlers::MoveBasePower.add("PowerHigherWithConsecutiveUseOnUserSide",
  proc { |power, move, user, target, ai, battle|
    next power * (user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] + 1)
  }
)

Battle::AI::Handlers::MoveBasePower.add("RandomPowerDoublePowerIfTargetUnderground",
  proc { |power, move, user, target, ai, battle|
    power = 71   # Average damage
    next move.pbModifyDamage(power, user.battler, target.battler)
  }
)

Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfTargetHPLessThanHalf",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)

Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetHPLessThanHalf",
                                         "DoublePowerIfUserPoisonedBurnedParalyzed")

Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetHPLessThanHalf",
                                         "DoublePowerIfTargetAsleepCureTarget")
Battle::AI::Handlers::MoveEffectScore.add("DoublePowerIfTargetAsleepCureTarget",
  proc { |score, move, user, target, ai, battle|
    next score - 20 if target.status == :SLEEP &&   # Will cure status
                       target.statusCount > 1
  }
)

Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfTargetPoisoned",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)

Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetPoisoned",
                                         "DoublePowerIfTargetParalyzedCureTarget")
Battle::AI::Handlers::MoveEffectScore.add("DoublePowerIfTargetParalyzedCureTarget",
  proc { |score, move, user, target, ai, battle|
    next score - 20 if target.status == :PARALYSIS   # Will cure status
  }
)

Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfTargetStatusProblem",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)

Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfUserHasNoItem",
  proc { |power, move, user, target, ai, battle|
    next power * 2 if !user.item || user.has_active_item?(:FLYINGGEM)
  }
)

Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfTargetUnderwater",
  proc { |power, move, user, target, ai, battle|
    next move.pbModifyDamage(power, user.battler, target.battler)
  }
)

Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetUnderwater",
                                         "DoublePowerIfTargetUnderground")

Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfTargetInSky",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)

Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetInSky",
                                         "DoublePowerInElectricTerrain",
                                         "DoublePowerIfUserLastMoveFailed",
                                         "DoublePowerIfAllyFaintedLastTurn")

Battle::AI::Handlers::MoveEffectScore.add("DoublePowerIfUserLostHPThisTurn",
  proc { |score, move, user, target, ai, battle|
    next score + 30 if target.faster_than?(user)
  }
)

Battle::AI::Handlers::MoveEffectScore.add("DoublePowerIfTargetLostHPThisTurn",
  proc { |score, move, user, target, ai, battle|
    next score + 20 if battle.pbOpposingBattlerCount(user.battler) > 1
  }
)

# DoublePowerIfUserStatsLoweredThisTurn

Battle::AI::Handlers::MoveEffectScore.add("DoublePowerIfTargetActed",
  proc { |score, move, user, target, ai, battle|
    next score + 30 if target.faster_than?(user)
  }
)

# DoublePowerIfTargetNotActed

# AlwaysCriticalHit

Battle::AI::Handlers::MoveEffectScore.add("EnsureNextCriticalHit",
  proc { |score, move, user, target, ai, battle|
    if user.effects[PBEffects::LaserFocus] > 0
      score -= 90
    else
      score += 40
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("EnsureNextCriticalHit",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.pbOwnSide.effects[PBEffects::LuckyChant] > 0
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("StartPreventCriticalHitsAgainstUserSide",
  proc { |move, user, target, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::LuckyChant] > 0
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("CannotMakeTargetFaint",
  proc { |move, user, target, ai, battle|
    next true if target.hp == 1
  }
)
Battle::AI::Handlers::MoveEffectScore.add("CannotMakeTargetFaint",
  proc { |score, move, user, target, ai, battle|
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
  proc { |score, move, user, target, ai, battle|
    score -= 25 if user.hp > user.totalhp / 2
    if ai.trainer.medium_skill?
      score -= 50 if user.effects[PBEffects::ProtectRate] > 1
      score -= 50 if target.effects[PBEffects::HyperBeam] > 0
    else
      score -= user.effects[PBEffects::ProtectRate] * 40
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("StartWeakenElectricMoves",
  proc { |move, user, target, ai, battle|
    if Settings::MECHANICS_GENERATION >= 6
      next true if battle.field.effects[PBEffects::MudSportField] > 0
    else
      next true if battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartWeakenElectricMoves",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.effects[PBEffects::MudSport]
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("StartWeakenFireMoves",
  proc { |move, user, target, ai, battle|
    if Settings::MECHANICS_GENERATION >= 6
      next true if battle.field.effects[PBEffects::WaterSportField] > 0
    else
      next true if battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartWeakenFireMoves",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.effects[PBEffects::WaterSport]
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("StartWeakenPhysicalDamageAgainstUserSide",
  proc { |move, user, target, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::Reflect] > 0
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("StartWeakenSpecialDamageAgainstUserSide",
  proc { |move, user, target, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::LightScreen] > 0
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("StartWeakenDamageAgainstUserSideIfHail",
  proc { |move, user, target, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
    next true if user.battler.effectiveWeather != :Hail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartWeakenDamageAgainstUserSideIfHail",
  proc { |score, move, user, target, ai, battle|
    next score + 40
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RemoveScreens",
  proc { |score, move, user, target, ai, battle|
    score += 20 if user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
    score += 20 if user.pbOpposingSide.effects[PBEffects::Reflect] > 0
    score += 20 if user.pbOpposingSide.effects[PBEffects::LightScreen] > 0
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ProtectUser",
  proc { |score, move, user, target, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1 ||
       target.effects[PBEffects::HyperBeam] > 0
      score -= 50
    else
      if ai.trainer.medium_skill?
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ProtectUserBanefulBunker",
  proc { |score, move, user, target, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1 ||
       target.effects[PBEffects::HyperBeam] > 0
      score -= 50
    else
      if ai.trainer.medium_skill?
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
  proc { |score, move, user, target, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1 ||
       target.effects[PBEffects::HyperBeam] > 0
      score -= 50
    else
      if ai.trainer.medium_skill?
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ProtectUserFromDamagingMovesObstruct",
  proc { |score, move, user, target, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1 ||
       target.effects[PBEffects::HyperBeam] > 0
      score -= 50
    else
      if ai.trainer.medium_skill?
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("ProtectUserFromTargetingMovesSpikyShield",
  proc { |score, move, user, target, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1 ||
       target.effects[PBEffects::HyperBeam] > 0
      score -= 90
    else
      if ai.trainer.medium_skill?
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("ProtectUserSideFromDamagingMovesIfUserFirstTurn",
  proc { |move, user, target, ai, battle|
    next true if user.turnCount > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("ProtectUserSideFromDamagingMovesIfUserFirstTurn",
  proc { |score, move, user, target, ai, battle|
    next score + 30
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("ProtectUserSideFromStatusMoves",
  proc { |move, user, target, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::CraftyShield]
  }
)

# ProtectUserSideFromPriorityMoves

# ProtectUserSideFromMultiTargetDamagingMoves

# RemoveProtections

# RemoveProtectionsBypassSubstitute

Battle::AI::Handlers::MoveFailureCheck.add("HoopaRemoveProtectionsBypassSubstituteLowerUserDef1",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.isSpecies?(:HOOPA) || user.battler.form != 1
  }
)
Battle::AI::Handlers::MoveEffectScore.add("HoopaRemoveProtectionsBypassSubstituteLowerUserDef1",
  proc { |score, move, user, target, ai, battle|
    next score + 20 if target.stages[:DEFENSE] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RecoilQuarterOfDamageDealt",
  proc { |score, move, user, target, ai, battle|
    next score - 25
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RecoilThirdOfDamageDealtParalyzeTarget",
  proc { |score, move, user, target, ai, battle|
    score -= 30
    if target.battler.pbCanParalyze?(user.battler, false)
      score += 30
      if ai.trainer.medium_skill?
        aspeed = user.rough_stat(:SPEED)
        ospeed = target.rough_stat(:SPEED)
        if aspeed < ospeed
          score += 30
        elsif aspeed > ospeed
          score -= 40
        end
      end
      score -= 40 if target.has_active_ability?([:GUTS, :MARVELSCALE, :QUICKFEET])
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RecoilThirdOfDamageDealtBurnTarget",
  proc { |score, move, user, target, ai, battle|
    score -= 30
    if target.battler.pbCanBurn?(user.battler, false)
      score += 30
      score -= 40 if target.has_active_ability?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RecoilHalfOfDamageDealt",
  proc { |score, move, user, target, ai, battle|
    next score - 40
  }
)

Battle::AI::Handlers::MoveBasePower.add("EffectivenessIncludesFlyingType",
  proc { |power, move, user, target, ai, battle|
    if GameData::Type.exists?(:FLYING)
      if ai.trainer.high_skill?
        targetTypes = target.battler.pbTypes(true)
        mult = Effectiveness.calculate(
          :FLYING, targetTypes[0], targetTypes[1], targetTypes[2]
        )
      else
        mult = Effectiveness.calculate(
          :FLYING, target.types[0], target.types[1], target.effects[PBEffects::Type3]
        )
      end
      next (power.to_f * mult / Effectiveness::NORMAL_EFFECTIVE).round
    end
  }
)

Battle::AI::Handlers::MoveEffectScore.add("CategoryDependsOnHigherDamagePoisonTarget",
  proc { |score, move, user, target, ai, battle|
    next score + 5 if target.battler.pbCanPoison?(user.battler, false)
  }
)

# CategoryDependsOnHigherDamageIgnoreTargetAbility

# UseUserBaseDefenseInsteadOfUserBaseAttack

# UseTargetAttackInsteadOfUserAttack

# UseTargetDefenseInsteadOfTargetSpDef

Battle::AI::Handlers::MoveEffectScore.add("EnsureNextMoveAlwaysHits",
  proc { |score, move, user, target, ai, battle|
    next score - 50 if user.effects[PBEffects::LockOn] > 0
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartNegateTargetEvasionStatStageAndGhostImmunity",
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::Foresight]
      score -= 90
    elsif target.has_type?(:GHOST)
      score += 70
    elsif target.stages[:EVASION] <= 0
      score -= 60
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartNegateTargetEvasionStatStageAndDarkImmunity",
  proc { |score, move, user, target, ai, battle|
    if target.effects[PBEffects::MiracleEye]
      score -= 50
    elsif target.has_type?(:DARK)
      score += 70
    elsif target.stages[:EVASION] <= 0
      score -= 60
    end
    next score
  }
)

# IgnoreTargetDefSpDefEvaStatStages

# TypeIsUserFirstType

Battle::AI::Handlers::MoveBasePower.add("TypeDependsOnUserIVs",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)

Battle::AI::Handlers::MoveFailureCheck.add("TypeAndPowerDependOnUserBerry",
  proc { |move, user, target, ai, battle|
    item = user.item
    next true if !item || !item.is_berry? || !user.item_active?
    next true if item.flags.none? { |f| f[/^NaturalGift_/i] }
  }
)
Battle::AI::Handlers::MoveBasePower.add("TypeAndPowerDependOnUserBerry",
  proc { |power, move, user, target, ai, battle|
    # TODO: Can't this just call move.pbBaseDamage?
    ret = move.pbNaturalGiftBaseDamage(user.item_id)
    next (ret == 1) ? 0 : ret
  }
)

# TypeDependsOnUserPlate

# TypeDependsOnUserMemory

# TypeDependsOnUserDrive

Battle::AI::Handlers::MoveFailureCheck.add("TypeDependsOnUserMorpekoFormRaiseUserSpeed1",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.isSpecies?(:MORPEKO) && user.effects[PBEffects::TransformSpecies] != :MORPEKO
  }
)
Battle::AI::Handlers::MoveEffectScore.add("TypeDependsOnUserMorpekoFormRaiseUserSpeed1",
  proc { |score, move, user, target, ai, battle|
    next score + 20 if user.stages[:SPEED] <= 0
  }
)

Battle::AI::Handlers::MoveBasePower.add("TypeAndPowerDependOnWeather",
  proc { |power, move, user, target, ai, battle|
    next move.pbBaseDamage(power, user.battler, target.battler)
  }
)

Battle::AI::Handlers::MoveBasePower.copy("TypeAndPowerDependOnWeather",
                                         "TypeAndPowerDependOnTerrain")
Battle::AI::Handlers::MoveEffectScore.add("TypeAndPowerDependOnTerrain",
  proc { |score, move, user, target, ai, battle|
    next score + 40 if battle.field.terrain != :None
  }
)

Battle::AI::Handlers::MoveEffectScore.add("TargetMovesBecomeElectric",
  proc { |score, move, user, target, ai, battle|
    next 0 if user.faster_than?(target)
  }
)

# NormalMovesBecomeElectric
