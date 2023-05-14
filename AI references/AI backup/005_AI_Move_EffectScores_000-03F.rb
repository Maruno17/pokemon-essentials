class PokeBattle_AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctionCode(score,move,user,target,skill=100)
    case move.function
    #---------------------------------------------------------------------------
    when "000"   # No extra effect
    #---------------------------------------------------------------------------
    when "001"
      score -= 95
      score = 0 if skill>=PBTrainerAI.highSkill
    #---------------------------------------------------------------------------
    when "002"   # Struggle
    #---------------------------------------------------------------------------
    when "003"
      if target.pbCanSleep?(user,false)
        score += 30
        if skill>=PBTrainerAI.mediumSkill
          score -= 30 if target.effects[PBEffects::Yawn]>0
        end
        if skill>=PBTrainerAI.highSkill
          score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
        end
        if skill>=PBTrainerAI.bestSkill
          if target.pbHasMoveFunction?("011","0B4")   # Snore, Sleep Talk
            score -= 50
          end
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
    #---------------------------------------------------------------------------
    when "004"
      if target.effects[PBEffects::Yawn]>0 || !target.pbCanSleep?(user,false)
        score -= 90 if skill>=PBTrainerAI.mediumSkill
      else
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 30 if target.hasActiveAbility?(:MARVELSCALE)
        end
        if skill>=PBTrainerAI.bestSkill
          if target.pbHasMoveFunction?("011","0B4")   # Snore, Sleep Talk
            score -= 50
          end
        end
      end
    #---------------------------------------------------------------------------
    when "005", "006", "0BE"
      if target.pbCanPoison?(user,false)
        score += 30
        if skill>=PBTrainerAI.mediumSkill
          score += 30 if target.hp<=target.totalhp/4
          score += 50 if target.hp<=target.totalhp/8
          score -= 40 if target.effects[PBEffects::Yawn]>0
        end
        if skill>=PBTrainerAI.highSkill
          score += 10 if pbRoughStat(target,PBStats::DEFENSE,skill)>100
          score += 10 if pbRoughStat(target,PBStats::SPDEF,skill)>100
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:TOXICBOOST])
        end
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
    #---------------------------------------------------------------------------
    when "007", "008", "009", "0C5"
      if target.pbCanParalyze?(user,false) &&
         !(skill>=PBTrainerAI.mediumSkill &&
         isConst?(move.id,PBMoves,:THUNDERWAVE) &&
         PBTypes.ineffective?(pbCalcTypeMod(move.type,user,target)))
        score += 30
        if skill>=PBTrainerAI.mediumSkill
           aspeed = pbRoughStat(user,PBStats::SPEED,skill)
           ospeed = pbRoughStat(target,PBStats::SPEED,skill)
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
    when "00A", "00B", "0C6"
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
    when "00C", "00D", "00E"
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
    when "00F"
      score += 30
      if skill>=PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute]==0
      end
    #---------------------------------------------------------------------------
    when "010"
      if skill>=PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute]==0
      end
      score += 30 if target.effects[PBEffects::Minimize]
    #---------------------------------------------------------------------------
    when "011"
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
    when "012"
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
    when "013", "014", "015"
      if target.pbCanConfuse?(user,false)
        score += 30
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90 if move.statusMove?
        end
      end
    #---------------------------------------------------------------------------
    when "016"
      canattract = true
      agender = user.gender
      ogender = target.gender
      if agender==2 || ogender==2 || agender==ogender
        score -= 90; canattract = false
      elsif target.effects[PBEffects::Attract]>=0
        score -= 80; canattract = false
      elsif skill>=PBTrainerAI.bestSkill && target.hasActiveAbility?(:OBLIVIOUS)
        score -= 80; canattract = false
      end
      if skill>=PBTrainerAI.highSkill
        if canattract && target.hasActiveItem?(:DESTINYKNOT) &&
           user.pbCanAttract?(target,false)
          score -= 30
        end
      end
    #---------------------------------------------------------------------------
    when "017"
      score += 30 if target.status==PBStatuses::NONE
    #---------------------------------------------------------------------------
    when "018"
      case user.status
      when PBStatuses::POISON
        score += 40
        if skill>=PBTrainerAI.mediumSkill
          if user.hp<user.totalhp/8
            score += 60
          elsif skill>=PBTrainerAI.highSkill &&
             user.hp<(user.effects[PBEffects::Toxic]+1)*user.totalhp/16
            score += 60
          end
        end
      when PBStatuses::BURN, PBStatuses::PARALYSIS
        score += 40
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "019"
      statuses = 0
      @battle.pbParty(user.index).each do |pkmn|
        statuses += 1 if pkmn && pkmn.status!=PBStatuses::NONE
      end
      if statuses==0
        score -= 80
      else
        score += 20*statuses
      end
    #---------------------------------------------------------------------------
    when "01A"
      if user.pbOwnSide.effects[PBEffects::Safeguard]>0
        score -= 80
      elsif user.status!=0
        score -= 40
      else
        score += 30
      end
    #---------------------------------------------------------------------------
    when "01B"
      if user.status==PBStatuses::NONE
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "01C"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::ATTACK)
          score -= 90
        else
          score -= user.stages[PBStats::ATTACK]*20
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
        score += 20 if user.stages[PBStats::ATTACK]<0
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
    when "01D", "01E", "0C8"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::DEFENSE)
          score -= 90
        else
          score -= user.stages[PBStats::DEFENSE]*20
        end
      else
        score += 20 if user.stages[PBStats::DEFENSE]<0
      end
    #---------------------------------------------------------------------------
    when "01F"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::SPEED)
          score -= 90
        else
          score -= user.stages[PBStats::SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,PBStats::SPEED,skill)
            ospeed = pbRoughStat(target,PBStats::SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 20 if user.stages[PBStats::SPEED]<0
      end
    #---------------------------------------------------------------------------
    when "020"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::SPATK)
          score -= 90
        else
          score -= user.stages[PBStats::SPATK]*20
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
        score += 20 if user.stages[PBStats::SPATK]<0
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
    when "021"
      foundMove = false
      user.eachMove do |m|
        next if !isConst?(m.type,PBTypes,:ELECTRIC) || !m.damagingMove?
        foundMove = true
        break
      end
      score += 20 if foundMove
      if move.statusMove?
        if user.statStageAtMax?(PBStats::SPDEF)
          score -= 90
        else
          score -= user.stages[PBStats::SPDEF]*20
        end
      else
        score += 20 if user.stages[PBStats::SPDEF]<0
      end
    #---------------------------------------------------------------------------
    when "022"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::EVASION)
          score -= 90
        else
          score -= user.stages[PBStats::EVASION]*10
        end
      else
        score += 20 if user.stages[PBStats::EVASION]<0
      end
    #---------------------------------------------------------------------------
    when "023"
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
    when "024"
      if user.statStageAtMax?(PBStats::ATTACK) &&
         user.statStageAtMax?(PBStats::DEFENSE)
        score -= 90
      else
        score -= user.stages[PBStats::ATTACK]*10
        score -= user.stages[PBStats::DEFENSE]*10
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
    when "025"
      if user.statStageAtMax?(PBStats::ATTACK) &&
         user.statStageAtMax?(PBStats::DEFENSE) &&
         user.statStageAtMax?(PBStats::ACCURACY)
        score -= 90
      else
        score -= user.stages[PBStats::ATTACK]*10
        score -= user.stages[PBStats::DEFENSE]*10
        score -= user.stages[PBStats::ACCURACY]*10
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
    when "026"
      score += 40 if user.turnCount==0   # Dragon Dance tends to be popular
      if user.statStageAtMax?(PBStats::ATTACK) &&
         user.statStageAtMax?(PBStats::SPEED)
        score -= 90
      else
        score -= user.stages[PBStats::ATTACK]*10
        score -= user.stages[PBStats::SPEED]*10
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
          aspeed = pbRoughStat(user,PBStats::SPEED,skill)
          ospeed = pbRoughStat(target,PBStats::SPEED,skill)
          score += 20 if aspeed<ospeed && aspeed*2>ospeed
        end
      end
    #---------------------------------------------------------------------------
    when "027", "028"
      if user.statStageAtMax?(PBStats::ATTACK) &&
         user.statStageAtMax?(PBStats::SPATK)
        score -= 90
      else
        score -= user.stages[PBStats::ATTACK]*10
        score -= user.stages[PBStats::SPATK]*10
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
        if move.function=="028"   # Growth
          score += 20 if @battle.pbWeather==PBWeather::Sun ||
                         @battle.pbWeather==PBWeather::HarshSun
        end
      end
    #---------------------------------------------------------------------------
    when "029"
      if user.statStageAtMax?(PBStats::ATTACK) &&
         user.statStageAtMax?(PBStats::ACCURACY)
        score -= 90
      else
        score -= user.stages[PBStats::ATTACK]*10
        score -= user.stages[PBStats::ACCURACY]*10
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
    when "02A"
      if user.statStageAtMax?(PBStats::DEFENSE) &&
         user.statStageAtMax?(PBStats::SPDEF)
        score -= 90
      else
        score -= user.stages[PBStats::DEFENSE]*10
        score -= user.stages[PBStats::SPDEF]*10
      end
    #---------------------------------------------------------------------------
    when "02B"
      if user.statStageAtMax?(PBStats::SPEED) &&
         user.statStageAtMax?(PBStats::SPATK) &&
         user.statStageAtMax?(PBStats::SPDEF)
        score -= 90
      else
        score -= user.stages[PBStats::SPATK]*10
        score -= user.stages[PBStats::SPDEF]*10
        score -= user.stages[PBStats::SPEED]*10
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
          aspeed = pbRoughStat(user,PBStats::SPEED,skill)
          ospeed = pbRoughStat(target,PBStats::SPEED,skill)
          if aspeed<ospeed && aspeed*2>ospeed
            score += 20
          end
        end
      end
    #---------------------------------------------------------------------------
    when "02C"
      if user.statStageAtMax?(PBStats::SPATK) &&
         user.statStageAtMax?(PBStats::SPDEF)
        score -= 90
      else
        score += 40 if user.turnCount==0   # Calm Mind tends to be popular
        score -= user.stages[PBStats::SPATK]*10
        score -= user.stages[PBStats::SPDEF]*10
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
    when "02D"
      PBStats.eachMainBattleStat { |s| score += 10 if user.stages[s]<0 }
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
    when "02E"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::ATTACK)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[PBStats::ATTACK]*20
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
        score += 20 if user.stages[PBStats::ATTACK]<0
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
    when "02F"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::DEFENSE)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[PBStats::DEFENSE]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[PBStats::DEFENSE]<0
      end
    #---------------------------------------------------------------------------
    when "030", "031"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::SPEED)
          score -= 90
        else
          score += 20 if user.turnCount==0
          score -= user.stages[PBStats::SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,PBStats::SPEED,skill)
            ospeed = pbRoughStat(target,PBStats::SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[PBStats::SPEED]<0
      end
    #---------------------------------------------------------------------------
    when "032"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::SPATK)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[PBStats::SPATK]*20
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
        score += 20 if user.stages[PBStats::SPATK]<0
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
    when "033"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::SPDEF)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[PBStats::SPDEF]*20
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[PBStats::SPDEF]<0
      end
    #---------------------------------------------------------------------------
    when "034"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::EVASION)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[PBStats::EVASION]*10
        end
      else
        score += 10 if user.turnCount==0
        score += 20 if user.stages[PBStats::EVASION]<0
      end
    #---------------------------------------------------------------------------
    when "035"
      score -= user.stages[PBStats::ATTACK]*20
      score -= user.stages[PBStats::SPEED]*20
      score -= user.stages[PBStats::SPATK]*20
      score += user.stages[PBStats::DEFENSE]*10
      score += user.stages[PBStats::SPDEF]*10
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
    when "036"
      if user.statStageAtMax?(PBStats::ATTACK) &&
         user.statStageAtMax?(PBStats::SPEED)
        score -= 90
      else
        score -= user.stages[PBStats::ATTACK]*10
        score -= user.stages[PBStats::SPEED]*10
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
          aspeed = pbRoughStat(user,PBStats::SPEED,skill)
          ospeed = pbRoughStat(target,PBStats::SPEED,skill)
          score += 30 if aspeed<ospeed && aspeed*2>ospeed
        end
      end
    #---------------------------------------------------------------------------
    when "037"
      avgStat = 0; canChangeStat = false
      PBStats.eachBattleStat do |s|
        next if target.statStageAtMax?(s)
        avgStat -= target.stages[s]
        canChangeStat = true
      end
      if canChangeStat
        avgStat = avgStat/2 if avgStat<0   # More chance of getting even better
        score += avgStat*10
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "038"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::DEFENSE)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[PBStats::DEFENSE]*30
        end
      else
        score += 10 if user.turnCount==0
        score += 30 if user.stages[PBStats::DEFENSE]<0
      end
    #---------------------------------------------------------------------------
    when "039"
      if move.statusMove?
        if user.statStageAtMax?(PBStats::SPATK)
          score -= 90
        else
          score += 40 if user.turnCount==0
          score -= user.stages[PBStats::SPATK]*30
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
        score += 30 if user.stages[PBStats::SPATK]<0
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
    when "03A"
      if user.statStageAtMax?(PBStats::ATTACK) ||
         user.hp<=user.totalhp/2
        score -= 100
      else
        score += (6-user.stages[PBStats::ATTACK])*10
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
    when "03B"
      avg =  user.stages[PBStats::ATTACK]*10
      avg += user.stages[PBStats::DEFENSE]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "03C"
      avg =  user.stages[PBStats::DEFENSE]*10
      avg += user.stages[PBStats::SPDEF]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "03D"
      avg =  user.stages[PBStats::DEFENSE]*10
      avg += user.stages[PBStats::SPEED]*10
      avg += user.stages[PBStats::SPDEF]*10
      score += (avg/3).floor
    #---------------------------------------------------------------------------
    when "03E"
      score += user.stages[PBStats::SPEED]*10
    #---------------------------------------------------------------------------
    when "03F"
      score += user.stages[PBStats::SPATK]*10
    #---------------------------------------------------------------------------
    end
    return score
  end
end
