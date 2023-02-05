class Battle
  #=============================================================================
  # Attack phase actions
  #=============================================================================
  # Quick Claw, Custap Berry's "X let it move first!" message.
  def pbAttackPhasePriorityChangeMessages
    pbPriority.each do |b|
      if b.effects[PBEffects::PriorityAbility] && b.abilityActive?
        Battle::AbilityEffects.triggerPriorityBracketUse(b.ability, b, self)
      elsif b.effects[PBEffects::PriorityItem] && b.itemActive?
        Battle::ItemEffects.triggerPriorityBracketUse(b.item, b, self)
      end
    end
  end

  def pbAttackPhaseCall
    pbPriority.each do |b|
      next unless @choices[b.index][0] == :Call && !b.fainted?
      b.lastMoveFailed = false   # Counts as a successful move for Stomping Tantrum
      pbCall(b.index)
    end
  end

  def pbPursuit(idxSwitcher)
    @switching = true
    pbPriority.each do |b|
      next if b.fainted? || !b.opposes?(idxSwitcher)   # Shouldn't hit an ally
      next if b.movedThisRound? || !pbChoseMoveFunctionCode?(b.index, "PursueSwitchingFoe")
      # Check whether Pursuit can be used
      next unless pbMoveCanTarget?(b.index, idxSwitcher, @choices[b.index][2].pbTarget(b))
      next unless pbCanChooseMove?(b.index, @choices[b.index][1], false)
      next if b.status == :SLEEP || b.status == :FROZEN
      next if b.effects[PBEffects::SkyDrop] >= 0
      next if b.hasActiveAbility?(:TRUANT) && b.effects[PBEffects::Truant]
      # Mega Evolve
      if !b.wild?
        owner = pbGetOwnerIndexFromBattlerIndex(b.index)
        pbMegaEvolve(b.index) if @megaEvolution[b.idxOwnSide][owner] == b.index
      end
      # Use Pursuit
      @choices[b.index][3] = idxSwitcher   # Change Pursuit's target
      b.pbProcessTurn(@choices[b.index], false)
      break if @decision > 0 || @battlers[idxSwitcher].fainted?
    end
    @switching = false
  end

  def pbAttackPhaseSwitch
    pbPriority.each do |b|
      next unless @choices[b.index][0] == :SwitchOut && !b.fainted?
      idxNewPkmn = @choices[b.index][1]   # Party index of Pokémon to switch to
      b.lastMoveFailed = false   # Counts as a successful move for Stomping Tantrum
      @lastMoveUser = b.index
      # Switching message
      pbMessageOnRecall(b)
      # Pursuit interrupts switching
      pbPursuit(b.index)
      return if @decision > 0
      # Switch Pokémon
      allBattlers.each do |b2|
        b2.droppedBelowHalfHP = false
        b2.statsDropped = false
      end
      pbRecallAndReplace(b.index, idxNewPkmn)
      pbOnBattlerEnteringBattle(b.index, true)
    end
  end

  def pbAttackPhaseItems
    pbPriority.each do |b|
      next unless @choices[b.index][0] == :UseItem && !b.fainted?
      b.lastMoveFailed = false   # Counts as a successful move for Stomping Tantrum
      item = @choices[b.index][1]
      next if !item
      case GameData::Item.get(item).battle_use
      when 1, 2   # Use on Pokémon/Pokémon's move
        pbUseItemOnPokemon(item, @choices[b.index][2], b) if @choices[b.index][2] >= 0
      when 3      # Use on battler
        pbUseItemOnBattler(item, @choices[b.index][2], b)
      when 4      # Use Poké Ball
        pbUsePokeBallInBattle(item, @choices[b.index][2], b)
      when 5      # Use directly
        pbUseItemInBattle(item, @choices[b.index][2], b)
      else
        next
      end
      return if @decision > 0
    end
    pbCalculatePriority if Settings::RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES
  end

  def pbAttackPhaseMegaEvolution
    pbPriority.each do |b|
      next if b.wild?
      next unless @choices[b.index][0] == :UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @megaEvolution[b.idxOwnSide][owner] != b.index
      pbMegaEvolve(b.index)
    end
  end

  def pbAttackPhaseMoves
    # Show charging messages (Focus Punch)
    pbPriority.each do |b|
      next unless @choices[b.index][0] == :UseMove && !b.fainted?
      next if b.movedThisRound?
      @choices[b.index][2].pbDisplayChargeMessage(b)
    end
    # Main move processing loop
    loop do
      priority = pbPriority
      # Forced to go next
      advance = false
      priority.each do |b|
        next unless b.effects[PBEffects::MoveNext] && !b.fainted?
        next unless @choices[b.index][0] == :UseMove || @choices[b.index][0] == :Shift
        next if b.movedThisRound?
        advance = b.pbProcessTurn(@choices[b.index])
        break if advance
      end
      return if @decision > 0
      next if advance
      # Regular priority order
      priority.each do |b|
        next if b.effects[PBEffects::Quash] > 0 || b.fainted?
        next unless @choices[b.index][0] == :UseMove || @choices[b.index][0] == :Shift
        next if b.movedThisRound?
        advance = b.pbProcessTurn(@choices[b.index])
        break if advance
      end
      return if @decision > 0
      next if advance
      # Quashed
      if Settings::MECHANICS_GENERATION >= 8
        priority.each do |b|
          next unless b.effects[PBEffects::Quash] > 0 && !b.fainted?
          next unless @choices[b.index][0] == :UseMove || @choices[b.index][0] == :Shift
          next if b.movedThisRound?
          advance = b.pbProcessTurn(@choices[b.index])
          break if advance
        end
      else
        quashLevel = 0
        loop do
          quashLevel += 1
          moreQuash = false
          priority.each do |b|
            moreQuash = true if b.effects[PBEffects::Quash] > quashLevel
            next unless b.effects[PBEffects::Quash] == quashLevel && !b.fainted?
            next unless @choices[b.index][0] == :UseMove || @choices[b.index][0] == :Shift
            next if b.movedThisRound?
            advance = b.pbProcessTurn(@choices[b.index])
            break
          end
          break if advance || !moreQuash
        end
      end
      return if @decision > 0
      next if advance
      # Check for all done
      priority.each do |b|
        next if b.fainted?
        next if b.movedThisRound? || ![:UseMove, :Shift].include?(@choices[b.index][0])
        advance = true
        break
      end
      next if advance
      # All Pokémon have moved; end the loop
      break
    end
  end

  #=============================================================================
  # Attack phase
  #=============================================================================
  def pbAttackPhase
    @scene.pbBeginAttackPhase
    # Reset certain effects
    @battlers.each_with_index do |b, i|
      next if !b
      b.turnCount += 1 if !b.fainted?
      @successStates[i].clear
      if @choices[i][0] != :UseMove && @choices[i][0] != :Shift && @choices[i][0] != :SwitchOut
        b.effects[PBEffects::DestinyBond] = false
        b.effects[PBEffects::Grudge]      = false
      end
      b.effects[PBEffects::Rage] = false if !pbChoseMoveFunctionCode?(i, "StartRaiseUserAtk1WhenDamaged")
    end
    # Calculate move order for this round
    pbCalculatePriority(true)
    PBDebug.log("")
    # Perform actions
    pbAttackPhasePriorityChangeMessages
    pbAttackPhaseCall
    pbAttackPhaseSwitch
    return if @decision > 0
    pbAttackPhaseItems
    return if @decision > 0
    pbAttackPhaseMegaEvolution
    pbAttackPhaseMoves
  end
end
