class PokeBattle_AI
  alias __f__pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctionCode(score,move,user,target,skill=100)
    score = __f__pbGetMoveScoreFunctionCode(score,move,user,target,skill)
    case move.function
    #---------------------------------------------------------------------------
    when "140"
      count=0
      @battle.eachBattler do |b|
        if b.poisoned? &&
           (!b.statStageAtMin?(PBStats::ATTACK) ||
           !b.statStageAtMin?(PBStats::SPATK) ||
           !b.statStageAtMin?(PBStats::SPEED))
          count += 1
          if user.opposes?(b)
            score += user.stages[PBStats::ATTACK]*10
            score += user.stages[PBStats::SPATK]*10
            score += user.stages[PBStats::SPEED]*10
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
        PBStats.eachBattleStat do |s|
          numpos += target.stages[s] if target.stages[s]>0
          numneg += target.stages[s] if target.stages[s]<0
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
      aspeed = pbRoughStat(user,PBStats::SPEED,skill)
      ospeed = pbRoughStat(target,PBStats::SPEED,skill)
      score -= 90 if aspeed>ospeed
    #---------------------------------------------------------------------------
    when "146"
    #---------------------------------------------------------------------------
    when "147"
    #---------------------------------------------------------------------------
    when "148"
      aspeed = pbRoughStat(user,PBStats::SPEED,skill)
      ospeed = pbRoughStat(target,PBStats::SPEED,skill)
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
        score += 30 if target.effects[PBEffects::TwoTurnAttack]>0
      end
    #---------------------------------------------------------------------------
    when "14D"
    #---------------------------------------------------------------------------
    when "14E"
      if user.statStageAtMax?(PBStats::SPATK) &&
         user.statStageAtMax?(PBStats::SPDEF) &&
         user.statStageAtMax?(PBStats::SPEED)
        score -= 90
      else
        score -= user.stages[PBStats::SPATK]*10   # Only *10 isntead of *20
        score -= user.stages[PBStats::SPDEF]*10   # because two-turn attack
        score -= user.stages[PBStats::SPEED]*10
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
          aspeed = pbRoughStat(user,PBStats::SPEED,skill)
          ospeed = pbRoughStat(target,PBStats::SPEED,skill)
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
      score += 20 if !user.statStageAtMax?(PBStats::ATTACK) && target.hp<=target.totalhp/4
    #---------------------------------------------------------------------------
    when "151"
      avg  = target.stages[PBStats::ATTACK]*10
      avg += target.stages[PBStats::SPATK]*10
      score += avg/2
    #---------------------------------------------------------------------------
    when "152"
    #---------------------------------------------------------------------------
    when "153"
      score -= 95 if target.pbOwnSide.effects[PBEffects::StickyWeb]
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
      if !target.pbCanPoison?(user,false) && !target.pbCanLowerStatStage?(PBStats::SPEED,user)
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
            score += 10 if pbRoughStat(target,PBStats::DEFENSE,skill)>100
            score += 10 if pbRoughStat(target,PBStats::SPDEF,skill)>100
            score -= 40 if target.hasActiveAbility?([:GUTS,:MARVELSCALE,:TOXICBOOST])
          end
        end
        if target.pbCanLowerStatStage?(PBStats::SPEED,user)
          score += target.stages[PBStats::SPEED]*10
          if skill>=PBTrainerAI.highSkill
            aspeed = pbRoughStat(user,PBStats::SPEED,skill)
            ospeed = pbRoughStat(target,PBStats::SPEED,skill)
            score += 30 if aspeed<ospeed && aspeed*2>ospeed
          end
        end
      end
    #---------------------------------------------------------------------------
    when "15A"
      if target.opposes?(user)
        score -= 40 if target.status==PBStatuses::BURN
      else
        score += 40 if target.status==PBStatuses::BURN
      end
    #---------------------------------------------------------------------------
    when "15B"
      if target.status==PBStatuses::NONE
        score -= 90
      elsif user.hp==user.totalhp && target.opposes?(user)
        score -= 90
      else
        score += (user.totalhp-user.hp)*50/user.totalhp
        score -= 30 if target.opposes?(user)
      end
    #---------------------------------------------------------------------------
    when "15C"
      hasEffect = user.statStageAtMax?(PBStats::ATTACK) &&
                  user.statStageAtMax?(PBStats::SPATK)
      user.eachAlly do |b|
        next if b.statStageAtMax?(PBStats::ATTACK) && b.statStageAtMax?(PBStats::SPATK)
        hasEffect = true
        score -= b.stages[PBStats::ATTACK]*10
        score -= b.stages[PBStats::SPATK]*10
      end
      if hasEffect
        score -= user.stages[PBStats::ATTACK]*10
        score -= user.stages[PBStats::SPATK]*10
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "15D"
      numStages = 0
      PBStats.eachBattleStat do |s|
        next if target.stages[s]<=0
        numStages += target.stages[s]
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
      score += user.stages[PBStats::DEFENSE]*10
    #---------------------------------------------------------------------------
    when "160"
      if target.statStageAtMin?(PBStats::ATTACK)
        score -= 90
      else
        if target.pbCanLowerStatStage?(PBStats::ATTACK,user)
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
         userSpeed   = pbRoughStat(user,PBStats::SPEED,skill)
         targetSpeed = pbRoughStat(target,PBStats::SPEED,skill)
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
      if user.pbOwnSide.effects[PBEffects::AuroraVeil]>0 || @battle.pbWeather!=PBWeather::Hail
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
        score += 30 if target.effects[PBEffects::TwoTurnAttack]>0
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
        if target.lastRegularMoveUsed<0 ||
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
        score += 30 if @battle.pbWeather==PBWeather::Sandstorm
      end
    #---------------------------------------------------------------------------
    when "16E"
      if user.hp==user.totalhp || (skill>=PBTrainerAI.mediumSkill && !user.canHeal?)
        score -= 90
      else
        score += 50
        score -= user.hp*100/user.totalhp
        if skill>=PBTrainerAI.mediumSkill
          score += 30 if @battle.field.terrain==PBBattleTerrains::Grassy
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
      score -= 90 if user.turnCount>0 || user.lastRoundMoved>=0
    #---------------------------------------------------------------------------
    when "175"
      score += 30 if target.effects[PBEffects::Minimize]
    #---------------------------------------------------------------------------
    end
    return score
  end
end
