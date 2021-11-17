class Battle::AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctionCode(score,move,user,target,skill=100)
    case move.function
    #---------------------------------------------------------------------------
    when "None"   # No extra effect
    #---------------------------------------------------------------------------
    when "DoesNothingUnusableInGravity"
      score -= 95
      score = 0 if skill>=PBTrainerAI.highSkill
    #---------------------------------------------------------------------------
    when "Struggle"   # Struggle
    #---------------------------------------------------------------------------
    when "SleepTarget", "SleepTargetChangeUserMeloettaForm"
      if target.pbCanSleep?(user,false)
        score += 30
        if skill>=PBTrainerAI.mediumSkill
          score -= 30 if target.effects[PBEffects::Yawn]>0
        end
        if skill>=PBTrainerAI.highSkill
          score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
        end
        if skill>=PBTrainerAI.bestSkill
          if target.pbHasMoveFunction?("FlinchTargetFailsIfUserNotAsleep",
                                       "UseRandomUserMoveIfAsleep")   # Snore, Sleep Talk
            score -= 50
          end
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
    #---------------------------------------------------------------------------
    when "SleepTargetNextTurn"
      if target.effects[PBEffects::Yawn]>0 || !target.pbCanSleep?(user,false)
        score -= 90 if skill>=PBTrainerAI.mediumSkill
      else
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
        end
        if skill>=PBTrainerAI.bestSkill
          if target.pbHasMoveFunction?("FlinchTargetFailsIfUserNotAsleep",
                                       "UseRandomUserMoveIfAsleep")   # Snore, Sleep Talk
            score -= 50
          end
        end
      end
    #---------------------------------------------------------------------------
    when "PoisonTarget", "BadPoisonTarget", "HitTwoTimesPoisonTarget"
      if target.pbCanPoison?(user,false)
        score += 30
        if skill>=PBTrainerAI.mediumSkill
          score += 30 if target.hp<=target.totalhp/4
          score += 50 if target.hp<=target.totalhp/8
          score -= 40 if target.effects[PBEffects::Yawn]>0
        end
        if skill>=PBTrainerAI.highSkill
          score += 10 if pbRoughStat(target,:DEFENSE,skill)>100
          score += 10 if pbRoughStat(target,:SPECIAL_DEFENSE,skill)>100
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:TOXICBOOST])
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
    #---------------------------------------------------------------------------
    when "ParalyzeTarget", "ParalyzeTargetIfNotTypeImmune",
         "ParalyzeTargetTrampleMinimize", "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky",
         "ParalyzeFlinchTarget", "TwoTurnAttackParalyzeTarget"
      if target.pbCanParalyze?(user,false) &&
         !(skill>=PBTrainerAI.mediumSkill &&
         move.id == :THUNDERWAVE &&
         Effectiveness.ineffective?(pbCalcTypeMod(move.type,user,target)))
        score += 30
        if skill>=PBTrainerAI.mediumSkill
           aspeed = pbRoughStat(user,:SPEED,skill)
           ospeed = pbRoughStat(target,:SPEED,skill)
          if aspeed<ospeed
            score += 30
          elsif aspeed>ospeed
            score -= 40
          end
        end
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET])
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
    #---------------------------------------------------------------------------
    when "BurnTarget", "BurnFlinchTarget", "TwoTurnAttackBurnTarget"
      if target.pbCanBurn?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
    #---------------------------------------------------------------------------
    when "FreezeTarget", "FreezeTargetAlwaysHitsInHail", "FreezeFlinchTarget"
      if target.pbCanFreeze?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
    #---------------------------------------------------------------------------
    when "FlinchTarget"
      score += 30
      if skill>=PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute]==0
      end
    #---------------------------------------------------------------------------
    when "FlinchTargetTrampleMinimize"
      if skill>=PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute]==0
      end
      score += 30 if target.effects[PBEffects::Minimize]
    #---------------------------------------------------------------------------
    when "FlinchTargetFailsIfUserNotAsleep"
      if user.asleep?
        score += 100   # Because it can only be used while asleep
        if skill>=PBTrainerAI.highSkill
          score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                         target.effects[PBEffects::Substitute]==0
        end
      else
        score -= 90   # Because it will fail here
        score = 0 if skill>=PBTrainerAI.bestSkill
      end
    #---------------------------------------------------------------------------
    when "FlinchTargetFailsIfNotUserFirstTurn"
      if user.turnCount==0
        if skill>=PBTrainerAI.highSkill
          score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                         target.effects[PBEffects::Substitute]==0
        end
      else
        score -= 90   # Because it will fail here
        score = 0 if skill>=PBTrainerAI.bestSkill
      end
    #---------------------------------------------------------------------------
    when "ConfuseTarget", "ConfuseTargetAlwaysHitsInRainHitsTargetInSky"
      if target.pbCanConfuse?(user,false)
        score += 30
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
    #---------------------------------------------------------------------------
    when "AttractTarget"
      canattract = true
      agender = user.gender
      ogender = target.gender
      if agender==2 || ogender==2 || agender==ogender
        score -= 90
        canattract = false
      elsif target.effects[PBEffects::Attract]>=0
        score -= 80
        canattract = false
      elsif skill>=PBTrainerAI.bestSkill && target.hasActiveAbility?(:OBLIVIOUS)
        score -= 80
        canattract = false
      end
      if skill>=PBTrainerAI.highSkill
        if canattract && target.hasActiveItem?(:DESTINYKNOT) &&
           user.pbCanAttract?(target,false)
          score -= 30
        end
      end
    #---------------------------------------------------------------------------
    when "ParalyzeBurnOrFreezeTarget"
      score += 30 if target.status == :NONE
    #---------------------------------------------------------------------------
    when "CureUserBurnPoisonParalysis"
      case user.status
      when :POISON
        score += 40
        if skill>=PBTrainerAI.mediumSkill
          if user.hp<user.totalhp/8
            score += 60
          elsif skill>=PBTrainerAI.highSkill &&
             user.hp<(user.effects[PBEffects::Toxic]+1)*user.totalhp/16
            score += 60
          end
        end
      when :BURN, :PARALYSIS
        score += 40
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "CureUserPartyStatus"
      statuses = 0
      @battle.pbParty(user.index).each do |pkmn|
        statuses += 1 if pkmn && pkmn.status != :NONE
      end
      if statuses==0
        score -= 80
      else
        score += 20*statuses
      end
    #---------------------------------------------------------------------------
    when "StartUserSideImmunityToInflictedStatus"
      if user.pbOwnSide.effects[PBEffects::Safeguard]>0
        score -= 80
      elsif user.status != :NONE
        score -= 40
      else
        score += 30
      end
    #---------------------------------------------------------------------------
    when "GiveUserStatusToTarget"
      if user.status == :NONE
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAttack1"
      if move.statusMove?
        if user.statStageAtMax?(:ATTACK)
          score -= 90
        else
          score -= user.stages[:ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            user.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 20 if user.stages[:ATTACK]<0
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserDefense1", "RaiseUserDefense1CurlUpUser", "TwoTurnAttackChargeRaiseUserDefense1"
      if move.statusMove?
        if user.statStageAtMax?(:DEFENSE)
          score -= 90
        else
          score -= user.stages[:DEFENSE]*20
        end
      else
        score += 20 if user.stages[:DEFENSE]<0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpeed1"
      if move.statusMove?
        if user.statStageAtMax?(:SPEED)
          score -= 90
        else
          score -= user.stages[:SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,:SPEED,skill)
            ospeed = pbRoughStat(target,:SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 20 if user.stages[:SPEED]<0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtk1"
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_ATTACK)
          score -= 90
        else
          score -= user.stages[:SPECIAL_ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            user.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 20 if user.stages[:SPECIAL_ATTACK]<0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 20 if hasSpecicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpDef1PowerUpElectricMove"
      foundMove = false
      user.eachMove do |m|
        next if m.type != :ELECTRIC || !m.damagingMove?
        foundMove = true
        break
      end
      score += 20 if foundMove
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_DEFENSE)
          score -= 90
        else
          score -= user.stages[:SPECIAL_DEFENSE]*20
        end
      else
        score += 20 if user.stages[:SPECIAL_DEFENSE]<0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserEvasion1"
      if move.statusMove?
        if user.statStageAtMax?(:EVASION)
          score -= 90
        else
          score -= user.stages[:EVASION]*10
        end
      else
        score += 20 if user.stages[:EVASION]<0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserCriticalHitRate2"
      if move.statusMove?
        if user.effects[PBEffects::FocusEnergy]>=2
          score -= 80
        else
          score += 30
        end
      else
        score += 30 if user.effects[PBEffects::FocusEnergy]<2
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtkDef1"
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:DEFENSE)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:DEFENSE]*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtkDefAcc1"
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:DEFENSE) &&
         user.statStageAtMax?(:ACCURACY)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:DEFENSE]*10
        score -= user.stages[:ACCURACY]*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtkSpd1"
      score += 40 if user.turnCount==0   # Dragon Dance tends to be popular
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:SPEED)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:SPEED]*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill>=PBTrainerAI.highSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          score += 20 if aspeed<ospeed && aspeed*2>ospeed
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtkSpAtk1", "RaiseUserAtkSpAtk1Or2InSun"
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:SPECIAL_ATTACK)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:SPECIAL_ATTACK]*10
        if skill>=PBTrainerAI.mediumSkill
          hasDamagingAttack = false
          user.eachMove do |m|
            next if !m.damagingMove?
            hasDamagingAttack = true
            break
          end
          if hasDamagingAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
        if move.function=="RaiseUserAtkSpAtk1Or2InSun"   # Growth
          score += 20 if [:Sun, :HarshSun].include?(user.effectiveWeather)
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtkAcc1"
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:ACCURACY)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:ACCURACY]*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserDefSpDef1"
      if user.statStageAtMax?(:DEFENSE) &&
         user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= user.stages[:DEFENSE]*10
        score -= user.stages[:SPECIAL_DEFENSE]*10
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtkSpDefSpd1"
      if user.statStageAtMax?(:SPEED) &&
         user.statStageAtMax?(:SPECIAL_ATTACK) &&
         user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= user.stages[:SPECIAL_ATTACK]*10
        score -= user.stages[:SPECIAL_DEFENSE]*10
        score -= user.stages[:SPEED]*10
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          if hasSpecicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill>=PBTrainerAI.highSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          if aspeed<ospeed && aspeed*2>ospeed
            score += 20
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtkSpDef1"
      if user.statStageAtMax?(:SPECIAL_ATTACK) &&
         user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score += 40 if user.turnCount==0   # Calm Mind tends to be popular
        score -= user.stages[:SPECIAL_ATTACK]*10
        score -= user.stages[:SPECIAL_DEFENSE]*10
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          if hasSpecicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserMainStats1"
      GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] < 0 }
      if skill>=PBTrainerAI.mediumSkill
        hasDamagingAttack = false
        user.eachMove do |m|
          next if !m.damagingMove?
          hasDamagingAttack = true
          break
        end
        score += 20 if hasDamagingAttack
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAttack2", "RaiseUserAttack3"
      if move.statusMove?
        if user.statStageAtMax?(:ATTACK)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            user.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:ATTACK]<0
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserDefense2"
      if move.statusMove?
        if user.statStageAtMax?(:DEFENSE)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:DEFENSE]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:DEFENSE]<0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpeed2", "RaiseUserSpeed2LowerUserWeight", "RaiseUserSpeed3"
      if move.statusMove?
        if user.statStageAtMax?(:SPEED)
          score -= 90
        else
          score += 20 if user.turnCount==0
          score -= user.stages[:SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,:SPEED,skill)
            ospeed = pbRoughStat(target,:SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:SPEED]<0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtk2"
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_ATTACK)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:SPECIAL_ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            user.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:SPECIAL_ATTACK]<0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 20 if hasSpecicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpDef1", "RaiseUserSpDef2", "RaiseUserSpDef3"
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_DEFENSE)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:SPECIAL_DEFENSE]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:SPECIAL_DEFENSE]<0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAccuracy1", "RaiseUserAccuracy2", "RaiseUserAccuracy3"
      if move.statusMove?
        if user.statStageAtMax?(:ACCURACY)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:ACCURACY]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:ACCURACY]<0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserEvasion2", "RaiseUserEvasion2MinimizeUser", "RaiseUserEvasion3"
      if move.statusMove?
        if user.statStageAtMax?(:EVASION)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:EVASION]*10
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[:EVASION]<0
      end
    #---------------------------------------------------------------------------
    when "LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2"
      score -= user.stages[:ATTACK]*20
      score -= user.stages[:SPEED]*20
      score -= user.stages[:SPECIAL_ATTACK]*20
      score += user.stages[:DEFENSE]*10
      score += user.stages[:SPECIAL_DEFENSE]*10
      if skill>=PBTrainerAI.mediumSkill
        hasDamagingAttack = false
        user.eachMove do |m|
          next if !m.damagingMove?
          hasDamagingAttack = true
          break
        end
        score += 20 if hasDamagingAttack
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtk1Spd2"
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:SPEED)
        score -= 90
      else
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:SPEED]*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill>=PBTrainerAI.highSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          score += 30 if aspeed<ospeed && aspeed*2>ospeed
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseTargetRandomStat2"
      avgStat = 0
      canChangeStat = false
      GameData::Stat.each_battle do |s|
        next if target.statStageAtMax?(s.id)
        avgStat -= target.stages[s.id]
        canChangeStat = true
      end
      if canChangeStat
        avgStat = avgStat/2 if avgStat<0   # More chance of getting even better
        score += avgStat*10
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "RaiseUserDefense3"
      if move.statusMove?
        if user.statStageAtMax?(:DEFENSE)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:DEFENSE]*30
        end
      else
        score += 10 if user.turnCount==0
        score += 30 if user.stages[:DEFENSE]<0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtk3"
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_ATTACK)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[:SPECIAL_ATTACK]*30
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            user.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 30 if user.stages[:SPECIAL_ATTACK]<0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 30 if hasSpecicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "MaxUserAttackLoseHalfOfTotalHP"
      if user.statStageAtMax?(:ATTACK) ||
         user.hp<=user.totalhp/2
        score -= 100
      else
        score += (6-user.stages[:ATTACK])*10
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 40
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "LowerUserAtkDef1"
      avg =  user.stages[:ATTACK]*10
      avg += user.stages[:DEFENSE]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "LowerUserDefSpDef1"
      avg =  user.stages[:DEFENSE]*10
      avg += user.stages[:SPECIAL_DEFENSE]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "LowerUserDefSpDefSpd1"
      avg =  user.stages[:DEFENSE]*10
      avg += user.stages[:SPEED]*10
      avg += user.stages[:SPECIAL_DEFENSE]*10
      score += (avg/3).floor
    #---------------------------------------------------------------------------
    when "LowerUserSpeed1", "LowerUserSpeed2"
      score += user.stages[:SPEED]*10
    #---------------------------------------------------------------------------
    when "LowerUserSpAtk1", "LowerUserSpAtk2"
      score += user.stages[:SPECIAL_ATTACK]*10
    #---------------------------------------------------------------------------
    when "LowerUserSpDef1", "LowerUserSpDef2"
      score += user.stages[:SPECIAL_DEFENSE] * 10
    #---------------------------------------------------------------------------
    when "RaiseTargetSpAtk1ConfuseTarget"
      if !target.pbCanConfuse?(user,false)
        score -= 90
      else
        score += 30 if target.stages[:SPECIAL_ATTACK]<0
      end
    #---------------------------------------------------------------------------
    when "RaiseTargetAttack2ConfuseTarget"
      if !target.pbCanConfuse?(user,false)
        score -= 90
      else
        score += 30 if target.stages[:ATTACK]<0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetAttack1"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:ATTACK,user)
          score -= 90
        else
          score += target.stages[:ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            target.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 20 if target.stages[:ATTACK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "LowerTargetDefense1"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:DEFENSE,user)
          score -= 90
        else
          score += target.stages[:DEFENSE]*20
        end
      else
        score += 20 if target.stages[:DEFENSE]>0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpeed1", "LowerTargetSpeed1WeakerInGrassyTerrain"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:SPEED,user)
          score -= 90
        else
          score += target.stages[:SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,:SPEED,skill)
            ospeed = pbRoughStat(target,:SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 20 if user.stages[:SPEED]>0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpAtk1"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
          score -= 90
        else
          score += user.stages[:SPECIAL_ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            target.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 20 if user.stages[:SPECIAL_ATTACK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          target.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 20 if hasSpecicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpDef1"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user)
          score -= 90
        else
          score += target.stages[:SPECIAL_DEFENSE]*20
        end
      else
        score += 20 if target.stages[:SPECIAL_DEFENSE]>0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetAccuracy1", "LowerTargetAccuracy2", "LowerTargetAccuracy3"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:ACCURACY,user)
          score -= 90
        else
          score += target.stages[:ACCURACY]*10
        end
      else
        score += 20 if target.stages[:ACCURACY]>0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetEvasion1", "LowerTargetEvasion2", "LowerTargetEvasion3"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:EVASION,user)
          score -= 90
        else
          score += target.stages[:EVASION]*10
        end
      else
        score += 20 if target.stages[:EVASION]>0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetEvasion1RemoveSideEffects"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:EVASION,user)
          score -= 90
        else
          score += target.stages[:EVASION]*10
        end
      else
        score += 20 if target.stages[:EVASION]>0
      end
      score += 30 if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
                     target.pbOwnSide.effects[PBEffects::Reflect]>0 ||
                     target.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
                     target.pbOwnSide.effects[PBEffects::Mist]>0 ||
                     target.pbOwnSide.effects[PBEffects::Safeguard]>0
      score -= 30 if target.pbOwnSide.effects[PBEffects::Spikes]>0 ||
                     target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
                     target.pbOwnSide.effects[PBEffects::StealthRock]
    #---------------------------------------------------------------------------
    when "LowerTargetAtkDef"
      avg =  target.stages[:ATTACK]*10
      avg += target.stages[:DEFENSE]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "LowerTargetAttack2", "LowerTargetAttack3"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:ATTACK,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[:ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            target.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[:ATTACK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          score += 20 if hasPhysicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "LowerTargetDefense2", "LowerTargetDefense3"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:DEFENSE,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[:DEFENSE]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[:DEFENSE]>0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpeed2", "LowerTargetSpeed3"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:SPEED,user)
          score -= 90
        else
          score += 20 if user.turnCount==0
          score += target.stages[:SPEED]*20
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,:SPEED,skill)
            ospeed = pbRoughStat(target,:SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 30 if target.stages[:SPEED]>0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpAtk2IfCanAttract"
      if user.gender==2 || target.gender==2 || user.gender==target.gender ||
         target.hasActiveAbility?(:OBLIVIOUS)
        score -= 90
      elsif move.statusMove?
        if !target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[:SPECIAL_ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            target.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[:SPECIAL_ATTACK]>0
        if skill>=PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          target.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          score += 30 if hasSpecicalAttack
        end
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpDef2", "LowerTargetSpDef3"
      if move.statusMove?
        if !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score += target.stages[:SPECIAL_DEFENSE]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if target.stages[:SPECIAL_DEFENSE]>0
      end
    #---------------------------------------------------------------------------
    when "ResetTargetStatStages"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      else
        avg = 0
        anyChange = false
        GameData::Stat.each_battle do |s|
          next if target.stages[s.id]==0
          avg += target.stages[s.id]
          anyChange = true
        end
        if anyChange
          score += avg*10
        else
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "ResetAllBattlersStatStages"
      if skill>=PBTrainerAI.mediumSkill
        stages = 0
        @battle.allBattlers.each do |b|
          totalStages = 0
          GameData::Stat.each_battle { |s| totalStages += b.stages[s.id] }
          if b.opposes?(user)
            stages += totalStages
          else
            stages -= totalStages
          end
        end
        score += stages*10
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapAtkSpAtkStages"
      if skill>=PBTrainerAI.mediumSkill
        aatk = user.stages[:ATTACK]
        aspa = user.stages[:SPECIAL_ATTACK]
        oatk = target.stages[:ATTACK]
        ospa = target.stages[:SPECIAL_ATTACK]
        if aatk>=oatk && aspa>=ospa
          score -= 80
        else
          score += (oatk-aatk)*10
          score += (ospa-aspa)*10
        end
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapDefSpDefStages"
      if skill>=PBTrainerAI.mediumSkill
        adef = user.stages[:DEFENSE]
        aspd = user.stages[:SPECIAL_DEFENSE]
        odef = target.stages[:DEFENSE]
        ospd = target.stages[:SPECIAL_DEFENSE]
        if adef>=odef && aspd>=ospd
          score -= 80
        else
          score += (odef-adef)*10
          score += (ospd-aspd)*10
        end
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapStatStages"
      if skill>=PBTrainerAI.mediumSkill
        userStages = 0
        targetStages = 0
        GameData::Stat.each_battle do |s|
          userStages   += user.stages[s.id]
          targetStages += target.stages[s.id]
        end
        score += (targetStages-userStages)*10
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "UserCopyTargetStatStages"
      if skill>=PBTrainerAI.mediumSkill
        equal = true
        GameData::Stat.each_battle do |s|
          stagediff = target.stages[s.id] - user.stages[s.id]
          score += stagediff*10
          equal = false if stagediff!=0
        end
        score -= 80 if equal
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "StartUserSideImmunityToStatStageLowering"
      score -= 80 if user.pbOwnSide.effects[PBEffects::Mist]>0
    #---------------------------------------------------------------------------
    when "UserSwapBaseAtkDef"
      if skill>=PBTrainerAI.mediumSkill
        aatk = pbRoughStat(user,:ATTACK,skill)
        adef = pbRoughStat(user,:DEFENSE,skill)
        if aatk==adef ||
           user.effects[PBEffects::PowerTrick]   # No flip-flopping
          score -= 90
        elsif adef>aatk   # Prefer a higher Attack
          score += 30
        else
          score -= 30
        end
      else
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "UserTargetAverageBaseAtkSpAtk"
      if skill>=PBTrainerAI.mediumSkill
        aatk   = pbRoughStat(user,:ATTACK,skill)
        aspatk = pbRoughStat(user,:SPECIAL_ATTACK,skill)
        oatk   = pbRoughStat(target,:ATTACK,skill)
        ospatk = pbRoughStat(target,:SPECIAL_ATTACK,skill)
        if aatk<oatk && aspatk<ospatk
          score += 50
        elsif aatk+aspatk<oatk+ospatk
          score += 30
        else
          score -= 50
        end
      else
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "UserTargetAverageBaseDefSpDef"
      if skill>=PBTrainerAI.mediumSkill
        adef   = pbRoughStat(user,:DEFENSE,skill)
        aspdef = pbRoughStat(user,:SPECIAL_DEFENSE,skill)
        odef   = pbRoughStat(target,:DEFENSE,skill)
        ospdef = pbRoughStat(target,:SPECIAL_DEFENSE,skill)
        if adef<odef && aspdef<ospdef
          score += 50
        elsif adef+aspdef<odef+ospdef
          score += 30
        else
          score -= 50
        end
      else
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "UserTargetAverageHP"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif user.hp>=(user.hp+target.hp)/2
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "StartUserSideDoubleSpeed"
      score -= 90 if user.pbOwnSide.effects[PBEffects::Tailwind]>0
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
    when "SetUserTypesToUserMoveType"
      if !user.canChangeType?
        score -= 90
      else
        has_possible_type = false
        user.eachMoveWithIndex do |m,i|
          break if Settings::MECHANICS_GENERATION >= 6 && i>0
          next if GameData::Type.get(m.type).pseudo_type
          next if user.pbHasType?(m.type)
          has_possible_type = true
          break
        end
        score -= 90 if !has_possible_type
      end
    #---------------------------------------------------------------------------
    when "SetUserTypesToResistLastAttack"
      if !user.canChangeType?
        score -= 90
      elsif !target.lastMoveUsed || !target.lastMoveUsedType ||
         GameData::Type.get(target.lastMoveUsedType).pseudo_type
        score -= 90
      else
        aType = nil
        target.eachMove do |m|
          next if m.id!=target.lastMoveUsed
          aType = m.pbCalcType(user)
          break
        end
        if !aType
          score -= 90
        else
          has_possible_type = false
          GameData::Type.each do |t|
            next if t.pseudo_type || user.pbHasType?(t.id) ||
                    !Effectiveness.resistant_type?(target.lastMoveUsedType, t.id)
            has_possible_type = true
            break
          end
          score -= 90 if !has_possible_type
        end
      end
    #---------------------------------------------------------------------------
    when "SetUserTypesBasedOnEnvironment"
      if !user.canChangeType?
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        new_type = nil
        case @battle.field.terrain
        when :Electric
          new_type = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
        when :Grassy
          new_type = :GRASS if GameData::Type.exists?(:GRASS)
        when :Misty
          new_type = :FAIRY if GameData::Type.exists?(:FAIRY)
        when :Psychic
          new_type = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
        end
        if !new_type
          envtypes = {
             :None        => :NORMAL,
             :Grass       => :GRASS,
             :TallGrass   => :GRASS,
             :MovingWater => :WATER,
             :StillWater  => :WATER,
             :Puddle      => :WATER,
             :Underwater  => :WATER,
             :Cave        => :ROCK,
             :Rock        => :GROUND,
             :Sand        => :GROUND,
             :Forest      => :BUG,
             :ForestGrass => :BUG,
             :Snow        => :ICE,
             :Ice         => :ICE,
             :Volcano     => :FIRE,
             :Graveyard   => :GHOST,
             :Sky         => :FLYING,
             :Space       => :DRAGON,
             :UltraSpace  => :PSYCHIC
          }
          new_type = envtypes[@battle.environment]
          new_type = nil if !GameData::Type.exists?(new_type)
          new_type ||= :NORMAL
        end
        score -= 90 if !user.pbHasOtherType?(new_type)
      end
    #---------------------------------------------------------------------------
    when "SetTargetTypesToWater"
      if target.effects[PBEffects::Substitute]>0 || !target.canChangeType?
        score -= 90
      elsif !target.pbHasOtherType?(:WATER)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "SetUserTypesToTargetTypes"
      if !user.canChangeType? || target.pbTypes(true).length == 0
        score -= 90
      elsif user.pbTypes == target.pbTypes &&
         user.effects[PBEffects::Type3] == target.effects[PBEffects::Type3]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToSimple"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        if target.unstoppableAbility? || [:TRUANT, :SIMPLE].include?(target.ability)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToInsomnia"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        if target.unstoppableAbility? || [:TRUANT, :INSOMNIA].include?(target.ability_id)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "SetUserAbilityToTargetAbility"
      score -= 40   # don't prefer this move
      if skill>=PBTrainerAI.mediumSkill
        if !target.ability || user.ability==target.ability ||
           [:MULTITYPE, :RKSSYSTEM].include?(user.ability_id) ||
           [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
            :TRACE, :WONDERGUARD, :ZENMODE].include?(target.ability_id)
          score -= 90
        end
      end
      if skill>=PBTrainerAI.highSkill
        if target.ability == :TRUANT && user.opposes?(target)
          score -= 90
        elsif target.ability == :SLOWSTART && user.opposes?(target)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToUserAbility"
      score -= 40   # don't prefer this move
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        if !user.ability || user.ability==target.ability ||
          [:MULTITYPE, :RKSSYSTEM, :TRUANT].include?(target.ability_id) ||
          [:FLOWERGIFT, :FORECAST, :ILLUSION, :IMPOSTER, :MULTITYPE, :RKSSYSTEM,
           :TRACE, :ZENMODE].include?(user.ability_id)
          score -= 90
        end
        if skill>=PBTrainerAI.highSkill
          if user.ability == :TRUANT && user.opposes?(target)
            score += 90
          elsif user.ability == :SLOWSTART && user.opposes?(target)
            score += 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapAbilities"
      score -= 40   # don't prefer this move
      if skill>=PBTrainerAI.mediumSkill
        if (!user.ability && !target.ability) ||
           user.ability==target.ability ||
           [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(user.ability_id) ||
           [:ILLUSION, :MULTITYPE, :RKSSYSTEM, :WONDERGUARD].include?(target.ability_id)
          score -= 90
        end
      end
      if skill>=PBTrainerAI.highSkill
        if target.ability == :TRUANT && user.opposes?(target)
          score -= 90
        elsif target.ability == :SLOWSTART && user.opposes?(target)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "NegateTargetAbility"
      if target.effects[PBEffects::Substitute]>0 ||
         target.effects[PBEffects::GastroAcid]
        score -= 90
      elsif skill>=PBTrainerAI.highSkill
        score -= 90 if [:MULTITYPE, :RKSSYSTEM, :SLOWSTART, :TRUANT].include?(target.ability_id)
      end
    #---------------------------------------------------------------------------
    when "TransformUserIntoTarget"
      score -= 70
    #---------------------------------------------------------------------------
    when "FixedDamage20"
      if target.hp<=20
        score += 80
      elsif target.level>=25
        score -= 60   # Not useful against high-level Pokemon
      end
    #---------------------------------------------------------------------------
    when "FixedDamage40"
      score += 80 if target.hp<=40
    #---------------------------------------------------------------------------
    when "FixedDamageHalfTargetHP"
      score -= 50
      score += target.hp*100/target.totalhp
    #---------------------------------------------------------------------------
    when "FixedDamageUserLevel"
      score += 80 if target.hp<=user.level
    #---------------------------------------------------------------------------
    when "LowerTargetHPToUserHP"
      if user.hp>=target.hp
        score -= 90
      elsif user.hp<target.hp/2
        score += 50
      end
    #---------------------------------------------------------------------------
    when "FixedDamageUserLevelRandom"
      score += 30 if target.hp<=user.level
    #---------------------------------------------------------------------------
  when "OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"
      score -= 90 if target.hasActiveAbility?(:STURDY)
      score -= 90 if target.level>user.level
    #---------------------------------------------------------------------------
    when "CounterPhysicalDamage"
      if target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        attack = pbRoughStat(user,:ATTACK,skill)
        spatk  = pbRoughStat(user,:SPECIAL_ATTACK,skill)
        if attack*1.5<spatk
          score -= 60
        elsif skill>=PBTrainerAI.mediumSkill && target.lastMoveUsed
          moveData = GameData::Move.get(target.lastMoveUsed)
          score += 60 if moveData.physical?
        end
      end
    #---------------------------------------------------------------------------
    when "CounterSpecialDamage"
      if target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        attack = pbRoughStat(user,:ATTACK,skill)
        spatk  = pbRoughStat(user,:SPECIAL_ATTACK,skill)
        if attack>spatk*1.5
          score -= 60
        elsif skill>=PBTrainerAI.mediumSkill && target.lastMoveUsed
          moveData = GameData::Move.get(target.lastMoveUsed)
          score += 60 if moveData.special?
        end
      end
    #---------------------------------------------------------------------------
    when "CounterDamagePlusHalf"
      score -= 90 if target.effects[PBEffects::HyperBeam]>0
    #---------------------------------------------------------------------------
    when "DamageTargetAlly"
      target.allAllies.each do |b|
        next if !b.near?(target)
        score += 10
      end
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetUnderwater"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetUnderground"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetInSky"
    #---------------------------------------------------------------------------
    when "FlinchTargetDoublePowerIfTargetInSky"
      if skill>=PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute]==0
      end
    #---------------------------------------------------------------------------
    when "DoublePowerAfterFusionFlare"
    #---------------------------------------------------------------------------
    when "DoublePowerAfterFusionBolt"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetPoisoned"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetParalyzedCureTarget"
      score -= 20 if target.status == :PARALYSIS   # Will cure status
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetAsleepCureTarget"
      score -= 20 if target.status == :SLEEP &&   # Will cure status
                     target.statusCount > 1
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserPoisonedBurnedParalyzed"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetStatusProblem"
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetHPLessThanHalf"
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserLostHPThisTurn"
      attspeed = pbRoughStat(user,:SPEED,skill)
      oppspeed = pbRoughStat(target,:SPEED,skill)
      score += 30 if oppspeed>attspeed
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetLostHPThisTurn"
      score += 20 if @battle.pbOpposingBattlerCount(user)>1
    #---------------------------------------------------------------------------
    when "UsedAfterAllyRoundWithDoublePower"
      if skill>=PBTrainerAI.mediumSkill
        user.allAllies.each do |b|
          next if !b.pbHasMove?(move.id)
          score += 20
        end
      end
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetActed"
      attspeed = pbRoughStat(user,:SPEED,skill)
      oppspeed = pbRoughStat(target,:SPEED,skill)
      score += 30 if oppspeed>attspeed
    #---------------------------------------------------------------------------
    when "DoublePowerIfAllyFaintedLastTurn"
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserHasNoItem"
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnWeather"
    #---------------------------------------------------------------------------
    when "PursueSwitchingFoe"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHappiness"
    #---------------------------------------------------------------------------
    when "PowerLowerWithUserHappiness"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHP"
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetHP"
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetFasterThanUser"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserPositiveStatStages"
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetPositiveStatStages"
    #---------------------------------------------------------------------------
    when "TypeDependsOnUserIVs"
    #---------------------------------------------------------------------------
    when "PowerHigherWithConsecutiveUse"
    #---------------------------------------------------------------------------
    when "PowerHigherWithConsecutiveUseOnUserSide"
    #---------------------------------------------------------------------------
    when "StartRaiseUserAtk1WhenDamaged"
      score += 25 if user.effects[PBEffects::Rage]
    #---------------------------------------------------------------------------
    when "RandomlyDamageOrHealTarget"
    #---------------------------------------------------------------------------
    when "RandomPowerDoublePowerIfTargetUnderground"
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnUserBerry"
      score -= 90 if !user.item || !user.item.is_berry? || !user.itemActive?
    #---------------------------------------------------------------------------
    when "PowerHigherWithLessPP"
    #---------------------------------------------------------------------------
    when "PowerLowerWithUserHP"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserFasterThanTarget"
    #---------------------------------------------------------------------------
    when "PowerHigherWithTargetWeight"
    #---------------------------------------------------------------------------
    when "PowerHigherWithUserHeavierThanTarget"
    #---------------------------------------------------------------------------
    when "PowerUpAllyMove"
      hasAlly = false
      user.allAllies.each do |b|
        hasAlly = true
        score += 30
        break
      end
      score -= 90 if !hasAlly
    #---------------------------------------------------------------------------
    when "StartWeakenElectricMoves"
      score -= 90 if user.effects[PBEffects::MudSport]
    #---------------------------------------------------------------------------
    when "StartWeakenFireMoves"
      score -= 90 if user.effects[PBEffects::WaterSport]
    #---------------------------------------------------------------------------
    when "TypeDependsOnUserPlate", "TypeDependsOnUserMemory", "TypeDependsOnUserDrive"
    #---------------------------------------------------------------------------
    when "AlwaysCriticalHit"
    #---------------------------------------------------------------------------
    when "StartPreventCriticalHitsAgainstUserSide"
      score -= 90 if user.pbOwnSide.effects[PBEffects::LuckyChant]>0
    #---------------------------------------------------------------------------
    when "StartWeakenPhysicalDamageAgainstUserSide"
      score -= 90 if user.pbOwnSide.effects[PBEffects::Reflect]>0
    #---------------------------------------------------------------------------
    when "StartWeakenSpecialDamageAgainstUserSide"
      score -= 90 if user.pbOwnSide.effects[PBEffects::LightScreen]>0
    #---------------------------------------------------------------------------
    when "EffectDependsOnEnvironment"
    #---------------------------------------------------------------------------
    when "EnsureNextMoveAlwaysHits"
      score -= 90 if target.effects[PBEffects::Substitute]>0
      score -= 90 if user.effects[PBEffects::LockOn]>0
    #---------------------------------------------------------------------------
    when "StartNegateTargetEvasionStatStageAndGhostImmunity"
      if target.effects[PBEffects::Foresight]
        score -= 90
      elsif target.pbHasType?(:GHOST)
        score += 70
      elsif target.stages[:EVASION]<=0
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "StartNegateTargetEvasionStatStageAndDarkImmunity"
      if target.effects[PBEffects::MiracleEye]
        score -= 90
      elsif target.pbHasType?(:DARK)
        score += 70
      elsif target.stages[:EVASION]<=0
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "IgnoreTargetDefSpDefEvaStatStages"
    #---------------------------------------------------------------------------
    when "ProtectUser"
      if user.effects[PBEffects::ProtectRate]>1 ||
         target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate]*40
        end
        score += 50 if user.turnCount==0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromPriorityMoves"
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromMultiTargetDamagingMoves"
    #---------------------------------------------------------------------------
    when "RemoveProtections"
    #---------------------------------------------------------------------------
    when "UseLastMoveUsedByTarget"
      score -= 40
      if skill>=PBTrainerAI.highSkill
        score -= 100 if !target.lastRegularMoveUsed ||
           !GameData::Move.get(target.lastRegularMoveUsed).flags.any? { |f| f[/^CanMirrorMove$/i] }
      end
    #---------------------------------------------------------------------------
    when "UseLastMoveUsed"
    #---------------------------------------------------------------------------
    when "UseMoveTargetIsAboutToUse"
    #---------------------------------------------------------------------------
    when "BounceBackProblemCausingStatusMoves"
    #---------------------------------------------------------------------------
    when "StealAndUseBeneficialStatusMove"
    #---------------------------------------------------------------------------
    when "UseMoveDependingOnEnvironment"
    #---------------------------------------------------------------------------
    when "UseRandomUserMoveIfAsleep"
      if user.asleep?
        score += 100   # Because it can only be used while asleep
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "UseRandomMoveFromUserParty"
    #---------------------------------------------------------------------------
    when "UseRandomMove"
    #---------------------------------------------------------------------------
    when "DisableTargetUsingSameMoveConsecutively"
      score -= 90 if target.effects[PBEffects::Torment]
    #---------------------------------------------------------------------------
    when "DisableTargetMovesKnownByUser"
      score -= 90 if user.effects[PBEffects::Imprison]
    #---------------------------------------------------------------------------
    when "DisableTargetLastMoveUsed"
      score -= 90 if target.effects[PBEffects::Disable]>0
    #---------------------------------------------------------------------------
    when "DisableTargetStatusMoves"
      score -= 90 if target.effects[PBEffects::Taunt]>0
    #---------------------------------------------------------------------------
    when "DisableTargetHealingMoves"
      score -= 90 if target.effects[PBEffects::HealBlock]>0
    #---------------------------------------------------------------------------
    when "DisableTargetUsingDifferentMove"
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      if target.effects[PBEffects::Encore]>0
        score -= 90
      elsif aspeed>ospeed
        if !target.lastRegularMoveUsed
          score -= 90
        else
          moveData = GameData::Move.get(target.lastRegularMoveUsed)
          if moveData.category == 2 &&   # Status move
             [:User, :BothSides].include?(moveData.target)
            score += 60
          elsif moveData.category != 2 &&   # Damaging move
             moveData.target == :NearOther &&
             Effectiveness.ineffective?(pbCalcTypeMod(moveData.type, target, user))
            score += 60
          end
        end
      end
    #---------------------------------------------------------------------------
    when "HitTwoTimes"
    #---------------------------------------------------------------------------
    when "HitTwoTimesPoisonTarget"
    #---------------------------------------------------------------------------
    when "HitThreeTimesPowersUpWithEachHit"
    #---------------------------------------------------------------------------
    when "HitTwoToFiveTimes"
    #---------------------------------------------------------------------------
    when "HitTwoToFiveTimesOrThreeForAshGreninja"
    #---------------------------------------------------------------------------
    when "HitOncePerUserTeamMember"
    #---------------------------------------------------------------------------
    when "AttackAndSkipNextTurn"
    #---------------------------------------------------------------------------
    when "TwoTurnAttack"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackFlinchTarget"
      score += 20 if user.effects[PBEffects::FocusEnergy]>0
      if skill>=PBTrainerAI.highSkill
        score += 20 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute]==0
      end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSky"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableUnderground"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableUnderwater"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSkyParalyzeTarget"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableRemoveProtections"
    #---------------------------------------------------------------------------
    when "TwoTurnAttackInvulnerableInSkyTargetCannotAct"
    #---------------------------------------------------------------------------
    when "BindTarget"
      score += 40 if target.effects[PBEffects::Trapping]==0
    #---------------------------------------------------------------------------
    when "BindTargetDoublePowerIfTargetUnderwater"
      score += 40 if target.effects[PBEffects::Trapping]==0
    #---------------------------------------------------------------------------
    when "MultiTurnAttackPreventSleeping"
    #---------------------------------------------------------------------------
    when "MultiTurnAttackConfuseUserAtEnd"
    #---------------------------------------------------------------------------
    when "MultiTurnAttackPowersUpEachTurn"
    #---------------------------------------------------------------------------
    when "MultiTurnAttackBideThenReturnDoubleDamage"
      if user.hp<=user.totalhp/4
        score -= 90
      elsif user.hp<=user.totalhp/2
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "HealUserHalfOfTotalHP", "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn"
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp*100/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "HealUserPositionNextTurn"
      score -= 90 if @battle.positions[user.index].effects[PBEffects::Wish]>0
    #---------------------------------------------------------------------------
    when "HealUserDependingOnWeather"
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
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
        score -= user.hp*100/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "HealUserFullyAndFallAsleep"
      if user.hp==user.totalhp || !user.pbCanSleep?(user,false,nil,true)
        score -= 90
      else
        score += 70
        score -= user.hp*140/user.totalhp
        score += 30 if user.status != :NONE
      end
    #---------------------------------------------------------------------------
    when "StartHealUserEachTurn"
      score -= 90 if user.effects[PBEffects::AquaRing]
    #---------------------------------------------------------------------------
    when "StartHealUserEachTurnTrapUserInBattle"
      score -= 90 if user.effects[PBEffects::Ingrain]
    #---------------------------------------------------------------------------
    when "StartLeechSeedTarget"
      if target.effects[PBEffects::LeechSeed]>=0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill && target.pbHasType?(:GRASS)
        score -= 90
      else
        score += 60 if user.turnCount==0
      end
    #---------------------------------------------------------------------------
    when "HealUserByHalfOfDamageDone"
      if skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 70
      else
        score += 20 if user.hp<=user.totalhp/2
      end
    #---------------------------------------------------------------------------
    when "HealUserByHalfOfDamageDoneIfTargetAsleep"
      if !target.asleep?
        score -= 100
      elsif skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 70
      else
        score += 20 if user.hp<=user.totalhp/2
      end
    #---------------------------------------------------------------------------
    when "HealTargetHalfOfTotalHP"
      if user.opposes?(target)
        score -= 100
      else
        score += 20 if target.hp<target.totalhp/2 &&
                       target.effects[PBEffects::Substitute]==0
      end
    #---------------------------------------------------------------------------
    when "UserFaintsExplosive"
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif skill>=PBTrainerAI.mediumSkill && reserves==0 && foes>0
        score -= 100   # don't want to lose
      elsif skill>=PBTrainerAI.highSkill && reserves==0 && foes==0
        score += 80   # want to draw
      else
        score -= user.hp*100/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "UserFaintsFixedDamageUserHP"
    #---------------------------------------------------------------------------
    when "UserFaintsLowerTargetAtkSpAtk2"
      if !target.pbCanLowerStatStage?(:ATTACK,user) &&
         !target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
        score -= 100
      elsif @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        score -= 100
      else
        score += target.stages[:ATTACK]*10
        score += target.stages[:SPECIAL_ATTACK]*10
        score -= user.hp*100/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "UserFaintsHealAndCureReplacement", "UserFaintsHealAndCureReplacementRestorePP"
      score -= 70
    #---------------------------------------------------------------------------
    when "StartPerishCountsForAllBattlers"
      if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        score -= 90
      else
        score -= 90 if target.effects[PBEffects::PerishSong]>0
      end
    #---------------------------------------------------------------------------
    when "ReduceAttackerMovePPTo0IfUserFaints"
      score += 50
      score -= user.hp*100/user.totalhp
      score += 30 if user.hp<=user.totalhp/10
    #---------------------------------------------------------------------------
    when "AttackerFaintsIfUserFaints"
      score += 50
      score -= user.hp*100/user.totalhp
      score += 30 if user.hp<=user.totalhp/10
    #---------------------------------------------------------------------------
    when "UserEnduresFaintingThisTurn"
      score -= 25 if user.hp>user.totalhp/2
      if skill>=PBTrainerAI.mediumSkill
        score -= 90 if user.effects[PBEffects::ProtectRate]>1
        score -= 90 if target.effects[PBEffects::HyperBeam]>0
      else
        score -= user.effects[PBEffects::ProtectRate]*40
      end
    #---------------------------------------------------------------------------
    when "CannotMakeTargetFaint"
      if target.hp==1
        score -= 90
      elsif target.hp<=target.totalhp/8
        score -= 60
      elsif target.hp<=target.totalhp/4
        score -= 30
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
        score += 40 if user.effects[PBEffects::Confusion]>0
        total = 0
        GameData::Stat.each_battle { |s| total += user.stages[s.id] }
        if total<=0 || user.turnCount==0
          score += 60
        else
          score -= total*10
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
    when "SwitchOutTargetStatusMove"
      if target.effects[PBEffects::Ingrain] ||
         (skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:SUCTIONCUPS))
        score -= 90
      else
        ch = 0
        @battle.pbParty(target.index).each_with_index do |pkmn,i|
          ch += 1 if @battle.pbCanSwitchLax?(target.index,i)
        end
        score -= 90 if ch==0
      end
      if score>20
        score += 50 if target.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 50 if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 50 if target.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "SwitchOutTargetDamagingMove"
      if !target.effects[PBEffects::Ingrain] &&
         !(skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:SUCTIONCUPS))
        score += 40 if target.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 40 if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 40 if target.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "SwitchOutUserPassOnEffects"
      if !@battle.pbCanChooseNonActive?(user.index)
        score -= 100
      else
        score -= 40 if user.effects[PBEffects::Confusion]>0
        total = 0
        GameData::Stat.each_battle { |s| total += user.stages[s.id] }
        if total<=0 || user.turnCount==0
          score -= 60
        else
          score += total*10
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
    when "TrapTargetInBattle"
      score -= 90 if target.effects[PBEffects::MeanLook]>=0
    #---------------------------------------------------------------------------
    when "RemoveTargetItem"
      if skill>=PBTrainerAI.highSkill
        score += 20 if target.item
      end
    #---------------------------------------------------------------------------
    when "UserTakesTargetItem"
      if skill>=PBTrainerAI.highSkill
        if !user.item && target.item
          score += 40
        else
          score -= 90
        end
      else
        score -= 80
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapItems"
      if !user.item && !target.item
        score -= 90
      elsif skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:STICKYHOLD)
        score -= 90
      elsif user.hasActiveItem?([:FLAMEORB,:TOXICORB,:STICKYBARB,:IRONBALL,
                                 :CHOICEBAND,:CHOICESCARF,:CHOICESPECS])
        score += 50
      elsif !user.item && target.item
        score -= 30 if user.lastMoveUsed &&
                       GameData::Move.get(user.lastMoveUsed).function_code == "UserTargetSwapItems"
      end
    #---------------------------------------------------------------------------
    when "TargetTakesUserItem"
      if !user.item || target.item
        score -= 90
      else
        if user.hasActiveItem?([:FLAMEORB,:TOXICORB,:STICKYBARB,:IRONBALL,
                                :CHOICEBAND,:CHOICESCARF,:CHOICESPECS])
          score += 50
        else
          score -= 80
        end
      end
    #---------------------------------------------------------------------------
    when "UserConsumeTargetBerry", "DestroyTargetBerryOrGem"
      if target.effects[PBEffects::Substitute]==0
        if skill>=PBTrainerAI.highSkill && target.item && target.item.is_berry?
          score += 30
        end
      end
    #---------------------------------------------------------------------------
    when "RestoreUserConsumedItem"
      if !user.recycleItem || user.item
        score -= 80
      elsif user.recycleItem
        score += 30
      end
    #---------------------------------------------------------------------------
    when "ThrowUserItemAtTarget"
      if !user.item || !user.itemActive? ||
         user.unlosableItem?(user.item) || user.item.is_poke_ball?
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "StartTargetCannotUseItem"
      score -= 90 if target.effects[PBEffects::Embargo]>0
    #---------------------------------------------------------------------------
    when "StartNegateHeldItems"
      if @battle.field.effects[PBEffects::MagicRoom]>0
        score -= 90
      else
        score += 30 if !user.item && target.item
      end
    #---------------------------------------------------------------------------
    when "RecoilQuarterOfDamageDealt"
      score -= 25
    #---------------------------------------------------------------------------
    when "RecoilThirdOfDamageDealt"
      score -= 30
    #---------------------------------------------------------------------------
    when "RecoilHalfOfDamageDealt"
      score -= 40
    #---------------------------------------------------------------------------
    when "RecoilThirdOfDamageDealtParalyzeTarget"
      score -= 30
      if target.pbCanParalyze?(user,false)
        score += 30
        if skill>=PBTrainerAI.mediumSkill
           aspeed = pbRoughStat(user,:SPEED,skill)
           ospeed = pbRoughStat(target,:SPEED,skill)
          if aspeed<ospeed
            score += 30
          elsif aspeed>ospeed
            score -= 40
          end
        end
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET])
        end
      end
    #---------------------------------------------------------------------------
    when "RecoilThirdOfDamageDealtBurnTarget"
      score -= 30
      if target.pbCanBurn?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
        end
      end
    #---------------------------------------------------------------------------
    when "StartSunWeather"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Sun
        score -= 90
      else
        user.eachMove do |m|
          next if !m.damagingMove? || m.type != :FIRE
          score += 20
        end
      end
    #---------------------------------------------------------------------------
    when "StartRainWeather"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Rain
        score -= 90
      else
        user.eachMove do |m|
          next if !m.damagingMove? || m.type != :WATER
          score += 20
        end
      end
    #---------------------------------------------------------------------------
    when "StartSandstormWeather"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Sandstorm
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "StartHailWeather"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Hail
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "AddSpikesToFoeSide"
      if user.pbOpposingSide.effects[PBEffects::Spikes]>=3
        score -= 90
      else
        if user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
          # Opponent can't switch in any Pokemon
          score -= 90
        else
          score += 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
          score += [40,26,13][user.pbOpposingSide.effects[PBEffects::Spikes]]
        end
      end
    #---------------------------------------------------------------------------
    when "AddToxicSpikesToFoeSide"
      if user.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
        score -= 90
      else
        if user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
          # Opponent can't switch in any Pokemon
          score -= 90
        else
          score += 8*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
          score += [26,13][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
        end
      end
    #---------------------------------------------------------------------------
    when "AddStealthRocksToFoeSide"
      if user.pbOpposingSide.effects[PBEffects::StealthRock]
        score -= 90
      else
        if user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
          # Opponent can't switch in any Pokemon
          score -= 90
        else
          score += 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        end
      end
    #---------------------------------------------------------------------------
    when "GrassPledge"
    #---------------------------------------------------------------------------
    when "FirePledge"
    #---------------------------------------------------------------------------
    when "WaterPledge"
    #---------------------------------------------------------------------------
    when "AddMoneyGainedFromBattle"
    #---------------------------------------------------------------------------
    when "RemoveScreens"
      score += 20 if user.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      score += 20 if user.pbOpposingSide.effects[PBEffects::Reflect]>0
      score += 20 if user.pbOpposingSide.effects[PBEffects::LightScreen]>0
    #---------------------------------------------------------------------------
    when "CrashDamageIfFailsUnusableInGravity"
      score += 10*(user.stages[:ACCURACY]-target.stages[:EVASION])
    #---------------------------------------------------------------------------
    when "UserMakeSubstitute"
      if user.effects[PBEffects::Substitute]>0
        score -= 90
      elsif user.hp<=user.totalhp/4
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1"
      if user.pbHasType?(:GHOST)
        if target.effects[PBEffects::Curse]
          score -= 90
        elsif user.hp<=user.totalhp/2
          if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
            score -= 90
          else
            score -= 50
            score -= 30 if @battle.switchStyle
          end
        end
      else
        avg  = user.stages[:SPEED]*10
        avg -= user.stages[:ATTACK]*10
        avg -= user.stages[:DEFENSE]*10
        score += avg/3
      end
    #---------------------------------------------------------------------------
    when "LowerPPOfTargetLastMoveBy4"
      score -= 40
    #---------------------------------------------------------------------------
    when "StartDamageTargetEachTurnIfTargetAsleep"
      if target.effects[PBEffects::Nightmare] ||
         target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif !target.asleep?
        score -= 90
      else
        score -= 90 if target.statusCount<=1
        score += 50 if target.statusCount>3
      end
    #---------------------------------------------------------------------------
    when "RemoveUserBindingAndEntryHazards"
      score += 30 if user.effects[PBEffects::Trapping]>0
      score += 30 if user.effects[PBEffects::LeechSeed]>=0
      if @battle.pbAbleNonActiveCount(user.idxOwnSide)>0
        score += 80 if user.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 80 if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 80 if user.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "AttackTwoTurnsLater"
      if @battle.positions[target.index].effects[PBEffects::FutureSightCounter]>0
        score -= 100
      elsif @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        # Future Sight tends to be wasteful if down to last Pokemon
        score -= 70
      end
    #---------------------------------------------------------------------------
    when "UserAddStockpileRaiseDefSpDef1"
      avg = 0
      avg -= user.stages[:DEFENSE]*10
      avg -= user.stages[:SPECIAL_DEFENSE]*10
      score += avg/2
      if user.effects[PBEffects::Stockpile]>=3
        score -= 80
      else
        # More preferable if user also has Spit Up/Swallow
        score += 20 if user.pbHasMoveFunction?("PowerDependsOnUserStockpile",
                                               "HealUserDependingOnUserStockpile")   # Spit Up, Swallow
      end
    #---------------------------------------------------------------------------
    when "PowerDependsOnUserStockpile"
      score -= 100 if user.effects[PBEffects::Stockpile]==0
    #---------------------------------------------------------------------------
    when "HealUserDependingOnUserStockpile"
      if user.effects[PBEffects::Stockpile]==0
        score -= 90
      elsif user.hp==user.totalhp
        score -= 90
      else
        mult = [0,25,50,100][user.effects[PBEffects::Stockpile]]
        score += mult
        score -= user.hp*mult*2/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "FailsIfUserDamagedThisTurn"
      score += 50 if target.effects[PBEffects::HyperBeam]>0
      score -= 35 if target.hp<=target.totalhp/2   # If target is weak, no
      score -= 70 if target.hp<=target.totalhp/4   # need to risk this move
    #---------------------------------------------------------------------------
    when "FailsIfTargetActed"
    #---------------------------------------------------------------------------
    when "RedirectAllMovesToUser"
      score -= 90 if user.allAllies.length == 0
    #---------------------------------------------------------------------------
    when "StartGravity"
      if @battle.field.effects[PBEffects::Gravity]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        score -= 30
        score -= 20 if user.effects[PBEffects::SkyDrop]>=0
        score -= 20 if user.effects[PBEffects::MagnetRise]>0
        score -= 20 if user.effects[PBEffects::Telekinesis]>0
        score -= 20 if user.pbHasType?(:FLYING)
        score -= 20 if user.hasActiveAbility?(:LEVITATE)
        score -= 20 if user.hasActiveItem?(:AIRBALLOON)
        score += 20 if target.effects[PBEffects::SkyDrop]>=0
        score += 20 if target.effects[PBEffects::MagnetRise]>0
        score += 20 if target.effects[PBEffects::Telekinesis]>0
        score += 20 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                               "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                               "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
        score += 20 if target.pbHasType?(:FLYING)
        score += 20 if target.hasActiveAbility?(:LEVITATE)
        score += 20 if target.hasActiveItem?(:AIRBALLOON)
      end
    #---------------------------------------------------------------------------
    when "StartUserAirborne"
      if user.effects[PBEffects::MagnetRise]>0 ||
         user.effects[PBEffects::Ingrain] ||
         user.effects[PBEffects::SmackDown]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "StartTargetAirborneAndAlwaysHitByMoves"
      if target.effects[PBEffects::Telekinesis]>0 ||
         target.effects[PBEffects::Ingrain] ||
         target.effects[PBEffects::SmackDown]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "HitsTargetInSky"
    #---------------------------------------------------------------------------
    when "HitsTargetInSkyGroundsTarget"
      if skill>=PBTrainerAI.mediumSkill
        score += 20 if target.effects[PBEffects::MagnetRise]>0
        score += 20 if target.effects[PBEffects::Telekinesis]>0
        score += 20 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                               "TwoTurnAttackInvulnerableInSkyParalyzeTarget")
        score += 20 if target.pbHasType?(:FLYING)
        score += 20 if target.hasActiveAbility?(:LEVITATE)
        score += 20 if target.hasActiveItem?(:AIRBALLOON)
      end
    #---------------------------------------------------------------------------
    when "TargetActsNext"
    #---------------------------------------------------------------------------
    when "TargetActsLast"
    #---------------------------------------------------------------------------
    when "StartSlowerBattlersActFirst"
    #---------------------------------------------------------------------------
    when "UserSwapsPositionsWithAlly"
    #---------------------------------------------------------------------------
    when "UseTargetAttackInsteadOfUserAttack"
    #---------------------------------------------------------------------------
    when "UseTargetDefenseInsteadOfTargetSpDef"
    #---------------------------------------------------------------------------
    when "FailsUnlessTargetSharesTypeWithUser"
      if !target.pbHasType?(user.type1) &&
         !target.pbHasType?(user.type2)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "StartSwapAllBattlersBaseDefensiveStats"
    #---------------------------------------------------------------------------
    when "FailsIfUserHasUnusedMove"
    #---------------------------------------------------------------------------
    when "AllBattlersLoseHalfHPUserSkipsNextTurn"
      score += 20   # Shadow moves are more preferable
      score += 20 if target.hp>=target.totalhp/2
      score -= 20 if user.hp<user.hp/2
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
      if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
         target.pbOwnSide.effects[PBEffects::Reflect]>0 ||
         target.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
         target.pbOwnSide.effects[PBEffects::Safeguard]>0
        score += 30
        score -= 90 if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
                       user.pbOwnSide.effects[PBEffects::Reflect]>0 ||
                       user.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
                       user.pbOwnSide.effects[PBEffects::Safeguard]>0
      else
        score -= 110
      end
    #---------------------------------------------------------------------------
    when "DoesNothingFailsIfNoAlly", "DoesNothingCongratulations"
      score -= 95
      score = 0 if skill>=PBTrainerAI.highSkill
    #---------------------------------------------------------------------------
    when "FreezeTargetSuperEffectiveAgainstWater"
      if target.pbCanFreeze?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
        end
      end
    #---------------------------------------------------------------------------
    when "RaisePlusMinusUserAndAlliesDefSpDef1"
      hasEffect = user.statStageAtMax?(:DEFENSE) &&
                  user.statStageAtMax?(:SPECIAL_DEFENSE)
      user.allAllies.each do |b|
        next if b.statStageAtMax?(:DEFENSE) && b.statStageAtMax?(:SPECIAL_DEFENSE)
        hasEffect = true
        score -= b.stages[:DEFENSE]*10
        score -= b.stages[:SPECIAL_DEFENSE]*10
      end
      if hasEffect
        score -= user.stages[:DEFENSE]*10
        score -= user.stages[:SPECIAL_DEFENSE]*10
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "RaiseTargetSpDef1"
      if target.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= target.stages[:SPECIAL_DEFENSE]*10
      end
    #---------------------------------------------------------------------------
    when "LowerTargetAttack1BypassSubstitute"
      if !target.pbCanLowerStatStage?(:ATTACK,user)
        score -= 90
      else
        score += target.stages[:ATTACK]*20
        if skill>=PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "LowerTargetAtkSpAtk1"
      avg  = target.stages[:ATTACK]*10
      avg += target.stages[:SPECIAL_ATTACK]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"
      if !user.isSpecies?(:HOOPA) || user.form!=1
        score -= 100
      else
        score += 20 if target.stages[:DEFENSE]>0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpAtk2", "LowerTargetSpAtk3"
      if !target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
        score -= 90
      else
        score += 40 if user.turnCount==0
        score += target.stages[:SPECIAL_ATTACK]*20
      end
    #---------------------------------------------------------------------------
    when "RaiseGroundedGrassBattlersAtkSpAtk1"
      count = 0
      @battle.allBattlers.each do |b|
        if b.pbHasType?(:GRASS) && !b.airborne? &&
           (!b.statStageAtMax?(:ATTACK) || !b.statStageAtMax?(:SPECIAL_ATTACK))
          count += 1
          if user.opposes?(b)
            score -= 20
          else
            score -= user.stages[:ATTACK]*10
            score -= user.stages[:SPECIAL_ATTACK]*10
          end
        end
      end
      score -= 95 if count==0
    #---------------------------------------------------------------------------
    when "RaiseGrassBattlersDef1"
      count = 0
      @battle.allBattlers.each do |b|
        if b.pbHasType?(:GRASS) && !b.statStageAtMax?(:DEFENSE)
          count += 1
          if user.opposes?(b)
            score -= 20
          else
            score -= user.stages[:DEFENSE]*10
          end
        end
      end
      score -= 95 if count==0
    #---------------------------------------------------------------------------
    when "LowerPoisonedTargetAtkSpAtkSpd1"
      count=0
      @battle.allBattlers.each do |b|
        if b.poisoned? &&
           (!b.statStageAtMin?(:ATTACK) ||
           !b.statStageAtMin?(:SPECIAL_ATTACK) ||
           !b.statStageAtMin?(:SPEED))
          count += 1
          if user.opposes?(b)
            score += user.stages[:ATTACK]*10
            score += user.stages[:SPECIAL_ATTACK]*10
            score += user.stages[:SPEED]*10
          else
            score -= 20
          end
        end
      end
      score -= 95 if count==0
    #---------------------------------------------------------------------------
    when "InvertTargetStatStages"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      else
        numpos = 0
        numneg = 0
        GameData::Stat.each_battle do |s|
          numpos += target.stages[s.id] if target.stages[s.id] > 0
          numneg += target.stages[s.id] if target.stages[s.id] < 0
        end
        if numpos!=0 || numneg!=0
          score += (numpos-numneg)*10
        else
          score -= 95
        end
      end
    #---------------------------------------------------------------------------
    when "AddGhostTypeToTarget"
      score -= 90 if target.pbHasType?(:GHOST)
    #---------------------------------------------------------------------------
    when "AddGrassTypeToTarget"
      score -= 90 if target.pbHasType?(:GRASS)
    #---------------------------------------------------------------------------
    when "EffectivenessIncludesFlyingType"
    #---------------------------------------------------------------------------
    when "TargetMovesBecomeElectric"
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      score -= 90 if aspeed>ospeed
    #---------------------------------------------------------------------------
    when "NormalMovesBecomeElectric"
    #---------------------------------------------------------------------------
    when "RemoveProtectionsBypassSubstitute"
    #---------------------------------------------------------------------------
    when "TargetNextFireMoveDamagesTarget"
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      if aspeed>ospeed
        score -= 90
      else
        score += 30 if target.pbHasMoveType?(:FIRE)
      end
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromDamagingMovesIfUserFirstTurn"
      if user.turnCount==0
        score += 30
      else
        score -= 90   # Because it will fail here
        score = 0 if skill>=PBTrainerAI.bestSkill
      end
    #---------------------------------------------------------------------------
    when "ProtectUserSideFromStatusMoves"
    #---------------------------------------------------------------------------
    when "ProtectUserFromDamagingMovesKingsShield", "ProtectUserFromTargetingMovesSpikyShield"
      if user.effects[PBEffects::ProtectRate]>1 ||
         target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate]*40
        end
        score += 50 if user.turnCount==0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
    #---------------------------------------------------------------------------
    when "TwoTurnAttackRaiseUserSpAtkSpDefSpd2"
      if user.statStageAtMax?(:SPECIAL_ATTACK) &&
         user.statStageAtMax?(:SPECIAL_DEFENSE) &&
         user.statStageAtMax?(:SPEED)
        score -= 90
      else
        score -= user.stages[:SPECIAL_ATTACK]*10   # Only *10 instead of *20
        score -= user.stages[:SPECIAL_DEFENSE]*10   # because two-turn attack
        score -= user.stages[:SPEED]*10
        if skill>=PBTrainerAI.mediumSkill
          hasSpecialAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecialAttack = true
            break
          end
          if hasSpecialAttack
            score += 20
          elsif skill>=PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill>=PBTrainerAI.highSkill
          aspeed = pbRoughStat(user,:SPEED,skill)
          ospeed = pbRoughStat(target,:SPEED,skill)
          score += 30 if aspeed<ospeed && aspeed*2>ospeed
        end
      end
    #---------------------------------------------------------------------------
    when "HealUserByThreeQuartersOfDamageDone"
      if skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 80
      else
        score += 40 if user.hp<=user.totalhp/2
      end
    #---------------------------------------------------------------------------
    when "RaiseTargetAttack1"
    #---------------------------------------------------------------------------
    when "RaiseTargetAttack1IfKOTarget"
      score += 20 if !user.statStageAtMax?(:ATTACK) && target.hp<=target.totalhp/4
    #---------------------------------------------------------------------------
    when "LowerTargetAtkSpAtk1SwitchOutUser"
      avg  = target.stages[:ATTACK]*10
      avg += target.stages[:SPECIAL_ATTACK]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "TrapAllBattlersInBattleForOneTurn"
    #---------------------------------------------------------------------------
    when "AddStickyWebToFoeSide"
      score -= 95 if user.pbOpposingSide.effects[PBEffects::StickyWeb]
    #---------------------------------------------------------------------------
    when "StartElectricTerrain"
    #---------------------------------------------------------------------------
    when "StartGrassyTerrain"
    #---------------------------------------------------------------------------
    when "StartMistyTerrain"
    #---------------------------------------------------------------------------
    when "DoubleMoneyGainedFromBattle"
      score -= 90
    #---------------------------------------------------------------------------
    when "FailsIfUserNotConsumedBerry"
      score -= 90 if !user.belched?
    #---------------------------------------------------------------------------
    when "PoisonTargetLowerTargetSpeed1"
      if !target.pbCanPoison?(user,false) && !target.pbCanLowerStatStage?(:SPEED,user)
        score -= 90
      else
        if target.pbCanPoison?(user,false)
          score += 30
          if skill>=PBTrainerAI.mediumSkill
            score += 30 if target.hp<=target.totalhp/4
            score += 50 if target.hp<=target.totalhp/8
            score -= 40 if target.effects[PBEffects::Yawn]>0
          end
          if skill>=PBTrainerAI.highSkill
            score += 10 if pbRoughStat(target,:DEFENSE,skill)>100
            score += 10 if pbRoughStat(target,:SPECIAL_DEFENSE,skill)>100
            score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:TOXICBOOST])
          end
        end
        if target.pbCanLowerStatStage?(:SPEED,user)
          score += target.stages[:SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,:SPEED,skill)
            ospeed = pbRoughStat(target,:SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      end
    #---------------------------------------------------------------------------
    when "CureTargetBurn"
      if target.opposes?(user)
        score -= 40 if target.status == :BURN
      else
        score += 40 if target.status == :BURN
      end
    #---------------------------------------------------------------------------
    when "CureTargetStatusHealUserHalfOfTotalHP"
      if target.status == :NONE
        score -= 90
      elsif user.hp==user.totalhp && target.opposes?(user)
        score -= 90
      else
        score += (user.totalhp-user.hp)*50/user.totalhp
        score -= 30 if target.opposes?(user)
      end
    #---------------------------------------------------------------------------
    when "RaisePlusMinusUserAndAlliesAtkSpAtk1"
      hasEffect = user.statStageAtMax?(:ATTACK) &&
                  user.statStageAtMax?(:SPECIAL_ATTACK)
      user.allAllies.each do |b|
        next if b.statStageAtMax?(:ATTACK) && b.statStageAtMax?(:SPECIAL_ATTACK)
        hasEffect = true
        score -= b.stages[:ATTACK]*10
        score -= b.stages[:SPECIAL_ATTACK]*10
      end
      if hasEffect
        score -= user.stages[:ATTACK]*10
        score -= user.stages[:SPECIAL_ATTACK]*10
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "UserStealTargetPositiveStatStages"
      numStages = 0
      GameData::Stat.each_battle do |s|
        next if target.stages[s.id] <= 0
        numStages += target.stages[s.id]
      end
      score += numStages*20
    #---------------------------------------------------------------------------
    when "EnsureNextCriticalHit"
      if user.effects[PBEffects::LaserFocus]>0
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "LowerUserAttack1", "LowerUserAttack2"
      score += user.stages[:ATTACK] * 10
    #---------------------------------------------------------------------------
    when "LowerUserDefense1", "LowerUserDefense2"
      score += user.stages[:DEFENSE]*10
    #---------------------------------------------------------------------------
    when "HealUserByTargetAttackLowerTargetAttack1"
      if target.statStageAtMin?(:ATTACK)
        score -= 90
      else
        if target.pbCanLowerStatStage?(:ATTACK,user)
          score += target.stages[:ATTACK]*20
          if skill>=PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            target.eachMove do |m|
              next if !m.physicalMove?(m.type)
              hasPhysicalAttack = true
              break
            end
            if hasPhysicalAttack
              score += 20
            elsif skill>=PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
        score += (user.totalhp-user.hp)*50/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapBaseSpeed"
      if skill>=PBTrainerAI.mediumSkill
        if user.speed>target.speed
          score += 50
        else
          score -= 70
        end
      end
    #---------------------------------------------------------------------------
    when "UserLosesFireType"
      score -= 90 if !user.pbHasType?(:FIRE)
    #---------------------------------------------------------------------------
    when "IgnoreTargetAbility"
    #---------------------------------------------------------------------------
    when "CategoryDependsOnHigherDamageIgnoreTargetAbility"
    #---------------------------------------------------------------------------
    when "NegateTargetAbilityIfTargetActed"
      if skill>=PBTrainerAI.mediumSkill
         userSpeed   = pbRoughStat(user,:SPEED,skill)
         targetSpeed = pbRoughStat(target,:SPEED,skill)
        if userSpeed<targetSpeed
          score += 30
        end
      else
        score += 30
      end
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserLastMoveFailed"
    #---------------------------------------------------------------------------
    when "StartWeakenDamageAgainstUserSideIfHail"
      if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0 || user.effectiveWeather != :Hail
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "ProtectUserBanefulBunker"
      if user.effects[PBEffects::ProtectRate]>1 ||
         target.effects[PBEffects::HyperBeam]>0
        score -= 90
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate]*40
        end
        score += 50 if user.turnCount==0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
        score += 20   # Because of possible poisoning
      end
    #---------------------------------------------------------------------------
    when "TypeIsUserFirstType"
    #---------------------------------------------------------------------------
    when "RedirectAllMovesToTarget"
      score -= 90 if user.allAllies.length == 0
    #---------------------------------------------------------------------------
    when "TargetUsesItsLastUsedMoveAgain"
      if skill>=PBTrainerAI.mediumSkill
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
    when "DisableTargetSoundMoves"
      if target.effects[PBEffects::ThroatChop]==0 && skill>=PBTrainerAI.highSkill
        hasSoundMove = false
        user.eachMove do |m|
          next if !m.soundMove?
          hasSoundMove = true
          break
        end
        score += 40 if hasSoundMove
      end
    #---------------------------------------------------------------------------
    when "HealUserDependingOnSandstorm"
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp*100/user.totalhp
        score += 30 if user.effectiveWeather == :Sandstorm
      end
    #---------------------------------------------------------------------------
    when "HealTargetDependingOnGrassyTerrain"
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp*100/user.totalhp
        if skill>=PBTrainerAI.mediumSkill
          score += 30 if @battle.field.terrain == :Grassy
        end
      end
    #---------------------------------------------------------------------------
    when "HealAllyOrDamageFoe"
      if !target.opposes?(user)
        if target.hp==target.totalhp || (skill>=PBTrainerAI.mediumSkill && !target.canHeal?)
          score -= 90
        else
          score += 50
          score -= target.hp*100/target.totalhp
        end
      end
    #---------------------------------------------------------------------------
    when "UserLosesHalfOfTotalHPExplosive"
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif skill>=PBTrainerAI.mediumSkill && reserves==0 && foes>0
        score -= 100   # don't want to lose
      elsif skill>=PBTrainerAI.highSkill && reserves==0 && foes==0
        score += 80   # want to draw
      else
        score -= (user.totalhp-user.hp)*75/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "UsedAfterUserTakesPhysicalDamage"
      if skill>=PBTrainerAI.mediumSkill
        hasPhysicalAttack = false
        target.eachMove do |m|
          next if !m.physicalMove?(m.type)
          hasPhysicalAttack = true
          break
        end
        score -= 80 if !hasPhysicalAttack
      end
    #---------------------------------------------------------------------------
    when "BurnAttackerBeforeUserActs"
      score += 20   # Because of possible burning
    #---------------------------------------------------------------------------
    when "StartPsychicTerrain"
    #---------------------------------------------------------------------------
    when "FailsIfNotUserFirstTurn"
      score -= 90 if user.turnCount > 0
    #---------------------------------------------------------------------------
    when "HitTwoTimesFlinchTarget"
      score += 30 if target.effects[PBEffects::Minimize]
    #---------------------------------------------------------------------------
    when "CategoryDependsOnHigherDamagePoisonTarget"
      score += 5 if target.pbCanPoison?(user, false)
    #---------------------------------------------------------------------------
    when "BurnTargetIfTargetStatsRaisedThisTurn"
      if target.pbCanBurn?(user, false)
        score += 40
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :FLAREBOOST])
        end
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "TypeDependsOnUserMorpekoFormRaiseUserSpeed1"
      score += 20 if user.stages[:SPEED] <= 0
    #---------------------------------------------------------------------------
    when "RaiseUserMainStats1TrapUserInBattle"
      if user.effects[PBEffects::NoRetreat]
        score -= 100
      elsif user.hasActiveAbility?(:CONTRARY)
        score -= 100
      else
        stats_maxed = true
        GameData::Stat.each_main_battle do |s|
          next if user.statStageAtMax?(s.id)
          stats_maxed = false
          break
        end
        if stats_maxed
          score -= 100
        else
          if skill >= PBTrainerAI.highSkill
            score -= 50 if user.hp <= user.totalhp / 2
            score += 30 if user.trappedInBattle?
          end
          GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] <= 0 }
          if skill >= PBTrainerAI.mediumSkill
            hasDamagingAttack = user.moves.any? { |m| next m && m.damagingMove? }
            score += 20 if hasDamagingAttack
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserMainStats1LoseThirdOfTotalHP"
      if user.hp <= user.totalhp / 2
        score -= 100
      elsif user.hasActiveAbility?(:CONTRARY)
        score -= 100
      else
        stats_maxed = true
        GameData::Stat.each_main_battle do |s|
          next if user.statStageAtMax?(s.id)
          stats_maxed = false
          break
        end
        if stats_maxed
          score -= 100
        else
          if skill >= PBTrainerAI.highSkill && user.hp >= user.totalhp * 0.75
            score += 30
          end
          GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] <= 0 }
          if skill >= PBTrainerAI.mediumSkill
            hasDamagingAttack = user.moves.any? { |m| next m && m.damagingMove? }
            score += 20 if hasDamagingAttack
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAndAlliesAtkDef1"
      has_ally = false
      user.allAllies.each do |b|
        next if !b.pbCanLowerStatStage?(:ATTACK, user) &&
                !b.pbCanLowerStatStage?(:SPECIAL_ATTACK, user)
        has_ally = true
        if skill >= PBTrainerAI.mediumSkill && b.hasActiveAbility?(:CONTRARY)
          score -= 90
        else
          score += 40
          score -= b.stages[:ATTACK] * 20
          score -= b.stages[:SPECIAL_ATTACK] * 20
        end
      end
      score = 0 if !has_ally
    #---------------------------------------------------------------------------
    when "RaiseTargetAtkSpAtk2"
      if target.opposes?(user)
        score -= 100
      elsif skill >= PBTrainerAI.mediumSkill && target.hasActiveAbility?(:CONTRARY)
        score -= 90
      else
        score -= target.stages[:ATTACK] * 20
        score -= target.stages[:SPECIAL_ATTACK] * 20
      end
    #---------------------------------------------------------------------------
    when "LowerTargetDefense1DoublePowerInGravity"
      if !target.pbCanLowerStatStage?(:DEFENSE, user)
        score -= 90
      else
        score += 20
        score += target.stages[:DEFENSE] * 20
      end
      score += 30 if @battle.field.effects[PBEffects::Gravity] > 0
    #---------------------------------------------------------------------------
    when "LowerTargetSpeed1MakeTargetWeakerToFire"
      if !target.pbCanLowerStatStage?(:SPEED, user) && target.effects[PBEffects::TarShot]
        score -= 100
      else
        score += target.stages[:SPEED] * 10
        if skill >= PBTrainerAI.highSkill
          aspeed = pbRoughStat(user, :SPEED, skill)
          ospeed = pbRoughStat(target, :SPEED, skill)
          score += 50 if aspeed < ospeed && aspeed * 2 > ospeed
        end
      end
      score += 20 if user.moves.any? { |m| m.damagingMove? && m.pbCalcType(user) == :FIRE }
    #---------------------------------------------------------------------------
    when "SetTargetTypesToPsychic"
      if target.pbHasOtherType?(:PSYCHIC)
        score -= 90
      elsif !target.canChangeType?
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "DoublePowerInElectricTerrain"
      score += 40 if @battle.field.terrain == :Electric && target.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "HitsAllFoesAndPowersUpInPsychicTerrain"
      score += 40 if @battle.field.terrain == :Psychic && user.affectedByTerrain?
    #---------------------------------------------------------------------------
    when "TypeAndPowerDependOnTerrain"
      score += 40 if @battle.field.terrain != :None
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetNotActed"
    #---------------------------------------------------------------------------
    when "DoublePowerIfUserStatsLoweredThisTurn"
    #---------------------------------------------------------------------------
    when "HigherPriorityInGrassyTerrain"
      if skill >= PBTrainerAI.mediumSkill && @battle.field.terrain == :Grassy
        aspeed = pbRoughStat(user, :SPEED, skill)
        ospeed = pbRoughStat(target, :SPEED, skill)
        score += 40 if aspeed < ospeed
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
    when "HitTwoTimesTargetThenTargetAlly"
    #---------------------------------------------------------------------------
    when "HitThreeTimesAlwaysCriticalHit"
      if skill >= PBTrainerAI.highSkill
        stat = (move.physicalMove?)? :DEFENSE : :SPECIAL_DEFENSE
        score += 50 if targets.stages[stat] > 1
      end
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
    when "UserLosesHalfOfTotalHP"
      score -= 100 if user.hp <= user.totalhp / 2
    #---------------------------------------------------------------------------
    when "LowerPPOfTargetLastMoveBy3"
      last_move = target.pbGetMoveWithID(target.lastRegularMoveUsed)
      if last_move && last_move.total_pp > 0 && last_move.pp <= 3
        score += 50
      end
    #---------------------------------------------------------------------------
    when "FailsIfTargetHasNoItem"
      if skill >= PBTrainerAI.mediumSkill
        if !target.item || !target.itemActive?
          score -= 90
        else
          score += 50
        end
      end
    #---------------------------------------------------------------------------
    when "UseUserBaseDefenseInsteadOfUserBaseAttack"
    #---------------------------------------------------------------------------
    when "SwapSideEffects"
      if skill >= PBTrainerAI.mediumSkill
        good_effects = [:Reflect, :LightScreen, :AuroraVeil, :SeaOfFire,
                        :Swamp, :Rainbow, :Mist, :Safeguard,
                        :Tailwind].map! { |e| PBEffects.const_get(e) }
        bad_effects = [:Spikes, :StickyWeb, :ToxicSpikes, :StealthRock].map! { |e| PBEffects.const_get(e) }
        bad_effects.each do |e|
          score += 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
          score -= 10 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
        end
        if skill >= PBTrainerAI.highSkill
          good_effects.each do |e|
            score += 10 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
            score -= 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RemoveTerrain"
      score -= 100 if @battle.field.terrain == :None
    #---------------------------------------------------------------------------
    end
    return score
  end
end
