class PokeBattle_AI
  alias __e__pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctionCode(score,move,user,target,skill=100)
    score = __e__pbGetMoveScoreFunctionCode(score,move,user,target,skill)
    case move.function
    #---------------------------------------------------------------------------
    when "100"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather==PBWeather::Rain
        score -= 90
      else
        user.eachMove do |m|
          next if !m.damagingMove? || !isConst?(m.type,PBTypes,:WATER)
          score += 20
        end
      end
    #---------------------------------------------------------------------------
    when "101"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather==PBWeather::Sandstorm
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "102"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.pbWeather==PBWeather::Hail
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
      score += 10*(user.stages[PBStats::ACCURACY]-target.stages[PBStats::EVASION])
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
        avg  = user.stages[PBStats::SPEED]*10
        avg -= user.stages[PBStats::ATTACK]*10
        avg -= user.stages[PBStats::DEFENSE]*10
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
      avg -= user.stages[PBStats::DEFENSE]*10
      avg -= user.stages[PBStats::SPDEF]*10
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
      if !target.pbCanLowerStatStage?(PBStats::DEFENSE,user)
        score -= 90
      else
        score += 40 if user.turnCount==0
        score += target.stages[PBStats::DEFENSE]*20
      end
    #---------------------------------------------------------------------------
    when "12C"
      score += 20   # Shadow moves are more preferable
      if !target.pbCanLowerStatStage?(PBStats::EVASION,user)
        score -= 90
      else
        score += target.stages[PBStats::EVASION]*15
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
      elsif @battle.pbWeather==PBWeather::ShadowSky
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
      score += 20 if user.stages[PBStats::DEFENSE]<0
    #---------------------------------------------------------------------------
    when "137"
      hasEffect = user.statStageAtMax?(PBStats::DEFENSE) &&
                  user.statStageAtMax?(PBStats::SPDEF)
      user.eachAlly do |b|
        next if b.statStageAtMax?(PBStats::DEFENSE) && b.statStageAtMax?(PBStats::SPDEF)
        hasEffect = true
        score -= b.stages[PBStats::DEFENSE]*10
        score -= b.stages[PBStats::SPDEF]*10
      end
      if hasEffect
        score -= user.stages[PBStats::DEFENSE]*10
        score -= user.stages[PBStats::SPDEF]*10
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "138"
      if target.statStageAtMax?(PBStats::SPDEF)
        score -= 90
      else
        score -= target.stages[PBStats::SPDEF]*10
      end
    #---------------------------------------------------------------------------
    when "139"
      if !target.pbCanLowerStatStage?(PBStats::ATTACK,user)
        score -= 90
      else
        score += target.stages[PBStats::ATTACK]*20
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
      avg  = target.stages[PBStats::ATTACK]*10
      avg += target.stages[PBStats::SPATK]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "13B"
      if !user.isSpecies?(:HOOPA) || user.form!=1
        score -= 100
      else
        score += 20 if target.stages[PBStats::DEFENSE]>0
      end
    #---------------------------------------------------------------------------
    when "13C"
      score += 20 if target.stages[PBStats::SPATK]>0
    #---------------------------------------------------------------------------
    when "13D"
      if !target.pbCanLowerStatStage?(PBStats::SPATK,user)
        score -= 90
      else
        score += 40 if user.turnCount==0
        score += target.stages[PBStats::SPATK]*20
      end
    #---------------------------------------------------------------------------
    when "13E"
      count = 0
      @battle.eachBattler do |b|
        if b.pbHasType?(:GRASS) && !b.airborne? &&
           (!b.statStageAtMax?(PBStats::ATTACK) || !b.statStageAtMax?(PBStats::SPATK))
          count += 1
          if user.opposes?(b)
            score -= 20
          else
            score -= user.stages[PBStats::ATTACK]*10
            score -= user.stages[PBStats::SPATK]*10
          end
        end
      end
      score -= 95 if count==0
    #---------------------------------------------------------------------------
    when "13F"
      count = 0
      @battle.eachBattler do |b|
        if b.pbHasType?(:GRASS) && !b.statStageAtMax?(PBStats::DEFENSE)
          count += 1
          if user.opposes?(b)
            score -= 20
          else
            score -= user.stages[PBStats::DEFENSE]*10
          end
        end
      end
      score -= 95 if count==0
    #---------------------------------------------------------------------------
    end
    return score
  end
end
