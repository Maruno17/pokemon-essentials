class Battle
  #=============================================================================
  # Choosing a move/target
  #=============================================================================
  def pbCanChooseMove?(idxBattler, idxMove, showMessages, sleepTalk = false)
    battler = @battlers[idxBattler]
    move = battler.moves[idxMove]
    return false unless move
    if move.pp == 0 && move.total_pp > 0 && !sleepTalk
      pbDisplayPaused(_INTL("There's no PP left for this move!")) if showMessages
      return false
    end
    if battler.effects[PBEffects::Encore] > 0
      idxEncoredMove = battler.pbEncoredMoveIndex
      return false if idxEncoredMove >= 0 && idxMove != idxEncoredMove
    end
    return battler.pbCanChooseMove?(move, true, showMessages, sleepTalk)
  end

  def pbCanChooseAnyMove?(idxBattler, sleepTalk = false)
    battler = @battlers[idxBattler]
    battler.eachMoveWithIndex do |m, i|
      next if m.pp == 0 && m.total_pp > 0 && !sleepTalk
      if battler.effects[PBEffects::Encore] > 0
        idxEncoredMove = battler.pbEncoredMoveIndex
        next if idxEncoredMove >= 0 && i != idxEncoredMove
      end
      next if !battler.pbCanChooseMove?(m, true, false, sleepTalk)
      return true
    end
    return false
  end

  # Called when the Pokémon is Encored, or if it can't use any of its moves.
  # Makes the Pokémon use the Encored move (if Encored), or Struggle.
  def pbAutoChooseMove(idxBattler, showMessages = true)
    battler = @battlers[idxBattler]
    if battler.fainted?
      pbClearChoice(idxBattler)
      return true
    end
    # Encore
    idxEncoredMove = battler.pbEncoredMoveIndex
    if idxEncoredMove >= 0 && pbCanChooseMove?(idxBattler, idxEncoredMove, false)
      encoreMove = battler.moves[idxEncoredMove]
      @choices[idxBattler][0] = :UseMove         # "Use move"
      @choices[idxBattler][1] = idxEncoredMove   # Index of move to be used
      @choices[idxBattler][2] = encoreMove       # Battle::Move object
      @choices[idxBattler][3] = -1               # No target chosen yet
      return true if singleBattle?
      if pbOwnedByPlayer?(idxBattler)
        if showMessages
          pbDisplayPaused(_INTL("{1} has to use {2}!", battler.name, encoreMove.name))
        end
        return pbChooseTarget(battler, encoreMove)
      end
      return true
    end
    # Struggle
    if pbOwnedByPlayer?(idxBattler) && showMessages
      pbDisplayPaused(_INTL("{1} has no moves left!", battler.name))
    end
    @choices[idxBattler][0] = :UseMove    # "Use move"
    @choices[idxBattler][1] = -1          # Index of move to be used
    @choices[idxBattler][2] = @struggle   # Struggle Battle::Move object
    @choices[idxBattler][3] = -1          # No target chosen yet
    return true
  end

  def pbRegisterMove(idxBattler, idxMove, showMessages = true)
    battler = @battlers[idxBattler]
    move = battler.moves[idxMove]
    return false if !pbCanChooseMove?(idxBattler, idxMove, showMessages)
    @choices[idxBattler][0] = :UseMove   # "Use move"
    @choices[idxBattler][1] = idxMove    # Index of move to be used
    @choices[idxBattler][2] = move       # Battle::Move object
    @choices[idxBattler][3] = -1         # No target chosen yet
    return true
  end

  def pbChoseMove?(idxBattler, moveID)
    return false if !@battlers[idxBattler] || @battlers[idxBattler].fainted?
    if @choices[idxBattler][0] == :UseMove && @choices[idxBattler][1]
      return @choices[idxBattler][2].id == moveID
    end
    return false
  end

  def pbChoseMoveFunctionCode?(idxBattler, code)
    return false if @battlers[idxBattler].fainted?
    if @choices[idxBattler][0] == :UseMove && @choices[idxBattler][1]
      return @choices[idxBattler][2].function == code
    end
    return false
  end

  def pbRegisterTarget(idxBattler, idxTarget)
    @choices[idxBattler][3] = idxTarget   # Set target of move
  end

  # Returns whether the idxTarget will be targeted by a move with target_data
  # used by a battler in idxUser.
  def pbMoveCanTarget?(idxUser, idxTarget, target_data)
    return false if target_data.num_targets == 0
    case target_data.id
    when :NearAlly
      return false if opposes?(idxUser, idxTarget)
      return false if !nearBattlers?(idxUser, idxTarget)
    when :UserOrNearAlly
      return true if idxUser == idxTarget
      return false if opposes?(idxUser, idxTarget)
      return false if !nearBattlers?(idxUser, idxTarget)
    when :AllAllies
      return false if idxUser == idxTarget
      return false if opposes?(idxUser, idxTarget)
    when :UserAndAllies
      return false if opposes?(idxUser, idxTarget)
    when :NearFoe, :RandomNearFoe, :AllNearFoes
      return false if !opposes?(idxUser, idxTarget)
      return false if !nearBattlers?(idxUser, idxTarget)
    when :Foe
      return false if !opposes?(idxUser, idxTarget)
    when :AllFoes
      return false if !opposes?(idxUser, idxTarget)
    when :NearOther, :AllNearOthers
      return false if !nearBattlers?(idxUser, idxTarget)
    when :Other
      return false if idxUser == idxTarget
    end
    return true
  end

  #=============================================================================
  # Turn order calculation (priority)
  #=============================================================================
  def pbCalculatePriority(fullCalc = false, indexArray = nil)
    needRearranging = false
    if fullCalc
      @priorityTrickRoom = (@field.effects[PBEffects::TrickRoom] > 0)
      # Recalculate everything from scratch
      randomOrder = Array.new(maxBattlerIndex + 1) { |i| i }
      (randomOrder.length - 1).times do |i|   # Can't use shuffle! here
        r = i + pbRandom(randomOrder.length - i)
        randomOrder[i], randomOrder[r] = randomOrder[r], randomOrder[i]
      end
      @priority.clear
      (0..maxBattlerIndex).each do |i|
        b = @battlers[i]
        next if !b
        # [battler, speed, sub-priority from ability, sub-priority from item,
        #  final sub-priority, priority, tie-breaker order]
        entry = [b, b.pbSpeed, 0, 0, 0, 0, randomOrder[i]]
        if @choices[b.index][0] == :UseMove || @choices[b.index][0] == :Shift
          # Calculate move's priority
          if @choices[b.index][0] == :UseMove
            move = @choices[b.index][2]
            pri = move.pbPriority(b)
            if b.abilityActive?
              pri = Battle::AbilityEffects.triggerPriorityChange(b.ability, b, move, pri)
            end
            entry[5] = pri
            @choices[b.index][4] = pri
          end
          # Calculate sub-priority changes (first/last within priority bracket)
          # Abilities (Stall)
          if b.abilityActive?
            entry[2] = Battle::AbilityEffects.triggerPriorityBracketChange(b.ability, b, self)
          end
          # Items (Quick Claw, Custap Berry, Lagging Tail, Full Incense)
          if b.itemActive?
            entry[3] = Battle::ItemEffects.triggerPriorityBracketChange(b.item, b, self)
          end
        end
        @priority.push(entry)
      end
      needRearranging = true
    else
      if (@field.effects[PBEffects::TrickRoom] > 0) != @priorityTrickRoom
        needRearranging = true
        @priorityTrickRoom = (@field.effects[PBEffects::TrickRoom] > 0)
      end
      # Recheck all battler speeds and changes to priority caused by abilities
      @priority.each do |entry|
        next if !entry
        next if indexArray && !indexArray.include?(entry[0].index)
        # Recalculate speed of battler
        newSpeed = entry[0].pbSpeed
        needRearranging = true if newSpeed != entry[1]
        entry[1] = newSpeed
        # Recalculate move's priority in case ability has changed
        choice = @choices[entry[0].index]
        if choice[0] == :UseMove
          move = choice[2]
          pri = move.pbPriority(entry[0])
          if entry[0].abilityActive?
            pri = Battle::AbilityEffects.triggerPriorityChange(entry[0].ability, entry[0], move, pri)
          end
          needRearranging = true if pri != entry[5]
          entry[5] = pri
          choice[4] = pri
        end
        # Recalculate sub-priority change caused by ability (but not by item)
        if entry[0].abilityActive?
          subPri = Battle::AbilityEffects.triggerPriorityBracketChange(entry[0].ability, entry[0], self)
          needRearranging = true if subPri != entry[2]
          entry[2] = subPri
        end
      end
    end
    # Calculate each battler's overall sub-priority, and whether its ability or
    # item is responsible
    # NOTE: Going fast beats going slow. A Pokémon with Stall and Quick Claw
    #       will go first in its priority bracket if Quick Claw triggers,
    #       regardless of Stall.
    @priority.each do |entry|
      entry[0].effects[PBEffects::PriorityAbility] = false
      entry[0].effects[PBEffects::PriorityItem] = false
      subpri = entry[2]   # Sub-priority from ability
      if (subpri == 0 && entry[3] != 0) ||   # Ability has no effect, item has effect
         (subpri < 0 && entry[3] >= 1)   # Ability makes it slower, item makes it faster
        subpri = entry[3]   # Sub-priority from item
        entry[0].effects[PBEffects::PriorityItem] = true
      elsif subpri != 0   # Ability has effect, item had superfluous/no effect
        entry[0].effects[PBEffects::PriorityAbility] = true
      end
      entry[4] = subpri   # Final sub-priority
    end
    # Reorder the priority array
    if needRearranging
      @priority.sort! { |a, b|
        if a[5] != b[5]
          # Sort by priority (highest value first)
          b[5] <=> a[5]
        elsif a[4] != b[4]
          # Sort by sub-priority (highest value first)
          b[4] <=> a[4]
        elsif @priorityTrickRoom
          # Sort by speed (lowest first), and use tie-breaker if necessary
          (a[1] == b[1]) ? b[6] <=> a[6] : a[1] <=> b[1]
        else
          # Sort by speed (highest first), and use tie-breaker if necessary
          (a[1] == b[1]) ? b[6] <=> a[6] : b[1] <=> a[1]
        end
      }
      # Write the priority order to the debug log
      logMsg = (fullCalc) ? "[Round order] " : "[Round order recalculated] "
      comma = false
      @priority.each do |entry|
        logMsg += ", " if comma
        logMsg += "#{entry[0].pbThis(comma)} (#{entry[0].index})"
        comma = true
      end
      PBDebug.log(logMsg)
    end
  end

  def pbPriority(onlySpeedSort = false)
    ret = []
    if onlySpeedSort
      # Sort battlers by their speed stats and tie-breaker order only.
      tempArray = []
      @priority.each { |pArray| tempArray.push([pArray[0], pArray[1], pArray[6]]) }
      tempArray.sort! { |a, b| (a[1] == b[1]) ? b[2] <=> a[2] : b[1] <=> a[1] }
      tempArray.each { |tArray| ret.push(tArray[0]) }
    else
      # Sort battlers by priority, sub-priority and their speed. Ties are
      # resolved in the same way each time this method is called in a round.
      @priority.each { |pArray| ret.push(pArray[0]) if !pArray[0].fainted? }
    end
    return ret
  end
end
