class Battle::AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias aiEffectScorePart2_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    case move.function
    #---------------------------------------------------------------------------
    when "FixedDamage20"
      if target.hp <= 20
        score += 80
      elsif target.level >= 25
        score -= 60   # Not useful against high-level Pokemon
      end
    #---------------------------------------------------------------------------
    when "FixedDamage40"
      score += 80 if target.hp <= 40
    #---------------------------------------------------------------------------
    when "FixedDamageHalfTargetHP"
      score -= 50
      score += target.hp * 100 / target.totalhp
    #---------------------------------------------------------------------------
    when "FixedDamageUserLevel"
      score += 80 if target.hp <= user.level
    #---------------------------------------------------------------------------
    when "FixedDamageUserLevelRandom"
      score += 30 if target.hp <= user.level
    #---------------------------------------------------------------------------
    when "LowerTargetHPToUserHP"
      if user.hp >= target.hp
        score -= 90
      elsif user.hp < target.hp / 2
        score += 50
      end
    #---------------------------------------------------------------------------
    when "OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"
      score -= 90 if target.hasActiveAbility?(:STURDY)
      score -= 90 if target.level > user.level
    #---------------------------------------------------------------------------
    when "DamageTargetAlly"
      target.allAllies.each do |b|
        next if !b.near?(target)
        score += 10
      end
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHP"
    #---------------------------------------------------------------------------
    when "PowerLowerWithUserHP"
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetHP"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHappiness"
    #---------------------------------------------------------------------------
    when "PowerLowerWithUserHappiness"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserPositiveStatStages"
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetPositiveStatStages"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserFasterThanTarget"
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetFasterThanUser"
    #---------------------------------------------------------------------------
    when "PowerHigherWithLessPP"
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetWeight"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHeavierThanTarget"
    #---------------------------------------------------------------------------
    when "PowerHigherWithConsecutiveUse"
    #---------------------------------------------------------------------------
    when "PowerHigherWithConsecutiveUseOnUserSide"
    #---------------------------------------------------------------------------
    when "RandomPowerDoublePowerIfTargetUnderground"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetHPLessThanHalf"
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserPoisonedBurnedParalyzed"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetAsleepCureTarget"
      score -= 20 if target.status == :SLEEP &&   # Will cure status
                     target.statusCount > 1
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetPoisoned"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetParalyzedCureTarget"
      score -= 20 if target.status == :PARALYSIS   # Will cure status
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetStatusProblem"
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserHasNoItem"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetUnderwater"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetUnderground"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetInSky"
    #---------------------------------------------------------------------------
    when "DoublePowerInElectricTerrain"
      score += 40 if @battle.field.terrain == :Electric && target.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserLastMoveFailed"
    #---------------------------------------------------------------------------
    when "DoublePowerIfAllyFaintedLastTurn"
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserLostHPThisTurn"
      attspeed = pbRoughStat(user, :SPEED, skill)
      oppspeed = pbRoughStat(target, :SPEED, skill)
      score += 30 if oppspeed > attspeed
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetLostHPThisTurn"
      score += 20 if @battle.pbOpposingBattlerCount(user) > 1
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserStatsLoweredThisTurn"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetActed"
      attspeed = pbRoughStat(user, :SPEED, skill)
      oppspeed = pbRoughStat(target, :SPEED, skill)
      score += 30 if oppspeed > attspeed
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetNotActed"
    #---------------------------------------------------------------------------
    when "AlwaysCriticalHit"
    #---------------------------------------------------------------------------
    when "EnsureNextCriticalHit"
      if user.effects[PBEffects::LaserFocus] > 0
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "StartPreventCriticalHitsAgainstUserSide"
      score -= 90 if user.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    #---------------------------------------------------------------------------
    when "CannotMakeTargetFaint"
      if target.hp == 1
        score -= 90
      elsif target.hp <= target.totalhp / 8
        score -= 60
      elsif target.hp <= target.totalhp / 4
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "UserEnduresFaintingThisTurn"
      score -= 25 if user.hp > user.totalhp / 2
      if skill >= PBTrainerAI.mediumSkill
        score -= 90 if user.effects[PBEffects::ProtectRate] > 1
        score -= 90 if target.effects[PBEffects::HyperBeam] > 0
      else
        score -= user.effects[PBEffects::ProtectRate] * 40
      end
    #---------------------------------------------------------------------------
    when "StartWeakenElectricMoves"
      score -= 90 if user.effects[PBEffects::MudSport]
    #---------------------------------------------------------------------------
    when "StartWeakenFireMoves"
      score -= 90 if user.effects[PBEffects::WaterSport]
    #---------------------------------------------------------------------------
    when "StartWeakenPhysicalDamageAgainstUserSide"
      score -= 90 if user.pbOwnSide.effects[PBEffects::Reflect] > 0
    #---------------------------------------------------------------------------
    when "StartWeakenSpecialDamageAgainstUserSide"
      score -= 90 if user.pbOwnSide.effects[PBEffects::LightScreen] > 0
    #---------------------------------------------------------------------------
    when "StartWeakenDamageAgainstUserSideIfHail"
      if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 || user.effectiveWeather != :Hail
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "RemoveScreens"
      score += 20 if user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
      score += 20 if user.pbOpposingSide.effects[PBEffects::Reflect] > 0
      score += 20 if user.pbOpposingSide.effects[PBEffects::LightScreen] > 0
    #---------------------------------------------------------------------------
    when "ProtectUser"
      if user.effects[PBEffects::ProtectRate] > 1 ||
         target.effects[PBEffects::HyperBeam] > 0
        score -= 90
      else
        if skill >= PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate] * 40
        end
        score += 50 if user.turnCount == 0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
    #---------------------------------------------------------------------------
    when "ProtectUserBanefulBunker"
      if user.effects[PBEffects::ProtectRate] > 1 ||
         target.effects[PBEffects::HyperBeam] > 0
        score -= 90
      else
        if skill >= PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate] * 40
        end
        score += 50 if user.turnCount == 0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
        score += 20   # Because of possible poisoning
      end
    #---------------------------------------------------------------------------
    when "ProtectUserFromDamagingMovesKingsShield"
      if user.effects[PBEffects::ProtectRate] > 1 ||
         target.effects[PBEffects::HyperBeam] > 0
        score -= 90
      else
        if skill >= PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate] * 40
        end
        score += 50 if user.turnCount == 0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
    #---------------------------------------------------------------------------
    when "ProtectUserFromDamagingMovesObstruct"
      if user.effects[PBEffects::ProtectRate] > 1 ||
         target.effects[PBEffects::HyperBeam] > 0
        score -= 90
      else
        if skill >= PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate] * 40
        end
        score += 50 if user.turnCount == 0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
    #---------------------------------------------------------------------------
    when "ProtectUserFromTargetingMovesSpikyShield"
      if user.effects[PBEffects::ProtectRate] > 1 ||
         target.effects[PBEffects::HyperBeam] > 0
        score -= 90
      else
        if skill >= PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate] * 40
        end
        score += 50 if user.turnCount == 0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromDamagingMovesIfUserFirstTurn"
      if user.turnCount == 0
        score += 30
      else
        score -= 90   # Because it will fail here
        score = 0 if skill >= PBTrainerAI.bestSkill
      end
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromStatusMoves"
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromPriorityMoves"
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromMultiTargetDamagingMoves"
    #---------------------------------------------------------------------------
    when "RemoveProtections"
    #---------------------------------------------------------------------------
    when "RemoveProtectionsBypassSubstitute"
    #---------------------------------------------------------------------------
    when "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"
      if !user.isSpecies?(:HOOPA) || user.form != 1
        score -= 100
      elsif target.stages[:DEFENSE] > 0
        score += 20
      end
    #---------------------------------------------------------------------------
    when "RecoilQuarterOfDamageDealt"
      score -= 25
    #---------------------------------------------------------------------------
    when "RecoilThirdOfDamageDealt"
      score -= 30
    #---------------------------------------------------------------------------
    when "RecoilThirdOfDamageDealtParalyzeTarget"
      score -= 30
      if target.pbCanParalyze?(user, false)
        score += 30
        if skill >= PBTrainerAI.mediumSkill
          aspeed = pbRoughStat(user, :SPEED, skill)
          ospeed = pbRoughStat(target, :SPEED, skill)
          if aspeed < ospeed
            score += 30
          elsif aspeed > ospeed
            score -= 40
          end
        end
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET])
        end
      end
    #---------------------------------------------------------------------------
    when "RecoilThirdOfDamageDealtBurnTarget"
      score -= 30
      if target.pbCanBurn?(user, false)
        score += 30
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
        end
      end
    #---------------------------------------------------------------------------
    when "RecoilHalfOfDamageDealt"
      score -= 40
    #---------------------------------------------------------------------------
    when "EffectivenessIncludesFlyingType"
    #---------------------------------------------------------------------------
    when "CategoryDependsOnHigherDamagePoisonTarget"
      score += 5 if target.pbCanPoison?(user, false)
    #---------------------------------------------------------------------------
    when "CategoryDependsOnHigherDamageIgnoreTargetAbility"
    #---------------------------------------------------------------------------
    when "UseUserBaseDefenseInsteadOfUserBaseAttack"
    #---------------------------------------------------------------------------
    when "UseTargetAttackInsteadOfUserAttack"
    #---------------------------------------------------------------------------
    when "UseTargetDefenseInsteadOfTargetSpDef"
    #---------------------------------------------------------------------------
    when "EnsureNextMoveAlwaysHits"
      score -= 90 if target.effects[PBEffects::Substitute] > 0
      score -= 90 if user.effects[PBEffects::LockOn] > 0
    #---------------------------------------------------------------------------
    when "StartNegateTargetEvasionStatStageAndGhostImmunity"
      if target.effects[PBEffects::Foresight]
        score -= 90
      elsif target.pbHasType?(:GHOST)
        score += 70
      elsif target.stages[:EVASION] <= 0
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "StartNegateTargetEvasionStatStageAndDarkImmunity"
      if target.effects[PBEffects::MiracleEye]
        score -= 90
      elsif target.pbHasType?(:DARK)
        score += 70
      elsif target.stages[:EVASION] <= 0
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "IgnoreTargetDefSpDefEvaStatStages"
    #---------------------------------------------------------------------------
    when "TypeIsUserFirstType"
    #---------------------------------------------------------------------------
    when "TypeDependsOnUserIVs"
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnUserBerry"
      score -= 90 if !user.item || !user.item.is_berry? || !user.itemActive?
    #---------------------------------------------------------------------------
    when "TypeDependsOnUserPlate", "TypeDependsOnUserMemory", "TypeDependsOnUserDrive"
    #---------------------------------------------------------------------------
    when "TypeDependsOnUserMorpekoFormRaiseUserSpeed1"
      score += 20 if user.stages[:SPEED] <= 0
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnWeather"
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnTerrain"
      score += 40 if @battle.field.terrain != :None
    #---------------------------------------------------------------------------
    when "TargetMovesBecomeElectric"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      score -= 90 if aspeed > ospeed
    #---------------------------------------------------------------------------
    when "NormalMovesBecomeElectric"
    #---------------------------------------------------------------------------
    when "HitTwoTimes"
    #---------------------------------------------------------------------------
    when "HitTwoTimesPoisonTarget"
      if target.pbCanPoison?(user, false)
        score += 30
        if skill >= PBTrainerAI.mediumSkill
          score += 30 if target.hp <= target.totalhp / 4
          score += 50 if target.hp <= target.totalhp / 8
          score -= 40 if target.effects[PBEffects::Yawn] > 0
        end
        if skill >= PBTrainerAI.highSkill
          score += 10 if pbRoughStat(target, :DEFENSE, skill) > 100
          score += 10 if pbRoughStat(target, :SPECIAL_DEFENSE, skill) > 100
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :TOXICBOOST])
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "HitTwoTimesFlinchTarget"
      score += 30 if target.effects[PBEffects::Minimize]
    #---------------------------------------------------------------------------
    when "HitTwoTimesTargetThenTargetAlly"
    #---------------------------------------------------------------------------
    when "HitThreeTimesPowersUpWithEachHit"
    #---------------------------------------------------------------------------
    when "HitThreeTimesAlwaysCriticalHit"
      if skill >= PBTrainerAI.highSkill
        stat = (move.physicalMove?) ? :DEFENSE : :SPECIAL_DEFENSE
        score += 50 if targets.stages[stat] > 1
      end
    #---------------------------------------------------------------------------
    when "HitTwoToFiveTimes"
    #---------------------------------------------------------------------------
    when "HitTwoToFiveTimesOrThreeForAshGreninja"
    #---------------------------------------------------------------------------
    when "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      if aspeed > ospeed && aspeed * 2 / 3 < ospeed
        score -= 50
      elsif aspeed < ospeed && aspeed * 1.5 > ospeed
        score += 50
      end
      score += user.stages[:DEFENSE] * 30
    #---------------------------------------------------------------------------
    when "HitOncePerUserTeamMember"
    #---------------------------------------------------------------------------
    when "AttackAndSkipNextTurn"
    #---------------------------------------------------------------------------
    when "TwoTurnAttack", "TwoTurnAttackOneTurnInSun"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackParalyzeTarget"
      if target.pbCanParalyze?(user, false) &&
         !(skill >= PBTrainerAI.mediumSkill &&
         move.id == :THUNDERWAVE &&
         Effectiveness.ineffective?(pbCalcTypeMod(move.type, user, target)))
        score += 30
        if skill >= PBTrainerAI.mediumSkill
          aspeed = pbRoughStat(user, :SPEED, skill)
          ospeed = pbRoughStat(target, :SPEED, skill)
          if aspeed < ospeed
            score += 30
          elsif aspeed > ospeed
            score -= 40
          end
        end
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET])
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackBurnTarget"
      if target.pbCanBurn?(user, false)
        score += 30
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackFlinchTarget"
      score += 20 if user.effects[PBEffects::FocusEnergy] > 0
      if skill >= PBTrainerAI.highSkill
        score += 20 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute] == 0
      end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackRaiseUserSpAtkSpDefSpd2"
      if user.statStageAtMax?(:SPECIAL_ATTACK) &&
         user.statStageAtMax?(:SPECIAL_DEFENSE) &&
         user.statStageAtMax?(:SPEED)
        score -= 90
      else
        score -= user.stages[:SPECIAL_ATTACK] * 10   # Only *10 instead of *20
        score -= user.stages[:SPECIAL_DEFENSE] * 10   # because two-turn attack
        score -= user.stages[:SPEED] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasSpecialAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecialAttack = true
            break
          end
          if hasSpecialAttack
            score += 20
          elsif skill >= PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill >= PBTrainerAI.highSkill
          aspeed = pbRoughStat(user, :SPEED, skill)
          ospeed = pbRoughStat(target, :SPEED, skill)
          score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
        end
      end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackChargeRaiseUserDefense1"
      if move.statusMove?
        if user.statStageAtMax?(:DEFENSE)
          score -= 90
        else
          score -= user.stages[:DEFENSE] * 20
        end
      elsif user.stages[:DEFENSE] < 0
        score += 20
      end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackChargeRaiseUserSpAtk1"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      if (aspeed > ospeed && user.hp > user.totalhp / 3) || user.hp > user.totalhp / 2
        score += 60
      else
        score -= 90
      end
      score += user.stages[:SPECIAL_ATTACK] * 20
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableUnderground"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableUnderwater"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSky"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSkyParalyzeTarget"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSkyTargetCannotAct"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableRemoveProtections"
    #---------------------------------------------------------------------------
    when "MultiTurnAttackPreventSleeping"
    #---------------------------------------------------------------------------
    when "MultiTurnAttackConfuseUserAtEnd"
    #---------------------------------------------------------------------------
    when "MultiTurnAttackPowersUpEachTurn"
    #---------------------------------------------------------------------------
    when "MultiTurnAttackBideThenReturnDoubleDamage"
      if user.hp <= user.totalhp / 4
        score -= 90
      elsif user.hp <= user.totalhp / 2
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "HealUserFullyAndFallAsleep"
      if user.hp == user.totalhp || !user.pbCanSleep?(user, false, nil, true)
        score -= 90
      else
        score += 70
        score -= user.hp * 140 / user.totalhp
        score += 30 if user.status != :NONE
      end
    #---------------------------------------------------------------------------
    when "HealUserHalfOfTotalHP"
      if user.hp == user.totalhp || (skill >= PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp * 100 / user.totalhp
      end
    #---------------------------------------------------------------------------
    when "HealUserDependingOnWeather"
      if user.hp == user.totalhp || (skill >= PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        case user.effectiveWeather
        when :Sun, :HarshSun
          score += 30
        when :None
        else
          score -= 30
        end
        score += 50
        score -= user.hp * 100 / user.totalhp
      end
    #---------------------------------------------------------------------------
    when "HealUserDependingOnSandstorm"
      if user.hp == user.totalhp || (skill >= PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp * 100 / user.totalhp
        score += 30 if user.effectiveWeather == :Sandstorm
      end
    #---------------------------------------------------------------------------
    when "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn"
      if user.hp == user.totalhp || (skill >= PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp * 100 / user.totalhp
      end
    #---------------------------------------------------------------------------
    when "CureTargetStatusHealUserHalfOfTotalHP"
      if target.status == :NONE
        score -= 90
      elsif user.hp == user.totalhp && target.opposes?(user)
        score -= 90
      else
        score += (user.totalhp - user.hp) * 50 / user.totalhp
        score -= 30 if target.opposes?(user)
      end
    #---------------------------------------------------------------------------
    when "HealUserByTargetAttackLowerTargetAttack1"
      if target.statStageAtMin?(:ATTACK)
        score -= 90
      else
        if target.pbCanLowerStatStage?(:ATTACK, user)
          score += target.stages[:ATTACK] * 20
          if skill >= PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            target.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill >= PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
        score += (user.totalhp - user.hp) * 50 / user.totalhp
      end
    #---------------------------------------------------------------------------
    when "HealUserByHalfOfDamageDone"
      if skill >= PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 70
      elsif user.hp <= user.totalhp / 2
        score += 20
      end
    #---------------------------------------------------------------------------
    when "HealUserByHalfOfDamageDoneIfTargetAsleep"
      if !target.asleep?
        score -= 100
      elsif skill >= PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 70
      elsif user.hp <= user.totalhp / 2
        score += 20
      end
    #---------------------------------------------------------------------------
    when "HealUserByThreeQuartersOfDamageDone"
      if skill >= PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 80
      elsif user.hp <= user.totalhp / 2
        score += 40
      end
    #---------------------------------------------------------------------------
    when "HealUserAndAlliesQuarterOfTotalHP"
      ally_amt = 30
      @battle.allSameSideBattlers(user.index).each do |b|
        if b.hp == b.totalhp || (skill >= PBTrainerAI.mediumSkill && !b.canHeal?)
          score -= ally_amt / 2
        elsif b.hp < b.totalhp * 3 / 4
          score += ally_amt
        end
      end
    #---------------------------------------------------------------------------
    when "HealUserAndAlliesQuarterOfTotalHPCureStatus"
      ally_amt = 80 / @battle.pbSideSize(user.index)
      @battle.allSameSideBattlers(user.index).each do |b|
        if b.hp == b.totalhp || (skill >= PBTrainerAI.mediumSkill && !b.canHeal?)
          score -= ally_amt
        elsif b.hp < b.totalhp * 3 / 4
          score += ally_amt
        end
        score += ally_amt / 2 if b.pbHasAnyStatus?
      end
    #---------------------------------------------------------------------------
    when "HealTargetHalfOfTotalHP"
      if user.opposes?(target)
        score -= 100
      elsif target.hp < target.totalhp / 2 && target.effects[PBEffects::Substitute] == 0
        score += 20
      end
    #---------------------------------------------------------------------------
    when "HealTargetDependingOnGrassyTerrain"
      if user.hp == user.totalhp || (skill >= PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp * 100 / user.totalhp
        if skill >= PBTrainerAI.mediumSkill
          score += 30 if @battle.field.terrain == :Grassy
        end
      end
    #---------------------------------------------------------------------------
    when "HealUserPositionNextTurn"
      score -= 90 if @battle.positions[user.index].effects[PBEffects::Wish] > 0
    #---------------------------------------------------------------------------
    when "StartHealUserEachTurn"
      score -= 90 if user.effects[PBEffects::AquaRing]
    #---------------------------------------------------------------------------
    when "StartHealUserEachTurnTrapUserInBattle"
      score -= 90 if user.effects[PBEffects::Ingrain]
    #---------------------------------------------------------------------------
    when "StartDamageTargetEachTurnIfTargetAsleep"
      if target.effects[PBEffects::Nightmare] ||
         target.effects[PBEffects::Substitute] > 0
        score -= 90
      elsif !target.asleep?
        score -= 90
      else
        score -= 90 if target.statusCount <= 1
        score += 50 if target.statusCount > 3
      end
    #---------------------------------------------------------------------------
    when "StartLeechSeedTarget"
      if target.effects[PBEffects::LeechSeed] >= 0
        score -= 90
      elsif skill >= PBTrainerAI.mediumSkill && target.pbHasType?(:GRASS)
        score -= 90
      elsif user.turnCount == 0
        score += 60
      end
    #---------------------------------------------------------------------------
    when "UserLosesHalfOfTotalHP"
      score -= 100 if user.hp <= user.totalhp / 2
    #---------------------------------------------------------------------------
    when "UserLosesHalfOfTotalHPExplosive"
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
        score -= 100   # don't want to lose
      elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
        score += 80   # want to draw
      else
        score -= (user.totalhp - user.hp) * 75 / user.totalhp
      end
    #---------------------------------------------------------------------------
    when "UserFaintsExplosive"
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
        score -= 100   # don't want to lose
      elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
        score += 80   # want to draw
      else
        score -= user.hp * 100 / user.totalhp
      end
    #---------------------------------------------------------------------------
    when "UserFaintsPowersUpInMistyTerrainExplosive"
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif skill >= PBTrainerAI.mediumSkill && reserves == 0 && foes > 0
        score -= 100   # don't want to lose
      elsif skill >= PBTrainerAI.highSkill && reserves == 0 && foes == 0
        score += 40   # want to draw
        score += 40 if @battle.field.terrain == :Misty
      else
        score -= user.hp * 100 / user.totalhp
        score += 20 if @battle.field.terrain == :Misty
      end
    #---------------------------------------------------------------------------
    when "UserFaintsFixedDamageUserHP"
    #---------------------------------------------------------------------------
    when "UserFaintsLowerTargetAtkSpAtk2"
      if !target.pbCanLowerStatStage?(:ATTACK, user) &&
         !target.pbCanLowerStatStage?(:SPECIAL_ATTACK, user)
        score -= 100
      elsif @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
        score -= 100
      else
        score += target.stages[:ATTACK] * 10
        score += target.stages[:SPECIAL_ATTACK] * 10
        score -= user.hp * 100 / user.totalhp
      end
    #---------------------------------------------------------------------------
    when "UserFaintsHealAndCureReplacement", "UserFaintsHealAndCureReplacementRestorePP"
      score -= 70
    #---------------------------------------------------------------------------
    when "StartPerishCountsForAllBattlers"
      if @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
        score -= 90
      elsif target.effects[PBEffects::PerishSong] > 0
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "AttackerFaintsIfUserFaints"
      score += 50
      score -= user.hp * 100 / user.totalhp
      score += 30 if user.hp <= user.totalhp / 10
    #---------------------------------------------------------------------------
    when "SetAttackerMovePPTo0IfUserFaints"
      score += 50
      score -= user.hp * 100 / user.totalhp
      score += 30 if user.hp <= user.totalhp / 10
    #---------------------------------------------------------------------------
    when "UserTakesTargetItem"
      if skill >= PBTrainerAI.highSkill
        if !user.item && target.item
          score += 40
        else
          score -= 90
        end
      else
        score -= 80
      end
    #---------------------------------------------------------------------------
    when "TargetTakesUserItem"
      if !user.item || target.item
        score -= 90
      elsif user.hasActiveItem?([:FLAMEORB, :TOXICORB, :STICKYBARB, :IRONBALL,
                                 :CHOICEBAND, :CHOICESCARF, :CHOICESPECS])
        score += 50
      else
        score -= 80
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapItems"
      if !user.item && !target.item
        score -= 90
      elsif skill >= PBTrainerAI.highSkill && target.hasActiveAbility?(:STICKYHOLD)
        score -= 90
      elsif user.hasActiveItem?([:FLAMEORB, :TOXICORB, :STICKYBARB, :IRONBALL,
                                 :CHOICEBAND, :CHOICESCARF, :CHOICESPECS])
        score += 50
      elsif !user.item && target.item
        score -= 30 if user.lastMoveUsed &&
                       GameData::Move.get(user.lastMoveUsed).function_code == "UserTargetSwapItems"
      end
    #---------------------------------------------------------------------------
    when "RestoreUserConsumedItem"
      if !user.recycleItem || user.item
        score -= 80
      elsif user.recycleItem
        score += 30
      end
    #---------------------------------------------------------------------------
    when "RemoveTargetItem"
      if skill >= PBTrainerAI.highSkill
        score += 20 if target.item
      end
    #---------------------------------------------------------------------------
    when "DestroyTargetBerryOrGem"
      if target.effects[PBEffects::Substitute] == 0
        if skill >= PBTrainerAI.highSkill && target.item && target.item.is_berry?
          score += 30
        end
      end
    #---------------------------------------------------------------------------
    when "CorrodeTargetItem"
      if @battle.corrosiveGas[target.index % 2][target.pokemonIndex]
        score -= 100
      elsif !target.item || !target.itemActive? || target.unlosableItem?(target.item) ||
            target.hasActiveAbility?(:STICKYHOLD)
        score -= 90
      elsif target.effects[PBEffects::Substitute] > 0
        score -= 90
      else
        score += 50
      end
    #---------------------------------------------------------------------------
    when "StartTargetCannotUseItem"
      score -= 90 if target.effects[PBEffects::Embargo] > 0
    #---------------------------------------------------------------------------
    when "StartNegateHeldItems"
      if @battle.field.effects[PBEffects::MagicRoom] > 0
        score -= 90
      elsif !user.item && target.item
        score += 30
      end
    #---------------------------------------------------------------------------
    when "UserConsumeBerryRaiseDefense2"
      if !user.item || !user.item.is_berry? || !user.itemActive?
        score -= 100
      else
        if skill >= PBTrainerAI.highSkill
          useful_berries = [
            :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
            :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
            :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
            :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY, :RAWSTBERRY,
            :SALACBERRY, :STARFBERRY, :WIKIBERRY
          ]
          score += 30 if useful_berries.include?(user.item_id)
        end
        if skill >= PBTrainerAI.mediumSkill
          score += 20 if user.canHeal? && user.hp < user.totalhp / 3 && user.hasActiveAbility?(:CHEEKPOUCH)
          score += 20 if user.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                         user.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
          score += 20 if !user.canConsumeBerry?
        end
        score -= user.stages[:DEFENSE] * 20
      end
    #---------------------------------------------------------------------------
    when "AllBattlersConsumeBerry"
      useful_berries = [
        :ORANBERRY, :SITRUSBERRY, :AGUAVBERRY, :APICOTBERRY, :CHERIBERRY,
        :CHESTOBERRY, :FIGYBERRY, :GANLONBERRY, :IAPAPABERRY, :KEEBERRY,
        :LANSATBERRY, :LEPPABERRY, :LIECHIBERRY, :LUMBERRY, :MAGOBERRY,
        :MARANGABERRY, :PECHABERRY, :PERSIMBERRY, :PETAYABERRY,
        :RAWSTBERRY, :SALACBERRY, :STARFBERRY, :WIKIBERRY
      ]
      @battle.allSameSideBattlers(user.index).each do |b|
        if !b.item || !b.item.is_berry? || !b.itemActive?
          score -= 100 / @battle.pbSideSize(user.index)
        else
          if skill >= PBTrainerAI.highSkill
            amt = 30 / @battle.pbSideSize(user.index)
            score += amt if useful_berries.include?(b.item_id)
          end
          if skill >= PBTrainerAI.mediumSkill
            amt = 20 / @battle.pbSideSize(user.index)
            score += amt if b.canHeal? && b.hp < b.totalhp / 3 && b.hasActiveAbility?(:CHEEKPOUCH)
            score += amt if b.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                            b.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
            score += amt if !b.canConsumeBerry?
          end
        end
      end
      if skill >= PBTrainerAI.highSkill
        @battle.allOtherSideBattlers(user.index).each do |b|
          amt = 10 / @battle.pbSideSize(target.index)
          score -= amt if b.hasActiveItem?(useful_berries)
          score -= amt if b.canHeal? && b.hp < b.totalhp / 3 && b.hasActiveAbility?(:CHEEKPOUCH)
          score -= amt if b.hasActiveAbility?([:HARVEST, :RIPEN]) ||
                          b.pbHasMoveFunction?("RestoreUserConsumedItem")   # Recycle
          score -= amt if !b.canConsumeBerry?
        end
      end
    #---------------------------------------------------------------------------
    when "UserConsumeTargetBerry"
      if target.effects[PBEffects::Substitute] == 0
        if skill >= PBTrainerAI.highSkill && target.item && target.item.is_berry?
          score += 30
        end
      end
    #---------------------------------------------------------------------------
    when "ThrowUserItemAtTarget"
      if !user.item || !user.itemActive? ||
         user.unlosableItem?(user.item) || user.item.is_poke_ball?
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "RedirectAllMovesToUser"
      score -= 90 if user.allAllies.length == 0
    #---------------------------------------------------------------------------
    when "RedirectAllMovesToTarget"
      score -= 90 if user.allAllies.length == 0
    #---------------------------------------------------------------------------
    when "CannotBeRedirected"
      redirection = false
      user.allOpposing.each do |b|
        next if b.index == target.index
        if b.effects[PBEffects::RagePowder] ||
           b.effects[PBEffects::Spotlight] > 0 ||
           b.effects[PBEffects::FollowMe] > 0 ||
           (b.hasActiveAbility?(:LIGHTNINGROD) && move.pbCalcType == :ELECTRIC) ||
           (b.hasActiveAbility?(:STORMDRAIN) && move.pbCalcType == :WATER)
          redirection = true
          break
        end
      end
      score += 50 if redirection && skill >= PBTrainerAI.mediumSkill
    #---------------------------------------------------------------------------
    when "RandomlyDamageOrHealTarget"
    #---------------------------------------------------------------------------
    when "HealAllyOrDamageFoe"
      if !target.opposes?(user)
        if target.hp == target.totalhp || (skill >= PBTrainerAI.mediumSkill && !target.canHeal?)
          score -= 90
        else
          score += 50
          score -= target.hp * 100 / target.totalhp
        end
      end
    #---------------------------------------------------------------------------
    when "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1"
      if user.pbHasType?(:GHOST)
        if target.effects[PBEffects::Curse]
          score -= 90
        elsif user.hp <= user.totalhp / 2
          if @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
            score -= 90
          else
            score -= 50
            score -= 30 if @battle.switchStyle
          end
        end
      else
        avg  = user.stages[:SPEED] * 10
        avg -= user.stages[:ATTACK] * 10
        avg -= user.stages[:DEFENSE] * 10
        score += avg / 3
      end
    #---------------------------------------------------------------------------
    when "EffectDependsOnEnvironment"
    #---------------------------------------------------------------------------
    when "HitsAllFoesAndPowersUpInPsychicTerrain"
      score += 40 if @battle.field.terrain == :Psychic && user.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "TargetNextFireMoveDamagesTarget"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      if aspeed > ospeed
        score -= 90
      elsif target.pbHasMoveType?(:FIRE)
        score += 30
      end
    #---------------------------------------------------------------------------
    when "DoublePowerAfterFusionFlare"
    #---------------------------------------------------------------------------
    when "DoublePowerAfterFusionBolt"
    #---------------------------------------------------------------------------
    when "PowerUpAllyMove"
      hasAlly = !user.allAllies.empty?
      score += 30 if hasAlly
      score -= 90 if !hasAlly
    #---------------------------------------------------------------------------
    when "CounterPhysicalDamage"
      if target.effects[PBEffects::HyperBeam] > 0
        score -= 90
      else
        attack = pbRoughStat(user, :ATTACK, skill)
        spatk  = pbRoughStat(user, :SPECIAL_ATTACK, skill)
        if attack * 1.5 < spatk
          score -= 60
        elsif skill >= PBTrainerAI.mediumSkill && target.lastMoveUsed
          moveData = GameData::Move.get(target.lastMoveUsed)
          score += 60 if moveData.physical?
        end
      end
    #---------------------------------------------------------------------------
    when "CounterSpecialDamage"
      if target.effects[PBEffects::HyperBeam] > 0
        score -= 90
      else
        attack = pbRoughStat(user, :ATTACK, skill)
        spatk  = pbRoughStat(user, :SPECIAL_ATTACK, skill)
        if attack > spatk * 1.5
          score -= 60
        elsif skill >= PBTrainerAI.mediumSkill && target.lastMoveUsed
          moveData = GameData::Move.get(target.lastMoveUsed)
          score += 60 if moveData.special?
        end
      end
    #---------------------------------------------------------------------------
    when "CounterDamagePlusHalf"
      score -= 90 if target.effects[PBEffects::HyperBeam] > 0
    #---------------------------------------------------------------------------
    when "UserAddStockpileRaiseDefSpDef1"
      avg = 0
      avg -= user.stages[:DEFENSE] * 10
      avg -= user.stages[:SPECIAL_DEFENSE] * 10
      score += avg / 2
      if user.effects[PBEffects::Stockpile] >= 3
        score -= 80
      elsif user.pbHasMoveFunction?("PowerDependsOnUserStockpile",
                                    "HealUserDependingOnUserStockpile")   # Spit Up, Swallow
        score += 20   # More preferable if user also has Spit Up/Swallow
      end
    #---------------------------------------------------------------------------
    when "PowerDependsOnUserStockpile"
      score -= 100 if user.effects[PBEffects::Stockpile] == 0
    #---------------------------------------------------------------------------
    when "HealUserDependingOnUserStockpile"
      if user.effects[PBEffects::Stockpile] == 0
        score -= 90
      elsif user.hp == user.totalhp
        score -= 90
      else
        mult = [0, 25, 50, 100][user.effects[PBEffects::Stockpile]]
        score += mult
        score -= user.hp * mult * 2 / user.totalhp
      end
    #---------------------------------------------------------------------------
    when "GrassPledge"
    #---------------------------------------------------------------------------
    when "FirePledge"
    #---------------------------------------------------------------------------
    when "WaterPledge"
    #---------------------------------------------------------------------------
    when "UseLastMoveUsed"
    #---------------------------------------------------------------------------
    when "UseLastMoveUsedByTarget"
      score -= 40
      if skill >= PBTrainerAI.highSkill
        score -= 100 if !target.lastRegularMoveUsed ||
                        GameData::Move.get(target.lastRegularMoveUsed).flags.none? { |f| f[/^CanMirrorMove$/i] }
      end
    #---------------------------------------------------------------------------
    when "UseMoveTargetIsAboutToUse"
    #---------------------------------------------------------------------------
    when "UseMoveDependingOnEnvironment"
    #---------------------------------------------------------------------------
    when "UseRandomMove"
    #---------------------------------------------------------------------------
    when "UseRandomMoveFromUserParty"
    #---------------------------------------------------------------------------
    when "UseRandomUserMoveIfAsleep"
      if user.asleep?
        score += 100   # Because it can only be used while asleep
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "BounceBackProblemCausingStatusMoves"
    #---------------------------------------------------------------------------
    when "StealAndUseBeneficialStatusMove"
    #---------------------------------------------------------------------------
    when "ReplaceMoveThisBattleWithTargetLastMoveUsed"
      moveBlacklist = [
        "Struggle",   # Struggle
        "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
        "ReplaceMoveWithTargetLastMoveUsed",   # Sketch
        "UseRandomMove"   # Metronome
      ]
      if user.effects[PBEffects::Transform] || !target.lastRegularMoveUsed
        score -= 90
      else
        lastMoveData = GameData::Move.get(target.lastRegularMoveUsed)
        if moveBlacklist.include?(lastMoveData.function_code) ||
           lastMoveData.type == :SHADOW
          score -= 90
        end
        user.eachMove do |m|
          next if m != target.lastRegularMoveUsed
          score -= 90
          break
        end
      end
    #---------------------------------------------------------------------------
    when "ReplaceMoveWithTargetLastMoveUsed"
      moveBlacklist = [
        "Struggle",   # Struggle
        "ReplaceMoveWithTargetLastMoveUsed"   # Sketch
      ]
      if user.effects[PBEffects::Transform] || !target.lastRegularMoveUsed
        score -= 90
      else
        lastMoveData = GameData::Move.get(target.lastRegularMoveUsed)
        if moveBlacklist.include?(lastMoveData.function_code) ||
           lastMoveData.type == :SHADOW
          score -= 90
        end
        user.eachMove do |m|
          next if m != target.lastRegularMoveUsed
          score -= 90   # User already knows the move that will be Sketched
          break
        end
      end
    #---------------------------------------------------------------------------
    when "FleeFromBattle"
      score -= 100 if @battle.trainerBattle?
    #---------------------------------------------------------------------------
    when "SwitchOutUserStatusMove"
      if !@battle.pbCanChooseNonActive?(user.index) ||
         @battle.pbTeamAbleNonActiveCount(user.index) > 1   # Don't switch in ace
        score -= 100
      else
        score += 40 if user.effects[PBEffects::Confusion] > 0
        total = 0
        GameData::Stat.each_battle { |s| total += user.stages[s.id] }
        if total <= 0 || user.turnCount == 0
          score += 60
        else
          score -= total * 10
          # special case: user has no damaging moves
          hasDamagingMove = false
          user.eachMove do |m|
            next if !m.damagingMove?
            hasDamagingMove = true
            break
          end
          score += 75 if !hasDamagingMove
        end
      end
    #---------------------------------------------------------------------------
    when "SwitchOutUserDamagingMove"
      if !@battle.pbCanChooseNonActive?(user.index) ||
         @battle.pbTeamAbleNonActiveCount(user.index) > 1   # Don't switch in ace
        score -= 100
      end
    #---------------------------------------------------------------------------
    when "LowerTargetAtkSpAtk1SwitchOutUser"
      avg  = target.stages[:ATTACK] * 10
      avg += target.stages[:SPECIAL_ATTACK] * 10
      score += avg / 2
    #---------------------------------------------------------------------------
    when "SwitchOutUserPassOnEffects"
      if @battle.pbCanChooseNonActive?(user.index)
        score -= 40 if user.effects[PBEffects::Confusion] > 0
        total = 0
        GameData::Stat.each_battle { |s| total += user.stages[s.id] }
        if total <= 0 || user.turnCount == 0
          score -= 60
        else
          score += total * 10
          # special case: user has no damaging moves
          hasDamagingMove = false
          user.eachMove do |m|
            next if !m.damagingMove?
            hasDamagingMove = true
            break
          end
          score += 75 if !hasDamagingMove
        end
      else
        score -= 100
      end
    #---------------------------------------------------------------------------
    when "SwitchOutTargetStatusMove"
      if target.effects[PBEffects::Ingrain] ||
         (skill >= PBTrainerAI.highSkill && target.hasActiveAbility?(:SUCTIONCUPS))
        score -= 90
      else
        ch = 0
        @battle.pbParty(target.index).each_with_index do |pkmn, i|
          ch += 1 if @battle.pbCanSwitchLax?(target.index, i)
        end
        score -= 90 if ch == 0
      end
      if score > 20
        score += 50 if target.pbOwnSide.effects[PBEffects::Spikes] > 0
        score += 50 if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
        score += 50 if target.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "SwitchOutTargetDamagingMove"
      if !target.effects[PBEffects::Ingrain] &&
         !(skill >= PBTrainerAI.highSkill && target.hasActiveAbility?(:SUCTIONCUPS))
        score += 40 if target.pbOwnSide.effects[PBEffects::Spikes] > 0
        score += 40 if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
        score += 40 if target.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "BindTarget"
      score += 40 if target.effects[PBEffects::Trapping] == 0
    #---------------------------------------------------------------------------
    when "BindTargetDoublePowerIfTargetUnderwater"
      score += 40 if target.effects[PBEffects::Trapping] == 0
    #---------------------------------------------------------------------------
    when "TrapTargetInBattle"
      score -= 90 if target.effects[PBEffects::MeanLook] >= 0
    #---------------------------------------------------------------------------
    when "TrapTargetInBattleLowerTargetDefSpDef1EachTurn"
      if target.effects[PBEffects::Octolock] >= 0
        score -= 100
      else
        score += 30 if !target.trappedInBattle?
        score -= 100 if !target.pbCanLowerStatStage?(:DEFENSE, user, move) &&
                        !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user, move)
      end
    #---------------------------------------------------------------------------
    when "TrapUserAndTargetInBattle"
      if target.effects[PBEffects::JawLock] < 0
        score += 40 if !user.trappedInBattle? && !target.trappedInBattle?
      end
    #---------------------------------------------------------------------------
    when "TrapAllBattlersInBattleForOneTurn"
    #---------------------------------------------------------------------------
    when "PursueSwitchingFoe"
    #---------------------------------------------------------------------------
    when "UsedAfterUserTakesPhysicalDamage"
      if skill >= PBTrainerAI.mediumSkill
        hasPhysicalAttack = false
        target.eachMove do |m|
          next if !m.physicalMove?(m.type)
          hasPhysicalAttack = true
          break
        end
        score -= 80 if !hasPhysicalAttack
      end
    #---------------------------------------------------------------------------
    when "UsedAfterAllyRoundWithDoublePower"
      if skill >= PBTrainerAI.mediumSkill
        user.allAllies.each do |b|
          next if !b.pbHasMove?(move.id)
          score += 20
        end
      end
    #---------------------------------------------------------------------------
    when "TargetActsNext"
    #---------------------------------------------------------------------------
    when "TargetActsLast"
    #---------------------------------------------------------------------------
    when "TargetUsesItsLastUsedMoveAgain"
      if skill >= PBTrainerAI.mediumSkill
        if !target.lastRegularMoveUsed ||
           !target.pbHasMove?(target.lastRegularMoveUsed) ||
           target.usingMultiTurnAttack?
          score -= 90
        else
          # Without lots of code here to determine good/bad moves and relative
          # speeds, using this move is likely to just be a waste of a turn
          score -= 50
        end
      end
    #---------------------------------------------------------------------------
    when "StartSlowerBattlersActFirst"
    #---------------------------------------------------------------------------
    when "HigherPriorityInGrassyTerrain"
      if skill >= PBTrainerAI.mediumSkill && @battle.field.terrain == :Grassy
        aspeed = pbRoughStat(user, :SPEED, skill)
        ospeed = pbRoughStat(target, :SPEED, skill)
        score += 40 if aspeed < ospeed
      end
    #---------------------------------------------------------------------------
    when "LowerPPOfTargetLastMoveBy3"
      last_move = target.pbGetMoveWithID(target.lastRegularMoveUsed)
      if last_move && last_move.total_pp > 0 && last_move.pp <= 3
        score += 50
      end
    #---------------------------------------------------------------------------
    when "LowerPPOfTargetLastMoveBy4"
      score -= 40
    #---------------------------------------------------------------------------
    when "DisableTargetLastMoveUsed"
      score -= 90 if target.effects[PBEffects::Disable] > 0
    #---------------------------------------------------------------------------
    when "DisableTargetUsingSameMoveConsecutively"
      score -= 90 if target.effects[PBEffects::Torment]
    #---------------------------------------------------------------------------
    when "DisableTargetUsingDifferentMove"
      aspeed = pbRoughStat(user, :SPEED, skill)
      ospeed = pbRoughStat(target, :SPEED, skill)
      if target.effects[PBEffects::Encore] > 0
        score -= 90
      elsif aspeed > ospeed
        if target.lastRegularMoveUsed
          moveData = GameData::Move.get(target.lastRegularMoveUsed)
          if moveData.category == 2 &&   # Status move
             [:User, :BothSides].include?(moveData.target)
            score += 60
          elsif moveData.category != 2 &&   # Damaging move
                moveData.target == :NearOther &&
                Effectiveness.ineffective?(pbCalcTypeMod(moveData.type, target, user))
            score += 60
          end
        else
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "DisableTargetStatusMoves"
      score -= 90 if target.effects[PBEffects::Taunt] > 0
    #---------------------------------------------------------------------------
    when "DisableTargetHealingMoves"
      score -= 90 if target.effects[PBEffects::HealBlock] > 0
    #---------------------------------------------------------------------------
    when "DisableTargetSoundMoves"
      if target.effects[PBEffects::ThroatChop] == 0 && skill >= PBTrainerAI.highSkill
        hasSoundMove = false
        user.eachMove do |m|
          next if !m.soundMove?
          hasSoundMove = true
          break
        end
        score += 40 if hasSoundMove
      end
    #---------------------------------------------------------------------------
    when "DisableTargetMovesKnownByUser"
      score -= 90 if user.effects[PBEffects::Imprison]
    #---------------------------------------------------------------------------
    when "AllBattlersLoseHalfHPUserSkipsNextTurn"
      score += 20   # Shadow moves are more preferable
      score += 20 if target.hp >= target.totalhp / 2
      score -= 20 if user.hp < user.hp / 2
    #---------------------------------------------------------------------------
    when "UserLosesHalfHP"
      score += 20   # Shadow moves are more preferable
      score -= 40
    #---------------------------------------------------------------------------
    when "StartShadowSkyWeather"
      score += 20   # Shadow moves are more preferable
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :ShadowSky
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "RemoveAllScreens"
      score += 20   # Shadow moves are more preferable
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 ||
         target.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
         target.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
         target.pbOwnSide.effects[PBEffects::Safeguard] > 0
        score += 30
        score -= 90 if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 ||
                       user.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
                       user.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
                       user.pbOwnSide.effects[PBEffects::Safeguard] > 0
      else
        score -= 110
      end
    #---------------------------------------------------------------------------
    else
      return aiEffectScorePart2_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    end
    return score
  end
end
