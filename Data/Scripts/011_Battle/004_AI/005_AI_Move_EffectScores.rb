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
    when "007", "008", "009", "0C5"
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
      score += 30 if target.status == :NONE
    #---------------------------------------------------------------------------
    when "018"
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
    when "019"
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
    when "01A"
      if user.pbOwnSide.effects[PBEffects::Safeguard]>0
        score -= 80
      elsif user.status != :NONE
        score -= 40
      else
        score += 30
      end
    #---------------------------------------------------------------------------
    when "01B"
      if user.status == :NONE
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "01C"
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
    when "01D", "01E", "0C8"
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
    when "01F"
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
    when "020"
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
    when "021"
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
    when "022"
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
    when "025"
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
    when "026"
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
    when "027", "028"
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
        if move.function=="028"   # Growth
          score += 20 if [:Sun, :HarshSun].include?(@battle.pbWeather)
        end
      end
    #---------------------------------------------------------------------------
    when "029"
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
    when "02A"
      if user.statStageAtMax?(:DEFENSE) &&
         user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= user.stages[:DEFENSE]*10
        score -= user.stages[:SPECIAL_DEFENSE]*10
      end
    #---------------------------------------------------------------------------
    when "02B"
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
    when "02C"
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
    when "02D"
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
    when "02E"
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
    when "02F"
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
    when "030", "031"
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
    when "032"
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
    when "033"
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
    when "034"
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
    when "035"
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
    when "036"
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
    when "037"
      avgStat = 0; canChangeStat = false
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
    when "038"
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
    when "039"
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
    when "03A"
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
    when "03B"
      avg =  user.stages[:ATTACK]*10
      avg += user.stages[:DEFENSE]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "03C"
      avg =  user.stages[:DEFENSE]*10
      avg += user.stages[:SPECIAL_DEFENSE]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "03D"
      avg =  user.stages[:DEFENSE]*10
      avg += user.stages[:SPEED]*10
      avg += user.stages[:SPECIAL_DEFENSE]*10
      score += (avg/3).floor
    #---------------------------------------------------------------------------
    when "03E"
      score += user.stages[:SPEED]*10
    #---------------------------------------------------------------------------
    when "03F"
      score += user.stages[:SPECIAL_ATTACK]*10
    #---------------------------------------------------------------------------
    when "040"
      if !target.pbCanConfuse?(user,false)
        score -= 90
      else
        score += 30 if target.stages[:SPECIAL_ATTACK]<0
      end
    #---------------------------------------------------------------------------
    when "041"
      if !target.pbCanConfuse?(user,false)
        score -= 90
      else
        score += 30 if target.stages[:ATTACK]<0
      end
    #---------------------------------------------------------------------------
    when "042"
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
    when "043"
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
    when "044"
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
    when "045"
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
    when "046"
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
    when "047"
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
    when "048"
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
    when "049"
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
    when "04A"
      avg =  target.stages[:ATTACK]*10
      avg += target.stages[:DEFENSE]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "04B"
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
    when "04C"
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
    when "04D"
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
    when "04E"
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
    when "04F"
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
    when "050"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      else
        avg = 0; anyChange = false
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
    when "051"
      if skill>=PBTrainerAI.mediumSkill
        stages = 0
        @battle.eachBattler do |b|
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
    when "052"
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
    when "053"
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
    when "054"
      if skill>=PBTrainerAI.mediumSkill
        userStages = 0; targetStages = 0
        GameData::Stat.each_battle do |s|
          userStages   += user.stages[s.id]
          targetStages += target.stages[s.id]
        end
        score += (targetStages-userStages)*10
      else
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "055"
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
    when "056"
      score -= 80 if user.pbOwnSide.effects[PBEffects::Mist]>0
    #---------------------------------------------------------------------------
    when "057"
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
    when "058"
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
    when "059"
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
    when "05A"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif user.hp>=(user.hp+target.hp)/2
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "05B"
      score -= 90 if user.pbOwnSide.effects[PBEffects::Tailwind]>0
    #---------------------------------------------------------------------------
    when "05C"
      moveBlacklist = [
         "002",   # Struggle
         "014",   # Chatter
         "05C",   # Mimic
         "05D",   # Sketch
         "0B6"    # Metronome
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
    when "05D"
      moveBlacklist = [
         "002",   # Struggle
         "014",   # Chatter
         "05D"    # Sketch
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
    when "05E"
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
    when "05F"
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
    when "060"
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
    when "061"
      if target.effects[PBEffects::Substitute]>0 || !target.canChangeType?
        score -= 90
      elsif !target.pbHasOtherType?(:WATER)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "062"
      if !user.canChangeType? || target.pbTypes(true).length == 0
        score -= 90
      elsif user.pbTypes == target.pbTypes &&
         user.effects[PBEffects::Type3] == target.effects[PBEffects::Type3]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "063"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        if target.unstoppableAbility? || [:TRUANT, :SIMPLE].include?(target.ability)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "064"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill
        if target.unstoppableAbility? || [:TRUANT, :INSOMNIA].include?(target.ability_id)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "065"
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
    when "066"
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
    when "067"
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
    when "068"
      if target.effects[PBEffects::Substitute]>0 ||
         target.effects[PBEffects::GastroAcid]
        score -= 90
      elsif skill>=PBTrainerAI.highSkill
        score -= 90 if [:MULTITYPE, :RKSSYSTEM, :SLOWSTART, :TRUANT].include?(target.ability_id)
      end
    #---------------------------------------------------------------------------
    when "069"
      score -= 70
    #---------------------------------------------------------------------------
    when "06A"
      if target.hp<=20
        score += 80
      elsif target.level>=25
        score -= 60   # Not useful against high-level Pokemon
      end
    #---------------------------------------------------------------------------
    when "06B"
      score += 80 if target.hp<=40
    #---------------------------------------------------------------------------
    when "06C"
      score -= 50
      score += target.hp*100/target.totalhp
    #---------------------------------------------------------------------------
    when "06D"
      score += 80 if target.hp<=user.level
    #---------------------------------------------------------------------------
    when "06E"
      if user.hp>=target.hp
        score -= 90
      elsif user.hp<target.hp/2
        score += 50
      end
    #---------------------------------------------------------------------------
    when "06F"
      score += 30 if target.hp<=user.level
    #---------------------------------------------------------------------------
    when "070"
      score -= 90 if target.hasActiveAbility?(:STURDY)
      score -= 90 if target.level>user.level
    #---------------------------------------------------------------------------
    when "071"
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
    when "072"
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
    when "073"
      score -= 90 if target.effects[PBEffects::HyperBeam]>0
    #---------------------------------------------------------------------------
    when "074"
      target.eachAlly do |b|
        next if !b.near?(target)
        score += 10
      end
    #---------------------------------------------------------------------------
    when "075"
    #---------------------------------------------------------------------------
    when "076"
    #---------------------------------------------------------------------------
    when "077"
    #---------------------------------------------------------------------------
    when "078"
      if skill>=PBTrainerAI.highSkill
        score += 30 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute]==0
      end
    #---------------------------------------------------------------------------
    when "079"
    #---------------------------------------------------------------------------
    when "07A"
    #---------------------------------------------------------------------------
    when "07B"
    #---------------------------------------------------------------------------
    when "07C"
      score -= 20 if target.status == :PARALYSIS   # Will cure status
    #---------------------------------------------------------------------------
    when "07D"
      score -= 20 if target.status == :SLEEP &&   # Will cure status
                     target.statusCount > 1
    #---------------------------------------------------------------------------
    when "07E"
    #---------------------------------------------------------------------------
    when "07F"
    #---------------------------------------------------------------------------
    when "080"
    #---------------------------------------------------------------------------
    when "081"
      attspeed = pbRoughStat(user,:SPEED,skill)
      oppspeed = pbRoughStat(target,:SPEED,skill)
      score += 30 if oppspeed>attspeed
    #---------------------------------------------------------------------------
    when "082"
      score += 20 if @battle.pbOpposingBattlerCount(user)>1
    #---------------------------------------------------------------------------
    when "083"
      if skill>=PBTrainerAI.mediumSkill
        user.eachAlly do |b|
          next if !b.pbHasMove?(move.id)
          score += 20
        end
      end
    #---------------------------------------------------------------------------
    when "084"
      attspeed = pbRoughStat(user,:SPEED,skill)
      oppspeed = pbRoughStat(target,:SPEED,skill)
      score += 30 if oppspeed>attspeed
    #---------------------------------------------------------------------------
    when "085"
    #---------------------------------------------------------------------------
    when "086"
    #---------------------------------------------------------------------------
    when "087"
    #---------------------------------------------------------------------------
    when "088"
    #---------------------------------------------------------------------------
    when "089"
    #---------------------------------------------------------------------------
    when "08A"
    #---------------------------------------------------------------------------
    when "08B"
    #---------------------------------------------------------------------------
    when "08C"
    #---------------------------------------------------------------------------
    when "08D"
    #---------------------------------------------------------------------------
    when "08E"
    #---------------------------------------------------------------------------
    when "08F"
    #---------------------------------------------------------------------------
    when "090"
    #---------------------------------------------------------------------------
    when "091"
    #---------------------------------------------------------------------------
    when "092"
    #---------------------------------------------------------------------------
    when "093"
      score += 25 if user.effects[PBEffects::Rage]
    #---------------------------------------------------------------------------
    when "094"
    #---------------------------------------------------------------------------
    when "095"
    #---------------------------------------------------------------------------
    when "096"
      score -= 90 if !user.item || !user.item.is_berry? || !user.itemActive?
    #---------------------------------------------------------------------------
    when "097"
    #---------------------------------------------------------------------------
    when "098"
    #---------------------------------------------------------------------------
    when "099"
    #---------------------------------------------------------------------------
    when "09A"
    #---------------------------------------------------------------------------
    when "09B"
    #---------------------------------------------------------------------------
    when "09C"
      hasAlly = false
      user.eachAlly do |b|
        hasAlly = true
        score += 30
        break
      end
      score -= 90 if !hasAlly
    #---------------------------------------------------------------------------
    when "09D"
      score -= 90 if user.effects[PBEffects::MudSport]
    #---------------------------------------------------------------------------
    when "09E"
      score -= 90 if user.effects[PBEffects::WaterSport]
    #---------------------------------------------------------------------------
    when "09F"
    #---------------------------------------------------------------------------
    when "0A0"
    #---------------------------------------------------------------------------
    when "0A1"
      score -= 90 if user.pbOwnSide.effects[PBEffects::LuckyChant]>0
    #---------------------------------------------------------------------------
    when "0A2"
      score -= 90 if user.pbOwnSide.effects[PBEffects::Reflect]>0
    #---------------------------------------------------------------------------
    when "0A3"
      score -= 90 if user.pbOwnSide.effects[PBEffects::LightScreen]>0
    #---------------------------------------------------------------------------
    when "0A4"
    #---------------------------------------------------------------------------
    when "0A5"
    #---------------------------------------------------------------------------
    when "0A6"
      score -= 90 if target.effects[PBEffects::Substitute]>0
      score -= 90 if user.effects[PBEffects::LockOn]>0
    #---------------------------------------------------------------------------
    when "0A7"
      if target.effects[PBEffects::Foresight]
        score -= 90
      elsif target.pbHasType?(:GHOST)
        score += 70
      elsif target.stages[:EVASION]<=0
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "0A8"
      if target.effects[PBEffects::MiracleEye]
        score -= 90
      elsif target.pbHasType?(:DARK)
        score += 70
      elsif target.stages[:EVASION]<=0
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "0A9"
    #---------------------------------------------------------------------------
    when "0AA"
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
    when "0AB"
    #---------------------------------------------------------------------------
    when "0AC"
    #---------------------------------------------------------------------------
    when "0AD"
    #---------------------------------------------------------------------------
    when "0AE"
      score -= 40
      if skill>=PBTrainerAI.highSkill
        score -= 100 if !target.lastRegularMoveUsed ||
           !GameData::Move.get(target.lastRegularMoveUsed).flags[/e/]   # Not copyable by Mirror Move
      end
    #---------------------------------------------------------------------------
    when "0AF"
    #---------------------------------------------------------------------------
    when "0B0"
    #---------------------------------------------------------------------------
    when "0B1"
    #---------------------------------------------------------------------------
    when "0B2"
    #---------------------------------------------------------------------------
    when "0B3"
    #---------------------------------------------------------------------------
    when "0B4"
      if user.asleep?
        score += 100   # Because it can only be used while asleep
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "0B5"
    #---------------------------------------------------------------------------
    when "0B6"
    #---------------------------------------------------------------------------
    when "0B7"
      score -= 90 if target.effects[PBEffects::Torment]
    #---------------------------------------------------------------------------
    when "0B8"
      score -= 90 if user.effects[PBEffects::Imprison]
    #---------------------------------------------------------------------------
    when "0B9"
      score -= 90 if target.effects[PBEffects::Disable]>0
    #---------------------------------------------------------------------------
    when "0BA"
      score -= 90 if target.effects[PBEffects::Taunt]>0
    #---------------------------------------------------------------------------
    when "0BB"
      score -= 90 if target.effects[PBEffects::HealBlock]>0
    #---------------------------------------------------------------------------
    when "0BC"
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
    when "0BD"
    #---------------------------------------------------------------------------
    when "0BF"
    #---------------------------------------------------------------------------
    when "0C0"
    #---------------------------------------------------------------------------
    when "0C1"
    #---------------------------------------------------------------------------
    when "0C2"
    #---------------------------------------------------------------------------
    when "0C3"
    #---------------------------------------------------------------------------
    when "0C4"
    #---------------------------------------------------------------------------
    when "0C7"
      score += 20 if user.effects[PBEffects::FocusEnergy]>0
      if skill>=PBTrainerAI.highSkill
        score += 20 if !target.hasActiveAbility?(:INNERFOCUS) &&
                       target.effects[PBEffects::Substitute]==0
      end
    #---------------------------------------------------------------------------
    when "0C9"
    #---------------------------------------------------------------------------
    when "0CA"
    #---------------------------------------------------------------------------
    when "0CB"
    #---------------------------------------------------------------------------
    when "0CC"
    #---------------------------------------------------------------------------
    when "0CD"
    #---------------------------------------------------------------------------
    when "0CE"
    #---------------------------------------------------------------------------
    when "0CF"
      score += 40 if target.effects[PBEffects::Trapping]==0
    #---------------------------------------------------------------------------
    when "0D0"
      score += 40 if target.effects[PBEffects::Trapping]==0
    #---------------------------------------------------------------------------
    when "0D1"
    #---------------------------------------------------------------------------
    when "0D2"
    #---------------------------------------------------------------------------
    when "0D3"
    #---------------------------------------------------------------------------
    when "0D4"
      if user.hp<=user.totalhp/4
        score -= 90
      elsif user.hp<=user.totalhp/2
        score -= 50
      end
    #---------------------------------------------------------------------------
    when "0D5", "0D6"
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp*100/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "0D7"
      score -= 90 if @battle.positions[user.index].effects[PBEffects::Wish]>0
    #---------------------------------------------------------------------------
    when "0D8"
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        case @battle.pbWeather
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
    when "0D9"
      if user.hp==user.totalhp || !user.pbCanSleep?(user,false,nil,true)
        score -= 90
      else
        score += 70
        score -= user.hp*140/user.totalhp
        score += 30 if user.status != :NONE
      end
    #---------------------------------------------------------------------------
    when "0DA"
      score -= 90 if user.effects[PBEffects::AquaRing]
    #---------------------------------------------------------------------------
    when "0DB"
      score -= 90 if user.effects[PBEffects::Ingrain]
    #---------------------------------------------------------------------------
    when "0DC"
      if target.effects[PBEffects::LeechSeed]>=0
        score -= 90
      elsif skill>=PBTrainerAI.mediumSkill && target.pbHasType?(:GRASS)
        score -= 90
      else
        score += 60 if user.turnCount==0
      end
    #---------------------------------------------------------------------------
    when "0DD"
      if skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 70
      else
        score += 20 if user.hp<=user.totalhp/2
      end
    #---------------------------------------------------------------------------
    when "0DE"
      if !target.asleep?
        score -= 100
      elsif skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 70
      else
        score += 20 if user.hp<=user.totalhp/2
      end
    #---------------------------------------------------------------------------
    when "0DF"
      if user.opposes?(target)
        score -= 100
      else
        score += 20 if target.hp<target.totalhp/2 &&
                       target.effects[PBEffects::Substitute]==0
      end
    #---------------------------------------------------------------------------
    when "0E0"
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
    when "0E1"
    #---------------------------------------------------------------------------
    when "0E2"
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
    when "0E3", "0E4"
      score -= 70
    #---------------------------------------------------------------------------
    when "0E5"
      if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        score -= 90
      else
        score -= 90 if target.effects[PBEffects::PerishSong]>0
      end
    #---------------------------------------------------------------------------
    when "0E6"
      score += 50
      score -= user.hp*100/user.totalhp
      score += 30 if user.hp<=user.totalhp/10
    #---------------------------------------------------------------------------
    when "0E7"
      score += 50
      score -= user.hp*100/user.totalhp
      score += 30 if user.hp<=user.totalhp/10
    #---------------------------------------------------------------------------
    when "0E8"
      score -= 25 if user.hp>user.totalhp/2
      if skill>=PBTrainerAI.mediumSkill
        score -= 90 if user.effects[PBEffects::ProtectRate]>1
        score -= 90 if target.effects[PBEffects::HyperBeam]>0
      else
        score -= user.effects[PBEffects::ProtectRate]*40
      end
    #---------------------------------------------------------------------------
    when "0E9"
      if target.hp==1
        score -= 90
      elsif target.hp<=target.totalhp/8
        score -= 60
      elsif target.hp<=target.totalhp/4
        score -= 30
      end
    #---------------------------------------------------------------------------
    when "0EA"
      score -= 100 if @battle.trainerBattle?
    #---------------------------------------------------------------------------
    when "0EB"
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
    when "0EC"
      if !target.effects[PBEffects::Ingrain] &&
         !(skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:SUCTIONCUPS))
        score += 40 if target.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 40 if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 40 if target.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "0ED"
      if !@battle.pbCanChooseNonActive?(user.index)
        score -= 80
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
    when "0EE"
    #---------------------------------------------------------------------------
    when "0EF"
      score -= 90 if target.effects[PBEffects::MeanLook]>=0
    #---------------------------------------------------------------------------
    when "0F0"
      if skill>=PBTrainerAI.highSkill
        score += 20 if target.item
      end
    #---------------------------------------------------------------------------
    when "0F1"
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
    when "0F2"
      if !user.item && !target.item
        score -= 90
      elsif skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:STICKYHOLD)
        score -= 90
      elsif user.hasActiveItem?([:FLAMEORB,:TOXICORB,:STICKYBARB,:IRONBALL,
                                 :CHOICEBAND,:CHOICESCARF,:CHOICESPECS])
        score += 50
      elsif !user.item && target.item
        score -= 30 if user.lastMoveUsed &&
                       GameData::Move.get(user.lastMoveUsed).function_code == "0F2"   # Trick/Switcheroo
      end
    #---------------------------------------------------------------------------
    when "0F3"
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
    when "0F4", "0F5"
      if target.effects[PBEffects::Substitute]==0
        if skill>=PBTrainerAI.highSkill && target.item && target.item.is_berry?
          score += 30
        end
      end
    #---------------------------------------------------------------------------
    when "0F6"
      if !user.recycleItem || user.item
        score -= 80
      elsif user.recycleItem
        score += 30
      end
    #---------------------------------------------------------------------------
    when "0F7"
      if !user.item || !user.itemActive? ||
         user.unlosableItem?(user.item) || user.item.is_poke_ball?
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "0F8"
      score -= 90 if target.effects[PBEffects::Embargo]>0
    #---------------------------------------------------------------------------
    when "0F9"
      if @battle.field.effects[PBEffects::MagicRoom]>0
        score -= 90
      else
        score += 30 if !user.item && target.item
      end
    #---------------------------------------------------------------------------
    when "0FA"
      score -= 25
    #---------------------------------------------------------------------------
    when "0FB"
      score -= 30
    #---------------------------------------------------------------------------
    when "0FC"
      score -= 40
    #---------------------------------------------------------------------------
    when "0FD"
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
    when "0FE"
      score -= 30
      if target.pbCanBurn?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
        end
      end
    #---------------------------------------------------------------------------
    when "0FF"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather == :Sun
        score -= 90
      else
        user.eachMove do |m|
          next if !m.damagingMove? || m.type != :FIRE
          score += 20
        end
      end
    #---------------------------------------------------------------------------
    when "100"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather == :Rain
        score -= 90
      else
        user.eachMove do |m|
          next if !m.damagingMove? || m.type != :WATER
          score += 20
        end
      end
    #---------------------------------------------------------------------------
    when "101"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather == :Sandstorm
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "102"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather == :Hail
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "103"
      if user.pbOpposingSide.effects[PBEffects::Spikes]>=3
        score -= 90
      else
        canChoose = false
        user.eachOpposing do |b|
          next if !@battle.pbCanChooseNonActive?(b.index)
          canChoose = true
          break
        end
        if !canChoose
          # Opponent can't switch in any Pokemon
        score -= 90
        else
          score += 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
          score += [40,26,13][user.pbOpposingSide.effects[PBEffects::Spikes]]
        end
      end
    #---------------------------------------------------------------------------
    when "104"
      if user.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
        score -= 90
      else
        canChoose = false
        user.eachOpposing do |b|
          next if !@battle.pbCanChooseNonActive?(b.index)
          canChoose = true
          break
        end
        if !canChoose
          # Opponent can't switch in any Pokemon
          score -= 90
        else
          score += 8*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
          score += [26,13][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
        end
      end
    #---------------------------------------------------------------------------
    when "105"
      if user.pbOpposingSide.effects[PBEffects::StealthRock]
        score -= 90
      else
        canChoose = false
        user.eachOpposing do |b|
          next if !@battle.pbCanChooseNonActive?(b.index)
          canChoose = true
          break
        end
        if !canChoose
          # Opponent can't switch in any Pokemon
          score -= 90
        else
          score += 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        end
      end
    #---------------------------------------------------------------------------
    when "106"
    #---------------------------------------------------------------------------
    when "107"
    #---------------------------------------------------------------------------
    when "108"
    #---------------------------------------------------------------------------
    when "109"
    #---------------------------------------------------------------------------
    when "10A"
      score += 20 if user.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      score += 20 if user.pbOpposingSide.effects[PBEffects::Reflect]>0
      score += 20 if user.pbOpposingSide.effects[PBEffects::LightScreen]>0
    #---------------------------------------------------------------------------
    when "10B"
      score += 10*(user.stages[:ACCURACY]-target.stages[:EVASION])
    #---------------------------------------------------------------------------
    when "10C"
      if user.effects[PBEffects::Substitute]>0
        score -= 90
      elsif user.hp<=user.totalhp/4
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "10D"
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
    when "10E"
      score -= 40
    #---------------------------------------------------------------------------
    when "10F"
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
    when "110"
      score += 30 if user.effects[PBEffects::Trapping]>0
      score += 30 if user.effects[PBEffects::LeechSeed]>=0
      if @battle.pbAbleNonActiveCount(user.idxOwnSide)>0
        score += 80 if user.pbOwnSide.effects[PBEffects::Spikes]>0
        score += 80 if user.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        score += 80 if user.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "111"
      if @battle.positions[target.index].effects[PBEffects::FutureSightCounter]>0
        score -= 100
      elsif @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        # Future Sight tends to be wasteful if down to last Pokemon
        score -= 70
      end
    #---------------------------------------------------------------------------
    when "112"
      avg = 0
      avg -= user.stages[:DEFENSE]*10
      avg -= user.stages[:SPECIAL_DEFENSE]*10
      score += avg/2
      if user.effects[PBEffects::Stockpile]>=3
        score -= 80
      else
        # More preferable if user also has Spit Up/Swallow
        score += 20 if user.pbHasMoveFunction?("113","114")   # Spit Up, Swallow
      end
    #---------------------------------------------------------------------------
    when "113"
      score -= 100 if user.effects[PBEffects::Stockpile]==0
    #---------------------------------------------------------------------------
    when "114"
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
    when "115"
      score += 50 if target.effects[PBEffects::HyperBeam]>0
      score -= 35 if target.hp<=target.totalhp/2   # If target is weak, no
      score -= 70 if target.hp<=target.totalhp/4   # need to risk this move
    #---------------------------------------------------------------------------
    when "116"
    #---------------------------------------------------------------------------
    when "117"
      hasAlly = false
      user.eachAlly do |b|
        hasAlly = true
        break
      end
      score -= 90 if !hasAlly
    #---------------------------------------------------------------------------
    when "118"
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
        score += 20 if target.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly, Bounce, Sky Drop
        score += 20 if target.pbHasType?(:FLYING)
        score += 20 if target.hasActiveAbility?(:LEVITATE)
        score += 20 if target.hasActiveItem?(:AIRBALLOON)
      end
    #---------------------------------------------------------------------------
    when "119"
      if user.effects[PBEffects::MagnetRise]>0 ||
         user.effects[PBEffects::Ingrain] ||
         user.effects[PBEffects::SmackDown]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "11A"
      if target.effects[PBEffects::Telekinesis]>0 ||
         target.effects[PBEffects::Ingrain] ||
         target.effects[PBEffects::SmackDown]
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "11B"
    #---------------------------------------------------------------------------
    when "11C"
      if skill>=PBTrainerAI.mediumSkill
        score += 20 if target.effects[PBEffects::MagnetRise]>0
        score += 20 if target.effects[PBEffects::Telekinesis]>0
        score += 20 if target.inTwoTurnAttack?("0C9","0CC")   # Fly, Bounce
        score += 20 if target.pbHasType?(:FLYING)
        score += 20 if target.hasActiveAbility?(:LEVITATE)
        score += 20 if target.hasActiveItem?(:AIRBALLOON)
      end
    #---------------------------------------------------------------------------
    when "11D"
    #---------------------------------------------------------------------------
    when "11E"
    #---------------------------------------------------------------------------
    when "11F"
    #---------------------------------------------------------------------------
    when "120"
    #---------------------------------------------------------------------------
    when "121"
    #---------------------------------------------------------------------------
    when "122"
    #---------------------------------------------------------------------------
    when "123"
      if !target.pbHasType?(user.type1) &&
         !target.pbHasType?(user.type2)
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "124"
    #---------------------------------------------------------------------------
    when "125"
    #---------------------------------------------------------------------------
    when "126"
      score += 20   # Shadow moves are more preferable
    #---------------------------------------------------------------------------
    when "127"
      score += 20   # Shadow moves are more preferable
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
    when "128"
      score += 20   # Shadow moves are more preferable
      if target.pbCanBurn?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET,:FLAREBOOST])
        end
      end
    #---------------------------------------------------------------------------
    when "129"
      score += 20   # Shadow moves are more preferable
      if target.pbCanFreeze?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
        end
      end
    #---------------------------------------------------------------------------
    when "12A"
      score += 20   # Shadow moves are more preferable
      if target.pbCanConfuse?(user,false)
        score += 30
      else
        if skill>=PBTrainerAI.mediumSkill
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "12B"
      score += 20   # Shadow moves are more preferable
      if !target.pbCanLowerStatStage?(:DEFENSE,user)
        score -= 90
      else
        score += 40 if user.turnCount==0
        score += target.stages[:DEFENSE]*20
      end
    #---------------------------------------------------------------------------
    when "12C"
      score += 20   # Shadow moves are more preferable
      if !target.pbCanLowerStatStage?(:EVASION,user)
        score -= 90
      else
        score += target.stages[:EVASION]*15
      end
    #---------------------------------------------------------------------------
    when "12D"
      score += 20   # Shadow moves are more preferable
    #---------------------------------------------------------------------------
    when "12E"
      score += 20   # Shadow moves are more preferable
      score += 20 if target.hp>=target.totalhp/2
      score -= 20 if user.hp<user.hp/2
    #---------------------------------------------------------------------------
    when "12F"
      score += 20   # Shadow moves are more preferable
      score -= 110 if target.effects[PBEffects::MeanLook]>=0
    #---------------------------------------------------------------------------
    when "130"
      score += 20   # Shadow moves are more preferable
      score -= 40
    #---------------------------------------------------------------------------
    when "131"
      score += 20   # Shadow moves are more preferable
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather == :ShadowSky
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "132"
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
    when "133", "134"
      score -= 95
      score = 0 if skill>=PBTrainerAI.highSkill
    #---------------------------------------------------------------------------
    when "135"
      if target.pbCanFreeze?(user,false)
        score += 30
        if skill>=PBTrainerAI.highSkill
          score -= 20 if target.hasActiveAbility?(:MARVELSCALE)
        end
      end
    #---------------------------------------------------------------------------
    when "136"
      score += 20 if user.stages[:DEFENSE]<0
    #---------------------------------------------------------------------------
    when "137"
      hasEffect = user.statStageAtMax?(:DEFENSE) &&
                  user.statStageAtMax?(:SPECIAL_DEFENSE)
      user.eachAlly do |b|
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
    when "138"
      if target.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score -= target.stages[:SPECIAL_DEFENSE]*10
      end
    #---------------------------------------------------------------------------
    when "139"
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
    when "13A"
      avg  = target.stages[:ATTACK]*10
      avg += target.stages[:SPECIAL_ATTACK]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "13B"
      if !user.isSpecies?(:HOOPA) || user.form!=1
        score -= 100
      else
        score += 20 if target.stages[:DEFENSE]>0
      end
    #---------------------------------------------------------------------------
    when "13C"
      score += 20 if target.stages[:SPECIAL_ATTACK]>0
    #---------------------------------------------------------------------------
    when "13D"
      if !target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
        score -= 90
      else
        score += 40 if user.turnCount==0
        score += target.stages[:SPECIAL_ATTACK]*20
      end
    #---------------------------------------------------------------------------
    when "13E"
      count = 0
      @battle.eachBattler do |b|
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
    when "13F"
      count = 0
      @battle.eachBattler do |b|
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
    when "140"
      count=0
      @battle.eachBattler do |b|
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
    when "141"
      if target.effects[PBEffects::Substitute]>0
        score -= 90
      else
        numpos = 0; numneg = 0
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
    when "142"
      score -= 90 if target.pbHasType?(:GHOST)
    #---------------------------------------------------------------------------
    when "143"
      score -= 90 if target.pbHasType?(:GRASS)
    #---------------------------------------------------------------------------
    when "144"
    #---------------------------------------------------------------------------
    when "145"
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      score -= 90 if aspeed>ospeed
    #---------------------------------------------------------------------------
    when "146"
    #---------------------------------------------------------------------------
    when "147"
    #---------------------------------------------------------------------------
    when "148"
      aspeed = pbRoughStat(user,:SPEED,skill)
      ospeed = pbRoughStat(target,:SPEED,skill)
      if aspeed>ospeed
        score -= 90
      else
        score += 30 if target.pbHasMoveType?(:FIRE)
      end
    #---------------------------------------------------------------------------
    when "149"
      if user.turnCount==0
        score += 30
      else
        score -= 90   # Because it will fail here
        score = 0 if skill>=PBTrainerAI.bestSkill
      end
    #---------------------------------------------------------------------------
    when "14A"
    #---------------------------------------------------------------------------
    when "14B", "14C"
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
    when "14D"
    #---------------------------------------------------------------------------
    when "14E"
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
    when "14F"
      if skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:LIQUIDOOZE)
        score -= 80
      else
        score += 40 if user.hp<=user.totalhp/2
      end
    #---------------------------------------------------------------------------
    when "150"
      score += 20 if !user.statStageAtMax?(:ATTACK) && target.hp<=target.totalhp/4
    #---------------------------------------------------------------------------
    when "151"
      avg  = target.stages[:ATTACK]*10
      avg += target.stages[:SPECIAL_ATTACK]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "152"
    #---------------------------------------------------------------------------
    when "153"
      score -= 95 if user.pbOpposingSide.effects[PBEffects::StickyWeb]
    #---------------------------------------------------------------------------
    when "154"
    #---------------------------------------------------------------------------
    when "155"
    #---------------------------------------------------------------------------
    when "156"
    #---------------------------------------------------------------------------
    when "157"
      score -= 90
    #---------------------------------------------------------------------------
    when "158"
      score -= 90 if !user.belched?
    #---------------------------------------------------------------------------
    when "159"
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
    when "15A"
      if target.opposes?(user)
        score -= 40 if target.status == :BURN
      else
        score += 40 if target.status == :BURN
      end
    #---------------------------------------------------------------------------
    when "15B"
      if target.status == :NONE
        score -= 90
      elsif user.hp==user.totalhp && target.opposes?(user)
        score -= 90
      else
        score += (user.totalhp-user.hp)*50/user.totalhp
        score -= 30 if target.opposes?(user)
      end
    #---------------------------------------------------------------------------
    when "15C"
      hasEffect = user.statStageAtMax?(:ATTACK) &&
                  user.statStageAtMax?(:SPECIAL_ATTACK)
      user.eachAlly do |b|
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
    when "15D"
      numStages = 0
      GameData::Stat.each_battle do |s|
        next if target.stages[s.id] <= 0
        numStages += target.stages[s.id]
      end
      score += numStages*20
    #---------------------------------------------------------------------------
    when "15E"
      if user.effects[PBEffects::LaserFocus]>0
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "15F"
      score += user.stages[:DEFENSE]*10
    #---------------------------------------------------------------------------
    when "160"
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
    when "161"
      if skill>=PBTrainerAI.mediumSkill
        if user.speed>target.speed
          score += 50
        else
          score -= 70
        end
      end
    #---------------------------------------------------------------------------
    when "162"
      score -= 90 if !user.pbHasType?(:FIRE)
    #---------------------------------------------------------------------------
    when "163"
    #---------------------------------------------------------------------------
    when "164"
    #---------------------------------------------------------------------------
    when "165"
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
    when "166"
    #---------------------------------------------------------------------------
    when "167"
      if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0 || @battle.pbWeather != :Hail
        score -= 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "168"
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
    when "169"
    #---------------------------------------------------------------------------
    when "16A"
      hasAlly = false
      target.eachAlly do |b|
        hasAlly = true
        break
      end
      score -= 90 if !hasAlly
    #---------------------------------------------------------------------------
    when "16B"
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
    when "16C"
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
    when "16D"
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp*100/user.totalhp
        score += 30 if @battle.pbWeather == :Sandstorm
      end
    #---------------------------------------------------------------------------
    when "16E"
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
    when "16F"
      if !target.opposes?(user)
        if target.hp==target.totalhp || (skill>=PBTrainerAI.mediumSkill && !target.canHeal?)
          score -= 90
        else
          score += 50
          score -= target.hp*100/target.totalhp
        end
      end
    #---------------------------------------------------------------------------
    when "170"
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif skill>=PBTrainerAI.mediumSkill && reserves==0 && foes>0
        score -= 100   # don't want to lose
      elsif skill>=PBTrainerAI.highSkill && reserves==0 && foes==0
        score += 80   # want to draw
      else
        score -= (user.total.hp-user.hp)*75/user.totalhp
      end
    #---------------------------------------------------------------------------
    when "171"
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
    when "172"
      score += 20   # Because of possible burning
    #---------------------------------------------------------------------------
    when "173"
    #---------------------------------------------------------------------------
    when "174"
      score -= 90 if user.turnCount > 0
    #---------------------------------------------------------------------------
    when "175"
      score += 30 if target.effects[PBEffects::Minimize]
    #---------------------------------------------------------------------------
    end
    return score
  end
end
