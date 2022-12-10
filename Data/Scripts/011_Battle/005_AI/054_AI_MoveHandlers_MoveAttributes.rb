#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("FixedDamage20",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbFixedDamage(user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("FixedDamage40",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbFixedDamage(user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("FixedDamageHalfTargetHP",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbFixedDamage(user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("FixedDamageUserLevel",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbFixedDamage(user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("FixedDamageUserLevelRandom",
  proc { |power, move, user, target, ai, battle|
    next user.level   # Average power
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("LowerTargetHPToUserHP",
  proc { |move, user, target, ai, battle|
    next true if user.hp >= target.hp
  }
)
Battle::AI::Handlers::MoveBasePower.add("LowerTargetHPToUserHP",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbFixedDamage(user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("OHKO",
  proc { |move, user, target, ai, battle|
    next true if target.level > user.level
    next true if !battle.moldBreaker && target.has_active_ability?(:STURDY)
  }
)
Battle::AI::Handlers::MoveBasePower.add("OHKO",
  proc { |power, move, user, target, ai, battle|
    next target.hp
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("OHKO",
  proc { |score, move, user, target, ai, battle|
    # Don't prefer if the target has less HP and user has a non-OHKO damaging move
    if user.check_for_move { |m| !m.is_a?(Battle::Move::OHKO) && m.damagingMove? }
      score -= 10 if target.hp <= target.totalhp / 2
      score -= 10 if target.hp <= target.totalhp / 4
    end
    # TODO: Maybe predict dealt damage of all user's other moves, and score this
    #       move useless if another one can KO the target. Might also need to
    #       take into account whether those moves will fail. Might need to do
    #       this specially after all move scores are determined.
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("OHKOIce",
  proc { |move, user, target, ai, battle|
    next true if target.has_type?(:ICE)
    next Battle::AI::Handlers.move_will_fail_against_target?("OHKO", move, user, target, ai, battle)
  }
)
Battle::AI::Handlers::MoveBasePower.copy("OHKO",
                                         "OHKOIce")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("OHKO",
                                                        "OHKOIce")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.copy("OHKO",
                                                         "OHKOHitsUndergroundTarget")
Battle::AI::Handlers::MoveBasePower.copy("OHKO",
                                         "OHKOHitsUndergroundTarget")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.copy("OHKO",
                                                        "OHKOHitsUndergroundTarget")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DamageTargetAlly",
  proc { |score, move, user, target, ai, battle|
    target.battler.allAllies.each do |b|
      next if !b.near?(target.battler) || !b.battler.takesIndirectDamage?
      score += 10
      score += 15 if b.hp <= b.totalhp / 16
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("PowerHigherWithUserHP",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("PowerHigherWithUserHP",
                                         "PowerLowerWithUserHP")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("PowerHigherWithUserHP",
                                         "PowerHigherWithTargetHP")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("PowerHigherWithUserHP",
                                         "PowerHigherWithUserHappiness")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("PowerHigherWithUserHP",
                                         "PowerLowerWithUserHappiness")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("PowerHigherWithUserHP",
                                         "PowerHigherWithUserPositiveStatStages")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("PowerHigherWithUserHP",
                                         "PowerHigherWithTargetPositiveStatStages")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("PowerHigherWithUserHP",
                                         "PowerHigherWithUserFasterThanTarget")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("PowerHigherWithUserHP",
                                         "PowerHigherWithTargetFasterThanUser")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("PowerHigherWithLessPP",
  proc { |power, move, user, target, ai, battle|
    next 0 if move.move.pp == 0 && move.move.totalpp > 0
    dmgs = [200, 80, 60, 50, 40]
    ppLeft = [move.pp - 1, dmgs.length - 1].min
    next dmgs[ppLeft]
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("PowerHigherWithTargetWeight",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("PowerHigherWithTargetWeight",
                                         "PowerHigherWithUserHeavierThanTarget")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("PowerHigherWithConsecutiveUse",
  proc { |power, move, user, target, ai, battle|
    next power << user.effects[PBEffects::FuryCutter]
  }
)
Battle::AI::Handlers::MoveEffectScore.add("PowerHigherWithConsecutiveUse",
  proc { |score, move, user, ai, battle|
    # Prefer continuing to use this move
    score += 10 if user.effects[PBEffects::FuryCutter] > 0
    # Prefer if holding the Metronome
    score += 5 if user.has_active_item?(:METRONOME)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("PowerHigherWithConsecutiveUseOnUserSide",
  proc { |power, move, user, target, ai, battle|
    next power * (user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] + 1)
  }
)
Battle::AI::Handlers::MoveEffectScore.add("PowerHigherWithConsecutiveUse",
  proc { |score, move, user, ai, battle|
    # Prefer continuing to use this move
    score += 10 if user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] > 0
    # Prefer if holding the Metronome
    score += 5 if user.has_active_item?(:METRONOME)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("RandomPowerDoublePowerIfTargetUnderground",
  proc { |power, move, user, target, ai, battle|
    power = 71   # Average damage
    next move.move.pbModifyDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfTargetHPLessThanHalf",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetHPLessThanHalf",
                                         "DoublePowerIfUserPoisonedBurnedParalyzed")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetHPLessThanHalf",
                                         "DoublePowerIfTargetAsleepCureTarget")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DoublePowerIfTargetAsleepCureTarget",
  proc { |score, move, user, target, ai, battle|
    next score - 20 if target.status == :SLEEP &&   # Will cure status
                       target.statusCount > 1
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfTargetPoisoned",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetPoisoned",
                                         "DoublePowerIfTargetParalyzedCureTarget")
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DoublePowerIfTargetParalyzedCureTarget",
  proc { |score, move, user, target, ai, battle|
    next score - 20 if target.status == :PARALYSIS   # Will cure status
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfTargetStatusProblem",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfUserHasNoItem",
  proc { |power, move, user, target, ai, battle|
    next power * 2 if !user.item || user.has_active_item?(:FLYINGGEM)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfTargetUnderwater",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbModifyDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetUnderwater",
                                         "DoublePowerIfTargetUnderground")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("DoublePowerIfTargetInSky",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetInSky",
                                         "DoublePowerInElectricTerrain")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetInSky",
                                         "DoublePowerIfUserLastMoveFailed")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("DoublePowerIfTargetInSky",
                                         "DoublePowerIfAllyFaintedLastTurn")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("DoublePowerIfUserLostHPThisTurn",
  proc { |score, move, user, ai, battle|
    # TODO: Remove target from this; consider the speeds of all foes instead.
#    next score + 15 if target.faster_than?(user)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DoublePowerIfTargetLostHPThisTurn",
  proc { |score, move, user, target, ai, battle|
    next score + 15 if battle.pbOpposingBattlerCount(user.battler) > 1
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# DoublePowerIfUserStatsLoweredThisTurn

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DoublePowerIfTargetActed",
  proc { |score, move, user, target, ai, battle|
    next score + 15 if target.faster_than?(user)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DoublePowerIfTargetNotActed",
  proc { |score, move, user, target, ai, battle|
    next score + 15 if user.faster_than?(target)
  }
)

#===============================================================================
#
#===============================================================================
# AlwaysCriticalHit

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("EnsureNextCriticalHit",
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if user.effects[PBEffects::LaserFocus] > 0
    # TODO: Useless if user will already always critical hit ("AlwaysCriticalHit"
    #       or Lucky Chant/crit stage is +3/etc.).
    next score + 10
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartPreventCriticalHitsAgainstUserSide",
  proc { |move, user, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::LuckyChant] > 0
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("CannotMakeTargetFaint",
  proc { |move, user, target, ai, battle|
    next true if target.hp == 1
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("UserEnduresFaintingThisTurn",
  proc { |score, move, user, ai, battle|
    score -= 10 if user.hp > user.totalhp / 2
    if ai.trainer.medium_skill?
      score -= 20 if user.effects[PBEffects::ProtectRate] > 1
#      score -= 20 if target.effects[PBEffects::HyperBeam] > 0
    else
      score -= user.effects[PBEffects::ProtectRate] * 10
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartWeakenElectricMoves",
  proc { |move, user, ai, battle|
    if Settings::MECHANICS_GENERATION >= 6
      next true if battle.field.effects[PBEffects::MudSportField] > 0
    else
      next true if battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartWeakenElectricMoves",
  proc { |score, move, user, ai, battle|
    # Don't prefer the lower the user's HP is
    if user.hp < user.totalhp / 2
      score -= 40 * (0.75 - (user.hp.to_f / user.totalhp))   # -10 to -30
    end
    # Prefer if foes have Electric moves
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) == :ELECTRIC }
      score += 10
      score += 5 if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) != :ELECTRIC }
    end
    # Don't prefer if any allies have Electric moves
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) == :ELECTRIC }
      score -= 8
      score -= 4 if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) != :ELECTRIC }
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartWeakenFireMoves",
  proc { |move, user, ai, battle|
    if Settings::MECHANICS_GENERATION >= 6
      next true if battle.field.effects[PBEffects::WaterSportField] > 0
    else
      next true if battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
    end
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartWeakenElectricMoves",
  proc { |score, move, user, ai, battle|
    # Don't prefer the lower the user's HP is
    if user.hp < user.totalhp / 2
      score -= 40 * (0.75 - (user.hp.to_f / user.totalhp))   # -10 to -30
    end
    # Prefer if foes have Fire moves
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) == :FIRE }
      score += 10
      score += 5 if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) != :FIRE }
    end
    # Don't prefer if any allies have Fire moves
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) == :FIRE }
      score -= 8
      score -= 4 if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) != :FIRE }
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartWeakenPhysicalDamageAgainstUserSide",
  proc { |move, user, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::Reflect] > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartWeakenPhysicalDamageAgainstUserSide",
  proc { |score, move, user, ai, battle|
    # Doesn't stack with Aurora Veil
    next Battle::AI::MOVE_USELESS_SCORE if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
    # Don't prefer the lower the user's HP is
    # TODO: Should this HP check exist? The effect can still be set up for
    #       allies. Maybe just don't prefer if there are no replacement mons
    #       left.
    if user.hp < user.totalhp / 2
      score -= 40 * (0.75 - (user.hp.to_f / user.totalhp))   # -10 to -30
    end
    # Prefer if foes have physical moves (moreso if they don't have special moves)
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.physicalMove?(m.type) }
      score += 8
      score += 5 if !b.check_for_move { |m| m.specialMove?(m.type) }
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartWeakenSpecialDamageAgainstUserSide",
  proc { |move, user, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::LightScreen] > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartWeakenSpecialDamageAgainstUserSide",
  proc { |score, move, user, ai, battle|
    # Doesn't stack with Aurora Veil
    next Battle::AI::MOVE_USELESS_SCORE if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
    # Don't prefer the lower the user's HP is
    # TODO: Should this HP check exist? The effect can still be set up for
    #       allies. Maybe just don't prefer if there are no replacement mons
    #       left.
    if user.hp < user.totalhp / 2
      score -= 40 * (0.75 - (user.hp.to_f / user.totalhp))   # -10 to -30
    end
    # Prefer if foes have special moves (moreso if they don't have physical moves)
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.specialMove?(m.type) }
      score += 8
      score += 5 if !b.check_for_move { |m| m.physicalMove?(m.type) }
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("StartWeakenDamageAgainstUserSideIfHail",
  proc { |move, user, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
    next true if user.battler.effectiveWeather != :Hail
  }
)
Battle::AI::Handlers::MoveEffectScore.add("StartWeakenDamageAgainstUserSideIfHail",
  proc { |score, move, user, ai, battle|
    # Doesn't stack with Reflect/Light Screen
    next Battle::AI::MOVE_USELESS_SCORE if user.pbOwnSide.effects[PBEffects::Reflect] > 0 &&
                                           user.pbOwnSide.effects[PBEffects::LightScreen] > 0
    # Don't prefer the lower the user's HP is
    # TODO: Should this HP check exist? The effect can still be set up for
    #       allies. Maybe just don't prefer if there are no replacement mons
    #       left.
    if user.hp < user.totalhp / 2
      score -= 40 * (0.75 - (user.hp.to_f / user.totalhp))   # -10 to -30
    end
    next score + 15
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("RemoveScreens",
  proc { |score, move, user, ai, battle|
    # Prefer if allies have physical moves that are being weakened
    if user.pbOpposingSide.effects[PBEffects::Reflect] > 0 ||
       user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
      ai.each_same_side_battler(user.side) do |b, i|
        score += 10 if b.check_for_move { |m| m.physicalMove?(m.type) }
      end
    end
    # Prefer if allies have special moves that are being weakened
    if user.pbOpposingSide.effects[PBEffects::LightScreen] > 0 ||
       user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
      ai.each_same_side_battler(user.side) do |b, i|
        score += 10 if b.check_for_move { |m| m.specialMove?(m.type) }
      end
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("ProtectUser",
  proc { |score, move, user, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1   # ||
#       target.effects[PBEffects::HyperBeam] > 0
      score -= 50
    else
      if ai.trainer.medium_skill?
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
#      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("ProtectUserBanefulBunker",
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if user.effects[PBEffects::ProtectRate] > 1   #  ||
#                                           target.effects[PBEffects::HyperBeam] > 0
    if ai.trainer.medium_skill?
      score -= user.effects[PBEffects::ProtectRate] * 40
    end
    score += 10 if user.turnCount == 0
#    score += 15 if target.effects[PBEffects::TwoTurnAttack]
    score += 15   # Because of possible poisoning
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("ProtectUserFromDamagingMovesKingsShield",
  proc { |score, move, user, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1   # ||
#       target.effects[PBEffects::HyperBeam] > 0
      score -= 50
    else
      if ai.trainer.medium_skill?
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
#      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("ProtectUserFromDamagingMovesObstruct",
  proc { |score, move, user, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1   # ||
#       target.effects[PBEffects::HyperBeam] > 0
      score -= 50
    else
      if ai.trainer.medium_skill?
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
#      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
Battle::AI::Handlers::MoveEffectScore.add("ProtectUserFromTargetingMovesSpikyShield",
  proc { |score, move, user, ai, battle|
    if user.effects[PBEffects::ProtectRate] > 1   # ||
#       target.effects[PBEffects::HyperBeam] > 0
      score -= 90
    else
      if ai.trainer.medium_skill?
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
      score += 50 if user.turnCount == 0
#      score += 30 if target.effects[PBEffects::TwoTurnAttack]
    end
    next score
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("ProtectUserSideFromDamagingMovesIfUserFirstTurn",
  proc { |move, user, ai, battle|
    next true if user.turnCount > 0
  }
)
Battle::AI::Handlers::MoveEffectScore.add("ProtectUserSideFromDamagingMovesIfUserFirstTurn",
  proc { |score, move, user, ai, battle|
    next score + 25   # Use it or lose it
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("ProtectUserSideFromStatusMoves",
  proc { |move, user, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::CraftyShield]
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
# ProtectUserSideFromPriorityMoves

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code shouldn't make use of target.
#===============================================================================
# ProtectUserSideFromMultiTargetDamagingMoves

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# RemoveProtections

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# RemoveProtectionsBypassSubstitute

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("HoopaRemoveProtectionsBypassSubstituteLowerUserDef1",
  proc { |move, user, ai, battle|
    next true if !user.battler.isSpecies?(:HOOPA) || user.battler.form != 1
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HoopaRemoveProtectionsBypassSubstituteLowerUserDef1",
  proc { |score, move, user, target, ai, battle|
    next score + 20 if target.stages[:DEFENSE] > 0
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RecoilQuarterOfDamageDealt",
  proc { |score, move, user, target, ai, battle|
    next score if !user.battler.takesIndirectDamage? || user.has_active_ability?(:ROCKHEAD)
    dmg = move.rough_damage / 4
    if dmg >= user.hp
      reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
      next Battle::AI::MOVE_USELESS_SCORE if reserves <= foes
    end
    score -= 10 * [dmg, user.hp].min / user.hp
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RecoilThirdOfDamageDealtParalyzeTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for being a recoil move
    if user.battler.takesIndirectDamage? && !user.has_active_ability?(:ROCKHEAD)
      dmg = move.rough_damage / 3
      if dmg >= user.hp
        reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
        foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
        next Battle::AI::MOVE_USELESS_SCORE if reserves <= foes
      end
      score -= 10 * [dmg, user.hp].min / user.hp
    end
    # Score for paralysing
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("ParalyzeTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RecoilThirdOfDamageDealtBurnTarget",
  proc { |score, move, user, target, ai, battle|
    # Score for being a recoil move
    if user.battler.takesIndirectDamage? && !user.has_active_ability?(:ROCKHEAD)
      dmg = move.rough_damage / 3
      if dmg >= user.hp
        reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
        foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
        next Battle::AI::MOVE_USELESS_SCORE if reserves <= foes
      end
      score -= 10 * [dmg, user.hp].min / user.hp
    end
    # Score for burning
    score = Battle::AI::Handlers.apply_move_effect_against_target_score("BurnTarget",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RecoilHalfOfDamageDealt",
  proc { |score, move, user, target, ai, battle|
    next score if !user.battler.takesIndirectDamage? || user.has_active_ability?(:ROCKHEAD)
    dmg = move.rough_damage / 2
    if dmg >= user.hp
      reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
      next Battle::AI::MOVE_USELESS_SCORE if reserves <= foes
    end
    score -= 10 * [dmg, user.hp].min / user.hp
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("EffectivenessIncludesFlyingType",
  proc { |power, move, user, target, ai, battle|
    if GameData::Type.exists?(:FLYING)
      targetTypes = target.battler.pbTypes(true)
      mult = Effectiveness.calculate(
        :FLYING, targetTypes[0], targetTypes[1], targetTypes[2]
      )
      next (power.to_f * mult / Effectiveness::NORMAL_EFFECTIVE).round
    end
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("CategoryDependsOnHigherDamagePoisonTarget",
  proc { |score, move, user, target, ai, battle|
    next score + 5 if target.battler.pbCanPoison?(user.battler, false)
  }
)

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
# CategoryDependsOnHigherDamageIgnoreTargetAbility

#===============================================================================
#
#===============================================================================
# UseUserDefenseInsteadOfUserAttack

#===============================================================================
#
#===============================================================================
# UseTargetAttackInsteadOfUserAttack

#===============================================================================
#
#===============================================================================
# UseTargetDefenseInsteadOfTargetSpDef

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("EnsureNextMoveAlwaysHits",
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::LockOn] > 0
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("EnsureNextMoveAlwaysHits",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if user.has_active_ability?(:NOGUARD) || target.has_active_ability?(:NOGUARD)
    next Battle::AI::MOVE_USELESS_SCORE if target.effects[PBEffects::Telekinesis] > 0
    # Prefer if the user knows moves with low accuracy
    # TODO: This isn't the correct use of check_for_move, since it should just
    #       loop through them instead.
    user.check_for_move do |m|
      next if target.effects[PBEffects::Minimize] && m.tramplesMinimize? && Settings::MECHANICS_GENERATION >= 6
      # TODO: There are other effects that make a move certain to hit. Account
      #       for those as well. Score this move useless if no moves would
      #       benefit from locking on.
      acc = m.accuracy
      acc = m.pbBaseAccuracy(user.battler, target.battler) if ai.trainer.medium_skill?
      score += 4 if acc < 90 && acc != 0
      score += 4 if acc <= 50 && acc != 0
      # TODO: Prefer more if m is a OHKO move.
    end
    # Not worth it if the user or the target is at low HP
    score -= 10 if user.hp < user.totalhp / 2
    score -= 8 if target.hp < target.totalhp / 2
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("StartNegateTargetEvasionStatStageAndGhostImmunity",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.effects[PBEffects::Foresight] || user.has_active_ability?(:SCRAPPY)
    # Check if the user knows any moves that would benefit from negating the
    # target's Ghost type immunity
    if target.has_type?(:GHOST)
      user.check_for_move do |m|
        next if !m.damagingMove?
        score += 10 if Effectiveness.ineffective_type?(m.pbCalcType(user.battler), :GHOST)
      end
    end
    # Prefer if the target has increased evasion
    score += 10 * target.stages[:EVASION] if target.stages[:EVASION] > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("StartNegateTargetEvasionStatStageAndDarkImmunity",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.effects[PBEffects::MiracleEye]
    # Check if the user knows any moves that would benefit from negating the
    # target's Dark type immunity
    if target.has_type?(:DARK)
      user.check_for_move do |m|
        next if !m.damagingMove?
        score += 10 if Effectiveness.ineffective_type?(m.pbCalcType(user.battler), :DARK)
      end
    end
    # Prefer if the target has increased evasion
    score += 10 * target.stages[:EVASION] if target.stages[:EVASION] > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
# IgnoreTargetDefSpDefEvaStatStages

#===============================================================================
#
#===============================================================================
# TypeIsUserFirstType

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("TypeDependsOnUserIVs",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("TypeAndPowerDependOnUserBerry",
  proc { |move, user, ai, battle|
    item = user.item
    next true if !item || !item.is_berry? || !user.item_active?
    next true if item.flags.none? { |f| f[/^NaturalGift_/i] }
  }
)
Battle::AI::Handlers::MoveBasePower.add("TypeAndPowerDependOnUserBerry",
  proc { |power, move, user, target, ai, battle|
    ret = move.move.pbBaseDamage(1, user.battler, target.battler)
    next (ret == 1) ? 0 : ret
  }
)

#===============================================================================
#
#===============================================================================
# TypeDependsOnUserPlate

#===============================================================================
#
#===============================================================================
# TypeDependsOnUserMemory

#===============================================================================
#
#===============================================================================
# TypeDependsOnUserDrive

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveFailureCheck.add("TypeDependsOnUserMorpekoFormRaiseUserSpeed1",
  proc { |move, user, ai, battle|
    next true if !user.battler.isSpecies?(:MORPEKO) && user.effects[PBEffects::TransformSpecies] != :MORPEKO
  }
)
Battle::AI::Handlers::MoveEffectScore.copy("RaiseUserSpeed1",
                                           "TypeDependsOnUserMorpekoFormRaiseUserSpeed1")

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.add("TypeAndPowerDependOnWeather",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
Battle::AI::Handlers::MoveBasePower.copy("TypeAndPowerDependOnWeather",
                                         "TypeAndPowerDependOnTerrain")

#===============================================================================
# TODO: Review score modifiers.
#===============================================================================
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("TargetMovesBecomeElectric",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if user.faster_than?(target)
  }
)

#===============================================================================
# TODO: Review score modifiers.
# TODO: This code can be called with a single target and with no targets. Make
#       sure it doesn't assume that there is a target.
#===============================================================================
# NormalMovesBecomeElectric
