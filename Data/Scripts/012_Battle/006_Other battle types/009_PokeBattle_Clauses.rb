#===============================================================================
# This script modifies the battle system to implement battle rules
#===============================================================================
class PokeBattle_Battle
  unless @__clauses__aliased
    alias __clauses__pbDecisionOnDraw pbDecisionOnDraw
    alias __clauses__pbEndOfRoundPhase pbEndOfRoundPhase
    @__clauses__aliased = true
  end

  def pbDecisionOnDraw
    if @rules["selfkoclause"]
      if self.lastMoveUser<0
        # in extreme cases there may be no last move user
        return 5   # game is a draw
      elsif opposes?(self.lastMoveUser)
        return 2   # loss
      else
        return 1   # win
      end
    end
    return __clauses__pbDecisionOnDraw
  end

  def pbJudgeCheckpoint(user,move=nil)
    if pbAllFainted?(0) && pbAllFainted?(1)
      if @rules["drawclause"]   # NOTE: Also includes Life Orb (not implemented)
        if !(move && move.function=="0DD")   # Not a draw if fainting occurred due to Liquid Ooze
          @decision = (user.opposes?) ? 1 : 2   # win / loss
        end
      elsif @rules["modifiedselfdestructclause"]
        if move && move.function=="0E0"   # Self-Destruct
          @decision = (user.opposes?) ? 1 : 2   # win / loss
        end
      end
    end
  end

  def pbEndOfRoundPhase
    __clauses__pbEndOfRoundPhase
    if @rules["suddendeath"] && @decision==0
      p1able = pbAbleCount(0)
      p2able = pbAbleCount(1)
      if p1able>p2able;    @decision = 1   # loss
      elsif p1able<p2able; @decision = 2   # win
      end
    end
  end
end



class PokeBattle_Battler
  unless @__clauses__aliased
    alias __clauses__pbCanSleep? pbCanSleep?
    alias __clauses__pbCanSleepYawn? pbCanSleepYawn?
    alias __clauses__pbCanFreeze? pbCanFreeze?
    alias __clauses__pbUseMove pbUseMove
    @__clauses__aliased = true
  end

  def pbCanSleep?(user,showMessages,move=nil,ignoreStatus=false)
    selfsleep = (user && user.index==@index)
    if ((@battle.rules["modifiedsleepclause"]) || (!selfsleep && @battle.rules["sleepclause"])) &&
       pbHasStatusPokemon?(:SLEEP)
      if showMessages
        @battle.pbDisplay(_INTL("But {1} couldn't sleep!",pbThis(true)))
      end
      return false
    end
    return __clauses__pbCanSleep?(user,showMessages,move,ignoreStatus)
  end

  def pbCanSleepYawn?
    if (@battle.rules["sleepclause"] || @battle.rules["modifiedsleepclause"]) &&
       pbHasStatusPokemon?(:SLEEP)
      return false
    end
    return __clauses__pbCanSleepYawn?
  end

  def pbCanFreeze?(*arg)
    if @battle.rules["freezeclause"] && pbHasStatusPokemon?(:FROZEN)
      return false
    end
    return __clauses__pbCanFreeze?(*arg)
  end

  def pbHasStatusPokemon?(status)
    count = 0
    @battle.pbParty(@index).each do |pkmn|
      next if !pkmn || pkmn.egg?
      next if pkmn.status!=status
      count += 1
    end
    return count>0
  end
end



class PokeBattle_Move_022   # Double Team
  alias __clauses__pbMoveFailed? pbMoveFailed?

  def pbMoveFailed?(user,targets)
    if !damagingMove? && @battle.rules["evasionclause"]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return __clauses__pbMoveFailed?(user,targets)
  end
end



class PokeBattle_Move_034   # Minimize
  alias __clauses__pbMoveFailed? pbMoveFailed?

  def pbMoveFailed?(user,targets)
    if !damagingMove? && @battle.rules["evasionclause"]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return __clauses__pbMoveFailed?(user,targets)
  end
end



class PokeBattle_Move_067   # Skill Swap
  alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?

  def pbFailsAgainstTarget?(user,target)
    if @battle.rules["skillswapclause"]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user,target)
  end
end



class PokeBattle_Move_06A   # Sonic Boom
  alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?

  def pbFailsAgainstTarget?(user,target)
    if @battle.rules["sonicboomclause"]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user,target)
  end
end



class PokeBattle_Move_06B   # Dragon Rage
  alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?

  def pbFailsAgainstTarget?(user,target)
    if @battle.rules["sonicboomclause"]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user,target)
  end
end



class PokeBattle_Move_070   # OHKO moves
  alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?

  def pbFailsAgainstTarget?(user,target)
    if @battle.rules["ohkoclause"]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user,target)
  end
end



class PokeBattle_Move_0E0   # Self-Destruct
  unless @__clauses__aliased
    alias __clauses__pbMoveFailed? pbMoveFailed?
    @__clauses__aliased = true
  end

  def pbMoveFailed?(user,targets)
    if @battle.rules["selfkoclause"]
      # Check whether no unfainted Pokemon remain in either party
      count  = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      count += @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if count==0
        @battle.pbDisplay("But it failed!")
        return false
      end
    end
    if @battle.rules["selfdestructclause"]
      # Check whether no unfainted Pokemon remain in either party
      count  = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      count += @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if count==0
        @battle.pbDisplay(_INTL("{1}'s team was disqualified!",user.pbThis))
        @battle.decision = (user.opposes?) ? 1 : 2
        return false
      end
    end
    return __clauses__pbMoveFailed?(user,targets)
  end
end



class PokeBattle_Move_0E5   # Perish Song
  alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?

  def pbFailsAgainstTarget?(user,target)
    if @battle.rules["perishsongclause"] &&
       @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user,target)
  end
end



class PokeBattle_Move_0E7   # Destiny Bond
  alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?

  def pbFailsAgainstTarget?(user,target)
    if @battle.rules["perishsongclause"] &&
       @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user,target)
  end
end
