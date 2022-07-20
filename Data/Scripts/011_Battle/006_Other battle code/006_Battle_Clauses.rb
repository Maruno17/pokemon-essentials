#===============================================================================
# This script modifies the battle system to implement battle rules
#===============================================================================
class Battle
  unless @__clauses__aliased
    alias __clauses__pbDecisionOnDraw pbDecisionOnDraw
    alias __clauses__pbEndOfRoundPhase pbEndOfRoundPhase
    @__clauses__aliased = true
  end

  def pbDecisionOnDraw
    if @rules["selfkoclause"]
      if self.lastMoveUser < 0
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

  def pbJudgeCheckpoint(user, move = nil)
    if pbAllFainted?(0) && pbAllFainted?(1)
      if @rules["drawclause"]   # NOTE: Also includes Life Orb (not implemented)
        if !(move && move.function == "HealUserByHalfOfDamageDone")
          # Not a draw if fainting occurred due to Liquid Ooze
          @decision = (user.opposes?) ? 1 : 2   # win / loss
        end
      elsif @rules["modifiedselfdestructclause"]
        if move && move.function == "UserFaintsExplosive"   # Self-Destruct
          @decision = (user.opposes?) ? 1 : 2   # win / loss
        end
      end
    end
  end

  def pbEndOfRoundPhase
    __clauses__pbEndOfRoundPhase
    if @rules["suddendeath"] && @decision == 0
      p1able = pbAbleCount(0)
      p2able = pbAbleCount(1)
      if p1able > p2able
        @decision = 1   # loss
      elsif p1able < p2able
        @decision = 2   # win
      end
    end
  end
end



class Battle::Battler
  unless @__clauses__aliased
    alias __clauses__pbCanSleep? pbCanSleep?
    alias __clauses__pbCanSleepYawn? pbCanSleepYawn?
    alias __clauses__pbCanFreeze? pbCanFreeze?
    alias __clauses__pbUseMove pbUseMove
    @__clauses__aliased = true
  end

  def pbCanSleep?(user, showMessages, move = nil, ignoreStatus = false)
    selfsleep = (user && user.index == @index)
    if ((@battle.rules["modifiedsleepclause"]) || (!selfsleep && @battle.rules["sleepclause"])) &&
       pbHasStatusPokemon?(:SLEEP)
      if showMessages
        @battle.pbDisplay(_INTL("But {1} couldn't sleep!", pbThis(true)))
      end
      return false
    end
    return __clauses__pbCanSleep?(user, showMessages, move, ignoreStatus)
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
      next if pkmn.status != status
      count += 1
    end
    return count > 0
  end
end



class Battle::Move::RaiseUserEvasion1   # Double Team
  unless method_defined?(:__clauses__pbMoveFailed?)
    alias __clauses__pbMoveFailed? pbMoveFailed?
  end

  def pbMoveFailed?(user, targets)
    if !damagingMove? && @battle.rules["evasionclause"]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return __clauses__pbMoveFailed?(user, targets)
  end
end



class Battle::Move::RaiseUserEvasion2MinimizeUser   # Minimize
  unless method_defined?(:__clauses__pbMoveFailed?)
    alias __clauses__pbMoveFailed? pbMoveFailed?
  end

  def pbMoveFailed?(user, targets)
    if !damagingMove? && @battle.rules["evasionclause"]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return __clauses__pbMoveFailed?(user, targets)
  end
end



class Battle::Move::UserTargetSwapAbilities   # Skill Swap
  unless method_defined?(:__clauses__pbFailsAgainstTarget?)
    alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if @battle.rules["skillswapclause"]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user, target, show_message)
  end
end



class Battle::Move::FixedDamage20   # Sonic Boom
  unless method_defined?(:__clauses__pbFailsAgainstTarget?)
    alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if @battle.rules["sonicboomclause"]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user, target, show_message)
  end
end



class Battle::Move::FixedDamage40   # Dragon Rage
  unless method_defined?(:__clauses__pbFailsAgainstTarget?)
    alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if @battle.rules["sonicboomclause"]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user, target, show_message)
  end
end



class Battle::Move::OHKO
  unless method_defined?(:__clauses__pbFailsAgainstTarget?)
    alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if @battle.rules["ohkoclause"]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user, target, show_message)
  end
end



class Battle::Move::OHKOIce
  unless method_defined?(:__clauses__pbFailsAgainstTarget?)
    alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if @battle.rules["ohkoclause"]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user, target, show_message)
  end
end



class Battle::Move::OHKOHitsUndergroundTarget
  unless method_defined?(:__clauses__pbFailsAgainstTarget?)
    alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if @battle.rules["ohkoclause"]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user, target, show_message)
  end
end



class Battle::Move::UserFaintsExplosive   # Self-Destruct
  unless method_defined?(:__clauses__pbMoveFailed?)
    alias __clauses__pbMoveFailed? pbMoveFailed?
  end

  def pbMoveFailed?(user, targets)
    if @battle.rules["selfkoclause"]
      # Check whether no unfainted Pokemon remain in either party
      count  = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      count += @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if count == 0
        @battle.pbDisplay("But it failed!")
        return false
      end
    end
    if @battle.rules["selfdestructclause"]
      # Check whether no unfainted Pokemon remain in either party
      count  = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      count += @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if count == 0
        @battle.pbDisplay(_INTL("{1}'s team was disqualified!", user.pbThis))
        @battle.decision = (user.opposes?) ? 1 : 2
        return false
      end
    end
    return __clauses__pbMoveFailed?(user, targets)
  end
end



class Battle::Move::StartPerishCountsForAllBattlers   # Perish Song
  unless method_defined?(:__clauses__pbFailsAgainstTarget?)
    alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if @battle.rules["perishsongclause"] &&
       @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user, target, show_message)
  end
end



class Battle::Move::AttackerFaintsIfUserFaints   # Destiny Bond
  unless method_defined?(:__clauses__pbFailsAgainstTarget?)
    alias __clauses__pbFailsAgainstTarget? pbFailsAgainstTarget?
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if @battle.rules["perishsongclause"] &&
       @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return __clauses__pbFailsAgainstTarget?(user, target, show_message)
  end
end
