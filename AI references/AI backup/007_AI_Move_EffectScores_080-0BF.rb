class PokeBattle_AI
  alias __c__pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctionCode(score,move,user,target,skill=100)
    score = __c__pbGetMoveScoreFunctionCode(score,move,user,target,skill)
    case move.function
    #---------------------------------------------------------------------------
    when "080"
    #---------------------------------------------------------------------------
    when "081"
      attspeed = pbRoughStat(user,PBStats::SPEED,skill)
      oppspeed = pbRoughStat(target,PBStats::SPEED,skill)
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
      attspeed = pbRoughStat(user,PBStats::SPEED,skill)
      oppspeed = pbRoughStat(target,PBStats::SPEED,skill)
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
      score -= 90 if !pbIsBerry?(user.item) || !user.itemActive?
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
      elsif target.stages[PBStats::EVASION]<=0
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "0A8"
      if target.effects[PBEffects::MiracleEye]
        score -= 90
      elsif target.pbHasType?(:DARK)
        score += 70
      elsif target.stages[PBStats::EVASION]<=0
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
        score += 30 if target.effects[PBEffects::TwoTurnAttack]>0
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
        score -= 100 if target.lastRegularMoveUsed<=0 ||
           !pbGetMoveData(target.lastRegularMoveUsed,MOVE_FLAGS)[/e/]   # Not copyable by Mirror Move
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
      aspeed = pbRoughStat(user,PBStats::SPEED,skill)
      ospeed = pbRoughStat(target,PBStats::SPEED,skill)
      if target.effects[PBEffects::Encore]>0
        score -= 90
      elsif aspeed>ospeed
        if target.lastMoveUsed<=0
          score -= 90
        else
          moveData = pbGetMoveData(target.lastRegularMoveUsed)
          if moveData[MOVE_CATEGORY]==2 &&   # Status move
             (moveData[MOVE_TARGET]==PBTargets::User ||
             moveData[MOVE_TARGET]==PBTargets::BothSides)
            score += 60
          elsif moveData[MOVE_CATEGORY]!=2 &&   # Damaging move
             moveData[MOVE_TARGET]==PBTargets::NearOther &&
             PBTypes.ineffective?(pbCalcTypeMod(moveData[MOVE_TYPE],target,user))
            score += 60
          end
        end
      end
    #---------------------------------------------------------------------------
    when "0BD"
    #---------------------------------------------------------------------------
    when "0BF"
    #---------------------------------------------------------------------------
    end
    return score
  end
end
