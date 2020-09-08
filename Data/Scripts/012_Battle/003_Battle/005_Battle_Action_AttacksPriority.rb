class PokeBattle_Battle
  #=============================================================================
  # Choosing a move/target
  #=============================================================================
  def pbCanChooseMove?(idxBattler,idxMove,showMessages,sleepTalk=false)
    battler = @battlers[idxBattler]
    move = battler.moves[idxMove]
    return false unless move && move.id>0
    if move.pp==0 && move.totalpp>0 && !sleepTalk
      pbDisplayPaused(_INTL("There's no PP left for this move!")) if showMessages
      return false
    end
    if battler.effects[PBEffects::Encore]>0
      idxEncoredMove = battler.pbEncoredMoveIndex
      return false if idxEncoredMove>=0 && idxMove!=idxEncoredMove
    end
    return battler.pbCanChooseMove?(move,true,showMessages,sleepTalk)
  end

  def pbCanChooseAnyMove?(idxBattler,sleepTalk=false)
    battler = @battlers[idxBattler]
    battler.eachMoveWithIndex do |m,i|
      next if m.pp==0 && m.totalpp>0 && !sleepTalk
      if battler.effects[PBEffects::Encore]>0
        idxEncoredMove = battler.pbEncoredMoveIndex
        next if idxEncoredMove>=0 && i!=idxEncoredMove
      end
      next if !battler.pbCanChooseMove?(m,true,false,sleepTalk)
      return true
    end
    return false
  end

  # Called when the Pokémon is Encored, or if it can't use any of its moves.
  # Makes the Pokémon use the Encored move (if Encored), or Struggle.
  def pbAutoChooseMove(idxBattler,showMessages=true)
    battler = @battlers[idxBattler]
    if battler.fainted?
      pbClearChoice(idxBattler)
      return true
    end
    # Encore
    idxEncoredMove = battler.pbEncoredMoveIndex
    if idxEncoredMove>=0 && pbCanChooseMove?(idxBattler,idxEncoredMove,false)
      encoreMove = battler.moves[idxEncoredMove]
      @choices[idxBattler][0] = :UseMove         # "Use move"
      @choices[idxBattler][1] = idxEncoredMove   # Index of move to be used
      @choices[idxBattler][2] = encoreMove       # PokeBattle_Move object
      @choices[idxBattler][3] = -1               # No target chosen yet
      return true if singleBattle?
      if pbOwnedByPlayer?(idxBattler)
        if showMessages
          pbDisplayPaused(_INTL("{1} has to use {2}!",battler.name,encoreMove.name))
        end
        return pbChooseTarget(battler,encoreMove)
      end
      return true
    end
    # Struggle
    if pbOwnedByPlayer?(idxBattler) && showMessages
      pbDisplayPaused(_INTL("{1} has no moves left!",battler.name))
    end
    @choices[idxBattler][0] = :UseMove    # "Use move"
    @choices[idxBattler][1] = -1          # Index of move to be used
    @choices[idxBattler][2] = @struggle   # Struggle PokeBattle_Move object
    @choices[idxBattler][3] = -1          # No target chosen yet
    return true
  end

  def pbRegisterMove(idxBattler,idxMove,showMessages=true)
    battler = @battlers[idxBattler]
    move = battler.moves[idxMove]
    return false if !pbCanChooseMove?(idxBattler,idxMove,showMessages)
    @choices[idxBattler][0] = :UseMove   # "Use move"
    @choices[idxBattler][1] = idxMove    # Index of move to be used
    @choices[idxBattler][2] = move       # PokeBattle_Move object
    @choices[idxBattler][3] = -1         # No target chosen yet
    return true
  end

  def pbChoseMove?(idxBattler,moveID)
    return false if !@battlers[idxBattler] || @battlers[idxBattler].fainted?
    idxMove = @choices[idxBattler][1]
    if @choices[idxBattler][0]==:UseMove && idxMove>=0
      chosenMoveID = @battlers[idxBattler].moves[idxMove].id
      return isConst?(chosenMoveID,PBMoves,moveID)
    end
    return false
  end

  def pbChoseMoveFunctionCode?(idxBattler,code)
    return false if @battlers[idxBattler].fainted?
    idxMove = @choices[idxBattler][1]
    if @choices[idxBattler][0]==:UseMove && idxMove>=0
      return @battlers[idxBattler].moves[idxMove].function==code
    end
    return false
  end

  def pbRegisterTarget(idxBattler,idxTarget)
    @choices[idxBattler][3] = idxTarget   # Set target of move
  end

  # Returns whether the idxTarget will be targeted by a move with targetType
  # used by a battler in idxUser.
  def pbMoveCanTarget?(idxUser,idxTarget,targetType)
    return false if PBTargets.noTargets?(targetType)
    case targetType
    when PBTargets::NearAlly
      return false if opposes?(idxUser,idxTarget)
      return false if !nearBattlers?(idxUser,idxTarget)
    when PBTargets::UserOrNearAlly
      return true if idxUser==idxTarget
      return false if opposes?(idxUser,idxTarget)
      return false if !nearBattlers?(idxUser,idxTarget)
    when PBTargets::NearFoe, PBTargets::AllNearFoes, PBTargets::RandomNearFoe
      return false if !opposes?(idxUser,idxTarget)
      return false if !nearBattlers?(idxUser,idxTarget)
    when PBTargets::Foe
      return false if !opposes?(idxUser,idxTarget)
    when PBTargets::NearOther, PBTargets::AllNearOthers
      return false if !nearBattlers?(idxUser,idxTarget)
    when PBTargets::Other
      return false if idxUser==idxTarget
    when PBTargets::UserAndAllies
      return false if opposes?(idxUser,idxTarget)
    when PBTargets::AllFoes
      return false if !opposes?(idxUser,idxTarget)
    end
    return true
  end

  #=============================================================================
  # Turn order calculation (priority)
  #=============================================================================
  def pbCalculatePriority(fullCalc=false,indexArray=nil)
    needRearranging = false
    if fullCalc
      @priorityTrickRoom = (@field.effects[PBEffects::TrickRoom]>0)
      # Recalculate everything from scratch
      randomOrder = Array.new(maxBattlerIndex+1) { |i| i }
      (randomOrder.length-1).times do |i|   # Can't use shuffle! here
        r = i+pbRandom(randomOrder.length-i)
        randomOrder[i], randomOrder[r] = randomOrder[r], randomOrder[i]
      end
      @priority.clear
      for i in 0..maxBattlerIndex
        b = @battlers[i]
        next if !b
        # [battler, speed, sub-priority, priority, tie-breaker order]
        bArray = [b,b.pbSpeed,0,0,randomOrder[i]]
        if @choices[b.index][0]==:UseMove || @choices[b.index][0]==:Shift
          # Calculate move's priority
          if @choices[b.index][0]==:UseMove
            move = @choices[b.index][2]
            pri = move.priority
            if b.abilityActive?
              pri = BattleHandlers.triggerPriorityChangeAbility(b.ability,b,move,pri)
            end
            bArray[3] = pri
            # Grassy Glide
            if move.function == "191" &&
               @field.terrain == PBBattleTerrains::Grassy &&
               !b.airborne?
              pri+=1
            end
            @choices[b.index][4] = pri
          end
          # Calculate sub-priority (first/last within priority bracket)
          # NOTE: Going fast beats going slow. A Pokémon with Stall and Quick
          #       Claw will go first in its priority bracket if Quick Claw
          #       triggers, regardless of Stall.
          subPri = 0
          # Abilities (Stall)
          if b.abilityActive?
            newSubPri = BattleHandlers.triggerPriorityBracketChangeAbility(b.ability,
             b,subPri,self)
            if subPri!=newSubPri
              subPri = newSubPri
              b.effects[PBEffects::PriorityAbility] = true
              b.effects[PBEffects::PriorityItem]    = false
            end
          end
          # Items (Quick Claw, Custap Berry, Lagging Tail, Full Incense)
          if b.itemActive?
            newSubPri = BattleHandlers.triggerPriorityBracketChangeItem(b.item,
               b,subPri,self)
            if subPri!=newSubPri
              subPri = newSubPri
              b.effects[PBEffects::PriorityAbility] = false
              b.effects[PBEffects::PriorityItem]    = true
            end
          end
          bArray[2] = subPri
        end
        @priority.push(bArray)
      end
      needRearranging = true
    else
      if (@field.effects[PBEffects::TrickRoom]>0)!=@priorityTrickRoom
        needRearranging = true
        @priorityTrickRoom = (@field.effects[PBEffects::TrickRoom]>0)
      end
      # Just recheck all battler speeds
      @priority.each do |orderArray|
        next if !orderArray
        next if indexArray && !indexArray.include?(orderArray[0].index)
        oldSpeed = orderArray[1]
        orderArray[1] = orderArray[0].pbSpeed
        needRearranging = true if orderArray[1]!=oldSpeed
      end
    end
    # Reorder the priority array
    if needRearranging
      @priority.sort! { |a,b|
        if a[3]!=b[3]
          # Sort by priority (highest value first)
          b[3]<=>a[3]
        elsif a[2]!=b[2]
          # Sort by sub-priority (highest value first)
          b[2]<=>a[2]
        elsif @priorityTrickRoom
          # Sort by speed (lowest first), and use tie-breaker if necessary
          (a[1]==b[1]) ? b[4]<=>a[4] : a[1]<=>b[1]
        else
          # Sort by speed (highest first), and use tie-breaker if necessary
          (a[1]==b[1]) ? b[4]<=>a[4] : b[1]<=>a[1]
        end
      }
      # Write the priority order to the debug log
      logMsg = (fullCalc) ? "[Round order] " : "[Round order recalculated] "
      comma = false
      @priority.each do |orderArray|
        logMsg += ", " if comma
        logMsg += "#{orderArray[0].pbThis(comma)} (#{orderArray[0].index})"
        comma = true
      end
      PBDebug.log(logMsg)
    end
  end

  # NOTE: In Gen 8, battler speeds stored in priority are recalculated far more
  #       frequently than they used to be. There are several quoted-out calls to
  #       pbCalculatePriority in these scripts which do this; just unquote them.
  def pbPriority(onlySpeedSort=false)
    ret = []
    if onlySpeedSort
      # Sort battlers by their speed stats and tie-breaker order only.
      tempArray = []
      @priority.each { |pArray| tempArray.push([pArray[0],pArray[1],pArray[4]]) }
      tempArray.sort! { |a,b| (a[1]==b[1]) ? b[2]<=>a[2] : b[1]<=>a[1] }
      tempArray.each { |tArray| ret.push(tArray[0]) }
    else
      # Sort battlers by priority, sub-priority and their speed. Ties are
      # resolved in the same way each time this method is called in a round.
      @priority.each { |pArray| ret.push(pArray[0]) if !pArray[0].fainted? }
    end
    return ret
  end
end
