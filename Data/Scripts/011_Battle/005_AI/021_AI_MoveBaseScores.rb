class Battle::AI
  #=============================================================================
  # Calculate how much damage a move is likely to do to a given target (as a
  # percentage of the target's current HP)
  # TODO: How much is this going to be used? Should the predicted percentage of
  #       damage be used as the initial score for damaging moves?
  #=============================================================================
  def pbGetDamagingMoveBaseScore
    return 100

=begin
    # Don't prefer moves that are ineffective because of abilities or effects
    return 0 if @target.immune_to_move?
    user_battler = @user.battler
    target_battler = @target.battler

    # Calculate how much damage the move will do (roughly)
    calc_damage = @move.rough_damage

    # TODO: Maybe move this check elsewhere? Note that Reborn's base score does
    #       not include this halving, but the predicted damage does.
    # Two-turn attacks waste 2 turns to deal one lot of damage
    calc_damage /= 2 if @move.move.chargingTurnMove?

    # TODO: Maybe move this check elsewhere?
    # Increased critical hit rate
    if @trainer.medium_skill?
      crit_stage = @move.rough_critical_hit_stage
      if crit_stage >= 0
        crit_fraction = (crit_stage > 50) ? 1 : Battle::Move::CRITICAL_HIT_RATIOS[crit_stage]
        crit_mult = (Settings::NEW_CRITICAL_HIT_RATE_MECHANICS) ? 0.5 : 1
        calc_damage *= (1 + crit_mult / crit_fraction)
      end
    end

    # Convert damage to percentage of target's remaining HP
    damage_percentage = calc_damage * 100.0 / target_battler.hp

    # Don't prefer weak attacks
#    damage_percentage /= 2 if damage_percentage < 20

    # Prefer damaging attack if level difference is significantly high
#    damage_percentage *= 1.2 if user_battler.level - 10 > target_battler.level

    # Adjust score
    damage_percentage = 110 if damage_percentage > 110   # Treat all lethal moves the same
    damage_percentage += 40 if damage_percentage > 100   # Prefer moves likely to be lethal

    return damage_percentage.to_i
=end
  end

  #=============================================================================
  # TODO: Remove this method. If we're keeping any score changes inherent to a
  #       move's effect, they will go in MoveEffectScore handlers instead.
  #=============================================================================
  def pbGetStatusMoveBaseScore
    return 100

