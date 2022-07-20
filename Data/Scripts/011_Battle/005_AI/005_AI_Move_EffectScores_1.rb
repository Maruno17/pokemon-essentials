class Battle::AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    case move.function
    #---------------------------------------------------------------------------
    when "Struggle"
    #---------------------------------------------------------------------------
    when "None"   # No extra effect
    #---------------------------------------------------------------------------
    when "DoesNothingCongratulations", "DoesNothingFailsIfNoAlly",
         "DoesNothingUnusableInGravity"
      score -= 95
      score = 0 if skill >= PBTrainerAI.highSkill
    #---------------------------------------------------------------------------
    when "AddMoneyGainedFromBattle"
    #---------------------------------------------------------------------------
    when "DoubleMoneyGainedFromBattle"
      score -= 90
    #---------------------------------------------------------------------------
    when "FailsIfNotUserFirstTurn"
      score -= 90 if user.turnCount > 0
    #---------------------------------------------------------------------------
    when "FailsIfUserHasUnusedMove"
    #---------------------------------------------------------------------------
    when "FailsIfUserNotConsumedBerry"
      score -= 90 if !user.belched?
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
    when "FailsUnlessTargetSharesTypeWithUser"
      if !(user.types[0] && target.pbHasType?(user.types[0])) &&
         !(user.types[1] && target.pbHasType?(user.types[1]))
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "FailsIfUserDamagedThisTurn"
      score += 50 if target.effects[PBEffects::HyperBeam] > 0
      score -= 35 if target.hp <= target.totalhp / 2   # If target is weak, no
      score -= 70 if target.hp <= target.totalhp / 4   # need to risk this move
    #---------------------------------------------------------------------------
    when "FailsIfTargetActed"
    #---------------------------------------------------------------------------
    when "CrashDamageIfFailsUnusableInGravity"
      score += 10 * (user.stages[:ACCURACY] - target.stages[:EVASION])
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
    when "StartElectricTerrain"
    #---------------------------------------------------------------------------
    when "StartGrassyTerrain"
    #---------------------------------------------------------------------------
    when "StartMistyTerrain"
    #---------------------------------------------------------------------------
    when "StartPsychicTerrain"
    #---------------------------------------------------------------------------
    when "RemoveTerrain"
      score -= 100 if @battle.field.terrain == :None
    #---------------------------------------------------------------------------
    when "AddSpikesToFoeSide"
      if user.pbOpposingSide.effects[PBEffects::Spikes] >= 3
        score -= 90
      elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
        score -= 90   # Opponent can't switch in any Pokemon
      else
        score += 10 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
        score += [40, 26, 13][user.pbOpposingSide.effects[PBEffects::Spikes]]
      end
    #---------------------------------------------------------------------------
    when "AddToxicSpikesToFoeSide"
      if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2
        score -= 90
      elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
        score -= 90  # Opponent can't switch in any Pokemon
      else
        score += 8 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
        score += [26, 13][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
      end
    #---------------------------------------------------------------------------
    when "AddStealthRocksToFoeSide"
      if user.pbOpposingSide.effects[PBEffects::StealthRock]
        score -= 90
      elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
        score -= 90   # Opponent can't switch in any Pokemon
      else
        score += 10 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      end
    #---------------------------------------------------------------------------
    when "AddStickyWebToFoeSide"
      score -= 95 if user.pbOpposingSide.effects[PBEffects::StickyWeb]
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
    when "UserMakeSubstitute"
      if user.effects[PBEffects::Substitute] > 0
        score -= 90
      elsif user.hp <= user.totalhp / 4
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "RemoveUserBindingAndEntryHazards"
      score += 30 if user.effects[PBEffects::Trapping] > 0
      score += 30 if user.effects[PBEffects::LeechSeed] >= 0
      if @battle.pbAbleNonActiveCount(user.idxOwnSide) > 0
        score += 80 if user.pbOwnSide.effects[PBEffects::Spikes] > 0
        score += 80 if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
        score += 80 if user.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "AttackTwoTurnsLater"
      if @battle.positions[target.index].effects[PBEffects::FutureSightCounter] > 0
        score -= 100
      elsif @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
        # Future Sight tends to be wasteful if down to last Pokemon
        score -= 70
      end
    #---------------------------------------------------------------------------
    when "UserSwapsPositionsWithAlly"
    #---------------------------------------------------------------------------
    when "BurnAttackerBeforeUserActs"
      score += 20   # Because of possible burning
    #---------------------------------------------------------------------------
    when "RaiseUserAttack1"
      if move.statusMove?
        if user.statStageAtMax?(:ATTACK)
          score -= 90
        else
          score -= user.stages[:ATTACK] * 20
          if skill >= PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            user.eachMove do |m|
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
      else
        score += 20 if user.stages[:ATTACK] < 0
        if skill >= PBTrainerAI.mediumSkill
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
    when "RaiseUserAttack2", "RaiseUserAttack2IfTargetFaints",
         "RaiseUserAttack3", "RaiseUserAttack3IfTargetFaints"
      if move.statusMove?
        if user.statStageAtMax?(:ATTACK)
          score -= 90
        else
          score += 40 if user.turnCount == 0
          score -= user.stages[:ATTACK] * 20
          if skill >= PBTrainerAI.mediumSkill
            hasPhysicalAttack = false
            user.eachMove do |m|
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
      else
        score += 10 if user.turnCount == 0
        score += 20 if user.stages[:ATTACK] < 0
        if skill >= PBTrainerAI.mediumSkill
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
    when "MaxUserAttackLoseHalfOfTotalHP"
      if user.statStageAtMax?(:ATTACK) ||
         user.hp <= user.totalhp / 2
        score -= 100
      else
        score += (6 - user.stages[:ATTACK]) * 10
        if skill >= PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 40
          elsif skill >= PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserDefense1", "RaiseUserDefense1CurlUpUser"
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
    when "RaiseUserDefense2"
      if move.statusMove?
        if user.statStageAtMax?(:DEFENSE)
          score -= 90
        else
          score += 40 if user.turnCount == 0
          score -= user.stages[:DEFENSE] * 20
        end
      else
        score += 10 if user.turnCount == 0
        score += 20 if user.stages[:DEFENSE] < 0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserDefense3"
      if move.statusMove?
        if user.statStageAtMax?(:DEFENSE)
          score -= 90
        else
          score += 40 if user.turnCount == 0
          score -= user.stages[:DEFENSE] * 30
        end
      else
        score += 10 if user.turnCount == 0
        score += 30 if user.stages[:DEFENSE] < 0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtk1"
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_ATTACK)
          score -= 90
        else
          score -= user.stages[:SPECIAL_ATTACK] * 20
          if skill >= PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            user.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill >= PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 20 if user.stages[:SPECIAL_ATTACK] < 0
        if skill >= PBTrainerAI.mediumSkill
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
    when "RaiseUserSpAtk2"
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_ATTACK)
          score -= 90
        else
          score += 40 if user.turnCount == 0
          score -= user.stages[:SPECIAL_ATTACK] * 20
          if skill >= PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            user.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill >= PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount == 0
        score += 20 if user.stages[:SPECIAL_ATTACK] < 0
        if skill >= PBTrainerAI.mediumSkill
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
    when "RaiseUserSpAtk3"
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_ATTACK)
          score -= 90
        else
          score += 40 if user.turnCount == 0
          score -= user.stages[:SPECIAL_ATTACK] * 30
          if skill >= PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            user.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill >= PBTrainerAI.highSkill
              score -= 90
            end
          end
        end
      else
        score += 10 if user.turnCount == 0
        score += 30 if user.stages[:SPECIAL_ATTACK] < 0
        if skill >= PBTrainerAI.mediumSkill
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
    when "RaiseUserSpDef1", "RaiseUserSpDef2", "RaiseUserSpDef3"
      if move.statusMove?
        if user.statStageAtMax?(:SPECIAL_DEFENSE)
          score -= 90
        else
          score += 40 if user.turnCount == 0
          score -= user.stages[:SPECIAL_DEFENSE] * 20
        end
      else
        score += 10 if user.turnCount == 0
        score += 20 if user.stages[:SPECIAL_DEFENSE] < 0
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
          score -= user.stages[:SPECIAL_DEFENSE] * 20
        end
      elsif user.stages[:SPECIAL_DEFENSE] < 0
        score += 20
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpeed1"
      if move.statusMove?
        if user.statStageAtMax?(:SPEED)
          score -= 90
        else
          score -= user.stages[:SPEED] * 10
          if skill >= PBTrainerAI.highSkill
            aspeed = pbRoughStat(user, :SPEED, skill)
            ospeed = pbRoughStat(target, :SPEED, skill)
            score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
          end
        end
      elsif user.stages[:SPEED] < 0
        score += 20
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpeed2", "RaiseUserSpeed2LowerUserWeight", "RaiseUserSpeed3"
      if move.statusMove?
        if user.statStageAtMax?(:SPEED)
          score -= 90
        else
          score += 20 if user.turnCount == 0
          score -= user.stages[:SPEED] * 10
          if skill >= PBTrainerAI.highSkill
            aspeed = pbRoughStat(user, :SPEED, skill)
            ospeed = pbRoughStat(target, :SPEED, skill)
            score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
          end
        end
      else
        score += 10 if user.turnCount == 0
        score += 20 if user.stages[:SPEED] < 0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAccuracy1", "RaiseUserAccuracy2", "RaiseUserAccuracy3"
      if move.statusMove?
        if user.statStageAtMax?(:ACCURACY)
          score -= 90
        else
          score += 40 if user.turnCount == 0
          score -= user.stages[:ACCURACY] * 20
        end
      else
        score += 10 if user.turnCount == 0
        score += 20 if user.stages[:ACCURACY] < 0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserEvasion1"
      if move.statusMove?
        if user.statStageAtMax?(:EVASION)
          score -= 90
        else
          score -= user.stages[:EVASION] * 10
        end
      elsif user.stages[:EVASION] < 0
        score += 20
      end
    #---------------------------------------------------------------------------
    when "RaiseUserEvasion2", "RaiseUserEvasion2MinimizeUser", "RaiseUserEvasion3"
      if move.statusMove?
        if user.statStageAtMax?(:EVASION)
          score -= 90
        else
          score += 40 if user.turnCount == 0
          score -= user.stages[:EVASION] * 10
        end
      else
        score += 10 if user.turnCount == 0
        score += 20 if user.stages[:EVASION] < 0
      end
    #---------------------------------------------------------------------------
    when "RaiseUserCriticalHitRate2"
      if move.statusMove?
        if user.effects[PBEffects::FocusEnergy] >= 2
          score -= 80
        else
          score += 30
        end
      elsif user.effects[PBEffects::FocusEnergy] < 2
        score += 30
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtkDef1"
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:DEFENSE)
        score -= 90
      else
        score -= user.stages[:ATTACK] * 10
        score -= user.stages[:DEFENSE] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
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
    #---------------------------------------------------------------------------
    when "RaiseUserAtkDefAcc1"
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:DEFENSE) &&
         user.statStageAtMax?(:ACCURACY)
        score -= 90
      else
        score -= user.stages[:ATTACK] * 10
        score -= user.stages[:DEFENSE] * 10
        score -= user.stages[:ACCURACY] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
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
    #---------------------------------------------------------------------------
    when "RaiseUserAtkSpAtk1", "RaiseUserAtkSpAtk1Or2InSun"
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:SPECIAL_ATTACK)
        score -= 90
      else
        score -= user.stages[:ATTACK] * 10
        score -= user.stages[:SPECIAL_ATTACK] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasDamagingAttack = false
          user.eachMove do |m|
            next if !m.damagingMove?
            hasDamagingAttack = true
            break
          end
          if hasDamagingAttack
            score += 20
          elsif skill >= PBTrainerAI.highSkill
            score -= 90
          end
        end
        if move.function == "RaiseUserAtkSpAtk1Or2InSun"   # Growth
          score += 20 if [:Sun, :HarshSun].include?(user.effectiveWeather)
        end
      end
    #---------------------------------------------------------------------------
    when "LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2"
      score -= user.stages[:ATTACK] * 20
      score -= user.stages[:SPEED] * 20
      score -= user.stages[:SPECIAL_ATTACK] * 20
      score += user.stages[:DEFENSE] * 10
      score += user.stages[:SPECIAL_DEFENSE] * 10
      if skill >= PBTrainerAI.mediumSkill
        hasDamagingAttack = false
        user.eachMove do |m|
          next if !m.damagingMove?
          hasDamagingAttack = true
          break
        end
        score += 20 if hasDamagingAttack
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtkSpd1"
      score += 40 if user.turnCount == 0   # Dragon Dance tends to be popular
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:SPEED)
        score -= 90
      else
        score -= user.stages[:ATTACK] * 10
        score -= user.stages[:SPEED] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
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
        if skill >= PBTrainerAI.highSkill
          aspeed = pbRoughStat(user, :SPEED, skill)
          ospeed = pbRoughStat(target, :SPEED, skill)
          score += 20 if aspeed < ospeed && aspeed * 2 > ospeed
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtk1Spd2"
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:SPEED)
        score -= 90
      else
        score -= user.stages[:ATTACK] * 10
        score -= user.stages[:SPEED] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
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
        if skill >= PBTrainerAI.highSkill
          aspeed = pbRoughStat(user, :SPEED, skill)
          ospeed = pbRoughStat(target, :SPEED, skill)
          score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtkAcc1"
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:ACCURACY)
        score -= 90
      else
        score -= user.stages[:ATTACK] * 10
        score -= user.stages[:ACCURACY] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
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
    #---------------------------------------------------------------------------
    when "RaiseUserDefSpDef1"
      if user.statStageAtMax?(:DEFENSE) &&
         user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= user.stages[:DEFENSE] * 10
        score -= user.stages[:SPECIAL_DEFENSE] * 10
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtkSpDef1"
      if user.statStageAtMax?(:SPECIAL_ATTACK) &&
         user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score += 40 if user.turnCount == 0   # Calm Mind tends to be popular
        score -= user.stages[:SPECIAL_ATTACK] * 10
        score -= user.stages[:SPECIAL_DEFENSE] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          if hasSpecicalAttack
            score += 20
          elsif skill >= PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtkSpDefSpd1"
      if user.statStageAtMax?(:SPEED) &&
         user.statStageAtMax?(:SPECIAL_ATTACK) &&
         user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= user.stages[:SPECIAL_ATTACK] * 10
        score -= user.stages[:SPECIAL_DEFENSE] * 10
        score -= user.stages[:SPEED] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          if hasSpecicalAttack
            score += 20
          elsif skill >= PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill >= PBTrainerAI.highSkill
          aspeed = pbRoughStat(user, :SPEED, skill)
          ospeed = pbRoughStat(target, :SPEED, skill)
          if aspeed < ospeed && aspeed * 2 > ospeed
            score += 20
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserMainStats1"
      GameData::Stat.each_main_battle { |s| score += 10 if user.stages[s.id] < 0 }
      if skill >= PBTrainerAI.mediumSkill
        hasDamagingAttack = false
        user.eachMove do |m|
          next if !m.damagingMove?
          hasDamagingAttack = true
          break
        end
        score += 20 if hasDamagingAttack
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
            hasDamagingAttack = user.moves.any? { |m| next m&.damagingMove? }
            score += 20 if hasDamagingAttack
          end
        end
      end
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
            hasDamagingAttack = user.moves.any? { |m| next m&.damagingMove? }
            score += 20 if hasDamagingAttack
          end
        end
      end
    #---------------------------------------------------------------------------
    when "StartRaiseUserAtk1WhenDamaged"
      score += 25 if user.effects[PBEffects::Rage]
    #---------------------------------------------------------------------------
    when "LowerUserAttack1", "LowerUserAttack2"
      score += user.stages[:ATTACK] * 10
    #---------------------------------------------------------------------------
    when "LowerUserDefense1", "LowerUserDefense2"
      score += user.stages[:DEFENSE] * 10
    #---------------------------------------------------------------------------
    when "LowerUserSpAtk1", "LowerUserSpAtk2"
      score += user.stages[:SPECIAL_ATTACK] * 10
    #---------------------------------------------------------------------------
    when "LowerUserSpDef1", "LowerUserSpDef2"
      score += user.stages[:SPECIAL_DEFENSE] * 10
    #---------------------------------------------------------------------------
    when "LowerUserSpeed1", "LowerUserSpeed2"
      score += user.stages[:SPEED] * 10
    #---------------------------------------------------------------------------
    when "LowerUserAtkDef1"
      avg =  user.stages[:ATTACK] * 10
      avg += user.stages[:DEFENSE] * 10
      score += avg / 2
    #---------------------------------------------------------------------------
    when "LowerUserDefSpDef1"
      avg =  user.stages[:DEFENSE] * 10
      avg += user.stages[:SPECIAL_DEFENSE] * 10
      score += avg / 2
    #---------------------------------------------------------------------------
    when "LowerUserDefSpDefSpd1"
      avg =  user.stages[:DEFENSE] * 10
      avg += user.stages[:SPEED] * 10
      avg += user.stages[:SPECIAL_DEFENSE] * 10
      score += (avg / 3).floor
    #---------------------------------------------------------------------------
    when "RaiseTargetAttack1"
    #---------------------------------------------------------------------------
    when "RaiseTargetAttack2ConfuseTarget"
      if !target.pbCanConfuse?(user, false)
        score -= 90
      elsif target.stages[:ATTACK] < 0
        score += 30
      end
    #---------------------------------------------------------------------------
    when "RaiseTargetSpAtk1ConfuseTarget"
      if !target.pbCanConfuse?(user, false)
        score -= 90
      elsif target.stages[:SPECIAL_ATTACK] < 0
        score += 30
      end
    #---------------------------------------------------------------------------
    when "RaiseTargetSpDef1"
      if target.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= target.stages[:SPECIAL_DEFENSE] * 10
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
        avgStat = avgStat / 2 if avgStat < 0   # More chance of getting even better
        score += avgStat * 10
      else
        score -= 90
      end
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
    when "LowerTargetAttack1"
      if move.statusMove?
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
        else
          score -= 90
        end
      else
        score += 20 if target.stages[:ATTACK] > 0
        if skill >= PBTrainerAI.mediumSkill
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
    when "LowerTargetAttack1BypassSubstitute"
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
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "LowerTargetAttack2", "LowerTargetAttack3"
      if move.statusMove?
        if target.pbCanLowerStatStage?(:ATTACK, user)
          score += 40 if user.turnCount == 0
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
        else
          score -= 90
        end
      else
        score += 10 if user.turnCount == 0
        score += 20 if target.stages[:ATTACK] > 0
        if skill >= PBTrainerAI.mediumSkill
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
        if target.pbCanLowerStatStage?(:DEFENSE, user)
          score += target.stages[:DEFENSE] * 20
        else
          score -= 90
        end
      elsif target.stages[:DEFENSE] > 0
        score += 20
      end
    #---------------------------------------------------------------------------
    when "LowerTargetDefense1PowersUpInGravity"
      if target.pbCanLowerStatStage?(:DEFENSE, user)
        score += 20
        score += target.stages[:DEFENSE] * 20
      else
        score -= 90
      end
      score += 30 if @battle.field.effects[PBEffects::Gravity] > 0
    #---------------------------------------------------------------------------
    when "LowerTargetDefense2", "LowerTargetDefense3"
      if move.statusMove?
        if target.pbCanLowerStatStage?(:DEFENSE, user)
          score += 40 if user.turnCount == 0
          score += target.stages[:DEFENSE] * 20
        else
          score -= 90
        end
      else
        score += 10 if user.turnCount == 0
        score += 20 if target.stages[:DEFENSE] > 0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpAtk1"
      if move.statusMove?
        if target.pbCanLowerStatStage?(:SPECIAL_ATTACK, user)
          score += user.stages[:SPECIAL_ATTACK] * 20
          if skill >= PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            target.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill >= PBTrainerAI.highSkill
              score -= 90
            end
          end
        else
          score -= 90
        end
      else
        score += 20 if user.stages[:SPECIAL_ATTACK] > 0
        if skill >= PBTrainerAI.mediumSkill
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
    when "LowerTargetSpAtk2"
      if target.pbCanLowerStatStage?(:SPECIAL_ATTACK, user)
        score += 40 if user.turnCount == 0
        score += target.stages[:SPECIAL_ATTACK] * 20
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpAtk2IfCanAttract"
      if user.gender == 2 || target.gender == 2 || user.gender == target.gender ||
         target.hasActiveAbility?(:OBLIVIOUS)
        score -= 90
      elsif move.statusMove?
        if target.pbCanLowerStatStage?(:SPECIAL_ATTACK, user)
          score += 40 if user.turnCount == 0
          score += target.stages[:SPECIAL_ATTACK] * 20
          if skill >= PBTrainerAI.mediumSkill
            hasSpecicalAttack = false
            target.eachMove do |m|
              next if !m.specialMove?(m.type)
              hasSpecicalAttack = true
              break
            end
            if hasSpecicalAttack
              score += 20
            elsif skill >= PBTrainerAI.highSkill
              score -= 90
            end
          end
        else
          score -= 90
        end
      else
        score += 10 if user.turnCount == 0
        score += 20 if target.stages[:SPECIAL_ATTACK] > 0
        if skill >= PBTrainerAI.mediumSkill
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
    when "LowerTargetSpAtk3"
      if target.pbCanLowerStatStage?(:SPECIAL_ATTACK, user)
        score += 40 if user.turnCount == 0
        score += target.stages[:SPECIAL_ATTACK] * 20
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpDef1"
      if move.statusMove?
        if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user)
          score += target.stages[:SPECIAL_DEFENSE] * 20
        else
          score -= 90
        end
      elsif target.stages[:SPECIAL_DEFENSE] > 0
        score += 20
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpDef2", "LowerTargetSpDef3"
      if move.statusMove?
        if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user)
          score += 40 if user.turnCount == 0
          score += target.stages[:SPECIAL_DEFENSE] * 20
        else
          score -= 90
        end
      else
        score += 10 if user.turnCount == 0
        score += 20 if target.stages[:SPECIAL_DEFENSE] > 0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetSpeed1", "LowerTargetSpeed1WeakerInGrassyTerrain"
      if move.statusMove?
        if target.pbCanLowerStatStage?(:SPEED, user)
          score += target.stages[:SPEED] * 10
          if skill >= PBTrainerAI.highSkill
            aspeed = pbRoughStat(user, :SPEED, skill)
            ospeed = pbRoughStat(target, :SPEED, skill)
            score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
          end
        else
          score -= 90
        end
      elsif user.stages[:SPEED] > 0
        score += 20
      end
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
    when "LowerTargetSpeed2", "LowerTargetSpeed3"
      if move.statusMove?
        if target.pbCanLowerStatStage?(:SPEED, user)
          score += 20 if user.turnCount == 0
          score += target.stages[:SPEED] * 20
          if skill >= PBTrainerAI.highSkill
            aspeed = pbRoughStat(user, :SPEED, skill)
            ospeed = pbRoughStat(target, :SPEED, skill)
            score += 30 if aspeed < ospeed && aspeed * 2 > ospeed
          end
        else
          score -= 90
        end
      else
        score += 10 if user.turnCount == 0
        score += 30 if target.stages[:SPEED] > 0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetAccuracy1", "LowerTargetAccuracy2", "LowerTargetAccuracy3"
      if move.statusMove?
        if target.pbCanLowerStatStage?(:ACCURACY, user)
          score += target.stages[:ACCURACY] * 10
        else
          score -= 90
        end
      elsif target.stages[:ACCURACY] > 0
        score += 20
      end
    #---------------------------------------------------------------------------
    when "LowerTargetEvasion1"
      if move.statusMove?
        if target.pbCanLowerStatStage?(:EVASION, user)
          score += target.stages[:EVASION] * 10
        else
          score -= 90
        end
      elsif target.stages[:EVASION] > 0
        score += 20
      end
    #---------------------------------------------------------------------------
    when "LowerTargetEvasion1RemoveSideEffects"
      if move.statusMove?
        if target.pbCanLowerStatStage?(:EVASION, user)
          score += target.stages[:EVASION] * 10
        else
          score -= 90
        end
      elsif target.stages[:EVASION] > 0
        score += 20
      end
      score += 30 if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 ||
                     target.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
                     target.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
                     target.pbOwnSide.effects[PBEffects::Mist] > 0 ||
                     target.pbOwnSide.effects[PBEffects::Safeguard] > 0
      score -= 30 if target.pbOwnSide.effects[PBEffects::Spikes] > 0 ||
                     target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0 ||
                     target.pbOwnSide.effects[PBEffects::StealthRock]
    #---------------------------------------------------------------------------
    when "LowerTargetEvasion2", "LowerTargetEvasion3"
      if move.statusMove?
        if target.pbCanLowerStatStage?(:EVASION, user)
          score += target.stages[:EVASION] * 10
        else
          score -= 90
        end
      elsif target.stages[:EVASION] > 0
        score += 20
      end
    #---------------------------------------------------------------------------
    when "LowerTargetAtkDef1"
      avg =  target.stages[:ATTACK] * 10
      avg += target.stages[:DEFENSE] * 10
      score += avg / 2
    #---------------------------------------------------------------------------
    when "LowerTargetAtkSpAtk1"
      avg  = target.stages[:ATTACK] * 10
      avg += target.stages[:SPECIAL_ATTACK] * 10
      score += avg / 2
    #---------------------------------------------------------------------------
    when "LowerPoisonedTargetAtkSpAtkSpd1"
      count = 0
      @battle.allBattlers.each do |b|
        if b.poisoned? &&
           (!b.statStageAtMin?(:ATTACK) ||
           !b.statStageAtMin?(:SPECIAL_ATTACK) ||
           !b.statStageAtMin?(:SPEED))
          count += 1
          if user.opposes?(b)
            score += user.stages[:ATTACK] * 10
            score += user.stages[:SPECIAL_ATTACK] * 10
            score += user.stages[:SPEED] * 10
          else
            score -= 20
          end
        end
      end
      score -= 95 if count == 0
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
    when "RaisePlusMinusUserAndAlliesAtkSpAtk1"
      hasEffect = user.statStageAtMax?(:ATTACK) &&
                  user.statStageAtMax?(:SPECIAL_ATTACK)
      user.allAllies.each do |b|
        next if b.statStageAtMax?(:ATTACK) && b.statStageAtMax?(:SPECIAL_ATTACK)
        hasEffect = true
        score -= b.stages[:ATTACK] * 10
        score -= b.stages[:SPECIAL_ATTACK] * 10
      end
      if hasEffect
        score -= user.stages[:ATTACK] * 10
        score -= user.stages[:SPECIAL_ATTACK] * 10
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "RaisePlusMinusUserAndAlliesDefSpDef1"
      hasEffect = user.statStageAtMax?(:DEFENSE) &&
                  user.statStageAtMax?(:SPECIAL_DEFENSE)
      user.allAllies.each do |b|
        next if b.statStageAtMax?(:DEFENSE) && b.statStageAtMax?(:SPECIAL_DEFENSE)
        hasEffect = true
        score -= b.stages[:DEFENSE] * 10
        score -= b.stages[:SPECIAL_DEFENSE] * 10
      end
      if hasEffect
        score -= user.stages[:DEFENSE] * 10
        score -= user.stages[:SPECIAL_DEFENSE] * 10
      else
        score -= 90
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
            score -= user.stages[:ATTACK] * 10
            score -= user.stages[:SPECIAL_ATTACK] * 10
          end
        end
      end
      score -= 95 if count == 0
    #---------------------------------------------------------------------------
    when "RaiseGrassBattlersDef1"
      count = 0
      @battle.allBattlers.each do |b|
        if b.pbHasType?(:GRASS) && !b.statStageAtMax?(:DEFENSE)
          count += 1
          if user.opposes?(b)
            score -= 20
          else
            score -= user.stages[:DEFENSE] * 10
          end
        end
      end
      score -= 95 if count == 0
    #---------------------------------------------------------------------------
    when "UserTargetSwapAtkSpAtkStages"
      if skill >= PBTrainerAI.mediumSkill
        aatk = user.stages[:ATTACK]
        aspa = user.stages[:SPECIAL_ATTACK]
        oatk = target.stages[:ATTACK]
        ospa = target.stages[:SPECIAL_ATTACK]
        if aatk >= oatk && aspa >= ospa
          score -= 80
        else
          score += (oatk - aatk) * 10
          score += (ospa - aspa) * 10
        end
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapDefSpDefStages"
      if skill >= PBTrainerAI.mediumSkill
        adef = user.stages[:DEFENSE]
        aspd = user.stages[:SPECIAL_DEFENSE]
        odef = target.stages[:DEFENSE]
        ospd = target.stages[:SPECIAL_DEFENSE]
        if adef >= odef && aspd >= ospd
          score -= 80
        else
          score += (odef - adef) * 10
          score += (ospd - aspd) * 10
        end
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapStatStages"
      if skill >= PBTrainerAI.mediumSkill
        userStages = 0
        targetStages = 0
        GameData::Stat.each_battle do |s|
          userStages   += user.stages[s.id]
          targetStages += target.stages[s.id]
        end
        score += (targetStages - userStages) * 10
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "UserCopyTargetStatStages"
      if skill >= PBTrainerAI.mediumSkill
        equal = true
        GameData::Stat.each_battle do |s|
          stagediff = target.stages[s.id] - user.stages[s.id]
          score += stagediff * 10
          equal = false if stagediff != 0
        end
        score -= 80 if equal
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "UserStealTargetPositiveStatStages"
      numStages = 0
      GameData::Stat.each_battle do |s|
        next if target.stages[s.id] <= 0
        numStages += target.stages[s.id]
      end
      score += numStages * 20
    #---------------------------------------------------------------------------
    when "InvertTargetStatStages"
      if target.effects[PBEffects::Substitute] > 0
        score -= 90
      else
        numpos = 0
        numneg = 0
        GameData::Stat.each_battle do |s|
          numpos += target.stages[s.id] if target.stages[s.id] > 0
          numneg += target.stages[s.id] if target.stages[s.id] < 0
        end
        if numpos != 0 || numneg != 0
          score += (numpos - numneg) * 10
        else
          score -= 95
        end
      end
    #---------------------------------------------------------------------------
    when "ResetTargetStatStages"
      if target.effects[PBEffects::Substitute] > 0
        score -= 90
      else
        avg = 0
        anyChange = false
        GameData::Stat.each_battle do |s|
          next if target.stages[s.id] == 0
          avg += target.stages[s.id]
          anyChange = true
        end
        if anyChange
          score += avg * 10
        else
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "ResetAllBattlersStatStages"
      if skill >= PBTrainerAI.mediumSkill
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
        score += stages * 10
      end
    #---------------------------------------------------------------------------
    when "StartUserSideImmunityToStatStageLowering"
      score -= 80 if user.pbOwnSide.effects[PBEffects::Mist] > 0
    #---------------------------------------------------------------------------
    when "UserSwapBaseAtkDef"
      if skill >= PBTrainerAI.mediumSkill
        aatk = pbRoughStat(user, :ATTACK, skill)
        adef = pbRoughStat(user, :DEFENSE, skill)
        if aatk == adef ||
           user.effects[PBEffects::PowerTrick]   # No flip-flopping
          score -= 90
        elsif adef > aatk   # Prefer a higher Attack
          score += 30
        else
          score -= 30
        end
      else
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapBaseSpeed"
      if skill >= PBTrainerAI.mediumSkill
        if user.speed > target.speed
          score += 50
        else
          score -= 70
        end
      end
    #---------------------------------------------------------------------------
    when "UserTargetAverageBaseAtkSpAtk"
      if skill >= PBTrainerAI.mediumSkill
        aatk   = pbRoughStat(user, :ATTACK, skill)
        aspatk = pbRoughStat(user, :SPECIAL_ATTACK, skill)
        oatk   = pbRoughStat(target, :ATTACK, skill)
        ospatk = pbRoughStat(target, :SPECIAL_ATTACK, skill)
        if aatk < oatk && aspatk < ospatk
          score += 50
        elsif aatk + aspatk < oatk + ospatk
          score += 30
        else
          score -= 50
        end
      else
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "UserTargetAverageBaseDefSpDef"
      if skill >= PBTrainerAI.mediumSkill
        adef   = pbRoughStat(user, :DEFENSE, skill)
        aspdef = pbRoughStat(user, :SPECIAL_DEFENSE, skill)
        odef   = pbRoughStat(target, :DEFENSE, skill)
        ospdef = pbRoughStat(target, :SPECIAL_DEFENSE, skill)
        if adef < odef && aspdef < ospdef
          score += 50
        elsif adef + aspdef < odef + ospdef
          score += 30
        else
          score -= 50
        end
      else
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "UserTargetAverageHP"
      if target.effects[PBEffects::Substitute] > 0
        score -= 90
      elsif user.hp >= (user.hp + target.hp) / 2
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "StartUserSideDoubleSpeed"
      score -= 90 if user.pbOwnSide.effects[PBEffects::Tailwind] > 0
    #---------------------------------------------------------------------------
    when "StartSwapAllBattlersBaseDefensiveStats"
    #---------------------------------------------------------------------------
    end
    return score
  end
end
