class PokeBattle_StatUpMove < PokeBattle_Move
  attr_reader :statUp
end

class PokeBattle_MultiStatUpMove < PokeBattle_Move
  attr_reader :statUp
end

#===============================================================================
# Battle Palace AI.
#===============================================================================
class PokeBattle_AI
  alias _battlePalace_pbEnemyShouldWithdraw? pbEnemyShouldWithdraw?

  def pbEnemyShouldWithdraw?
    return _battlePalace_pbEnemyShouldWithdraw? if !@battlePalace
    shouldswitch = false
    if @user.effects[PBEffects::PerishSong]==1
      shouldswitch = true
    elsif !@battle.pbCanChooseAnyMove?(@user.index) &&
       @user.turnCount && @user.turnCount>5
      shouldswitch = true
    else
      hppercent = @user.hp*100/@user.totalhp
      percents = []
      maxindex = -1
      maxpercent = 0
      factor = 0
      @battle.pbParty(@user.index).each_with_index do |pkmn,i|
        if @battle.pbCanSwitch?(@user.index,i)
          percents[i] = 100*pkmn.hp/pkmn.totalhp
          if percents[i]>maxpercent
            maxindex = i
            maxpercent = percents[i]
          end
        else
          percents[i] = 0
        end
      end
      if hppercent<50
        factor = (maxpercent<hppercent) ? 20 : 40
      end
      if hppercent<25
        factor = (maxpercent<hppercent) ? 30 : 50
      end
      case @user.status
      when PBStatuses::SLEEP, PBStatuses::FROZEN
        factor += 20
      when PBStatuses::POISON, PBStatuses::BURN
        factor += 10
      when PBStatuses::PARALYSIS
        factor += 15
      end
      if @justswitched[@user.index]
        factor -= 60
        factor = 0 if factor<0
      end
      shouldswitch = (pbAIRandom(100)<factor)
      if shouldswitch && maxindex>=0
        @battle.pbRegisterSwitch(@user.index,maxindex)
        return true
      end
    end
    @justswitched[@user.index] = shouldswitch
    if shouldswitch
      @battle.pbParty(@user.index).each_with_index do |_pkmn,i|
        next if !@battle.pbCanSwitch?(@user.index,i)
        @battle.pbRegisterSwitch(@user.index,i)
        return true
      end
    end
    return false
  end
end

#===============================================================================
# Battle Arena AI.
#===============================================================================
class PokeBattle_AI
  alias _battleArena_pbEnemyShouldWithdraw? pbEnemyShouldWithdraw?

  def pbEnemyShouldWithdraw?
    return _battleArena_pbEnemyShouldWithdraw? if !@battleArena
    return false
  end
end
