class PokeBattle_AI
  alias __d__pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  def pbGetMoveScoreFunctionCode(score,move,user,target,skill=100)
    score = __d__pbGetMoveScoreFunctionCode(score,move,user,target,skill)
    case move.function
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
        when PBWeather::Sun, PBWeather::HarshSun
          score += 30
        when PBWeather::None
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
        score += 30 if user.status!=0
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
      if !target.pbCanLowerStatStage?(PBStats::ATTACK,user) &&
         !target.pbCanLowerStatStage?(PBStats::SPATK,user)
        score -= 100
      elsif @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
        score -= 100
      else
        score += target.stages[PBStats::ATTACK]*10
        score += target.stages[PBStats::SPATK]*10
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
        PBStats.eachBattleStat { |s| total += user.stages[s] }
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
        score += 20 if target.item!=0
      end
    #---------------------------------------------------------------------------
    when "0F1"
      if skill>=PBTrainerAI.highSkill
        if user.item==0 && target.item!=0
          score += 40
        else
          score -= 90
        end
      else
        score -= 80
      end
    #---------------------------------------------------------------------------
    when "0F2"
      if user.item==0 && target.item==0
        score -= 90
      elsif skill>=PBTrainerAI.highSkill && target.hasActiveAbility?(:STICKYHOLD)
        score -= 90
      elsif user.hasActiveItem?([:FLAMEORB,:TOXICORB,:STICKYBARB,:IRONBALL,
                                 :CHOICEBAND,:CHOICESCARF,:CHOICESPECS])
        score += 50
      elsif user.item==0 && target.item!=0
        score -= 30 if pbGetMoveData(user.lastMoveUsed,MOVE_FUNCTION_CODE)=="0F2"   # Trick/Switcheroo
      end
    #---------------------------------------------------------------------------
    when "0F3"
      if user.item==0 || target.item!=0
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
        if skill>=PBTrainerAI.highSkill && pbIsBerry?(target.item)
          score += 30
        end
      end
    #---------------------------------------------------------------------------
    when "0F6"
      if user.recycleItem==0 || user.item!=0
        score -= 80
      elsif user.recycleItem!=0
        score += 30
      end
    #---------------------------------------------------------------------------
    when "0F7"
      if user.item==0 || !user.itemActive? ||
         user.unlosableItem?(user.item) || pbIsPokeBall?(user.item)
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
        score += 30 if user.item==0 && target.item!=0
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
      elsif @battle.pbWeather==PBWeather::Sun
        score -= 90
      else
        user.eachMove do |m|
          next if !m.damagingMove? || !isConst?(m.type,PBTypes,:FIRE)
          score += 20
        end
      end
    #---------------------------------------------------------------------------
    end
    return score
  end
end