=begin
    # TODO: Call @target.immune_to_move? here too, not just for damaging moves
    #       (only if this status move will be affected).

    # TODO: Make sure all status moves are accounted for.
    # TODO: Duplicates in Reborn's AI:
    # "SleepTarget"  Grass Whistle (15), Hypnosis (15), Sing (15),
    #                Lovely Kiss (20), Sleep Powder (20), Spore (60)
    # "PoisonTarget" - Poison Powder (15), Poison Gas (20)
    # "ParalyzeTarget" - Stun Spore (25), Glare (30)
    # "ConfuseTarget" - Teeter Dance (5), Supersonic (10),
    #                   Sweet Kiss (20), Confuse Ray (25)
    # "RaiseUserAttack1" - Howl (10), Sharpen (10), Medicate (15)
    # "RaiseUserSpeed2" - Agility (15), Rock Polish (25)
    # "LowerTargetAttack1" - Growl (10), Baby-Doll Eyes (15)
    # "LowerTargetAccuracy1" - Sand Attack (5), Flash (10), Kinesis (10), Smokescreen (10)
    # "LowerTargetAttack2" - Charm (10), Feather Dance (15)
    # "LowerTargetSpeed2" - String Shot (10), Cotton Spore (15), Scary Face (15)
    # "LowerTargetSpDef2" - Metal Sound (10), Fake Tears (15)
    case @move.move.function
    when "ConfuseTarget",
         "LowerTargetAccuracy1",
         "LowerTargetEvasion1RemoveSideEffects",
         "UserTargetSwapAtkSpAtkStages",
         "UserTargetSwapDefSpDefStages",
         "UserSwapBaseAtkDef",
         "UserTargetAverageBaseAtkSpAtk",
         "UserTargetAverageBaseDefSpDef",
         "SetUserTypesToUserMoveType",
         "SetTargetTypesToWater",
         "SetUserTypesToTargetTypes",
         "SetTargetAbilityToUserAbility",
         "UserTargetSwapAbilities",
         "PowerUpAllyMove",
         "StartWeakenElectricMoves",
         "StartWeakenFireMoves",
         "EnsureNextMoveAlwaysHits",
         "StartNegateTargetEvasionStatStageAndGhostImmunity",
         "StartNegateTargetEvasionStatStageAndDarkImmunity",
         "ProtectUserSideFromPriorityMoves",
         "ProtectUserSideFromMultiTargetDamagingMoves",
         "BounceBackProblemCausingStatusMoves",
         "StealAndUseBeneficialStatusMove",
         "DisableTargetMovesKnownByUser",
         "DisableTargetHealingMoves",
         "SetAttackerMovePPTo0IfUserFaints",
         "UserEnduresFaintingThisTurn",
         "RestoreUserConsumedItem",
         "StartNegateHeldItems",
         "StartDamageTargetEachTurnIfTargetAsleep",
         "HealUserDependingOnUserStockpile",
         "StartGravity",
         "StartUserAirborne",
         "UserSwapsPositionsWithAlly",
         "StartSwapAllBattlersBaseDefensiveStats",
         "RaiseTargetSpDef1",
         "RaiseGroundedGrassBattlersAtkSpAtk1",
         "RaiseGrassBattlersDef1",
         "AddGrassTypeToTarget",
         "TrapAllBattlersInBattleForOneTurn",
         "EnsureNextCriticalHit",
         "UserTargetSwapBaseSpeed",
         "RedirectAllMovesToTarget",
         "TargetUsesItsLastUsedMoveAgain"
      return 55
    when "RaiseUserAttack1",
         "RaiseUserDefense1",
         "RaiseUserDefense1CurlUpUser",
         "RaiseUserCriticalHitRate2",
         "RaiseUserAtkSpAtk1",
         "RaiseUserAtkSpAtk1Or2InSun",
         "RaiseUserAtkAcc1",
         "RaiseTargetRandomStat2",
         "LowerTargetAttack1",
         "LowerTargetDefense1",
         "LowerTargetAccuracy1",
         "LowerTargetAttack2",
         "LowerTargetSpeed2",
         "LowerTargetSpDef2",
         "ResetAllBattlersStatStages",
         "UserCopyTargetStatStages",
         "SetUserTypesBasedOnEnvironment",
         "DisableTargetUsingSameMoveConsecutively",
         "StartTargetCannotUseItem",
         "LowerTargetAttack1BypassSubstitute",
         "LowerTargetAtkSpAtk1",
         "LowerTargetSpAtk1",
         "TargetNextFireMoveDamagesTarget"
      return 60
    when "SleepTarget",
         "SleepTargetIfUserDarkrai",
         "SleepTargetChangeUserMeloettaForm",
         "PoisonTarget",
         "CureUserBurnPoisonParalysis",
         "RaiseUserAttack1",
         "RaiseUserSpDef1PowerUpElectricMove",
         "RaiseUserEvasion1",
         "RaiseUserSpeed2",
         "LowerTargetAttack1",
         "LowerTargetAtkDef1",
         "LowerTargetAttack2",
         "LowerTargetDefense2",
         "LowerTargetSpeed2",
         "LowerTargetSpAtk2IfCanAttract",
         "LowerTargetSpDef2",
         "ReplaceMoveThisBattleWithTargetLastMoveUsed",
         "ReplaceMoveWithTargetLastMoveUsed",
         "SetUserAbilityToTargetAbility",
         "UseMoveTargetIsAboutToUse",
         "UseRandomMoveFromUserParty",
         "StartHealUserEachTurnTrapUserInBattle",
         "HealTargetHalfOfTotalHP",
         "UserFaintsHealAndCureReplacement",
         "UserFaintsHealAndCureReplacementRestorePP",
         "StartSunWeather",
         "StartRainWeather",
         "StartSandstormWeather",
         "StartHailWeather",
         "RaisePlusMinusUserAndAlliesDefSpDef1",
         "LowerTargetSpAtk2",
         "LowerPoisonedTargetAtkSpAtkSpd1",
         "AddGhostTypeToTarget",
         "LowerTargetAtkSpAtk1SwitchOutUser",
         "RaisePlusMinusUserAndAlliesAtkSpAtk1",
         "HealTargetDependingOnGrassyTerrain"
      return 65
    when "SleepTarget",
         "SleepTargetChangeUserMeloettaForm",
         "SleepTargetNextTurn",
         "PoisonTarget",
         "ConfuseTarget",
         "RaiseTargetSpAtk1ConfuseTarget",
         "RaiseTargetAttack2ConfuseTarget",
         "UserTargetSwapStatStages",
         "StartUserSideImmunityToStatStageLowering",
         "SetUserTypesToResistLastAttack",
         "SetTargetAbilityToSimple",
         "SetTargetAbilityToInsomnia",
         "NegateTargetAbility",
         "TransformUserIntoTarget",
         "UseLastMoveUsedByTarget",
         "UseLastMoveUsed",
         "UseRandomMove",
         "HealUserFullyAndFallAsleep",
         "StartHealUserEachTurn",
         "StartPerishCountsForAllBattlers",
         "SwitchOutTargetStatusMove",
         "TrapTargetInBattle",
         "TargetMovesBecomeElectric",
         "NormalMovesBecomeElectric",
         "PoisonTargetLowerTargetSpeed1"
      return 70
    when "BadPoisonTarget",
         "ParalyzeTarget",
         "BurnTarget",
         "ConfuseTarget",
         "AttractTarget",
         "GiveUserStatusToTarget",
         "RaiseUserDefSpDef1",
         "RaiseUserDefense2",
         "RaiseUserSpeed2",
         "RaiseUserSpeed2LowerUserWeight",
         "RaiseUserSpDef2",
         "RaiseUserEvasion2MinimizeUser",
         "RaiseUserDefense3",
         "MaxUserAttackLoseHalfOfTotalHP",
         "UserTargetAverageHP",
         "ProtectUser",
         "DisableTargetLastMoveUsed",
         "DisableTargetStatusMoves",
         "HealUserHalfOfTotalHP",
         "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn",
         "HealUserPositionNextTurn",
         "HealUserDependingOnWeather",
         "StartLeechSeedTarget",
         "AttackerFaintsIfUserFaints",
         "UserTargetSwapItems",
         "UserMakeSubstitute",
         "UserAddStockpileRaiseDefSpDef1",
         "RedirectAllMovesToUser",
         "InvertTargetStatStages",
         "HealUserByTargetAttackLowerTargetAttack1",
         "HealUserDependingOnSandstorm"
      return 75
    when "ParalyzeTarget",
         "ParalyzeTargetIfNotTypeImmune",
         "RaiseUserAtkDef1",
         "RaiseUserAtkDefAcc1",
         "RaiseUserSpAtkSpDef1",
         "UseMoveDependingOnEnvironment",
         "UseRandomUserMoveIfAsleep",
         "DisableTargetUsingDifferentMove",
         "SwitchOutUserPassOnEffects",
         "AddSpikesToFoeSide",
         "AddToxicSpikesToFoeSide",
         "AddStealthRocksToFoeSide",
         "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
         "StartSlowerBattlersActFirst",
         "ProtectUserFromTargetingMovesSpikyShield",
         "StartElectricTerrain",
         "StartGrassyTerrain",
         "StartMistyTerrain",
         "StartPsychicTerrain",
         "CureTargetStatusHealUserHalfOfTotalHP"
      return 80
    when "CureUserPartyStatus",
         "RaiseUserAttack2",
         "RaiseUserSpAtk2",
         "RaiseUserSpAtk3",
         "StartUserSideDoubleSpeed",
         "StartWeakenPhysicalDamageAgainstUserSide",
         "StartWeakenSpecialDamageAgainstUserSide",
         "ProtectUserSideFromDamagingMovesIfUserFirstTurn",
         "ProtectUserFromDamagingMovesKingsShield",
         "ProtectUserBanefulBunker"
      return 85
    when "RaiseUserAtkSpd1",
         "RaiseUserSpAtkSpDefSpd1",
         "LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2",
         "RaiseUserAtk1Spd2",
         "TwoTurnAttackRaiseUserSpAtkSpDefSpd2"
      return 90
    when "SleepTarget",
         "SleepTargetChangeUserMeloettaForm",
         "AddStickyWebToFoeSide",
         "StartWeakenDamageAgainstUserSideIfHail"
      return 100
    end
    # "DoesNothingUnusableInGravity",
    # "StartUserSideImmunityToInflictedStatus",
    # "LowerTargetEvasion1",
    # "LowerTargetEvasion2",
    # "StartPreventCriticalHitsAgainstUserSide",
    # "UserFaintsLowerTargetAtkSpAtk2",
    # "FleeFromBattle",
    # "SwitchOutUserStatusMove"
    # "TargetTakesUserItem",
    # "LowerPPOfTargetLastMoveBy4",
    # "StartTargetAirborneAndAlwaysHitByMoves",
    # "TargetActsNext",
    # "TargetActsLast",
    # "ProtectUserSideFromStatusMoves"
    return 100
=end
  end
end
